/* This file contains standalone items for debug purposes. */

/obj/item/debug/human_spawner
	name = "human spawner"
	desc = "Spawn a human by aiming at a turf and clicking. Use in hand to change type."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "nothingwand"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/species/selected_species

/obj/item/debug/human_spawner/afterattack(atom/target, mob/user, proximity)
	..()
	if(isturf(target))
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(target)
		if(selected_species)
			H.set_species(selected_species)

/obj/item/debug/human_spawner/attack_self(mob/user)
	..()
	var/choice = input("Select a species", "Human Spawner", null) in GLOB.species_list
	selected_species = GLOB.species_list[choice]

/obj/item/debug/omnitool
	name = "omnitool"
	desc = "The original hypertool, born before them all. Use it in hand to unleash its true power."
	icon = 'icons/obj/device.dmi'
	icon_state = "hypertool"
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.1
	tool_behaviour = TOOL_SCREWDRIVER
	var/static/obj/item/stack/cable_coil/cable_coil
	var/static/obj/item/cultivator/cultivator
	var/static/obj/item/shovel/spade/spade
	var/static/list/abstract_tools

	var/list/available_selections = list(
		"Engineering tools" = list(
			TOOL_SCREWDRIVER,
			TOOL_WRENCH,
			TOOL_CROWBAR,
			TOOL_WIRECUTTER,
			TOOL_MULTITOOL,
			TOOL_WELDER,
			TOOL_ANALYZER,
			"wires"
		),
		"Medical tools" = list(
			"drapes",
			TOOL_SCALPEL,
			TOOL_HEMOSTAT,
			TOOL_RETRACTOR,
			TOOL_SAW,
			TOOL_CAUTERY,
			TOOL_DRILL,
			TOOL_BLOODFILTER
		),
		"Miscellaneous tools" = list(
			TOOL_MINING,
			TOOL_SHOVEL,
			"spade",
			"cultivator",
			TOOL_RUSTSCRAPER,
			TOOL_ROLLINGPIN,
			TOOL_BIKEHORN,
			"debug_placeholder"
		)
	)

/obj/item/debug/omnitool/Initialize(mapload)
	. = ..()

	if(!abstract_tools)
		abstract_tools = list()

		cable_coil = new
		abstract_tools += cable_coil
		cable_coil.max_amount = INFINITY
		cable_coil.amount = INFINITY

		cultivator = new
		abstract_tools += cultivator

		spade = new
		abstract_tools += spade

		for(var/obj/each in src.abstract_tools)
			each.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
			if(isitem(each))
				var/obj/item/I = each
				I.custom_materials = null // we don't want to feed lathe with these items

/obj/item/debug/omnitool/examine()
	. = ..()
	. += " The mode is: [tool_behaviour]"

/obj/item/debug/omnitool/pre_attack(atom/A, mob/living/user, params)
	switch(tool_behaviour)
		if("wires")
			cable_coil.melee_attack_chain(user, A, params)
			return
		if("cultivator")
			cultivator.melee_attack_chain(user, A, params)
			return
		if("spade")
			spade.melee_attack_chain(user, A, params)
			return
		if("debug_placeholder") // QoL. put anything you need.
			return
	. = ..()

/obj/item/debug/omnitool/attack(mob/living/M, mob/living/user)
	switch(tool_behaviour)
		if("drapes")
			attempt_initiate_surgery(src, M, user)
		if("debug_placeholder") // QoL. put anything you need. - pre_attack() is preffered.
			pass()
	. = ..()

/obj/item/debug/omnitool/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ToolSelection")
		ui.open()

/obj/item/debug/omnitool/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/tools)
	)

/obj/item/debug/omnitool/ui_data(mob/user)
	var/list/data = list()
	. = data

	data["selections"] = available_selections

/obj/item/debug/omnitool/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_selection")
			var/tool = params["chosen_selection"]
			if(!(tool in available_selections[params["chosen_category"]]))
				return
			tool_behaviour = tool
			to_chat(usr, span_notice("Tool behaviour of [src] is now [tool_behaviour]"))
			return

/obj/item/construction/rcd/arcd/debug
	name = "\improper CentCom Admin RCD"
	icon_state = "ircd"
	item_state = "ircd"
	w_class = WEIGHT_CLASS_TINY
	max_matter = INFINITY
	matter = INFINITY
	delay_mod = 0.1
	ranged = TRUE
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING
	canRturf = TRUE

/obj/item/construction/rld/debug
	name = "\improper CentCom Admin RLD"
	w_class = WEIGHT_CLASS_TINY
	max_matter = INFINITY
	matter = INFINITY
	walldelay = 0.1
	floordelay = 0.1
	decondelay = 0.1

/obj/item/holosign_creator/atmos/debug
	name = "\improper CentCom ATMOS holofan projector"
	w_class = WEIGHT_CLASS_TINY
	max_signs = 999
	ranged = TRUE

/obj/item/pipe_dispenser/debug
	name= "\improper CentCom Rapid Pipe Dispenser (RPD)"
	w_class = WEIGHT_CLASS_TINY
	atmos_build_speed = 0.1
	disposal_build_speed = 0.1
	transit_build_speed = 0.1
	upgrade_flags = RPD_UPGRADE_UNWRENCH

//Debug suit
/obj/item/clothing/head/helmet/space/hardsuit/debug
	name = "\improper Central Command black hardsuit helmet"
	desc = "very powerful."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	armor_type = /datum/armor/hardsuit_debug
	strip_delay = 6000
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	geiger_counter = FALSE


/datum/armor/hardsuit_debug
	melee = 300
	bullet = 300
	laser = 300
	energy = 300
	bomb = 300
	bio = 300
	rad = 300
	fire = 300
	acid = 300
	stamina = 300

/obj/item/clothing/suit/space/hardsuit/debug
	name = "\improper Central Command black hardsuit"
	desc = "very powerful."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	w_class = WEIGHT_CLASS_TINY
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/debug
	armor_type = /datum/armor/hardsuit_debug
	gas_transfer_coefficient = 0
	siemens_coefficient = 0
	slowdown = -1
	equip_delay_other = 6000 // stripping an admin for 10 minutes
	cold_protection = FULL_BODY
	heat_protection = FULL_BODY
	body_parts_covered = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


// debug bag

/obj/item/storage/backpack/debug
	name = "bag of portable hole"
	desc = "A backpack that opens into a localized pocket of nullspace."
	icon_state = "holdingpack"
	item_state = "holdingpack"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = NO_MAT_REDEMPTION
	armor_type = /datum/armor/backpack_debug


/datum/armor/backpack_debug
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	rad = 100
	fire = 100
	acid = 100

/obj/item/storage/backpack/debug/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/rad_insulation, _amount = RAD_FULL_INSULATION, contamination_proof = TRUE) //please datum mats no more cancer
	atom_storage.allow_big_nesting = TRUE
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC
	atom_storage.max_slots = 1000
	atom_storage.max_total_storage = 1000

/obj/item/storage/box/debugtools
	name = "box of debug tools"
	icon_state = "syndiebox"
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/box/debugtools/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 1000
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC
	atom_storage.max_slots = 1000
	atom_storage.allow_big_nesting = TRUE

/obj/item/storage/box/debugtools/PopulateContents()
	var/static/items_inside = list(
		/obj/item/flashlight/emp/debug=1,
		/obj/item/modular_computer/tablet/pda=1,
		/obj/item/modular_computer/tablet/preset/advanced=1,
		/obj/item/storage/belt/military/abductor/full=1,
		/obj/item/geiger_counter=1,
		/obj/item/holosign_creator/atmos/debug=1,
		/obj/item/pipe_dispenser/debug=1,
		/obj/item/construction/rcd/arcd/debug=1,
		/obj/item/construction/rld/debug=1,
		/obj/item/areaeditor/blueprints=1,
		/obj/item/card/emag=1,
		/obj/item/storage/belt/medical/ert=1,
		/obj/item/disk/tech_disk/debug=1,
		/obj/item/disk/surgery/debug=1,
		/obj/item/disk/data/debug=1,
		/obj/item/uplink/debug=1,
		/obj/item/uplink/nuclear/debug=1,
		/obj/item/storage/box/beakers/bluespace=1,
		/obj/item/storage/box/beakers/variety=1,
		/obj/item/storage/box/material=1
	)
	generate_items_inside(items_inside,src)

/obj/item/debug/orb_of_power
	name = "\improper Orb of Power"
	desc = "grants incredible power to its owner."
	icon = 'icons/obj/device.dmi'
	icon_state = "sp_green"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/traits_to_give = list(
		TRAIT_MADNESS_IMMUNE,
		TRAIT_FEARLESS,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_CONFUSEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NODISMEMBER,
		TRAIT_NOLIMBDISABLE,
		TRAIT_XENO_IMMUNE,
		TRAIT_NOFIRE,
		TRAIT_TOXIMMUNE,
		TRAIT_NOCLONELOSS,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOSLIPALL,
		TRAIT_NOHUNGER,
		TRAIT_NOVOMIT,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_SELF_AWARE,
		TRAIT_SIXTHSENSE,
		TRAIT_XRAY_VISION,
		TRAIT_MEDICAL_HUD,
		TRAIT_SECURITY_HUD,
		TRAIT_BARMASTER,
		TRAIT_SURGEON,
		TRAIT_METALANGUAGE_KEY_ALLOWED
	)
	var/spacewalk_initial

/obj/item/debug/orb_of_power/pickup(mob/user)
	. = ..()
	for(var/each in traits_to_give)
		ADD_TRAIT(user, each, "debug")
	grant_all_languages(source = "debug")
	user.grant_language(/datum/language/metalanguage, source = "debug")

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	hud.add_hud_to(user)
	hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	hud.add_hud_to(user)
	hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	hud.add_hud_to(user)

	if(!isliving(user))
		user.update_sight()
		return
	var/mob/living/picker = user
	picker.see_override = SEE_INVISIBLE_OBSERVER
	picker.update_sight()

	spacewalk_initial = user.spacewalk
	user.spacewalk = TRUE

/obj/item/debug/orb_of_power/dropped(mob/living/carbon/human/user)
	. = ..()
	var/obj/item/debug/orb_of_power/orb = locate() in user.get_contents()
	if(orb)
		return

	user.spacewalk = spacewalk_initial

	for(var/each in traits_to_give)
		REMOVE_TRAIT(user, each, "debug")
	user.remove_all_languages("debug")
	user.remove_language(/datum/language/metalanguage, TRUE, TRUE, "debug")
	user.see_override = initial(user.see_override)
	user.update_sight()

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
	hud.remove_hud_from(user)
	if(!HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
		hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		hud.remove_hud_from(user)
	if(!HAS_TRAIT(user, TRAIT_SECURITY_HUD))
		hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
		hud.remove_hud_from(user)

// kinda works like hilbert, but not really
/obj/item/map_template_diver
	name = "Pseudo-world diver"
	desc = "A globe that you can dive into a pseudo-world, but there's no way back."
	icon_state = "hilbertshotel"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/datum/map_template/map_template = /datum/map_template/debug_target
	var/working
	var/turf/turf_to_dive

	var/live_server_warning

/datum/map_template/debug_target
	name = "Debug map to test"
	mappath = '_maps/map_files/debug/multidir_sprite_debug.dmm'

// friendly warning setter
/obj/item/map_template_diver/Initialize(mapload)
	. = ..()
#ifndef DEBUG
	live_server_warning = TRUE
#endif

/obj/item/map_template_diver/attack_self(mob/user)
	. = ..()

	if(turf_to_dive)
		dive_into(user)
		return

	if(!check_rights_for(user.client, R_ADMIN | R_DEBUG))
		client_alert(user.client, "Players are not allowed to use this debug item, even for fun.", "No permission, no fun")
		return
	if(live_server_warning)
		client_alert(user.client, "It looks the server is actually live. Using this may cost the performance of the server. Use this again if you're sure.", "Warning")
		live_server_warning = FALSE
		return

	if(working)
		to_chat(user, span_notice("We're creating a map yet."))
		return

	if(ispath(map_template))
		create_map(user)
		return

/obj/item/map_template_diver/proc/create_map(mob/user)
	set waitfor = FALSE

	to_chat(user, span_notice("Creates a map template..."))
	working = TRUE
	map_template = new map_template()
	var/datum/space_level/space_level = map_template.load_new_z(null, ZTRAITS_DEBUG)
	turf_to_dive = locate(round((world.maxx - map_template.width)/2), round((world.maxy - map_template.height)/2), space_level.z_value)
	to_chat(user, span_notice("Creation is completed."))
	working = FALSE
	dive_into(user)

/obj/item/map_template_diver/proc/dive_into(mob/user)
	to_chat(user, span_notice("Teleports to the test area."))
	user.forceMove(turf_to_dive)
