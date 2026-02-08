#!/usr/bin/env python3
"""Rename media files to Jellyfin naming convention: Series Name S##E##.ext

Expects folder structure:
  Animes/
  └── Series Name (Year) [tags]/
      ├── Season 01/
      │   ├── whatever_01.mkv
      │   └── whatever_02.en.vtt
      └── Season 02/
          └── ...

Season 00 is skipped (specials).
"""
import sys
import os
import re

MEDIA_EXTS = {".mkv", ".mp4", ".avi", ".ts", ".m4v", ".wmv", ".flv", ".webm"}
SUB_EXTS = {".srt", ".vtt", ".ass", ".sub", ".idx", ".ssa"}
ALL_EXTS = MEDIA_EXTS | SUB_EXTS


def split_ext(filename):
    """Split into (stem, ext), handling compound exts like .en.vtt"""
    name, ext = os.path.splitext(filename)
    if ext.lower() in SUB_EXTS:
        name2, maybe_lang = os.path.splitext(name)
        if maybe_lang and re.match(r"^\.[a-z]{2,3}$", maybe_lang, re.IGNORECASE):
            return name2, maybe_lang + ext
    return name, ext


def is_media_or_sub(filename):
    _, ext = split_ext(filename)
    base_ext = os.path.splitext(ext)[1] if "." in ext[1:] else ext
    return base_ext.lower() in ALL_EXTS


def clean_series_name(folder_name):
    """Derive series name from folder: strip (...), [...], release info."""
    name = folder_name
    name = re.sub(r"\[.*?\]", "", name)
    name = re.sub(r"\(.*?\)", "", name)
    # Strip release info from first technical pattern onward
    name = re.sub(
        r"\s+(?:S\d{2}|\d{3,4}p|WEBRip|WEB[.-]DL|BluRay|BDRip|DVDRip|HDTV|"
        r"DVD|x264|x265|h\.?264|h\.?265|HEVC|AVC|AAC|FLAC|DTS|10bit)\b.*$",
        "",
        name,
        flags=re.IGNORECASE,
    )
    # Strip trailing " - digits..." (e.g. " - 01-12")
    name = re.sub(r"\s+-\s+\d.*$", "", name)
    # Clean up trailing separators and whitespace
    name = re.sub(r"[\s-]+$", "", name)
    name = re.sub(r"\s{2,}", " ", name)
    return name.strip()


def clean_stem(stem):
    """Remove [...] and (...) from stem for episode number extraction."""
    s = re.sub(r"\[.*?\]", "", stem)
    s = re.sub(r"\(.*?\)", "", s)
    return s.strip()


def extract_episode_info(stem):
    """Extract (start_ep, end_ep) from filename stem. end_ep is None for single episodes."""
    s = clean_stem(stem)

    # S##E##-E## or S##E##
    m = re.search(r"S\d+E(\d+)(?:\s*-\s*E(\d+))?", s, re.IGNORECASE)
    if m:
        return int(m.group(1)), int(m.group(2)) if m.group(2) else None

    # "Episode X-Y" or "Episode X"
    m = re.search(r"Episode\s+(\d+)(?:\s*-\s*(\d+))?", s, re.IGNORECASE)
    if m:
        return int(m.group(1)), int(m.group(2)) if m.group(2) else None

    # Separator + number at end: "_##", " - ##", " ##" (with optional V#/END suffix)
    m = re.search(r"(?:_|\s+-\s+|\s)(\d+)(?:\s*(?:V\d+|END))?\s*$", s)
    if m:
        return int(m.group(1)), None

    return None


def format_name(series_name, season_num, start_ep, end_ep, ext):
    ep = f"E{start_ep:02d}"
    if end_ep is not None:
        ep += f"-E{end_ep:02d}"
    return f"{series_name} S{season_num:02d}{ep}{ext}"


def process_season(series_name, season_path, season_num, apply):
    files = sorted(
        f
        for f in os.listdir(season_path)
        if os.path.isfile(os.path.join(season_path, f))
        and is_media_or_sub(f)
        and not f.startswith(".")
    )
    if not files:
        print("    (no media files)")
        return

    renames = []
    skipped = []
    for filename in files:
        stem, ext = split_ext(filename)
        info = extract_episode_info(stem)
        if info is None:
            skipped.append(filename)
            continue
        start_ep, end_ep = info
        new_name = format_name(series_name, season_num, start_ep, end_ep, ext)
        if filename != new_name:
            renames.append((filename, new_name))

    for f in skipped:
        print(f"    [SKIP] {f}")

    # Check for collisions
    targets = {}
    for old, new in renames:
        targets.setdefault(new, []).append(old)
    has_collision = False
    for target, sources in targets.items():
        if len(sources) > 1:
            has_collision = True
            print(f"    [COLLISION] {target}:")
            for s in sources:
                print(f"      <- {s}")
    if has_collision and apply:
        print("    Aborting season due to collisions!")
        return

    for old, new in renames:
        if apply:
            os.rename(os.path.join(season_path, old), os.path.join(season_path, new))
            print(f"    {old} -> {new}")
        else:
            print(f"    {old}")
            print(f"      -> {new}")


def process_series(series_path, name_override=None, apply=False):
    folder_name = os.path.basename(series_path)
    series_name = name_override or clean_series_name(folder_name)

    # Find Season folders
    season_dirs = []
    for d in sorted(os.listdir(series_path)):
        full = os.path.join(series_path, d)
        if os.path.isdir(full):
            m = re.match(r"Season\s+(\d+)", d, re.IGNORECASE)
            if m:
                season_dirs.append((int(m.group(1)), full, d))

    # No Season folders: create Season 01 and move media files into it
    if not season_dirs:
        loose_files = [
            f
            for f in os.listdir(series_path)
            if os.path.isfile(os.path.join(series_path, f))
            and is_media_or_sub(f)
            and not f.startswith(".")
        ]
        if not loose_files:
            return

        season_dir = os.path.join(series_path, "Season 01")
        print(f"\n{folder_name}")
        if series_name != folder_name:
            print(f"  -> {series_name}")
        print(f"  Creating Season 01 and moving {len(loose_files)} files:")

        for f in sorted(loose_files):
            print(f"    -> Season 01/{f}")

        if apply:
            os.makedirs(season_dir, exist_ok=True)
            for f in loose_files:
                os.rename(
                    os.path.join(series_path, f),
                    os.path.join(season_dir, f),
                )
            season_dirs = [(1, season_dir, "Season 01")]
        else:
            # Dry-run: simulate rename from the original location
            print(f"  Season 01 (rename preview):")
            process_season(series_name, series_path, 1, apply=False)
            return

    else:
        print(f"\n{folder_name}")
        if series_name != folder_name:
            print(f"  -> {series_name}")

    for season_num, season_path, season_name in season_dirs:
        if season_num == 0:
            print(f"  {season_name}: (skipped)")
            continue
        print(f"  {season_name}:")
        process_season(series_name, season_path, season_num, apply)


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <folder> [--name NAME] [--apply]")
        print()
        print("  folder   series folder or root folder containing series")
        print("  --name   override series name (single series only)")
        print("  --apply  rename files (default: dry-run)")
        sys.exit(1)

    folder = os.path.abspath(sys.argv[1])
    apply = "--apply" in sys.argv

    name_override = None
    if "--name" in sys.argv:
        idx = sys.argv.index("--name")
        if idx + 1 < len(sys.argv):
            name_override = sys.argv[idx + 1]

    if not os.path.isdir(folder):
        print(f"Error: '{folder}' is not a directory.")
        sys.exit(1)

    if not apply:
        print("DRY RUN (pass --apply to rename)\n")

    # Detect: series folder vs root folder containing series
    # A series folder either has Season subdirs or has media files directly in it
    has_seasons = any(
        re.match(r"Season\s+\d+", d, re.IGNORECASE)
        for d in os.listdir(folder)
        if os.path.isdir(os.path.join(folder, d))
    )
    has_media = any(
        is_media_or_sub(f)
        for f in os.listdir(folder)
        if os.path.isfile(os.path.join(folder, f))
    )

    if has_seasons or has_media:
        process_series(folder, name_override, apply)
    else:
        if name_override:
            print("Warning: --name ignored when processing multiple series\n")
        for d in sorted(os.listdir(folder)):
            series_path = os.path.join(folder, d)
            if os.path.isdir(series_path):
                process_series(series_path, apply=apply)


if __name__ == "__main__":
    main()
