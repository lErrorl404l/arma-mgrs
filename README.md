# Arma MGRS

An Arma 3 addon that patches the engine map grid with MGRS-derived easting
and spacing, and provides a WGS 84 georeference API for terrains.

Source: https://github.com/lErrorl404l/arma-mgrs

It does not show a live readout. The engine grid, GPS and `mapGridPosition`
use the patched grid, which counts northing northwards like a printed sheet.

## What it does

- Resolves a georeference for every scanned terrain, with a declared synthetic
  baseline for maps that declare nothing.
- Writes `mgrsGeo[]` and a per-world `Grid` patch into the generated addon.
- Scales the grid cells so a 10 m, 100 m, 1 km or 10 km MGRS cell matches the
  terrain's declared lat/lon box. Each tier switches at about 20 visible cells,
  so the zoom thresholds scale with the terrain rather than using one fixed
  set of values. The script API and devices still provide 1 m digits.
- Provides MGRS, UTM and `mapGridPosition`-style conversions to scripts.

## Install

Copy the built `@mgrs` folder to the Arma 3 directory and load it as a mod.
The core needs no other mod. The settings addon loads only when CBA is
present, and the ACE compatibility addon only when ACE3 and CBA are present.

The Steam Workshop release uses the same PBOs.

## Requirements

- Arma 3 2.10 or later.
- `hemtt` on PATH for the converter and the build.
- The generated grid addon requires `A3_Data_F_Decade_Loadorder`, a base-game
  load-order anchor present in every supported build. It does not require the
  per-map addons, so a missing DLC map does not block the addon.

The core addon does not require CBA or ACE3. It contains two optional
addons. The core settings addon requires CBA and the ACE compatibility addon
requires ACE3 and CBA. Both set `skipWhenMissingDependencies = 1`, so they
skip cleanly when their dependencies are absent.

## Build

Run the converter first. It scans the game and any mod paths, then writes the
georeference and grid addon:

```
python tools/mgrs_convert.py --game "/path/to/Arma 3" --out .
python tools/mgrs_convert.py --game "/path/to/Arma 3" --mod /path/to/@TerrainMod --out .
```

`--game` on its own covers only the six official terrains. Pass every terrain
mod with `--mod` to keep the full modset table; the generated files are
overwritten each run.

Use `--no-grid` to generate the georeference table without engine `Grid`
patches. Then build the core mod:

```
hemtt build
```

The core is written to `.hemttout/build` and loaded as `@mgrs`. The core
settings and ACE compatibility addons are part of that build. No separate
packages are required.

## Headless terrain test

The resolver can be checked on the native Linux headless server. No game
client and no Wine are needed.

Build the mod, link the build folder as a mod, and start the server with a
probe mission on the terrain under test:

```
ln -s "<repo>/.hemttout/build" "@mgrs"
./arma3server_x64 -server -autoInit -mod="@mgrs" -profiles=<profile dir>
```

The probe mission calls `mgrs_fnc_getGeorefInfo` and logs the box, source,
confidence, control points and five sample conversions. Each line starts with
`[MGRS-PROBE]`. Compare the box centre and the sample strings with the real
reference for that terrain.

The probe verifies the box, the source, the confidence and the internal
consistency of the conversion. It cannot prove real-world accuracy without
ground control points.

## CBA settings

The core settings addon is part of `@mgrs` and requires CBA only. It works
without ACE3. Settings are under `MGRS > Core`:

- `Default MGRS digits`: digits per axis used when the script API is called
  without an explicit count.
- `Georeference debug log`: write the resolved box and source to the RPT.

The engine `Grid` and the terrain georeference are read at load time. CBA
cannot change them at runtime. Use the converter or a separate PBO for those
changes.

## ACE compatibility

The ACE compatibility addon is part of `@mgrs`. It sets
`skipWhenMissingDependencies = 1`, so it registers only when ACE3 and CBA are
present. It replaces the DAGR and MicroDAGR grid fields with the per-position
MGRS conversion. It is not required by the engine grid patch.

CBA settings are under `MGRS > ACE Compatibility`:

- `Enable ACE device patch`: turn the device patch off.
- `Device update interval`: grid field refresh rate.
- `DAGR full MGRS`: show zone, band and 100 km square, or digits only. Off by
  default because the full string can exceed the DAGR field.
- `DAGR precision`: 100 m, 10 m or 1 m per axis.
- `MicroDAGR precision`: 10 m or 1 m per axis.

Settings that need a mission restart are marked with the CBA restart marker.
Changing one mid-mission also produces a chat warning. The two restart settings
are `Enable ACE device patch` and `Device update interval`. The other settings
apply live.

The engine Grid stops at the 10 m tier. This keeps `mapGridPosition`, the
vanilla GPS/NAV field and the ACE map-GPS field at eight digits so they do not
wrap. One-metre precision remains in `mgrs_fnc_*` and the ACE devices.

## Multiplayer

A marker stores a world position. That position is shared by every client and
is not moved by this mod. The grid text under the marker is derived locally
from each client's `Grid` configuration.

Every client and the server should load the same core `@mgrs` build. If one
client does not load it, that client sees the vanilla grid at the same world
position. The marker, terrain and objects stay where they are. The MGRS text
differs because the grid labels differ.

The ACE device patch is part of `@mgrs` and loads only when ACE3 is present.
A player without ACE3 still sees the same world and markers, but their DAGR
and MicroDAGR use ACE's approximation. A mission that stores a grid string
sends that string to every client. The stored string does not move the marker.

## Script API

All functions are global and final:

```
_position call mgrs_fnc_posToMGRS;        // "35S LD 2960 9840"
[_position, 5] call mgrs_fnc_posToMGRS;   // 1 m digits
_player call mgrs_fnc_posToMGRS;          // Object or Position, like mapGridPosition
_position call mgrs_fnc_posToUTM;         // "35S 329603E 4398403N"
_player call mgrs_fnc_mapGridPosition;    // MGRS string, easting first
call mgrs_fnc_getGeorefInfo;              // [box, source, confidence, control, biome]
call mgrs_fnc_getGeoref;                  // [latMin, lonMin, latMax, lonMax, virtual]
["WL_Rosche", [52.9275, 10.5640, 53.0639, 10.7918]] call mgrs_fnc_setGeoref;
```

`mgrs_fnc_posToMGRS`, `mgrs_fnc_posToUTM` and
`mgrs_fnc_mapGridPosition` accept an Object or a Position and return an
empty string when the terrain has no georeference. Every function returns a
defined value. None returns `nil`.

`mgrs_fnc_getGeorefInfo` returns the box, the source token, a confidence
between 0 and 1, the control-point array and the optional biome hint. The
source tokens are `mgrsGeo`, `known`, `mapArea`, `mapArea-root`, `latlon`,
`runtime`, `cache` and `synthetic`.

`mgrs_fnc_posToMGRS` and `mgrs_fnc_mapGridPosition` use four digits per
axis when no count is passed. The `Default MGRS digits` CBA setting changes
that default.

`mgrs_fnc_setGeoref` pins a box at runtime for a map that fell back to a
virtual reference. It overrides the generated table and the runtime resolver
until the mission restarts. It does not change the engine Grid, which is read
at load time.

## Terrain georeference

A terrain can declare its own box:

```
class CfgWorlds {
    class MyWorld {
        mgrsGeo[] = {latMin, lonMin, latMax, lonMax};
    };
};
```

The values are the WGS84 corners of the terrain: `[0, 0]` is
`(latMin, lonMin)` and `[worldSize, worldSize]` is `(latMax, lonMax)`. Add a
fifth value of `1` to mark the reference as virtual.

The addon resolves the georeference in this order:

1. `mgrsGeo[]` in the world config, with `mgrsControl[]`, `mgrsSource`,
   `mgrsConfidence` and `mgrsBiome` read beside it.
2. `tools/known_terrains.json`, written into the generated table.
3. Corrections for official maps whose metadata is missing or wrong.
4. `mapArea[]` from the world config, with order detection, a `mapZone`
   cross-check, and a conflict check against the lat/lon fields.
5. `latitude`/`longitude` with the sign fixed, only when the declared
   `mapZone` matches the longitude.
6. A declared synthetic baseline (WGS 84, one zone, one origin), marked
   virtual and exercise only.

When `mapArea` and the lat/lon fields disagree by more than 0.5 degrees, the
converter rejects both and uses the virtual fallback.

### Scoring and confidence

Every candidate box is scored against the other metadata on the world:

- the declared `mapZone` must agree with the box centre longitude, unless the
  lat/lon fields agree with the box and the zone is stale;
- the box centre must sit near the declared `latitude` and `longitude`;
- the box's metric width and height must be plausible against `mapSize`;
- extreme anisotropy is penalised;
- a box identical to an official map's box on a map of a different size is
  treated as inherited metadata and rejected.

The highest-scoring candidate wins. A candidate that contradicts the other
fields is dropped rather than silently used, and `virtual = 1` is reserved
for maps with no usable data at all.

`mapSize` comes from the config when present. Ported terrains often omit it,
so the converter reads the cell count and cell size from the terrain WRP
header and multiplies them. The `reason` field in `docs/georef-report.json`
records which checks fired for each world.

### Control points

`mgrsControl[]` holds optional ground control points, one row per point:

```
mgrsControl[] = {worldX, worldY, latitude, longitude};
```

Three or more points let `mgrs_fnc_posToMGRS` and `mgrs_fnc_posToUTM` fit a
local affine transform, which corrects scale, rotation and grid convergence.
The engine `Grid` still uses the box because the engine grid cannot rotate.
With fewer than three points the API falls back to the box.

### Source, confidence and biome

Every reference carries a source token and a confidence value. A tropical
(`A`) or polar (`E`) hint lowers the confidence when the box centre falls
outside the matching latitude band. The biome never selects a location. It
rejects an implausible one.

When the world can be scanned, `mgrs_fnc_biomeBand` classifies it from the
box latitude and water fraction, then refines that verdict with surface and
vegetation evidence from the world itself. The result is a Köppen code, and
the function returns its first letter. Only bands A (tropical) and E (polar)
are unambiguous enough to lower confidence; B, C and D are recorded but
never penalise. Weak evidence returns nothing. Without a band, only
`mgrsBiome` applies.

### Real-map references

Official terrains are resolved from verified real-world inspirations, not
from the shipped metadata alone:

| Terrain | Real area |
|---|---|
| Altis | Lemnos, Greece |
| Stratis | Agios Efstratios, Greece |
| Malden | Lefkada, Greece |
| Tanoa | Ovalau, Fiji |
| Livonia (Enoch) | Chřiby, Czechia |
| VR | synthetic training space |

Where the real extent has a uniform scale, the box keeps it. Stratis and
Enoch were non-uniform, so both are metric squares sized to `mapSize` around
the verified centre.

The converter in `tools/mgrs_convert.py` runs steps 1 to 5 over every scanned
PBO and writes `addons/mgrs_geo/config.cpp`. That file is generated; do not
edit it.

## Baseline and provenance

`tools/synthetic_baseline.json` declares the synthetic reference:

```
{
  "datum": "WGS84",
  "zone": 31,
  "origin": [30.0, 3.0],
  "version": "1.0.0",
  "convergence": "world north assumed grid north",
  "label": "Declared synthetic training baseline"
}
```

Every map that falls back to synthetic uses this zone and origin. The report
records a provenance for each map: `real/declared`, `derived`, or `synthetic`.
It also states the datum, zone, origin, convergence assumption, and baseline
version. Synthetic references are exercise only and must not be used for
real-world targeting.

## Real-world overrides

`tools/known_terrains.json` maps a world name to a real box:

```
{
  "northtakistan": [35.0, 62.0, 36.0, 63.0],
  "map_with_control": {
    "box": [52.927, 10.564, 53.063, 10.791],
    "controlPoints": [
      [1200, 3400, 52.98, 10.61],
      [8200, 9100, 53.03, 10.74]
    ],
    "source": "survey",
    "confidence": 0.95,
    "biome": "C"
  }
}
```

An entry here wins over automatic resolution and is written into the
generated table. Rerun the converter after editing. The runtime alternative
is `mgrs_fnc_setGeoref`:

```
["WL_Rosche", [52.9275, 10.564, 53.0639, 10.7918], [[1200, 3400, 52.98, 10.61]], "survey", 0.95] call mgrs_fnc_setGeoref;
```

## Limits

- The engine grid draws numerals only. It cannot draw the MGRS zone, latitude
  band or 100 km square letters.
- The engine grid stops at the 10 m tier. `mapGridPosition` and the vanilla
  and ACE map-GPS fields show eight digits. One-metre precision is available
  only through the script API and the ACE device patch.
- Vanilla grids use a negative `stepY` and count northing down from the top.
  The patched grid uses a positive `stepY`, so northing increases northwards
  and matches a printed map sheet. CBA's `northingReversed` and `mapGridToPos`
  functions keep their own handling for unpatched maps.
- The box path maps the terrain linearly onto its declared lat/lon box. It
  is not a geodetic transform. Expect hundreds of metres of error against a
  survey-grade position. Control points improve the script API and the
  devices, not the engine `Grid`.
- A datum transformation never improves the accuracy of the source survey
  (Eurocontrol WGS 84 Implementation Manual, v2.4, §4.1.3). Published
  parameter sets can differ by up to 50 m, and a 0.1 m survey can land at
  metre-level accuracy after transformation. The confidence value describes
  the provenance of the box, not a survey accuracy.
- Altis maps a 41 km real region onto a 30.72 km terrain, so in-game
  distances are about 0.75 of real distances. A 10 m MGRS cell is about
  7.5 world metres there. This is the terrain's own scale, not a conversion
  error.
- `mgrsBiome` is a manual hint. Automatic terrain classification is not
  implemented.
- Altis crosses the 4,400,000 m northing line about 1.6 km north of its
  southern edge. A single engine grid cannot represent the 100 km reset.
- The engine grid patch uses `A3_Data_F_Decade_Loadorder` to load after the
  base data. Custom terrains that load as mods can still shadow it; they are
  not patched by the single generated config.
- The engine UAV HUD remains a 3+3, 100 m grid. The ACE compatibility addon
  patches the DAGR and MicroDAGR fields, not the UAV HUD.
- ACE waypoint and target-name paths still use ACE's final
  `getMapGridFromPos` function. Only the direct DAGR and MicroDAGR readouts
  are replaced.
- UPS (polar) conversion is not implemented; the band returns `Z`.
- A box that spans a UTM zone boundary cannot produce one engine `Grid`. The
  script API still returns the correct zone for each position. Chernarus
  crosses 30 E at its centre, so it gets the API without a patched grid.
- Ported terrains that ship no `Grid` block get a synthesised one at the same
  four tiers.
- The baseline assumes WGS 84 and that world north equals grid north.

## License

GNU General Public License v2.0 or later. See [LICENSE](LICENSE).
