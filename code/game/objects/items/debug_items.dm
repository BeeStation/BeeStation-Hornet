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
		get_asset_datum(/datum/asset/spritesheet/tools)
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
			to_chat(usr, "<span class='notice'>Tool behaviour of [src] is now [tool_behaviour]</span>")
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
	plumbing_build_speed = 0.1
	destroy_speed = 0.1
	paint_speed = 0.1
	ranged = TRUE
	upgrade_flags = RPD_UPGRADE_UNWRENCH

/obj/item/spellbook/debug
	name = "\improper Robehator's spell book"
	uses = 200
	everything_robeless = TRUE
	bypass_lock = TRUE

//Debug suit
/obj/item/clothing/head/helmet/space/hardsuit/debug
	name = "\improper Central Command black hardsuit helmet"
	desc = "very powerful."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	armor = list(MELEE = 300,  BULLET = 300, LASER = 300, ENERGY = 300, BOMB = 300, BIO = 300, RAD = 300, FIRE = 300, ACID = 300, STAMINA = 300) // prevent armor penetration
	strip_delay = 6000
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/debug
	name = "\improper Central Command black hardsuit"
	desc = "very powerful."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	w_class = WEIGHT_CLASS_TINY
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/debug
	armor = list(MELEE = 300,  BULLET = 300, LASER = 300, ENERGY = 300, BOMB = 300, BIO = 300, RAD = 300, FIRE = 300, ACID = 300, STAMINA = 300) // prevent armor penetration
	gas_transfer_coefficient = 0
	permeability_coefficient = 0
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
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 0)

/obj/item/storage/backpack/debug/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_big_nesting = TRUE
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC
	STR.max_items = 1000
	STR.max_combined_w_class = 1000

/obj/item/storage/box/debugtools
	name = "box of debug tools"
	icon_state = "syndiebox"
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/box/debugtools/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 1000
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC
	STR.max_items = 1000
	STR.allow_big_nesting = TRUE

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
		/obj/item/spellbook/debug=1,
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

/obj/item/debug/orb_of_power/pickup(mob/user)
	. = ..()
	for(var/each in traits_to_give)
		ADD_TRAIT(user, each, "debug")
	user.grant_all_languages(TRUE, TRUE, TRUE, "debug")
	user.grant_language(/datum/language/metalanguage, TRUE, TRUE, "debug")

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


/obj/item/debug/orb_of_power/dropped(mob/living/carbon/human/user)
	. = ..()
	var/obj/item/debug/orb_of_power/orb = locate() in user.get_contents()
	if(orb)
		return
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
