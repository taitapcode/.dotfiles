#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# Install an AppImage as a fixed command plus a menu shortcut: copy it to
# ~/.local/bin, unpack the embedded .desktop entry and its icons into the
# hicolor theme, then write a shortcut that keeps the app's real name and
# an icon id launchers can actually resolve.
#
# On NixOS the file runs through binfmt -> appimage-run, so it never answers
# --appimage-extract (the argument is handed to the app itself). The squashfs
# payload is therefore unpacked directly, using the same offset math as
# nixpkgs appimage-exec.sh: e_shoff + e_shentsize * e_shnum.

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: appimage-install <file.AppImage> [command-name]" >&2
  exit 1
fi

src=$1
if [ ! -f "$src" ]; then
  echo "error: $src: no such file" >&2
  exit 1
fi

default_name=$(basename "$src")
default_name=${default_name%.AppImage}
default_name=${default_name%.appimage}
name=${2:-${default_name%%-[0-9]*}}
name=${name%.AppImage}

bin_dir=$HOME/.local/bin
entry_dir=$HOME/.local/share/applications
theme_dir=$HOME/.local/share/icons/hicolor
pixmap_dir=$HOME/.local/share/pixmaps

mkdir -p "$bin_dir" "$entry_dir"
install -m 755 "$src" "$bin_dir/$name"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
root=$tmp/root

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

if [ "$(od -An -tx1 -j8 -N2 "$src" | tr -d ' ')" != "4149" ]; then
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

app_name=$name
entry_id=$name
comment=
generic=
categories=Utility
keywords=
wmclass=
icon_id=
root_icon=

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
      case $(file --brief --mime-type "$root_icon") in
        image/svg+xml) ext=svg ;;
        image/png) ext=png ;;
        *) ext= ;;
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

entry_file=$entry_dir/$entry_id.desktop
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
