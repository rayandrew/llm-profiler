#!/usr/bin/env bash

set -e

if [ -z "$PROJECT_ROOT" ]; then
  echo "PROJECT_ROOT is not set. Exiting."
  exit 1
fi

source "${PROJECT_ROOT}/scripts/utils.sh"

export TMPDIR="${PROJECT_ROOT}/.tmp"
mkdir -p "$TMPDIR"

pip install -r "$PROJECT_ROOT"/requirements.txt # --global-option=build_ext --global-option="-I${PROJECT_ROOT}/.venv/hwloc/include" --global-option="-L${PROJECT_ROOT}/.venv/hwloc/lib"

