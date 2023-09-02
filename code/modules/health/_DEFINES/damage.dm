
GLOBAL_LIST_EMPTY(damage_type_singletons)

#define GET_DAMAGE(damage_type) (length(GLOB.damage_type_singletons) ? GLOB.damage_type_singletons[damage_type] : (GLOB.damage_type_singletons = create_damage_singletons())[damage_type])

/proc/create_damage_singletons()
	for (var/type in subtypesof(/datum/damage))
		GLOB.damage_type_singletons[type] = new type
