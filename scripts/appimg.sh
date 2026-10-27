#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# Manage AppImages installed outside the Nix store: one command per app in
# ~/.local/bin, a real .desktop entry carrying the app's own name, and icons
# unpacked into the hicolor theme.
#
# On NixOS the file runs through binfmt -> appimage-run, so it never answers
# --appimage-extract (the argument is handed to the app itself). The squashfs
# payload is therefore unpacked directly, using the same offset math as
# nixpkgs appimage-exec.sh: e_shoff + e_shentsize * e_shnum.

bin_dir=$HOME/.local/bin
entry_dir=$HOME/.local/share/applications
theme_dir=$HOME/.local/share/icons/hicolor
pixmap_dir=$HOME/.local/share/pixmaps
cache_dir=$HOME/.cache/appimage-run

tmp_dir=''
cleanup() {
  if [ -n "$tmp_dir" ]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

usage() {
  cat <<'EOF'
Usage: appimg <command> [args]

Commands:
  install <file.AppImage> [name]   Install an AppImage: copy to ~/.local/bin,
                                   write a .desktop entry, unpack its icons
  remove [-n] <name>...            Uninstall: binary, .desktop entry, icons,
                                   and the appimage-run extraction cache
  list                             Show installed AppImage apps and cache use

Options for remove:
  -n, --dry-run   Print what would be deleted, touch nothing
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

is_appimage() {
  [ -f "$1" ] && [ "$(od -An -tx1 -j8 -N2 "$1" | tr -d ' ')" = "4149" ]
}

# Name of the .desktop entry whose Exec runs bin/<name>.
entry_for() {
  local entry
  for entry in "$entry_dir"/*.desktop; do
    [ -f "$entry" ] || continue
    if grep -qE "^Exec=[\"']?[^ ]*/bin/$1([\"' ]|$)" "$entry"; then
      printf '%s\n' "$entry"
      return 0
    fi
  done
  return 1
}

cmd_install() {
  if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    usage >&2
    exit 1
  fi

  local src=$1 name default_name
  [ -f "$src" ] || die "$src: no such file"

  default_name=$(basename "$src")
  default_name=${default_name%.AppImage}
  default_name=${default_name%.appimage}
  name=${2:-${default_name%%-[0-9]*}}
  name=${name%.AppImage}
  [ -n "$name" ] || die "cannot derive a command name from $src; pass one explicitly"

  mkdir -p "$bin_dir" "$entry_dir"
  install -m 755 "$src" "$bin_dir/$name"

  local root
  tmp_dir=$(mktemp -d)
  root=$tmp_dir/root

  unpack() {
    case $(od -An -tu1 -j10 -N1 "$src" | tr -d ' ') in
      1)
        mkdir -p "$root"
        bsdtar -xf "$src" -C "$root"
        ;;
      2)
        local shoff shentsize shnum
        shoff=$(od -An -tu8 -j40 -N8 "$src" | tr -d ' ')
        shentsize=$(od -An -tu2 -j58 -N2 "$src" | tr -d ' ')
        shnum=$(od -An -tu2 -j60 -N2 "$src" | tr -d ' ')
        unsquashfs -q -d "$root" -o $((shoff + shentsize * shnum)) "$src"
        ;;
      *)
        return 1
        ;;
    esac
  }

  if ! is_appimage "$src"; then
    echo "warning: $src has no AppImage magic; name and icon stay generic" >&2
  elif ! unpack; then
    echo "warning: unpack failed; name and icon stay generic" >&2
  fi

  key() {
    awk -v k="$2=" 'index($0, k) == 1 { sub(k, ""); print; exit }' "$1"
  }

  # Launchers resolve Icon= by name against the icon themes, so the artwork has
  # to sit in a size directory: $root_icon is the fallback copy.
  has_icon() {
    local candidate
    for candidate in "$theme_dir"/*"/apps/$1.png" "$theme_dir"/*"/apps/$1.svg" "$pixmap_dir/$1.png" "$pixmap_dir/$1.svg"; do
      [ -f "$candidate" ] && return 0
    done
    return 1
  }

  local app_name=$name entry_id=$name categories=Utility
  local comment='' generic='' keywords='' wmclass=''
  local icon_id='' root_icon='' icon_ref='' entry=''

  if [ -d "$root" ]; then
    entry=$(find "$root" -maxdepth 1 -name '*.desktop' -print -quit)
    entry=${entry:-$(find "$root" -maxdepth 4 -path '*/applications/*.desktop' -print -quit)}
    if [ -n "$entry" ]; then
      entry_id=$(basename "$entry" .desktop)
      app_name=$(key "$entry" Name)
      app_name=${app_name:-$name}
      generic=$(key "$entry" GenericName)
      comment=$(key "$entry" Comment)
      categories=$(key "$entry" Categories)
      keywords=$(key "$entry" Keywords)
      wmclass=$(key "$entry" StartupWMClass)
      icon_ref=$(key "$entry" Icon)
      icon_id=${icon_ref##*/}
      case $icon_id in
        *.png | *.svg | *.xpm) icon_id=${icon_id%.*} ;;
      esac
    fi

    local candidate
    for candidate in "$root/$icon_id.svg" "$root/$icon_id.png" "$root/.DirIcon"; do
      if [ -f "$candidate" ]; then
        root_icon=$candidate
        break
      fi
    done

    if [ -z "$icon_id" ] && [ -n "$root_icon" ]; then
      icon_id=$entry_id
    fi

    if [ -n "$icon_id" ]; then
      if [ -d "$root/usr/share/icons/hicolor" ]; then
        mkdir -p "$theme_dir"
        cp -a "$root/usr/share/icons/hicolor/." "$theme_dir/"
      fi

      if [ -n "$root_icon" ] && ! has_icon "$icon_id"; then
        local ext=
        case $(file --brief --mime-type "$root_icon") in
          image/svg+xml) ext=svg ;;
          image/png) ext=png ;;
        esac
        if [ -n "$ext" ]; then
          mkdir -p "$pixmap_dir"
          cp -f "$root_icon" "$pixmap_dir/$icon_id.$ext"
        fi
      fi
    fi
  fi

  icon_ref=
  if [ -n "$icon_id" ] && has_icon "$icon_id"; then
    icon_ref=$icon_id
  fi

  local entry_file=$entry_dir/$entry_id.desktop
  {
    printf '[Desktop Entry]\n'
    printf 'Type=Application\n'
    printf 'Name=%s\n' "$app_name"
    [ -n "$generic" ] && printf 'GenericName=%s\n' "$generic"
    [ -n "$comment" ] && printf 'Comment=%s\n' "$comment"
    printf 'Exec=%s %%U\n' "$bin_dir/$name"
    [ -n "$icon_ref" ] && printf 'Icon=%s\n' "$icon_ref"
    [ -n "$categories" ] && printf 'Categories=%s\n' "${categories%;}"
    [ -n "$keywords" ] && printf 'Keywords=%s\n' "${keywords%;}"
    [ -n "$wmclass" ] && printf 'StartupWMClass=%s\n' "$wmclass"
    printf 'Terminal=false\n'
  } >"$entry_file"
  chmod 644 "$entry_file"

  update-desktop-database "$entry_dir" >/dev/null 2>&1 || true

  echo "Installed $app_name"
  echo "  command : $name"
  echo "  shortcut: $entry_file"
  echo "  icon    : ${icon_ref:-none}"
}

cmd_remove() {
  local dry=0 name bin hash entry icon root f arg
  local names=()

  for arg in "$@"; do
    case $arg in
      -n | --dry-run) dry=1 ;;
      -*) die "unknown option: $arg" ;;
      *) names+=("$arg") ;;
    esac
  done
  [ "${#names[@]}" -gt 0 ] || {
    usage >&2
    exit 1
  }

  wipe() {
    if [ "$dry" = 1 ]; then
      echo "  would remove: $1"
    else
      rm -rf "$1"
    fi
  }

  for name in "${names[@]}"; do
    bin=$bin_dir/$name
    if [ ! -e "$bin" ]; then
      echo "skip $name: $bin does not exist" >&2
      continue
    fi

    echo "$name"
    hash=$(sha256sum "$bin" | cut -d' ' -f1)
    wipe "$bin"

    if entry=$(entry_for "$name"); then
      icon=$(awk -F= '$1 == "Icon" { print $2; exit }' "$entry")
      echo "  entry: $(basename "$entry")"
      wipe "$entry"
      if [ -n "${icon:-}" ]; then
        for root in "$theme_dir" "$pixmap_dir"; do
          [ -d "$root" ] || continue
          while IFS= read -r -d '' f; do
            echo "  icon : ${f#"$HOME"/.local/share/icons/hicolor/}"
            wipe "$f"
          done < <(find "$root" -type f \( -name "$icon.png" -o -name "$icon.svg" -o -name "$icon.xpm" \) -print0)
        done
      fi
    else
      echo "  entry: none found" >&2
    fi

    if [ -d "$cache_dir/$hash" ]; then
      echo "  cache: $hash ($(du -sh "$cache_dir/$hash" | cut -f1))"
      wipe "$cache_dir/$hash"
    fi
  done

  [ "$dry" = 1 ] && echo "dry run: nothing deleted"
  [ "$dry" = 1 ] || update-desktop-database "$entry_dir" >/dev/null 2>&1 || true
  return 0
}

cmd_list() {
  local bin name hash entry found=0 dir
  declare -A live=()

  printf '%-22s %8s %8s  %s\n' "COMMAND" "SIZE" "CACHE" "SHORTCUT"
  for bin in "$bin_dir"/*; do
    [ -f "$bin" ] || continue
    is_appimage "$bin" || continue
    found=1
    name=$(basename "$bin")
    hash=$(sha256sum "$bin" | cut -d' ' -f1)
    live[$hash]=1
    entry=$(entry_for "$name" 2>/dev/null | xargs -r basename || true)
    printf '%-22s %8s %8s  %s\n' \
      "$name" \
      "$(du -h "$bin" | cut -f1)" \
      "$(du -sh "$cache_dir/$hash" 2>/dev/null | cut -f1 || echo -)" \
      "${entry:-none}"
  done
  [ "$found" = 1 ] || echo "(no AppImage apps installed in $bin_dir)"

  # Cache dirs keyed by a hash no installed binary has are leftovers from
  # replaced versions; appimage-run never prunes them.
  for dir in "$cache_dir"/*/; do
    [ -d "$dir" ] || continue
    hash=$(basename "$dir")
    [ -n "${live[$hash]:-}" ] || echo "orphan cache: $hash ($(du -sh "$dir" | cut -f1))"
  done
}

case ${1:-} in
  install) shift && cmd_install "$@" ;;
  remove) shift && cmd_remove "$@" ;;
  list) shift && cmd_list "$@" ;;
  -h | --help | help) usage ;;
  "") usage >&2; exit 1 ;;
  *) die "unknown command: $1 (try: appimg --help)" ;;
esac
