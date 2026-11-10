/*
 * Public API: mapGridPosition-compatible MGRS string. Always easting then
 * northing, from the terrain georeference rather than the engine grid.
 */
params [["_pos", [0, 0, 0], [[]], [2, 3]], ["_digits", -1, [0]]];

[_pos, _digits] call zmgrs_fnc_posToMgrs
