GLOBAL_DATUM(the_gateway, /obj/machinery/gateway/station)

/* Dense invisible object starting the teleportation. Created by gateways on activation. */
/obj/effect/gateway_portal_bumper
	var/obj/machinery/gateway/parent_gateway
	density = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/gateway_portal_bumper/Bumped(atom/movable/AM)
	if(get_dir(src, AM) == SOUTH)
		parent_gateway.try_teleport(AM)

/obj/effect/gateway_portal_bumper/Destroy()
	parent_gateway = null
	return ..()

/obj/machinery/gateway
	name = "gateway"
	desc = "A gateway built for quick travel between linked destinations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	move_resist = INFINITY

	// 3x2 offset by one row
	pixel_x = -32
	pixel_y = -32
	bound_height = 64
	bound_width = 96
	bound_x = -32
	bound_y = 0
	density = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 1000

	var/obj/effect/gateway_portal_bumper/bumper

	var/active = FALSE

	/// The gateway this machine is linked to
	var/obj/machinery/gateway/linked_gateway

	/// Cooldown for says and buzz-sigh
	COOLDOWN_DECLARE(telegraph_cooldown)

/obj/machinery/gateway/Destroy()
	if(GLOB.the_gateway == src)
		GLOB.the_gateway = null
	if(linked_gateway)
		linked_gateway.linked_gateway = null
		linked_gateway = null
	if(!isnull(bumper))
		QDEL_NULL(bumper)
	return ..()

/obj/machinery/gateway/examine(mob/user)
	. = ..()

	. += span_info("It appears to be [active ? (istype(linked_gateway) ? "on, and connected to a destination" : "on, but not linked") : "off"].")

	if(active)
		. += ""
		. += span_info("Use a <b>multi-tool</b> to turn it off.")

/obj/machinery/gateway/MouseDrop_T(atom/movable/AM, mob/user)
	. = ..()
	if(AM == user)
		try_teleport(AM) // This is so that if you're drag-clicking yourself into the gateway it'll appear as if you're entering it
	else
		try_teleport(AM, user)

/obj/machinery/gateway/proc/pre_check_teleport(atom/movable/AM, turf/dest_turf)
	if(!active)
		return FALSE
	if(!linked_gateway || QDELETED(linked_gateway))
		say_cooldown("Target destination not found.")
		return FALSE
	if(!linked_gateway.active)
		say_cooldown("Destination gateway not active.")
		return FALSE

	return check_teleport(AM, dest_turf, channel = TELEPORT_CHANNEL_GATEWAY)

/obj/machinery/gateway/proc/say_cooldown(words, sound)
	if(COOLDOWN_FINISHED(src, telegraph_cooldown))
		COOLDOWN_START(src, telegraph_cooldown, 5 SECONDS)
		say(words)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)

/// Try to teleport
/obj/machinery/gateway/proc/try_teleport(atom/movable/target_movable, atom/movable/assailant)
	if(isnull(linked_gateway))
		return

	var/self = isnull(assailant) || !ismob(assailant)

	var/turf/dest_turf = get_step(get_turf(linked_gateway), SOUTH)
	if(!pre_check_teleport(target_movable, dest_turf))
		return // Gateway off/broken

	if(ismob(target_movable))
		var/mob/target_mob = target_movable
		if(src in target_mob.do_afters)
			return // Don't enter if we're already trying to enter

		if(!self)//Let the assailant know
			to_chat(assailant, span_warning("You try to push [target_mob] into [src]..."))
		target_mob.visible_message( \
			self ? span_notice("[target_mob] tries to climb into [src]...") : span_warning("[assailant] tries to shove [target_mob] into [src]..."), \
			self ? span_notice("You begin climbing into [src]...") : span_userdanger("You're being shoved into [src] by [assailant]!"))

		// Try the actual teleport
		if(!do_after(self ? target_movable : assailant, 5 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
			return // failed do_after, we don't teleport
		if(!active)
			return // Its not on dummy!

	actually_teleport(target_movable, dest_turf)

/obj/machinery/gateway/proc/actually_teleport(atom/movable/AM, turf/dest_turf, rough_landing = FALSE)
	if(!do_teleport(AM, dest_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_GATEWAY, ignore_check_teleport = TRUE)) // We've already done the check_teleport() hopefully
		return
	AM.visible_message(span_notice("[AM] passes through [linked_gateway]!"), span_notice("You pass through [src]."))
	AM.setDir(SOUTH)

	if(rough_landing && isliving(AM))
		var/mob/living/victim = AM
		victim.Knockdown(3 SECONDS)
		to_chat(victim, span_userdanger("You fall onto \the [get_turf(AM)]!"))

/obj/machinery/gateway/update_icon_state()
	icon_state = active ? "on" : "off"
	return ..()

// Try to turn it on
/obj/machinery/gateway/attack_hand(mob/living/user)
	if(!active && toggleon(user))
		user.visible_message(span_notice("[user] switches [src] on."), span_notice("You switch [src] on."))
		return TRUE
	if(active)
		to_chat(user, span_warning("You need a multitool to turn it off!"))
		return TRUE
	return ..()

// Silicons can turn it on and off however they please
/obj/machinery/gateway/attack_silicon(mob/user)
	if(active ? toggleoff(telegraph = TRUE) : toggleon(user))
		to_chat(user, span_notice("You turn send a [active ? "startup" : "shutdown"] signal to [src]."))
		visible_message(span_notice("[src] turns on."), ignored_mobs = list(user))
		return TRUE
	return ..()

// Otherwise, you need a multitool to turn it off
/obj/machinery/gateway/multitool_act(mob/living/user, obj/item/I)
	if(active && toggleoff(telegraph = TRUE))
		user.visible_message(span_notice("[user] switches [src] off."), span_notice("You switch [src] off."))
		return TRUE
	else if(!active)
		to_chat(user, span_warning("Its already off!"))
		return TRUE
	return ..()

/obj/machinery/gateway/proc/toggleon(mob/user)
	if(!powered())
		to_chat(user, span_warning("It has no power!"))
		return FALSE
	if(!linked_gateway)
		to_chat(user, span_warning("No destination found!"))
		return FALSE

	active = TRUE
	use_power = ACTIVE_POWER_USE
	update_icon()
	bumper = new(get_turf(src))
	bumper.parent_gateway = src
	return TRUE

/obj/machinery/gateway/proc/toggleoff(telegraph = FALSE)
	if(!active)
		return FALSE
	active = FALSE
	use_power = IDLE_POWER_USE
	QDEL_NULL(bumper)
	update_icon()
	if(telegraph)
		playsound(src, 'sound/machines/terminal_off.ogg', 50, 0)
	return TRUE

//this is da important part wot makes things go
/obj/machinery/gateway/station

/obj/machinery/gateway/station/Initialize(mapload)
	. = ..()
	if(isnull(GLOB.the_gateway))
		GLOB.the_gateway = src
	update_icon()
	linked_gateway = locate(/obj/machinery/gateway/away)

/obj/machinery/gateway/away

/obj/machinery/gateway/away/Initialize(mapload)
	. = ..()
	update_icon()
	linked_gateway = locate(/obj/machinery/gateway/station)


/obj/item/paper/fluff/gateway
	default_raw_text = "Congratulations,<br><br>Your station has been selected to carry out the Gateway Project.<br><br>The equipment will be shipped to you at the start of the next quarter.<br> You are to prepare a secure location to house the equipment as outlined in the attached documents.<br><br>--Nanotrasen Bluespace Research"
	name = "Confidential Correspondence, Pg 1"

/obj/item/paper/fluff/itemnotice
	default_raw_text = "Notice: Over the last few weeks there have been increased reports of surplus, trash items such as wrappers being found in Bluespace Capsule Products. In the event this encampment has any such item, please dispose of them within a wastebin or the provided bonfire, especially if such items include frivolous, frankly embarrassing things. We apologise for the inconvienence. Thank you. -- Nanotrasen BS Productions"
	name = "Surplus Item Removal Notice"

/obj/item/paper/fluff/encampmentwelcome
	default_raw_text = "Welcome! If you are reading this, then you have bought and deployed the new line of bluespace capsule shelters, the mining encampment! This capsule provides standard shelter equipment and more, such as an expanded food vendor, floor safe, restroom, suit storage, spare equipment, and a personal requisitions vendor! The outside has even been lined with basalt tiles, just so no rocks get in the way of the cozy courtyard! We hope you stay safe, and enjoy the amenities! - Nanotrasen BS Productions"
	name = "Welcome!"

/obj/item/paper/fluff/shuttlenotice
	default_raw_text = "To the acting captain of Nanotrasen Research Station SS13, Due to the nature of your emergency, we sadly had to expedite the process of constructing this shuttle, and as such it does not follow standard sanitary regulations. We appreciate your purchase, and apologise for the inconvienence. Thank you, and have a safe flight! -- Nanotrasen BS Productions Engineering Team"
	name = "Shuttle Notice"
