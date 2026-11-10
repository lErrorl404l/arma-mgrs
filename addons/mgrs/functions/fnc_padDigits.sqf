/*
 * Truncates to an integer and left-pads with zeros to a fixed width.
 */
params ["_value", "_width"];

private _chars = toArray (str (round _value));

while {count _chars < _width} do {
    _chars = [48] + _chars;
};

if (count _chars > _width) then {
    _chars = _chars select [(count _chars) - _width, _width];
};

toString _chars
