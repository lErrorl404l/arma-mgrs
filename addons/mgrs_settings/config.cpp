#include "\z\mgrs\addons\mgrs\script_mod.hpp"

class CfgPatches {
    class mgrs_settings {
        name = "MGRS CBA settings";
        author = AUTHOR;
        authors[] = AUTHORS;
        url = URL;
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"mgrs_main", "cba_main"};
        skipWhenMissingDependencies = 1;
        units[] = {};
        weapons[] = {};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
