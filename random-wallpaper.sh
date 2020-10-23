#!/bin/bash

# Add to crontab to change wallpaper periodically.

set -e

WALLPAPER_DIR=/usr/share/backgrounds 
SESSION_PROG=gnome-session  # Used to discover DBUS_SESSION_BUS_ADDRESS.

function info_log {
  if [ -n "${LOGFILE}" ]; then
    echo "$@" >> "${LOGFILE}"
  fi
}

function error_log {
  info_log "$@"
  echo "$@" >2
}

function ensure_dbus_set {
  if [ -n "${DBUS_SESSION_BUS_ADDRESS}" ]; then
    info_log "DBUS_SESSION_BUS_ADDRESS already set"
    return
  fi;
  local pid=$(pgrep -u $(whoami) "${SESSION_PROG}" | head -n1)
  if [ -z "${pid}" ]; then
    error_log "No DBUS_SESSION_BUS_ADDRESS and no ${SESSION_PROG} running"
    exit 1
  fi
  export DBUS_SESSION_BUS_ADDRESS=$(
      grep -z DBUS_SESSION_BUS_ADDRESS < /proc/$pid/environ | cut -d= -f2-)
  if [ -z "${DBUS_SESSION_BUS_ADDRESS}" ]; then
    error_log "No DBUS_SESSION_BUS_ADDRESS and unable to fetch from environment for ${SESSION_PROG} (/proc/$pid/environ)"
    exit 2
  fi
}

function choose_background {
  find ${WALLPAPER_DIR} -name '*.jpg' -o -name '*.png' | shuf -n1
}

function set_background {
  info_log "$(date +"%Y-%m-%d %H:%M:%S") chose $1"
  gsettings set org.gnome.desktop.background picture-uri file://$1 >> /tmp/random-wallpaper.log
  ln -sf $1 $(dirname ${BASH_SOURCE[0]})/current-wallpaper.jpg
}

ensure_dbus_set
info_log DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS}
set_background "$(choose_background)"
