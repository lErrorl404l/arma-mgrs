/*
 * Public API: world position to a plain UTM string. Returns "" when the terrain
 * has no georeference.
 */
params ["_pos"];

private _geo = [worldName] call zmgrs_fnc_getGeoref;
if (count _geo < 4) exitWith { "" };

private _latLon = [_pos, _geo] call zmgrs_fnc_worldToLatLon;
_latLon params ["_lat", "_lon"];

private _utm = [_lat, _lon] call zmgrs_fnc_latLonToUtm;
_utm params ["_zone", "_easting", "_northing"];

format ["%1%2 %3E %4N", _zone, [_lat] call zmgrs_fnc_latToBand, round _easting, round _northing]
