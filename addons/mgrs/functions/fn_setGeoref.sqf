/*
 * Public API: pin a georeference for a world at runtime. Use this for a map
 * that falls back to a virtual reference and whose real box is known.
 *
 * Example: ["WL_Rosche", [52.9275, 10.5640, 53.0639, 10.7918]] call mgrs_fnc_setGeoref;
 * A fifth value of 1 marks the reference as virtual.
 */
params [
    ["_world", ""],
    ["_box", [], [[]]],
    ["_control", [], [[]]],
    ["_source", "runtime", [""]],
    ["_confidence", 0.5, [0]],
    ["_biome", "", [""]]
];

if (_world == "") then { _world = worldName; };
if (count _box < 4) exitWith {};

private _geo = [_box select 0, _box select 1, _box select 2, _box select 3, 0];
if (count _box >= 5) then { _geo set [4, _box select 4]; };

private _cache = missionNamespace getVariable ["mgrs_georefCache", createHashMap];
_cache set [_world, _geo + [_source, _confidence, _control, _biome]];
missionNamespace setVariable ["mgrs_georefCache", _cache];
