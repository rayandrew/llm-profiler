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

set +e

# sanity check
log_info "Running sanity check"
dlio_profiler_installed=$(python -c "import dlio_profiler" 2>&1)
if [[ $dlio_profiler_installed == *"No module named"* ]]; then
    log_err "dlio_profiler is not installed"
else
    log_success "dlio_profiler is already installed, skipping installation"
fi


dlio_bench_installed=$(python -c "import dlio_benchmark" 2>&1)
if [[ $dlio_bench_installed == *"No module named"* ]]; then
    log_err "dlio_benchmark is not installed"
else
    log_success "dlio_benchmark is already installed, skipping installation"
fi

