/datum/holoparasite_ability/lesser/teleport
	name = "Teleportation Pad"
	desc = "The $theme can prepare a bluespace teleportation pad, where it can then create quantum tunnels to warp things to said beacon afterwards."
	ui_icon = "rocket"
	cost = 2
	thresholds = list(
		list(
			"stat" = "Potential",
			"desc" = "Reduces the cooldown for placing a bluespace beacon."
		),
		list(
			"stat" = "Potential",
			"minimum" = 4,
			"desc" = "The $theme will no longer leave behind visible bluespace tears when warping."
		),
		list(
			"stat" = "Range",
			"minimum" = 5,
			"desc" = "The $theme can warp things to a beacon located on a different Z-level."
		)
	)
	/// The placed bluespace beacon that the holoparasite can warp things to.
	var/obj/structure/receiving_pad/beacon
	/// Whether the holoparasite is currently attempting to warp something.
	var/warping = FALSE
	/// Whether the holoparasite is currently attempting to place a beacon..
	var/placing = FALSE
	/// Whether the holoparasite leaves a visible bluespace tear behind when warping.
	var/leaves_tear_behind = FALSE
	/// Whether the holoparasite can warp to a beacon on a different Z-level.
	var/cross_z_warping = TRUE
	/// If the holoparasite is in warp mode - where it will try to warp whatever it clicks on.
	var/warp_mode = FALSE
	/// The HUD button used to deploy a warp beacon.
	var/atom/movable/screen/holoparasite/teleport/deploy/deploy_hud
	/// The HUD button used to warp something to the previously placed beacon.
	var/atom/movable/screen/holoparasite/teleport/warp/warp_hud
	/// Cooldown for placing a bluespace beacon.
	COOLDOWN_DECLARE(deploy_cooldown)
	/// Cooldown for warping to a beacon.
	COOLDOWN_DECLARE(warp_cooldown)

/datum/holoparasite_ability/lesser/teleport/Destroy()
	. = ..()
	QDEL_NULL(beacon)
	QDEL_NULL(deploy_hud)
	QDEL_NULL(warp_hud)

/datum/holoparasite_ability/lesser/teleport/apply()
	..()
	leaves_tear_behind = master_stats.potential < 4
	cross_z_warping = master_stats.potential >= 5

/datum/holoparasite_ability/lesser/teleport/register_signals()
	..()
	RegisterSignal(owner, COMSIG_HOLOPARA_SETUP_HUD, PROC_REF(on_hud_setup))
	RegisterSignal(owner, COMSIG_HOLOPARA_STAT, PROC_REF(on_stat))
	RegisterSignal(owner, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_attack))

/datum/holoparasite_ability/lesser/teleport/unregister_signals()
	..()
	UnregisterSignal(owner, list(COMSIG_HOLOPARA_SETUP_HUD, COMSIG_HOLOPARA_STAT, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))

/datum/holoparasite_ability/lesser/teleport/proc/on_hud_setup(datum/_source, datum/hud/holoparasite/hud, list/huds_to_add)
	SIGNAL_HANDLER
	if(QDELETED(deploy_hud))
		deploy_hud = new(null, owner, src)
	if(QDELETED(warp_hud))
		warp_hud = new(null, owner, src)
	huds_to_add += list(deploy_hud, warp_hud)

/**
 * Adds cooldown info to the holoparasite's stat panel.
 */
/datum/holoparasite_ability/lesser/teleport/proc/on_stat(datum/_source, list/tab_data)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, deploy_cooldown))
		tab_data["Beacon Deployment Cooldown"] = GENERATE_STAT_TEXT(COOLDOWN_TIMELEFT_TEXT(src, deploy_cooldown))
	if(!COOLDOWN_FINISHED(src, warp_cooldown))
		tab_data["Warp Cooldown"] = GENERATE_STAT_TEXT(COOLDOWN_TIMELEFT_TEXT(src, warp_cooldown))

/**
 * Attempts to teleport something to the holoparasite's bluespace beacon.
 */
/datum/holoparasite_ability/lesser/teleport/proc/on_attack(datum/_source, atom/movable/target)
	SIGNAL_HANDLER
	ASSERT_ABILITY_USABILITY
	if(!warp_mode || !istype(target))
		return
	if(!owner.is_manifested())
		to_chat(owner, span_dangerbold("You must be manifested to warp a target!"))
		return
	if(warping)
		to_chat(owner, span_dangerbold("You are already in the process of warping something!"))
		return
	if(!COOLDOWN_FINISHED(src, warp_cooldown))
		to_chat(owner, span_dangerbold("You must wait [COOLDOWN_TIMELEFT_TEXT(src, warp_cooldown)] before you can warp something else!"))
		return
	if(!istype(beacon))
		to_chat(owner, span_dangerbold("You need a beacon placed to warp things!"))
		return
	if(!owner.Adjacent(target))
		to_chat(owner, span_dangerbold("You must be adjacent to the thing you wish to warp!"))
		return
	if(target.anchored)
		to_chat(owner, span_dangerbold("You cannot warp something that is anchored to the ground!"))
		return
	// We invoke async here so we don't call do_after in a signal handler
	try_warp(target, beacon)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/holoparasite_ability/lesser/teleport/proc/try_warp(atom/movable/target, obj/structure/receiving_pad/beacon)
	set waitfor = FALSE

	warping = TRUE
	warp_hud.update_appearance()
	var/cooldown = warp(target, beacon)
	warping = FALSE
	if(cooldown)
		warp_mode = FALSE
		warp_hud.begin_timer(cooldown)
	warp_hud.update_appearance()

/**
 * Warps an atom to a bluespace beacon.
 */
/datum/holoparasite_ability/lesser/teleport/proc/warp(atom/movable/target, obj/structure/receiving_pad/beacon)
	var/turf/target_turf = get_turf(target)
	var/turf/beacon_turf = get_turf(beacon)
	// If our range isn't maxed out, then ensure that the beacon is on the same virtual Z-level as the target.
	if(!cross_z_warping && beacon_turf.get_virtual_z_level() != target_turf.get_virtual_z_level())
		to_chat(owner, span_dangerbold("The beacon is too far away to warp to!"))
		return

	to_chat(owner, span_dangerbold("You begin to warp [target]..."))
	target.visible_message(span_danger("[target] starts to [COLOR_TEXT(owner.accent_color, "glow faintly")]!"), \
		span_userdanger("You start to [COLOR_TEXT(owner.accent_color, "faintly glow")], and you feel strangely weightless!"))

	owner.do_attack_animation(target)
	owner.balloon_alert(owner, "attempting to warp", show_in_chat = FALSE)
	if(!do_after(owner, 6 SECONDS, target, extra_checks = CALLBACK(src, PROC_REF(extra_do_after_checks), beacon)))
		to_chat(owner, span_dangerbold("The warping process was interrupted, both you and your target must stay still!"))
		return
	owner.balloon_alert(owner, "warped successfully", show_in_chat = FALSE)
	SSblackbox.record_feedback("tally", "holoparasite_warped", 1, "[target.type]")
	new /obj/effect/temp_visual/holoparasite/phase/out(target_turf)
	if(leaves_tear_behind)
		for(var/obj/effect/holopara_bluespace_tear/bs_tear as() in list(new /obj/effect/holopara_bluespace_tear(target_turf, beacon_turf), new /obj/effect/holopara_bluespace_tear(beacon_turf, target_turf)))
			QDEL_IN(bs_tear, HOLOPARA_TELEPORT_BLUESPACE_TEAR_TIME)
			animate(bs_tear, alpha = 255, time = 1 MINUTES)
	log_game("[key_name(owner)] teleported [isliving(target) ? key_name(target) : "[target] ([target.type])"] from [AREACOORD(target_turf)] to the bluespace beacon at [AREACOORD(beacon_turf)]")
	do_teleport(target, beacon_turf, precision = 0, asoundin = 'sound/effects/telepad.ogg', asoundout = 'sound/effects/telepad.ogg', channel = TELEPORT_CHANNEL_FREE)
	new /obj/effect/temp_visual/holoparasite/phase(beacon_turf)

	// pulling this outta my ass
	var/cooldown = HOLOPARA_TELEPORT_BASE_COOLDOWN
	var/teleported_living_thing = FALSE
	if(isliving(target))
		teleported_living_thing = TRUE
	else
		for(var/thing in target.GetAllContents())
			if(isliving(thing))
				teleported_living_thing = TRUE
				break
	if(!teleported_living_thing)
		cooldown *= HOLOPARA_TELEPORT_NONLIVING_COOLDOWN_MULTIPLIER
	COOLDOWN_START(src, warp_cooldown, cooldown)
	return cooldown

/datum/holoparasite_ability/lesser/teleport/proc/extra_do_after_checks(obj/structure/receiving_pad/beacon)
	. = TRUE
	if(QDELETED(beacon) || !owner.can_use_abilities)
		return FALSE
	var/turf/beacon_turf = get_turf(beacon)
	if(!beacon_turf || !isanyfloor(beacon_turf))
		return FALSE

/datum/holoparasite_ability/lesser/teleport/proc/try_place_beacon()
	placing = TRUE
	deploy_hud.update_appearance()
	place_beacon()
	placing = FALSE
	deploy_hud.update_appearance()
	warp_hud.update_appearance()

/**
 * Places a bluespace beacon at the holoparasite's current location.
 */
/datum/holoparasite_ability/lesser/teleport/proc/place_beacon()
	. = TRUE
	if(!COOLDOWN_FINISHED(src, deploy_cooldown))
		to_chat(owner, span_warning("You must wait <b>[COOLDOWN_TIMELEFT_TEXT(src, deploy_cooldown)]</b> before you can place another beacon!"))
		return FALSE
	if(!owner.is_manifested())
		to_chat(owner, span_warning("You must be manifested to place a beacon!"))
		return FALSE
	var/turf/target_turf = get_turf(owner)
	var/area/target_area = get_area(owner)
	if(!target_turf || !target_area || !isanyfloor(target_turf))
		to_chat(owner, span_warning("You cannot place a beacon here!"))
		owner.balloon_alert(owner, "cannot place beacon", show_in_chat = FALSE)
		return FALSE
	if(istype(target_area, /area/shuttle/supply) || is_centcom_level(target_turf.z) || is_away_level(target_turf.z) || target_area.teleport_restriction != TELEPORT_ALLOW_ALL)
		to_chat(owner, span_warning("Something is interfering with your ability to place a beacon here! Try placing one somewhere else!"))
		owner.balloon_alert(owner, "cannot place beacon", show_in_chat = FALSE)
		return FALSE
	owner.visible_message(span_holoparasite("[owner.color_name] begins to deploy a glowing beacon..."), span_holoparasite("You begin to deploy a bluespace beacon below you..."))
	if(!do_after(owner, 5 SECONDS, target_turf))
		to_chat(owner, span_warning("You must stay still in order to place a beacon!"))
		owner.balloon_alert(owner, "failed to place beacon", show_in_chat = FALSE)
		return FALSE
	owner.visible_message(span_holoparasite("[owner.color_name] deploys a glowing beacon below [owner.p_them()]self!"), span_holoparasite("You successfully deploy a bluespace beacon!"))
	if(!QDELETED(beacon))
		QDEL_NULL(beacon)
	beacon = new(target_turf, src)
	owner.give_accent_border(beacon)
	owner.balloon_alert(owner, "beacon placed", show_in_chat = FALSE)
	COOLDOWN_START(src, deploy_cooldown, HOLOPARA_TELEPORT_DEPLOY_COOLDOWN)
	deploy_hud.begin_timer(HOLOPARA_TELEPORT_DEPLOY_COOLDOWN)
	var/datum/space_level/target_z_level = SSmapping.get_level(target_turf.z)
	SSblackbox.record_feedback("associative", "holoparasite_beacons", 1, list(
		"map" = SSmapping.current_map.map_name,
		"area" = "[target_area.name]",
		"x" = target_turf.x,
		"y" = target_turf.y,
		"z" = target_turf.z,
		"z_name" = target_z_level?.name
	))

/atom/movable/screen/holoparasite/teleport
	var/datum/holoparasite_ability/lesser/teleport/ability

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/holoparasite/teleport)

/atom/movable/screen/holoparasite/teleport/Initialize(mapload, mob/living/simple_animal/hostile/holoparasite/_owner, datum/holoparasite_ability/lesser/teleport/_ability)
	. = ..()
	if(!istype(_ability))
		CRASH("Tried to make telepad holoparasite HUD without proper reference to telepad ability")
	ability = _ability
	update_overlays()

/atom/movable/screen/holoparasite/teleport/warp
	name = "Enable Warping"
	desc = "Attempt to warp the next thing you click on to your bluespace beacon."
	icon_state = "warp:toggle"
	can_toggle = TRUE
	var/static/disable_name = "Disable Warping"
	var/static/disable_desc = "Stop trying to warp whatever you click on, returning to normal interactions."
	var/static/disable_icon = "cancel"

/atom/movable/screen/holoparasite/teleport/warp/update_name(updates)
	name = ability.warp_mode ? disable_name : initial(name)
	return ..()

/atom/movable/screen/holoparasite/teleport/warp/update_desc(updates)
	desc = ability.warp_mode ? disable_desc : initial(desc)
	return ..()

/atom/movable/screen/holoparasite/teleport/warp/update_icon_state()
	icon_state = (ability.warp_mode && !ability.warping) ? disable_icon : initial(icon_state)
	return ..()

/atom/movable/screen/holoparasite/teleport/warp/use()
	if(!COOLDOWN_FINISHED(ability, warp_cooldown))
		ability.warp_mode = FALSE
		begin_timer(COOLDOWN_TIMELEFT(ability, warp_cooldown))
		update_appearance()
		return
	if(ability.warping)
		return
	ability.warp_mode = !ability.warp_mode
	to_chat(owner, span_noticeholoparasite("You [ability.warp_mode ? "enable" : "disable"] warping."))
	update_appearance()

/atom/movable/screen/holoparasite/teleport/warp/in_use()
	return ability.warping

/atom/movable/screen/holoparasite/teleport/warp/activated()
	return ability.warp_mode

/atom/movable/screen/holoparasite/teleport/warp/should_be_transparent()
	return ..() || QDELETED(ability.beacon)

/atom/movable/screen/holoparasite/teleport/deploy
	name = "Deploy Beacon"
	desc = "Deploys a bluespace beacon, allowing you to warp things to it later."
	icon_state = "warp:place"

/atom/movable/screen/holoparasite/teleport/deploy/use()
	if(ability.placing)
		return
	ability.try_place_beacon()

/atom/movable/screen/holoparasite/teleport/deploy/in_use()
	return ability.placing

// the pad
/obj/structure/receiving_pad
	name = "bluespace receiving pad"
	desc = "A receiving zone for bluespace teleportations."
	icon = 'icons/mob/holoparasite.dmi'
	icon_state = "telepad"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER
	/// The holoparasite ability that created this beacon.
	var/datum/holoparasite_ability/lesser/teleport/ability

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/receiving_pad)

/obj/structure/receiving_pad/Initialize(mapload, datum/holoparasite_ability/lesser/teleport/_ability)
	. = ..()
	if(!istype(_ability))
		stack_trace("Attempted to initialize holoparasite beacon without associated ability reference!")
		return INITIALIZE_HINT_QDEL
	ability = _ability
	var/image/silicon_image = image(icon = 'icons/mob/holoparasite.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "holopara_warp_pad", silicon_image)

/obj/structure/receiving_pad/Destroy()
	cut_overlays()
	// Unset the ability's beacon ref (provided that ref still points to us)
	if(ability.beacon == src)
		ability.beacon = null
	return ..()

/obj/structure/receiving_pad/proc/disappear()
	visible_message(span_warning("[src] vanishes!"))
	qdel(src)

/obj/effect/holopara_bluespace_tear
	name = "bluespace tear"
	icon_state = "bluestream_fade"
	alpha = 0
	var/turf/destination

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/holopara_bluespace_tear)

/obj/effect/holopara_bluespace_tear/Initialize(mapload, turf/_destination)
	. = ..()
	if(istype(_destination))
		destination = _destination

/obj/effect/holopara_bluespace_tear/attack_hand(mob/living/carbon/user)
	if(!istype(user) || !user.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet))
		to_chat(user, span_warning("You peer into the \the [src], quickly realizing that you have absolutely no clue whatsoever how to navigate through it..."))
		return
	if(!istype(destination) || QDELETED(destination))
		to_chat(user, span_warning("There doesn't seem to be anything on the other side of \the [src]..."))
		return
	user.visible_message(span_notice("[span_name("[user]")] begins to effortlessly climb into \the [src], navigating through the tear with unnatural familarity!"), \
		span_notice("You begin to crawl into \the [src], fully understanding the complex path through bluespace, despite it being incomprehensible to most..."))
	if(!do_after(user, 1.5 SECONDS, src, extra_checks = CALLBACK(src, PROC_REF(_bluespace_tear_crawl_check), user)))
		user.visible_message(span_warning("[span_name("[user]")] backs out of \the [src]!"), span_warning("You were interrupted while trying to navigate \the [src]!"))
		return
	user.visible_message(span_warning("[span_name("[user]")] fully crawls into \the [src], disappearing from view!"), \
		span_notice("You crawl into \the [src], effortlessly navigating through the bluespace tunnels, and come out on the other side..."))
	playsound(user, 'sound/magic/wand_teleport.ogg', vol = 75, vary = TRUE)
	do_teleport(user, destination, precision = 0, channel = TELEPORT_CHANNEL_QUANTUM)

/obj/effect/holopara_bluespace_tear/proc/_bluespace_tear_crawl_check(mob/living/carbon/user)
	return istype(user) && istype(destination) && !QDELETED(destination) && user.has_trauma_type(/datum/brain_trauma/special/bluespace_prophet)
