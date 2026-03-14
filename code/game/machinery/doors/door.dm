/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/doorint.dmi'
	icon_state = "door1"
	base_icon_state = "door"
	opacity = TRUE
	density = TRUE
	move_resist = MOVE_FORCE_VERY_STRONG
	layer = OPEN_DOOR_LAYER
	power_channel = AREA_USAGE_ENVIRON
	pass_flags_self = PASSDOORS
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	max_integrity = 350
	armor_type = /datum/armor/machinery_door
	can_atmos_pass = ATMOS_PASS_DENSITY
	flags_1 = PREVENT_CLICK_UNDER_1
	ricochet_chance_mod = 0.8
	damage_deflection = 10

	interaction_flags_atom = INTERACT_ATOM_UI_INTERACT

	var/air_tight = FALSE	//TRUE means density will be set as soon as the door begins to close
	var/visible = TRUE
	var/operating = FALSE
	var/glass = FALSE
	var/welded = FALSE
	var/heat_proof = FALSE // For rglass-windowed airlocks and firedoors
	var/emergency = FALSE // Emergency access override
	var/sub_door = FALSE // true if it's meant to go under another door.
	var/closingLayer = CLOSED_DOOR_LAYER
	var/autoclose = FALSE //does it automatically close after some time
	var/safe = TRUE //whether the door detects things and mobs in its way and reopen or crushes them.
	var/locked = FALSE //whether the door is bolted or not.
	var/datum/effect_system/spark_spread/spark_system
	var/real_explosion_block	//ignore this, just use explosion_block
	var/red_alert_access = FALSE //if TRUE, this door will always open on red alert
	var/unres_sides = 0 //Unrestricted sides. A bitflag for which direction (if any) can open the door with no access
	var/open_speed = 5
	/// Whether or not this door can be opened through a door remote, ever
	var/opens_with_door_remote = FALSE


/datum/armor/machinery_door
	melee = 30
	bullet = 30
	laser = 20
	energy = 20
	bomb = 10
	fire = 80
	acid = 70

/obj/machinery/door/Initialize(mapload)
	. = ..()
	set_init_door_layer()
	update_freelook_sight()
	air_update_turf(TRUE, TRUE)
	GLOB.airlocks += src
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)

	//doors only block while dense though so we have to use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(check_security_level))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_MAGICALLY_UNLOCKED = PROC_REF(on_magic_unlock),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/door/examine(mob/user)
	. = ..()
	if(red_alert_access)
		if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
			. += span_notice("Due to a security threat, its access requirements have been lifted!")
		else
			. += span_notice("In the event of a red alert, its access requirements will automatically lift.")
		. += span_notice("Its maintenance panel is <b>screwed</b> in place.")

/obj/machinery/door/check_access_list(list/access_list)
	if(red_alert_access && SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		return TRUE
	return ..()

/obj/machinery/door/proc/set_init_door_layer()
	if(density)
		layer = closingLayer
	else
		layer = initial(layer)

/obj/machinery/door/Destroy()
	update_freelook_sight()
	GLOB.airlocks -= src
	if(spark_system)
		qdel(spark_system)
		spark_system = null
	air_update_turf(TRUE, FALSE)
	return ..()

/obj/machinery/door/Bumped(atom/movable/AM)
	. = ..()
	if(operating)
		return
	if(ismob(AM))
		var/mob/B = AM
		if((isdrone(B) || iscyborg(B)) && B.stat)
			return
		if(isliving(AM))
			var/mob/living/M = AM
			if(world.time - M.last_bumped <= 10)
				return	//Can bump-open one airlock per second. This is to prevent shock spam.
			M.last_bumped = world.time
			if(HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) && !check_access(null))
				return
			bumpopen(M)
			return

		return

	if(isitem(AM))
		var/obj/item/I = AM
		if(!density)
			return
		if(check_access(I))
			open()
		else
			do_animate("deny")

/obj/machinery/door/Move()
	var/turf/T = loc
	. = ..()
	if(density) //Gotta be closed my friend
		move_update_air(T)

/obj/machinery/door/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	// Snowflake handling for PASSTRANSPARENT.
	if(istype(mover) && (mover.pass_flags & PASSTRANSPARENT))
		return !opacity

/// Helper method for bumpopen() and try_to_activate_door(). Don't override.
/obj/machinery/door/proc/activate_door_base(mob/user, can_close_door)
	if(user)
		add_fingerprint(user)
	if(operating)
		return
	// Cutting WIRE_IDSCAN disables normal entry
	if(!id_scan_hacked() && allowed(user))
		if(density)
			open()
		else
			if(!can_close_door)
				return FALSE
			close()
		return TRUE
	if(density)
		do_animate("deny")

/// Handles a door getting "bumped" by a mob/living.
/obj/machinery/door/proc/bumpopen(mob/user)
	activate_door_base(user, FALSE)

/obj/machinery/door/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	return try_to_activate_door(null, user)

/obj/machinery/door/attack_tk(mob/user)
	// allowed(null) will always return false, unless the door is all-access.
	// So unless we've cut the id-scan wire, TK won't go through at all - not even showing an animation.
	// But if we *have* cut the wire, this eventually falls through to attack_hand(), which calls try_to_activate_door(),
	// which will fail because the door won't work if the wire is cut! Catch-22.
	// Basically, TK won't work unless the door is all-access.

	if(user.stat || !tkMaxRangeCheck(user, src))
		return
	new /obj/effect/temp_visual/telekinesis(get_turf(src))
	add_hiddenprint(user)
	activate_door_base(null, TRUE)

/// Handles door activation via clicks, through attackby().
/obj/machinery/door/proc/try_to_activate_door(obj/item/I, mob/user)
	return activate_door_base(user, TRUE)

/obj/machinery/door/allowed(mob/M)
	if(emergency)
		return TRUE
	if(unrestricted_side(M))
		return TRUE
	return ..()

/obj/machinery/door/proc/unrestricted_side(mob/opener) //Allows for specific side of airlocks to be unrestrected (IE, can exit maint freely, but need access to enter)
	return get_dir(src, opener) & unres_sides

/obj/machinery/door/proc/try_to_weld(obj/item/weldingtool/W, mob/user)
	return

/// Called when the user right-clicks on the door with a welding tool.
/obj/machinery/door/proc/try_to_weld_secondary(obj/item/weldingtool/tool, mob/user)
	return


/obj/machinery/door/proc/try_to_crowbar(obj/item/acting_object, mob/user, forced = FALSE)
	return

/obj/machinery/door/welder_act(mob/living/user, obj/item/tool)
	if (!user.combat_mode)
		try_to_weld(tool, user)
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode || HAS_TRAIT(tool, TRAIT_DOOR_PRYER))
		return
	try_to_crowbar(tool, user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!user.combat_mode && HAS_TRAIT(attacking_item, TRAIT_DOOR_PRYER))
		try_to_crowbar(attacking_item, user, forced = TRUE)
		return TRUE
	else if(!user.combat_mode && istype(attacking_item, /obj/item/fireaxe))
		try_to_crowbar(attacking_item, user, forced = FALSE)
		return TRUE
	else if(attacking_item.item_flags & NOBLUDGEON || user.combat_mode)
		return ..()
	else if(!user.combat_mode && istype(attacking_item, /obj/item/stack/sheet/wood))
		return ..() // we need this so our can_barricade element can be called using COMSIG_ATOM_ATTACKBY
	else if(try_to_activate_door(attacking_item, user))
		return TRUE
	return ..()

/obj/machinery/door/welder_act_secondary(mob/living/user, obj/item/tool)
	try_to_weld_secondary(tool, user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/crowbar_act_secondary(mob/living/user, obj/item/tool)
	if(HAS_TRAIT(tool, TRAIT_DOOR_PRYER))
		return
	try_to_crowbar(tool, user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && atom_integrity > 0)
		if(damage_amount >= 10 && prob(30))
			spark_system.start()

/obj/machinery/door/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(glass)
				playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
			else if(damage_amount)
				playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/door/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(prob(20/severity) && (istype(src, /obj/machinery/door/airlock) || istype(src, /obj/machinery/door/window)) )
		INVOKE_ASYNC(src, PROC_REF(open))

/obj/machinery/door/update_icon_state()
	icon_state = "[base_icon_state][density]"
	return ..()

/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(panel_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(panel_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			if(!machine_stat)
				flick("door_deny", src)

/// Public proc that simply handles opening the door. Returns TRUE if the door was opened, FALSE otherwise.
/// Use argument "forced" in conjunction with try_to_force_door_open if you want/need additional checks depending on how sorely you need the door opened.
/obj/machinery/door/proc/open(forced = DEFAULT_DOOR_CHECKS)
	if(!density)
		return TRUE
	if(operating)
		return FALSE
	operating = TRUE
	do_animate("opening")
	set_opacity(0)
	sleep(open_speed)
	set_density(FALSE)
	z_flags &= ~(Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP)
	sleep(open_speed)
	layer = initial(layer)
	update_appearance()
	set_opacity(0)
	operating = FALSE
	air_update_turf(TRUE, FALSE)
	update_freelook_sight()
	if(autoclose)
		autoclose_in(DOOR_CLOSE_WAIT)
	return TRUE

/// Private proc that runs a series of checks to see if we should forcibly open the door. Returns TRUE if we should open the door, FALSE otherwise. Implemented in child types.
/// In case a specific behavior isn't covered, we should default to TRUE just to be safe (simply put, this proc should have an explicit reason to return FALSE).
/obj/machinery/door/proc/try_to_force_door_open(force_type = DEFAULT_DOOR_CHECKS)
	return TRUE // the base "door" can always be forced open since there's no power or anything like emagging it to prevent an open, not even invoked on the base type anyways.

/// Public proc that simply handles closing the door. Returns TRUE if the door was closed, FALSE otherwise.
/// Use argument "forced" in conjuction with try_to_force_door_shut if you want/need additional checks depending on how sorely you need the door closed.
/obj/machinery/door/proc/close(forced = DEFAULT_DOOR_CHECKS)
	if(density)
		return TRUE
	if(operating || welded)
		return FALSE
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src) //something is blocking the door
				if(autoclose)
					autoclose_in(DOOR_CLOSE_WAIT)
				return FALSE

	operating = TRUE

	do_animate("closing")
	layer = closingLayer
	if(air_tight)
		set_density(TRUE)
		z_flags |= Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	sleep(open_speed)
	set_density(TRUE)
	z_flags |= Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	sleep(open_speed)
	update_appearance()
	if(visible && !glass)
		set_opacity(1)
	operating = FALSE
	air_update_turf(TRUE, TRUE)
	update_freelook_sight()
	if(safe)
		CheckForMobs()
	else if(!(flags_1 & ON_BORDER_1))
		crush()
	return TRUE

/// Private proc that runs a series of checks to see if we should forcibly shut the door. Returns TRUE if we should shut the door, FALSE otherwise. Implemented in child types.
/// In case a specific behavior isn't covered, we should default to TRUE just to be safe (simply put, this proc should have an explicit reason to return FALSE).
/obj/machinery/door/proc/try_to_force_door_shut(force_type = DEFAULT_DOOR_CHECKS)
	return TRUE // the base "door" can always be forced shut

/obj/machinery/door/proc/CheckForMobs()
	if(locate(/mob/living) in get_turf(src))
		sleep(1)
		open()

/obj/machinery/door/proc/crush()
	for(var/mob/living/L in get_turf(src))
		L.visible_message(span_warning("[src] closes on [L], crushing [L.p_them()]!"), span_userdanger("[src] closes on you and crushes you!"))
		if(isalien(L))  //For xenos
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE * 1.5) //Xenos go into crit after aproximately the same amount of crushes as humans.
			L.emote("roar")
		else if(ishuman(L)) //For humans
			var/armour = L.run_armor_check(BODY_ZONE_CHEST, MELEE)
			var/multiplier = clamp(1 - (armour * 0.01), 0, 1)
			L.adjustBruteLoss(multiplier * DOOR_CRUSH_DAMAGE)
			L.emote("scream")
			if(!L.IsParalyzed())
				L.Paralyze(60)
		else //for simple_animals & borgs
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
		var/turf/location = get_turf(src)
		//add_blood doesn't work for borgs/xenos, but add_blood_floor does.
		L.add_splatter_floor(location)
		log_combat(src, L, "crushed", src)
	for(var/obj/vehicle/sealed/mecha/M in get_turf(src))
		M.take_damage(DOOR_CRUSH_DAMAGE)
		log_combat(src, M, "crushed", src)

/obj/machinery/door/proc/autoclose()
	if(!QDELETED(src) && !density && !operating && !locked && !welded && autoclose)
		close()

/obj/machinery/door/proc/autoclose_in(wait)
	addtimer(CALLBACK(src, PROC_REF(autoclose)), wait, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/// Is the ID Scan wire cut, or has the AI disabled it?
/// This has a variety of non-uniform effects - it doesn't simply grant access.
/obj/machinery/door/proc/id_scan_hacked()
	return FALSE

/obj/machinery/door/proc/hasPower()
	return !(machine_stat & NOPOWER)

/obj/machinery/door/proc/update_freelook_sight()
	if(!glass && GLOB.cameranet)
		GLOB.cameranet.updateVisibility(src, 0)

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'

/obj/machinery/door/get_dumping_location()
	return null

/obj/machinery/door/proc/lock()
	return

/obj/machinery/door/proc/unlock()
	return

/obj/machinery/door/proc/hostile_lockdown(mob/origin)
	if(!machine_stat) //So that only powered doors are closed.
		close() //Close ALL the doors!

/obj/machinery/door/proc/disable_lockdown()
	if(!machine_stat) //Opens only powered doors.
		open() //Open everything!

/obj/machinery/door/ex_act(severity, target)
	//if it blows up a wall it should blow up a door
	..(severity ? max(1, severity - 1) : 0, target)

/obj/machinery/door/GetExplosionBlock()
	return density ? real_explosion_block : 0

/obj/machinery/door/power_change()
	. = ..()
	if(. && !(machine_stat & NOPOWER))
		autoclose_in(rand(0.5 SECONDS, 3 SECONDS))

/**
 * Signal handler for checking if we notify our surrounding that access requirements are lifted accordingly to a newly set security level
 *
 * Arguments:
 * * source The datum source of the signal
 * * new_level The new security level that is in effect
 */
/obj/machinery/door/proc/check_security_level(datum/source, new_level)
	SIGNAL_HANDLER

	if(new_level <= SEC_LEVEL_BLUE)
		return
	if(!red_alert_access)
		return
	audible_message(span_notice("[src] whirr[p_s()] as [p_they()] automatically lift[p_s()] access requirements!"))
	playsound(src, 'sound/machines/boltsup.ogg', 50, TRUE)

/// Signal proc for [COMSIG_ATOM_MAGICALLY_UNLOCKED]. Open up when someone casts knock.
/obj/machinery/door/proc/on_magic_unlock(datum/source, datum/action/spell/aoe/knock/spell, atom/caster)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(open))
