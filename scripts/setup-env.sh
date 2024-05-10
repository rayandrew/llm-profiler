#!/usr/bin/env bash

set -e

export PROJECT_ROOT=$(pwd)
export PYTHONPATH="${PROJECT_ROOT}:${PYTHONPATH}"

module use /soft/modulefiles 
module load conda
conda activate

source ${PROJECT_ROOT}/scripts/utils.sh

VENV_DIR="./.venv"
log_info "Checking if virtual environment exists"
if [ ! -d "${VENV_DIR}" ]; then
    mkdir -p "${VENV_DIR}"
    python -m venv "${VENV_DIR}" --system-site-packages
fi


source "${VENV_DIR}/bin/activate"

export LIBRARY_PATH="$LIBRARY_PATH:${PROJECT_ROOT}/.venv/hwloc/lib"
export PKG_CONFIG_PATH="${PROJECT_ROOT}/.venv/hwloc/lib/pkgconfig:$PKG_CONFIG_PATH"