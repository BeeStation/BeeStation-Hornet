/// Pixel offset using by mineral turf icons
#define MINERAL_WALL_OFFSET -4

/// Cache of /datum/mineral_spawn_chances types to their chance lists.
GLOBAL_LIST_INIT(mineral_spawn_chances, generate_mineral_spawn_chances())

/proc/generate_mineral_spawn_chances()
	var/list/result = list()
	for(var/datum/mineral_spawn_chances/type as anything in subtypesof(/datum/mineral_spawn_chances))
		var/datum/mineral_spawn_chances/chance = new type()
		result[chance] = chance.get_chances()
	return result

/// This is relevant because lavaland has thousands of these and creates an assload of unnecessary lists during /proc/(init).
/datum/mineral_spawn_chances/proc/get_chances()
	SHOULD_CALL_PARENT(FALSE)
	RETURN_TYPE(/list)
	CRASH("get_chances() called for base type /datum/mineral_spawn_chances by [type]")
