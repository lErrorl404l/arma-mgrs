// Experimental only. Not built by this project.
//
// This patch makes the Altis map draw a 10 m grid with 4-digit labels, which
// also changes mapGridPosition to 8 digits. The labels still count from the
// world origin, not from a UTM 100 km square, and the engine cannot draw the
// MGRS zone, band, or square letters. See docs/RESEARCH.md before shipping
// anything like this.
//
// Load as a separate PBO. requiredAddons[] must list A3_Map_Altis.
class CfgWorlds {
    class DefaultWorld {
        class Grid;
    };
    class CAWorld: DefaultWorld {};
    class Altis: CAWorld {
        class Grid: Grid {
            class Zoom1 {
                zoomMax = 0.05;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 10;
                stepY = -10;
            };
        };
    };
};
