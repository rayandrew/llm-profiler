#!/usr/bin/env bash

set -e

if [ -z "$PROJECT_ROOT" ]; then
  echo "PROJECT_ROOT is not set. Exiting."
  exit 1
fi

if [ "$(hostname)" != "midnight" ]; then
  module use /soft/modulefiles
fi

jupyter lab

