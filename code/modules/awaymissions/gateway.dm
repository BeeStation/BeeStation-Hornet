GLOBAL_DATUM(the_gateway, /obj/machinery/gateway/centerstation)

/obj/machinery/gateway
	name = "gateway"
	desc = "A gateway built for quick travel between linked destinations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/active = FALSE
	var/checkparts = TRUE
	var/list/adjacent_parts = list()
	var/centerpiece = FALSE	//Is this the centerpiece?

	/// The gateway this machine is linked to
	var/obj/machinery/gateway/linked_gateway

	/// Cooldown for says and buzz-sigh
	COOLDOWN_DECLARE(telegraph_cooldown)

/obj/machinery/gateway/Initialize(mapload)
	. = ..()
	if(!centerpiece)
		switch(dir)
			if(SOUTH,SOUTHEAST,SOUTHWEST)
				density = FALSE

/obj/machinery/gateway/Destroy()
	if(GLOB.the_gateway == src)
		GLOB.the_gateway = null
	if(linked_gateway)
		linked_gateway.linked_gateway = null
		linked_gateway = null
	return ..()

/obj/machinery/gateway/Bumped(atom/movable/AM)
	if(!centerpiece)
		return
	if(!active)
		return
	if(!check_parts())
		return
	if(!linked_gateway || QDELETED(linked_gateway))
		say_cooldown("Target destination not found.")
		return
	if(!linked_gateway.active)
		say_cooldown("Destination gateway not active.")
		return

	teleport(AM, linked_gateway)

/obj/machinery/gateway/proc/check_parts()
	. = TRUE
	if(!checkparts)
		return

	for(var/i in GLOB.alldirs)
		var/turf/T = get_step(src, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			adjacent_parts.Add(G)
			continue

		// Failed to link to a piece of the gateway
		. = FALSE
		toggleoff()
		break

/obj/machinery/gateway/proc/say_cooldown(words, sound)
	if(COOLDOWN_FINISHED(src, telegraph_cooldown))
		COOLDOWN_START(src, telegraph_cooldown, 5 SECONDS)
		say(words)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)

/obj/machinery/gateway/proc/teleport(atom/movable/AM, obj/machinery/gateway/target)
	var/turf/dest_turf = get_step(get_turf(target), SOUTH)

	if(check_teleport(AM, dest_turf, channel = TELEPORT_CHANNEL_GATEWAY))
		to_chat("<span class='warning'>You can't seem to pass through [src]!</span>")
		return

	if(ismob(AM))
		var/mob/M = AM
		M.visible_message("<span class='notice'>[AM] tries to climb into [src]...</span>", "<span class='notice'>You begin climbing into [src]...</span>")
		if(!do_after(M, 5 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
			return
	else
		AM.visible_message("<span class='notice'>[AM] enters the gateway...</span>") // oooo~ ominous

	if(do_teleport(AM, dest_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_GATEWAY))
		AM.setDir(SOUTH)

/obj/machinery/gateway/update_icon()
	icon_state = active ? "on" : "off"

/obj/machinery/gateway/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!centerpiece)
		return

	if(!check_parts())
		to_chat(user, "<span class='warning'>It seems incomplete...</span>")
		return

	if(active)
		toggleoff(telegraph = TRUE)
		to_chat(user, "<span class='notice'>You turn [src] off.</span>")
	else
		if(toggleon(user))
			to_chat(user, "<span class='notice'>You turn [src] on.</span>")

/obj/machinery/gateway/proc/toggleon(mob/user)
	if(!centerpiece)
		return
	if(!powered())
		to_chat(user, "<span class='warning'>It has no power!</span>")
		return FALSE
	if(!linked_gateway)
		to_chat(user, "<span class='warning'>No destination found!</span>")
		return FALSE

	for(var/obj/machinery/gateway/G in adjacent_parts)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()
	return TRUE

/obj/machinery/gateway/proc/toggleoff(telegraph = FALSE)
	for(var/obj/machinery/gateway/G in adjacent_parts)
		G.active = FALSE
		G.update_icon()
	active = FALSE
	update_icon()
	if(telegraph)
		playsound(src, 'sound/machines/terminal_off.ogg', 50, 0)

/obj/machinery/gateway/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG)
	return

//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = TRUE
	icon_state = "offcenter"
	use_power = IDLE_POWER_USE
	centerpiece = TRUE

/obj/machinery/gateway/centerstation/Initialize(mapload)
	. = ..()
	if(!GLOB.the_gateway)
		GLOB.the_gateway = src
	update_icon()
	linked_gateway = locate(/obj/machinery/gateway/centeraway)

/obj/machinery/gateway/centerstation/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"

/obj/machinery/gateway/centerstation/process()
	if((machine_stat & (NOPOWER)) && use_power)
		if(active)
			toggleoff(TRUE)
		return

	if(!is_operational)
		toggleoff(TRUE)
		return

	if(active)
		use_power(5000)

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = TRUE
	icon_state = "offcenter"
	use_power = NO_POWER_USE
	centerpiece = TRUE

/obj/machinery/gateway/centeraway/Initialize(mapload)
	. = ..()
	update_icon()
	linked_gateway = locate(/obj/machinery/gateway/centerstation)

/obj/machinery/gateway/centeraway/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"

/obj/machinery/gateway/centeraway/mining
	use_power = IDLE_POWER_USE

/obj/machinery/gateway/centeraway/mining/process()
	if((machine_stat & NOPOWER) && use_power)
		if(active)
			toggleoff(TRUE)
		return

	if(!is_operational)
		toggleoff(TRUE)
		return

	if(active)
		use_power(5000)

/obj/machinery/gateway/centeraway/admin
	desc = "A mysterious gateway built by unknown hands, this one seems more compact."

/obj/machinery/gateway/centeraway/admin/check_parts()
	return TRUE


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
