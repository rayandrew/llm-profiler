#!/usr/bin/env bash

set -e


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

# export MODULEPATH=/soft/modulefiles/conda/:$MODULEPATH
# module load 2024-04-29  # This is the latest conda module on Polaris

# module use /soft/modulefiles 
# module load conda
# module load spack-pe-base cmake
# module load PrgEnv-gnu
# module load PrgEnv-nvhpc
# module swap PrgEnv-nvhpc PrgEnv-gnu
# module load nvhpc-mixed
# export CC=$(which gcc)
# export CXX=$(which g++)
# module load mpiwrappers/cray-mpich-llvm
# conda activate

# if [[ -e $ML_ENV ]]; then
#     conda activate $ML_ENV
# else
#     conda create -p $ML_ENV --clone base
#     conda activate $ML_ENV
#     yes | MPICC="cc -shared -target-accel=nvidia80" pip install --force-reinstall --no-cache-dir --no-binary=mpi4py mpi4py
#     yes | pip install --no-cache-dir git+https://github.com/hariharan-devarajan/dlio-profiler.git
#     pip uninstall -y torch horovod
#     yes | pip install --no-cache-dir horovod
# fi

# module unload nvhpc-mixed
# module load PrgEnv-nvhpc
# module swap PrgEnv-gnu PrgEnv-nvhpc
# module load nvhpc-mixed

# yes | MPICC="cc -shared -target-accel=nvidia80" pip install --force-reinstall --no-cache-dir --no-binary=mpi4py mpi4py
# yes | pip install --no-cache-dir "git+https://github.com/hariharan-devarajan/dlio-profiler.git"
# pushd dlio-profiler
# pip install .
# popd
# pip uninstall -y torch horovod
# yes | pip install --no-cache-dir horovod