private _base = "\z\mgrs\addons\mgrs\functions\";

{
    missionNamespace setVariable [
        "zmgrs_fnc_" + _x,
        compileFinal preprocessFileLineNumbers (_base + "fnc_" + _x + ".sqf")
    ];
} forEach [
    "getGeoref",
    "syntheticGeoref",
    "worldToLatLon",
    "latLonToUtm",
    "latToBand",
    "padDigits",
    "utmToMgrs",
    "posToMgrs",
    "posToUtm",
    "setGeoref",
    "mapGridPosition"
];

zmgrs_georefCache = createHashMap;
