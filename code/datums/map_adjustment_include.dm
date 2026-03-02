/*
		< ATTENTION >
	This file exists because of 'dme' file sort system
	These files are automatically sorted superior due to having "_maps\" location
	But these can't use JOB_NAME defines because those are defined after "_maps\"

	This file separation can support different servers using their own maps, especially supporting downstreams
*/

// just fancy macro that makes it looks like a proc
#define ADD_MAP_ACCESS(thing) new thing()

#include "..\..\_maps\map_files\BoxStation\map_adjustment_box.dm"
#include "..\..\_maps\map_files\CardinalStation\map_adjustment_cardinal.dm"
// RIP Corg station
#include "..\..\_maps\map_files\DeltaStation\map_adjustment_delta.dm"
#include "..\..\_maps\map_files\EchoStation\map_adjustment_echo.dm"
#include "..\..\_maps\map_files\FlandStation\map_adjustment_fland.dm"
#include "..\..\_maps\map_files\MetaStation\map_adjustment_meta.dm"
#include "..\..\_maps\map_files\KiloStation\map_adjustment_kilo.dm"
#include "..\..\_maps\map_files\RadStation\map_adjustment_rad.dm"
