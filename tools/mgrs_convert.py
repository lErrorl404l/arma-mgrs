"""Scan Arma 3 terrains and generate a georeference table for the MGRS addon.

For every world class found in the scanned PBOs it resolves a lat/lon box:

  1. mgrsGeo[]          author-provided override
  2. mapArea[]          BI metadata, with order detection and mapZone check
  3. known corrections  official maps whose metadata is missing or wrong
  4. latitude/longitude  sign-fixed centre, box derived from mapSize
  5. synthetic anchor    deterministic hash of worldName, flagged virtual

The output is one config addon that adds mgrsGeo[] to each world class. The
runtime addon reads that array first, so the grid patch and the public API use
the same source.

Usage:
    python tools/mgrs_convert.py --game "/path/to/Arma 3" --out .
    python tools/mgrs_convert.py --pbo map.pbo --pbo other.pbo --out .
    python tools/mgrs_convert.py --mod /path/to/@TerrainMod --out .

Requires `hemtt` on PATH for PBO extraction and config derapification.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path

DEFAULT_BASELINE = {
    "datum": "WGS84",
    "zone": 31,
    "origin": [30.0, 3.0],
    "version": "1.0.0",
    "convergence": "world north assumed grid north",
    "label": "Declared synthetic training baseline",
}

# Corrections for official maps whose own metadata is missing or wrong.
KNOWN = {
    "altis": [39.7185, 25.0120, 40.0946, 25.4815],
    "stratis": [39.4500, 24.9500, 39.5600, 25.0600],
    "enoch": [53.8000, 22.7000, 54.2000, 23.2000],
    "malden": [39.7185, 25.0120, 40.0946, 25.4815],
    "tanoa": [-20.2680, 174.0030, -20.1353, 174.1460],
    "vr": [0.0000, 0.0000, 0.0900, 0.0900],
}

METRES_PER_DEGREE = 111320.0

WGS84_A = 6378137.0
WGS84_F = 1 / 298.257223563
WGS84_E2 = WGS84_F * (2 - WGS84_F)
WGS84_E4 = WGS84_E2 * WGS84_E2
WGS84_E6 = WGS84_E4 * WGS84_E2
WGS84_EP2 = WGS84_E2 / (1 - WGS84_E2)


def lat_lon_to_utm(lat: float, lon: float) -> tuple[int, float, float]:
    zone = min(60, max(1, math.floor((lon + 180) / 6) + 1))
    if 56 <= lat < 64 and 3 <= lon < 12:
        zone = 32
    if 72 <= lat < 84:
        if 0 <= lon < 9:
            zone = 31
        elif 9 <= lon < 21:
            zone = 33
        elif 21 <= lon < 33:
            zone = 35
        elif 33 <= lon < 42:
            zone = 37

    lon0 = (zone - 1) * 6 - 180 + 3
    dlon = math.radians(lon - lon0)
    latr = math.radians(lat)
    sin_lat, cos_lat, tan_lat = math.sin(latr), math.cos(latr), math.tan(latr)

    n = WGS84_A / math.sqrt(1 - WGS84_E2 * sin_lat * sin_lat)
    t = tan_lat * tan_lat
    c = WGS84_EP2 * cos_lat * cos_lat
    aa = cos_lat * dlon

    m = WGS84_A * (
        (1 - WGS84_E2 / 4 - 3 * WGS84_E4 / 64 - 5 * WGS84_E6 / 256) * latr
        - (3 * WGS84_E2 / 8 + 3 * WGS84_E4 / 32 + 45 * WGS84_E6 / 1024)
        * math.sin(2 * latr)
        + (15 * WGS84_E4 / 256 + 45 * WGS84_E6 / 1024) * math.sin(4 * latr)
        - (35 * WGS84_E6 / 3072) * math.sin(6 * latr)
    )

    easting = (
        0.9996
        * n
        * (
            aa
            + (1 - t + c) * aa**3 / 6
            + (5 - 18 * t + t * t + 72 * c - 58 * WGS84_EP2) * aa**5 / 120
        )
        + 500000
    )

    northing = 0.9996 * (
        m
        + n
        * tan_lat
        * (
            aa**2 / 2
            + (5 - t + 9 * c + 4 * c * c) * aa**4 / 24
            + (61 - 58 * t + t * t + 600 * c - 330 * WGS84_EP2) * aa**6 / 720
        )
    )
    if lat < 0:
        northing += 10000000

    return zone, easting, northing


@dataclass
class World:
    name: str
    parent: str | None
    pbo: str
    body: str
    map_size: float = 0.0
    map_zone: int = 0
    map_area: list[float] = field(default_factory=list)
    latitude: float | None = None
    longitude: float | None = None
    mgrs_geo: list[float] = field(default_factory=list)
    root_map_area: list[float] = field(default_factory=list)
    root_map_zone: int = 0
    root_latitude: float | None = None
    root_longitude: float | None = None
    grid_zoom_max: list[float] = field(default_factory=list)

    def parse(self) -> None:
        self.map_size = number(self.body, "mapSize") or 0.0
        self.map_zone = int(number(self.body, "mapZone") or 0)
        self.map_area = array(self.body, "mapArea")
        self.mgrs_geo = array(self.body, "mgrsGeo")
        self.latitude = number(self.body, "latitude")
        self.longitude = number(self.body, "longitude")

    def parse_grid(self) -> None:
        blocks = class_blocks(self.body, "Grid")
        if not blocks:
            return
        for name, _parent, body in child_classes(blocks[0]):
            if name.startswith("Zoom"):
                zoom = number(body, "zoomMax")
                if zoom is not None:
                    self.grid_zoom_max.append(zoom)


def run(cmd: list[str]) -> bytes:
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.decode("utf-8", "replace").strip())
    return result.stdout


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return re.sub(r"//[^\n]*", "", text)


def brace_block(text: str, open_index: int) -> tuple[str, int]:
    depth = 0
    for index in range(open_index, len(text)):
        char = text[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[open_index + 1 : index], index
    raise ValueError("unbalanced braces")


def class_blocks(text: str, name: str) -> list[str]:
    blocks = []
    for match in re.finditer(r"\bclass\s+" + re.escape(name) + r"\b[^{;]*\{", text):
        open_index = text.index("{", match.start())
        body, _ = brace_block(text, open_index)
        blocks.append(body)
    return blocks


def child_classes(body: str) -> list[tuple[str, str | None, str]]:
    children = []
    index = 0
    while True:
        match = re.search(r"\bclass\s+(\w+)\s*(?::\s*(\w+))?\s*\{", body[index:])
        if not match:
            break
        start = index + match.start()
        open_index = body.index("{", start)
        inner, end = brace_block(body, open_index)
        children.append((match.group(1), match.group(2), inner))
        index = end + 1
    return children


def number(body: str, name: str) -> float | None:
    match = re.search(r"(?m)^\s*" + re.escape(name) + r"\s*=\s*([-+0-9.eE]+)\s*;", body)
    return float(match.group(1)) if match else None


def array(body: str, name: str) -> list[float]:
    match = re.search(
        r"(?m)^\s*" + re.escape(name) + r"\s*\[\s*\]\s*=\s*\{([^}]*)\}", body
    )
    if not match:
        return []
    values = []
    for token in match.group(1).split(","):
        token = token.strip()
        if not token:
            continue
        try:
            values.append(float(token))
        except ValueError:
            return []
    return values


def extract_config(pbo: Path) -> str | None:
    with tempfile.TemporaryDirectory() as tmp:
        raw = Path(tmp) / "config.bin"
        text = Path(tmp) / "config.cpp"
        for name in ("config.bin", "config.cpp"):
            try:
                run(["hemtt", "utils", "pbo", "extract", str(pbo), name, str(raw)])
            except RuntimeError:
                continue
            if name.endswith(".cpp"):
                return strip_comments(raw.read_text(encoding="utf-8", errors="replace"))
            try:
                run(["hemtt", "utils", "config", "derapify", str(raw), str(text)])
            except RuntimeError:
                continue
            return strip_comments(text.read_text(encoding="utf-8", errors="replace"))
    return None


def parse_worlds(pbo: Path) -> list[World]:
    config = extract_config(pbo)
    if config is None:
        return []

    worlds = []
    for root in class_blocks(config, "CfgWorlds"):
        # Root-level properties come before the first child class. Some
        # terrains keep the correct box there while the world class carries a
        # copied box (Rosche).
        prefix = root.split("class ", 1)[0]
        root_area = array(prefix, "mapArea")
        root_zone = int(number(prefix, "mapZone") or 0)
        root_lat = number(prefix, "latitude")
        root_lon = number(prefix, "longitude")

        for name, parent, body in child_classes(root):
            if name in {"DefaultWorld", "CAWorld", "CfgWorlds"}:
                continue
            if (
                "class Grid" not in body
                and "mapArea" not in body
                and "latitude" not in body
            ):
                continue
            world = World(name=name, parent=parent, pbo=str(pbo), body=body)
            world.parse()
            world.parse_grid()
            world.root_map_area = root_area
            world.root_map_zone = root_zone
            world.root_latitude = root_lat
            world.root_longitude = root_lon
            worlds.append(world)
    return worlds


def valid_box(lat_min: float, lon_min: float, lat_max: float, lon_max: float) -> bool:
    return -80.0 <= lat_min < lat_max <= 84.0 and -180.0 <= lon_min < lon_max <= 180.0


def zone_for(lon: float) -> int:
    return min(60, max(1, int(math.floor((lon + 180.0) / 6.0)) + 1))


def normalise_area(values: list[float], map_zone: int) -> list[float] | None:
    if len(values) != 4:
        return None

    lon_first = [values[1], values[0], values[3], values[2]]
    lat_first = [values[0], values[1], values[2], values[3]]

    candidates = []
    if valid_box(*lon_first):
        candidates.append(("lon", lon_first))
    if valid_box(*lat_first):
        candidates.append(("lat", lat_first))
    if not candidates:
        return None
    if len(candidates) == 1:
        return candidates[0][1]

    if 1 <= map_zone <= 60:
        for _, box in candidates:
            centre_lon = (box[1] + box[3]) / 2.0
            if zone_for(centre_lon) == map_zone:
                return box
    return lon_first


def from_lat_lon(latitude: float, longitude: float, size: float) -> list[float] | None:
    lat = -latitude  # Arma stores north as negative
    lon = longitude
    if not (-80.0 <= lat <= 84.0 and -180.0 <= lon <= 180.0):
        return None
    if lat == 0.0 and lon == 0.0:
        return None
    if size <= 0.0:
        size = 8192.0
    half_lat = (size / 2.0) / METRES_PER_DEGREE
    half_lon = (size / 2.0) / (
        METRES_PER_DEGREE * max(0.05, math.cos(math.radians(lat)))
    )
    box = [lat - half_lat, lon - half_lon, lat + half_lat, lon + half_lon]
    if not valid_box(*box):
        return None
    return box


def synthetic(size: float, baseline: dict) -> list[float]:
    if size <= 0.0:
        size = 8192.0
    lat, lon = baseline["origin"]
    half_lat = (size / 2.0) / METRES_PER_DEGREE
    half_lon = (size / 2.0) / (
        METRES_PER_DEGREE * max(0.05, math.cos(math.radians(lat)))
    )
    return [lat - half_lat, lon - half_lon, lat + half_lat, lon + half_lon]


def area_centre(box: list[float]) -> tuple[float, float]:
    return (box[0] + box[2]) / 2.0, (box[1] + box[3]) / 2.0


def area_conflicts(
    box: list[float], latitude: float | None, longitude: float | None
) -> bool:
    """True when the declared box and the lat/lon point disagree badly.

    Copied metadata is common: Rosche carries Altis's mapArea and North
    Takistan carries Tanoa's. A 0.5 degree tolerance is about 55 km.
    """
    if latitude is None or longitude is None:
        return False
    lat = -latitude
    if not (-80.0 <= lat <= 84.0 and -180.0 <= longitude <= 180.0):
        return False
    centre_lat, centre_lon = area_centre(box)
    return abs(centre_lat - lat) > 0.5 or abs(centre_lon - longitude) > 0.5


def load_overrides(path: Path) -> dict[str, list[float]]:
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"Overrides ignored: {exc}", file=sys.stderr)
        return {}
    overrides: dict[str, list[float]] = {}
    for key, value in data.items():
        if key.startswith("_"):
            continue
        if (
            isinstance(value, list)
            and len(value) == 4
            and all(isinstance(item, (int, float)) for item in value)
            and valid_box(*(float(item) for item in value))
        ):
            overrides[key.lower()] = [float(item) for item in value]
        else:
            print(
                f"Override ignored for {key}: expected four valid numbers",
                file=sys.stderr,
            )
    return overrides


def load_baseline(path: Path) -> dict:
    baseline = dict(DEFAULT_BASELINE)
    baseline["origin"] = list(DEFAULT_BASELINE["origin"])
    if not path.exists():
        return baseline
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"Baseline ignored: {exc}", file=sys.stderr)
        return baseline

    if isinstance(data.get("datum"), str) and data["datum"]:
        baseline["datum"] = data["datum"]
    zone = data.get("zone")
    if isinstance(zone, int) and 1 <= zone <= 60:
        baseline["zone"] = zone
    origin = data.get("origin")
    if (
        isinstance(origin, list)
        and len(origin) == 2
        and all(isinstance(item, (int, float)) for item in origin)
        and -80.0 <= float(origin[0]) <= 84.0
        and -180.0 <= float(origin[1]) <= 180.0
    ):
        baseline["origin"] = [float(origin[0]), float(origin[1])]
    for key in ("version", "convergence", "label"):
        if isinstance(data.get(key), str) and data[key]:
            baseline[key] = data[key]

    derived = zone_for(baseline["origin"][1])
    if baseline["zone"] != derived:
        print(
            f"Baseline zone {baseline['zone']} does not match origin longitude; using zone {derived}.",
            file=sys.stderr,
        )
        baseline["zone"] = derived
    return baseline


def resolve(
    world: World,
    overrides: dict[str, list[float]] | None = None,
    baseline: dict | None = None,
) -> tuple[list[float], str, bool]:
    baseline = baseline or DEFAULT_BASELINE
    if len(world.mgrs_geo) >= 4:
        box = world.mgrs_geo[:4]
        if valid_box(*box):
            virtual = bool(world.mgrs_geo[4]) if len(world.mgrs_geo) >= 5 else False
            return box, "mgrsGeo", virtual

    override = (overrides or {}).get(world.name.lower())
    if override and valid_box(*override):
        return override, "override", False

    known = KNOWN.get(world.name.lower())
    if known and valid_box(*known):
        return known, "known", False

    area = normalise_area(world.map_area, world.map_zone)
    if area and not area_conflicts(area, world.latitude, world.longitude):
        return area, "mapArea", False

    root_area = normalise_area(
        world.root_map_area, world.map_zone or world.root_map_zone
    )
    if root_area and not area_conflicts(root_area, world.latitude, world.longitude):
        return root_area, "mapArea-root", False

    if world.latitude is not None and world.longitude is not None:
        # Trust lat/lon only when the declared UTM zone agrees with the
        # longitude. BI's fields are unreliable on their own.
        if 1 <= world.map_zone <= 60 and zone_for(world.longitude) == world.map_zone:
            box = from_lat_lon(world.latitude, world.longitude, world.map_size)
            if box:
                return box, "latlon", False

    return synthetic(world.map_size or 0.0, baseline), "synthetic", True


def discover(game: Path | None, mods: list[Path], pbos: list[Path]) -> list[Path]:
    found = list(pbos)
    if game:
        for candidate in list(game.glob("Addons/map_*.pbo")) + list(
            game.glob("*/Addons/map_*.pbo")
        ):
            name = candidate.name.lower()
            if any(skip in name for skip in ("_data", "_layers", "_scenes")):
                continue
            found.append(candidate)
    for mod in mods:
        if mod.is_file():
            found.append(mod)
        else:
            found.extend(sorted(mod.rglob("*.pbo")))
    seen = set()
    unique = []
    for path in found:
        key = path.resolve()
        if key not in seen:
            seen.add(key)
            unique.append(path)
    return unique


def scan(paths: list[Path]) -> tuple[list[World], list[str]]:
    worlds: dict[str, World] = {}
    errors = []
    for index, pbo in enumerate(paths, 1):
        print(f"[{index}/{len(paths)}] {pbo}", file=sys.stderr)
        try:
            found = parse_worlds(pbo)
        except Exception as exc:  # noqa: BLE001 - report and continue
            errors.append(f"{pbo}: {exc}")
            continue
        for world in found:
            key = world.name.lower()
            if key in worlds:
                continue
            worlds[key] = world
    return list(worlds.values()), errors


def config_string(value: str) -> str:
    return str(value).replace('"', "'")


def provenance(source: str, virtual: bool) -> str:
    if virtual or source == "synthetic":
        return "synthetic"
    if source in {"latlon", "latlon-unverified"}:
        return "derived"
    return "real/declared"


def grid_applies(world: World, enabled: bool) -> bool:
    return (
        enabled
        and world.parent in {"CAWorld", "DefaultWorld"}
        and len(world.grid_zoom_max) >= 3
    )


def grid_patch(world: World, box: list[float], enabled: bool) -> list[str]:
    if not grid_applies(world, enabled):
        return []
    if len(world.grid_zoom_max) < 3:
        return []

    size = world.map_size or 8192.0
    if size <= 0:
        return []

    lat_min, lon_min, lat_max, lon_max = box
    sw = lat_lon_to_utm(lat_min, lon_min)
    ne = lat_lon_to_utm(lat_max, lon_max)
    scale_x = (ne[1] - sw[1]) / size
    scale_y = (ne[2] - sw[2]) / size
    if scale_x <= 0 or scale_y <= 0:
        return []

    centre = lat_lon_to_utm((lat_min + lat_max) / 2, (lon_min + lon_max) / 2)
    square_e = math.floor(centre[1] / 100000.0) * 100000.0
    square_n = math.floor(centre[2] / 100000.0) * 100000.0
    east0 = sw[1] - square_e
    north0 = sw[2] - square_n

    lines = [
        "        class Grid: Grid {",
        f"            offsetX = {-east0 / scale_x:.3f};",
        f"            offsetY = {-north0 / scale_y:.3f};",
    ]
    tiers = [
        (10.0, "0000"),
        (100.0, "000"),
        (1000.0, "00"),
        (10000.0, "0"),
    ]
    # Keep the same number of visible cells at every tier. zoomMax is a
    # fraction of mapSize, so a fixed value changes density between maps.
    cells_per_tier = 20
    for index, (unit, fmt) in enumerate(tiers, 1):
        step_x = unit / scale_x
        zoom_max = 1e30 if unit >= 10000 else cells_per_tier * step_x / size
        lines.extend(
            [
                f"            class Zoom{index} {{",
                f"                zoomMax = {zoom_max:g};",
                '                format = "XY";',
                f'                formatX = "{fmt}";',
                f'                formatY = "{fmt}";',
                f"                stepX = {step_x:.6f};",
                f"                stepY = {unit / scale_y:.6f};",
                "            };",
            ]
        )
    lines.append("        };")
    return lines


def render_config(
    rows: list[tuple[World, list[float], str, bool]],
    baseline: dict,
    grid: bool = True,
) -> str:
    lat, lon = baseline["origin"]
    world_names = {world.name.lower() for world, _, _, _ in rows}
    grid_lines = {
        world.name.lower(): grid_patch(world, box, grid)
        for world, box, _source, _virtual in rows
    }
    if grid:
        required_text = '"A3_Data_F_Decade_Loadorder"'
    else:
        required_text = ""
    has_grid = any(grid_lines.values())
    parents = set()
    for world, _, _, _ in rows:
        if (
            world.parent
            and world.parent not in {"DefaultWorld", "CAWorld"}
            and world.parent.lower() not in world_names
        ):
            parents.add(world.parent)

    lines = [
        "// Generated by tools/mgrs_convert.py. Do not edit by hand.",
        "// Rerun the converter when the modset changes.",
        "",
        "class CfgPatches {",
        "    class zmgrs_geo {",
        '        name = "MGRS georeference table";',
        '        author = "lErrorl404l";',
        "        requiredVersion = 2.10;",
        f"        requiredAddons[] = {{{required_text}}};",
        "        units[] = {};",
        "        weapons[] = {};",
        f'        datum = "{config_string(baseline["datum"])}";',
        f"        syntheticOrigin[] = {{{lat:.6f}, {lon:.6f}}};",
        f"        syntheticZone = {baseline['zone']};",
        f'        baselineVersion = "{config_string(baseline["version"])}";',
        f'        convergence = "{config_string(baseline["convergence"])}";',
        f'        baselineLabel = "{config_string(baseline["label"])}";',
        "    };",
        "};",
        "",
        "class CfgWorlds {",
        "    class DefaultWorld" + (" { class Grid; };" if has_grid else ";"),
        "    class CAWorld: DefaultWorld {};",
    ]
    for parent in sorted(parents):
        lines.append(f"    class {parent};")
    for world, box, _source, virtual in rows:
        if not re.fullmatch(r"\w+", world.name):
            continue
        parent = world.parent or "CAWorld"
        values = ", ".join(f"{value:.6f}" for value in box)
        lines.append(f"    class {world.name}: {parent} {{")
        lines.append(f"        mgrsGeo[] = {{{values}, {1 if virtual else 0}}};")
        lines.extend(grid_lines.get(world.name.lower(), []))
        lines.append("    };")
    lines.append("};")
    lines.append("")
    return "\n".join(lines)


def render_report(
    rows: list[tuple[World, list[float], str, bool]],
    baseline: dict,
    grid: bool = True,
) -> str:
    lat, lon = baseline["origin"]
    grid_rows = sum(
        1 for world, box, _source, _virtual in rows if grid_patch(world, box, grid)
    )
    lines = [
        "# Georeference report",
        "",
        "## Baseline",
        "",
        f"- Datum: {baseline['datum']}",
        f"- Synthetic zone: {baseline['zone']}",
        f"- Synthetic origin: {lat:.4f}, {lon:.4f}",
        f"- Grid convergence: {baseline['convergence']}",
        f"- Baseline version: {baseline['version']}",
        f"- Label: {baseline['label']}",
        f"- Engine grid: {'patched' if grid else 'unchanged'} ({grid_rows} of {len(rows)} worlds)",
        "",
        "Synthetic references are exercise only. Do not use them for real-world targeting.",
        "",
        "## Worlds",
        "",
        "| World | Provenance | Source | Virtual | Grid | Lat min | Lon min | Lat max | Lon max | Map size | Map zone (declared) | Resolved zone |",
        "|---|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    for world, box, source, virtual in sorted(
        rows, key=lambda row: row[0].name.lower()
    ):
        lines.append(
            "| {name} | {prov} | {source} | {virtual} | {grid} | {a:.4f} | {b:.4f} | {c:.4f} | {d:.4f} | {size:.0f} | {zone} | {resolved} |".format(
                name=world.name,
                prov=provenance(source, virtual),
                source=source,
                virtual="yes" if virtual else "no",
                grid="yes" if grid_patch(world, box, grid) else "no",
                a=box[0],
                b=box[1],
                c=box[2],
                d=box[3],
                size=world.map_size,
                zone=world.map_zone,
                resolved=zone_for((box[1] + box[3]) / 2.0),
            )
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game", type=Path, default=None)
    parser.add_argument("--mod", type=Path, action="append", default=[])
    parser.add_argument("--pbo", type=Path, action="append", default=[])
    parser.add_argument("--out", type=Path, default=Path("."))
    parser.add_argument(
        "--overrides",
        type=Path,
        default=Path(__file__).with_name("known_terrains.json"),
    )
    parser.add_argument(
        "--baseline",
        type=Path,
        default=Path(__file__).with_name("synthetic_baseline.json"),
    )
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument(
        "--no-grid",
        action="store_true",
        help="Do not emit CfgWorlds Grid patches.",
    )
    args = parser.parse_args()

    paths = discover(args.game, args.mod, args.pbo)
    if not paths:
        print("No PBOs found. Pass --game, --mod, or --pbo.", file=sys.stderr)
        return 1

    worlds, errors = scan(paths)
    if not worlds:
        print("No CfgWorlds entries found.", file=sys.stderr)
        return 1

    overrides = load_overrides(args.overrides)
    baseline = load_baseline(args.baseline)
    rows = [(world, *resolve(world, overrides, baseline)) for world in worlds]
    grid = not args.no_grid
    config = render_config(rows, baseline, grid)
    report = render_report(rows, baseline, grid)

    counts: dict[str, int] = {}
    for _world, _box, source, _virtual in rows:
        counts[source] = counts.get(source, 0) + 1
    print(
        f"Worlds: {len(rows)}  "
        + "  ".join(f"{key}={value}" for key, value in sorted(counts.items()))
    )
    print(
        f"Baseline: {baseline['datum']} zone {baseline['zone']} "
        f"origin {baseline['origin'][0]:.4f},{baseline['origin'][1]:.4f} "
        f"version {baseline['version']}"
    )

    if args.dry_run:
        print(report)
        return 0

    addon = args.out / "addons" / "mgrs_geo"
    addon.mkdir(parents=True, exist_ok=True)
    (addon / "$PBOPREFIX$").write_text("z\\mgrs\\addons\\mgrs_geo\n", encoding="utf-8")
    (addon / "config.cpp").write_text(config, encoding="utf-8")

    (args.out / "docs").mkdir(parents=True, exist_ok=True)
    (args.out / "docs" / "georef-report.md").write_text(report, encoding="utf-8")

    payload = {
        "baseline": baseline,
        "worlds": [
            {
                "name": world.name,
                "provenance": provenance(source, virtual),
                "source": source,
                "virtual": virtual,
                "geo": box,
                "mapSize": world.map_size,
                "mapZone": world.map_zone,
                "pbo": world.pbo,
            }
            for world, box, source, virtual in rows
        ],
        "errors": errors,
    }
    (args.out / "docs" / "georef-report.json").write_text(
        json.dumps(payload, indent=2), encoding="utf-8"
    )
    print(f"Wrote {addon / 'config.cpp'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
