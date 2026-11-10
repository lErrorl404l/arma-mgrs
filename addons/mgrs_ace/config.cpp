#include "\z\mgrs\addons\mgrs\script_mod.hpp"

class CfgPatches {
    class mgrs_ace {
        name = "MGRS ACE DAGR and MicroDAGR compatibility";
        author = AUTHOR;
        authors[] = AUTHORS;
        url = URL;
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"mgrs_main", "cba_main", "ace_common", "ace_dagr", "ace_microdagr"};
        skipWhenMissingDependencies = 1;
        units[] = {};
        weapons[] = {};
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
