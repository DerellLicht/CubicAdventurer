#!/usr/bin/env python3
"""Build Source/CE_Resources.res from Source/CE_Resources.rc without BRCC32.

The .rc file lists the default layout and settings that are built into the exe:

    DEFAULT_LAYOUT_DATA RCDATA Defaults\\layout.xml

Run this after changing a file in Source/Defaults, then rebuild the program in the IDE.
Usage:  python tools/make_default_res.py          (writes the .res)
        python tools/make_default_res.py --check  (exit code 1 if the .res is out of date)
"""
import os
import struct
import sys

SOURCE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Source')
RC_FILE = os.path.join(SOURCE_DIR, 'CE_Resources.rc')
RES_FILE = os.path.join(SOURCE_DIR, 'CE_Resources.res')

RT_RCDATA = 10
MEMORY_FLAGS = 0x0030          # moveable + pure, same as the original compiler wrote
LANGUAGE_NEUTRAL = 0           # FindResource also finds neutral resources


def pad4(data):
    """Pad a byte string with zeros to a multiple of four bytes."""
    return data + b'\0' * (-len(data) % 4)


def make_entry(name, data):
    """Return one resource entry (header, data) in the 32-bit .res format."""
    name_bytes = pad4(name.upper().encode('utf-16-le') + b'\0\0')
    type_bytes = struct.pack('<HH', 0xFFFF, RT_RCDATA)
    tail = struct.pack('<IHHII', 0, MEMORY_FLAGS, LANGUAGE_NEUTRAL, 0, 0)
    header = type_bytes + name_bytes + tail
    head = struct.pack('<II', len(data), 8 + len(header))
    return head + header + pad4(data)


def parse_rc():
    """Return [(resource name, file path)] for every RCDATA line of the .rc file."""
    items = []
    with open(RC_FILE, 'r', encoding='ascii') as f:
        for line in f:
            parts = line.split()
            if not parts:
                continue
            if len(parts) != 3 or parts[1] != 'RCDATA':
                raise SystemExit('Unsupported line in %s: %r' % (RC_FILE, line))
            path = os.path.normpath(os.path.join(SOURCE_DIR, parts[2].replace('\\', os.sep)))
            items.append((parts[0], path))
    return items


def build():
    """Return the complete .res file as bytes."""
    out = struct.pack('<II', 0, 0x20) + struct.pack('<HHHH', 0xFFFF, 0, 0xFFFF, 0) + b'\0' * 16
    for name, path in parse_rc():
        with open(path, 'rb') as f:
            out += make_entry(name, f.read())
    return out


def main():
    data = build()
    if '--check' in sys.argv:
        with open(RES_FILE, 'rb') as f:
            current = f.read()
        if current != data:
            print('CE_Resources.res is out of date: run tools/make_default_res.py')
            return 1
        print('CE_Resources.res is up to date')
        return 0
    with open(RES_FILE, 'wb') as f:
        f.write(data)
    print('Wrote %s (%d bytes)' % (os.path.normpath(RES_FILE), len(data)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
