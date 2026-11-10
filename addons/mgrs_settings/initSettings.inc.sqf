[
    "mgrs_defaultDigits",
    "LIST",
    [localize "STR_MGRS_CORE_DEFAULT_DIGITS_NAME", localize "STR_MGRS_CORE_DEFAULT_DIGITS_DESC"],
    ["MGRS", "Core"],
    [[3, 4, 5], ["100 m", "10 m", "1 m"], 1]
] call CBA_fnc_addSetting;

[
    "mgrs_debug",
    "CHECKBOX",
    [localize "STR_MGRS_CORE_DEBUG_NAME", localize "STR_MGRS_CORE_DEBUG_DESC"],
    ["MGRS", "Core"],
    false
] call CBA_fnc_addSetting;
