/// How much damage you take from an emp when wearing a hardsuit
#define HARDSUIT_EMP_BURN 2 // a very orange number

//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon = 'icons/obj/clothing/head/hardsuit.dmi'
	worn_icon = 'icons/mob/clothing/head/hardsuit.dmi'
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	max_integrity = 300
	armor = list(MELEE = 10,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 75, FIRE = 50, ACID = 75, STAMINA = 20, BLEED = 70)
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 1
	light_on = FALSE
	var/basestate = "hardsuit"
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit
	var/hardsuit_type = "engineering" //Determines used sprites: hardsuit[on]-[type]
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | HEADINTERNALS
	var/current_tick_amount = 0
	var/radiation_count = 0
	var/grace = RAD_GEIGER_GRACE_PERIOD
	var/datum/looping_sound/geiger/soundloop
	/// If the headlamp is broken, used by lighteater
	var/light_broken = FALSE

/obj/item/clothing/head/helmet/space/hardsuit/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE, TRUE)
	soundloop.volume = 5
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	if(!QDELETED(suit))
		qdel(suit)
	suit = null
	QDEL_NULL(soundloop)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	if(light_broken)
		to_chat(user, "<span class='notice'>The headlamp has been burnt out... Looks like there's no replacing it.</span>")
		on = FALSE
	else
		on = !on
	icon_state = "[basestate][on]-[hardsuit_type]"
	user?.update_inv_head()	//so our mob-overlays update

	set_light_on(on)

	update_action_buttons()

/obj/item/clothing/head/helmet/space/hardsuit/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveHelmet()
		if(user.client)
			soundloop.stop(user)

/obj/item/clothing/head/helmet/space/hardsuit/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_HEAD)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_HEAD)
		if(suit)
			suit.RemoveHelmet()
			if(user.client)
				soundloop.stop(user)
		else
			qdel(src)
	else if(user.client)
		soundloop.start(user)

/obj/item/clothing/head/helmet/space/hardsuit/proc/toggle_hud(mob/user)
	var/datum/component/team_monitor/worn/monitor = GetComponent(/datum/component/team_monitor/worn)
	if(!monitor)
		to_chat(user, "<span class='notice'>The suit is not fitted with a tracking beacon.</span>")
		return
	monitor.toggle_hud(!monitor.hud_visible, user)
	if(monitor.hud_visible)
		to_chat(user, "<span class='notice'>You toggle the heads up display of your suit.</span>")
	else
		to_chat(user, "<span class='warning'>You disable the heads up display of your suit.</span>")

/obj/item/clothing/head/helmet/space/hardsuit/proc/display_visor_message(var/msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message("[icon2html(src, wearer)]<b><span class='robot'>[msg]</span></b>", MSG_VISUAL)

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(amount)
	. = ..()
	if(amount <= RAD_BACKGROUND_RADIATION)
		return
	current_tick_amount += amount

/obj/item/clothing/head/helmet/space/hardsuit/process(delta_time)
	radiation_count = LPFILTER(radiation_count, current_tick_amount, delta_time, RAD_GEIGER_RC)

	if(current_tick_amount)
		grace = RAD_GEIGER_GRACE_PERIOD
	else
		grace -= delta_time
		if(grace <= 0)
			radiation_count = 0

	current_tick_amount = 0

	soundloop.last_radiation = radiation_count

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
	item_state = "eng_hardsuit"
	max_integrity = 300
	armor = list(MELEE = 10,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 75, FIRE = 50, ACID = 75, STAMINA = 20, BLEED = 70)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(
		/datum/action/item_action/toggle_spacesuit,
		/datum/action/item_action/toggle_helmet
	)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/tank/jetpack/suit/jetpack = null
	pocket_storage_component_path = null
	var/hardsuit_type
	/// Whether the helmet is on.
	var/helmet_on = FALSE

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
		. += "<span class='notice'> The helmet on [src] seems to be malfunctioning. It's light bulb needs to be replaced.</span>"

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, "<span class='warning'>[src] already has a jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return

		if(user.transferItemToLoc(I, src))
			jetpack = I
			to_chat(user, "<span class='notice'>You successfully install the jetpack into [src].</span>")
			return
	else if(!cell_cover_open && I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!jetpack)
			to_chat(user, "<span class='warning'>[src] has no jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
			to_chat(user, "<span class='warning'>You cannot remove the jetpack from [src] while wearing it.</span>")
			return

		jetpack.turn_off(user)
		jetpack.forceMove(drop_location())
		jetpack = null
		to_chat(user, "<span class='notice'>You successfully remove the jetpack from [src].</span>")
		return
	else if(istype(I, /obj/item/light) && helmettype)
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
			to_chat(user, "<span class='warning'>You cannot replace the bulb in the helmet of [src] while wearing it.</span>")
			return
		if(helmet)
			to_chat(user, "<span class='warning'>The helmet of [src] does not require a new bulb.</span>")
			return
		var/obj/item/light/L = I
		if(L.status)
			to_chat(user, "<span class='warning'>This bulb is too damaged to use as a replacement!</span>")
			return
		if(do_after(user, 5 SECONDS, 1, src))
			qdel(I)
			helmet = new helmettype(src)
			to_chat(user, "<span class='notice'>You have successfully repaired [src]'s helmet.</span>")
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
		to_chat(user, "<span class='notice'>The suit is not fitted with a tracking beacon.</span>")
		return
	beacon.toggle_visibility(!beacon.visible)
	if(beacon.visible)
		to_chat(user, "<span class='notice'>You enable the tracking beacon on [src]. Anybody on the same frequency will now be able to track your location.</span>")
	else
		to_chat(user, "<span class='warning'>You disable the tracking beacon on [src].</span>")

/obj/item/clothing/suit/space/hardsuit/proc/set_beacon_freq(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>The suit is not fitted with a tracking beacon.</span>")
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
		to_chat(user, "<span class='warning'>You feel \the [src] heat up from the EMP burning you slightly.</span>")

		// Chance to scream
		if (user.stat < UNCONSCIOUS && prob(10))
			user.emote("scream")

	//Engineering
/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 12, BOMB = 10, BIO = 100, RAD = 75, FIRE = 100, ACID = 75, STAMINA = 20, BLEED = 70)
	hardsuit_type = "engineering"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 75, FIRE = 100, ACID = 75, STAMINA = 20, BLEED = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	resistance_flags = FIRE_PROOF

	//Atmospherics
/obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	icon_state = "hardsuit0-atmospherics"
	item_state = "atmo_helm"
	hardsuit_type = "atmospherics"
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 25, FIRE = 100, ACID = 75, STAMINA = 20, BLEED = 70)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding."
	icon_state = "hardsuit-atmospherics"
	item_state = "atmo_hardsuit"
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 25, FIRE = 100, ACID = 75, STAMINA = 20, BLEED = 70)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/atmos


	//Chief Engineer's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	item_state = "ce_helm"
	hardsuit_type = "white"
	armor = list(MELEE = 40,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 90, STAMINA = 30, BLEED = 70)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/elite
	icon_state = "hardsuit-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	armor = list(MELEE = 40,  BULLET = 5, LASER = 10, ENERGY = 20, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 90, STAMINA = 30, BLEED = 70)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/super

	//Mining hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating for wildlife encounters and dual floodlights."
	icon_state = "hardsuit0-mining"
	item_state = "mining_helm"
	hardsuit_type = "mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	heat_protection = HEAD
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 75, STAMINA = 40, BLEED = 70)
	light_range = 7
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator)
	high_pressure_multiplier = 0.6

/obj/item/clothing/head/helmet/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/suit/space/hardsuit/mining
	icon_state = "hardsuit-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating for wildlife encounters."
	item_state = "mining_hardsuit"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	supports_variations = DIGITIGRADE_VARIATION
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 20, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 75, STAMINA = 40, BLEED = 70)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	high_pressure_multiplier = 0.6

/obj/item/clothing/suit/space/hardsuit/mining/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

	//Exploration hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/exploration
	name = "exploration hardsuit helmet"
	desc = "An advanced space-proof hardsuit designed to protect against off-station threats."
	icon_state = "hardsuit0-exploration"
	item_state = "death_commando_mask"
	hardsuit_type = "exploration"
	heat_protection = HEAD
	armor = list(MELEE = 35,  BULLET = 15, LASER = 20, ENERGY = 10, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 75, STAMINA = 20, BLEED = 70)
	light_range = 6
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator)
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_beacon_hud/explorer
		)

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
	item_state = "exploration_hardsuit"
	armor = list(MELEE = 35,  BULLET = 15, LASER = 20, ENERGY = 10, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 75, STAMINA = 20, BLEED = 70)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/exploration
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

//Cybersun Hardsuit
//A kind of side-grade to the explorer suit, sacrificing burn protection for brute. If you can kill the guy inside it, anyways.
/obj/item/clothing/head/helmet/space/hardsuit/cybersun
	name = "Cybersun hardsuit helmet"
	desc = "A bulbous red helmet designed for scavenging in hazardous, low pressure environments. Has dual floodlights, and a 360 Degree view."
	icon_state = "hardsuit0-cybersun"
	item_state = "death_commando_mask"
	hardsuit_type = "cybersun"
	armor = list(MELEE = 30,  BULLET = 35, LASER = 15, ENERGY = 15, BOMB = 60, BIO = 100, RAD = 55, FIRE = 30, ACID = 60, STAMINA = 15, BLEED = 70)
	strip_delay = 600

/obj/item/clothing/suit/space/hardsuit/cybersun
	icon_state = "cybersun"
	name = "Cybersun hardsuit"
	desc = "A bulky, protective suit designed to protect against the perils facing Cybersun Employed Engineers, Researchers, and more as they head from the safety of \
		more stable employment to the dangers of Nanotrasen Controlled Deep Space. Designed to get the job done despite on-site hazards in derelicts, laser armor was \
		sacrificed in favor of more effective blunt armor plates and radiation shielding."
	armor = list(MELEE = 30,  BULLET = 35, LASER = 15, ENERGY = 15, BOMB = 60, BIO = 100, RAD = 55, FIRE = 30, ACID = 60, STAMINA = 15, BLEED = 70)
	hardsuit_type = "cybersun"
	item_state = "death_commando_mask"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/cybersun
	jetpack = /obj/item/tank/jetpack/suit

	//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor = list(MELEE = 40,  BULLET = 50, LASER = 30, ENERGY = 55, BOMB = 35, BIO = 100, RAD = 50, FIRE = 50, ACID = 90, STAMINA = 60, BLEED = 70)
	on = TRUE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(
		/datum/action/item_action/toggle_helmet_mode,
		/datum/action/item_action/toggle_beacon_hud
	)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEEARS|HIDESNOUT
	visor_flags = STOPSPRESSUREDAMAGE | HEADINTERNALS

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
	..()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot toggle your helmet while in this [user.loc]!</span>" )
		return
	on = !on
	if(on || force)
		to_chat(user, "<span class='notice'>You switch your hardsuit to EVA mode, sacrificing speed for space protection.</span>")
		activate_space_mode()
	else
		to_chat(user, "<span class='notice'>You switch your hardsuit to combat mode and can now run at full speed.</span>")
		activate_combat_mode()
	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	toggle_hardsuit_mode(user)
	user.update_inv_head()
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
	item_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	w_class = WEIGHT_CLASS_NORMAL
	supports_variations = DIGITIGRADE_VARIATION
	armor = list(MELEE = 40,  BULLET = 50, LASER = 30, ENERGY = 55, BOMB = 35, BIO = 100, RAD = 50, FIRE = 50, ACID = 90, STAMINA = 60, BLEED = 70)
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/hyper
	item_flags = ILLEGAL	//Syndicate only and difficult to obtain outside of uplink anyway. Nukie hardsuits on the ship are illegal.
	slowdown = 0.5
	actions_types = list(
		/datum/action/item_action/toggle_spacesuit,
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)

/obj/item/clothing/suit/space/hardsuit/syndi/ComponentInitialize()
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
		A.UpdateButtonIcon()
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
		H.update_inv_wear_suit()
		H.update_inv_w_uniform()

/obj/item/clothing/suit/space/hardsuit/syndi/proc/activate_combat_mode()
	name = "[initial(name)] (combat)"
	desc = alt_desc
	slowdown = 0
	clothing_flags &= ~STOPSPRESSUREDAMAGE
	cold_protection &= ~(CHEST | GROIN | LEGS | FEET | ARMS | HANDS)
	if(ishuman(loc))
		var/mob/living/carbon/H = loc
		H.update_equipment_speed_mods()
		H.update_inv_wear_suit()
		H.update_inv_w_uniform()

//Stupid snowflake type so we dont freak out the spritesheets. Its not actually used ingame
/obj/item/clothing/suit/space/hardsuit/syndipreview
	name = "blood-red hardsuit"
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
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
	armor = list(MELEE = 60,  BULLET = 60, LASER = 50, ENERGY = 80, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, STAMINA = 80, BLEED = 70)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in travel mode."
	alt_desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in combat mode."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor = list(MELEE = 60,  BULLET = 60, LASER = 50, ENERGY = 80, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, STAMINA = 80, BLEED = 70)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	cell = /obj/item/stock_parts/cell/bluespace

//The Owl Hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/owl
	name = "owl hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	item_state = "s_helmet"
	hardsuit_type = "owl"
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE

/obj/item/clothing/suit/space/hardsuit/syndi/owl
	name = "owl hardsuit"
	desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	item_state = "s_suit"
	hardsuit_type = "owl"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/owl


	//Wizard hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "hardsuit0-wiz"
	item_state = "wiz_helm"
	hardsuit_type = "wiz"
	resistance_flags = FIRE_PROOF | ACID_PROOF //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(MELEE = 40,  BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, STAMINA = 70, BLEED = 70)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/wizard
	icon_state = "hardsuit-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 40,  BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, STAMINA = 70, BLEED = 70)
	allowed = list(/obj/item/teleportation_scroll, /obj/item/tank/internals)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/wizard
	cell = /obj/item/stock_parts/cell/hyper
	jetpack = /obj/item/tank/jetpack/suit
	slowdown = 0.3

/obj/item/clothing/suit/space/hardsuit/wizard/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)
	AddComponent(/datum/component/anti_magic, INNATE_TRAIT, TRUE, FALSE, INFINITY, FALSE)


	//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	item_state = "medical_helm"
	hardsuit_type = "medical"
	flash_protect = 0
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 60, FIRE = 60, ACID = 75, STAMINA = 20, BLEED = 70)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | SCAN_REAGENTS | HEADINTERNALS

/obj/item/clothing/suit/space/hardsuit/medical
	icon_state = "hardsuit-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Built with lightweight materials for easier movement."
	item_state = "medical_hardsuit"
	supports_variations = DIGITIGRADE_VARIATION
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/firstaid, /obj/item/healthanalyzer, /obj/item/stack/medical)
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 60, FIRE = 60, ACID = 75, STAMINA = 20, BLEED = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical
	slowdown = 0.5

/obj/item/clothing/head/helmet/space/hardsuit/medical/cmo
	name = "chief medical officer's hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort and protects the eyes from intense light."
	flash_protect = 2

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
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 100, BIO = 100, RAD = 60, FIRE = 60, ACID = 80, STAMINA = 30, BLEED = 70)
	var/obj/machinery/doppler_array/integrated/bomb_radar
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | SCAN_REAGENTS | HEADINTERNALS
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_research_scanner
	)

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
	item_state = "hardsuit-rd"
	supports_variations = DIGITIGRADE_VARIATION
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/energy/wormhole_projector,
	/obj/item/hand_tele, /obj/item/aicard)
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 15, BOMB = 100, BIO = 100, RAD = 60, FIRE = 60, ACID = 80, STAMINA = 30, BLEED = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/rd
	cell = /obj/item/stock_parts/cell/super

/obj/item/clothing/suit/space/hardsuit/research_director/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

	//Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A bulky, armored helmet designed to protect security personnel in low pressure environments."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	hardsuit_type = "sec"
	armor = list(MELEE = 35,  BULLET = 35, LASER = 30, ENERGY = 50, BOMB = 40, BIO = 100, RAD = 50, FIRE = 75, ACID = 75, STAMINA = 50, BLEED = 70)


/obj/item/clothing/suit/space/hardsuit/security
	icon_state = "hardsuit-sec"
	name = "security hardsuit"
	desc = "A bulky, armored suit designed to protect security personnel in low pressure environments."
	item_state = "sec_hardsuit"
	supports_variations = DIGITIGRADE_VARIATION
	armor = list(MELEE = 35,  BULLET = 35, LASER = 30, ENERGY = 50, BOMB = 40, BIO = 100, RAD = 50, FIRE = 75, ACID = 75, STAMINA = 50, BLEED = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security

/obj/item/clothing/suit/space/hardsuit/security/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

	//Head of Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "head of security's hardsuit helmet"
	desc = "A bulky, armored helmet designed to protect security personnel in low pressure environments. This one has markings for the head of security."
	icon_state = "hardsuit0-hos"
	hardsuit_type = "hos"
	armor = list(MELEE = 35,  BULLET = 35, LASER = 30, ENERGY = 50, BOMB = 40, BIO = 100, RAD = 50, FIRE = 75, ACID = 75, STAMINA = 50, BLEED = 70)


/obj/item/clothing/suit/space/hardsuit/security/head_of_security
	icon_state = "hardsuit-hos"
	name = "head of security's hardsuit"
	supports_variations = DIGITIGRADE_VARIATION
	desc = "A bulky, armored suit designed to protect security personnel in low pressure environments. This one has markings for the head of security."
	armor = list(MELEE = 35,  BULLET = 35, LASER = 30, ENERGY = 50, BOMB = 40, BIO = 100, RAD = 50, FIRE = 75, ACID = 75, STAMINA = 50, BLEED = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/tank/jetpack/suit
	cell = /obj/item/stock_parts/cell/super

	//SWAT MKII
/obj/item/clothing/head/helmet/space/hardsuit/swat
	name = "\improper MK.II SWAT Helmet"
	icon_state = "swat2helm"
	item_state = "swat2helm"
	desc = "A tactical SWAT helmet MK.II."
	armor = list(MELEE = 40,  BULLET = 50, LASER = 50, ENERGY = 60, BOMB = 50, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, STAMINA = 60, BLEED = 70)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/swat/attack_self() //What the fuck

/obj/item/clothing/suit/space/hardsuit/swat
	name = "\improper MK.II SWAT Suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available."
	icon_state = "swat2"
	item_state = "swat2"
	armor = list(MELEE = 40,  BULLET = 50, LASER = 50, ENERGY = 60, BOMB = 50, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, STAMINA = 60, BLEED = 70)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this needed to be added a long fucking time ago
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat

// SWAT and Captain get EMP Protection
/obj/item/clothing/suit/space/hardsuit/swat/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

	//Captain
/obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	name = "captain's hardsuit helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A tactical MK.II SWAT helmet boasting better protection and a horrible fashion sense."

/obj/item/clothing/suit/space/hardsuit/swat/captain
	name = "captain's SWAT suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available. Usually reserved for heavy hitter corporate security, this one has a regal finish in Nanotrasen company colors. Better not let the assistants get a hold of it."
	icon_state = "caparmor"
	item_state = "capspacesuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	cell = /obj/item/stock_parts/cell/super

	//Clown
/obj/item/clothing/head/helmet/space/hardsuit/clown
	name = "cosmohonk hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-humor environment. Has radiation shielding."
	icon_state = "hardsuit0-clown"
	item_state = "hardsuit0-clown"
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 20, BOMB = 10, BIO = 100, RAD = 75, FIRE = 60, ACID = 30, STAMINA = 20, BLEED = 70)
	hardsuit_type = "clown"

/obj/item/clothing/suit/space/hardsuit/clown
	name = "cosmohonk hardsuit"
	desc = "A special suit that protects against hazardous, low humor environments. Has radiation shielding. Only a true clown can wear it."
	icon_state = "hardsuit-clown"
	item_state = "clown_hardsuit"
	armor = list(MELEE = 30,  BULLET = 5, LASER = 10, ENERGY = 20, BOMB = 10, BIO = 100, RAD = 75, FIRE = 60, ACID = 30, STAMINA = 20, BLEED = 70)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/clown

/obj/item/clothing/suit/space/hardsuit/clown/mob_can_equip(mob/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(H.mind.assigned_role == JOB_NAME_CLOWN)
		return TRUE
	else
		return FALSE

	//Old Prototype
/obj/item/clothing/head/helmet/space/hardsuit/ancient
	name = "prototype RIG hardsuit helmet"
	desc = "Early prototype RIG hardsuit helmet, designed to quickly shift over a user's head. Design constraints of the helmet mean it has no inbuilt cameras, thus it restricts the users visability."
	icon_state = "hardsuit0-ancient"
	item_state = "anc_helm"
	armor = list(MELEE = 30,  BULLET = 5, LASER = 5, ENERGY = 10, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 75, STAMINA = 30, BLEED = 70)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/gun/energy/plasmacutter, /obj/item/gun/energy/plasmacutter/adv, /obj/item/gun/energy/laser/retro, /obj/item/gun/energy/laser/retro/old, /obj/item/gun/energy/e_gun/old)
	hardsuit_type = "ancient"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ancient
	name = "prototype RIG hardsuit"
	desc = "Prototype powered RIG hardsuit. Provides excellent protection from the elements of space while being comfortable to move around in, thanks to the powered locomotives. Remains very bulky however."
	icon_state = "hardsuit-ancient"
	item_state = "anc_hardsuit"
	armor = list(MELEE = 30,  BULLET = 5, LASER = 5, ENERGY = 10, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 75, STAMINA = 30, BLEED = 70)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/gun/energy/laser/retro, /obj/item/gun/energy/laser/retro/old, /obj/item/gun/energy/e_gun/old)
	slowdown = 3
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	resistance_flags = FIRE_PROOF
	move_sound = list('sound/effects/servostep.ogg')

/////////////SHIELDED//////////////////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded
	name = "shielded hardsuit"
	desc = "A hardsuit with built in energy shielding. Will rapidly recharge when not under fire."
	icon_state = "hardsuit-hos"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	allowed = null
	supports_variations = DIGITIGRADE_VARIATION
	armor = list(MELEE = 30,  BULLET = 15, LASER = 30, ENERGY = 40, BOMB = 10, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, STAMINA = 60, BLEED = 70)
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/shielded/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 3, recharge_start_delay = 20 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, shield_icon = "shield-old")

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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0, BLEED = 0) // CTF gear gives no protection outside of the shield
	allowed = null
	greyscale_config = /datum/greyscale_config/ctf_standard
	greyscale_config_worn = /datum/greyscale_config/ctf_standard_worn
	greyscale_colors = "#ffffff"

	///Icon state to be fed into the shielded component
	var/team_shield_icon = "shield-old"

/obj/item/clothing/suit/armor/vest/ctf/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 150, recharge_start_delay = 20 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 30, lose_multiple_charges = TRUE, shield_icon = team_shield_icon)

// LIGHT SHIELDED VEST

/obj/item/clothing/suit/armor/vest/ctf/light
	name = "light white shielded vest"
	desc = "Lightweight vest for playing capture the flag."
	icon_state = "light"
	greyscale_config = /datum/greyscale_config/ctf_light
	greyscale_config_worn = /datum/greyscale_config/ctf_light_worn
	slowdown = -0.25

/obj/item/clothing/suit/armor/vest/ctf/light/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 30, recharge_start_delay = 20 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 30, lose_multiple_charges = TRUE, shield_icon = team_shield_icon)

// RED TEAM SUITS

// Regular
/obj/item/clothing/suit/armor/vest/ctf/red
	name = "red shielded vest"
	item_state = "ert_security"
	team_shield_icon = "shield-red"
	greyscale_colors = COLOR_VIVID_RED

// Light
/obj/item/clothing/suit/armor/vest/ctf/light/red
	name = "light red shielded vest"
	item_state = "ert_security"
	team_shield_icon = "shield-red"
	greyscale_colors = COLOR_VIVID_RED


// BLUE TEAM SUITS

// Regular
/obj/item/clothing/suit/armor/vest/ctf/blue
	name = "blue shielded vest"
	item_state = "ert_command"
	team_shield_icon = "shield-old"
	greyscale_colors = COLOR_DARK_CYAN

// Light
/obj/item/clothing/suit/armor/vest/ctf/light/blue
	name = "light blue shielded vest"
	item_state = "ert_command"
	team_shield_icon = "shield-old"
	greyscale_colors = COLOR_DARK_CYAN


//////Syndicate Version

/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit"
	desc = "An advanced hardsuit with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	armor = list(MELEE = 40,  BULLET = 50, LASER = 30, ENERGY = 40, BOMB = 35, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, STAMINA = 60, BLEED = 70)
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	slowdown = 0
	actions_types = list(
		/datum/action/item_action/toggle_spacesuit,
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 3, recharge_start_delay = 20 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, shield_icon = "shield-red")

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/ui_action_click(mob/user, datum/actiontype)
	switch(actiontype.type)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
		if(/datum/action/item_action/toggle_beacon)
			toggle_beacon(user)
		if(/datum/action/item_action/toggle_beacon_frequency)
			set_beacon_freq(user)

//Helmet - With built in HUD

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced hardsuit helmet with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor = list(MELEE = 40,  BULLET = 50, LASER = 30, ENERGY = 40, BOMB = 35, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, STAMINA = 60, BLEED = 70)
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_beacon_hud
	)

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

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi/ui_action_click(mob/user, datum/action)
	switch(action.type)
		if(/datum/action/item_action/toggle_beacon_hud)
			toggle_hud(user)

///SWAT version
/obj/item/clothing/suit/space/hardsuit/shielded/swat
	name = "death commando spacesuit"
	desc = "An advanced hardsuit favored by commandos for use in special operations."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	hardsuit_type = "syndi"
	armor = list(MELEE = 80,  BULLET = 80, LASER = 50, ENERGY =60, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 100, BLEED = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	jetpack = /obj/item/tank/jetpack/suit
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	dog_fashion = /datum/dog_fashion/back/deathsquad

/obj/item/clothing/suit/space/hardsuit/shielded/swat/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 4, recharge_start_delay = 1.5 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, shield_icon = "shield-old")

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	name = "death commando helmet"
	desc = "A tactical helmet with built in energy shielding."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	hardsuit_type = "syndi"
	armor = list(MELEE = 80,  BULLET = 80, LASER = 50, ENERGY = 60, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 100, BLEED = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/suit/space/hardsuit/shielded/swat/honk
	name = "honk squad spacesuit"
	desc = "A hilarious hardsuit favored by HONK squad troopers for use in special pranks."
	icon_state = "hardsuit-clown"
	item_state = "clown_hardsuit"
	hardsuit_type = "clown"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat/honk

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat/honk
	name = "honk squad helmet"
	desc = "A hilarious helmet with built in anti-mime propaganda shielding."
	icon_state = "hardsuit0-clown"
	item_state = "hardsuit0-clown"
	hardsuit_type = "clown"


// Doomguy ERT version
/obj/item/clothing/suit/space/hardsuit/shielded/doomguy
	name = "juggernaut armor"
	desc = "A somehow spaceworthy set of armor with outstanding protection against almost everything. Comes in an oddly nostalgic green. "
	icon_state = "doomguy"
	item_state = "doomguy"
	armor = list(MELEE = 135,  BULLET = 135, LASER = 135, ENERGY = 135, BOMB = 135, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 100, BLEED = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/doomguy
	dog_fashion = /datum/dog_fashion/back/deathsquad

/obj/item/clothing/suit/space/hardsuit/shielded/doomguy/setup_shielding()
	AddComponent(/datum/component/shielded, max_charges = 1, recharge_start_delay = 1 SECONDS, charge_increment_delay = 1 SECONDS, charge_recovery = 1, lose_multiple_charges = FALSE, shield_icon = "shield-old")

/obj/item/clothing/head/helmet/space/hardsuit/shielded/doomguy
	name = "juggernaut helmet"
	desc = "A dusty old helmet, somehow capable of resisting the strongest of blows."
	icon_state = "doomguy"
	item_state = "doomguy"
	armor = list(MELEE = 135,  BULLET = 135, LASER = 135, ENERGY = 135, BOMB = 135, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 100, BLEED = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

#undef HARDSUIT_EMP_BURN
