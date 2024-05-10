import os
import numpy as np
from dlio_profiler.logger import dlio_logger, fn_interceptor
from multiprocessing import get_context
import time

pid = os.getpid()
log_inst = dlio_logger.initialize_log(
    # logfile="test.log",
    logfile=f"dlio_log_py_level-{pid}.pfw",
    data_dir=None,
    process_id=pid,
)
dlio_log = fn_interceptor("COMPUTE")


# Example of using function decorators
@dlio_log.log
def log_events(index):
    time.sleep(1)


cwd = "/grand/ReForMerS/llm-profiler/data/test"
os.makedirs(f"{cwd}/data", exist_ok=True)


# Example of function spawning and implicit I/O calls
def posix_calls(val):
    index, is_spawn = val
    path = f"{cwd}/data/demofile{index}.txt"
    f = open(path, "w+")
    f.write("Now the file has more content!")
    f.close()
    if is_spawn:
        print(f"Calling spawn on {index} with pid {os.getpid()}")
        log_inst.finalize()  # This need to be called to correctly finalize DLIO Profiler.
    else:
        print(f"Not calling spawn on {index} with pid {os.getpid()}")


# NPZ calls internally calls POSIX calls.
def npz_calls(index):
    path = f"{cwd}/data/img_{index:03d}_of_168.npz"
    if os.path.exists(path):
        os.remove(path)
    records = np.random.randint(255, size=(8, 8, 1024), dtype=np.uint8)
    record_labels = [0] * 1024
    np.savez(path, x=records, y=record_labels)


def init():
    """This function is called when new processes start."""
    print(f"Initializing process {os.getpid()}")


def main():
    log_events(0)
    npz_calls(1)
    with get_context("spawn").Pool(1, initializer=init) as pool:
        pool.map(posix_calls, ((2, True),))
    log_inst.finalize()


if __name__ == "__main__":
    main()
