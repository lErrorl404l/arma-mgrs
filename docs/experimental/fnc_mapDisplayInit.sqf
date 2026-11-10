/*
 * DisplayLoad handler for RscDiary (the in-game map, display 12). Creates the
 * readout control and wires it to the map control's Draw event.
 */
params ["_display"];

if (isNull _display) exitWith {};

private _map = _display displayCtrl 51;
if (isNull _map) exitWith {};

private _readout = _display ctrlCreate ["RscText", -1];
_readout ctrlSetPosition [0.02, 0.02, 0.60, 0.05];
_readout ctrlSetBackgroundColor [0, 0, 0, 0.45];
_readout ctrlSetTextColor [1, 1, 1, 1];
_readout ctrlSetFont "EtelkaMonospacePro";
_readout ctrlSetFontHeight 0.036;
_readout ctrlSetText "";
_readout ctrlCommit 0;

_display setVariable ["zmgrs_readoutCtrl", _readout];

private _labels = [];
for "_i" from 1 to 96 do {
    private _label = _display ctrlCreate ["RscText", -1];
    _label ctrlSetFont "EtelkaMonospacePro";
    _label ctrlSetFontHeight 0.021;
    _label ctrlSetTextColor [0, 0, 0, 1];
    _label ctrlSetBackgroundColor [1, 1, 1, 0.62];
    _label ctrlSetPosition [0, 0, 0.042, 0.022];
    _label ctrlCommit 0;
    _label ctrlShow false;
    _labels pushBack _label;
};
_display setVariable ["zmgrs_gridLabelCtrls", _labels];

_map ctrlAddEventHandler ["Draw", {
    _this call zmgrs_fnc_updateReadout
}];
