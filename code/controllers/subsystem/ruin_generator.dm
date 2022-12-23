SUBSYSTEM_DEF(ruin_generator)
	name = "Ruin Generator"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RUIN_GENERATOR
	//The decorators that we can apply
	var/list/datum/ruin_decorator/decorators = list()
	//The ruin that we are waiting to gobble up
	var/datum/map_generator/space_ruin/unused_ruin

/datum/controller/subsystem/ruin_generator/Initialize(start_timeofday)
	. = ..()
	//Build decorator list
	for (var/subtype in subtypesof(/datum/ruin_decorator))
		var/datum/ruin_decorator/decorator = new subtype
		decorators[decorator] = decorator.decorator_weight
	//Generate the initial ruin
	generate_ruin()

/datum/controller/subsystem/ruin_generator/proc/get_ruin()
	. = unused_ruin
	//We no longer need to keep that ruin around
	SSzclear.unkeep_z(unused_ruin.center_z)
	unused_ruin = null
	generate_ruin()

/datum/controller/subsystem/ruin_generator/proc/decorate_ruin(datum/map_generator/space_ruin/ruin)
	var/datum/ruin_decorator/selected_decorator = pickweight(decorators)
	selected_decorator.decorate(ruin)

/datum/controller/subsystem/ruin_generator/proc/generate_ruin()
	var/datum/space_level/target_level = SSzclear.get_free_z_level()
	//Generate the actual ruin
	unused_ruin = generate_space_ruin(world.maxx / 2, world.maxy / 2, target_level.z_value, 100, 100, null)
	//Add decorations to the ruin, if needed
	decorate_ruin(unused_ruin)
	//Keep this around until the explorers arrive
	SSzclear.keep_z(target_level.z_value)
