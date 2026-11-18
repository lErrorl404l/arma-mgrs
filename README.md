# A-MGRS

A-MGRS (Arma Military Grid Reference System) is a demonstration addon that replaces the Arma 3 map grid with a grid derived from MGRS, and gives every terrain a WGS 84 georeference.

This is a demo build. It shows how far the technique reaches on official and modded terrain, and it states where it stops. Treat the synthetic fallback as exercise data only.

The engine grid, the GPS and **mapGridPosition** use the patched grid. Northing counts northwards, as on a printed map sheet.

## What it does

- Patches the map grid on every terrain the converter can place in one UTM zone, so grid cells carry real MGRS easting and northing.
- Scales each grid tier to the terrain, so a 10 m, 100 m, 1 km or 10 km cell matches the real extent of that terrain.
- Resolves a real-world reference for the official terrains, and for terrain mods that declare one.
- Falls back to a declared synthetic reference when a map declares nothing, marked virtual.
- Replaces the DAGR and MicroDAGR grid fields through an optional ACE3 addon.
- Gives scripts MGRS, UTM and **mapGridPosition** conversions.

## How it works

A converter reads each terrain's own data: latitude and longitude, **mapArea**, **mapZone**, map size and the terrain's own map coordinates. It writes a georeference table and a grid patch into a generated addon. A new terrain needs a converter run, not a code change.

The generated config uses class inheritance. The base world class holds a **Grid** class, each terrain derives from it, and each override sets only the offsets and steps for that terrain.

The grid is a least-squares fit. The engine draws straight lines, so the converter fits one step and one origin per axis to the exact conversion across the terrain, which spreads the residual instead of pinning it to a corner.

Every candidate box is scored against the other metadata on the world. A box that contradicts the declared zone, the map size or the centre coordinates loses, and so does a copied box.

The converter also classifies the terrain with the Köppen climate system (Peel et al. 2007). A tropical or polar verdict lowers the confidence of a box that places the terrain in another climate. The climate check never picks a location. It rejects an implausible one.

## Accuracy

The conversion is exact. The script port was checked against the **mgrs** 1.7.0 reference library over 1,518 conversions at 506 positions, with zero mismatches.

The drawn grid is an approximation, because Arma draws straight lines and MGRS easting curves with northing. Measured over the 29 terrains that carry a grid, a grid read differs from the exact conversion by 130 m at the median and 619 m at worst, on Altis.

Against the real world, the box stays a linear fit to the declared extent, so expect hundreds of metres of error at a survey point. Three control points let the API correct scale, rotation and convergence, but the engine grid cannot rotate.

## Supported terrains

Altis is Lemnos, Stratis is Agios Efstratios, Malden is Lefkada, Tanoa is Ovalau, Livonia is Chřiby, and VR is a synthetic training space.

The converter scans any terrain mod in the same way, with no per-map code. Of the 49 worlds in the current scan, 30 carry a patched engine grid. The rest keep the script API only.

## Settings

The settings are under **MGRS > Core** and need CBA:

- **Default MGRS digits**: digits per axis when a script call omits the count.
- **Georeference debug log**: write the resolved box and source to the RPT.

The engine grid and the terrain reference are read at load time. A CBA setting cannot change them during a mission.

## ACE3

The ACE3 addon replaces the grid field on the DAGR and MicroDAGR with the MGRS string for the player's position.

The settings are under **MGRS > ACE Compatibility**:

- **Enable ACE device patch**: turn the device patch off.
- **Device update interval**: grid field refresh rate.
- **DAGR full MGRS**: show the zone, band and 100 km square, or digits only.
- **DAGR precision**: 100 m, 10 m or 1 m per axis.
- **MicroDAGR precision**: 10 m or 1 m per axis.

**DAGR full MGRS** is off by default, because the full string can exceed the DAGR field. The two settings that need a mission restart carry the CBA restart marker.

The engine grid stops at the 10 m tier. This keeps **mapGridPosition** and the GPS fields at eight digits, so they do not wrap. One-metre precision remains in the script functions and the devices.

## Multiplayer

Every client and the server should load the same build.

A marker stores a world position, and this addon does not move it. The grid text under the marker comes from each client's grid configuration, so a client without the addon sees the vanilla grid at the same position.

## For mission makers

All functions are global:

```
_position call mgrs_fnc_posToMGRS;        // "35S LD 2960 9840"
[_position, 5] call mgrs_fnc_posToMGRS;   // 1 m digits
_player call mgrs_fnc_posToMGRS;          // Object or Position
_position call mgrs_fnc_posToUTM;         // "35S 329603E 4398403N"
_player call mgrs_fnc_mapGridPosition;    // MGRS string, easting first
call mgrs_fnc_getGeorefInfo;              // [box, source, confidence, control, biome]
call mgrs_fnc_getGeoref;                  // [latMin, lonMin, latMax, lonMax, virtual]
["WL_Rosche", [52.9275, 10.5640, 53.0639, 10.7918]] call mgrs_fnc_setGeoref;
```

**mgrs_fnc_posToMGRS**, **mgrs_fnc_posToUTM** and **mgrs_fnc_mapGridPosition** accept an Object or a Position, and return an empty string when the terrain has no reference.

**mgrs_fnc_posToMGRS** and **mgrs_fnc_mapGridPosition** use four digits per axis when no count is passed. The **Default MGRS digits** setting changes that default.

**mgrs_fnc_setGeoref** pins a box at runtime for a map that fell back to a virtual reference. It overrides the generated table until the mission restarts. It does not change the engine grid, which is read at load time.

The function prefix stays **mgrs**. A-MGRS is the project name.

## Known limits

- The engine grid draws numerals only. It cannot draw the zone, band or 100 km square letters.
- The engine grid cannot follow grid convergence, so the drawn grid and the exact conversion diverge on a large terrain.
- The grid maps the terrain linearly onto its declared latitude and longitude box. It is not a geodetic transform.
- A map whose box crosses a UTM zone boundary gets no engine grid. The script API still returns the correct zone for each position.
- A terrain that loads as a mod can still shadow the patched grid.
- Polar (UPS) conversion is not implemented. The band returns **Z**.

The full list, with the reasons, is in the development notes.

## Contributing

This is a development project. Issues and pull requests that improve, polish or update it are welcome on the tracker linked below. Forking it for your own version is fine as well.

The aim is to push what Arma modding can do for realism and milsim, not to hold it back. Contributions are accepted under the same licence, so a fork stays open as well.

## Source and support

- [Source and issue tracker](https://github.com/lErrorl404l/arma-mgrs)
- [Development notes](https://github.com/lErrorl404l/arma-mgrs/blob/main/docs/DEVELOPMENT.md)
- [Accuracy report](https://github.com/lErrorl404l/arma-mgrs/blob/main/docs/accuracy-report.md)
- [Licence](https://github.com/lErrorl404l/arma-mgrs/blob/main/LICENSE): GNU General Public License v2.0 or later.
