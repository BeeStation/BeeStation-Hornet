//----------------------//
//   Initial Building   //
//----------------------//

/proc/make_datum_references_lists()
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, GLOB.hair_styles_list, GLOB.hair_styles_male_list, GLOB.hair_styles_female_list)
	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list, GLOB.facial_hair_styles_male_list, GLOB.facial_hair_styles_female_list)
	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	//undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	//socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list)
	//bodypart accessories (blizzard intensifies)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, GLOB.tails_list_lizard)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails_animated/lizard, GLOB.animated_tails_list_lizard)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_list_human)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails_animated/human, GLOB.animated_tails_list_human)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/horns,GLOB.horns_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.ears_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_open, GLOB.wings_open_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, GLOB.spines_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines_animated, GLOB.animated_spines_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.r_wings_list,roundstart = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/caps, GLOB.caps_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_roundstart_list, roundstart = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_antennae, GLOB.moth_antennae_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_antennae, GLOB.moth_antennae_roundstart_list, roundstart = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_markings, GLOB.moth_markings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_markings, GLOB.moth_markings_roundstart_list, roundstart = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wingsopen, GLOB.moth_wingsopen_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_screens, GLOB.ipc_screens_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_antennas, GLOB.ipc_antennas_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_chassis, GLOB.ipc_chassis_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/insect_type, GLOB.insect_type_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/apid_antenna, GLOB.apid_antenna_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/apid_stripes, GLOB.apid_stripes_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/apid_headstripes, GLOB.apid_headstripes_list)

	//Species
	for(var/spath in subtypesof(/datum/species))
		var/datum/species/S = new spath()
		GLOB.species_list[S.id] = spath
	sort_list(GLOB.species_list)

	//Surgeries
	for(var/path in subtypesof(/datum/surgery))
		GLOB.surgeries_list += new path()
	sort_list(GLOB.surgeries_list)
	GLOB.emote_list = init_emote_list()

	// Hair Gradients - Initialise all /datum/sprite_accessory/hair_gradient into an list indexed by gradient-style name
	for(var/path in subtypesof(/datum/sprite_accessory/hair_gradient))
		var/datum/sprite_accessory/hair_gradient/H = new path()
		GLOB.hair_gradients_list[H.name] = H

	// Keybindings
	for(var/KB in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = KB
		if(!initial(keybinding.key) || !initial(keybinding.keybind_signal))
			continue
		var/datum/keybinding/instance = new keybinding
		GLOB.keybindings_by_name[initial(instance.name)] = instance
		if (!(initial(instance.key) in GLOB.keybinding_list_by_key))
			GLOB.keybinding_list_by_key[initial(instance.key)] = list()
		GLOB.keybinding_list_by_key[initial(instance.key)] += instance.name
	// Sort all the keybindings by their weight
	for(var/key in GLOB.keybinding_list_by_key)
		GLOB.keybinding_list_by_key[key] = sort_list(GLOB.keybinding_list_by_key[key])


	init_crafting_recipes(GLOB.crafting_recipes)

/// Inits the crafting recipe list, sorting crafting recipe requirements in the process.
/proc/init_crafting_recipes(list/crafting_recipes)
	for(var/path in subtypesof(/datum/crafting_recipe))
		var/datum/crafting_recipe/recipe = new path()
		recipe.reqs = sort_list(recipe.reqs, /proc/cmp_crafting_req_priority)
		crafting_recipes += recipe
	return crafting_recipes

/proc/make_datum_references_lists_late_setup()
	// this should be done lately because it needs something pre-setup

	// Tooltips - this one needs config but config is loaded before this
	for(var/each in world.file2list("config/tooltips.txt"))
		if(!each)
			continue
		if(each[1] == "#")
			continue
		var/keycut = findtext(each, " ")
		var/key = copytext(each, 1, keycut)
		var/text_value = copytext(each, keycut+1)

		text_value = encode_wiki_link(text_value)
		GLOB.tooltips[key] = text_value
		// if runtime error happens, that means your config file is wrong

//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

//returns a list of paths to every subtype of prototype (excluding prototype)
//if no list/L is provided, one is created.
/proc/init_paths(prototype, list/L)
	if(!istype(L))
		L = list()
		for(var/path in subtypesof(prototype))
			L+= path
		return L

/*
Checks if that loc and dir has an item on the wall
*/
// Wall mounted machinery which are visually on the wall.
GLOBAL_LIST_INIT(WALLITEMS_INTERIOR, typecacheof(list(
	/obj/machinery/power/apc,
	/obj/machinery/airalarm,
	/obj/item/radio/intercom,
	/obj/structure/extinguisher_cabinet,
	/obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display,
	/obj/machinery/requests_console,
	/obj/machinery/light_switch,
	/obj/structure/sign,
	/obj/machinery/newscaster,
	/obj/machinery/firealarm,
	/obj/structure/noticeboard,
	/obj/machinery/button,
	/obj/machinery/computer/security/telescreen,
	/obj/machinery/embedded_controller/radio/simple_vent_controller,
	/obj/item/storage/secure/safe,
	/obj/machinery/door_timer,
	/obj/machinery/flasher,
	/obj/machinery/keycard_auth,
	/obj/structure/mirror,
	/obj/structure/fireaxecabinet,
	/obj/machinery/computer/security/telescreen/entertainment,
	/obj/structure/sign/picture_frame
	)))

// Wall mounted machinery which are visually coming out of the wall.
// These do not conflict with machinery which are visually placed on the wall.
GLOBAL_LIST_INIT(WALLITEMS_EXTERIOR, typecacheof(list(
	/obj/machinery/camera,
	/obj/structure/camera_assembly,
	/obj/structure/light_construct,
	/obj/machinery/light
	)))

GLOBAL_LIST_INIT(WALLITEMS_INVERSE, typecacheof(list(
	/obj/structure/light_construct,
	/obj/machinery/light
	)))
