/*
 * Public API: world position to MGRS string. Returns "" when the terrain has
 * no georeference.
 */
params ["_pos", ["_digits", -1, [0]]];

if (_digits < 0) then {
    _digits = missionNamespace getVariable ["zmgrs_defaultDigits", 4];
};

private _geo = [worldName] call zmgrs_fnc_getGeoref;
if (count _geo < 4) exitWith { "" };

private _latLon = [_pos, _geo] call zmgrs_fnc_worldToLatLon;
_latLon params ["_lat", "_lon"];

private _utm = [_lat, _lon] call zmgrs_fnc_latLonToUtm;
_utm params ["_zone", "_easting", "_northing"];

[_zone, _easting, _northing, _lat, _digits] call zmgrs_fnc_utmToMgrs
