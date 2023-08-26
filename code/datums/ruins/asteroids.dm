
#define RUIN_ARTIFACT 1
#define RUIN_LEGENDARY 3
#define RUIN_RARE 6
#define RUIN_UNCOMMON 10
#define RUIN_COMMON 18

/datum/map_template/asteroid
	var/weight = 10

/datum/map_template/asteroid/New(path, rename, cache, admin_load)
	..(path = "_maps/RandomRuins/AsteroidRuins/[name].dmm")

/datum/map_template/asteroid/puzzle_cube
	name = "puzzle_cube"
	weight = RUIN_RARE

/datum/map_template/asteroid/blood_drunk_1
	name = "blood_drunk_1"
	weight = RUIN_LEGENDARY

/datum/map_template/asteroid/blood_drunk_2
	name = "blood_drunk_2"
	weight = RUIN_LEGENDARY

/datum/map_template/asteroid/cult_altar
	name = "cult_alter"
	weight = RUIN_LEGENDARY
