/*
 * Returns [latMin, lonMin, latMax, lonMax, virtual] for a world, or [] when no
 * box can be resolved.
 *
 * Resolution order:
 *   1. CfgWorlds >> world >> mgrsGeo[]  (author or generated table)
 *   2. Known corrections for official maps
 *   3. CfgWorlds >> world >> mapArea[]  (order detected, mapZone checked,
 *      rejected when it contradicts the lat/lon fields)
 *   4. CfgWorlds >> world >> latitude/longitude (north stored negative, only
 *      when mapZone agrees with the longitude)
 *   5. Deterministic synthetic anchor (virtual = 1)
 */
params [["_world", ""]];

if (_world == "") then { _world = worldName; };

private _debug = missionNamespace getVariable ["zmgrs_debug", false];
private _finish = {
    params ["_geo", "_source", "_world", "_debug"];
    if (_debug) then {
        diag_log format ["[MGRS] georef %1 source=%2 box=%3", _world, _source, _geo];
    };
    _geo
};

private _cache = missionNamespace getVariable ["zmgrs_georefCache", createHashMap];
private _cached = _cache getOrDefault [_world, []];
if (count _cached >= 4) exitWith { [_cached, "cache", _world, _debug] call _finish };

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
    _cache set [_world, _geo];
    [_geo, "mgrsGeo", _world, _debug] call _finish
};

private _known = createHashMapFromArray [
    ["altis", [39.7185, 25.0120, 40.0946, 25.4815]],
    ["stratis", [39.4500, 24.9500, 39.5600, 25.0600]],
    ["malden", [39.7185, 25.0120, 40.0946, 25.4815]],
    ["tanoa", [-20.2680, 174.0030, -20.1353, 174.1460]],
    ["enoch", [53.8000, 22.7000, 54.2000, 23.2000]],
    ["vr", [0.0000, 0.0000, 0.0900, 0.0900]]
];
private _hit = _known getOrDefault [toLower _world, []];
if (count _hit == 4) exitWith {
    private _geo = _hit + [0];
    _cache set [_world, _geo];
    [_geo, "known", _world, _debug] call _finish
};

private _lat = -(getNumber (_cfg >> "latitude"));
private _lon = getNumber (_cfg >> "longitude");
private _hasLatLon = ((_lat != 0) || (_lon != 0)) && (_lat >= -80) && (_lat <= 84) && (_lon >= -180) && (_lon <= 180);

private _area = getArray (_cfg >> "mapArea");
if (count _area == 4) then {
    // BI documents {lonSW, latSW, lonNE, latNE}, but some worlds store latitude first.
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
        // Reject copied metadata: Rosche carries Altis's box, North Takistan
        // carries Tanoa's. When the box and the lat/lon point disagree by
        // more than 0.5 degrees, neither is trusted.
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
            _cache set [_world, _geo];
            [_geo, "mapArea", _world, _debug] call _finish
        };
    };
};

private _derived = [];
if (_hasLatLon) then {
    private _zone = getNumber (_cfg >> "mapZone");
    if ((_zone >= 1) && (_zone <= 60) && ((floor ((_lon + 180) / 6) + 1) == _zone)) then {
        private _halfLat = (_size / 2) / 111320;
        private _halfLon = (_size / 2) / (111320 * ((cos _lat) max 0.05));
        private _candidate = [_lat - _halfLat, _lon - _halfLon, _lat + _halfLat, _lon + _halfLon, 0];
        if (_candidate call _isValid) then { _derived = _candidate; };
    };
};

if (count _derived == 4) exitWith {
    _cache set [_world, _derived];
    [_derived, "derived", _world, _debug] call _finish
};

private _geo = [_world, _size] call zmgrs_fnc_syntheticGeoref;
_cache set [_world, _geo];
[_geo, "synthetic", _world, _debug] call _finish
