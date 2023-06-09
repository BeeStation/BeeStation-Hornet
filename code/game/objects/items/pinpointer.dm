//Pinpointers are used to track atoms from a distance as long as they're on the same z-level. The captain and nuke ops have ones that track the nuclear authentication disk.
/obj/item/pinpointer
	name = "pinpointer"
	desc = "A handheld tracking device that locks onto certain signals."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron = 500, /datum/material/glass = 250)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/active = FALSE
	var/atom/movable/target //The thing we're searching for
	var/minimum_range = 0 //at what range the pinpointer declares you to be at your destination
	var/ignore_suit_sensor_level = FALSE // Do we find people even if their suit sensors are turned off
	var/alert = FALSE // TRUE to display things more seriously
	var/process_scan = TRUE // some pinpointers change target every time they scan, which means we can't have it change very process but instead when it turns on.
	var/icon_suffix = "" // for special pinpointer icons

	/// FALSE: only tracks multiple z levels that are in the same group (i.e. multi-floored station) / TRUE: can track always regardless of the group (from station to laveland). This shouldn't be TRUE in general.
	var/tracks_grand_z = FALSE

	/// if this is declared (like JAMMER_PROTECTION_SENSOR_NETWORK), it will be not usable when it's jammed
	var/jamming_resistance = null

	/// Lets you to know where you should go to when you examine
	var/z_level_direction = ""

/obj/item/pinpointer/Initialize(mapload)
	. = ..()
	GLOB.pinpointer_list += src

/obj/item/pinpointer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.pinpointer_list -= src
	target = null
	return ..()

/obj/item/pinpointer/examine(mob/user)
	. = ..()
	if(!active || !target)
		return
	if(z_level_direction)
		. += "A display reads that the target is [z_level_direction]."

/obj/item/pinpointer/attack_self(mob/living/user)
	if(!process_scan) //since it's not scanning on process, it scans here.
		scan_for_target()
	toggle_on()
	user.visible_message("<span class='notice'>[user] [active ? "" : "de"]activates [user.p_their()] pinpointer.</span>", "<span class='notice'>You [active ? "" : "de"]activate your pinpointer.</span>")

/obj/item/pinpointer/proc/toggle_on()
	active = !active
	playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
	if(active)
		START_PROCESSING(SSfastprocess, src)
	else
		target = null
		z_level_direction = ""
		STOP_PROCESSING(SSfastprocess, src)
	update_icon()

/obj/item/pinpointer/process()
	if(!active)
		return PROCESS_KILL
	if(process_scan)
		scan_for_target()
	update_icon()

/obj/item/pinpointer/proc/scan_for_target()
	return

/obj/item/pinpointer/update_icon()
	cut_overlays()
	if(!active)
		return
	if(!target || (!isnull(jamming_resistance) && src.is_jammed(jamming_resistance)))
		add_overlay("pinon[alert ? "alert" : ""]null[icon_suffix]")
		return
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(target)

	// these two variables are used to update icon based on its string
	var/pin_xy_result = "direct"
	var/pin_z_result = ""


	// getting z result first
	var/here_zlevel = here.get_virtual_z_level()
	var/there_zlevel = there.get_virtual_z_level()
	if(here_zlevel > there_zlevel) // target is at below
		pin_z_result = "below"
	else if(here_zlevel < there_zlevel) // target is at above
		pin_z_result = "above"

	if(pin_z_result)
		var/result = compare_z(here_zlevel, there_zlevel)
		if(isnull(result)) // null: no good to track z levels
			add_overlay("pinon[alert ? "alert" : ""]null[icon_suffix]")
			return
		else if(!result) // FALSE: z-levels are in different groups. (i.e. Station v.s. Lavaland)
			if(!tracks_grand_z)
				add_overlay("pinon[alert ? "alert" : ""]null[icon_suffix]")
				return
			else
				z_level_direction = "located at [SSorbits.get_orbital_map_name_from_z(there_zlevel) || scramble_message_replace_chars("???????", replaceprob=85)]"
				add_overlay("pinon[alert ? "alert" : ""]z[icon_suffix]")
				return
		else // TRUE: z-levels are in the same group (i.e. multi-floored station)
			z_level_direction = "located [abs(there_zlevel - here_zlevel)] floors [pin_z_result]"
	if(!tracks_grand_z)
		z_level_direction = ""

	// getting xy result
	if(get_dist_euclidian(here,there) <= minimum_range)
		pin_xy_result = "direct"
	else
		setDir(get_dir(here, there))
		switch(get_dist(here, there))
			if(1 to 8)
				pin_xy_result = "close"
			if(9 to 16)
				pin_xy_result = "medium"
			if(16 to INFINITY)
				pin_xy_result = "far"


	// building overlays with sprite components
	add_overlay(alert ? "pincomp_base_alert[icon_suffix]" : "pincomp_base[icon_suffix]")
	if(pin_z_result)
		add_overlay("pincomp_z_[pin_z_result][icon_suffix]")
	add_overlay("pincomp_arrow_[pin_xy_result][icon_suffix]")
	if(alert)
		pin_xy_result = pin_xy_result=="direct" ? "direct_" : ""
		add_overlay("pincomp_arrow_[pin_xy_result]alert[icon_suffix]")

/obj/item/pinpointer/proc/trackable(atom/target)
	return checks_trackable_core(src, target, tracks_grand_z, jamming_resistance)

/// compares if get_virtual_z_level() of two parameters is the same orbital map. this can be used in lifeline app too
/proc/compare_z(here_z, there_z)
	var/here_map = SSorbits.get_orbital_map_name_from_z(here_z)
	var/there_map = SSorbits.get_orbital_map_name_from_z(there_z)
	if(isnull(here_map) || isnull(there_map))
		return null
	if(here_map == there_map)
		return TRUE
	else
		return FALSE

/// checks if it's basically trackable - used by pinpointer item and a radar
/proc/checks_trackable_core(atom/given_here, atom/given_there, powerful_z_check=FALSE, jam_level=JAMMER_PROTECTION_SENSOR_NETWORK)
	if(!given_here || !given_there)
		return FALSE
	var/turf/here = get_turf(given_here)
	var/turf/there = get_turf(given_there)
	if(!here || !there)
		return FALSE

	if(there.is_jammed(jam_level))
		return FALSE

	if(!powerful_z_check) // z-check will be only limited within the same area (i.e. multi-floor'ed station)
		if(!compare_z(here.get_virtual_z_level(), there.get_virtual_z_level()))
			return FALSE

	return TRUE

/proc/checks_trackable_lifeline(atom/given_here, atom/given_there, powerful_z_check=FALSE, jam_level=JAMMER_PROTECTION_SENSOR_NETWORK, ignore_suit_sensor_level=FALSE)
	// do the core thing first
	if(!checks_trackable_core(given_here, given_there, powerful_z_check, jam_level))
		return FALSE

	var/mob/living/L = given_there

	if(HAS_TRAIT(L, TRAIT_NANITE_SENSORS) && (ishuman(L) || L.mind)) // they should be fakehuman with no mind, or be a mob with mind. Nanites spam to mobs will be annoying
		return TRUE

	if(!ishuman(L)) // now human-only part. non-humans should have passed this from above already.
		return FALSE

	var/mob/living/carbon/human/H = L
	if(!H.w_uniform) // clothless humans should have passed this already
		return FALSE

	var/obj/item/clothing/under/U = H.w_uniform
	if(!U.has_sensor || (U.sensor_mode < SENSOR_COORDS && !ignore_suit_sensor_level))
		return FALSE

	return TRUE

/obj/item/pinpointer/crew // A replacement for the old crew monitoring consoles
	name = "crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors."
	icon_state = "pinpointer_crew"
	custom_price = 150
	jamming_resistance = JAMMER_PROTECTION_SENSOR_NETWORK
	var/has_owner = FALSE
	var/pinpointer_owner = null

/obj/item/pinpointer/crew/examine(mob/user)
	. = ..()
	if(!active || !target)
		return
	. += "It is currently tracking <b>[target]</b>."

/obj/item/pinpointer/crew/trackable(mob/living/L)
	return checks_trackable_lifeline(src, L, tracks_grand_z, jamming_resistance)


/obj/item/pinpointer/crew/attack_self(mob/living/user)
	if(active)
		toggle_on()
		user.visible_message("<span class='notice'>[user] deactivates [user.p_their()] pinpointer.</span>", "<span class='notice'>You deactivate your pinpointer.</span>")
		return

	if (has_owner && !pinpointer_owner)
		pinpointer_owner = user

	if (pinpointer_owner && pinpointer_owner != user)
		to_chat(user, "<span class='notice'>The pinpointer doesn't respond. It seems to only recognise its owner.</span>")
		return

	var/list/name_counts = list()
	var/list/names = list()

	for(var/mob/living/L in GLOB.suit_sensors_list)
		if(!trackable(L))
			continue

		var/crewmember_name = "Unknown"
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.wear_id)
				var/obj/item/card/id/I = H.wear_id.GetID()
				if(I?.registered_name)
					crewmember_name = I.registered_name
		else
			crewmember_name = L.name // non-human can't get ID card, but displaying them as Unknown is annoying

		while(crewmember_name in name_counts)
			name_counts[crewmember_name]++
			crewmember_name = "[crewmember_name] ([name_counts[crewmember_name]])"
		names[crewmember_name] = L
		name_counts[crewmember_name] = 1

	if(!names.len)
		user.visible_message("<span class='notice'>[user]'s pinpointer fails to detect a signal.</span>", "<span class='notice'>Your pinpointer fails to detect a signal.</span>")
		return

	var/A = input(user, "Person to track", "Pinpoint") in sort_list(names)
	if(!A || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated())
		return

	target = names[A]
	toggle_on()
	user.visible_message("<span class='notice'>[user] activates [user.p_their()] pinpointer.</span>", "<span class='notice'>You activate your pinpointer.</span>")

/obj/item/pinpointer/crew/scan_for_target()
	if(target)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(!trackable(H))
				target = null
	if(!target) //target can be set to null from above code, or elsewhere
		active = FALSE


/obj/item/pinpointer/pair
	name = "pair pinpointer"
	desc = "A handheld tracking device that locks onto its other half of the matching pair."
	tracks_grand_z = TRUE
	var/other_pair

/obj/item/pinpointer/pair/Destroy()
	other_pair = null
	. = ..()

/obj/item/pinpointer/pair/scan_for_target()
	target = other_pair

/obj/item/pinpointer/pair/examine(mob/user)
	. = ..()
	if(!active || !target)
		return
	var/mob/mob_holder = get(target, /mob)
	if(istype(mob_holder))
		. += "Its pair is being held by [mob_holder]."
		return

/obj/item/storage/box/pinpointer_pairs
	name = "pinpointer pair box"

/obj/item/storage/box/pinpointer_pairs/PopulateContents()
	var/obj/item/pinpointer/pair/A = new(src)
	var/obj/item/pinpointer/pair/B = new(src)

	A.other_pair = B
	B.other_pair = A

/obj/item/pinpointer/shuttle
	name = "hunter shuttle pinpointer"
	desc = "A handheld tracking device that locates the bounty hunter shuttle for quick escapes."
	icon_state = "pinpointer_hunter"
	icon_suffix = "-hunter"
	tracks_grand_z = TRUE
	var/obj/shuttleport

/obj/item/pinpointer/shuttle/Initialize(mapload)
	. = ..()
	shuttleport = SSshuttle.getShuttle("huntership")

/obj/item/pinpointer/shuttle/scan_for_target()
	target = shuttleport

/obj/item/pinpointer/shuttle/Destroy()
	shuttleport = null
	. = ..()
