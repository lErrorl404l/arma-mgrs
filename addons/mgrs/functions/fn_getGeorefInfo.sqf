/*
 * Returns [box, source, confidence, controlPoints, biome].
 * The box remains the engine-grid compatible reference. Control points are
 * optional and are used by the script API for a local affine fit.
 */
params [["_world", ""]];

if (_world == "") then { _world = worldName; };

private _debug = missionNamespace getVariable ["mgrs_debug", false];
private _finish = {
    params ["_geo", "_source", "_confidence", "_control", "_biome", "_world", "_debug"];

    if (_biome == "") then {
        private _centreLat = ((_geo select 0) + (_geo select 2)) / 2;
        _biome = [_world, _centreLat] call mgrs_fnc_biomeBand;
    };

    if (_biome != "") then {
        private _lat = ((_geo select 0) + (_geo select 2)) / 2;
        private _band = toUpper (_biome select [0, 1]);
        private _ok = true;
        switch (_band) do {
            case "A": { _ok = abs _lat <= 30; };
            case "E": { _ok = abs _lat >= 60; };
            default {};
        };
        if (!_ok) then { _confidence = _confidence * 0.5; };
    };

    if (_debug) then {
        diag_log format [
            "[MGRS] georef %1 source=%2 confidence=%3 box=%4 controls=%5 biome=%6",
            _world, _source, _confidence, _geo, count _control, _biome
        ];
    };

    [_geo, _source, _confidence, _control, _biome]
};

private _cache = missionNamespace getVariable ["mgrs_georefCache", createHashMap];
missionNamespace setVariable ["mgrs_georefCache", _cache];
private _cached = _cache getOrDefault [_world, []];
if (count _cached >= 4) exitWith {
    private _geo = _cached;
    if (count _geo > 5) then { _geo = _geo select [0, 5]; };
    private _source = if (count _cached > 5) then { _cached select 5 } else { "cache" };
    private _confidence = if (count _cached > 6) then { _cached select 6 } else { 0.5 };
    private _control = if (count _cached > 7) then { _cached select 7 } else { [] };
    private _biome = if (count _cached > 8) then { _cached select 8 } else { "" };
    [_geo, _source, _confidence, _control, _biome, _world, _debug] call _finish
};

private _cfg = configFile >> "CfgWorlds" >> _world;
private _size = getNumber (_cfg >> "mapSize");
if (_size <= 0) then { _size = worldSize; };

private _isValid = {
    params ["_box"];
    ((_box select 0) >= -80)
    && ((_box select 0) < (_box select 2))
    && ((_box select 2) <= 84)
    && ((_box select 1) >= -180)
    && ((_box select 1) < (_box select 3))
    && ((_box select 3) <= 180)
};

private _mgrs = getArray (_cfg >> "mgrsGeo");
if (count _mgrs >= 4) exitWith {
    private _geo = [_mgrs select 0, _mgrs select 1, _mgrs select 2, _mgrs select 3, 0];
    if (count _mgrs >= 5) then { _geo set [4, _mgrs select 4]; };
    private _source = getText (_cfg >> "mgrsSource");
    if (_source == "") then { _source = "mgrsGeo"; };
    private _control = getArray (_cfg >> "mgrsControl");
    private _confidence = getNumber (_cfg >> "mgrsConfidence");
    if (_confidence <= 0) then {
        _confidence = [0.9, 0.95] select (count _control >= 3);
    };
    private _biome = getText (_cfg >> "mgrsBiome");
    _cache set [_world, _geo + [_source, _confidence, _control, _biome]];
    [_geo, _source, _confidence, _control, _biome, _world, _debug] call _finish
};

private _known = missionNamespace getVariable ["mgrs_knownGeoref", createHashMap];
if (count _known == 0) then {
    _known = createHashMapFromArray [
        ["altis", [39.7185, 25.0120, 40.0946, 25.4815]],
        ["stratis", [39.4682, 24.9573, 39.5418, 25.0527]],
        ["malden", [38.7420, 20.6270, 38.8580, 20.7730]],
        ["tanoa", [-17.7673, 178.7100, -17.6287, 178.8560]],
        ["enoch", [49.1090, 17.2451, 49.2240, 17.4209]],
        ["vr", [0.0000, 0.0000, 0.0900, 0.0900]]
    ];
    missionNamespace setVariable ["mgrs_knownGeoref", _known];
};
private _hit = _known getOrDefault [toLower _world, []];
if (count _hit == 4) exitWith {
    private _geo = _hit + [0];
    _cache set [_world, _geo + ["known", 0.85, [], ""]];
    [_geo, "known", 0.85, [], "", _world, _debug] call _finish
};

private _lat = -(getNumber (_cfg >> "latitude"));
private _lon = getNumber (_cfg >> "longitude");
private _hasLatLon = ((_lat != 0) || (_lon != 0)) && (_lat >= -80) && (_lat <= 84) && (_lon >= -180) && (_lon <= 180);

private _area = getArray (_cfg >> "mapArea");
if (count _area == 4) then {
    private _lonFirst = [_area select 1, _area select 0, _area select 3, _area select 2];
    private _latFirst = _area;
    private _validLon = _lonFirst call _isValid;
    private _validLat = _latFirst call _isValid;
    private _box = [];

    if (_validLon && _validLat) then {
        _box = _lonFirst;
        private _zone = getNumber (_cfg >> "mapZone");
        if ((_zone >= 1) && (_zone <= 60)) then {
            private _centreLon = ((_lonFirst select 1) + (_lonFirst select 3)) / 2;
            if ((floor ((_centreLon + 180) / 6) + 1) != _zone) then {
                _centreLon = ((_latFirst select 1) + (_latFirst select 3)) / 2;
                if ((floor ((_centreLon + 180) / 6) + 1) == _zone) then {
                    _box = _latFirst;
                };
            };
        };
    } else {
        if (_validLon) then { _box = _lonFirst; };
        if (_validLat) then { _box = _latFirst; };
    };

    if (count _box == 4) then {
        private _centreLatS = ((_box select 0) + (_box select 2)) / 2;
        private _spanW = ((_box select 3) - (_box select 1)) * 111320 * ((cos _centreLatS) max 0.05);
        private _spanH = ((_box select 2) - (_box select 0)) * 111320;
        private _scaleOk = (_size <= 0)
            || ((_spanW / _size <= 2) && (_spanW / _size >= 0.5)
                && (_spanH / _size <= 2) && (_spanH / _size >= 0.5));
        if (!_scaleOk) then { _box = []; };
    };

    if (count _box == 4) then {
        private _conflict = false;
        if (_hasLatLon) then {
            private _centreLat = ((_box select 0) + (_box select 2)) / 2;
            private _centreLon = ((_box select 1) + (_box select 3)) / 2;
            if ((abs (_centreLat - _lat) > 0.5) || (abs (_centreLon - _lon) > 0.5)) then {
                _conflict = true;
            };
        };
        if (!_conflict) exitWith {
            private _geo = _box + [0];
            _cache set [_world, _geo + ["mapArea", 0.65, [], ""]];
            [_geo, "mapArea", 0.65, [], "", _world, _debug] call _finish
        };
    };
};

private _derived = [];
private _derivedConf = 0.45;
if (_hasLatLon) then {
    private _zone = getNumber (_cfg >> "mapZone");
    if ((_zone < 1) || (_zone > 60)) then { _derivedConf = 0.3; };
    if ((_zone < 1) || (_zone > 60) || ((floor ((_lon + 180) / 6) + 1) == _zone)) then {
        private _halfLat = (_size / 2) / 111320;
        private _halfLon = (_size / 2) / (111320 * ((cos _lat) max 0.05));
        private _candidate = [_lat - _halfLat, _lon - _halfLon, _lat + _halfLat, _lon + _halfLon, 0];
        if (_candidate call _isValid) then { _derived = _candidate; };
    };
};

if (count _derived == 4) exitWith {
    _cache set [_world, _derived + ["derived", _derivedConf, [], ""]];
    [_derived, "derived", _derivedConf, [], "", _world, _debug] call _finish
};

private _geo = [_world, _size] call mgrs_fnc_syntheticGeoref;
_cache set [_world, _geo + ["synthetic", 0.1, [], ""]];
[_geo, "synthetic", 0.1, [], "", _world, _debug] call _finish
