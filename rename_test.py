"""Rename test.txt (in the current folder) after a 10-second count.

Test aid for the CubicAdventurer rename safeguard: it plays the part of
another program renaming a file while CA's rename box is open on it.
Run it only in a temporary test folder.
"""
import os
import sys
import time

SOURCE = "test.txt"
TARGET = "renamed_by_script.txt"
DELAY_SECONDS = 10


# Check both names first, count up, then rename; returns a process exit code.
def main():
    if not os.path.isfile(SOURCE):
        print(f"{SOURCE} was not found in {os.getcwd()}")
        return 1
    if os.path.exists(TARGET):
        print(f"{TARGET} already exists; delete it first")
        return 1
    for count in range(1, DELAY_SECONDS + 1):
        print(count, flush=True)
        time.sleep(1)
    try:
        os.rename(SOURCE, TARGET)
    except OSError as err:
        print(f"rename failed: {err}")
        return 1
    print(f"renamed {SOURCE} to {TARGET}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
