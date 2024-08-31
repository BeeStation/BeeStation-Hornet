#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

// uncomment this for a map you need to use
// #define FORCE_MAP "corgstation"
// #define FORCE_MAP "boxstation"
// #define FORCE_MAP "metastation"
// #define FORCE_MAP "deltastation"
// #define FORCE_MAP "kilostation"
// #define FORCE_MAP "flandstation"
// #define FORCE_MAP "radstation"
// #define FORCE_MAP "echostation"
// #define FORCE_MAP "runtimestation"
// #define FORCE_MAP "multiz_debug"

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"
		#include "map_files\CorgStation\CorgStation.dmm"
		#include "map_files\Deltastation\DeltaStation2.dmm"
		#include "map_files\MetaStation\MetaStation.dmm"
		#include "map_files\BoxStation\BoxStation.dmm"
		#include "map_files\KiloStation\KiloStation.dmm"
		#include "map_files\flandstation\flandstation.dmm"
		#include "map_files\RadStation\RadStation.dmm"
		#include "map_files\EchoStation\EchoStation.dmm"

		#ifdef CIBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
