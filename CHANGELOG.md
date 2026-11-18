# Changelog

All notable changes to this project are recorded in this file.

The format follows Keep a Changelog. Version numbers follow Semantic
Versioning, because the Workshop uploader reads them.

## [0.1.0] - 2026-11-18

- Added: engine grid patch built from MGRS easting and northing, counted northwards.
- Added: grid tiers at 10 m, 100 m, 1 km and 10 km, with zoom thresholds scaled to the terrain.
- Added: georeference resolution for scanned terrains, with metadata scoring and a declared synthetic baseline for maps that declare nothing.
- Added: script functions mgrs_fnc_posToMGRS, mgrs_fnc_mapGridPosition, mgrs_fnc_posToUTM, mgrs_fnc_getGeoref, mgrs_fnc_getGeorefInfo and mgrs_fnc_setGeoref.
- Added: CBA settings addon with default digit count and debug logging.
- Added: ACE3 addon that replaces the DAGR and MicroDAGR grid fields.
- Added: terrain converter that scans the game and mod paths and writes the grid addon.
- Added: A-MGRS identity and launcher logo.
- Fixed: grid digit counts are clamped to the supported range.
- Fixed: the engine grid is fitted by least squares, which halves the residual against the exact conversion.
- Fixed: mgrs_fnc_setGeoref returns a defined value on every path.
- Fixed: georeference candidates are scored against the map metadata, so stale inherited boxes are rejected.
- Fixed: a box that crosses a UTM zone boundary no longer gets an engine grid, which could not follow the zone reset.
