#!/usr/bin/env bash

source ${PROJECT_ROOT}/scripts/utils.sh

module use /soft/modulefiles
module load mpiwrappers/cray-mpich-llvm
# module swap PrgEnv-nvhpc PrgEnv-gnu
# module load nvhpc-mixed
# module load llvm cray-mpich cray-pals


# sanity check
log_info "Running sanity check"
# log_info "LLVM version: $(llvm-config --version)"
# log_info "Clang version: $(clang --version)"
log_info "MPICH version: $(mpirun --version)"
# export CC=$(which gcc)
# export CXX=$(which g++)

log_info "${blue}Installing dlio_benchmark${reset}"

# pip install dlio-profiler-py

# Install DLIO
pushd dlio_benchmark
export DLIO_PROFILER_DISABLE_HWLOC=Off
pip install .[dlio_profiler]
popd