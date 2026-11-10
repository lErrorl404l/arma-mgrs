[
    "zmgrs_ace_enabled",
    "CHECKBOX",
    [localize "STR_MGRS_ACE_ENABLED_NAME", localize "STR_MGRS_ACE_ENABLED_DESC"],
    ["MGRS", "ACE Compatibility"],
    true,
    0,
    {["zmgrs_ace_enabled", _this] call zmgrs_ace_fnc_settingChanged},
    true
] call CBA_fnc_addSetting;

[
    "zmgrs_ace_interval",
    "SLIDER",
    [localize "STR_MGRS_ACE_INTERVAL_NAME", localize "STR_MGRS_ACE_INTERVAL_DESC"],
    ["MGRS", "ACE Compatibility"],
    [0.05, 1.0, 0.1, 2],
    0,
    {["zmgrs_ace_interval", _this] call zmgrs_ace_fnc_settingChanged},
    true
] call CBA_fnc_addSetting;

[
    "zmgrs_ace_dagrFull",
    "CHECKBOX",
    [localize "STR_MGRS_ACE_DAGR_FULL_NAME", localize "STR_MGRS_ACE_DAGR_FULL_DESC"],
    ["MGRS", "ACE Compatibility"],
    false
] call CBA_fnc_addSetting;

[
    "zmgrs_ace_dagrDigits",
    "LIST",
    [localize "STR_MGRS_ACE_DAGR_DIGITS_NAME", localize "STR_MGRS_ACE_DAGR_DIGITS_DESC"],
    ["MGRS", "ACE Compatibility"],
    [[3, 4, 5], ["100 m", "10 m", "1 m"], 1]
] call CBA_fnc_addSetting;

[
    "zmgrs_ace_microDigits",
    "LIST",
    [localize "STR_MGRS_ACE_MICRO_DIGITS_NAME", localize "STR_MGRS_ACE_MICRO_DIGITS_DESC"],
    ["MGRS", "ACE Compatibility"],
    [[4, 5], ["10 m", "1 m"], 1]
] call CBA_fnc_addSetting;
