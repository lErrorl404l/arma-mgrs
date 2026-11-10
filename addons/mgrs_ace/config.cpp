class CfgPatches {
    class zmgrs_ace {
        name = "MGRS ACE DAGR and MicroDAGR compatibility";
        author = "lErrorl404l";
        requiredVersion = 2.10;
        requiredAddons[] = {"zmgrs_main", "cba_main", "ace_common", "ace_dagr", "ace_microdagr"};
        skipWhenMissingDependencies = 1;
        units[] = {};
        weapons[] = {};
    };
};

#include "CfgEventHandlers.hpp"
