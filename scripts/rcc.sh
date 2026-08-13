#!/usr/bin/env bash
# rcc — compile, run, and clean up a single C/C++ source file.
# Usage: rcc foo.c [foo.cpp ...]

for file_src in "$@"; do
  if [[ ! -f "$file_src" ]]; then
    echo "$file_src is not a file"
    continue
  fi

  # Strip the source extension to derive the output binary name
  file_out="${file_src%.*}"

  case "$file_src" in
    *.cpp)
      # Compile with C++17, optimise, enable most warnings, then run, then delete
      g++ -std=c++17 -O2 -Wall -Wextra "$file_src" -o "$file_out" \
        && "./$file_out" \
        && rm -f "$file_out"
      ;;
    *.c)
      # Compile with C11, optimise, enable most warnings, then run, then delete
      gcc -std=c11 -O2 -Wall -Wextra "$file_src" -o "$file_out" \
        && "./$file_out" \
        && rm -f "$file_out"
      ;;
    *)
      echo "$file_src is not a C or C++ file"
      ;;
  esac
done
