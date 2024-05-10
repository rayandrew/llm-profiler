#!/usr/bin/env bash

set -e

if [ -z "${PROJECT_ROOT}" ]; then
  echo "PROJECT_ROOT is not set"
  exit 1
fi

if [ -z "${MAMBA_ROOT_PREFIX}" ]; then
  echo "MAMBA_ROOT_PREFIX is not set"
  exit 1
fi

# check if micromamba is installed
if ! command -v micromamba &>/dev/null; then
  echo "micromamba could not be found"
  exit 1
fi

source "${PROJECT_ROOT}/scripts/utils.sh"
export PYTHONPATH="${PROJECT_ROOT}:${PYTHONPATH}"
export ENV_NAME="llm-profiler"

# check if ENV_NAME is already created in micromamba
if micromamba env list | grep -q "${ENV_NAME}"; then
  echo "Environment ${ENV_NAME} already exists"
else
  micromamba create -n ${ENV_NAME} python=3.11
fi

export PATH="${MAMBA_ROOT_PREFIX}/envs/${ENV_NAME}/bin:${PATH}"

VENV_DIR="./.venv"
log_info "Checking if virtual environment exists"
if [ ! -d "${VENV_DIR}" ]; then
  mkdir -p "${VENV_DIR}"
  python -m venv "${VENV_DIR}" --system-site-packages
fi

source "${VENV_DIR}/bin/activate"

export LIBRARY_PATH="$LIBRARY_PATH:${PROJECT_ROOT}/.venv/hwloc/lib"
export PKG_CONFIG_PATH="${PROJECT_ROOT}/.venv/hwloc/lib/pkgconfig:$PKG_CONFIG_PATH"
