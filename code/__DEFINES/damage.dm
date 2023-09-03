
GLOBAL_LIST_EMPTY(damage_type_singletons)

#define GET_DAMAGE(damage_type) (length(GLOB.damage_type_singletons) ? GLOB.damage_type_singletons[damage_type] : (create_damage_singletons())[damage_type])

/proc/create_damage_singletons()
	GLOB.damage_type_singletons = list()
	for (var/type in subtypesof(/datum/damage))
		GLOB.damage_type_singletons[type] = new type
	return GLOB.damage_type_singletons

GLOBAL_LIST_EMPTY(damage_source_singletons)

#define GET_DAMAGE_SOURCE(source_type) (length(GLOB.damage_source_singletons) ? GLOB.damage_source_singletons[source_type] : (create_source_singletons())[source_type])

/proc/create_source_singletons()
	GLOB.damage_source_singletons = list()
	for (var/type in subtypesof(/datum/damage_source))
		GLOB.damage_source_singletons[type] = new type
	return GLOB.damage_source_singletons

#define FIND_DAMAGE_SOURCE locate() in GLOB.damage_source_singletons
