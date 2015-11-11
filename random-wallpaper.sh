#!/bin/bash

set -e

WALLPAPER_DIR=/usr/share/backgrounds 

function choose_background {
  local TMPFILE=$(mktemp)
  find ${WALLPAPER_DIR} -name '*.jpg' -o -name '*.png' > "${TMPFILE}"
  local N=$(wc -l "${TMPFILE}" | cut -f1 -d' ')
  local R=$((RANDOM % N))
  head -n $((R + 1)) < "${TMPFILE}" | tail -n1  # Output choice
  rm "${TMPFILE}"
}

function set_background {
  gsettings set org.gnome.desktop.background picture-uri file://$1
}

set_background "$(choose_background)"
