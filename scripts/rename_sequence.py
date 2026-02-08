#!/usr/bin/env python3
import sys
import os
from itertools import groupby


def stem_and_ext(filename):
    """Split on the first dot: 'foo_02.en.vtt' -> ('foo_02', '.en.vtt')"""
    dot = filename.find(".")
    if dot == -1:
        return filename, ""
    return filename[:dot], filename[dot:]


def main():
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <folder> <base_name> <start_number> [--apply]")
        sys.exit(1)

    folder = sys.argv[1]
    base_name = sys.argv[2]
    start = int(sys.argv[3])
    apply = "--apply" in sys.argv

    folder = os.path.abspath(folder)
    if not os.path.isdir(folder):
        print(f"Error: '{folder}' is not a directory.")
        sys.exit(1)

    script = os.path.basename(__file__)
    files = sorted(
        f for f in os.listdir(folder)
        if os.path.isfile(os.path.join(folder, f)) and f != script and not f.startswith(".")
    )

    if not files:
        print("No files to rename.")
        return

    # Group consecutive files that share the same stem
    groups = [list(g) for _, g in groupby(files, key=lambda f: stem_and_ext(f)[0])]

    total = start + len(groups) - 1
    width = max(2, len(str(total)))

    if not apply:
        print("Dry run (pass --apply to rename):\n")

    num = start
    for group in groups:
        for filename in group:
            _, ext = stem_and_ext(filename)
            new_name = f"{base_name} - {num:0{width}d}{ext}"
            if apply:
                os.rename(os.path.join(folder, filename), os.path.join(folder, new_name))
                print(f"  {filename} -> {new_name}")
            else:
                print(f"  {filename}")
                print(f"    -> {new_name}")
                print()
        num += 1

    if not apply:
        print(f"{len(groups)} episodes, {len(files)} files total.")


if __name__ == "__main__":
    main()
