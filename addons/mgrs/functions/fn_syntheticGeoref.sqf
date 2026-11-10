/*
 * Synthetic georeference for a world that declares no usable real location.
 * The origin comes from the declared baseline in CfgPatches >> mgrs_geo
 * (WGS84, one UTM zone, one origin). Synthetic references are exercise only.
 * Fallback constants match tools/synthetic_baseline.json.
 */
params ["_world", ["_size", 0]];

if (_size <= 0) then { _size = worldSize; };

private _cfg = configFile >> "CfgPatches" >> "mgrs_geo";
private _origin = getArray (_cfg >> "syntheticOrigin");
if (count _origin < 2) then { _origin = [30.0, 3.0]; };
_origin params ["_lat", "_lon"];

private _halfLat = (_size / 2) / 111320;
private _halfLon = (_size / 2) / (111320 * ((cos _lat) max 0.05));

[_lat - _halfLat, _lon - _halfLon, _lat + _halfLat, _lon + _halfLon, 1]
