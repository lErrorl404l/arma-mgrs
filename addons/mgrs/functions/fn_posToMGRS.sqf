/*
 * Public API: world position to MGRS string. Returns "" when the terrain has
 * no georeference.
 */
params [["_pos", [0, 0, 0], [[], objNull], [2, 3]], ["_digits", -1, [0]]];

if (_pos isEqualType objNull) then { _pos = getPos _pos; };

if (_digits < 0) then {
    _digits = missionNamespace getVariable ["mgrs_defaultDigits", 4];
};

private _info = [worldName] call mgrs_fnc_getGeorefInfo;
_info params ["_geo", "_source", "_confidence", "_control"];
if (count _geo < 4) exitWith { "" };

private _latLon = [_pos, _geo, 0, _control] call mgrs_fnc_worldToLatLon;
_latLon params ["_lat", "_lon"];

private _utm = [_lat, _lon] call mgrs_fnc_latLonToUTM;
_utm params ["_zone", "_easting", "_northing"];

[_zone, _easting, _northing, _lat, _digits] call mgrs_fnc_utmToMGRS
