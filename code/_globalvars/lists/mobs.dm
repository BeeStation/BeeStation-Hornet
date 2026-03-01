GLOBAL_LIST_EMPTY(clients)							//all clients who have authenticated
GLOBAL_LIST_EMPTY(clients_unsafe)					//all clients, including unauthenticated ones
GLOBAL_LIST_EMPTY(admins)							//all clients whom are admins
GLOBAL_PROTECT(admins)
GLOBAL_LIST_EMPTY(deadmins)							//all ckeys who have used the de-admin verb.

GLOBAL_LIST_EMPTY(directory)							//all ckeys with associated client (including unauthenticated ones)
GLOBAL_LIST_EMPTY(stealthminID)						//reference list with IDs that store ckeys, for stealthmins


//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_LIST_EMPTY(player_list)				//all mobs **with clients attached**.
GLOBAL_LIST_EMPTY(mob_list)					//all mobs, including clientless
GLOBAL_LIST_EMPTY(mob_directory)			//mob_id -> mob
GLOBAL_LIST_EMPTY(alive_mob_list)			//all alive mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(suicided_mob_list)		//contains a list of all mobs that suicided, including their associated ghosts.
GLOBAL_LIST_EMPTY(drones_list)
GLOBAL_LIST_EMPTY(dead_mob_list)			//all dead mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(joined_player_list)		//all clients that have joined the game at round-start or as a latejoin.
GLOBAL_LIST_EMPTY(auth_new_player_list)		//all /mob/dead/new_player/authenticated, in theory all should have clients and those that don't are in the process of spawning and get deleted when done.
GLOBAL_LIST_EMPTY(pre_setup_antags)			//minds that have been picked as antag by dynamic. removed as antag datums are set.
GLOBAL_LIST_EMPTY(mob_living_list)			//all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(carbon_list)				//all instances of /mob/living/carbon and subtypes, notably does not contain brains or simple animals
GLOBAL_LIST_EMPTY(human_list) //all instances of /mob/living/carbon/human and subtypes
GLOBAL_LIST_EMPTY(silicon_mobs)				//all instances of /mob/living/silicon and subtypes
GLOBAL_LIST_EMPTY(ai_list)					//all instances of /mob/living/silicon/ai and subtypes
GLOBAL_LIST_EMPTY(cyborg_list)				//all instances of /mob/living/silicon/robot and subtypes
GLOBAL_LIST_EMPTY(pai_list)					//all instances of /mob/living/silicon/pai and subtypes
GLOBAL_LIST_EMPTY(available_ai_shells)
GLOBAL_LIST_INIT(simple_animals, list(list(),list(),list(),list())) // One for each AI_* status define
GLOBAL_LIST_EMPTY(spidermobs)				//all sentient spider mobs
GLOBAL_LIST_EMPTY(all_mimites)				//all mimites and their subtypes
GLOBAL_LIST_EMPTY(bots_list)
GLOBAL_LIST_EMPTY(ai_eyes)
GLOBAL_LIST_EMPTY(suit_sensors_list) 		//all people with suit sensors on
GLOBAL_LIST_EMPTY(unique_connected_keys)	//All ckeys that have connected at any point in the game

/// List of language prototypes to reference, assoc [type] = prototype
GLOBAL_LIST_INIT_TYPED(language_datum_instances, /datum/language, init_language_prototypes())
/// List if all language typepaths learnable, IE, those with keys
GLOBAL_LIST_INIT(all_languages, init_all_languages())
// /List of language prototypes to reference, assoc "name" = typepath
GLOBAL_LIST_INIT(language_types_by_name, init_language_types_by_name())

/proc/init_language_prototypes()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue

		lang_list[lang_type] = new lang_type()
	return lang_list

/proc/init_all_languages()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue
		lang_list += lang_type
	return lang_list

/proc/init_language_types_by_name()
	var/list/lang_list = list()
	for(var/datum/language/lang_type as anything in typesof(/datum/language))
		if(!initial(lang_type.key))
			continue
		lang_list[initial(lang_type.name)] = lang_type
	return lang_list

/// An assoc list of species IDs to type paths
GLOBAL_LIST_INIT(species_list, init_species_list())
/// List of all species prototypes to reference, assoc [type] = prototype
GLOBAL_LIST_INIT_TYPED(species_prototypes, /datum/species, init_species_prototypes())

/proc/init_species_list()
	var/list/species_list = list()
	for(var/datum/species/species_path as anything in subtypesof(/datum/species))
		species_list[initial(species_path.id)] = species_path
	return species_list

/proc/init_species_prototypes()
	var/list/species_list = list()
	for(var/species_type in subtypesof(/datum/species))
		species_list[species_type] = new species_type()
	return species_list

GLOBAL_LIST_EMPTY(sentient_disease_instances)

GLOBAL_LIST_EMPTY(latejoin_ai_cores)

GLOBAL_LIST_EMPTY(mob_config_movespeed_type_lookup)

GLOBAL_LIST_EMPTY(emote_list)

GLOBAL_LIST_EMPTY(cyborg_name_list)

GLOBAL_LIST_INIT(construct_radial_images, list(
	CONSTRUCT_JUGGERNAUT = image(icon = 'icons/mob/cult.dmi', icon_state = "juggernaut"),
	CONSTRUCT_WRAITH = image(icon = 'icons/mob/cult.dmi', icon_state = "wraith"),
	CONSTRUCT_ARTIFICER = image(icon = 'icons/mob/cult.dmi', icon_state = "artificer")
))

GLOBAL_LIST_INIT(blood_types, generate_blood_types())

/proc/generate_blood_types()
	. = list()
	for(var/path in subtypesof(/datum/blood_type))
		var/datum/blood_type/new_type = new path()
		.[new_type.name] = new_type

/proc/update_config_movespeed_type_lookup(update_mobs = TRUE)
	var/list/mob_types = list()
	var/list/entry_value = CONFIG_GET(keyed_list/multiplicative_movespeed)
	for(var/path in entry_value)
		var/value = entry_value[path]
		if(!value)
			continue
		for(var/subpath in typesof(path))
			mob_types[subpath] = value
	GLOB.mob_config_movespeed_type_lookup = mob_types
	if(update_mobs)
		update_mob_config_movespeeds()

/proc/update_mob_config_movespeeds()
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		M.update_config_movespeed()

/proc/init_emote_list()
	. = list()
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		if(E.key)
			if(!.[E.key])
				.[E.key] = list(E)
			else
				.[E.key] += E
		else if(E.message) //Assuming all non-base emotes have this
			stack_trace("Keyless emote: [E.type]")

		if(E.key_third_person) //This one is optional
			if(!.[E.key_third_person])
				.[E.key_third_person] = list(E)
			else
				.[E.key_third_person] |= E

/proc/get_crewmember_minds()
	var/list/minds = list()
	for(var/datum/record/locked/target in GLOB.manifest.locked)
		var/datum/mind/mind = target.weakref_mind.resolve()
		if(mind)
			minds += mind
	return minds
