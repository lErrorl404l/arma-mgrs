# MGRS Grid Reference

An Arma 3 addon that patches the engine map grid with MGRS-derived easting
and spacing, and provides a WGS 84 georeference API for terrains.

Source: https://github.com/lErrorl404l/arma-mgrs

It does not show a live readout. The engine grid, GPS and `mapGridPosition`
use the patched grid; the engine still numbers northing from the top.

## What it does

- Resolves a georeference for every scanned terrain, with a declared synthetic
  baseline for maps that declare nothing.
- Writes `mgrsGeo[]` and a per-world `Grid` patch into the generated addon.
- Scales the grid cells so a 10 m, 100 m, 1 km or 10 km MGRS cell matches the
  terrain's declared lat/lon box. Each tier switches at about 20 visible cells,
  so the zoom thresholds scale with the terrain rather than using one fixed
  set of values. The script API and devices still provide 1 m digits.
- Provides MGRS, UTM and `mapGridPosition`-style conversions to scripts.

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
wrap. One-metre precision remains in `zmgrs_fnc_*` and the ACE devices.

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
_position call zmgrs_fnc_posToMgrs;        // "35S LD 29603 98403"
[_position, 5] call zmgrs_fnc_posToMgrs;   // 1 m digits
_position call zmgrs_fnc_posToUtm;         // "35S 329603E 4398403N"
_position call zmgrs_fnc_mapGridPosition;  // MGRS string, easting first
call zmgrs_fnc_getGeoref;                  // [latMin, lonMin, latMax, lonMax, virtual]
["WL_Rosche", [52.9275, 10.5640, 53.0639, 10.7918]] call zmgrs_fnc_setGeoref;
```

`zmgrs_fnc_posToMgrs`, `zmgrs_fnc_posToUtm` and
`zmgrs_fnc_mapGridPosition` return an empty string when the terrain has no
georeference.

`zmgrs_fnc_posToMgrs` and `zmgrs_fnc_mapGridPosition` use four digits per
axis when no count is passed. The `Default MGRS digits` CBA setting changes
that default.

`zmgrs_fnc_setGeoref` pins a box at runtime for a map that fell back to a
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

1. `mgrsGeo[]` in the world config.
2. `mapArea[]` from the world config, with order detection, a `mapZone`
   cross-check, and a conflict check against the lat/lon fields.
3. Corrections for official maps whose metadata is missing or wrong.
4. `latitude`/`longitude` with the sign fixed, only when the declared
   `mapZone` matches the longitude.
5. A declared synthetic baseline (WGS 84, one zone, one origin), marked
   virtual and exercise only.

When `mapArea` and the lat/lon fields disagree by more than 0.5 degrees, the
converter rejects both and uses the virtual fallback.

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
  "northtakistan": [35.0, 62.0, 36.0, 63.0]
}
```

An entry here wins over automatic resolution and is written into the
generated table. Rerun the converter after editing. The runtime alternative
is `zmgrs_fnc_setGeoref`.

## Limits

- The engine grid draws numerals only. It cannot draw the MGRS zone, latitude
  band or 100 km square letters.
- The engine grid stops at the 10 m tier. `mapGridPosition` and the vanilla
  and ACE map-GPS fields show eight digits. One-metre precision is available
  only through the script API and the ACE device patch.
- The engine numbers northing from the top. A positive `stepY` patch does not
  change that, though CBA's `northingReversed` and `mapGridToPos` functions
  handle reversed maps for their own conversions.
- The conversion maps the terrain linearly onto its declared lat/lon box. It
  is not a geodetic transform. Expect hundreds of metres of error against a
  survey-grade position.
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
- The baseline assumes WGS 84 and that world north equals grid north.
