#include "\z\mgrs\addons\mgrs\script_mod.hpp"

class CfgPatches {
    class zmgrs_main {
        name = "MGRS Grid Reference";
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

#include "CfgEventHandlers.hpp"
