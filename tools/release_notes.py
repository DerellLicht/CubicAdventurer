"""Print the CHANGELOG.md section for one version, for use as GitHub release notes.

usage: python tools/release_notes.py 1.00 > temp_notes.md

The section starts just below the line "## [VERSION] - date" and ends just before the next "## ["
header, or at the end of the file for the oldest version.  The header line itself is left out,
because the GitHub release title already names the version (and the header may say "unreleased").
Exits 1 with a message on stderr if the version has no section, or the section is empty.
"""
import re
import sys


def section(text, version):
    """Return the body lines of the changelog section for version, header line excluded.

    Matches the header as "## [VERSION]" at the start of a line; the body runs until the next
    line that starts with "## [".  Returns None if there is no such header.
    """
    lines = text.splitlines()
    header = re.compile(r"^## \[" + re.escape(version) + r"\]")
    start = next((i for i, line in enumerate(lines) if header.match(line)), None)
    if start is None:
        return None
    end = len(lines)
    for i in range(start + 1, len(lines)):
        if lines[i].startswith("## ["):
            end = i
            break
    return lines[start + 1:end]


def main():
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 1
    with open("CHANGELOG.md", encoding="utf-8-sig") as f:
        found = section(f.read(), sys.argv[1])
    if found is None:
        print("no section for version " + sys.argv[1] + " in CHANGELOG.md", file=sys.stderr)
        return 1
    body = "\n".join(found).strip()
    if not body:
        print("the section for version " + sys.argv[1] + " in CHANGELOG.md is empty", file=sys.stderr)
        return 1
    print(body)
    return 0


if __name__ == "__main__":
    sys.exit(main())
