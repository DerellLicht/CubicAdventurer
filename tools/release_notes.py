#!/usr/bin/env python3
"""
Print the CHANGELOG.md section for one version (the text under "## [x.yy]" up to
the next "## [" header) so it can be used as GitHub release notes.

usage: release_notes.py VERSION [CHANGELOG.md]
"""
import re
import sys


def main():
    if len(sys.argv) < 2:
        sys.exit("usage: release_notes.py VERSION [CHANGELOG.md]")
    version = sys.argv[1]
    path = sys.argv[2] if len(sys.argv) > 2 else "CHANGELOG.md"
    with open(path, encoding="utf-8") as fh:
        lines = fh.read().splitlines()

    header = re.compile(r"^## \[" + re.escape(version) + r"\]")
    start = None
    for i, line in enumerate(lines):
        if header.match(line):
            start = i + 1
            break
    if start is None:
        sys.exit('no "## [%s]" section found in %s' % (version, path))

    end = len(lines)
    for i in range(start, len(lines)):
        if lines[i].startswith("## ["):
            end = i
            break

    body = "\n".join(lines[start:end]).strip()
    if not body:
        sys.exit('the "## [%s]" section in %s is empty' % (version, path))
    print(body)


if __name__ == "__main__":
    main()
