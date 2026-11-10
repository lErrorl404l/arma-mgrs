/* SPDX-License-Identifier: GPL-2.0-or-later */

/*
 * Classifies the current world and returns a coarse band (A tropical,
 * B arid, C temperate, D cold, E polar), or "" when the world cannot be
 * scanned. The band is a plausibility hint for the box, never a coordinate
 * source.
 *
 * The climate verdict comes from the box latitude and the map water
 * fraction. Terrain evidence from the surface and vegetation scan refines
 * that verdict, but only when it wins by a clear margin. The result is a
 * Koppen code; only its first letter is returned.
 */
params [["_world", ""], ["_lat", 0, [0]]];

if (_world == "") then { _world = worldName; };
if (_world != worldName) exitWith { "" };

private _cache = missionNamespace getVariable ["mgrs_biomeCache", createHashMap];
private _cached = _cache getOrDefault [_world, ""];
if (_cached != "") exitWith { _cached };

private _signals = missionNamespace getVariable ["mgrs_biomeSignals", []];
if (count _signals == 0) then { _signals = [] call mgrs_fnc_biomeScan; };
_signals params [
    "_surfaceScores", "_vegScores", "_structScores",
    "_waterFrac", "_meanElev", "_elevMax"
];
if (isNil "_surfaceScores") then { _surfaceScores = createHashMap; };
if (isNil "_vegScores") then { _vegScores = createHashMap; };
if (isNil "_structScores") then { _structScores = createHashMap; };

private _normals = [_lat, _waterFrac] call mgrs_fnc_biomeClimate;
private _tDay = _normals select 2;
private _tNight = _normals select 3;
private _precip = _normals select 5;

private _meanTemps = [];
for "_m" from 0 to 11 do {
    _meanTemps pushBack (((_tDay select _m) + (_tNight select _m)) / 2);
};

private _climate = [_meanTemps, _precip, 0] call mgrs_fnc_biomeClassify;
if (_climate == "") then { _climate = "Cfb"; };

// Climate is the anchor (10); vegetation is the strongest terrain signal
// (8), then surface (4) and structures (3). Terrain can refine the climate
// but must beat it by the margin below to replace it.
private _scores = createHashMap;
_scores set [_climate, 10];
{
    private _code = _x;
    _scores set [_code, (_scores getOrDefault [_code, 0]) + ((_vegScores get _code) * 8)];
} forEach (keys _vegScores);
{
    private _code = _x;
    _scores set [_code, (_scores getOrDefault [_code, 0]) + ((_surfaceScores get _code) * 4)];
} forEach (keys _surfaceScores);
{
    private _code = _x;
    _scores set [_code, (_scores getOrDefault [_code, 0]) + ((_structScores get _code) * 3)];
} forEach (keys _structScores);

// High ground is colder than its latitude suggests.
if (_meanElev > 1500) then {
    _scores set ["Dfc", (_scores getOrDefault ["Dfc", 0]) + 15];
    _scores set ["ET", (_scores getOrDefault ["ET", 0]) + 8];
};

private _bestCode = "";
private _bestScore = 0;
private _secondScore = 0;
{
    private _value = _scores get _x;
    if (_value > _bestScore) then {
        _secondScore = _bestScore;
        _bestScore = _value;
        _bestCode = _x;
    } else {
        if (_value > _secondScore) then { _secondScore = _value; };
    };
} forEach (keys _scores);

if (_bestCode != _climate && _bestScore < (_secondScore * 1.4)) then {
    _bestCode = _climate;
};
if (_bestCode == "") then { _bestCode = _climate; };

private _band = toUpper (_bestCode select [0, 1]);
_cache set [_world, _band];
missionNamespace setVariable ["mgrs_biomeCache", _cache];
_band
