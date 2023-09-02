
GLOBAL_LIST_EMPTY(damage_type_singletons)

#define GET_DAMAGE(damage_type) (length(GLOB.damage_type_singletons) ? GLOB.damage_type_singletons[damage_type] : (GLOB.damage_type_singletons = create_damage_singletons())[damage_type])

/proc/create_damage_singletons()
	for (var/type in subtypesof(/datum/damage))
		GLOB.damage_type_singletons[type] = new type

GLOBAL_LIST_EMPTY(damage_source_singletons)

#define GET_DAMAGE_SOURCE(source_type) (length(GLOB.damage_source_singletons) ? GLOB.damage_source_singletons[source_type] : (GLOB.damage_source_singletons = create_source_singletons())[source_type])

/proc/create_source_singletons()
	for (var/type in subtypesof(/datum/damage_source))
		GLOB.damage_source_singletons[type] = new type

#define FIND_DAMAGE_SOURCE locate() in GLOB.damage_source_singletons
