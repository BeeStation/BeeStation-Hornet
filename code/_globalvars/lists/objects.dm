/// List of all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST_EMPTY(cable_list)

/// List of all portals
GLOBAL_LIST_EMPTY(portals)

/// List of all mechs for hostile mob target tracking
GLOBAL_LIST_EMPTY(mechas_list)

/// List of all atoms that can call the shuttle, for automatic shuttle calls when there are none.
GLOBAL_LIST_EMPTY(shuttle_caller_list)

/// List of all nukie shuttle boards, for forcing launch delay if they declare war
GLOBAL_LIST_EMPTY(syndicate_shuttle_boards)

/// List of all nav beacons indexed by stringified z-level
GLOBAL_LIST_EMPTY(navbeacons)

/// List of all active teleport beacons
GLOBAL_LIST_EMPTY(teleportbeacons)

/// List of all active delivery beacons
GLOBAL_LIST_EMPTY(deliverybeacons)

/// List of all active delivery beacon locations
GLOBAL_LIST_EMPTY(deliverybeacontags)

/// List of all singularity components that exist
GLOBAL_LIST_EMPTY_TYPED(singularities, /datum/component/singularity)

/// list of all /datum/chemical_reaction datums indexed by their typepath. Use this for general lookup stuff
GLOBAL_LIST(chemical_reactions_list)
/// list of all /datum/chemical_reaction datums. Used during chemical reactions. Indexed by REACTANT types
GLOBAL_LIST(chemical_reactions_list_reactant_index)
/// list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST(chemical_reagents_list)

/// list of all surgeries by name, associated with their path.
GLOBAL_LIST_INIT(surgeries_list, init_surgeries())

/// list of all surgery steps, associated by their path.
GLOBAL_LIST_INIT(surgery_steps, init_subtypes_w_path_keys(/datum/surgery_step, list()))

/// Global list of all non-cooking related crafting recipes.
GLOBAL_LIST_EMPTY(crafting_recipes)
/// This is a global list of typepaths, these typepaths are atoms or reagents that are associated with crafting recipes.
/// This includes stuff like recipe components and results.
GLOBAL_LIST_EMPTY(crafting_recipes_atoms)
/// Global list of all cooking related crafting recipes.
GLOBAL_LIST_EMPTY(cooking_recipes)
/// This is a global list of typepaths, these typepaths are atoms or reagents that are associated with cooking recipes.
/// This includes stuff like recipe components and results.
GLOBAL_LIST_EMPTY(cooking_recipes_atoms)

/// list of Rapid Construction Devices.
GLOBAL_LIST_EMPTY(rcd_list)
/// list of wallmounted intercom radios.
GLOBAL_LIST_EMPTY(intercoms_list)
/// list of all current implants that are tracked to work out what sort of trek everyone is on. Sadly not on lavaworld not implemented...
GLOBAL_LIST_EMPTY(tracked_implants)
/// list of implants the prisoner console can track and send inject commands too
GLOBAL_LIST_EMPTY(tracked_chem_implants)
/// list of points of interest for observe/follow
GLOBAL_LIST_EMPTY(poi_list)
/// list of all pinpointers. Used to change stuff they are pointing to all at once.
GLOBAL_LIST_EMPTY(pinpointer_list)
/// A list of all zombie_infection organs, for any mass "animation"
GLOBAL_LIST_EMPTY(zombie_infection_list)
/// List of all meteors.
GLOBAL_LIST_EMPTY(meteor_list)
/// List of active radio jammers
GLOBAL_LIST_EMPTY(active_jammers)
/// List of jam receivers by z-level
GLOBAL_LIST_EMPTY(jam_receivers_by_z)
GLOBAL_LIST_EMPTY(ladders)
GLOBAL_LIST_EMPTY(stairs)
GLOBAL_LIST_EMPTY(bot_elevator)
GLOBAL_LIST_EMPTY(janitor_devices)
GLOBAL_LIST_EMPTY(trophy_cases)

GLOBAL_LIST_EMPTY(wire_color_directory)
GLOBAL_LIST_EMPTY(wire_name_directory)

/// List of all instances of /obj/effect/mob_spawn/ghost_role in the game world
GLOBAL_LIST_EMPTY(mob_spawners)

// List of organ typepaths that are not unit test-able, and shouldn't be spawned by some things, such as certain class prototypes.
GLOBAL_LIST_INIT(prototype_organs, typecacheof(list(
	/obj/item/organ,
	/obj/item/organ/wings,
	/obj/item/organ/wings/moth,
	/obj/item/organ/cyberimp,
	/obj/item/organ/cyberimp/brain,
	/obj/item/organ/cyberimp/mouth,
	/obj/item/organ/cyberimp/arm,
	/obj/item/organ/cyberimp/chest,
	/obj/item/organ/cyberimp/eyes,
	/obj/item/organ/alien,
	/obj/item/organ/nymph_organ,
	/obj/item/organ/nymph_organ/chest,
	/obj/item/organ/nymph_organ/r_arm,
	/obj/item/organ/nymph_organ/l_arm,
	/obj/item/organ/nymph_organ/r_leg,
	/obj/item/organ/nymph_organ/l_leg,
), only_root_path = TRUE))

// List of organ typepaths similiar to prototype_organs, but including subtypes
GLOBAL_LIST_INIT(blacklist_organs, typecacheof(list(
	//initilization check these at some point
	/obj/item/organ/wings,
	/obj/item/organ/ears/cat,
	/obj/item/organ/horns,
	/obj/item/organ/frills,
	/obj/item/organ/tail,
	/obj/item/organ/spines,
	/obj/item/organ/snout,
), only_root_path = FALSE))
