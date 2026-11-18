/* SPDX-License-Identifier: GPL-2.0-or-later */
#define MAINPREFIX z
#define PREFIX mgrs
#define SUBPREFIX addons

#define MAJOR 0
#define MINOR 1
#define PATCHLVL 0
#define BUILD 0

#define VERSION MAJOR.MINOR
#define VERSION_STR "0.1.0"
#define VERSION_AR MAJOR,MINOR,PATCHLVL,BUILD
#define VERSION_CONFIG version = VERSION; versionStr = VERSION_STR; versionAr[] = {VERSION_AR}

#define REQUIRED_VERSION 2.10

#define AUTHOR "lErrorl404l"
#define AUTHORS {AUTHOR}
#define URL "https://github.com/lErrorl404l/arma-mgrs"
