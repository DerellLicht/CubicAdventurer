#!/usr/bin/env python3
"""
make_icon.py - build CE_AppIcon.ico from the per-size PNG files.

Layout of the resulting .ico (the usual Windows layout):
  * 16, 24, 32 and 48 px: classic 32-bit BMP (DIB) entries, which every
    resource compiler (including Delphi's) accepts.
  * 256 px: PNG-compressed entry (Vista and later; keeps the file small).

Usage:
    python make_icon.py            # reads PNG/CE_App_Icon_<n>.png, writes CE_AppIcon.ico
    python make_icon.py OUT.ico    # write somewhere else

Requires Pillow (pip install pillow).
"""

import io
import os
import struct
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
BMP_SIZES = (16, 24, 32, 48)
PNG_SIZES = (256,)


def png_path(size):
    """Return the path of the source PNG for a given pixel size."""
    return os.path.join(HERE, "PNG", "CE_App_Icon_%d.png" % size)


def load_rgba(size):
    """
    Load the PNG for 'size' as RGBA and check that it really is size x size.
    Exits with a message if the file is missing or the wrong dimensions.
    """
    path = png_path(size)
    if not os.path.isfile(path):
        sys.exit("missing source image: %s" % path)
    img = Image.open(path).convert("RGBA")
    if img.size != (size, size):
        sys.exit("%s is %dx%d, expected %dx%d" % (path, img.width, img.height, size, size))
    return img


def make_bmp_entry(img):
    """
    Encode an RGBA image as the image data of an .ico BMP entry:
    BITMAPINFOHEADER (height doubled), bottom-up BGRA pixels, then a 1-bpp
    AND mask (all zero, because the alpha channel carries the transparency).
    """
    w, h = img.size
    header = struct.pack("<IiiHHIIiiII", 40, w, h * 2, 1, 32, 0, 0, 0, 0, 0, 0)

    # pixels: BGRA, rows bottom to top
    px = img.load()
    rows = []
    for y in range(h - 1, -1, -1):
        row = bytearray()
        for x in range(w):
            r, g, b, a = px[x, y]
            row += bytes((b, g, r, a))
        rows.append(bytes(row))

    # AND mask: one bit per pixel, rows padded to 4 bytes, all zero
    mask_row = ((w + 31) // 32) * 4
    mask = bytes(mask_row * h)
    return header + b"".join(rows) + mask


def make_png_entry(img):
    """Encode an RGBA image as optimized PNG bytes for a PNG-compressed entry."""
    buf = io.BytesIO()
    img.save(buf, format="PNG", optimize=True)
    return buf.getvalue()


def build_ico(path):
    """
    Assemble the .ico file: ICONDIR, one ICONDIRENTRY per image (sizes
    ascending), then the image data blocks. A width/height byte of 0 means 256.
    """
    entries = []
    for size in BMP_SIZES:
        entries.append((size, make_bmp_entry(load_rgba(size))))
    for size in PNG_SIZES:
        entries.append((size, make_png_entry(load_rgba(size))))
    entries.sort(key=lambda e: e[0])

    out = bytearray(struct.pack("<HHH", 0, 1, len(entries)))
    offset = 6 + 16 * len(entries)
    for size, data in entries:
        dim = 0 if size >= 256 else size
        out += struct.pack("<BBBBHHII", dim, dim, 0, 0, 1, 32, len(data), offset)
        offset += len(data)
    for _size, data in entries:
        out += data

    with open(path, "wb") as fh:
        fh.write(out)
    print("wrote %s (%d bytes, %d images)" % (path, len(out), len(entries)))


def main():
    """Entry point: choose the output path and build the icon."""
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "CE_AppIcon.ico")
    build_ico(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
