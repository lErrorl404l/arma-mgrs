/*
 * Returns [latMin, lonMin, latMax, lonMax, virtual] for a world.
 * The richer source, confidence, control-point and biome data is available
 * from mgrs_fnc_getGeorefInfo.
 */
params [["_world", ""]];

private _info = [_world] call mgrs_fnc_getGeorefInfo;
_info select 0
