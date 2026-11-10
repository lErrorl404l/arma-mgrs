/*
 * UTM to MGRS (AA lettering scheme, WGS84): grid zone + 100 km square + digits.
 * Digits are truncated, never rounded, per the MGRS standard.
 *
 * _digits is the count per axis: 3 = 100 m, 4 = 10 m, 5 = 1 m.
 */
params ["_zone", "_easting", "_northing", "_lat", ["_digits", 4, [0]]];

private _band = [_lat] call zmgrs_fnc_latToBand;

private _colSets = ["ABCDEFGH", "JKLMNPQR", "STUVWXYZ"];
private _colSet = toArray (_colSets select ((_zone - 1) mod 3));

private _colIndex = (floor (_easting / 100000)) - 1;
if (_colIndex < 0) then { _colIndex = 0; };
if (_colIndex > 7) then { _colIndex = 7; };
private _col = toString [_colSet select _colIndex];

private _rowLetters = toArray "ABCDEFGHJKLMNPQRSTUV";
private _rowIndex = (floor (_northing / 100000)) mod 20;
if ((_zone mod 2) == 0) then { _rowIndex = (_rowIndex + 5) mod 20; };
private _row = toString [_rowLetters select _rowIndex];

private _scale = 10 ^ (5 - _digits);
private _east = floor ((floor _easting mod 100000) / _scale);
private _north = floor ((floor _northing mod 100000) / _scale);

format [
    "%1%2 %3%4 %5 %6",
    _zone,
    _band,
    _col,
    _row,
    [_east, _digits] call zmgrs_fnc_padDigits,
    [_north, _digits] call zmgrs_fnc_padDigits
]
