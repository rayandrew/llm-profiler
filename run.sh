#!/bin/sh
#PBS -l select=1:system=polaris
#PBS -l place=scatter
#PBS -l walltime=01:00:00
#PBS -l filesystems=home:grand
#PBS -q debug
#PBS -A ReForMers
#PBS -e /grand/ReForMerS/llm-profiler/log/err
#PBS -o /grand/ReForMerS/llm-profiler/log/out
#PBS -N llm-profiler

# MPI example w/ 16 MPI ranks per node spread evenly across cores
NNODES=`wc -l < $PBS_NODEFILE`
NRANKS_PER_NODE=16
NDEPTH=4
NTHREADS=1
NTOTRANKS=$(( NNODES * NRANKS_PER_NODE ))

export PROJECT_ROOT="/lus/grand/projects/ReForMerS/llm-profiler"
cd $PROJECT_ROOT
source ${PROJECT_ROOT}/scripts/utils.sh

source ./scripts/setup-env.sh

log_info "NUM_OF_NODES= ${NNODES} TOTAL_NUM_RANKS= ${NTOTRANKS} RANKS_PER_NODE= ${NRANKS_PER_NODE} THREADS_PER_RANK= ${NTHREADS}"

export LIBRARY_PATH="$LIBRARY_PATH:${PROJECT_ROOT}/.venv/hwloc/lib"
export PKG_CONFIG_PATH="${PROJECT_ROOT}/.venv/hwloc/lib/pkgconfig:$PKG_CONFIG_PATH"
export DLIO_PROFILER_ENABLE=1
export DLIO_PROFILER_INC_METADATA=1
export DLIO_PROFILER_LOG_FILE=${PROJECT_ROOT}/dlio
# export DLIO_PROFILER_INIT=preload

# mpirun -np 8 dlio_benchmark workload=unet3d ++workload.workflow.generate_data=True ++workload.workflow.train=False --config-dir="$PROJECT_ROOT/configs"
# mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth dlio_benchmark workload=unet3d ++workload.workflow.generate_data=True ++workload.workflow.train=False --config-dir="$PROJECT_ROOT/configs"

# the process id, app_name and .pfw will be appended by the profiler for each app and process.
# name of final log file is ~/log_file-<APP_NAME>-<PID>.pfw
# Colon separated paths for including for profiler
export DLIO_PROFILER_DATA_DIR=/dev/shm/:$PWD/data:$PROJECT_ROOT/data
# python test.py
# python test_mnist.py
python test2.py
# mpiexec -n $NTOTRANKS --ppn $NRANKS_PER_NODE --depth=$NDEPTH --cpu-bind depth python test2.py
# Enable profiler

echo "Done"