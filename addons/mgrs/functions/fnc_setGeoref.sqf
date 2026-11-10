/*
 * Public API: pin a georeference for a world at runtime. Use this for a map
 * that falls back to a virtual reference and whose real box is known.
 *
 * Example: ["WL_Rosche", [52.9275, 10.5640, 53.0639, 10.7918]] call zmgrs_fnc_setGeoref;
 * A fifth value of 1 marks the reference as virtual.
 */
params [["_world", ""], ["_box", [], [[]]]];

if (_world == "") then { _world = worldName; };
if (count _box < 4) exitWith {};

private _geo = [_box select 0, _box select 1, _box select 2, _box select 3, 0];
if (count _box >= 5) then { _geo set [4, _box select 4]; };

private _cache = missionNamespace getVariable ["zmgrs_georefCache", createHashMap];
_cache set [_world, _geo];
missionNamespace setVariable ["zmgrs_georefCache", _cache];
