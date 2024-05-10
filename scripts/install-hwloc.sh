#!/usr/bin/env bash

set -e

if [ -z "$PROJECT_ROOT" ]; then
  echo "PROJECT_ROOT is not set. Exiting."
  exit 1
fi

# check hostname is midnight
if [ "$(hostname)" != "midnight" ]; then
  module use /soft/modulefiles
  # module load PrgEnv-nvhpc
  # module swap PrgEnv-nvhpc PrgEnv-gnu
fi

source "${PROJECT_ROOT}/scripts/utils.sh"

mkdir -p deps

if [ ! -d "hwloc" ]; then
  log_info "Cloning hwloc"
  git clone https://github.com/open-mpi/hwloc deps/hwloc
fi

export HWLOC_PREFIX="$PROJECT_ROOT/.venv/hwloc"
pushd deps/hwloc
log_info "Generating hwloc configuration"
./autogen.sh
log_info "Configuring hwloc"
./configure --prefix=$HWLOC_PREFIX
log_info "Installing hwloc"
make -j all install
export CPATH=$HWLOC_PREFIX/include:$CPATH
export LIBRARY_PATH=$HWLOC_PREFIX/lib:$LIBRARY_PATH
popd