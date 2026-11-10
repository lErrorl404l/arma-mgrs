zmgrs_ace_fnc_settingChanged = {
    params ["_setting"];

    if (!(missionNamespace getVariable ["zmgrs_aceSettingsInitialized", false])) exitWith {};

    private _name = switch (_setting) do {
        case "zmgrs_ace_enabled": { localize "STR_MGRS_ACE_ENABLED_NAME" };
        case "zmgrs_ace_interval": { localize "STR_MGRS_ACE_INTERVAL_NAME" };
        default { _setting };
    };

    systemChat format ["[MGRS] %1 changed. Restart the mission to apply.", _name];
};

missionNamespace setVariable ["zmgrs_aceSettingsInitialized", false];
["CBA_settingsInitialized", {missionNamespace setVariable ["zmgrs_aceSettingsInitialized", true];}] call CBA_fnc_addEventHandler;

#include "initSettings.inc.sqf"
