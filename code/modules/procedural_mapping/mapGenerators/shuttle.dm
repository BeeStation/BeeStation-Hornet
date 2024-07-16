/datum/mapGeneratorModule/bottomLayer/shuttleFloor
	spawnableTurfs = list(/turf/open/floor/mineral/titanium = 100)

/datum/mapGeneratorModule/border/shuttleWalls
	spawnableTurfs = list(/turf/closed/wall/mineral/titanium = 100)
// Generators

/datum/mapGenerator/shuttle/full
	modules = list(/datum/mapGeneratorModule/bottomLayer/shuttleFloor, \
		/datum/mapGeneratorModule/border/shuttleWalls,\
		/datum/mapGeneratorModule/bottomLayer/repressurize)
	buildmode_name = "Pattern: Shuttle Room"

/datum/mapGenerator/shuttle/floor
	modules = list(/datum/mapGeneratorModule/bottomLayer/shuttleFloor)
	buildmode_name = "Block: Shuttle Floor"
