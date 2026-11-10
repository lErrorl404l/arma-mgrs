/*
 * Public API: world position to a plain UTM string. Returns "" when the terrain
 * has no georeference.
 */
params [["_pos", [0, 0, 0], [[], objNull], [2, 3]]];

if (_pos isEqualType objNull) then { _pos = getPos _pos; };

private _info = [worldName] call mgrs_fnc_getGeorefInfo;
_info params ["_geo", "_source", "_confidence", "_control"];
if (count _geo < 4) exitWith { "" };

private _latLon = [_pos, _geo, 0, _control] call mgrs_fnc_worldToLatLon;
_latLon params ["_lat", "_lon"];

private _utm = [_lat, _lon] call mgrs_fnc_latLonToUTM;
_utm params ["_zone", "_easting", "_northing"];

format ["%1%2 %3E %4N", _zone, [_lat] call mgrs_fnc_latToBand, round _easting, round _northing]
