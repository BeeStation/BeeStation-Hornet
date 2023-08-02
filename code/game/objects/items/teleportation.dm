#define SOURCE_PORTAL 1
#define DESTINATION_PORTAL 2

/* Teleportation devices.
 * Contains:
 *		Locator
 *		Hand-tele
 *		Syndicate Teleporter
 */

/*
 * Locator
 */
/obj/item/locator
	name = "bluespace locator"
	desc = "Used to track portable teleportation beacons and targets with embedded tracking implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/temp = null
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=400)
	var/tracking_range = 20

/obj/item/locator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceLocator", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/locator/ui_data(mob/user)
	var/list/data = list()

	data["trackingrange"] = tracking_range;

	// Get our current turf location.
	var/turf/sr = get_turf(src)

	if (sr)
		// Check every teleport beacon.
		var/list/tele_beacons = list()
		for(var/obj/item/beacon/W in GLOB.teleportbeacons)

			// Get the tracking beacon's turf location.
			var/turf/tr = get_turf(W)

			// Make sure it's on a turf and that its Z-level matches the tracker's Z-level
			if (tr && tr.z == sr.z)
				// Get the distance between the beacon's turf and our turf
				var/distance = max(abs(tr.x - sr.x), abs(tr.y - sr.y))

				// If the target is too far away, skip over this beacon.
				if(distance > tracking_range)
					continue

				var/beacon_name

				if(W.renamed)
					beacon_name = W.name
				else
					var/area/A = get_area(W)
					beacon_name = A.name

				var/D =  dir2text(get_dir(sr, tr))
				tele_beacons += list(list(name = beacon_name, direction = D, distance = distance))

		data["telebeacons"] = tele_beacons

		var/list/track_implants = list()

		for (var/obj/item/implant/tracking/W in GLOB.tracked_implants)
			if (!W.imp_in || !isliving(W.loc))
				continue
			else
				var/mob/living/M = W.loc
				if (M.stat == DEAD)
					if (M.timeofdeath + W.lifespan_postmortem < world.time)
						continue
			var/turf/tr = get_turf(W)
			var/distance = max(abs(tr.x - sr.x), abs(tr.y - sr.y))

			if(distance > tracking_range)
				continue

			var/D =  dir2text(get_dir(sr, tr))
			track_implants += list(list(name = W.imp_in.name, direction = D, distance = distance))
		data["trackimplants"] = track_implants
	return data


/*
 * Hand-tele
 */
/obj/item/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/iron=10000)
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, STAMINA = 0)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/list/active_portal_pairs
	var/max_portal_pairs = 3
	var/atmos_link_override
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/hand_tele/Initialize(mapload)
	. = ..()
	active_portal_pairs = list()

/obj/item/hand_tele/pre_attack(atom/target, mob/user, params)
	if(try_dispel_portal(target, user))
		return FALSE
	return ..()

/obj/item/hand_tele/proc/try_dispel_portal(obj/effect/portal/target, mob/user)
	if(is_parent_of_portal(target))
		target.dispel()
		to_chat(user, "<span class='notice'>You dispel [target] with \the [src]!</span>")
		return TRUE
	return FALSE

/obj/item/hand_tele/afterattack(atom/target, mob/user)
	try_dispel_portal(target, user)
	. = ..()

/obj/item/hand_tele/attack_self(mob/user)
	var/turf/current_location = get_turf(user)//What turf is the user on?
	var/area/current_area = current_location.loc
	if(!current_location || current_area.teleport_restriction || is_away_level(current_location.z) || is_centcom_level(current_location.z) || !isturf(user.loc))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if user is not located on a turf
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	// Add on teleport targets
	var/list/L = list()
	for(var/obj/machinery/computer/teleporter/com in GLOB.machines)
		var/atom/target = com.target_ref?.resolve()
		if(!target)
			com.target_ref = null
			continue
		var/area/A = get_area(target)
		if(!A || A.teleport_restriction)
			continue
		if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
			L["[get_area(target)] (Active)"] = target
		else
			L["[get_area(target)] (Inactive)"] = target
	// Add on slipspace wakes
	var/i = 0
	for (var/obj/effect/temp_visual/teleportation_wake/wake in range(7, user))
		if (!wake.destination)
			continue
		var/distance = get_dist(wake, user)
		var/range = distance <= 3 ? "Strong" : "Weak"
		L["Slipspace Wake [++i] ([range])"] = get_teleport_turf(wake.destination, 2 + distance)
	// Add on a random turf nearby
	var/list/turfs = list()
	for(var/turf/T as() in (RANGE_TURFS(10, user) - get_turf(user)))
		if(T.x>world.maxx-8 || T.x<8)
			continue	//putting them at the edge is dumb
		if(T.y>world.maxy-8 || T.y<8)
			continue
		var/area/A = T.loc
		if(A.teleport_restriction)
			continue
		turfs += T
	if(turfs.len)
		L["None (Dangerous)"] = pick(turfs)
	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") as null|anything in L
	if (!t1 || user.get_active_held_item() != src || user.incapacitated())
		return
	if(active_portal_pairs.len >= max_portal_pairs)
		user.show_message("<span class='notice'>\The [src] is recharging!</span>")
		return
	var/atom/T = L[t1]
	var/area/A = get_area(T)
	if(A.teleport_restriction)
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	current_location = get_turf(user)	//Recheck.
	current_area = current_location.loc
	if(!current_location || current_area.teleport_restriction || is_away_level(current_location.z) || is_centcom_level(current_location.z) || !isturf(user.loc))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if user is not located on a turf
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	var/list/obj/effect/portal/created = create_portal_pair(current_location, get_teleport_turf(get_turf(T)), src, 300, 1, null, atmos_link_override)
	if(!(LAZYLEN(created) == 2))
		return

	var/obj/effect/portal/c1 = created[1]
	var/obj/effect/portal/c2 = created[2]

	var/turf/check_turf = get_turf(get_step(user, user.dir))
	if(!check_turf.is_blocked_turf(TRUE, src))
		c1.forceMove(check_turf)
	active_portal_pairs[created[1]] = created[2]

	investigate_log("was used by [key_name(user)] at [AREACOORD(user)] to create a portal pair with destinations [AREACOORD(c1)] and [AREACOORD(c2)].", INVESTIGATE_PORTAL)
	add_fingerprint(user)

/obj/item/hand_tele/proc/on_portal_destroy(obj/effect/portal/P)
	// Identify the source and destination portal
	var/source = P
	// Lookup the portal that we are dispelling in the active portal pairs
	var/destination = active_portal_pairs[P]
	// If we cannot find it, lookup by the destination portals as we could be dispelling the other end.
	if (!destination)
		for (var/start in active_portal_pairs)
			if (active_portal_pairs[start] == P)
				destination = start
				break
	if (source && destination)
		// Create a wake to the target
		new /obj/effect/temp_visual/teleportation_wake(get_turf(source), get_turf(destination))
		new /obj/effect/temp_visual/teleportation_wake(get_turf(destination), get_turf(source))
	active_portal_pairs -= P	//If this portal pair is made by us it'll be erased along with the other portal by the portal.

/obj/item/hand_tele/proc/is_parent_of_portal(obj/effect/portal/P)
	if(!istype(P))
		return FALSE
	if(active_portal_pairs[P])
		return SOURCE_PORTAL
	for(var/i in active_portal_pairs)
		if(active_portal_pairs[i] == P)
			return DESTINATION_PORTAL
	return FALSE

/obj/item/hand_tele/suicide_act(mob/user)
	if(iscarbon(user))
		user.visible_message("<span class='suicide'>[user] is creating a weak portal and sticking [user.p_their()] head through! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		var/mob/living/carbon/itemUser = user
		var/obj/item/bodypart/head/head = itemUser.get_bodypart(BODY_ZONE_HEAD)
		if(head)
			head.drop_limb()
			var/list/safeLevels = SSmapping.levels_by_any_trait(list(ZTRAIT_DYNAMIC_LEVEL, ZTRAIT_LAVA_RUINS, ZTRAIT_STATION, ZTRAIT_MINING))
			head.forceMove(locate(rand(1, world.maxx), rand(1, world.maxy), pick(safeLevels)))
			itemUser.visible_message("<span class='suicide'>The portal snaps closed taking [user]'s head with it!</span>")
		else
			itemUser.visible_message("<span class='suicide'>[user] looks even further depressed as they realize they do not have a head...and suddenly dies of shame!</span>")
		return (BRUTELOSS)

/*
 * Syndicate Teleporter
 */

/obj/item/teleporter
	name = "syndicate jaunter"
	desc = "A device created by the Syndicate in order to mimic the effects of the hand teleporter which uses reverse-engineered jaunters obtained from captured miners. \
		While it fails to allow for long-range teleportation and teleportation through solid matter, the combat potential of the bluespace wake created as a result of \
		using the device far exceeds that of what Nanotrasen has been able to produce, mainly due to the fact that the Syndicate don't see it as an unwanted side effect."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi_tele"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10

	//Uses of the device left
	var/charges = 4
	//The maximum number of stored uses
	var/max_charges = 4
	var/minimum_teleport_distance = 6
	var/maximum_teleport_distance = 8
	//How far the emergency teleport checks for a safe position
	var/parallel_teleport_distance = 3
	//How long it takes to replenish a charge
	var/recharge_time = 15 SECONDS
	//If the device is recharging, prevents timers stacking
	var/recharging = FALSE
	//stores the recharge timer id
	var/recharge_timer

/obj/item/teleporter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] has [charges] out of [max_charges] charges left.</span>"
	if(recharging)
		. += "<span class='notice'><b>A small display on the back reads:</b></span>"
		var/timeleft = timeleft(recharge_timer)
		var/loadingbar = num2loadingbar(timeleft/recharge_time, reverse=TRUE)
		. += "<span class='notice'><b>CHARGING: [loadingbar] ([timeleft*0.1]s)</b></span>"

/obj/item/teleporter/attack_self(mob/user)
	..()
	attempt_teleport(user, FALSE)

/obj/item/teleporter/proc/check_charges()
	if(recharging)
		return
	if(charges < max_charges)
		recharge_timer = addtimer(CALLBACK(src, PROC_REF(recharge)), recharge_time, TIMER_STOPPABLE)
		recharging = TRUE

/obj/item/teleporter/proc/recharge()
	charges++
	playsound(src,'sound/machines/twobeep.ogg',10,TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	recharging = FALSE
	check_charges()

/obj/item/teleporter/emp_act(severity)
	if(prob(50 / severity))
		if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/user = loc
			to_chat(user, "<span class='danger'>[src] buzzes and activates!</span>")
			attempt_teleport(user, TRUE) //EMP Activates a teleport with no safety.
		else
			visible_message("<span class='warning'>[src] activates and blinks out of existence!</span>")
			do_sparks(2, 1, src)
			qdel(src)

/obj/item/teleporter/proc/attempt_teleport(mob/user, EMP_D = FALSE)
	if(!charges)
		to_chat(user, "<span class='warning'>[src] is still recharging.</span>")
		return

	var/turf/current_location = get_turf(user)
	var/area/current_area = current_location.loc
	if(!current_location || current_area.teleport_restriction || is_away_level(current_location.z) || is_centcom_level(current_location.z) || !isturf(user.loc))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if user is not located on a turf
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return

	var/mob/living/carbon/C = user
	var/teleport_distance = rand(minimum_teleport_distance,maximum_teleport_distance)
	var/list/bagholding = user.GetAllContents(/obj/item/storage/backpack/holding)
	var/direction = (EMP_D || length(bagholding)) ? pick(GLOB.cardinals) : user.dir

	for (var/i in 1 to teleport_distance)
		// Step forward
		var/turf/previous = current_location
		current_location = get_step(current_location, direction)

		// Check if we can move here
		current_area = current_location.loc
		if(!do_teleport(C, current_location, no_effects = TRUE, channel = TELEPORT_CHANNEL_BLINK, commit = FALSE))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if user is not located on a turf
			current_location = previous
			break
		// If it contains objects, try to break it
		for (var/obj/object in current_location.contents)
			if (object.density)
				object.take_damage(150)
		if (current_location.is_blocked_turf(TRUE))
			current_location = previous
			break

		// Telefrag this location
		if (!telefrag(current_location, user))
			current_location = previous
			break

	do_teleport(C, current_location, channel = TELEPORT_CHANNEL_BLINK)

	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(get_turf(user))
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(current_location)
	charges--
	check_charges()
	playsound(current_location, 'sound/effects/phasein.ogg', 25, 1)
	playsound(current_location, "sparks", 50, 1)

/obj/item/teleporter/proc/telefrag(turf/fragging_location, mob/user)
	for(var/mob/living/target in fragging_location)//Hit everything in the turf
		// Skip any mobs that aren't standing, or aren't dense
		if (!(target.mobility_flags & MOBILITY_STAND) || !target.density || user == target)
			continue
		// Run armour checks and apply damage
		var/armor_block = target.run_armor_check(BODY_ZONE_CHEST, MELEE)
		target.apply_damage(25, BRUTE, blocked = armor_block)
		target.Paralyze(10 * (100 - armor_block) / 100)
		target.Knockdown(40 * (100 - armor_block) / 100)
		// Check if we successfully knocked them down
		if (!(target.mobility_flags & MOBILITY_STAND))
			to_chat(target, "<span class='userdanger'>[user] teleports into you, knocking you to the floor with the bluespace wave!</span>")
		else
			to_chat(user, "<span class='userdanger'>[target] resists the force of your jaunt's wake, bringing you to stop!</span>")
			to_chat(target, "<span class='userdanger'>[user] slams into you, falling out of their bluespace jaunt tunnel!</span>")
			return FALSE
	return TRUE

/obj/effect/temp_visual/teleport_abductor/syndi_teleporter
	duration = 5
