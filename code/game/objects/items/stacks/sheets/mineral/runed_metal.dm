// Note, the order these in are deliberate, as it affects
// the order they are shown via radial.
GLOBAL_LIST_INIT(runed_metal_recipes, list( \
	new /datum/stack_recipe/radial( \
		title = "pylon", \
		result_type = /obj/structure/destructible/cult/pylon, \
		req_amount = 4, \
		time = 4 SECONDS, \
		crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, \
		desc = span_cultbold("Pylon: Heals and regenerates the blood of nearby blood cultists and constructs, and also \
			converts nearby floor tiles into engraved flooring, which allows blood cultists to scribe runes faster."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "altar", \
		result_type = /obj/structure/destructible/cult/talisman, \
		req_amount = 3, \
		time = 4 SECONDS, \
		crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, \
		desc = span_cultbold("Altar: Can make Eldritch Whetstones, Construct Shells, and Flasks of Unholy Water."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "archives", \
		result_type = /obj/structure/destructible/cult/tome, \
		req_amount = 3, \
		time = 4 SECONDS, \
		crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, \
		desc = span_cultbold("Archives: Can make Zealot's Blindfolds, Shuttle Curse Orbs, \
			and Veil Walker equipment. Emits Light."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "daemon forge", \
		result_type = /obj/structure/destructible/cult/forge, \
		req_amount = 3, \
		time = 4 SECONDS, \
		crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, \
		desc = span_cultbold("Daemon Forge: Can make Nar'Sien Hardened Armor, Flagellant's Robes, \
			and Eldritch Longswords. Emits Light."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "runed door", \
		result_type = /obj/machinery/door/airlock/cult, \
		time = 5 SECONDS, \
		crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, \
		desc = span_cultbold("Runed Door: A weak door which stuns non-blood cultists who touch it."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "runed girder", \
		result_type = /obj/structure/girder/cult, \
		time = 5 SECONDS, \
		crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, \
		desc = span_cultbold("Runed Girder: A weak girder that can be instantly destroyed by ritual daggers. \
			Not a recommended usage of runed metal."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
))

/* Runed Metal */

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of cold metal with shifting inscriptions writ upon them."
	singular_name = "runed metal sheet"
	icon_state = "sheet-runed"
	inhand_icon_state = "sheet-runed"
	//icon = 'icons/obj/stacks/mineral.dmi'
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/blood = 15)
	//material_type = /datum/material/runedmetal
	has_unique_girder = TRUE
	use_radial = TRUE

/obj/item/stack/sheet/runed_metal/ratvar_act()
	new /obj/item/stack/sheet/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/runed_metal/attack_self(mob/user)
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("Only one with forbidden knowledge could hope to work this metal..."))
		return FALSE

	var/turf/user_turf = get_turf(user)
	var/area/user_area = get_area(user)

	var/is_valid_turf = user_turf && (is_station_level(user_turf.z) || is_mining_level(user_turf.z))
	var/is_valid_area = user_area && (user_area.area_flags & (BLOBS_ALLOWED | VALID_TERRITORY))

	if(!is_valid_turf || !is_valid_area)
		to_chat(user, span_warning("The veil is not weak enough here."))
		return FALSE

	return ..()

/obj/item/stack/sheet/runed_metal/radial_check(mob/builder)
	return ..() && IS_CULTIST(builder)

/obj/item/stack/sheet/runed_metal/get_recipes()
	return GLOB.runed_metal_recipes

STACKSIZE_MACRO(/obj/item/stack/sheet/runed_metal)
