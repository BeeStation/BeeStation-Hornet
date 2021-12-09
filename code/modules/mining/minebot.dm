/**********************Mining drone**********************/

#define MINEDRONE_PKA 1 // Combat mode for AI, PKA usage mode for players
#define MINEDRONE_CUTTER 2 // Ore collection mode for AI, plasma cutter usage mode for players
#define MINEBOT_DAMAGE_PROB 30 //Probability that a minebot loses their plasma cutter or their PKA upgrades on death

/mob/living/simple_animal/hostile/mining_drone
	name = "\improper Nanotrasen minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners. It can be set to search and collect loose ore, or to help fend off wildlife. It is equipped with a drill, plasma cutter, and PKA."
	gender = NEUTER
	icon = 'icons/mob/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	icon_dead = "mining_drone_disabled"
	status_flags = CANSTUN|CANKNOCKDOWN|CANPUSH
	mouse_opacity = MOUSE_OPACITY_ICON
	faction = list("neutral")
	a_intent = INTENT_HARM
	hud_type = /datum/hud/minebot
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	// Health/damage
	health = 125
	maxHealth = 125
	melee_damage = 15
	obj_damage = 10
	environment_smash = ENVIRONMENT_SMASH_NONE
	healable = 0
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	deathmessage = "stops moving"
	// AI stuff
	check_friendly_fire = TRUE
	move_to_delay = 10
	ranged = TRUE
	sentience_type = SENTIENCE_MINEBOT
	stop_automated_movement_when_pulled = TRUE
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/plasma, /obj/item/stack/ore/uranium, /obj/item/stack/ore/iron,
						  /obj/item/stack/ore/bananium, /obj/item/stack/ore/titanium)
	// Response verbs
	response_help = "pets"
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	speak_emote = list("states")
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/plasma, /obj/item/stack/ore/uranium, /obj/item/stack/ore/iron,
						  /obj/item/stack/ore/bananium, /obj/item/stack/ore/titanium)
	healable = 0
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	del_on_death = FALSE
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_on = FALSE
	deathmessage = "buzzes and grows still."
	var/mode = MINEDRONE_CUTTER
	var/list/installed_upgrades
	var/obj/item/gun/energy/kinetic_accelerator/minebot/stored_pka
	var/obj/item/gun/energy/plasmacutter/stored_cutter
	var/obj/item/pickaxe/drill/stored_drill
	var/obj/item/t_scanner/adv_mining_scanner/lesser/stored_scanner

/mob/living/simple_animal/hostile/mining_drone/Initialize(mapload)
	. = ..()
	stored_pka = new(src)
	stored_drill = new(src)
	stored_scanner = new(src)
	var/datum/action/innate/minedrone/toggle_light/toggle_light_action = new()
	toggle_light_action.Grant(src)
	var/datum/action/innate/minedrone/toggle_meson_vision/toggle_meson_vision_action = new()
	toggle_meson_vision_action.Grant(src)
	var/datum/action/innate/minedrone/toggle_scanner/toggle_scanner = new()
	toggle_scanner.Grant(src)
	var/datum/action/innate/minedrone/toggle_mode/toggle_mode_action = new()
	toggle_mode_action.Grant(src)
	var/datum/action/innate/minedrone/dump_ore/dump_ore_action = new()
	dump_ore_action.Grant(src)

	// Setup radio
	var/obj/item/implant/radio/mining/imp = new(src)
	imp.implant(src)

	// Setup access
	access_card = new /obj/item/card/id(src)
	var/datum/job/mining/M = new
	access_card.access = M.get_access()

	SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/Destroy()
	for (var/datum/action/innate/minedrone/action as anything in actions)
		qdel(action)

	// Clear any equipment they might have
	for(var/obj/item/mine_bot_upgrade/U as anything in installed_upgrades)
		U.unequip()
		qdel(U)
	QDEL_NULL(stored_pka)
	QDEL_NULL(stored_cutter)
	QDEL_NULL(stored_drill)
	QDEL_NULL(stored_scanner)
	QDEL_LIST(installed_upgrades)
	return ..()

/mob/living/simple_animal/hostile/mining_drone/death()
	if(prob(MINEBOT_DAMAGE_PROB))
		if(stored_pka && prob(50))
			for(var/obj/item/borg/upgrade/modkit/M in stored_pka.modkits)
				M.uninstall(stored_pka)
		else if(stored_cutter)
			QDEL_NULL(stored_cutter)
	..()

/mob/living/simple_animal/hostile/mining_drone/update_health_hud()
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			if(health >= maxHealth)
				hud_used.healths.icon_state = "health0"
			else if(health > maxHealth*0.8)
				hud_used.healths.icon_state = "health2"
			else if(health > maxHealth * 0.5)
				hud_used.healths.icon_state = "health3"
			else if(health > maxHealth*0.2)
				hud_used.healths.icon_state = "health4"
			else
				hud_used.healths.icon_state = "health5"
		else
			hud_used.healths.icon_state = "health7"

/mob/living/simple_animal/hostile/mining_drone/examine(mob/user)
	. = ..()
	var/t_He = p_they(TRUE)
	var/t_him = p_them()
	var/t_s = p_s()
	var/t_their = p_their()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += "<span class='warning'>[t_He] look[t_s] slightly dented.</span>"
		else if(health > 0)
			. += "<span class='boldwarning'>[t_He] look[t_s] severely dented!</span>"
		else
			. += "<span class='boldwarning'>[t_He] is disabled."
	. += "<span class='notice'>Using a mining scanner on [t_him] will instruct [t_him] to drop stored ore.</span>"
	. += "<span class='notice'>Field repairs can be done with a welder.</span>"
	if(stored_pka && stored_pka.max_mod_capacity)
		. += "<span class='notice'><b>[stored_pka.get_remaining_mod_capacity()]%</b> mod capacity remaining.</span>"
		for(var/A in stored_pka.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			. += "<span class='notice'>There is \a [M] installed, using <b>[M.cost]%</b> capacity.</span>"
	if(stored_cutter)
		. += "<span class='notice'>There is \a [stored_cutter] installed on [t_their] plasma cutter mount.</span>"
	else
		. += "<span class='notice'>There is nothing on [t_their] plasma cutter mount.</span>"
	if(stored_drill)
		. += "<span class='notice'>There is \a [stored_cutter] installed on [t_their] drill mount.</span>"
	else
		. += "<span class='notice'>There is nothing on [t_their] drill mount.</span>"
	if(client)
		. += "<span class='notice'>[t_He]'s AI light is on.</span>"

// Generates the stat tab for player-controlled minebots
/mob/living/simple_animal/hostile/mining_drone/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Mode"] = GENERATE_STAT_TEXT("[mode]")

	// Handles Equipment
	if(stored_cutter)
		tab_data["Plasma cutter charge"] = GENERATE_STAT_TEXT("[round(stored_cutter.cell.percent())]%")
	tab_data["Equipped drill"] = GENERATE_STAT_TEXT("[stored_drill]")

	// Handles Upgrades
	if(LAZYLEN(installed_upgrades))
		for(var/obj/item/minebot_upgrade/U as anything in installed_upgrades)
			var/upgrade_data = U.get_stat_data()
			if(upgrade_data)
				tab_data[upgrade_data[1]] = GENERATE_STAT_TEXT(upgrade_data[2])
	return tab_data

// Repairing/reviving
/mob/living/simple_animal/hostile/mining_drone/welder_act(mob/living/user, obj/item/I)
	if(istype(I, /obj/item/gun/energy/plasmacutter)) //For installing plasma cutters
		return
	if(maxHealth == health)
		to_chat(user, "<span class='info'>[src] is at full integrity.</span>")
		return

	if(I.use_tool(src, user, 0, volume=40))
		if(stat == DEAD)
			adjustBruteLoss(-25)
			to_chat(user, "<span class='info'>You repair and restart [src].</span>")
			revive()
			return TRUE
		adjustBruteLoss(-15)
		to_chat(user, "<span class='info'>You repair some of the armor on [src].</span>")
		return TRUE

/mob/living/simple_animal/hostile/mining_drone/sentience_act()
	..()
	check_friendly_fire = 0

// Installing new tools/upgrades and interacting with the minebot

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I, mob/user, params)
	if(user == src)
		return TRUE
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner))
		if(!do_after(user, 20, TRUE, src))
			return TRUE
		stored_scanner.forceMove(get_turf(src))
		I.forceMove(src)
		stored_scanner = I
		to_chat(user, "<span class='info'>You install [I].</span>")
		return TRUE
	if(I.tool_behaviour == TOOL_CROWBAR || istype(I, /obj/item/borg/upgrade/modkit))
		I.melee_attack_chain(user, stored_pka, params)
		uninstall_upgrades()
		return
	if(istype(I, /obj/item/gun/energy/plasmacutter))
		if(!do_after(user, 20, TRUE, src))
			return TRUE //Prevents afterattack() from going off and shooting the minebot
		if(stored_cutter)
			stored_cutter.forceMove(get_turf(src))
		I.forceMove(src)
		stored_cutter = I
		return TRUE
	if(istype(I, /obj/item/pickaxe/drill))
		if(!do_after(user, 20, TRUE, src))
			return
		if(stored_drill)
			stored_drill.forceMove(get_turf(src))
		I.forceMove(src)
		stored_drill = I
		return TRUE
	..()
	check_friendly_fire = FALSE

// Toggling modes on a non-sentient minebot

// Toggling modes
/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(.)
		return
	if(client)
		to_chat(M, "<span class='info'>[src]'s equipment is currently slaved to its onboard AI.</span>")
	if(M.a_intent == INTENT_HELP)
		if(mode == MODE_MINING && !mining_enabled)
			mining_enabled = TRUE
		else // Either we've got mining enabled and want to switch to combat, or we're switching to ore pickup
			mining_enabled = FALSE
			toggle_mode()
		switch(mode)
			if(MINEDRONE_CUTTER)
				to_chat(M, "<span class='info'>[src] has been set to search and store loose ore.</span>")
			if(MINEDRONE_PKA)
				to_chat(M, "<span class='info'>[src] has been set to attack hostile wildlife.</span>")
		return
	for(var/obj/item/minebot_upgrade/upgrade as anything in installed_upgrades)
		upgrade.onAltClick(target)

// Acticating installed minebot mods

/mob/living/simple_animal/hostile/mining_drone/AltClickOn(atom/A)
	. = ..()
	for(var/obj/item/mine_bot_upgrade/upgrade as anything in installed_upgrades)
		upgrade.onAltClick(A)

// Minebot Passthrough

/mob/living/simple_animal/hostile/mining_drone/CanAllowThrough(atom/movable/O)
	. = ..()
	if(istype(O, /obj/item/projectile/kinetic))
		var/obj/item/projectile/kinetic/K = O
		if(K.kinetic_gun)
			for(var/A as anything in K.kinetic_gun.get_modkits())
				var/obj/item/borg/upgrade/modkit/M = A
				if(istype(M, /obj/item/borg/upgrade/modkit/minebot_passthrough))
					return TRUE
	if(istype(moving_atom, /obj/item/projectile/destabilizer))
		return TRUE

// Attacking targets in melee or ranged

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(client && (istype(target, /obj/item/stack/ore/plasma) || istype(target, /obj/item/stack/sheet/mineral/plasma)) && stored_cutter && mode == MINEDRONE_CUTTER) //Charging the on-board plasma cutter
		stored_cutter?.attackby(target, src)
		return
	if(istype(target, /obj/item/stack/ore)) // Collecting ore
		CollectOre()
		return
	if(!client && isliving(target)) // Offense
		SetOffenseBehavior()
	if(stored_drill)
		stored_drill.melee_attack_chain(src, target) // Use the drill if the target's adjacent

/mob/living/simple_animal/hostile/mining_drone/OpenFire(atom/A)
	if(CheckFriendlyFire(A))
		return
	// Either attack with the PKA or the cutter. AI will always use the PKA when firing, but players may use a plasma cutter.
	if(mode == MINEDRONE_PKA || !stored_cutter)
		stored_pka.afterattack(A, src)
	else
		stored_cutter.afterattack(A, src)

/mob/living/simple_animal/hostile/mining_drone/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!client && mode != MINEDRONE_PKA && amount > 0)
		SetOffenseBehavior()
	. = ..()

// Minebot procs

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	mode = MINEDRONE_CUTTER
	vision_range = 9
	search_objects = 2
	wander = TRUE
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"
	if(stored_cutter)
		to_chat(src, "<span class='info'>You are set to mining mode. You will now fire your plasma cutter.</span>")
	else
		to_chat(src, "<span class='info'>You are set to mining mode. No plasma cutter detected.</span>")

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	mode = MINEDRONE_PKA
	vision_range = 7
	search_objects = 0
	retreat_distance = 2
	minimum_distance = 1
	icon_state = "mining_drone_offense"
	to_chat(src, "<span class='info'>You are set to attack mode. You will now fire your proto-kinetic accelerator at targets.</span>")

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre(collect_range = 1)
	for(var/obj/item/stack/ore/O in range(collect_range, src))
		O.forceMove(src)

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre()
	if(!contents.len)
		to_chat(src, "<span class='notice'>You attempt to dump your stored ore, but you have none.</span>")
		return
	to_chat(src, "<span class='notice'>You dump your stored ore.</span>")
	for(var/obj/item/stack/ore/O in contents)
		O.forceMove(drop_location())

/mob/living/simple_animal/hostile/mining_drone/proc/toggle_mode()
	switch(mode)
		if(MINEDRONE_PKA)
			SetCollectBehavior()
			return FALSE // Used for action icon states
		else
			SetOffenseBehavior()
			return TRUE

/mob/living/simple_animal/hostile/mining_drone/proc/uninstall_upgrades()
	for(var/obj/item/mine_bot_upgrade/upgrade as anything in installed_upgrades)
		upgrade.unequip()

// Allowing tool use (for plasma cutters, etc.)

/mob/living/simple_animal/hostile/mining_drone/IsAdvancedToolUser()
	return TRUE // Allow

// Actions for sentient minebots

/datum/action/innate/minedrone
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	background_icon_state = "bg_default"

/datum/action/innate/minedrone/toggle_meson_vision
	name = "Toggle Meson Vision"
	button_icon_state = "trayson-"

/datum/action/innate/minedrone/toggle_meson_vision/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	if(user.sight & SEE_TURFS)
		user.sight &= ~SEE_TURFS
		user.sight |= SEE_BLACKNESS
		user.lighting_alpha = initial(user.lighting_alpha)
		button_icon_state = "trayson-"
	else
		user.sight |= SEE_TURFS
		user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		button_icon_state = "trayson-meson"
	user.sync_lighting_plane_alpha()
	to_chat(user, "<span class='notice'>You toggle your meson vision [(user.sight & SEE_TURFS) ? "on" : "off"].</span>")
	UpdateButtonIcon()

/datum/action/innate/minedrone/toggle_light
	name = "Toggle Light"
	button_icon_state = "mech_lights_off"

/datum/action/innate/minedrone/toggle_light/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.set_light_on(!user.light_on)
	to_chat(user, "<span class='notice'>You toggle your light [user.light_on ? "on" : "off"].</span>")
	button_icon_state = "mech_lights_[user.light_on ? "on" : "off"]"
	UpdateButtonIcon()

/datum/action/innate/minedrone/toggle_mode
	name = "Toggle Mode"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/minedrone/toggle_mode/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.toggle_mode()
	button_icon_state = "mech_zoom_[user.mode == 1 ? "on" : "off"]"
	UpdateButtonIcon()

/// Allows a minebot to manually dump its own ore.
/datum/action/innate/minedrone/dump_ore
	name = "Dump Ore"
	button_icon_state = "mech_eject"

/datum/action/innate/minedrone/dump_ore/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.DropOre()
	to_chat(user, "<span class='notice'>You dump your stored ore on the ground.</span>")

/datum/action/innate/minedrone/toggle_scanner
	name = "Toggle Mining Scanner"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/minedrone/toggle_scanner/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.stored_scanner.toggle_on()
	to_chat(user, "<span class='notice'>You toggle your mining scanner [user.stored_scanner.on ? "on" : "off"].</span>")
	button_icon_state = "mech_cycle_equip_[user.stored_scanner.on ? "on" : "off"]"
	UpdateButtonIcon()

/**********************Minebot Upgrades**********************/
// Similar to PKA upgrades, except for minebots. Each upgrade can only be installed once and is stored in the minebot when installed.

// Proc to get the minebot upgrades currently installed in a minebot
/mob/living/simple_animal/hostile/mining_drone/proc/get_mods()
	if(!LAZYLEN(installed_upgrades))
		return FALSE
	. = list()
	for(var/M as anything in installed_upgrades)
		var/obj/item/mine_bot_upgrade/upgrade = M
		. += upgrade

//Base

/obj/item/mine_bot_upgrade
	name = "generic minebot upgrade"
	desc = "Some sort of minebot upgrage. It doesn't seem to do anything."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	var/mob/living/simple_animal/hostile/mining_drone/linked_bot

/obj/item/mine_bot_upgrade/Destroy()
	unequip()
	return ..()

/obj/item/mine_bot_upgrade/afterattack(mob/living/simple_animal/hostile/mining_drone/M, mob/user, proximity)
	. = ..()
	if(!istype(M) || !proximity)
		return
	if(!istype(M))
		return ..()
	upgrade_bot(M, user)

/obj/item/mine_bot_upgrade/proc/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.get_mods() && is_type_in_list(src, M.get_mods()))
		M.balloon_alert(user, "A similar mod has already been installed.")
		return FALSE
	if(!user.transferItemToLoc(src, M))
		return FALSE
	linked_bot = M
	LAZYADD(linked_bot.installed_upgrades, src)
	to_chat(user, "<span class='notice'>You install the [src].</span>")
	playsound(loc, 'sound/items/screwdriver.ogg', 100, 1)
	return TRUE

/obj/item/mine_bot_upgrade/proc/unequip()
	LAZYREMOVE(linked_bot.installed_upgrades, src)
	forceMove(get_turf(linked_bot))
	linked_bot = null

/obj/item/mine_bot_upgrade/proc/onAltClick(atom/A) // For handling special actions
	return

// Health Bonus

/obj/item/mine_bot_upgrade/health
	name = "minebot armor upgrade"
	desc = "A minebot upgrade that improves armor."

/obj/item/mine_bot_upgrade/health/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(!..())
		return
	M.maxHealth += health_upgrade
	M.updatehealth()

/obj/item/mine_bot_upgrade/health/unequip()
	linked_bot.maxHealth -= 45
	linked_bot.updatehealth()
	..()

// Automatic Ore Pickup

/obj/item/mine_bot_upgrade/ore_pickup
	name = "minebot ore scoop upgrade"
	desc = "Allows a minebot to automatically pick up ores while moving."

/obj/item/mine_bot_upgrade/ore_pickup/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(!..())
		return
	RegisterSignal(M, COMSIG_MOVABLE_MOVED, .proc/automatic_pickup)

/obj/item/mine_bot_upgrade/ore_pickup/unequip()
	UnregisterSignal(linked_bot, COMSIG_MOVABLE_MOVED)
	..()

/obj/item/mine_bot_upgrade/ore_pickup/proc/automatic_pickup()
	SIGNAL_HANDLER
	linked_bot.CollectOre(0) // No automatically picking up adjacent ore, otherwise the bot will infinitely pick up any ore that they drop when they try to move away.

// Medical

/obj/item/mine_bot_upgrade/medical
	name = "minebot medical upgrade"
	desc = "Allows a sentient minebot to carry and administer a medipen. Comes equipped with an epinephrine medipen by default, but can accept other medipens as well."
	var/obj/item/reagent_containers/hypospray/medipen/stored_medipen

/obj/item/mine_bot_upgrade/medical/Initialize()
	. = ..()
	stored_medipen = new /obj/item/reagent_containers/hypospray/medipen(src)

/obj/item/mine_bot_upgrade/medical/Destroy()
	qdel(stored_medipen)
	return ..()

/obj/item/mine_bot_upgrade/medical/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/reagent_containers/hypospray/medipen))
		stored_medipen.forceMove(get_turf(src))
		I.forceMove(src)
		to_chat(user, "You replace [stored_medipen] with [I].</span>")
		stored_medipen = I
	else
		return ..()

/obj/item/mine_bot_upgrade/medical/onAltClick(atom/A)
	if(!linked_bot.Adjacent(A))
		return
	if(istype(A, /mob/living/carbon))
		if(!stored_medipen.reagents.total_volume) // Make sure the medipen actually has something in it before injecting
			linked_bot.balloon_alert(linked_bot, "Your medipen is empty!")
			return
		stored_medipen.attack(A, linked_bot)
		return
	if(istype(A, /obj/item/reagent_containers/hypospray/medipen))
		var/obj/item/reagent_containers/hypospray/medipen/M = A
		if(!stored_medipen.reagents.total_volume) // Delete a used medipen, otherwise just drop the old medipen on the ground before picking up a new one
			qdel(stored_medipen)
		else
			stored_medipen.forceMove(get_turf(linked_bot))
		M.forceMove(src)
		stored_medipen = A
		to_chat(linked_bot, "<span class='notice'>Loaded [A] to onboard medical module.</span>")

// Minebot Sentience

/obj/item/slimepotion/slime/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	sentience_type = SENTIENCE_MINEBOT

#undef MINEDRONE_PKA
#undef MINEDRONE_CUTTER
