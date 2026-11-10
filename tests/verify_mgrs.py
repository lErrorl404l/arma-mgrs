"""Check the addon's UTM/MGRS maths against the mgrs reference library.

The SQF in addons/mgrs/functions is a direct transcription of these formulas.
Run with a virtualenv that has mgrs installed:

    uv venv .venv
    uv pip install --python .venv/bin/python mgrs
    .venv/bin/python tests/verify_mgrs.py
"""

import math
import random
import re

import mgrs

A = 6378137.0
F = 1 / 298.257223563
E2 = F * (2 - F)
E4 = E2 * E2
E6 = E4 * E2
EP2 = E2 / (1 - E2)
K0 = 0.9996


def lat_lon_to_utm(lat, lon):
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

    n = A / math.sqrt(1 - E2 * sin_lat * sin_lat)
    t = tan_lat * tan_lat
    c = EP2 * cos_lat * cos_lat
    aa = cos_lat * dlon

    m = A * (
        (1 - E2 / 4 - 3 * E4 / 64 - 5 * E6 / 256) * latr
        - (3 * E2 / 8 + 3 * E4 / 32 + 45 * E6 / 1024) * math.sin(2 * latr)
        + (15 * E4 / 256 + 45 * E6 / 1024) * math.sin(4 * latr)
        - (35 * E6 / 3072) * math.sin(6 * latr)
    )

    easting = (
        K0
        * n
        * (
            aa
            + (1 - t + c) * aa**3 / 6
            + (5 - 18 * t + t * t + 72 * c - 58 * EP2) * aa**5 / 120
        )
        + 500000
    )

    northing = K0 * (
        m
        + n
        * tan_lat
        * (
            aa**2 / 2
            + (5 - t + 9 * c + 4 * c * c) * aa**4 / 24
            + (61 - 58 * t + t * t + 600 * c - 330 * EP2) * aa**6 / 720
        )
    )
    if lat < 0:
        northing += 10000000

    return zone, easting, northing


def band_letter(lat):
    if lat < -80 or lat > 84:
        return "Z"
    return "CDEFGHJKLMNPQRSTUVWX"[min(19, math.floor((lat + 80) / 8))]


def to_mgrs(lat, lon, digits=4):
    zone, easting, northing = lat_lon_to_utm(lat, lon)
    col_set = ["ABCDEFGH", "JKLMNPQR", "STUVWXYZ"][(zone - 1) % 3]
    col = col_set[max(0, min(7, math.floor(easting / 100000) - 1))]
    row_index = math.floor(northing / 100000) % 20
    if zone % 2 == 0:
        row_index = (row_index + 5) % 20
    row = "ABCDEFGHJKLMNPQRSTUV"[row_index]

    scale = 10 ** (5 - digits)
    east = math.floor((math.floor(easting) % 100000) / scale)
    north = math.floor((math.floor(northing) % 100000) / scale)
    return f"{zone}{band_letter(lat)} {col}{row} {east:0{digits}d} {north:0{digits}d}"


def canonical(text):
    match = re.match(
        r"^0*(\d+)([A-Z])([A-Z]{2})(\d+)$",
        text.replace(" ", ""),
    )
    return int(match.group(1)), match.group(2), match.group(3), match.group(4)


def main():
    reference = mgrs.MGRS()
    random.seed(1)
    points = [
        (39.7185, 25.012),
        (40.0946, 25.4815),
        (-20.2, 174.07),
        (54.0, 23.0),
        (38.8977, -77.0365),
        (48.85837, 2.294481),
    ]
    points += [(random.uniform(-79, 83), random.uniform(-179, 179)) for _ in range(500)]

    checked = 0
    mismatches = 0
    for lat, lon in points:
        for digits in (3, 4, 5):
            checked += 1
            mine = canonical(to_mgrs(lat, lon, digits))
            theirs = canonical(reference.toMGRS(lat, lon, MGRSPrecision=digits))
            if mine != theirs:
                mismatches += 1
                print("mismatch", lat, lon, digits, mine, theirs)

    print(f"checked {checked} conversions, {mismatches} mismatches")
    return 1 if mismatches else 0


if __name__ == "__main__":
    raise SystemExit(main())
