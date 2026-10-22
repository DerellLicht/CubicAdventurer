#!/usr/bin/env python3
"""
Stop a running program by name (Windows), so its exe can be replaced or installed
over.  Does nothing, and succeeds, if the program is not running.

usage: stop_app.py NAME        (NAME without .exe, e.g. CubicAdventurer)
"""
import subprocess
import sys


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: stop_app.py NAME")
    exe = sys.argv[1] + ".exe"
    try:
        out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq " + exe, "/NH"],
                             capture_output=True, text=True).stdout
    except FileNotFoundError:
        return  # not Windows: nothing to stop
    if exe.lower() in out.lower():
        print("stopping " + exe)
        subprocess.run(["taskkill", "/IM", exe, "/F"], capture_output=True)


if __name__ == "__main__":
    main()
