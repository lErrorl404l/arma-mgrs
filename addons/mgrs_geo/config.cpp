class CfgPatches {
    class zmgrs_geo {
        name = "MGRS georeference table";
        author = "lErrorl404l";
        requiredVersion = 2.1;
        requiredAddons[] = {"A3_Data_F_Decade_Loadorder"};
        units[] = {};
        weapons[] = {};
        datum = "WGS84";
        syntheticOrigin[] = {30, 3};
        syntheticZone = 31;
        baselineVersion = "1.0.0";
        convergence = "world north assumed grid north";
        baselineLabel = "Declared synthetic training baseline";
    };
};
class CfgWorlds {
    class DefaultWorld {
        class Grid;
    };
    class CAWorld: DefaultWorld {};
    class arm_world_centraleurope;
    class WL_Rosche: CAWorld {
        mgrsGeo[] = {52.927483, 10.564034, 53.063946, 10.791751, 0};
        class Grid: Grid {
            offsetX = -5284.111;
            offsetY = -64608.113;
            class Zoom1 {
                zoomMax = 0.0133987;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 10.290197;
                stepY = 9.886671;
            };
            class Zoom2 {
                zoomMax = 0.133987;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 102.901970;
                stepY = 98.866714;
            };
            class Zoom3 {
                zoomMax = 1.33987;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 1029.019800;
                stepY = 988.667200;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 10290.197000;
                stepY = 9886.672000;
            };
        };
    };
    class Altis: CAWorld {
        mgrsGeo[] = {39.7185, 25.012, 40.0946, 25.4815, 0};
        class Grid: Grid {
            offsetX = -22206.152;
            offsetY = 1197.304;
            class Zoom1 {
                zoomMax = 0.00488354;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 7.501114;
                stepY = 7.500331;
            };
            class Zoom2 {
                zoomMax = 0.0488354;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 75.011140;
                stepY = 75.003310;
            };
            class Zoom3 {
                zoomMax = 0.488354;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 750.111400;
                stepY = 750.033100;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 7501.114000;
                stepY = 7500.331000;
            };
        };
    };
    class Stratis: CAWorld {
        mgrsGeo[] = {39.45, 24.95, 39.56, 25.06, 0};
        class Grid: Grid {
            offsetX = -19880.307;
            offsetY = -46914.637;
            class Zoom1 {
                zoomMax = 0.0205578;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 8.420478;
                stepY = 6.826824;
            };
            class Zoom2 {
                zoomMax = 0.205578;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 84.204780;
                stepY = 68.268234;
            };
            class Zoom3 {
                zoomMax = 2.05578;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 842.047850;
                stepY = 682.682400;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 8420.479000;
                stepY = 6826.823700;
            };
        };
    };
    class VR: CAWorld {
        mgrsGeo[] = {0, 0, 0.09, 0.09, 0};
        class Grid: Grid {
            offsetX = -53930.688;
            offsetY = 0;
            class Zoom1 {
                zoomMax = 0.019943;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 8.168663;
                stepY = 8.224375;
            };
            class Zoom2 {
                zoomMax = 0.19943;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 81.686620;
                stepY = 82.243750;
            };
            class Zoom3 {
                zoomMax = 1.9943;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 816.866300;
                stepY = 822.437500;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 8168.662600;
                stepY = 8224.375000;
            };
        };
    };
    class Malden: CAWorld {
        mgrsGeo[] = {39.7185, 25.012, 40.0946, 25.4815, 0};
        class Grid: Grid {
            offsetX = -9252.564;
            offsetY = 498.877;
            class Zoom1 {
                zoomMax = 0.00488354;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 3.125464;
                stepY = 3.125138;
            };
            class Zoom2 {
                zoomMax = 0.0488354;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 31.254640;
                stepY = 31.251379;
            };
            class Zoom3 {
                zoomMax = 0.488354;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 312.546420;
                stepY = 312.513800;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 3125.464000;
                stepY = 3125.138000;
            };
        };
    };
    class Enoch: CAWorld {
        mgrsGeo[] = {53.8, 22.7, 54.2, 23.2, 0};
        class Grid: Grid {
            offsetX = -4854.409;
            offsetY = -17652.797;
            class Zoom1 {
                zoomMax = 0.00634054;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 4.057948;
                stepY = 2.819464;
            };
            class Zoom2 {
                zoomMax = 0.0634054;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 40.579480;
                stepY = 28.194640;
            };
            class Zoom3 {
                zoomMax = 0.634054;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 405.794770;
                stepY = 281.946400;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 4057.947800;
                stepY = 2819.464000;
            };
        };
    };
    class Tanoa: CAWorld {
        mgrsGeo[] = {-20.268, 174.003, -20.1353, 174.146, 0};
        class Grid: Grid {
            offsetX = -90856.9;
            offsetY = -57507.484;
            class Zoom1 {
                zoomMax = 0.0136101;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 10.452589;
                stepY = 10.264963;
            };
            class Zoom2 {
                zoomMax = 0.136101;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 104.525890;
                stepY = 102.649630;
            };
            class Zoom3 {
                zoomMax = 1.36101;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 1045.258900;
                stepY = 1026.496200;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 10452.589000;
                stepY = 10264.963000;
            };
        };
    };
    class kerama: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class Mountains_ACR: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Woodland_ACR: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Bootcamp_ACR: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Chernarus: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Chernarus_Summer: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Chernarus_Winter: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Porto: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
    };
    class Intro: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
    };
    class Desert_E: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class ProvingGrounds_PMC: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Sara: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Sara_dbe1: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class SaraLite: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Shapur_BAF: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Takistan: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Utes: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class Zargabad: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class dagger_island_summer: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class kunduz_valley: CAWorld {
        mgrsGeo[] = {36.628014, 68.74524, 36.81199, 68.97476, 0};
        class Grid: Grid {
            offsetX = -77049.27;
            offsetY = -53906.703;
            class Zoom1 {
                zoomMax = 0.00974363;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.977558;
                stepY = 10.050069;
            };
            class Zoom2 {
                zoomMax = 0.0974363;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.775580;
                stepY = 100.500690;
            };
            class Zoom3 {
                zoomMax = 0.974363;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 997.755800;
                stepY = 1005.006900;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9977.558000;
                stepY = 10050.069000;
            };
        };
    };
    class NorthTakistan: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class opx_tac: Stratis {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
    };
    class oski_corran: Stratis {
        mgrsGeo[] = {56.665203, -5.287022, 56.738796, -5.152978, 0};
    };
    class swu_public_Imber_uk: Stratis {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
    };
    class tem_kujari: CAWorld {
        mgrsGeo[] = {11.92641, 12.924766, 12.07359, 13.075234, 0};
        class Grid: Grid {
            offsetX = -73433.414;
            offsetY = -19523.42;
            class Zoom1 {
                zoomMax = 0.0121159;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.925399;
                stepY = 10.135513;
            };
            class Zoom2 {
                zoomMax = 0.121159;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.254000;
                stepY = 101.355130;
            };
            class Zoom3 {
                zoomMax = 1.21159;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 992.540000;
                stepY = 1013.551330;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9925.399000;
                stepY = 10135.514000;
            };
        };
    };
    class UMB_Colombia: Stratis {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
    };
    class bala_murghab_summer: CAWorld {
        mgrsGeo[] = {35.492012, 63.215893, 35.675987, 63.44211, 0};
        class Grid: Grid {
            offsetX = -19632.75;
            offsetY = -27639.043;
            class Zoom1 {
                zoomMax = 0.00979104;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 10.026012;
                stepY = 10.003610;
            };
            class Zoom2 {
                zoomMax = 0.0979104;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 100.260120;
                stepY = 100.036100;
            };
            class Zoom3 {
                zoomMax = 0.979104;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 1002.601200;
                stepY = 1000.361000;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 10026.012000;
                stepY = 10003.610000;
            };
        };
    };
    class bala_murghab_winter: CAWorld {
        mgrsGeo[] = {35.492012, 63.215893, 35.675987, 63.44211, 0};
        class Grid: Grid {
            offsetX = -19632.75;
            offsetY = -27639.043;
            class Zoom1 {
                zoomMax = 0.00979104;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 10.026012;
                stepY = 10.003610;
            };
            class Zoom2 {
                zoomMax = 0.0979104;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 100.260120;
                stepY = 100.036100;
            };
            class Zoom3 {
                zoomMax = 0.979104;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 1002.601200;
                stepY = 1000.361000;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 10026.012000;
                stepY = 10003.610000;
            };
        };
    };
    class clafghan: CAWorld {
        mgrsGeo[] = {29.963205, 2.957513, 30.036795, 3.042487, 1};
        class Grid: Grid {
            offsetX = 4097.511;
            offsetY = -14776.907;
            class Zoom1 {
                zoomMax = 0.0244035;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995674;
                stepY = 10.046195;
            };
            class Zoom2 {
                zoomMax = 0.244035;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956740;
                stepY = 100.461950;
            };
            class Zoom3 {
                zoomMax = 2.44035;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.567400;
                stepY = 1004.619570;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.674000;
                stepY = 10046.195000;
            };
        };
    };
    class lythium: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class brecon_becons: arm_world_centraleurope {
        mgrsGeo[] = {51.81597, -3.484249, 51.94323, -3.280779, 0};
    };
    class VEE_ArcticExpanse: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class VEE_DesertExpanse: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class VEE_GreenExpanse: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class VEE_SpaceExpanse: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class VEE_TasmanSea: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class VEE_UrbanExpanse: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
    class VEE_VaccumExpanse: CAWorld {
        mgrsGeo[] = {29.908012, 2.893782, 30.091988, 3.106218, 1};
        class Grid: Grid {
            offsetX = 10249.444;
            offsetY = -8636.96;
            class Zoom1 {
                zoomMax = 0.00976136;
                format = "XY";
                formatX = "0000";
                formatY = "0000";
                stepX = 9.995682;
                stepY = 10.046188;
            };
            class Zoom2 {
                zoomMax = 0.0976136;
                format = "XY";
                formatX = "000";
                formatY = "000";
                stepX = 99.956825;
                stepY = 100.461880;
            };
            class Zoom3 {
                zoomMax = 0.976136;
                format = "XY";
                formatX = "00";
                formatY = "00";
                stepX = 999.568240;
                stepY = 1004.618840;
            };
            class Zoom4 {
                zoomMax = 1e+30;
                format = "XY";
                formatX = "0";
                formatY = "0";
                stepX = 9995.683000;
                stepY = 10046.188000;
            };
        };
    };
};
