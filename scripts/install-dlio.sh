#!/usr/bin/env bash

source ${PROJECT_ROOT}/scripts/utils.sh

module use /soft/modulefiles

set -e

# sanity check
log_info "Running sanity check"
log_info "GCC version: $(gcc --version)"
log_info "MPICH version: $(mpirun --version)"
export CC=$(which gcc)
export CXX=$(which g++)

set +e

# check if dlio_profiler is already installed
installed=$(python -c "import dlio_profiler" 2>&1)
if [[ $installed == *"No module named"* ]]; then
    set -e
    # Install DLIO Profiler
    log_info "Installing dlio_profiler"
    git clone git@github.com:hariharan-devarajan/dlio-profiler.git
    pushd dlio-profiler
    git checkout tags/v0.0.5 -b v0.0.5
    git apply ${PROJECT_ROOT}/scripts/dlio-profiler.patch
    pip install .
    popd
    set +e
    rm -rf dlio-profiler
else
    log_info "dlio_profiler is already installed, skipping installation"
fi

installed=$(python -c "import dlio_benchmark" 2>&1)
if [[ $installed == *"No module named"* ]]; then
    set -e
    # Install DLIO Benchmark
    log_info "Installing dlio_benchmark"

    git clone https://github.com/argonne-lcf/dlio_benchmark
    pushd dlio_benchmark
    git apply ${PROJECT_ROOT}/scripts/dlio-benchmark.patch
    pip install .
    dlio_benchmark ++workload.workflow.generate_data=True
    popd
    set +e
else
    log_info "dlio_benchmark is already installed, skipping installation"
fi