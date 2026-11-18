# SPDX-License-Identifier: GPL-2.0-or-later
"""Measure the error of the linear engine grid against the exact conversion.

The converter gives the engine a linear easting and northing. The script API
converts each position exactly. This tool compares the two over every terrain
in docs/georef-report.json and prints the worst case in metres.

    python3 tools/measure_accuracy.py
"""

from __future__ import annotations

import importlib.util
import json
import math
import pathlib
import statistics
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SAMPLES = 9
CELL = 10.0
SQUARE = 100_000.0


def wrap(delta: float) -> float:
    """Distance within the 100 km square the engine grid draws."""
    delta = abs(delta) % SQUARE
    return min(delta, SQUARE - delta)


def load_converter() -> object:
    spec = importlib.util.spec_from_file_location(
        "mgrs_convert", ROOT / "tools" / "mgrs_convert.py"
    )
    if spec is None or spec.loader is None:
        raise SystemExit("cannot load tools/mgrs_convert.py")
    module = importlib.util.module_from_spec(spec)
    sys.modules["mgrs_convert"] = module
    spec.loader.exec_module(module)
    return module


def model(conv: object, box: list[float], size: float):
    """Rebuild the linear grid the converter emits for this terrain."""
    lat_min, lon_min, lat_max, lon_max = box
    centre = conv.lat_lon_to_utm((lat_min + lat_max) / 2, (lon_min + lon_max) / 2)
    zone = centre[0]
    scale_x, scale_y, east0, north0 = conv.grid_fit(box, size, zone)
    return zone, (east0, north0), scale_x, scale_y


def worst_error(conv: object, world: dict) -> tuple[float, float]:
    """Return the worst and the mean error in metres for one world."""
    box = world["geo"]
    size = float(world.get("mapSize") or 0)
    if size <= 0 or len(box) < 4:
        return math.nan, math.nan
    zone, origin, scale_x, scale_y = model(conv, box, size)
    if scale_x <= 0 or scale_y <= 0:
        return math.nan, math.nan

    lat_min, lon_min, lat_max, lon_max = box
    errors = []
    for iy in range(SAMPLES):
        for ix in range(SAMPLES):
            x = size * ix / (SAMPLES - 1)
            y = size * iy / (SAMPLES - 1)
            lat = lat_min + (lat_max - lat_min) * y / size
            lon = lon_min + (lon_max - lon_min) * x / size
            _, east, north = conv.lat_lon_to_utm(lat, lon)
            errors.append(
                math.hypot(
                    wrap(east - (origin[0] + scale_x * x)),
                    wrap(north - (origin[1] + scale_y * y)),
                )
            )
    return max(errors), statistics.fmean(errors)


def main() -> int:
    conv = load_converter()
    report = json.loads((ROOT / "docs" / "georef-report.json").read_text())
    rows = []
    for world in report["worlds"]:
        if not world.get("grid"):
            continue
        worst, mean = worst_error(conv, world)
        if math.isnan(worst):
            continue
        span = conv.zone_for(world["geo"][1]) != conv.zone_for(world["geo"][3])
        rows.append((world["name"], world.get("mapSize") or 0, worst, mean, span))

    if not rows:
        print("no terrains measured", file=sys.stderr)
        return 1

    rows.sort(key=lambda row: row[2], reverse=True)
    print("| Terrain | Map size | Cross-zone | Worst | Mean |")
    print("|---|---|---|---|---|")
    for name, size, worst, mean, span in rows:
        print(
            f"| {name} | {size:.0f} m | {'yes' if span else 'no'} "
            f"| {worst:.1f} m | {mean:.1f} m |"
        )

    single = [row for row in rows if not row[4]]
    cross = [row for row in rows if row[4]]
    print()
    print(f"terrains measured: {len(rows)}")

    def summary(label: str, group: list[tuple[str, float, float, float, bool]]) -> None:
        if not group:
            return
        worst = max(group, key=lambda row: row[2])
        print(
            f"{label}: {len(group)} terrains, worst {worst[0]} at {worst[2]:.1f} m, "
            f"median {statistics.median(row[2] for row in group):.1f} m"
        )

    summary("single zone", single)
    summary("zone boundary", cross)
    inside = sum(1 for row in single if row[2] <= CELL)
    print(f"single zone within one {CELL:.0f} m cell: {inside} of {len(single)}")
    print(f"largest map: {max(row[1] for row in rows):.0f} m")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
