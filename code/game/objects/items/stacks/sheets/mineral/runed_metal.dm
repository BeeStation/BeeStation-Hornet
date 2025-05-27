// Note, the order these in are deliberate, as it affects
// the order they are shown via radial.
GLOBAL_LIST_INIT(runed_metal_recipes, list( \
	new /datum/stack_recipe/radial( \
		title = "pylon", \
		result_type = /obj/structure/destructible/cult/pylon, \
		req_amount = 4, \
		time = 4 SECONDS, \
		one_per_turf = TRUE, \
		on_floor = TRUE, \
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
		one_per_turf = TRUE, \
		on_floor = TRUE, \
		desc = span_cultbold("Altar: Can make Eldritch Whetstones, Construct Shells, and Flasks of Unholy Water."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "archives", \
		result_type = /obj/structure/destructible/cult/tome, \
		req_amount = 3, \
		time = 4 SECONDS, \
		one_per_turf = TRUE, \
		on_floor = TRUE, \
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
		one_per_turf = TRUE, \
		on_floor = TRUE, \
		desc = span_cultbold("Daemon Forge: Can make Nar'Sien Hardened Armor, Flagellant's Robes, \
			and Eldritch Longswords. Emits Light."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "runed door", \
		result_type = /obj/machinery/door/airlock/cult, \
		time = 5 SECONDS, \
		one_per_turf = TRUE, \
		on_floor = TRUE, \
		desc = span_cultbold("Runed Door: A weak door which stuns non-blood cultists who touch it."), \
		required_noun = "runed metal sheet", \
		category = CAT_CULT, \
	), \
	new /datum/stack_recipe/radial( \
		title = "runed girder", \
		result_type = /obj/structure/girder/cult, \
		time = 5 SECONDS, \
		one_per_turf = TRUE, \
		on_floor = TRUE, \
		desc = span_cultbold("Runed Girder: A weak girder that can be instantly destroyed by ritual daggers. Not a recommended usage of runed metal."), \
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
	item_state = "sheet-runed"
	//icon = 'icons/obj/stacks/mineral.dmi'
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal
	novariants = TRUE
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/blood = 15)
	use_radial = TRUE

/obj/item/stack/sheet/runed_metal/ratvar_act()
	new /obj/item/stack/sheet/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/runed_metal/attack_self(mob/living/user)
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("Only one with forbidden knowledge could hope to work this metal..."))
		return

	var/turf/T = get_turf(user) //we may have moved. adjust as needed...
	var/area/A = get_area(user)

	if((!is_station_level(T.z) && !is_mining_level(T.z)) || (A && !(A.area_flags & (BLOBS_ALLOWED | VALID_TERRITORY))))
		to_chat(user, span_warning("The veil is not weak enough here."))
		return FALSE

	return ..()

/obj/item/stack/sheet/runed_metal/radial_check(mob/builder)
	return ..() && IS_CULTIST(builder)

/obj/item/stack/sheet/runed_metal/get_recipes()
	return GLOB.runed_metal_recipes

STACKSIZE_MACRO(/obj/item/stack/sheet/runed_metal)
