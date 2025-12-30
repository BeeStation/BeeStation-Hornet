/// How much damage you take from an emp when wearing a hardsuit
#define HARDSUIT_EMP_BURN 2 // a very orange number

//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon = 'icons/obj/clothing/head/hardsuit.dmi'
	worn_icon = 'icons/mob/clothing/head/hardsuit.dmi'
	icon_state = "hardsuit0-engineering"
	inhand_icon_state = "eng_helm"
	max_integrity = 300
	armor_type = /datum/armor/space_hardsuit
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 1
	light_on = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR | HIDEFACIALHAIR
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | HEADINTERNALS

	/// Whether or not this hardsuit has a geiger counter installed
	var/geiger_counter = FALSE

	/// If the headlamp is broken, used by lighteater
	var/light_broken = FALSE

	var/basestate = "hardsuit"
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit
	var/hardsuit_type = "engineering" //Determines used sprites: hardsuit[on]-[type]

/datum/armor/space_hardsuit
	melee = 10
	bullet = 5
	laser = 10
	energy = 15
	bomb = 10
	bio = 100
	fire = 50
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/Initialize(mapload)
	. = ..()
	if(geiger_counter)
		AddComponent(/datum/component/geiger_sound)

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	// Move to nullspace first to prevent qdel loops
	moveToNullspace()
	if(!QDELETED(suit))
		qdel(suit)
	suit = null

	if(geiger_counter)
		qdel(GetComponent(/datum/component/geiger_sound))
	. = ..()

/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	if(light_broken)
		to_chat(user, span_notice("The headlamp has been burnt out... Looks like there's no replacing it."))
		on = FALSE
	else
		on = !on
	icon_state = "[basestate][on]-[hardsuit_type]"
	user?.update_worn_head()	//so our mob-overlays update

	set_light_on(on)

	update_action_buttons()

/obj/item/clothing/head/helmet/space/hardsuit/dropped(mob/user)
	..()
	suit?.RemoveHelmet()

/obj/item/clothing/head/helmet/space/hardsuit/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_HEAD)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_HEAD)
		if(suit)
			suit.RemoveHelmet()
		else
			qdel(src)

/obj/item/clothing/head/helmet/space/hardsuit/proc/toggle_hud(mob/user)
	var/datum/component/team_monitor/worn/monitor = GetComponent(/datum/component/team_monitor/worn)
	if(!monitor)
		to_chat(user, span_notice("The suit is not fitted with a tracking beacon."))
		return
	monitor.toggle_hud(!monitor.hud_visible, user)
	if(monitor.hud_visible)
		to_chat(user, span_notice("You toggle the heads up display of your suit."))
	else
		to_chat(user, span_warning("You disable the heads up display of your suit."))

/obj/item/clothing/head/helmet/space/hardsuit/proc/display_visor_message(msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message("[icon2html(src, wearer)]<b>[span_robot("[msg]")]</b>", MSG_VISUAL)

/obj/item/clothing/head/helmet/space/hardsuit/emp_act(severity)
	. = ..()
	display_visor_message("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!")

/obj/item/clothing/head/helmet/space/hardsuit/ui_action_click(mob/user, datum/action)
	switch(action.type)
		if(/datum/action/item_action/toggle_beacon_hud)
			toggle_hud(user)
			return
	. = ..()

/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon = 'icons/obj/clothing/suits/hardsuit.dmi'
	worn_icon = 'icons/mob/clothing/suits/hardsuit.dmi'
	icon_state = "hardsuit-engineering"
	inhand_icon_state = "eng_hardsuit"
	max_integrity = 300
	armor_type = /datum/armor/space_hardsuit
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(
		/datum/action/item_action/toggle_spacesuit,
		/datum/action/item_action/toggle_helmet
	)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/tank/jetpack/suit/jetpack = null
	var/hardsuit_type
	/// Whether the helmet is on.
	var/helmet_on = FALSE


/datum/armor/space_hardsuit
	melee = 10
	bullet = 5
	laser = 10
	energy = 15
	bomb = 10
	bio = 100
	fire = 50
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)
	. = ..()

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/examine(mob/user)
	. = ..()
	if(!helmet && helmettype)
		. += span_notice(" The helmet on [src] seems to be malfunctioning. It's light bulb needs to be replaced.")

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, span_warning("[src] already has a jetpack installed."))
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, span_warning("You cannot install the upgrade to [src] while wearing it."))
			return

		if(user.transferItemToLoc(I, src))
			jetpack = I
			to_chat(user, span_notice("You successfully install the jetpack into [src]."))
			return
	else if(!cell_cover_open && I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!jetpack)
			to_chat(user, span_warning("[src] has no jetpack installed."))
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
			to_chat(user, span_warning("You cannot remove the jetpack from [src] while wearing it."))
			return

		jetpack.turn_off(user)
		jetpack.forceMove(drop_location())
		jetpack = null
		to_chat(user, span_notice("You successfully remove the jetpack from [src]."))
		return
	else if(istype(I, /obj/item/light) && helmettype)
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
			to_chat(user, span_warning("You cannot replace the bulb in the helmet of [src] while wearing it."))
			return
		if(helmet)
			to_chat(user, span_warning("The helmet of [src] does not require a new bulb."))
			return
		var/obj/item/light/L = I
		if(L.status)
			to_chat(user, span_warning("This bulb is too damaged to use as a replacement!"))
			return
		if(do_after(user, 5 SECONDS, 1, src))
			qdel(I)
			helmet = new helmettype(src)
			to_chat(user, span_notice("You have successfully repaired [src]'s helmet."))
			new /obj/item/light/bulb/broken(drop_location())
	return ..()


/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(isatom(jetpack))
		if(slot == ITEM_SLOT_OCLOTHING)
			jetpack.update_known_user(user)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	if(isatom(jetpack))
		jetpack.turn_off()
		jetpack.lose_known_user()
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/ui_action_click(mob/user, datum/actiontype)
	switch(actiontype.type)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
			return
		if(/datum/action/item_action/toggle_beacon)
			toggle_beacon(user)
			return
		if(/datum/action/item_action/toggle_beacon_frequency)
			set_beacon_freq(user)
			return
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/toggle_beacon(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, span_notice("The suit is not fitted with a tracking beacon."))
		return
	beacon.toggle_visibility(!beacon.visible)
	if(beacon.visible)
		to_chat(user, span_notice("You enable the tracking beacon on [src]. Anybody on the same frequency will now be able to track your location."))
	else
		to_chat(user, span_warning("You disable the tracking beacon on [src]."))

/obj/item/clothing/suit/space/hardsuit/proc/set_beacon_freq(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, span_notice("The suit is not fitted with a tracking beacon."))
		return
	beacon.change_frequency(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_OCLOTHING) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return 1

/// Burn the person inside the hard suit just a little, the suit got really hot for a moment
/obj/item/clothing/suit/space/emp_act(severity)
	. = ..()
	var/mob/living/carbon/human/user = src.loc
	if(istype(user))
		user.apply_damage(HARDSUIT_EMP_BURN, BURN)
		to_chat(user, span_warning("You feel \the [src] heat up from the EMP burning you slightly."))

		// Chance to scream
		if (user.stat < UNCONSCIOUS && prob(10))
			user.emote("scream")

	//Engineering
/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	inhand_icon_state = "eng_helm"
	armor_type = /datum/armor/hardsuit_engine
	hardsuit_type = "engineering"
	resistance_flags = FIRE_PROOF


/datum/armor/hardsuit_engine
	melee = 30
	bullet = 5
	laser = 20
	energy = 20
	bomb = 10
	bio = 100
	fire = 100
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	inhand_icon_state = "eng_hardsuit"
	armor_type = /datum/armor/hardsuit_engine
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	resistance_flags = FIRE_PROOF

	//Atmospherics

/datum/armor/hardsuit_engine
	melee = 30
	bullet = 5
	laser = 10
	energy = 15
	bomb = 10
	bio = 100
	fire = 100
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	icon_state = "hardsuit0-atmospherics"
	inhand_icon_state = "atmo_helm"
	hardsuit_type = "atmospherics"
	armor_type = /datum/armor/engine_atmos
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT


/datum/armor/engine_atmos
	melee = 30
	bullet = 5
	laser = 10
	energy = 15
	bomb = 10
	bio = 100
	fire = 100
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding."
	icon_state = "hardsuit-atmospherics"
	inhand_icon_state = "atmo_hardsuit"
	armor_type = /datum/armor/engine_atmos
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner,
		/obj/item/construction/rcd, /obj/item/pipe_dispenser, /obj/item/extinguisher)


	//Chief Engineer's hardsuit

/datum/armor/engine_atmos
	melee = 30
	bullet = 5
	laser = 10
	energy = 15
	bomb = 10
	bio = 100
	fire = 100
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	inhand_icon_state = "ce_helm"
	hardsuit_type = "white"
	armor_type = /datum/armor/engine_elite
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT


/datum/armor/engine_elite
	melee = 40
	bullet = 5
	laser = 20
	energy = 15
	bomb = 50
	bio = 100
	fire = 100
	acid = 90
	stamina = 30
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/engine/elite
	icon_state = "hardsuit-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	inhand_icon_state = "ce_hardsuit"
	armor_type = /datum/armor/engine_elite
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/upgraded/plus

	//Mining hardsuit

/datum/armor/engine_elite
	melee = 40
	bullet = 5
	laser = 10
	energy = 20
	bomb = 50
	bio = 100
	fire = 100
	acid = 90
	stamina = 30
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating for wildlife encounters and dual floodlights."
	icon_state = "hardsuit0-mining"
	inhand_icon_state = "mining_helm"
	hardsuit_type = "mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	heat_protection = HEAD
	armor_type = /datum/armor/hardsuit_mining
	light_range = 7
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/recharge/kinetic_accelerator)
	high_pressure_multiplier = 0.6


/datum/armor/hardsuit_mining
	melee = 30
	bullet = 5
	laser = 10
	energy = 15
	bomb = 50
	bio = 100
	fire = 50
	acid = 75
	stamina = 40
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/suit/space/hardsuit/mining
	icon_state = "hardsuit-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating for wildlife encounters."
	inhand_icon_state = "mining_hardsuit"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	supports_variations = DIGITIGRADE_VARIATION
	armor_type = /datum/armor/hardsuit_mining
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	high_pressure_multiplier = 0.6


/datum/armor/hardsuit_mining
	melee = 30
	bullet = 5
	laser = 10
	energy = 20
	bomb = 50
	bio = 100
	fire = 50
	acid = 75
	stamina = 40
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

	//Exploration hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/exploration
	name = "exploration hardsuit helmet"
	desc = "An advanced space-proof hardsuit designed to protect against off-station threats."
	icon_state = "hardsuit0-exploration"
	inhand_icon_state = "death_commando_mask"
	hardsuit_type = "exploration"
	heat_protection = HEAD
	armor_type = /datum/armor/hardsuit_exploration
	light_range = 6
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/recharge/kinetic_accelerator)
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_beacon_hud/explorer
		)


/datum/armor/hardsuit_exploration
	melee = 35
	bullet = 15
	laser = 20
	energy = 10
	bomb = 50
	bio = 100
	fire = 50
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/exploration/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/team_monitor/worn, EXPLORATION_TRACKING, -1)

/obj/item/clothing/head/helmet/space/hardsuit/exploration/ui_action_click(mob/user, datum/action)
	switch(action.type)
		if(/datum/action/item_action/toggle_beacon_hud/explorer)
			toggle_hud(user)
			return
	. = ..()

/obj/item/clothing/suit/space/hardsuit/exploration
	icon_state = "hardsuit-exploration"
	name = "exploration hardsuit"
	desc = "An advanced space-proof hardsuit designed to protect against off-station threats. Despite looking remarkably similar to the mining hardsuit \
		Nanotrasen officials note that it is unique in every way and the design has not been copied in any way."
	inhand_icon_state = "exploration_hardsuit"
	armor_type = /datum/armor/hardsuit_exploration
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe, /obj/item/gun/ballistic/rifle/leveraction/exploration, /obj/item/gun/energy/laser/repeater/explorer)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/exploration
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

	//Syndicate hardsuit

/datum/armor/hardsuit_cybersun
	melee = 30
	bullet = 35
	laser = 15
	energy = 15
	bomb = 60
	bio = 100
	fire = 30
	acid = 60
	stamina = 15
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/hardsuit_syndi
	on = TRUE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(
		/datum/action/item_action/toggle_helmet_mode,
		/datum/action/item_action/toggle_beacon_hud
	)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEEARS|HIDESNOUT
	visor_flags = STOPSPRESSUREDAMAGE | HEADINTERNALS
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL

/datum/armor/hardsuit_syndi
	melee = 40
	bullet = 50
	laser = 30
	energy = 55
	bomb = 35
	bio = 100
	fire = 50
	acid = 100
	stamina = 60
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon()
	icon_state = "hardsuit[on]-[hardsuit_type]"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/Initialize(mapload)
	. = ..()
	//Link
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/syndi))
		linkedsuit = loc
		//NOTE FOR COPY AND PASTING: BEACON MUST BE MADE FIRST
		//Add the monitor (Default to null - No tracking)
		var/datum/component/tracking_beacon/component_beacon = linkedsuit.AddComponent(/datum/component/tracking_beacon, "synd", null, null, TRUE, "#8f4a4b", FALSE, FALSE, "#573d3d")
		//Add the monitor (Default to null - No tracking)
		component_beacon.attached_monitor = AddComponent(/datum/component/team_monitor/worn, "synd", null, component_beacon)
	else
		AddComponent(/datum/component/team_monitor/worn, "synd", -1)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/ui_action_click(mob/user, datum/action)
	switch(action.type)
		if(/datum/action/item_action/toggle_helmet_mode)
			attack_self(user)
			return
	. = ..()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, span_warning("You cannot toggle your helmet while in this [user.loc]!") )
		return
	on = !on
	if(on || force)
		to_chat(user, span_notice("You switch your hardsuit to EVA mode, sacrificing speed for space protection."))
		activate_space_mode()
	else
		to_chat(user, span_notice("You switch your hardsuit to combat mode and can now run at full speed."))
		activate_combat_mode()
	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	toggle_hardsuit_mode(user)
	user.update_worn_head()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	update_action_buttons()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/toggle_hardsuit_mode(mob/user) //Helmet Toggles Suit Mode
	if(linkedsuit)
		linkedsuit.icon_state = "hardsuit[on]-[hardsuit_type]"
		linkedsuit.update_icon()
		if(on)
			linkedsuit.activate_space_mode()
		else
			linkedsuit.activate_combat_mode()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/activate_space_mode()
	name = initial(name)
	desc = initial(desc)
	set_light_on(TRUE)
	clothing_flags |= visor_flags
	flags_cover |= HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv |= visor_flags_inv
	cold_protection |= HEAD
	on = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/activate_combat_mode()
	name = "[initial(name)] (combat)"
	desc = alt_desc
	set_light_on(FALSE)
	clothing_flags &= ~visor_flags
	flags_cover &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
	flags_inv &= ~visor_flags_inv
	cold_protection &= ~HEAD
	on = FALSE

/obj/item/clothing/suit/space/hardsuit/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = ACID_PROOF
	supports_variations = DIGITIGRADE_VARIATION
	armor_type = /datum/armor/hardsuit_syndi
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/super
	item_flags = ILLEGAL	//Syndicate only and difficult to obtain outside of uplink anyway. Nukie hardsuits on the ship are illegal.
	slowdown = 0.5
	actions_types = list(
		/datum/action/item_action/toggle_spacesuit,
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL

/obj/item/clothing/suit/space/hardsuit/syndi/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

/obj/item/clothing/suit/space/hardsuit/syndi/RemoveHelmet()
	. = ..()
	//Update helmet to non combat mode
	var/obj/item/clothing/head/helmet/space/hardsuit/syndi/syndieHelmet = helmet
	if(!syndieHelmet)
		return
	syndieHelmet.activate_combat_mode()
	syndieHelmet.update_icon()
	for(var/X in syndieHelmet.actions)
		var/datum/action/A = X
		A.update_buttons()
	//Update the icon_state first
	icon_state = "hardsuit[syndieHelmet.on]-[syndieHelmet.hardsuit_type]"
	update_icon()
	//Actually apply the non-combat mode to suit and update the suit overlay
	activate_combat_mode()

/obj/item/clothing/suit/space/hardsuit/syndi/proc/activate_space_mode()
	name = initial(name)
	desc = initial(desc)
	slowdown = 0.5
	clothing_flags |= STOPSPRESSUREDAMAGE
	cold_protection |= CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	if(ishuman(loc))
		var/mob/living/carbon/H = loc
		H.update_equipment_speed_mods()
		H.update_worn_oversuit()
		H.update_worn_undersuit()

/obj/item/clothing/suit/space/hardsuit/syndi/proc/activate_combat_mode()
	name = "[initial(name)] (combat)"
	desc = alt_desc
	slowdown = 0
	clothing_flags &= ~STOPSPRESSUREDAMAGE
	cold_protection &= ~(CHEST | GROIN | LEGS | FEET | ARMS | HANDS)
	if(ishuman(loc))
		var/mob/living/carbon/H = loc
		H.update_equipment_speed_mods()
		H.update_worn_oversuit()
		H.update_worn_undersuit()

//Stupid snowflake type so we dont freak out the spritesheets. Its not actually used ingame
/obj/item/clothing/suit/space/hardsuit/syndipreview
	name = "blood-red hardsuit"
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	cell = null
	show_hud = FALSE

//Elite Syndie suit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fireproofing. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "An elite version of the syndicate helmet, with improved armour and fireproofing. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	armor_type = /datum/armor/syndi_elite
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL

/datum/armor/syndi_elite
	melee = 60
	bullet = 60
	laser = 50
	energy = 80
	bomb = 55
	bio = 100
	fire = 100
	acid = 100
	stamina = 80
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in travel mode."
	alt_desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in combat mode."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor_type = /datum/armor/syndi_elite
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	cell = /obj/item/stock_parts/cell/bluespace
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL

//The Owl Hardsuit

/datum/armor/syndi_elite
	melee = 60
	bullet = 60
	laser = 50
	energy = 80
	bomb = 55
	bio = 100
	fire = 100
	acid = 100
	stamina = 80
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/syndi/owl
	name = "owl hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	inhand_icon_state = "s_helmet"
	hardsuit_type = "owl"
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE

/obj/item/clothing/suit/space/hardsuit/syndi/owl
	name = "owl hardsuit"
	desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	inhand_icon_state = "s_suit"
	hardsuit_type = "owl"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/owl


	//Wizard hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "hardsuit0-wiz"
	inhand_icon_state = "wiz_helm"
	hardsuit_type = "wiz"
	resistance_flags = FIRE_PROOF | ACID_PROOF //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor_type = /datum/armor/hardsuit_wizard
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	clothing_flags = CASTING_CLOTHES | NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/wizard
	icon_state = "hardsuit-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	inhand_icon_state = "wiz_hardsuit"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = CASTING_CLOTHES | NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL
	armor_type = /datum/armor/hardsuit_wizard
	allowed = list(
		/obj/item/staff,
		/obj/item/gun/magic,
		/obj/item/singularityhammer,
		/obj/item/mjolnir,
		/obj/item/wizard_armour_charge,
		/obj/item/spellbook,
		/obj/item/scrying,
		/obj/item/camera/rewind,
		/obj/item/soulstone,
		/obj/item/holoparasite_creator/wizard,
		/obj/item/antag_spawner/contract,
		/obj/item/antag_spawner/slaughter_demon,
		/obj/item/warpwhistle,
		/obj/item/necromantic_stone,
		/obj/item/clothing/gloves/translocation_ring,
		/obj/item/clothing/glasses/red/wizard,
		/obj/item/tank/internals,
		)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/wizard
	cell = /obj/item/stock_parts/cell/hyper
	jetpack = /obj/item/tank/jetpack/suit
	slowdown = 0.3


/datum/armor/hardsuit_wizard
	melee = 40
	bullet = 40
	laser = 40
	energy = 50
	bomb = 35
	bio = 100
	fire = 100
	acid = 100
	stamina = 70
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/wizard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)
	AddComponent(/datum/component/anti_magic, INNATE_TRAIT, MAGIC_RESISTANCE)

/obj/item/clothing/suit/space/hardsuit/wizard/equipped(mob/user, slot)
	ADD_TRAIT(user, TRAIT_ANTIMAGIC_NO_SELFBLOCK, TRAIT_ANTIMAGIC_NO_SELFBLOCK)
	. = ..()

/obj/item/clothing/suit/space/hardsuit/wizard/dropped(mob/user, slot)
	REMOVE_TRAIT(user, TRAIT_ANTIMAGIC_NO_SELFBLOCK, TRAIT_ANTIMAGIC_NO_SELFBLOCK)
	. = ..()

	//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	inhand_icon_state = "medical_helm"
	hardsuit_type = "medical"
	flash_protect = FLASH_PROTECTION_NONE
	armor_type = /datum/armor/hardsuit_medical
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS
	clothing_traits = list(TRAIT_REAGENT_SCANNER)


/datum/armor/hardsuit_medical
	melee = 30
	bullet = 5
	laser = 10
	energy = 15
	bomb = 10
	bio = 100
	fire = 60
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/medical
	icon_state = "hardsuit-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Built with lightweight materials for easier movement."
	inhand_icon_state = "medical_hardsuit"
	supports_variations = DIGITIGRADE_VARIATION
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/storage/firstaid,
		/obj/item/healthanalyzer,
		/obj/item/stack/medical,
	)
	armor_type = /datum/armor/hardsuit_medical
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical
	slowdown = 0.5


/datum/armor/hardsuit_medical
	melee = 30
	bullet = 5
	laser = 10
	energy = 15
	bomb = 10
	bio = 100
	fire = 60
	acid = 75
	stamina = 20
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/medical/cmo
	name = "chief medical officer's hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort and protects the eyes from intense light."
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/suit/space/hardsuit/medical/cmo
	name = "chief medical officer's hardsuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical/cmo

	//Research Director hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/rd
	name = "prototype hardsuit helmet"
	desc = "A prototype helmet designed for research in a hazardous, low pressure environment. Scientific data flashes across the visor."
	icon_state = "hardsuit0-rd"
	hardsuit_type = "rd"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	armor_type = /datum/armor/hardsuit_rd
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS
	clothing_traits = list(TRAIT_REAGENT_SCANNER)
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_research_scanner
	)

	var/obj/machinery/doppler_array/integrated/bomb_radar

/datum/armor/hardsuit_rd
	melee = 30
	bullet = 5
	laser = 10
	energy = 15
	bomb = 100
	bio = 100
	fire = 60
	acid = 80
	stamina = 30
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/rd/Initialize(mapload)
	. = ..()
	bomb_radar = new /obj/machinery/doppler_array/integrated(src)

/obj/item/clothing/head/helmet/space/hardsuit/rd/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.add_hud_to(user)

/obj/item/clothing/head/helmet/space/hardsuit/rd/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.remove_hud_from(user)

/obj/item/clothing/suit/space/hardsuit/research_director
	icon_state = "hardsuit-rd"
	name = "prototype hardsuit"
	desc = "A prototype suit that protects against hazardous, low pressure environments. Fitted with extensive plating for handling explosives and dangerous research materials."
	inhand_icon_state = "hardsuit-rd"
	supports_variations = DIGITIGRADE_VARIATION
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/energy/wormhole_projector, /obj/item/hand_tele, /obj/item/aicard)
	armor_type = /datum/armor/hardsuit_research_director
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/rd
	cell = /obj/item/stock_parts/cell/upgraded/plus

/datum/armor/hardsuit_research_director
	melee = 30
	bullet = 5
	laser = 10
	energy = 15
	bomb = 100
	bio = 100
	fire = 60
	acid = 80
	stamina = 30
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/research_director/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

	//Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A bulky, armored helmet designed to protect security personnel in low pressure environments."
	icon_state = "hardsuit0-sec"
	inhand_icon_state = "sec_helm"
	hardsuit_type = "sec"
	armor_type = /datum/armor/hardsuit_security

/obj/item/clothing/suit/space/hardsuit/security
	icon_state = "hardsuit-sec"
	name = "security hardsuit"
	desc = "A bulky, armored suit designed to protect security personnel in low pressure environments."
	inhand_icon_state = "sec_hardsuit"
	supports_variations = DIGITIGRADE_VARIATION
	armor_type = /datum/armor/hardsuit_security
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security


/datum/armor/hardsuit_security
	melee = 35
	bullet = 35
	laser = 30
	energy = 50
	bomb = 40
	bio = 100
	fire = 75
	acid = 75
	stamina = 50
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/security/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

	//Head of Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "head of security's hardsuit helmet"
	desc = "A bulky, armored helmet designed to protect security personnel in low pressure environments. This one has markings for the head of security."
	icon_state = "hardsuit0-hos"
	hardsuit_type = "hos"
	armor_type = /datum/armor/security_hos



/datum/armor/security_hos
	melee = 35
	bullet = 35
	laser = 30
	energy = 50
	bomb = 40
	bio = 100
	fire = 75
	acid = 75
	stamina = 50
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/security/head_of_security
	icon_state = "hardsuit-hos"
	name = "head of security's hardsuit"
	supports_variations = DIGITIGRADE_VARIATION
	desc = "A bulky, armored suit designed to protect security personnel in low pressure environments. This one has markings for the head of security."
	armor_type = /datum/armor/security_head_of_security
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/upgraded/plus

	//SWAT MKII

/datum/armor/security_head_of_security
	melee = 35
	bullet = 35
	laser = 30
	energy = 50
	bomb = 40
	bio = 100
	fire = 75
	acid = 75
	stamina = 50
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/swat
	name = "\improper MK.II SWAT Helmet"
	icon_state = "swat2helm"
	inhand_icon_state = "swat2helm"
	desc = "A tactical SWAT helmet MK.II."
	armor_type = /datum/armor/hardsuit_swat
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL

/datum/armor/hardsuit_swat
	melee = 40
	bullet = 50
	laser = 50
	energy = 60
	bomb = 50
	bio = 100
	fire = 100
	acid = 100
	stamina = 60
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/swat/attack_self() //What the fuck

/obj/item/clothing/suit/space/hardsuit/swat
	name = "\improper MK.II SWAT Suit"
	desc = "A tactical suit first developed in a joint effort by the defunct IS-ERI and Nanotrasen in 2321 for military operations. \
		It has a minor slowdown, but offers decent protection and helps the wearer resist shoving in close quarters."
	icon_state = "swat2"
	inhand_icon_state = "swat2"
	armor_type = /datum/armor/hardsuit_swat
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	clothing_flags = BLOCKS_SHOVE_KNOCKDOWN
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this needed to be added a long fucking time ago
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL

// SWAT and Captain get EMP Protection

/datum/armor/hardsuit_swat
	melee = 40
	bullet = 50
	laser = 50
	energy = 60
	bomb = 50
	bio = 100
	fire = 100
	acid = 100
	stamina = 60
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/swat/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

	//Captain
/obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	name = "captain's hardsuit helmet"
	icon_state = "capspace"
	inhand_icon_state = "capspacehelmet"
	desc = "A tactical MK.II SWAT helmet boasting better protection and a horrible fashion sense."

/obj/item/clothing/suit/space/hardsuit/swat/captain
	name = "captain's SWAT suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available. Usually reserved for heavy hitter corporate security, this one has a regal finish in Nanotrasen company colors. Better not let the assistants get a hold of it."
	icon_state = "caparmor"
	inhand_icon_state = "capspacesuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	cell = /obj/item/stock_parts/cell/upgraded/plus

	//Clown
/obj/item/clothing/head/helmet/space/hardsuit/clown
	name = "cosmohonk hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-humor environment. Has radiation shielding."
	icon_state = "hardsuit0-clown"
	inhand_icon_state = "hardsuit0-clown"
	armor_type = /datum/armor/hardsuit_clown
	hardsuit_type = "clown"


/datum/armor/hardsuit_clown
	melee = 30
	bullet = 5
	laser = 10
	energy = 20
	bomb = 10
	bio = 100
	fire = 60
	acid = 30
	stamina = 20
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/clown
	name = "cosmohonk hardsuit"
	desc = "A special suit that protects against hazardous, low humor environments. Has radiation shielding. Only a true clown can wear it."
	icon_state = "hardsuit-clown"
	inhand_icon_state = "clown_hardsuit"
	armor_type = /datum/armor/hardsuit_clown
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/clown


/datum/armor/hardsuit_clown
	melee = 30
	bullet = 5
	laser = 10
	energy = 20
	bomb = 10
	bio = 100
	fire = 60
	acid = 30
	stamina = 20
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/clown/mob_can_equip(mob/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_occupancy = FALSE)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if (!H.mind)
		return FALSE
	if(H.mind.assigned_role == JOB_NAME_CLOWN)
		return TRUE
	else
		return FALSE

	//Old Prototype
/obj/item/clothing/head/helmet/space/hardsuit/ancient
	name = "prototype RIG hardsuit helmet"
	desc = "Early prototype RIG hardsuit helmet, designed to quickly shift over a user's head. Design constraints of the helmet mean it has no inbuilt cameras, thus it restricts the users visability."
	icon_state = "hardsuit0-ancient"
	inhand_icon_state = "anc_helm"
	armor_type = /datum/armor/hardsuit_ancient
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/recharge/kinetic_accelerator, /obj/item/gun/energy/plasmacutter, /obj/item/gun/energy/plasmacutter/adv, /obj/item/gun/energy/laser/retro, /obj/item/gun/energy/laser/retro/old, /obj/item/gun/energy/e_gun/old)
	hardsuit_type = "ancient"
	resistance_flags = FIRE_PROOF


/datum/armor/hardsuit_ancient
	melee = 30
	bullet = 5
	laser = 5
	energy = 10
	bomb = 50
	bio = 100
	fire = 100
	acid = 75
	stamina = 30
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/ancient
	name = "prototype RIG hardsuit"
	desc = "Prototype powered RIG hardsuit. Provides excellent protection from the elements of space while being comfortable to move around in, thanks to the powered locomotives. Remains very bulky however."
	icon_state = "hardsuit-ancient"
	inhand_icon_state = "anc_hardsuit"
	armor_type = /datum/armor/hardsuit_ancient
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/recharge/kinetic_accelerator, /obj/item/gun/energy/laser/retro, /obj/item/gun/energy/laser/retro/old, /obj/item/gun/energy/e_gun/old)
	slowdown = 3
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	resistance_flags = FIRE_PROOF
	move_sound = list('sound/effects/servostep.ogg')

/////////////SHIELDED//////////////////////////////////


/datum/armor/hardsuit_ancient
	melee = 30
	bullet = 5
	laser = 5
	energy = 10
	bomb = 50
	bio = 100
	fire = 100
	acid = 75
	stamina = 30
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/shielded
	name = "shielded hardsuit"
	desc = "A hardsuit with built in energy shielding. Will rapidly recharge when not under fire."
	icon_state = "hardsuit-hos"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	allowed = null
	supports_variations = DIGITIGRADE_VARIATION
	armor_type = /datum/armor/hardsuit_shielded
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS | THICKMATERIAL
	/// How many charges total the shielding has
	var/shield_integrity = 60
	/// How long after we've been shot before we can start recharging.
	var/recharge_delay = 20 SECONDS
	/// How quickly the shield recharges each charge once it starts charging
	var/recharge_rate = 1 SECONDS
	/// The icon for the shield
	var/shield_icon = "shield-old"

/datum/armor/hardsuit_shielded
	melee = 30
	bullet = 15
	laser = 30
	energy = 40
	bomb = 10
	bio = 100
	fire = 100
	acid = 100
	stamina = 60
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/shielded/Initialize(mapload)
	. = ..()
	if(!allowed)
		allowed = GLOB.advanced_hardsuit_allowed
	AddComponent(
		/datum/component/shielded, \
		max_integrity = shield_integrity, \
		recharge_start_delay = recharge_delay, \
		charge_increment_delay = recharge_rate, \
		shield_icon = shield_icon \
	)

/obj/item/clothing/head/helmet/space/hardsuit/shielded
	resistance_flags = FIRE_PROOF | ACID_PROOF

///////////////Capture the Flag////////////////////

// SHIELDED VEST

/obj/item/clothing/suit/armor/vest/ctf
	name = "white shielded vest"
	desc = "Standard issue vest for playing capture the flag."
	icon = 'icons/mob/clothing/suits/ctf.dmi'
	worn_icon = 'icons/mob/clothing/suits/ctf.dmi'
	icon_state = "standard"
	// Adding TRAIT_NODROP is done when the CTF spawner equips people
	armor_type = /datum/armor/none
	allowed = null
	greyscale_config = /datum/greyscale_config/ctf_standard
	greyscale_config_worn = /datum/greyscale_config/ctf_standard_worn
	greyscale_colors = "#ffffff"
	clothing_flags = THICKMATERIAL

	///Icon state to be fed into the shielded component
	var/team_shield_icon = "shield-old"
	var/shield_integrity = 150
	var/charge_recovery = 30
	var/recharge_start_delay = 20 SECONDS
	var/charge_increment_delay = 1 SECONDS

/obj/item/clothing/suit/armor/vest/ctf/Initialize(mapload)
	. = ..()
	AddComponent(
		/datum/component/shielded, \
		max_integrity = shield_integrity, \
		charge_recovery = charge_recovery, \
		recharge_start_delay = recharge_start_delay, \
		charge_increment_delay = charge_increment_delay, \
		shield_icon = team_shield_icon \
	)

// LIGHT SHIELDED VEST

/obj/item/clothing/suit/armor/vest/ctf/light
	name = "light white shielded vest"
	desc = "Lightweight vest for playing capture the flag."
	icon_state = "light"
	greyscale_config = /datum/greyscale_config/ctf_light
	greyscale_config_worn = /datum/greyscale_config/ctf_light_worn
	slowdown = -0.25
	shield_integrity = 50

// RED TEAM SUITS

// Regular
/obj/item/clothing/suit/armor/vest/ctf/red
	name = "red shielded vest"
	inhand_icon_state = "ert_security"
	team_shield_icon = "shield-red"
	greyscale_colors = COLOR_VIVID_RED

// Light
/obj/item/clothing/suit/armor/vest/ctf/light/red
	name = "light red shielded vest"
	inhand_icon_state = "ert_security"
	team_shield_icon = "shield-red"
	greyscale_colors = COLOR_VIVID_RED


// BLUE TEAM SUITS

// Regular
/obj/item/clothing/suit/armor/vest/ctf/blue
	name = "blue shielded vest"
	inhand_icon_state = "ert_command"
	team_shield_icon = "shield-old"
	greyscale_colors = COLOR_DARK_CYAN

// Light
/obj/item/clothing/suit/armor/vest/ctf/light/blue
	name = "light blue shielded vest"
	inhand_icon_state = "ert_command"
	team_shield_icon = "shield-old"
	greyscale_colors = COLOR_DARK_CYAN


//////Syndicate Version

/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit"
	desc = "An advanced hardsuit with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/shielded_syndi
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	slowdown = 0
	actions_types = list(
		/datum/action/item_action/toggle_spacesuit,
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)
	jetpack = /obj/item/tank/jetpack/suit

/datum/armor/shielded_syndi
	melee = 40
	bullet = 50
	laser = 30
	energy = 40
	bomb = 35
	bio = 100
	fire = 100
	acid = 100
	stamina = 60
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/Initialize(mapload)
	. = ..()
	AddComponent(
		/datum/component/shielded, \
		max_integrity = 60, \
		charge_recovery = 20, \
		recharge_start_delay = 20 SECONDS, \
		charge_increment_delay = 1 SECONDS, \
		shield_icon = "shield-red" \
	)
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)


//Helmet - With built in HUD

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced hardsuit helmet with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	inhand_icon_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/shielded_syndi
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_beacon_hud
	)


/datum/armor/shielded_syndi
	melee = 40
	bullet = 50
	laser = 30
	energy = 40
	bomb = 35
	bio = 100
	fire = 100
	acid = 100
	stamina = 60
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/shielded/syndi))
		var/obj/linkedsuit = loc
		//NOTE FOR COPY AND PASTING: BEACON MUST BE MADE FIRST
		//Add the monitor (Default to null - No tracking)
		var/datum/component/tracking_beacon/component_beacon = linkedsuit.AddComponent(/datum/component/tracking_beacon, "synd", null, null, TRUE, "#8f4a4b", FALSE, FALSE, "#573d3d")
		//Add the monitor (Default to null - No tracking)
		component_beacon.attached_monitor = AddComponent(/datum/component/team_monitor/worn, "synd", null, component_beacon)
	else
		AddComponent(/datum/component/team_monitor/worn, "synd", -1)

///SWAT version
/obj/item/clothing/suit/space/hardsuit/shielded/swat
	name = "death commando spacesuit"
	desc = "An advanced hardsuit favored by commandos for use in special operations."
	icon_state = "deathsquad"
	inhand_icon_state = "swat_suit"
	hardsuit_type = "syndi"
	shield_integrity = 80
	recharge_delay = 1.5 SECONDS
	armor_type = /datum/armor/shielded_swat
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	jetpack = /obj/item/tank/jetpack/suit
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	dog_fashion = /datum/dog_fashion/back/deathsquad


/datum/armor/shielded_swat
	melee = 80
	bullet = 80
	laser = 50
	energy =60
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	stamina = 100
	bleed = 100

/obj/item/clothing/suit/space/hardsuit/shielded/swat/Initialize(mapload)
	. = ..()
	AddComponent(
		/datum/component/shielded, \
		max_integrity = 80, \
		charge_recovery = 20, \
		recharge_start_delay = 1.5 SECONDS, \
		charge_increment_delay = 1 SECONDS, \
		shield_icon = "shield-old" \
	)

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	name = "death commando helmet"
	desc = "A tactical helmet with built in energy shielding."
	icon_state = "deathsquad"
	inhand_icon_state = "deathsquad"
	hardsuit_type = "syndi"
	armor_type = /datum/armor/shielded_swat
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/datum/armor/shielded_swat
	melee = 80
	bullet = 80
	laser = 50
	energy = 60
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	stamina = 100
	bleed = 100

/obj/item/clothing/suit/space/hardsuit/shielded/swat/honk
	name = "honk squad spacesuit"
	desc = "A hilarious hardsuit favored by HONK squad troopers for use in special pranks."
	icon_state = "hardsuit-clown"
	inhand_icon_state = "clown_hardsuit"
	hardsuit_type = "clown"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat/honk

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat/honk
	name = "honk squad helmet"
	desc = "A hilarious helmet with built in anti-mime propaganda shielding."
	icon_state = "hardsuit0-clown"
	inhand_icon_state = "hardsuit0-clown"
	hardsuit_type = "clown"

#undef HARDSUIT_EMP_BURN
