from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent.parent
MANIFEST_PATH = ROOT / "KillSnailApp" / "PixelSnailArt.json"
APP_ICON_PATH = ROOT / "KillSnailApp" / "Assets.xcassets" / "AppIcon.appiconset"


ICON_SPECS = {
    "icon_16x16.png": 16,
    "icon_16x16@2x.png": 32,
    "icon_32x32.png": 32,
    "icon_32x32@2x.png": 64,
    "icon_128x128.png": 128,
    "icon_128x128@2x.png": 256,
    "icon_256x256.png": 256,
    "icon_256x256@2x.png": 512,
    "icon_512x512.png": 512,
    "icon_512x512@2x.png": 1024,
}


def parse_hex_color(value: str) -> tuple[int, int, int, int]:
    raw = value.removeprefix("#")
    if len(raw) == 6:
        raw += "FF"
    if len(raw) != 8:
        raise ValueError(f"Unsupported color value: {value}")
    return tuple(int(raw[index : index + 2], 16) for index in range(0, 8, 2))


def draw_rects(
    draw: ImageDraw.ImageDraw,
    rects: list[dict[str, int | str]],
    palette: dict[str, tuple[int, int, int, int]],
    canvas_width: int,
    canvas_height: int,
    size: int,
) -> None:
    if size % canvas_width != 0 or size % canvas_height != 0:
        raise ValueError(
            f"Target size {size} does not scale cleanly from {canvas_width}x{canvas_height}"
        )

    cell = size // canvas_width

    for rect in rects:
        color = palette[rect["color"]]
        x = int(rect["x"]) * cell
        y = int(rect["y"]) * cell
        width = int(rect["width"]) * cell
        height = int(rect["height"]) * cell
        draw.rectangle((x, y, x + width - 1, y + height - 1), fill=color)


def build_icon(size: int, manifest: dict[str, object]) -> Image.Image:
    canvas = manifest["canvas"]
    canvas_width = int(canvas["width"])
    canvas_height = int(canvas["height"])
    palette = {
        name: parse_hex_color(value) for name, value in manifest["palette"].items()
    }
    icon_background = manifest["iconBackground"]
    sprite = manifest["sprite"]

    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw_rects(draw, icon_background, palette, canvas_width, canvas_height, size)
    draw_rects(draw, sprite, palette, canvas_width, canvas_height, size)
    return image


def main() -> None:
    manifest = json.loads(MANIFEST_PATH.read_text())
    APP_ICON_PATH.mkdir(parents=True, exist_ok=True)

    for filename, size in ICON_SPECS.items():
        build_icon(size, manifest).save(APP_ICON_PATH / filename)


if __name__ == "__main__":
    main()
