/*
 * Map Draw handler. Reads the current cursor position (or the player) and
 * writes the configured reference into the readout control.
 */
params ["_map"];

private _display = ctrlParent _map;
if (isNull _display) exitWith {};

private _readout = _display getVariable ["mgrs_readoutCtrl", controlNull];
if (isNull _readout) exitWith {};

if (!(missionNamespace getVariable ["mgrs_enabled", true])) exitWith {
    _readout ctrlShow false;
};

private _now = diag_tickTime;
if (_now < (missionNamespace getVariable ["mgrs_nextUpdate", 0])) exitWith {};
missionNamespace setVariable ["mgrs_nextUpdate", _now + 0.1];

private _pos = if (missionNamespace getVariable ["mgrs_followCursor", true]) then {
    private _mapPos = ctrlPosition _map;
    private _mouse = ctrlMousePosition _map;
    private _screen = [
        (_mapPos select 0) + (_mouse select 0) * (_mapPos select 2),
        (_mapPos select 1) + (_mouse select 1) * (_mapPos select 3)
    ];
    _map ctrlMapScreenToWorld _screen
} else {
    getPosATL player
};

private _digits = (missionNamespace getVariable ["mgrs_precision", 8]) / 2;
private _type = missionNamespace getVariable ["mgrs_gridType", 0];

private _text = switch (_type) do {
    case 1: {
        [_pos] call mgrs_fnc_posToUTM
    };
    case 2: {
        format [
            "%1   |   %2",
            [_pos, _digits] call mgrs_fnc_posToMGRS,
            [_pos] call mgrs_fnc_posToUTM
        ]
    };
    default {
        [_pos, _digits] call mgrs_fnc_posToMGRS
    };
};

if (_text == "") then {
    _text = "MGRS: no georeference for this terrain";
};

private _geo = [worldName] call mgrs_fnc_getGeoref;
private _meta = "";
if (count _geo >= 4) then {
    private _latLon = [_pos, _geo] call mgrs_fnc_worldToLatLon;
    private _utm = [_latLon select 0, _latLon select 1] call mgrs_fnc_latLonToUTM;
    private _lon0 = ((_utm select 0) - 1) * 6 - 180 + 3;
    private _gamma = atan (tan ((_latLon select 1) - _lon0) * sin (_latLon select 0));
    _meta = format ["   G %1°", (round (_gamma * 10)) / 10];
};
private _decl = getNumber (configFile >> "CfgWorlds" >> worldName >> "mgrsDeclination");
if (_decl != 0) then {
    _meta = _meta + format [
        "   M %1°%2",
        (round ((abs _decl) * 10)) / 10,
        ["W", "E"] select (_decl > 0)
    ];
};
_text = _text + _meta;
if ((count _geo >= 5) && ((_geo select 4) == 1)) then {
    _text = _text + "   (virtual)";
};

_readout ctrlShow true;
_readout ctrlSetText _text;
