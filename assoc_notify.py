"""Send the Windows "file associations changed" notice after a short delay.

Test aid for the CubicAdventurer crash: installers send this same notice.
It changes no file associations.
"""
import ctypes
import time

SHCNE_ASSOCCHANGED = 0x08000000
SHCNF_IDLIST = 0x0000
DELAY_SECONDS = 10


# Count down so there is time to open a rename box in CA, then send the notice.
def main():
    for left in range(DELAY_SECONDS, 0, -1):
        print(f"sending in {left} ...", flush=True)
        time.sleep(1)
    ctypes.windll.shell32.SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, None, None)
    print("sent")


if __name__ == "__main__":
    main()
