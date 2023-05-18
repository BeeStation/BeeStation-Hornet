/**********************Mining drone**********************/

#define MODE_COMBAT "combat" /// Combat mode for AI, PKA usage mode for players
#define MODE_MINING "mining" /// Ore collection/mining mode for AI, plasma cutter usage mode for players

/mob/living/simple_animal/hostile/mining_drone
	name = "minebot"
	desc = "A small robot used to support miners. It can be set to search and collect loose ore, mine any ore it detects, or help fend off wildlife. It is equipped with a mining drill and kinetic accelerator, with mounting points for a plasma cutter."
	gender = NEUTER
	icon = 'icons/mob/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	icon_dead = "mining_drone_disabled"
	status_flags = CANSTUN|CANKNOCKDOWN|CANPUSH
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1 // So our equipment doesn't go poof
	mouse_opacity = MOUSE_OPACITY_ICON
	faction = list("neutral")
	a_intent = INTENT_HARM
	hud_type = /datum/hud/minebot
	// Atmos
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	// Health/damage
	health = 125
	maxHealth = 125
	melee_damage = 15
	obj_damage = 10
	environment_smash = ENVIRONMENT_SMASH_NONE
	healable = 0
	deathmessage = "stops moving"
	// AI stuff
	check_friendly_fire = TRUE
	move_to_delay = 5
	ranged = TRUE
	sentience_type = SENTIENCE_MINEBOT
	stop_automated_movement_when_pulled = TRUE
	wander = FALSE
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/plasma, /obj/item/stack/ore/uranium, /obj/item/stack/ore/iron,
						  /obj/item/stack/ore/bananium, /obj/item/stack/ore/titanium)
	// Response verbs
	response_help = "pets"
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	speak_emote = list("states")
	// Light handling
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_on = FALSE
	// Minebot-specific vars
	var/mode = MODE_MINING /// What mode the minebot is in
	var/mining_enabled = FALSE /// Whether or not the minebot will mine new ores while in mining mode.
	var/list/installed_upgrades /// A list of all the minebot's installed upgrades
	var/obj/item/gun/energy/kinetic_accelerator/minebot/stored_pka /// The minebot's stored PKA
	var/obj/item/gun/energy/plasmacutter/stored_cutter /// The minebot's stored plasma cutter
	var/obj/item/pickaxe/drill/stored_drill /// The minebot's stored drill
	var/obj/item/t_scanner/adv_mining_scanner/stored_scanner /// The minebot's stored mining scanner

/mob/living/simple_animal/hostile/mining_drone/Initialize(mapload)
	. = ..()
	// Setup equipment
	stored_pka = new(src)
	stored_drill = new(src)
	stored_scanner = new /obj/item/t_scanner/adv_mining_scanner/lesser(src) // No full-power scanner right off the bat

	// Keep track of our equipment
	RegisterSignal(stored_pka, COMSIG_PARENT_QDELETING, PROC_REF(on_pka_qdel))
	RegisterSignal(stored_drill, COMSIG_PARENT_QDELETING, PROC_REF(on_drill_qdel))
	RegisterSignal(stored_scanner, COMSIG_PARENT_QDELETING, PROC_REF(on_scanner_qdel))

	// Setup actions
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
	imp.implant(src, force = TRUE)

	// Setup access
	access_card = new /obj/item/card/id(src)
	var/datum/job/shaft_miner/M = new
	grant_accesses_to_card(access_card.card_access, M.get_access())


/mob/living/simple_animal/hostile/mining_drone/Destroy()
	for(var/datum/action/innate/minedrone/action in actions)
		qdel(action)

	// Clear any equipment they might have
	QDEL_LAZYLIST(installed_upgrades)
	QDEL_NULL(stored_pka)
	QDEL_NULL(stored_cutter)
	QDEL_NULL(stored_drill)
	QDEL_NULL(stored_scanner)
	return ..()

/mob/living/simple_animal/hostile/mining_drone/update_health_hud()
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			if(health >= maxHealth)
				hud_used.healths.icon_state = "health0"
			else if(health > maxHealth * 0.7)
				hud_used.healths.icon_state = "health2"
			else if(health > maxHealth * 0.4)
				hud_used.healths.icon_state = "health3"
			else if(health > maxHealth * 0.2)
				hud_used.healths.icon_state = "health4"
			else
				hud_used.healths.icon_state = "health5"
		else
			hud_used.healths.icon_state = "health7"

// Shows basic data about equipment and sentience status
/mob/living/simple_animal/hostile/mining_drone/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health >= maxHealth * 0.75)
			. += "<span class='warning'>It looks slightly dented.</span>"
		else if(health >= maxHealth * 0.25)
			. += "<span class='warning'>It looks <b>moderately</b> dented.</span>"
		else if(health > 0)
			. += "<span class='boldwarning'>It looks severely dented!</span>"
		else
			. += "<span class='boldwarning'>It is disabled and requires repairs.</span>"
	. += "<span class='notice'>Alt-clicking it will instruct it to drop any stored ore.</span>"
	. += "<span class='notice'>Field repairs can be performed with a welder.</span>"
	if(stored_pka && stored_pka.max_mod_capacity)
		. += "<span class='notice'>\The [stored_pka] has <b>[stored_pka.get_remaining_mod_capacity()]%</b> mod capacity remaining.</span>"
		for(var/A as anything in stored_pka.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			. += "<span class='notice'>There is \a [M] installed, using <b>[M.cost]%</b> capacity.</span>"
	if(stored_cutter)
		. += "<span class='notice'>There is \a [stored_cutter] installed on its plasma cutter mount. The charge meter reads [round(stored_cutter.cell.percent())]%.</span>"
	else
		. += "<span class='notice'>There is nothing on its plasma cutter mount.</span>"
	. += "<span class='notice'>There is \a [stored_drill] installed on its drill mount.</span>"
	if(client)
		. += "<span class='notice'>Its AI light is on.</span>"

/// Generates the stat tab for player-controlled minebots
/mob/living/simple_animal/hostile/mining_drone/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Mode"] = GENERATE_STAT_TEXT("[mode]")

	// Handles Equipment
	if(stored_cutter)
		tab_data["Plasma Cutter Charge"] = GENERATE_STAT_TEXT("[round(stored_cutter.cell.percent())]%")
	tab_data["Equipped Drill"] = GENERATE_STAT_TEXT("[stored_drill]")

	// Handles Upgrades
	if(LAZYLEN(installed_upgrades))
		for(var/obj/item/minebot_upgrade/U as anything in installed_upgrades)
			var/upgrade_data = U.get_stat_data()
			if(upgrade_data)
				tab_data[upgrade_data[1]] = GENERATE_STAT_TEXT(upgrade_data[2])
	return tab_data

/// Repairing/reviving minebots
/mob/living/simple_animal/hostile/mining_drone/welder_act(mob/living/user, obj/item/welder)
	if(istype(welder, /obj/item/gun/energy/plasmacutter) && maxHealth == health) // So we don't show the welding message while installing a plasma cutter
		return
	if(maxHealth == health)
		to_chat(user, "<span class='info'>[src] is at full integrity.</span>")
		return TRUE
	if(welder.use_tool(src, user, 0, volume = 40))
		if(stat == DEAD && health > 0)
			to_chat(user, "<span class='info'>You restart [src].</span>")
			revive()
			return TRUE
		adjustBruteLoss(-15)
		to_chat(user, "<span class='info'>You repair some of the armor on [src].</span>")
		return TRUE

/// Allows sentient minebots to FF
/mob/living/simple_animal/hostile/mining_drone/sentience_act()
	..()
	check_friendly_fire = FALSE

/// Handles installing new tools/upgrades and interacting with the minebot
/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/item, mob/user, params)
	if(user == src)
		return TRUE // Returning true in most cases prevents afterattacks from going off and whacking/shooting the minebot
	if(user.a_intent != INTENT_HELP)
		return ..() // For smacking
	if(istype(item, /obj/item/minebot_upgrade))
		if(!do_after(user, 20, src))
			return TRUE
		var/obj/item/minebot_upgrade/upgrade = item
		upgrade.upgrade_bot(src, user)
		return TRUE
	if(istype(item, /obj/item/t_scanner/adv_mining_scanner))
		if(!do_after(user, 20, src))
			return TRUE
		stored_scanner.forceMove(get_turf(src))
		UnregisterSignal(stored_scanner, COMSIG_PARENT_QDELETING)
		item.forceMove(src)
		stored_scanner = item
		RegisterSignal(stored_scanner, COMSIG_PARENT_QDELETING, PROC_REF(on_scanner_qdel))
		to_chat(user, "<span class='info'>You install [item].</span>")
		return TRUE
	if(istype(item, /obj/item/borg/upgrade/modkit))
		if(!do_after(user, 20, src))
			return TRUE
		item.melee_attack_chain(user, stored_pka, params) // This handles any install messages
		return TRUE
	if(item.tool_behaviour == TOOL_CROWBAR)
		uninstall_upgrades()
		to_chat(user, "<span class='info'>You uninstall [src]'s upgrades.</span>")
		return TRUE
	if(istype(item, /obj/item/gun/energy/plasmacutter))
		if(health != maxHealth)
			return // For repairs
		if(!do_after(user, 20, src))
			return TRUE
		if(stored_cutter)
			stored_cutter.forceMove(get_turf(src))
			stored_cutter.requires_wielding = initial(stored_cutter.requires_wielding)
			UnregisterSignal(stored_cutter, COMSIG_PARENT_QDELETING)
		item.forceMove(src)
		stored_cutter = item
		RegisterSignal(stored_cutter, COMSIG_PARENT_QDELETING, PROC_REF(on_cutter_qdel))
		stored_cutter.requires_wielding = FALSE // Prevents inaccuracy when firing for the minebot.
		to_chat(user, "<span class='info'>You install [item].</span>")
		return TRUE
	if(istype(item, /obj/item/pickaxe/drill))
		if(!do_after(user, 20, src))
			return TRUE
		if(stored_drill)
			stored_drill.forceMove(get_turf(src))
			UnregisterSignal(stored_drill, COMSIG_PARENT_QDELETING)
		item.forceMove(src)
		stored_drill = item
		RegisterSignal(stored_drill, COMSIG_PARENT_QDELETING, PROC_REF(on_drill_qdel))
		to_chat(user, "<span class='info'>You install [item].</span>")
		return TRUE
	..()
	check_friendly_fire = FALSE

// Procs handling deletion of items
/mob/living/simple_animal/hostile/mining_drone/proc/on_scanner_qdel()
	SIGNAL_HANDLER
	UnregisterSignal(stored_scanner, COMSIG_PARENT_QDELETING)
	stored_scanner = null

/mob/living/simple_animal/hostile/mining_drone/proc/on_drill_qdel()
	SIGNAL_HANDLER
	UnregisterSignal(stored_drill, COMSIG_PARENT_QDELETING)
	stored_drill = null

/mob/living/simple_animal/hostile/mining_drone/proc/on_pka_qdel(datum/source, forced)
	SIGNAL_HANDLER
	UnregisterSignal(stored_pka, COMSIG_PARENT_QDELETING)
	stored_pka = null

/mob/living/simple_animal/hostile/mining_drone/proc/on_cutter_qdel()
	SIGNAL_HANDLER
	UnregisterSignal(stored_cutter, COMSIG_PARENT_QDELETING)
	stored_cutter = null

/// EMPs stun and do some damage
/mob/living/simple_animal/hostile/mining_drone/emp_act(severity)
	. = ..()
	switch(severity)
		if(1)
			Stun(10 SECONDS)
			take_bodypart_damage(25) // 20% of HP
		if(2)
			Stun(5 SECONDS)
			take_bodypart_damage(10) // Bit less than 10% of HP
	to_chat(src, "<span class='userdanger'>*BZZZT*</span>")

/// Handles humans toggling minebot modes
/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent != INTENT_HELP) // Smacking/grabbing
		return ..()
	if(client) // No messing with the minebot while there's a player inside it.
		to_chat(user, "<span class='info'>[src]'s equipment is currently slaved to its onboard AI. Best not to touch it.</span>")
		return ..()
	if(mode == MODE_MINING && !mining_enabled)
		mining_enabled = TRUE
	else // Either we've got mining enabled and want to switch to combat, or we're switching to ore pickup
		mining_enabled = FALSE
		toggle_mode()
	switch(mode)
		if(MODE_MINING)
			if(mining_enabled)
				to_chat(user, "<span class='info'>[src] has been set to mine any detected ore.</span>")
				return
			to_chat(user, "<span class='info'>[src] has been set to search and store loose ore.</span>")
		if(MODE_COMBAT)
			to_chat(user, "<span class='info'>[src] has been set to attack hostile wildlife.</span>")

/// Handles dropping ore
/mob/living/simple_animal/hostile/mining_drone/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	to_chat(user, "<span class='info'>You instruct [src] to drop any collected ore.</span>")
	drop_ore()

/// Handles activating installed minebot mods
/mob/living/simple_animal/hostile/mining_drone/AltClickOn(atom/target)
	. = ..()
	if(!LAZYLEN(installed_upgrades))
		return
	for(var/obj/item/minebot_upgrade/upgrade as anything in installed_upgrades)
		upgrade.onAltClick(target)

/// Minebot passthrough handling (for the PKA upgrade and crushers)
/mob/living/simple_animal/hostile/mining_drone/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/item/projectile/kinetic))
		var/obj/item/projectile/kinetic/kinetic_proj = mover
		if(kinetic_proj.kinetic_gun)
			for(var/A as anything in kinetic_proj.kinetic_gun.get_modkits())
				var/obj/item/borg/upgrade/modkit/modkit = A
				if(istype(modkit, /obj/item/borg/upgrade/modkit/minebot_passthrough))
					return TRUE
	else if(istype(mover, /obj/item/projectile/destabilizer))
		return TRUE

/**********************Minebot Attack Handling**********************/

/// Melee attack handling
/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(client && istype(target, /obj/machinery/computer))
		target.ui_interact(src)
		return
	if(stored_cutter && (istype(target, /obj/item/stack/ore/plasma) || istype(target, /obj/item/stack/sheet/mineral/plasma)) && mode == MODE_MINING) //Charging the on-board plasma cutter
		stored_cutter.attackby(target, src)
		if(stored_cutter.cell.charge == stored_cutter.cell.maxcharge) // Either charge the cutter or pick up the plasma if the cutter's full
			collect_ore()
		return
	if(istype(target, /obj/item/stack/ore)) // Collecting ore
		collect_ore()
		return
	if(!client && isliving(target)) // Switching to offense mode if we've got a target
		set_offense_behavior()
	if(stored_drill)
		stored_drill.melee_attack_chain(src, target) // Use the drill if the target's adjacent

/// Ranged attack handling (PKA/plasma cutter)
/mob/living/simple_animal/hostile/mining_drone/OpenFire(atom/target)
	if(CheckFriendlyFire(target))
		return
	if(!client && istype(target, /obj/item/stack/ore)) // Prevents the AI from shooting ore
		return
	// Either attack with the PKA or the cutter. The cutter takes priority in mining mode, but if we're out of ammo or don't have one, we use the PKA.
	if(mode == MODE_COMBAT || !stored_cutter || !stored_cutter.can_shoot())
		stored_pka.afterattack(target, src)
	else
		stored_cutter.afterattack(target, src)

/// Handles reacting to attacks, getting the minebot in combat mode if it was mining.
/mob/living/simple_animal/hostile/mining_drone/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!client && mode != MODE_COMBAT && amount > 0) // We don't want to automatically switch it if a player's in control
		set_offense_behavior()
	update_health_hud()
	. = ..()

/**********************Minebot AI Handling**********************/

/// Allows the minebot to find ore through rocks, limited by the installed scanner's maximum range.
/mob/living/simple_animal/hostile/mining_drone/ListTargets()
	var/search_objects = orange(stored_scanner.range, GET_TARGETS_FROM(src))
	if(mode == MODE_MINING)
		. = list()
		for(var/object in search_objects)
			if(istype(object, /obj/item/stack/ore))
				LAZYADD(., object)
			if(mining_enabled && istype(object, /turf/closed/mineral))
				LAZYADD(., object)
		return
	. = ..()

/// Effectively the same as standard target listing
/mob/living/simple_animal/hostile/mining_drone/ListTargetsLazy(var/_Z)
	if(mode == MODE_MINING)
		return ListTargets()
	. = ..()

// We always attack the nearest target if we're in mining mode, so we don't go wandering off or leave ore on the ground.
/mob/living/simple_animal/hostile/mining_drone/PickTarget(list/Targets)
	if(mode == MODE_MINING)
		var/atom/target_from = GET_TARGETS_FROM(src)
		var/closest_target
		var/closest_distance
		for(var/target in Targets)
			var/distance = get_dist(target_from, target)
			if(!closest_target)
				closest_distance = distance
				closest_target = target
			else
				if(closest_distance > distance)
					closest_distance = distance
					closest_target = target
		return closest_target
	// No special targeting if we're in combat mode
	. = ..()

/// Handles mining, otherwise acts the same as simple_animal/hostile.
/mob/living/simple_animal/hostile/mining_drone/CanAttack(atom/A)
	if(mining_enabled && istype(A, /turf/closed/mineral)) // Normally CanAttack() skips over turfs, but we'll sometimes want to attack mineral turfs
		var/turf/closed/mineral/T = A
		for(var/turf/closed/obstructing_turf in getline(src,A))
			if(!istype(obstructing_turf, /turf/closed/mineral)) // No trying to mine through non-rock turfs
				return ..()
		if(T.mineralType)
			return TRUE
	if(search_objects && (!isturf(A) && !istype(A.loc, /turf))) // No trying to mine ore inside inventories
		return
	. = ..()

/**********************Minebot Procs**********************/

/// Sets the minebot's simplemob AI to focus on collecting ore.
/mob/living/simple_animal/hostile/mining_drone/proc/set_collect_behavior()
	mode = MODE_MINING
	vision_range = 9
	search_objects = 2
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"
	if(!client) // No point showing messages if we don't have a client
		return
	if(stored_cutter)
		to_chat(src, "<span class='info'>You are set to mining mode. You will now fire your plasma cutter.</span>")
		return
	to_chat(src, "<span class='info'>You are set to mining mode. No plasma cutter detected.</span>")

/// Sets the minebot's simplemob AI to focus on attacking targets. Also makes sure the minebot keeps its distance.
/mob/living/simple_animal/hostile/mining_drone/proc/set_offense_behavior()
	mode = MODE_COMBAT
	vision_range = 7
	search_objects = 0
	retreat_distance = 2
	minimum_distance = 1
	icon_state = "mining_drone_offense"
	if(!client) // No point showing messages if we don't have a client
		return
	to_chat(src, "<span class='info'>You are set to attack mode. You will now fire your proto-kinetic accelerator at targets.</span>")

/// Collects the ore in collect_range radius around the minebot.
/mob/living/simple_animal/hostile/mining_drone/proc/collect_ore(collect_range = 1)
	for(var/obj/item/stack/ore/orestack in range(collect_range, src))
		orestack.forceMove(src)

/// Drops the minebot's stored ore.
/mob/living/simple_animal/hostile/mining_drone/proc/drop_ore()
	var/dumped_ore = FALSE
	for(var/obj/item/stack/ore/orestack in contents)
		orestack.forceMove(drop_location())
		if(!dumped_ore)
			dumped_ore = TRUE
	if(!client)
		return
	if(!dumped_ore)
		to_chat(src, "<span class='notice'>You attempt to dump your stored ore, but you have none.</span>")
		return
	to_chat(src, "<span class='notice'>You dump your stored ore.</span>")

/// Toggles between collect/combat behavior.
/mob/living/simple_animal/hostile/mining_drone/proc/toggle_mode()
	if(mode == MODE_COMBAT)
		set_collect_behavior()
		return
	set_offense_behavior()

/// Uninstalls the upgrades in a minebot.
/mob/living/simple_animal/hostile/mining_drone/proc/uninstall_upgrades()
	if(!LAZYLEN(installed_upgrades))
		return
	for(var/obj/item/minebot_upgrade/upgrade as anything in installed_upgrades)
		upgrade.unequip()

/// Allows a minebot to use things like plasma cutters.
/mob/living/simple_animal/hostile/mining_drone/IsAdvancedToolUser()
	return TRUE // Allow

/**********************Minebot Actions**********************/
// Used when a player's in control of a minebot.

/datum/action/innate/minedrone
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	background_icon_state = "bg_default"

/// Toggles a minebot's inbuilt meson scanners.
/datum/action/innate/minedrone/toggle_meson_vision
	name = "Toggle Meson Vision"
	icon_icon = 'icons/obj/clothing/glasses.dmi'
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
		user.sight &= ~SEE_BLACKNESS
		user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		button_icon_state = "trayson-meson"
	user.sync_lighting_plane_alpha()
	to_chat(user, "<span class='notice'>You toggle your meson vision [(user.sight & SEE_TURFS) ? "on" : "off"].</span>")
	UpdateButtonIcon()

/// Toggles a minebot's inbuilt light.
/datum/action/innate/minedrone/toggle_light
	name = "Toggle Light"
	button_icon_state = "mech_lights_off"

/datum/action/innate/minedrone/toggle_light/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.set_light_on(!user.light_on)
	to_chat(user, "<span class='notice'>You toggle your light [user.light_on ? "on" : "off"].</span>")
	button_icon_state = "mech_lights_[user.light_on ? "on" : "off"]"
	UpdateButtonIcon()

/// Toggles the minebot's mode from combat to mining mode, effectively switching between the minebot's plasma cutter and PKA.
/datum/action/innate/minedrone/toggle_mode
	name = "Toggle Mode"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/minedrone/toggle_mode/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.toggle_mode()
	button_icon_state = "mech_zoom_[user.mode == MODE_COMBAT ? "on" : "off"]"
	UpdateButtonIcon()

/// Allows a minebot to manually dump its own ore.
/datum/action/innate/minedrone/dump_ore
	name = "Dump Ore"
	button_icon_state = "mech_eject"

/datum/action/innate/minedrone/dump_ore/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.drop_ore()

/// Toggles a minebot's mining scanner on and off.
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

// Base
/// The abstract for minebot upgrades. This handles all the equipping/unequipping stuff so we don't have to repeat it for each upgrade.
/obj/item/minebot_upgrade
	name = "generic minebot upgrade"
	desc = "A generic minebot upgrade. It doesn't seem to do anything."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	var/mob/living/simple_animal/hostile/mining_drone/linked_bot

/obj/item/minebot_upgrade/Destroy()
	unequip()
	return ..()

/// Handles adding upgrades. This checks for any duplicate mods and links the mod to the minebot. Returns FALSE if the upgrade fails, otherwise returns TRUE
/obj/item/minebot_upgrade/proc/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/minebot, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(is_type_in_list(src, minebot.installed_upgrades))
		minebot.balloon_alert(user, "A similar mod has already been installed.")
		return FALSE
	if(!user.transferItemToLoc(src, minebot))
		return FALSE
	linked_bot = minebot
	LAZYADD(linked_bot.installed_upgrades, src)
	to_chat(user, "<span class='notice'>You install [src].</span>")
	playsound(loc, 'sound/items/screwdriver.ogg', 100, 1)
	return TRUE

/// Handles removing upgrades. This handles unlinking the minebot as well, so it should be called after any upgrade-specific unequip actions.
/obj/item/minebot_upgrade/proc/unequip()
	SHOULD_CALL_PARENT(TRUE)
	LAZYREMOVE(linked_bot.installed_upgrades, src)
	forceMove(get_turf(linked_bot))
	linked_bot = null

/// For handling special minebot actions (currently just for the medical upgrade)
/obj/item/minebot_upgrade/proc/onAltClick(atom/A)
	return

/// Allows a minebot upgrade to put stat data into the minebot's stat panel. This should return a 2-entry list with the data to be inserted into the statpanel.
/obj/item/minebot_upgrade/proc/get_stat_data()
	return

// Health Bonus
// Gives a health bonus to the minebot.
/obj/item/minebot_upgrade/health
	name = "minebot armor upgrade"
	desc = "Improves a minebot's armor, allowing them to sustain more damage before being disabled."
	var/health_upgrade = 45

/obj/item/minebot_upgrade/health/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/minebot, mob/user)
	if(!..())
		return
	minebot.maxHealth += health_upgrade
	minebot.updatehealth()

/obj/item/minebot_upgrade/health/unequip()
	linked_bot.maxHealth -= health_upgrade
	linked_bot.updatehealth()
	..()

// Automatic Ore Pickup
/// This allows a minebot to automatically pick up ore as they walk over it.
/obj/item/minebot_upgrade/ore_pickup
	name = "minebot ore scoop upgrade"
	desc = "Allows a minebot to automatically pick up ores while moving."

/obj/item/minebot_upgrade/ore_pickup/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/minebot, mob/user)
	if(!..())
		return
	RegisterSignal(minebot, COMSIG_MOVABLE_MOVED, PROC_REF(automatic_pickup))

/obj/item/minebot_upgrade/ore_pickup/unequip()
	UnregisterSignal(linked_bot, COMSIG_MOVABLE_MOVED)
	..()

/// This proc handles the actual collecting of ore on movement.
/obj/item/minebot_upgrade/ore_pickup/proc/automatic_pickup()
	SIGNAL_HANDLER
	linked_bot.collect_ore(0) // No automatically picking up adjacent ore, otherwise the bot will infinitely pick up any ore that they drop when they try to move away.

// Medical
/// This allows a minebot to carry medipens and use them on other mobs (ideally dying miners).
/obj/item/minebot_upgrade/medical
	name = "minebot medical upgrade"
	desc = "Allows a sentient minebot to carry and administer a medipen."
	var/obj/item/reagent_containers/hypospray/medipen/stored_medipen

/obj/item/minebot_upgrade/medical/Initialize()
	. = ..()
	stored_medipen = new /obj/item/reagent_containers/hypospray/medipen(src)

/obj/item/minebot_upgrade/medical/Destroy()
	qdel(stored_medipen)
	. = ..()

/obj/item/minebot_upgrade/medical/examine(mob/user)
	. = ..()
	if(stored_medipen)
		. += "<span class='notice'>[src] contains \a [stored_medipen].</span>"
		return
	. += "<span class='notice'>There's no medipen attached to [src].</span>"

// Lets the minebot see what medipen they have loaded.
/obj/item/minebot_upgrade/medical/get_stat_data()
	if(stored_medipen)
		return list("Stored Medipen", "[stored_medipen]")
	return list("Stored Medipen", "None")

// Handles manually loading/unloading medipens.
/obj/item/minebot_upgrade/medical/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/reagent_containers/hypospray/medipen))
		if(stored_medipen)
			to_chat(user, "<span class='notice'>You replace [stored_medipen] with [item].</span>")
			stored_medipen.forceMove(get_turf(src))
		else
			to_chat(user, "<span class='notice'>You attach [item] to [src].</span>")
		item.forceMove(src)
		stored_medipen = item
		return TRUE
	if(item.tool_behaviour == TOOL_SCREWDRIVER)
		stored_medipen.forceMove(get_turf(src))
		stored_medipen = null
		to_chat(user, "<span class='notice'>You remove [stored_medipen] from [src].</span>")
		return TRUE
	. = ..()

/// Handles using the medical upgrade. If the target's a mob, we use the medipen on that mob. If it's a medipen, we replace our medipen with that medipen.
/obj/item/minebot_upgrade/medical/onAltClick(atom/target)
	if(!linked_bot.Adjacent(target))
		return
	if(istype(target, /mob/living/carbon))
		if(stored_medipen)
			stored_medipen.attack(target, linked_bot)
		return
	if(istype(target, /obj/item/reagent_containers/hypospray/medipen))
		var/obj/item/reagent_containers/hypospray/medipen/new_medipen = target
		if(!stored_medipen.reagents.total_volume) // Deletes used medipens, otherwise drops the old medipen on the ground and loads a new one
			qdel(stored_medipen)
		else
			stored_medipen.forceMove(get_turf(linked_bot))
		new_medipen.forceMove(src)
		stored_medipen = target
		to_chat(linked_bot, "<span class='notice'>Loaded \a [new_medipen] to onboard medical module.</span>")

// Anti-Weather
// This allows a minebot to survive lava and ash storms
/obj/item/minebot_upgrade/antiweather
	name = "minebot weatherproof chassis"
	desc = "A chassis reinforcement kit that allows a minebot to withstand exposure to high winds and molten rock."

/obj/item/minebot_upgrade/antiweather/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/minebot, mob/user)
	. = ..()
	minebot.weather_immunities += "lava"
	minebot.weather_immunities += "ash"

/obj/item/minebot_upgrade/antiweather/unequip()
	linked_bot.weather_immunities -= "lava"
	linked_bot.weather_immunities -= "ash"
	. = ..()

// Minebot Sentience

/obj/item/slimepotion/slime/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	sentience_type = SENTIENCE_MINEBOT
	var/cooldown_time = 600
	var/timer

/obj/item/slimepotion/slime/sentience/mining/attack(mob/living/M, mob/user)
	if(timer > world.time)
		to_chat(user, "<span class='warning'>Please wait [(timer - world.time)/10] seconds before trying again.</span>")
		return
	timer = world.time + cooldown_time
	..()

#undef MODE_COMBAT
#undef MODE_MINING
