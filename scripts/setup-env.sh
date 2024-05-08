#!/usr/bin/env bash

source ${PROJECT_ROOT}/scripts/utils.sh

VENV_DIR="./.venv"
log_info "Checking if virtual environment exists"
if [ ! -d "${VENV_DIR}" ]; then
    mkdir -p "${VENV_DIR}"
    python -m venv "${VENV_DIR}" --system-site-packages
fi

source "${VENV_DIR}/bin/activate"