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
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_screens, GLOB.ipc_screens_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_antennas, GLOB.ipc_antennas_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_chassis, GLOB.ipc_chassis_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/insect_type, GLOB.insect_type_list)

	//Species
	for(var/spath in subtypesof(/datum/species))
		var/datum/species/S = new spath()
		GLOB.species_list[S.id] = spath
	sortList(GLOB.species_list)

	//Surgeries
	for(var/path in subtypesof(/datum/surgery))
		GLOB.surgeries_list += new path()
	sortList(GLOB.surgeries_list)

	GLOB.emote_list = init_emote_list()



	// Keybindings
	for(var/KB in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = KB
		if(!initial(keybinding.key))
			continue
		var/datum/keybinding/instance = new keybinding
		GLOB.keybindings_by_name[initial(instance.name)] = instance
		if (!(initial(instance.key) in GLOB.keybinding_list_by_key))
			GLOB.keybinding_list_by_key[initial(instance.key)] = list()
		GLOB.keybinding_list_by_key[initial(instance.key)] += instance.name
	// Sort all the keybindings by their weight
	for(var/key in GLOB.keybinding_list_by_key)
		GLOB.keybinding_list_by_key[key] = sortList(GLOB.keybinding_list_by_key[key])


	init_subtypes(/datum/crafting_recipe, GLOB.crafting_recipes)

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
