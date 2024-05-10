#!/usr/bin/env bash

set -e

if [ -z "$PROJECT_ROOT" ]; then
  echo "PROJECT_ROOT is not set. Exiting."
  exit 1
fi

if [ "$(hostname)" != "midnight" ]; then
  module use /soft/modulefiles
fi

export TMPDIR="${PROJECT_ROOT}/.tmp"
mkdir -p "$TMPDIR"
export CC=$(which gcc)
export CXX=$(which g++)
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${PROJECT_ROOT}/.venv/hwloc/lib"
export LIBRARY_PATH="$LIBRARY_PATH:${PROJECT_ROOT}/.venv/hwloc/lib"
export PKG_CONFIG_PATH="${PROJECT_ROOT}/.venv/hwloc/lib/pkgconfig:$PKG_CONFIG_PATH"

pip install -r "$PROJECT_ROOT"/requirements.txt --global-option=build_ext --global-option="-I${PROJECT_ROOT}/.venv/hwloc/include" --global-option="-L${PROJECT_ROOT}/.venv/hwloc/lib"

