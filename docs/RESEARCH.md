# Arma 3 MGRS grid: feasibility study

Date: 2026-11-08. Scope: Arma 3 2.20, ACE3 3.21.2, CBA_A3 3.19.0.

## Verdict

The engine map grid cannot be turned into MGRS for every map at runtime. The
grid is per-world configuration, engine-drawn, and numeric only. A config
patch can make the digits finer for a named world, but it cannot draw the
MGRS zone, latitude band, or 100 km square letters, and it cannot apply to
every terrain in one step.

The workable config approach is an MGRS-scaled engine grid plus a per-terrain
georeference. This repository implements that as a generated per-world Grid
patch and a global georeference API. The grid is numeric only; the zone, band
and 100 km square letters are not drawn.

## What the Arma grid is

The grid comes from `CfgWorlds >> <world> >> Grid`. Extract of Altis from
`Addons/map_altis.pbo`:

```
mapSize = 30720;
mapZone = 35;
mapArea[] = {25.012, 39.7185, 25.4815, 40.0946};
class Grid: Grid {
    offsetX = 0;
    offsetY = 30720;
    class Zoom1 { zoomMax = 0.05; format = "XY"; formatX = "000"; stepX = 100;  stepY = -100;  };
    class Zoom2 { zoomMax = 0.5;  format = "XY"; formatX = "00";  stepX = 1000; stepY = -1000; };
    class Zoom3 { zoomMax = 1e30; format = "XY"; formatX = "0";   stepX = 10000; stepY = -10000; };
};
```

- `stepX`/`stepY` set the grid cell in metres for that zoom band.
- `formatX`/`formatY` set the zero-padded width of the numeric label, so the
  label is `coordinate / step` with that width.
- `offsetX`/`offsetY` shift the numbering origin. `offsetY = mapSize` with a
  negative `stepY` gives the south-west corner the label 000.
- `zoomMax` selects the band. Small values are zoomed in.

All official terrains use the same three bands: 100 m, 1 km, 10 km. Only the
`zoomMax` thresholds and `mapSize` differ.

### mapGridPosition

`mapGridPosition` returns the padded easting and northing of the active
`ZoomN` class, as the BI wiki states: "The format is determined by the Grid
format specified in the CfgWorlds for the current world. Eg: `024577` or
`De82` or similar."

There is no command to set the grid at runtime. The map command group has
`mapGridPosition` only. ACE3 reads the same config in
`ace_map_fnc_determineZoom` and limits the maximum map zoom to the 100 m
band.

## Can a mod change the grid?

Yes, for a named world, with a config patch. The patch replaces the `Grid`
class inside the world class. A working shape:

```
class CfgWorlds {
    class DefaultWorld { class Grid; };
    class CAWorld: DefaultWorld {};
    class Altis: CAWorld {
        class Grid: Grid {
            class Zoom1 { zoomMax = 0.05; format = "XY"; formatX = "0000"; formatY = "0000"; stepX = 10; stepY = -10; };
        };
    };
};
```

The extern chain (`DefaultWorld`, `CAWorld`, the world) must be declared or
the patch does not resolve. The override applies at load time.

What this buys: `mapGridPosition` then returns 4 digits per axis at maximum
zoom, and the map draws 10 m lines. Setting `stepX = 1` and a 5-digit format
gives 1 m digits.

What it does not buy:

- No zone, band, or 100 km square letters. The engine draws numerals only.
- The numerals count from the world origin, not from a UTM 100 km square.
  `offsetX`/`offsetY` can shift them, but the digits still repeat every
  10 km on a 30 km map unless the offset is tuned per terrain.
- One patch per world. There is no wildcard for "every map", and custom
  terrains load after yours.
- At 10 m, Altis has 3,072 lines per axis and labels overlap at maximum
  zoom.
- No runtime toggle. The setting is fixed when the world loads.
- The label is a zero-padded number, not a template. Every shipped world
  checked (Altis, Stratis, Tanoa, Livonia, Chernarus, Utes) uses
  `format = "XY"` and zero-only `formatX`/`formatY`. The engine has no
  per-cell text, so the GZD and 100 km square letters cannot be drawn by the
  grid.
- 100 km wrap is undocumented. An offset can align the digits to the UTM
  square, but whether a label past 9999 wraps to 0000 or overflows is
  unknown. Altis crosses 4,400,000 m N about 1.6 km north of its southern
  edge, so this one behaviour decides whether the northern part of Altis can
  be labelled correctly.

Community grid fixes use the same mechanism. CUP ships an addon named
`CUP_Worlds_Grid` for this purpose. That is evidence the patch works, and
also evidence it is a per-map compatibility problem.

### Load time is not runtime

A PBO config is applied when the process starts, after the base game PBOs,
and it can override BI classes. That is the mechanism above. Two checks on
the local 2.20 server:

- A patch setting `CfgWorlds >> Stratis >> Grid >> Zoom1 >> formatX` to
  `"0000"` reads back as `"0000"`.
- A patch adding a `Zoom0` class to `CAWorld >> Grid` makes
  `isClass (CfgWorlds >> Stratis >> Grid >> Zoom0)` true without naming
  Stratis. Worlds inherit classes they do not define.

So one patch can add a tier to every world. It cannot rewrite the Zoom1,
Zoom2, and Zoom3 values that each world defines itself; those must be named
one by one. The merge happens once, before scripts run. Config is immutable
afterwards. There is no wildcard, no loop, and no reaction to the map the
mission selects. `configClasses` also ignores inherited entries, so the
engine may not enumerate an inherited tier; a client test is still needed.

The only runtime merge is `diag_mergeConfigFile`, which BI restricts to the
Diagnostics Exe: dev branch, single-player, file-based.

## Why "9-digit" is not standard

MGRS digits are always paired, one set for easting and one for northing.
Valid totals are 0, 2, 4, 6, 8, or 10 digits. Eight digits (4 + 4) is the
NATO standard at 10 m. Ten digits (5 + 5) is 1 m. Nine digits has no MGRS
meaning. The demo exposes 6, 8, and 10.

## The georeference problem

MGRS needs a position on the WGS84 ellipsoid. Arma terrain config carries
three candidate fields, and none is dependable:

- `mapZone`: documented as "UTM Zone". It is missing or wrong on several
  terrains. Tanoa declares 60, which happens to match its longitude.
- `mapArea[]`: documented as `{lonSW, latSW, lonNE, latNE}`. BI notes it is
  "not used anyhow". Stored values are inconsistent:
  - Altis: `{25.012, 39.7185, 25.4815, 40.0946}` (lon first, Lemnos box).
  - Tanoa: `{-20.268, 174.003, -20.1353, 174.146}` (lat first).
  - Malden: copies the Altis box. Malden is fictional.
  - Livonia: `{}`. Stratis: absent. VR: absent.
- `latitude`/`longitude`: the sign is reversed (negative means north), and
  the values do not match `mapArea`. Altis has `-35.152` against a 39.72 N
  box corner. Do not use them for MGRS.

So a reliable addon needs a table. This demo ships a table for the official
terrains and a config hook (`mgrsGeo[]`) for terrain authors. The table maps
the south-west and north-east corners of the terrain onto the declared
lat/lon box. That is a linear approximation, not a geodetic transform.

## Military practice

A military map is usable only with a horizontal datum, spheroid, projection,
grid zone designation, grid convergence, and a control note. TC 3-25.26
paragraph 3-1 lists the marginal data. AGeoP-21 Annex B and NGA.STND.0037
cover the grid and the datum.

MGRS is not a datum. It encodes UTM on WGS 84. The same point on different
datums can differ by up to 900 m (TC 3-25.26 paragraph 3-1(17)). AGeoP-21
D.3.3 says to avoid datum transformations for targeting.

When control is missing or contradictory, the doctrinal outcome is a flag,
not a guess. NGA.STND.0037 section 9-11b prescribes notes such as "cannot be
placed on the World Geodetic System 1984 (WGS 84) Datum". A flagged sheet is
not a targeting source.

There is no published NATO, NGA, or UK doctrine for synthetic terrain
georeferencing. DIS and the RPR FOM transmit Earth-centred, Earth-fixed
WGS 84 positions. OGC CDB requires a WGS 84 extent. A fictional terrain must
be given a real WGS 84 anchor or it cannot join a mixed real and synthetic
picture. The defensible practice is a declared datum, zone, and origin,
marked synthetic and versioned. That is an engineering inference, not
doctrine.

The doctrinal terms are "geodetic control" and "horizontal datum". "Map
registration" does not appear in the sources. JSP 945 is configuration
management, not a geospatial standard. It is the regime for baselining the
table.

## Converter and synthetic baseline

`tools/mgrs_convert.py` removes the dependency on terrain authors. It scans
every PBO passed to it, parses `CfgWorlds`, and resolves a box:

1. `mgrsGeo[]`.
2. `mapArea[]`, with order detection and a `mapZone` cross-check.
3. Corrections for the official maps whose metadata is missing or wrong.
4. `latitude`/`longitude` with the north sign fixed, box derived from
   `mapSize`, accepted only when the declared `mapZone` matches the
   longitude. BI's fields are unreliable on their own; one UK map resolved to
   Papua New Guinea before this check.
5. A declared synthetic baseline: WGS 84, one UTM zone, one origin, marked
   virtual and exercise only.

For the six official terrains the converter resolves three from `mapArea`
(Altis, Malden, Tanoa) and three from corrections (Stratis, Livonia, VR). A
custom terrain with no usable metadata gets the declared synthetic reference
instead of no reference.

On the installed modset (28 worlds), 6 resolve from official corrections, 1
from `mapArea`, 1 from the root `CfgWorlds` box, 5 from
`latitude`/`longitude`, and 15 are synthetic. The synthetic group is
fictional maps, maps with no metadata, and maps whose metadata contradicts
itself. Rosche carries Altis's `mapArea`; North Takistan carries Tanoa's. The
converter rejects a box that disagrees with the lat/lon fields by more than
0.5 degrees, so those maps become synthetic rather than confidently wrong.
That is the cost of not trusting authors: some real maps lose a real
reference, but no map gets a false one.

The synthetic origin is declared in `tools/synthetic_baseline.json` and
written into `CfgPatches >> mgrs_geo`. The runtime reads it from there. The
zone, datum, and origin are a policy, not a per-map accident. All synthetic
maps share the origin, so the reference is consistent and briefable.

The output is `addons/mgrs_geo/config.cpp`, which adds `mgrsGeo[]` to each
world. The runtime addon reads that array before any other source, so the
grid patch and the public API cannot disagree.

This does not make a fictional map geographically real. It makes the
reference valid, stable, and marked. A terrain that declares a real box is
still preferred.

## ACE3 integration

- ACE3 registers map settings under `format["ACE %1", localize LSTRING(Module_DisplayName)]`,
  which is "ACE Map" in English. A third-party addon can pass the same
  string to `CBA_fnc_addSetting`; CBA groups categories by their resolved
  string. Use the composed localised form, not a hardcoded "ACE Map", or
  non-English clients get a second category.
- ACE3 already has `ace_common_fnc_getMapGridFromPos`. It returns a
  10-digit Arma grid, not MGRS: no zone, band, or 100 km square.
- The ACE GPS widget is drawn on the map display. Control 913592 holds the
  grid text and `ace_maptools_fnc_openMapGpsUpdate` rewrites it twice per
  second with `mapGridPosition`. ACE exposes no event or public setter for
  that text. Fighting the writer would flicker. The demo creates its own
  control instead.
- The map display class is `RscDiary` (display 12, control 51). ACE hooks it
  with `Extended_DisplayLoad_EventHandlers`. The demo uses the same hook.

## Verification

- `hemtt build` and `hemtt check` pass.
- The UTM and MGRS algorithms were ported to Python and compared with the
  `mgrs` 1.7.0 reference library over 1,518 conversions (3, 4, and 5 digits,
  506 positions including both hemispheres). Zero mismatches after zone
  zero-padding normalisation.
- Runtime test in this environment was blocked. The local Linux dedicated
  server has no working mission autostart: `-autoInit` reports "supported
  only for persistent missions" even with `persistent = 1` in the mission
  class, and addon preInit handlers do not run without a mission. In a real
  client, three things still need a visual check: control placement on the
  map, the band change across 40 degrees north on Altis, and the CBA
  category merge with ACE Map.

## Limits

- The lat/lon box is a linear stretch of the terrain. Expect hundreds of
  metres of error against a survey-grade position. Arma maps are fictional
  or compressed; consistency matters more than absolute accuracy.
- Altis crosses the S/T band boundary at 40 degrees north. The 4,400,000 m
  northing line is about 1.6 km north of the southern edge. A single engine
  grid cannot represent the 100 km reset.
- A terrain that declares no usable box gets the declared synthetic
  baseline, marked virtual and exercise only.
- UPS (polar) conversion is not implemented; the band returns "Z".
- Grid zone exceptions (Norway, Svalbard) are implemented but untested.

## References

- AGeoP-21 Edition A Version 1 (STANAG 2211 Edition 7), *Geodetic Datums,
  Projections, Grids and Grid References*, 2016.
- NGA.STND.0037 v2.0.0, *Universal Grids and Grid Reference Systems*, 2014.
  Supersedes DMA TM 8358.1.
- TC 3-25.26, *Map Reading and Land Navigation*, 2013.
- IEEE 1278.1 (DIS) world coordinates, Earth-centred Earth-fixed WGS 84.
- OGC CDB 1.0, Volume 1, WGS 84 and geocell requirements.
- BI, *Arma 3: CfgWorlds Config Reference*.

## Recommended next steps

1. Test in a real client with ACE3 and CBA.
2. Fill `tools/known_terrains.json` for real maps whose location is known.
3. Optional overlay for 100 km square boundaries, at most a few lines per
   map.
4. If the engine grid must change, ship per-terrain patches and accept the
   numeric-only result. Do not present that as MGRS.
