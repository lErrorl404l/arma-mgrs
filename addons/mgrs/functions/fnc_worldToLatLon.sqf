/*
 * Maps an Arma world position onto the terrain's declared lat/lon box.
 * Arma world axes are metres, +X east and +Y north, with the origin at the
 * south-west corner of the terrain.
 */
params ["_pos", "_geo", ["_size", 0]];

_geo params ["_latMin", "_lonMin", "_latMax", "_lonMax"];

if (_size <= 0) then { _size = worldSize; };
if (_size <= 0) exitWith { [0, 0] };

[
    _latMin + ((_pos select 1) / _size) * (_latMax - _latMin),
    _lonMin + ((_pos select 0) / _size) * (_lonMax - _lonMin)
]
