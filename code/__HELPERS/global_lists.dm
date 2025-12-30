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
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_roundstart_list_human, roundstart = TRUE)
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
	init_sprite_accessory_subtypes(/datum/sprite_accessory/psyphoza_cap, GLOB.psyphoza_cap_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_leaves, GLOB.diona_leaves_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_thorns, GLOB.diona_thorns_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_flowers, GLOB.diona_flowers_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_moss, GLOB.diona_moss_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_mushroom, GLOB.diona_mushroom_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_antennae, GLOB.diona_antennae_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_eyes, GLOB.diona_eyes_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/diona_pbody, GLOB.diona_pbody_list)


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
	init_keybindings()

	init_crafting_recipes()
	init_crafting_recipes_atoms()

	init_religion_sects()

/// Inits crafting recipe lists
/proc/init_crafting_recipes(list/crafting_recipes)
	for(var/path in subtypesof(/datum/crafting_recipe))
		if(ispath(path, /datum/crafting_recipe/stack))
			continue
		var/datum/crafting_recipe/recipe = new path()
		var/is_cooking = (recipe.category in GLOB.crafting_category_food)
		recipe.reqs = sort_list(recipe.reqs, GLOBAL_PROC_REF(cmp_crafting_req_priority))
		if(recipe.name != "" && recipe.result)
			if(is_cooking)
				GLOB.cooking_recipes += recipe
			else
				GLOB.crafting_recipes += recipe

	var/list/global_stack_recipes = list(
		/obj/item/stack/sheet/glass = GLOB.glass_recipes,
		/obj/item/stack/sheet/plasmaglass = GLOB.pglass_recipes,
		/obj/item/stack/sheet/rglass = GLOB.reinforced_glass_recipes,
		/obj/item/stack/sheet/plasmarglass = GLOB.prglass_recipes,
		/obj/item/stack/sheet/animalhide/gondola = GLOB.gondola_recipes,
		/obj/item/stack/sheet/animalhide/corgi = GLOB.corgi_recipes,
		/obj/item/stack/sheet/animalhide/monkey = GLOB.monkey_recipes,
		/obj/item/stack/sheet/animalhide/xeno = GLOB.xeno_recipes,
		/obj/item/stack/sheet/leather = GLOB.leather_recipes,
		/obj/item/stack/sheet/sinew = GLOB.sinew_recipes,
		//obj/item/stack/sheet/animalhide/carp = GLOB.carp_recipes,
		/obj/item/stack/sheet/mineral/sandstone = GLOB.sandstone_recipes,
		/obj/item/stack/sheet/sandbags = GLOB.sandbag_recipes,
		/obj/item/stack/sheet/mineral/diamond = GLOB.diamond_recipes,
		/obj/item/stack/sheet/mineral/uranium = GLOB.uranium_recipes,
		/obj/item/stack/sheet/mineral/plasma = GLOB.plasma_recipes,
		/obj/item/stack/sheet/mineral/gold = GLOB.gold_recipes,
		/obj/item/stack/sheet/mineral/silver = GLOB.silver_recipes,
		/obj/item/stack/sheet/mineral/copper = GLOB.copper_recipes,
		/obj/item/stack/sheet/mineral/bananium = GLOB.bananium_recipes,
		/obj/item/stack/sheet/mineral/titanium = GLOB.titanium_recipes,
		/obj/item/stack/sheet/mineral/plastitanium = GLOB.plastitanium_recipes,
		/obj/item/stack/sheet/snow = GLOB.snow_recipes,
		/obj/item/stack/sheet/mineral/adamantine = GLOB.adamantine_recipes,
		/obj/item/stack/sheet/mineral/abductor = GLOB.abductor_recipes,
		/obj/item/stack/sheet/iron = GLOB.metal_recipes,
		/obj/item/stack/sheet/plasteel = GLOB.plasteel_recipes,
		/obj/item/stack/sheet/wood = GLOB.wood_recipes,
		/obj/item/stack/sheet/bamboo = GLOB.bamboo_recipes,
		/obj/item/stack/sheet/cotton/cloth = GLOB.cloth_recipes,
		/obj/item/stack/sheet/cotton/cloth/durathread= GLOB.durathread_recipes,
		/obj/item/stack/sheet/cardboard = GLOB.cardboard_recipes,
		/obj/item/stack/sheet/bronze = GLOB.bronze_recipes,
		/obj/item/stack/sheet/plastic = GLOB.plastic_recipes,
		/obj/item/stack/ore/glass = GLOB.sand_recipes,
		/obj/item/stack/rods = GLOB.rod_recipes,
		/obj/item/stack/sheet/runed_metal = GLOB.runed_metal_recipes,
	)

	for(var/stack in global_stack_recipes)
		for(var/stack_recipe in global_stack_recipes[stack])
			if(istype(stack_recipe, /datum/stack_recipe_list))
				var/datum/stack_recipe_list/stack_recipe_list = stack_recipe
				for(var/nested_recipe in stack_recipe_list.recipes)
					if(!nested_recipe)
						continue
					var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(stack, nested_recipe)
					if(recipe.name != "" && recipe.result)
						GLOB.crafting_recipes += recipe
			else
				if(!stack_recipe)
					continue
				var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(stack, stack_recipe)
				if(recipe.name != "" && recipe.result)
					GLOB.crafting_recipes += recipe

	var/list/material_stack_recipes = list(
		//SSmaterials.base_stack_recipes,
		SSmaterials.rigid_stack_recipes,
	)

	for(var/list/recipe_list in material_stack_recipes)
		for(var/stack_recipe in recipe_list)
			var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(/obj/item/stack/sheet/iron, stack_recipe)
			recipe.steps = list("Use different materials in hand to make an item of that material")
			GLOB.crafting_recipes += recipe

/// Inits atoms used in crafting recipes
/proc/init_crafting_recipes_atoms()
	var/list/recipe_lists = list(
		GLOB.crafting_recipes,
		GLOB.cooking_recipes,
	)
	var/list/atom_lists = list(
		GLOB.crafting_recipes_atoms,
		GLOB.cooking_recipes_atoms,
	)

	for(var/list_index in 1 to length(recipe_lists))
		var/list/recipe_list = recipe_lists[list_index]
		var/list/atom_list = atom_lists[list_index]
		for(var/datum/crafting_recipe/recipe as anything in recipe_list)
			// Result
			atom_list |= recipe.result
			// Ingredients
			for(var/atom/req_atom as anything in recipe.reqs)
				atom_list |= req_atom
			// Catalysts
			for(var/atom/req_atom as anything in recipe.chem_catalysts)
				atom_list |= req_atom
			// Reaction data - required container
			if(recipe.reaction)
				var/required_container = initial(recipe.reaction.required_container)
				if(required_container)
					atom_list |= required_container
			// Tools
			for(var/atom/req_atom as anything in recipe.tool_paths)
				atom_list |= req_atom
			// Machinery
			for(var/atom/req_atom as anything in recipe.machinery)
				atom_list |= req_atom
			// Structures
			for(var/atom/req_atom as anything in recipe.structures)
				atom_list |= req_atom

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

/// Functions like init_subtypes, but uses the subtype's path as a key for easy access
/proc/init_subtypes_w_path_keys(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path as anything in subtypesof(prototype))
		L[path] = new path()
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
	/obj/item/storage/secure/safe,
	/obj/machinery/flasher,
	/obj/machinery/keycard_auth,
	/obj/structure/mirror,
	/obj/structure/fireaxecabinet,
	/obj/machinery/computer/security/telescreen/entertainment,
	/obj/structure/sign/picture_frame,
)))

// Wall mounted machinery which are visually coming out of the wall.
// These do not conflict with machinery which are visually placed on the wall.
GLOBAL_LIST_INIT(WALLITEMS_EXTERIOR, typecacheof(list(
	/obj/machinery/camera,
	/obj/structure/camera_assembly,
	/obj/structure/light_construct,
	/obj/machinery/light,
)))

GLOBAL_LIST_INIT(WALLITEMS_INVERSE, typecacheof(list(
	/obj/structure/light_construct,
	/obj/machinery/light,
)))

/proc/init_religion_sects()
	for(var/path in subtypesof(/datum/religion_sect))
		var/datum/religion_sect/each_sect = new path()
		GLOB.religion_sect_datums += each_sect
