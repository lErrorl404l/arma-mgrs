# Grid accuracy report

Measured by `python3 tools/measure_accuracy.py` against
`docs/georef-report.json`. Regenerate it after every converter run.

## Method

The converter gives the engine a linear easting and northing: a least-squares
fit of the exact conversion over a lattice of points inside the terrain box.
The script API converts each position through the full WGS 84 transverse
Mercator formula, with the zone of that position.

For each terrain with a patched grid the tool samples a 9 by 9 lattice of
world positions. At each point it compares two easting and northing pairs:

1. the value the engine grid draws, wrapped to the 100 km square;
2. the value `mgrs_fnc_posToUTM` returns for the same point.

The difference is the residual of the linear grid. It is not an error against
the real world, which needs ground control points.

## Results

| Terrain | Map size | Cross-zone | Worst | Mean |
|---|---|---|---|---|
| Altis | 30720 m | no | 618.7 m | 344.7 m |
| Enoch | 12800 m | no | 285.6 m | 168.9 m |
| WL_Rosche | 15360 m | no | 262.7 m | 152.6 m |
| dagger_island_summer | 20480 m | no | 262.3 m | 148.5 m |
| kerama | 20480 m | no | 228.7 m | 134.0 m |
| VEE_ArcticExpanse | 20480 m | no | 225.6 m | 130.3 m |
| VEE_DesertExpanse | 20480 m | no | 225.6 m | 130.3 m |
| VEE_GreenExpanse | 20480 m | no | 225.6 m | 130.3 m |
| VEE_SpaceExpanse | 20480 m | no | 225.6 m | 130.3 m |
| VEE_TasmanSea | 20480 m | no | 225.6 m | 130.3 m |
| VEE_UrbanExpanse | 20480 m | no | 225.6 m | 130.3 m |
| VEE_VaccumExpanse | 20480 m | no | 225.6 m | 130.3 m |
| Sara | 20480 m | no | 177.8 m | 100.2 m |
| Sara_dbe1 | 20480 m | no | 177.8 m | 100.2 m |
| Stratis | 8192 m | no | 130.2 m | 77.7 m |
| Tanoa | 15360 m | no | 106.0 m | 62.5 m |
| tem_kujari | 16384 m | no | 86.1 m | 50.8 m |
| SaraLite | 10240 m | no | 85.8 m | 50.1 m |
| tem_anizay | 10240 m | no | 67.2 m | 39.3 m |
| bala_murghab_summer | 20480 m | no | 59.1 m | 29.5 m |
| bala_murghab_winter | 20480 m | no | 59.1 m | 29.5 m |
| ProvingGrounds_PMC | 2048 m | no | 45.0 m | 27.2 m |
| Desert_E | 2048 m | no | 40.7 m | 24.6 m |
| Malden | 12800 m | no | 34.3 m | 18.0 m |
| kunduz_valley | 20480 m | no | 32.6 m | 13.3 m |
| Shapur_BAF | 2048 m | no | 13.8 m | 8.3 m |
| lythium | 20480 m | no | 11.4 m | 4.3 m |
| NorthTakistan | 20480 m | no | 9.8 m | 3.7 m |
| VR | 8192 m | no | 0.5 m | 0.2 m |

terrains measured: 29
single zone: 29 terrains, worst Altis at 618.7 m, median 130.2 m
single zone within one 10 m cell: 2 of 29
largest map: 30720 m

## Interpretation

The only residual left is grid convergence. Meridians converge, so true
easting changes with northing, and a linear grid cannot follow that. The
residual grows with map size and with distance from the central meridian,
which is why Altis, at 30.7 km and 1.8 degrees from the zone 35 central
meridian, is the worst terrain.

A box that crosses a UTM zone boundary gets no engine grid at all, because one
linear grid cannot follow a zone reset. The API still returns the correct zone
for each position on those terrains.

The script functions and the ACE devices carry no residual either way. They
convert each position exactly. The residual above applies only to the numbers
the engine draws on the map.

## Conversion accuracy

Separately, `tests/verify_mgrs.py` compares the formulas with the `mgrs` 1.7.0
reference library over 1,518 conversions at 506 positions in both hemispheres.
The last run reported zero mismatches after zone zero-padding normalisation.
