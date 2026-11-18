/* SPDX-License-Identifier: GPL-2.0-or-later */
class Extended_PreInit_EventHandlers {
    class mgrs_ace {
        init = "call compile preprocessFileLineNumbers '\z\mgrs\addons\mgrs_ace\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers {
    class mgrs_ace {
        init = "call compile preprocessFileLineNumbers '\z\mgrs\addons\mgrs_ace\XEH_postInit.sqf'";
    };
};
