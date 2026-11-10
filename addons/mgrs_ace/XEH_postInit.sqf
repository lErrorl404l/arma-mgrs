if (!hasInterface) exitWith {};
if (!(missionNamespace getVariable ["mgrs_ace_enabled", true])) exitWith {};

private _base = "\z\mgrs\addons\mgrs_ace\functions\";
mgrs_ace_fnc_update = compileFinal preprocessFileLineNumbers (_base + "fn_update.sqf");

mgrs_ace_fnc_watch = {
    private _interval = missionNamespace getVariable ["mgrs_ace_interval", 0.1];
    private _dagr = uiNamespace getVariable ["DAGR_Display", displayNull];
    if (isNull _dagr) then {
        _dagr = uiNamespace getVariable ["DAGR_DISPLAY", displayNull];
    };
    if (!isNull _dagr && {!(_dagr getVariable ["mgrs_ace_dagr", false])}) then {
        _dagr setVariable ["mgrs_ace_dagr", true];
        missionNamespace setVariable [
            "mgrs_ace_dagrHandle",
            [{ ["dagr"] call mgrs_ace_fnc_update; }, _interval, []] call CBA_fnc_addPerFrameHandler
        ];
    };

    private _micro = uiNamespace getVariable ["ace_microdagr_RscTitleDisplay", displayNull];
    if (isNull _micro) then {
        _micro = uiNamespace getVariable ["ace_microdagr_DialogDisplay", displayNull];
    };
    if (!isNull _micro && {!(_micro getVariable ["mgrs_ace_micro", false])}) then {
        _micro setVariable ["mgrs_ace_micro", true];
        missionNamespace setVariable [
            "mgrs_ace_microHandle",
            [{ ["micro"] call mgrs_ace_fnc_update; }, _interval, []] call CBA_fnc_addPerFrameHandler
        ];
    };
};

[{ call mgrs_ace_fnc_watch; }, 0.5, []] call CBA_fnc_addPerFrameHandler;
