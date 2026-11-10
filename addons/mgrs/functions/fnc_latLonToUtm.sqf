/*
 * WGS84 latitude/longitude to UTM (Snyder series, sub-metre for map use).
 * Returns [zone, easting, northing].
 */
params ["_lat", "_lon"];

private _zone = floor ((_lon + 180) / 6) + 1;
if (_zone < 1) then { _zone = 1; };
if (_zone > 60) then { _zone = 60; };

// Norway and Svalbard exceptions (not used by the official maps, kept for correctness).
if ((_lat >= 56) && (_lat < 64) && (_lon >= 3) && (_lon < 12)) then { _zone = 32; };
if ((_lat >= 72) && (_lat < 84)) then {
    if ((_lon >= 0) && (_lon < 9)) then { _zone = 31; };
    if ((_lon >= 9) && (_lon < 21)) then { _zone = 33; };
    if ((_lon >= 21) && (_lon < 33)) then { _zone = 35; };
    if ((_lon >= 33) && (_lon < 42)) then { _zone = 37; };
};

private _a = 6378137;
private _f = 1 / 298.257223563;
private _e2 = _f * (2 - _f);
private _e4 = _e2 * _e2;
private _e6 = _e4 * _e2;
private _ep2 = _e2 / (1 - _e2);
private _k0 = 0.9996;

private _lon0 = (_zone - 1) * 6 - 180 + 3;
private _dLon = (_lon - _lon0) * pi / 180;
private _latRad = _lat * pi / 180;

private _sinLat = sin _lat;
private _cosLat = cos _lat;
private _tanLat = tan _lat;

private _n = _a / sqrt (1 - _e2 * _sinLat * _sinLat);
private _t = _tanLat * _tanLat;
private _c = _ep2 * _cosLat * _cosLat;
private _aa = _cosLat * _dLon;

private _m = _a * (
    (1 - _e2 / 4 - 3 * _e4 / 64 - 5 * _e6 / 256) * _latRad
    - (3 * _e2 / 8 + 3 * _e4 / 32 + 45 * _e6 / 1024) * sin (2 * _lat)
    + (15 * _e4 / 256 + 45 * _e6 / 1024) * sin (4 * _lat)
    - (35 * _e6 / 3072) * sin (6 * _lat)
);

private _easting = _k0 * _n * (
    _aa
    + (1 - _t + _c) * (_aa ^ 3) / 6
    + (5 - 18 * _t + (_t ^ 2) + 72 * _c - 58 * _ep2) * (_aa ^ 5) / 120
) + 500000;

private _northing = _k0 * (
    _m
    + _n * _tanLat * (
        (_aa ^ 2) / 2
        + (5 - _t + 9 * _c + 4 * (_c ^ 2)) * (_aa ^ 4) / 24
        + (61 - 58 * _t + (_t ^ 2) + 600 * _c - 330 * _ep2) * (_aa ^ 6) / 720
    )
);

if (_lat < 0) then { _northing = _northing + 10000000; };

[_zone, _easting, _northing]
