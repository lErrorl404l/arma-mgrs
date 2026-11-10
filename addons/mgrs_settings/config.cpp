class CfgPatches {
    class zmgrs_settings {
        name = "MGRS CBA settings";
        author = "lErrorl404l";
        requiredVersion = 2.10;
        requiredAddons[] = {"zmgrs_main", "cba_main"};
        skipWhenMissingDependencies = 1;
        units[] = {};
        weapons[] = {};
    };
};

#include "CfgEventHandlers.hpp"
