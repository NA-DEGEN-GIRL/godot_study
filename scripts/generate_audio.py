#!/usr/bin/env python3
"""
Generate TTS audio narration for Godot study slides.

Parses HTML slide files, extracts data-narration attributes,
generates MP3 files using edge-tts (Microsoft Azure Neural voices).
Uses manifest.json to track text hashes and only regenerate changed slides.

Usage:
    pip install edge-tts
    python scripts/generate_audio.py [--voice ko-KR-SunHiNeural] [--chapter 01]
"""

import asyncio
import hashlib
import json
import os
import re
import sys
import html
from pathlib import Path

try:
    import edge_tts
except ImportError:
    print("Error: edge-tts not installed. Run: pip install edge-tts")
    sys.exit(1)

# Defaults
DEFAULT_VOICE = "ko-KR-SunHiNeural"
SLIDES_DIR = Path(__file__).parent.parent / "slides"
AUDIO_DIR = SLIDES_DIR / "audio"
MANIFEST_FILE = AUDIO_DIR / "manifest.json"


def parse_narrations(html_path: Path) -> list[dict]:
    """Extract data-narration attributes from each <section> in order."""
    content = html_path.read_text(encoding="utf-8")

    # Find all <section ...> tags with data-narration
    narrations = []
    slide_idx = 0

    for match in re.finditer(r"<section\b[^>]*?data-narration=\"([^\"]*)\"[^>]*>|<section\b[^>]*>", content):
        slide_idx += 1
        narr_text = match.group(1)  # Will be None if no data-narration
        narr_match = narr_text is not None
        if narr_match:
            text = html.unescape(narr_text).strip()
            if text:
                narrations.append({
                    "slide": slide_idx,
                    "text": text,
                })

    return narrations


def text_hash(text: str) -> str:
    """SHA-256 hash of narration text (first 16 hex chars)."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]


def load_manifest() -> dict:
    """Load existing manifest or return empty dict."""
    if MANIFEST_FILE.exists():
        return json.loads(MANIFEST_FILE.read_text(encoding="utf-8"))
    return {}


def save_manifest(manifest: dict):
    """Save manifest to JSON file."""
    MANIFEST_FILE.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_FILE.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


async def generate_mp3(text: str, output_path: Path, voice: str):
    """Generate MP3 using edge-tts."""
    communicate = edge_tts.Communicate(text, voice)
    await communicate.save(str(output_path))


async def process_chapter(chapter_num: str, voice: str, manifest: dict, force: bool = False):
    """Process one chapter: parse HTML, generate changed audio files."""
    html_file = None
    for f in sorted(SLIDES_DIR.glob(f"{chapter_num}-*.html")):
        html_file = f
        break

    if not html_file:
        print(f"  [SKIP] No HTML file found for chapter {chapter_num}")
        return 0

    narrations = parse_narrations(html_file)
    if not narrations:
        print(f"  [SKIP] {html_file.name}: no data-narration attributes found")
        return 0

    chapter_dir = AUDIO_DIR / chapter_num
    chapter_dir.mkdir(parents=True, exist_ok=True)

    chapter_manifest = manifest.get(chapter_num, {})
    generated = 0

    for item in narrations:
        slide_num = str(item["slide"]).zfill(2)
        key = f"slide-{slide_num}"
        h = text_hash(item["text"])
        output_path = chapter_dir / f"{key}.mp3"

        # Skip if hash matches and file exists
        if not force and chapter_manifest.get(key) == h and output_path.exists():
            print(f"  [OK]   {chapter_num}/{key}.mp3 (unchanged)")
            continue

        print(f"  [GEN]  {chapter_num}/{key}.mp3 ...")
        try:
            await generate_mp3(item["text"], output_path, voice)
            chapter_manifest[key] = h
            generated += 1
        except Exception as e:
            print(f"  [ERR]  {chapter_num}/{key}.mp3: {e}")

    manifest[chapter_num] = chapter_manifest
    return generated


async def main():
    import argparse

    parser = argparse.ArgumentParser(description="Generate TTS audio for Godot slides")
    parser.add_argument("--voice", default=DEFAULT_VOICE, help=f"TTS voice (default: {DEFAULT_VOICE})")
    parser.add_argument("--chapter", default=None, help="Process specific chapter (e.g., 01)")
    parser.add_argument("--force", action="store_true", help="Regenerate all files")
    parser.add_argument("--list-voices", action="store_true", help="List available Korean voices")
    args = parser.parse_args()

    if args.list_voices:
        voices = await edge_tts.list_voices()
        korean = [v for v in voices if v["Locale"].startswith("ko-")]
        for v in korean:
            print(f"  {v['ShortName']:30s} {v['Gender']:8s} {v.get('FriendlyName', '')}")
        return

    print(f"Voice: {args.voice}")
    print(f"Slides dir: {SLIDES_DIR}")
    print(f"Audio dir: {AUDIO_DIR}")
    print()

    manifest = load_manifest()
    total_generated = 0

    if args.chapter:
        chapters = [args.chapter.zfill(2)]
    else:
        # Find all chapter HTML files
        chapters = sorted(set(
            f.name[:2]
            for f in SLIDES_DIR.glob("[0-9][0-9]-*.html")
        ))

    for ch in chapters:
        print(f"Chapter {ch}:")
        count = await process_chapter(ch, args.voice, manifest, args.force)
        total_generated += count

    save_manifest(manifest)
    print(f"\nDone! Generated {total_generated} audio file(s).")
    print(f"Manifest saved to {MANIFEST_FILE}")


if __name__ == "__main__":
    asyncio.run(main())
