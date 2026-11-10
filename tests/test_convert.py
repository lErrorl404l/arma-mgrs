"""Tests for the terrain georeference converter."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

import mgrs_convert as conv  # noqa: E402


class AreaTests(unittest.TestCase):
    def test_altis_is_lon_first(self) -> None:
        box = conv.normalise_area([25.012, 39.7185, 25.4815, 40.0946], 35)
        self.assertEqual(box, [39.7185, 25.012, 40.0946, 25.4815])

    def test_tanoa_is_lat_first(self) -> None:
        box = conv.normalise_area([-20.268, 174.003, -20.1353, 174.146], 60)
        self.assertEqual(box, [-20.268, 174.003, -20.1353, 174.146])

    def test_ambiguous_uses_map_zone(self) -> None:
        # Values can be read either way. Zone 32 matches the lat-first reading.
        box = conv.normalise_area([40.0, 10.0, 41.0, 11.0], 32)
        self.assertEqual(box, [40.0, 10.0, 41.0, 11.0])

    def test_invalid(self) -> None:
        self.assertIsNone(conv.normalise_area([0, 0, 0, 0], 0))
        self.assertIsNone(conv.normalise_area([1, 2, 3], 0))


class LatLonTests(unittest.TestCase):
    def test_enoch_centre(self) -> None:
        box = conv.from_lat_lon(-54.0, 23.0, 12800)
        self.assertIsNotNone(box)
        assert box is not None
        self.assertAlmostEqual((box[0] + box[2]) / 2, 54.0, places=6)
        self.assertAlmostEqual((box[1] + box[3]) / 2, 23.0, places=6)
        self.assertTrue(conv.valid_box(*box))

    def test_zero_is_rejected(self) -> None:
        self.assertIsNone(conv.from_lat_lon(0.0, 0.0, 8192))


class SyntheticTests(unittest.TestCase):
    def test_uses_declared_origin(self) -> None:
        box = conv.synthetic(8192, {"origin": [30.0, 3.0]})
        centre_lat, centre_lon = conv.area_centre(box)
        self.assertAlmostEqual(centre_lat, 30.0, places=6)
        self.assertAlmostEqual(centre_lon, 3.0, places=6)
        self.assertTrue(conv.valid_box(*box))

    def test_same_baseline_same_box(self) -> None:
        baseline = {"origin": [30.0, 3.0]}
        self.assertEqual(conv.synthetic(8192, baseline), conv.synthetic(8192, baseline))


class BaselineTests(unittest.TestCase):
    def test_missing_file_uses_defaults(self) -> None:
        base = conv.load_baseline(Path("/nonexistent/does-not-exist.json"))
        self.assertEqual(base["zone"], 31)
        self.assertEqual(base["origin"], [30.0, 3.0])

    def test_zone_is_corrected_to_origin(self) -> None:
        import tempfile

        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as handle:
            handle.write('{"zone": 32, "origin": [30.0, 3.0]}')
            path = Path(handle.name)
        try:
            base = conv.load_baseline(path)
        finally:
            path.unlink()
        self.assertEqual(base["zone"], 31)


class ResolveTests(unittest.TestCase):
    def world(self, **kwargs) -> conv.World:
        world = conv.World(name="Test", parent="CAWorld", pbo="test.pbo", body="")
        for key, value in kwargs.items():
            setattr(world, key, value)
        return world

    def test_mgrs_geo_wins(self) -> None:
        world = self.world(mgrs_geo=[1.0, 2.0, 3.0, 4.0, 0])
        box, source, virtual = conv.resolve(world)
        self.assertEqual(box, [1.0, 2.0, 3.0, 4.0])
        self.assertEqual(source, "mgrsGeo")
        self.assertFalse(virtual)

    def test_synthetic_when_nothing_declared(self) -> None:
        world = self.world(name="NoDataAtAll", map_size=8192)
        box, source, virtual = conv.resolve(world)
        self.assertEqual(source, "synthetic")
        self.assertTrue(virtual)
        self.assertTrue(conv.valid_box(*box))

    def test_latlon_requires_matching_zone(self) -> None:
        world = self.world(
            name="ZoneMatch",
            latitude=-54.0,
            longitude=23.0,
            map_size=12800,
            map_zone=34,
        )
        _box, source, virtual = conv.resolve(world)
        self.assertEqual(source, "latlon")
        self.assertFalse(virtual)

    def test_latlon_zone_mismatch_falls_back(self) -> None:
        world = self.world(
            name="ZoneMismatch",
            latitude=-54.0,
            longitude=23.0,
            map_size=12800,
            map_zone=31,
        )
        _box, source, virtual = conv.resolve(world)
        self.assertEqual(source, "synthetic")
        self.assertTrue(virtual)

    def test_maparea_conflict_falls_back(self) -> None:
        # Rosche carries Altis's box; its lat/lon and zone do not agree.
        world = self.world(
            name="WL_Rosche",
            map_area=[25.011957, 39.718452, 25.481527, 40.094578],
            latitude=-52.985126,
            longitude=10.762755,
            map_zone=35,
            map_size=15360,
        )
        _box, source, virtual = conv.resolve(world)
        self.assertEqual(source, "synthetic")
        self.assertTrue(virtual)

    def test_maparea_agrees_with_latlon(self) -> None:
        world = self.world(
            name="brecon_becons",
            map_area=[51.81597, -3.4842489, 51.94323, -3.2807791],
            latitude=-51.879642,
            longitude=-3.3826575,
            map_zone=30,
            map_size=14080,
        )
        _box, source, virtual = conv.resolve(world)
        self.assertEqual(source, "mapArea")
        self.assertFalse(virtual)

    def test_root_maparea_recovers_copied_world_box(self) -> None:
        # Rosche's world class carries Altis's box; the CfgWorlds root has
        # the correct one and agrees with the lat/lon point.
        world = self.world(
            name="WL_Rosche",
            map_area=[25.011957, 39.718452, 25.481527, 40.094578],
            root_map_area=[10.5640335, 52.927483, 10.791751, 53.063946],
            latitude=-52.985126,
            longitude=10.762755,
            map_zone=35,
            map_size=15360,
        )
        box, source, virtual = conv.resolve(world)
        self.assertEqual(source, "mapArea-root")
        self.assertFalse(virtual)
        self.assertAlmostEqual(box[0], 52.927483, places=4)
        self.assertAlmostEqual(box[1], 10.5640335, places=4)

    def test_override_wins(self) -> None:
        world = self.world(
            name="NorthTakistan",
            map_area=[-20.268, 174.003, -20.1353, 174.146],
            map_zone=42,
            map_size=20480,
        )
        box, source, virtual = conv.resolve(
            world, {"northtakistan": [35.0, 62.0, 36.0, 63.0]}
        )
        self.assertEqual(source, "override")
        self.assertEqual(box, [35.0, 62.0, 36.0, 63.0])
        self.assertFalse(virtual)

    def test_load_overrides_ignores_bad_entries(self) -> None:
        import tempfile

        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as handle:
            handle.write(
                '{"good": [1, 2, 3, 4], "bad": [0, 0, 0, 0], "_comment": [9, 9, 9, 9]}'
            )
            path = Path(handle.name)
        try:
            overrides = conv.load_overrides(path)
        finally:
            path.unlink()
        self.assertEqual(overrides, {"good": [1.0, 2.0, 3.0, 4.0]})

    def test_known_correction(self) -> None:
        world = self.world(name="Stratis", map_size=8192)
        _box, source, virtual = conv.resolve(world)
        self.assertEqual(source, "known")
        self.assertFalse(virtual)


class ConfigTests(unittest.TestCase):
    def test_render_has_no_unused_grid(self) -> None:
        world = conv.World(name="Altis", parent="CAWorld", pbo="x", body="")
        text = conv.render_config(
            [(world, [1.0, 2.0, 3.0, 4.0], "mapArea", False)], conv.DEFAULT_BASELINE
        )
        self.assertIn("mgrsGeo[] = {1.000000, 2.000000, 3.000000, 4.000000, 0};", text)
        self.assertIn("syntheticOrigin[] = {30.000000, 3.000000};", text)
        self.assertIn('baselineVersion = "1.0.0";', text)
        self.assertNotIn("class Grid;", text)


if __name__ == "__main__":
    unittest.main()
