/*
 * Latitude band letter, C-X (I and O omitted). "Z" marks a polar (UPS) case,
 * which this addon does not convert.
 */
params ["_lat"];

if ((_lat < -80) || (_lat > 84)) exitWith { "Z" };

private _letters = toArray "CDEFGHJKLMNPQRSTUVWX";
private _index = floor ((_lat + 80) / 8);

if (_index > 19) then { _index = 19; }; // band X spans 72-84 degrees

toString [_letters select _index]
