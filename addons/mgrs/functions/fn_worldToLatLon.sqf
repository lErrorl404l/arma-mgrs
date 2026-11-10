/*
 * Maps an Arma world position onto the terrain georeference. The first three
 * control points define a local affine fit. Otherwise the declared box is
 * interpolated linearly. Arma world axes are metres, +X east and +Y north.
 */
params ["_pos", "_geo", ["_size", 0], ["_control", [], [[]]]];

_geo params ["_latMin", "_lonMin", "_latMax", "_lonMax"];

if (_size <= 0) then { _size = worldSize; };
if (_size <= 0) exitWith { [0, 0] };

private _x = _pos select 0;
private _y = _pos select 1;
private _lat = 0;
private _lon = 0;
private _usedControl = false;

if (count _control >= 3) then {
    private _p1 = _control select 0;
    private _p2 = _control select 1;
    private _p3 = _control select 2;
    private _x1 = _p1 select 0;
    private _y1 = _p1 select 1;
    private _lat1 = _p1 select 2;
    private _lon1 = _p1 select 3;
    private _x2 = _p2 select 0;
    private _y2 = _p2 select 1;
    private _lat2 = _p2 select 2;
    private _lon2 = _p2 select 3;
    private _x3 = _p3 select 0;
    private _y3 = _p3 select 1;
    private _lat3 = _p3 select 2;
    private _lon3 = _p3 select 3;

    private _det = _x1 * (_y2 - _y3) - _y1 * (_x2 - _x3) + (_x2 * _y3 - _y2 * _x3);
    if (abs _det > 1e-9) then {
        private _latA = (_lat1 * (_y2 - _y3) - _y1 * (_lat2 - _lat3) + (_lat2 * _y3 - _lat3 * _y2)) / _det;
        private _latB = (_x1 * (_lat2 - _lat3) - _lat1 * (_x2 - _x3) + (_x2 * _lat3 - _lat2 * _x3)) / _det;
        private _latC = (_x1 * (_y2 * _lat3 - _lat2 * _y3) - _y1 * (_x2 * _lat3 - _lat2 * _x3) + _lat1 * (_x2 * _y3 - _y2 * _x3)) / _det;
        private _lonA = (_lon1 * (_y2 - _y3) - _y1 * (_lon2 - _lon3) + (_lon2 * _y3 - _lon3 * _y2)) / _det;
        private _lonB = (_x1 * (_lon2 - _lon3) - _lon1 * (_x2 - _x3) + (_x2 * _lon3 - _lon2 * _x3)) / _det;
        private _lonC = (_x1 * (_y2 * _lon3 - _lon2 * _y3) - _y1 * (_x2 * _lon3 - _lon2 * _x3) + _lon1 * (_x2 * _y3 - _y2 * _x3)) / _det;
        _lat = _latA * _x + _latB * _y + _latC;
        _lon = _lonA * _x + _lonB * _y + _lonC;
        _usedControl = (_lat >= -80) && (_lat <= 84) && (_lon >= -180) && (_lon <= 180);
    };
};

if (!_usedControl) then {
    _lat = _latMin + (_y / _size) * (_latMax - _latMin);
    _lon = _lonMin + (_x / _size) * (_lonMax - _lonMin);
};

[_lat, _lon]
