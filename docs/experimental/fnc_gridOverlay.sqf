/*
 * Draws an MGRS grid on the map. Cell boundaries are placed from the terrain
 * georeference, and each label is derived from the same conversion as the
 * readout. Northing therefore increases upwards and resets at a 100 km line.
 */
params ["_map", "_display"];

if (isNull _map || isNull _display) exitWith {};
if (!(missionNamespace getVariable ["zmgrs_drawGrid", true])) exitWith {};

private _geo = [worldName] call zmgrs_fnc_getGeoref;
if (count _geo < 4) exitWith {};
private _virtual = ((count _geo >= 5) && ((_geo select 4) == 1));

private _size = worldSize;
if (_size <= 0) then {
    _size = getNumber (configFile >> "CfgWorlds" >> worldName >> "mapSize");
};
if (_size <= 0) exitWith {};

private _proj = _display getVariable ["zmgrs_gridProj", []];
if (count _proj < 6) then {
    private _ll0 = [[0, 0], _geo, _size] call zmgrs_fnc_worldToLatLon;
    private _llX = [[_size, 0], _geo, _size] call zmgrs_fnc_worldToLatLon;
    private _llY = [[0, _size], _geo, _size] call zmgrs_fnc_worldToLatLon;
    private _utm0 = [_ll0 select 0, _ll0 select 1] call zmgrs_fnc_latLonToUtm;
    private _utmX = [_llX select 0, _llX select 1] call zmgrs_fnc_latLonToUtm;
    private _utmY = [_llY select 0, _llY select 1] call zmgrs_fnc_latLonToUtm;
    _proj = [
        _size,
        _utm0 select 1,
        _utm0 select 2,
        ((_utmX select 1) - (_utm0 select 1)) / _size,
        ((_utmY select 2) - (_utm0 select 2)) / _size,
        _utm0 select 0
    ];
    _display setVariable ["zmgrs_gridProj", _proj];
};
_proj params ["_pSize", "_e0", "_n0", "_sx", "_sy", "_zone"];
if (_sx <= 0 || _sy <= 0) exitWith {};

private _tl = _map ctrlMapScreenToWorld [0, 0];
private _br = _map ctrlMapScreenToWorld [1, 1];
private _xMin = (_tl select 0) min (_br select 0);
private _xMax = (_tl select 0) max (_br select 0);
private _yMin = (_tl select 1) min (_br select 1);
private _yMax = (_tl select 1) max (_br select 1);

private _width = (_xMax - _xMin) max (_yMax - _yMin);
private _step = 10;
private _digits = 4;
if (_width > 600) then { _step = 100; _digits = 3; };
if (_width > 6000) then { _step = 1000; _digits = 2; };
if (_width > 20000) then { _step = 10000; _digits = 1; };

private _eStart = ceil ((_e0 + _xMin * _sx) / _step) * _step;
private _eEnd = _e0 + _xMax * _sx;
private _nStart = ceil ((_n0 + _yMin * _sy) / _step) * _step;
private _nEnd = _n0 + _yMax * _sy;

private _lineColor = if (_virtual) then { [0.55, 0.05, 0.05, 0.22] } else { [0, 0, 0, 0.28] };
private _boundaryColor = [0.55, 0.05, 0.05, 0.65];
private _square = 100000;

private _e = _eStart;
while {_e <= _eEnd} do {
    private _x = (_e - _e0) / _sx;
    private _isBoundary = ((round _e) mod _square) == 0;
    _map drawLine [
        [_x, _yMin],
        [_x, _yMax],
        [_lineColor, _boundaryColor] select _isBoundary
    ];
    _e = _e + _step;
};

private _n = _nStart;
while {_n <= _nEnd} do {
    private _y = (_n - _n0) / _sy;
    private _isBoundary = ((round _n) mod _square) == 0;
    _map drawLine [
        [_xMin, _y],
        [_xMax, _y],
        [_lineColor, _boundaryColor] select _isBoundary
    ];
    _n = _n + _step;
};

private _latMin = _geo select 0;
private _latMax = _geo select 2;
private _lonMin = _geo select 1;
private _lonMax = _geo select 3;
private _edgeColor = [0.9, 0.45, 0, 0.55];

for "_b" from -80 to 80 step 8 do {
    if ((_b > _latMin) && (_b < _latMax)) then {
        private _by = ((_b - _latMin) / (_latMax - _latMin)) * _size;
        _map drawLine [[_xMin, _by], [_xMax, _by], _edgeColor];
    };
};
if ((84 > _latMin) && (84 < _latMax)) then {
    private _by = ((84 - _latMin) / (_latMax - _latMin)) * _size;
    _map drawLine [[_xMin, _by], [_xMax, _by], _edgeColor];
};

for "_k" from 0 to 60 do {
    private _lon = -180 + 6 * _k;
    if ((_lon > _lonMin) && (_lon < _lonMax)) then {
        private _bx = ((_lon - _lonMin) / (_lonMax - _lonMin)) * _size;
        _map drawLine [[_bx, _yMin], [_bx, _yMax], _edgeColor];
    };
};

if (!(missionNamespace getVariable ["zmgrs_gridLabels", true])) exitWith {};

private _lastStep = _display getVariable ["zmgrs_gridStep", -1];
private _force = _step != _lastStep;
_display setVariable ["zmgrs_gridStep", _step];

private _next = _display getVariable ["zmgrs_gridLabelNext", 0];
if (!_force && (diag_tickTime < _next)) exitWith {};
_display setVariable ["zmgrs_gridLabelNext", diag_tickTime + 0.05];

private _pool = _display getVariable ["zmgrs_gridLabelCtrls", []];
if (count _pool == 0) exitWith {};

private _used = 0;

private _sheet = ctrlPosition _map;
private _sheetBottom = (((_sheet select 1) + (_sheet select 3)) min 1) max 0;
private _sheetRight = (((_sheet select 0) + (_sheet select 2)) min 1) max 0;
private _labelBottom = (_sheetBottom - 0.025) max 0.02;
private _labelRight = (_sheetRight - 0.044) max 0.02;

private _count = 0;
private _total = (floor ((_eEnd - _eStart) / _step)) + 1;
private _every = 1 max (ceil (_total / 12));
_e = _eStart;
while {_e <= _eEnd} do {
    if ((_count mod _every) == 0) then {
        private _x = (_e - _e0) / _sx;
        private _scr = _map ctrlMapWorldToScreen [_x, _yMin];
        private _px = _scr select 0;
        private _py = _labelBottom;
        if ((_px > 0) && (_px < 1) && (_used < (count _pool))) then {
            private _eMod = (((round _e) mod _square) + _square) mod _square;
            private _value = floor (_eMod / (10 ^ (5 - _digits)));
            private _ctrl = _pool select _used;
            _ctrl ctrlSetText ([_value, _digits] call zmgrs_fnc_padDigits);
            _ctrl ctrlSetBackgroundColor [1, 1, 1, 0.62];
            _ctrl ctrlSetTextColor [0, 0, 0, 1];
            _ctrl ctrlSetPosition [_px - 0.021, _py, 0.042, 0.022];
            _ctrl ctrlCommit 0;
            _ctrl ctrlShow true;
            _used = _used + 1;
        };
    };
    if ((((round _e) mod _square) == 0) && (_used < (count _pool))) then {
        private _x = (_e - _e0) / _sx;
        private _scr = _map ctrlMapWorldToScreen [_x, _yMin];
        private _px = _scr select 0;
        if ((_px > 0) && (_px < 1)) then {
            private _mgrs = [[_x + 1, _yMin + 1], 4] call zmgrs_fnc_posToMgrs;
            private _parts = _mgrs splitString " ";
            if (count _parts >= 2) then {
                private _ctrl = _pool select _used;
                _ctrl ctrlSetText (_parts select 1);
                _ctrl ctrlSetBackgroundColor [0.55, 0.05, 0.05, 0.8];
                _ctrl ctrlSetTextColor [1, 1, 1, 1];
                _ctrl ctrlSetPosition [_px - 0.047, _labelBottom - 0.029, 0.094, 0.022];
                _ctrl ctrlCommit 0;
                _ctrl ctrlShow true;
                _used = _used + 1;
            };
        };
    };
    _count = _count + 1;
    _e = _e + _step;
};

_count = 0;
_total = (floor ((_eEnd - _eStart) / _step)) + 1;
_every = 1 max (ceil (_total / 12));
_e = _eStart;
while {_e <= _eEnd} do {
    if ((_count mod _every) == 0) then {
        private _x = (_e - _e0) / _sx;
        private _scr = _map ctrlMapWorldToScreen [_x, _yMin];
        private _px = _scr select 0;
        private _py = 0.002;
        if ((_px > 0.65) && (_px < 1) && (_used < (count _pool))) then {
            private _eMod = (((round _e) mod _square) + _square) mod _square;
            private _value = floor (_eMod / (10 ^ (5 - _digits)));
            private _ctrl = _pool select _used;
            _ctrl ctrlSetText ([_value, _digits] call zmgrs_fnc_padDigits);
            _ctrl ctrlSetBackgroundColor [1, 1, 1, 0.62];
            _ctrl ctrlSetTextColor [0, 0, 0, 1];
            _ctrl ctrlSetPosition [_px - 0.021, _py, 0.042, 0.022];
            _ctrl ctrlCommit 0;
            _ctrl ctrlShow true;
            _used = _used + 1;
        };
    };
    _count = _count + 1;
    _e = _e + _step;
};

_count = 0;
_total = (floor ((_nEnd - _nStart) / _step)) + 1;
_every = 1 max (ceil (_total / 12));
_n = _nStart;
while {_n <= _nEnd} do {
    if ((_count mod _every) == 0) then {
        private _y = (_n - _n0) / _sy;
        private _scr = _map ctrlMapWorldToScreen [_xMin, _y];
        private _px = _labelRight;
        private _py = (_scr select 1) - 0.011;
        if ((_py > 0.08) && (_py < 0.93) && (_used < (count _pool))) then {
            private _nMod = (((round _n) mod _square) + _square) mod _square;
            private _value = floor (_nMod / (10 ^ (5 - _digits)));
            private _ctrl = _pool select _used;
            _ctrl ctrlSetText ([_value, _digits] call zmgrs_fnc_padDigits);
            _ctrl ctrlSetBackgroundColor [1, 1, 1, 0.62];
            _ctrl ctrlSetTextColor [0, 0, 0, 1];
            _ctrl ctrlSetPosition [_px, _py, 0.042, 0.022];
            _ctrl ctrlCommit 0;
            _ctrl ctrlShow true;
            _used = _used + 1;
        };
    };
    if ((((round _n) mod _square) == 0) && (_used < (count _pool))) then {
        private _y = (_n - _n0) / _sy;
        private _scr = _map ctrlMapWorldToScreen [_xMin, _y];
        private _py = (_scr select 1) - 0.011;
        if ((_py > 0.08) && (_py < 0.93)) then {
            private _mgrs = [[_xMin + 1, _y + 1], 4] call zmgrs_fnc_posToMgrs;
            private _parts = _mgrs splitString " ";
            if (count _parts >= 2) then {
                private _ctrl = _pool select _used;
                _ctrl ctrlSetText (format ["%1 %2", _parts select 0, _parts select 1]);
                _ctrl ctrlSetBackgroundColor [0.55, 0.05, 0.05, 0.8];
                _ctrl ctrlSetTextColor [1, 1, 1, 1];
                _ctrl ctrlSetPosition [_labelRight - 0.098, _py - 0.029, 0.094, 0.022];
                _ctrl ctrlCommit 0;
                _ctrl ctrlShow true;
                _used = _used + 1;
            };
        };
    };
    _count = _count + 1;
    _n = _n + _step;
};

_count = 0;
_total = (floor ((_nEnd - _nStart) / _step)) + 1;
_every = 1 max (ceil (_total / 12));
_n = _nStart;
while {_n <= _nEnd} do {
    if ((_count mod _every) == 0) then {
        private _y = (_n - _n0) / _sy;
        private _scr = _map ctrlMapWorldToScreen [_xMin, _y];
        private _px = 0.002;
        private _py = (_scr select 1) - 0.011;
        if ((_py > 0.08) && (_py < 0.9) && (_used < (count _pool))) then {
            private _nMod = (((round _n) mod _square) + _square) mod _square;
            private _value = floor (_nMod / (10 ^ (5 - _digits)));
            private _ctrl = _pool select _used;
            _ctrl ctrlSetText ([_value, _digits] call zmgrs_fnc_padDigits);
            _ctrl ctrlSetBackgroundColor [1, 1, 1, 0.62];
            _ctrl ctrlSetTextColor [0, 0, 0, 1];
            _ctrl ctrlSetPosition [_px, _py, 0.042, 0.022];
            _ctrl ctrlCommit 0;
            _ctrl ctrlShow true;
            _used = _used + 1;
        };
    };
    _count = _count + 1;
    _n = _n + _step;
};

for "_b" from -80 to 80 step 8 do {
    if ((_b > _latMin) && (_b < _latMax) && (_used < (count _pool))) then {
        private _by = ((_b - _latMin) / (_latMax - _latMin)) * _size;
        private _scr = _map ctrlMapWorldToScreen [_xMin, _by];
        private _py = (_scr select 1) - 0.011;
        if ((_py > 0.08) && (_py < 0.93)) then {
            private _band = [_b + 0.01] call zmgrs_fnc_latToBand;
            private _ctrl = _pool select _used;
            _ctrl ctrlSetText (format ["%1° %2%3", _b, _zone, _band]);
            _ctrl ctrlSetBackgroundColor [0.9, 0.45, 0, 0.8];
            _ctrl ctrlSetTextColor [1, 1, 1, 1];
            _ctrl ctrlSetPosition [0.72, _py, 0.14, 0.022];
            _ctrl ctrlCommit 0;
            _ctrl ctrlShow true;
            _used = _used + 1;
        };
    };
};

for "_i" from _used to ((count _pool) - 1) do {
    (_pool select _i) ctrlShow false;
};

if (_virtual && (_used < (count _pool))) then {
    private _ctrl = _pool select _used;
    _ctrl ctrlSetText "VIRTUAL";
    _ctrl ctrlSetBackgroundColor [0.55, 0.05, 0.05, 0.8];
    _ctrl ctrlSetTextColor [1, 1, 1, 1];
    _ctrl ctrlSetPosition [0.72, 0.02, 0.12, 0.025];
    _ctrl ctrlCommit 0;
    _ctrl ctrlShow true;
};
