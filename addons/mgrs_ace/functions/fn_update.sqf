params [["_mode", "", [""]]];

private _player = missionNamespace getVariable ["ACE_player", player];
if (isNull _player) exitWith {};

private _pos = getPos _player;

switch (_mode) do {
    case "dagr": {
        private _digits = missionNamespace getVariable ["mgrs_ace_dagrDigits", 4];
        private _mgrs = [_pos, _digits] call mgrs_fnc_posToMGRS;
        if (_mgrs == "") exitWith {};

        private _parts = _mgrs splitString " ";
        if (count _parts < 4) exitWith {};

        private _display = uiNamespace getVariable ["DAGR_Display", displayNull];
        if (isNull _display) then {
            _display = uiNamespace getVariable ["DAGR_DISPLAY", displayNull];
        };
        if (isNull _display) exitWith {};

        private _ctrl = _display displayCtrl 266851;
        if (isNull _ctrl) exitWith {};

        private _text = if (missionNamespace getVariable ["mgrs_ace_dagrFull", false]) then {
            format ["%1 %2 %3 %4", _parts select 0, _parts select 1, _parts select 2, _parts select 3]
        } else {
            format ["%1 %2", _parts select 2, _parts select 3]
        };
        _ctrl ctrlSetText _text;
    };
    case "micro": {
        private _digits = missionNamespace getVariable ["mgrs_ace_microDigits", 5];
        private _mgrs = [_pos, _digits] call mgrs_fnc_posToMGRS;
        if (_mgrs == "") exitWith {};

        private _parts = _mgrs splitString " ";
        if (count _parts < 4) exitWith {};

        private _display = uiNamespace getVariable ["ace_microdagr_RscTitleDisplay", displayNull];
        if (isNull _display) then {
            _display = uiNamespace getVariable ["ace_microdagr_DialogDisplay", displayNull];
        };
        if (isNull _display) exitWith {};

        private _utmCtrl = _display displayCtrl 144001;
        if (!isNull _utmCtrl) then {
            _utmCtrl ctrlSetText (format ["%1 %2", _parts select 0, _parts select 1]);
        };
        private _eCtrl = _display displayCtrl 144002;
        if (!isNull _eCtrl) then {
            _eCtrl ctrlSetText ((_parts select 2) + "e");
        };
        private _nCtrl = _display displayCtrl 144003;
        if (!isNull _nCtrl) then {
            _nCtrl ctrlSetText ((_parts select 3) + "n");
        };
    };
};
