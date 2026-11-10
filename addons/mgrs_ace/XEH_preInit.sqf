mgrs_ace_fnc_settingChanged = {
    params ["_setting"];

    if (!(missionNamespace getVariable ["mgrs_aceSettingsInitialized", false])) exitWith {};

    private _name = switch (_setting) do {
        case "mgrs_ace_enabled": { localize "STR_MGRS_ACE_ENABLED_NAME" };
        case "mgrs_ace_interval": { localize "STR_MGRS_ACE_INTERVAL_NAME" };
        default { _setting };
    };

    systemChat format ["[MGRS] %1 changed. Restart the mission to apply.", _name];
};

missionNamespace setVariable ["mgrs_aceSettingsInitialized", false];
["CBA_settingsInitialized", {missionNamespace setVariable ["mgrs_aceSettingsInitialized", true];}] call CBA_fnc_addEventHandler;

#include "initSettings.inc.sqf"
