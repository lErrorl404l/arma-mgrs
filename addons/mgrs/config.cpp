#include "\z\mgrs\addons\mgrs\script_mod.hpp"

class CfgPatches {
    class mgrs_main {
        name = "Arma MGRS";
        author = AUTHOR;
        authors[] = AUTHORS;
        url = URL;
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {};
        units[] = {};
        weapons[] = {};
        VERSION_CONFIG;
    };
};

class CfgFunctions {
    class mgrs {
        class core {
            file = "\z\mgrs\addons\mgrs\functions";
            class getGeorefInfo {};
            class getGeoref {};
            class biomeBand {};
            class biomeClimate {};
            class biomeClassify {};
            class biomeScan {};
            class syntheticGeoref {};
            class worldToLatLon {};
            class latLonToUTM {};
            class latToBand {};
            class padDigits {};
            class utmToMGRS {};
            class posToMGRS {};
            class posToUTM {};
            class setGeoref {};
            class mapGridPosition {};
        };
    };
};
