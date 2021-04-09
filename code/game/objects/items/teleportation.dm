
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

/obj/item/locator/attack_self(mob/user)
	user.set_machine(src)
	var/dat
	if (temp)
		dat = "[temp]<BR><BR><A href='byond://?src=[REF(src)];temp=1'>Clear</A>"
	else
		dat = {"
<B>Persistent Signal Locator</B><HR>
<A href='?src=[REF(src)];refresh=1'>Refresh</A>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/locator/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/turf/current_location = get_turf(usr)//What turf is the user on?
	if(!current_location || is_centcom_level(current_location.z))//If turf was not found or they're on CentCom
		to_chat(usr, "[src] is malfunctioning.")
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)))
		usr.set_machine(src)
		if (href_list["refresh"])
			temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				temp += "<B>Beacon Signals:</B><BR>"
				for(var/obj/item/beacon/W in GLOB.teleportbeacons)
					if (!W.renamed)
						continue
					var/turf/tr = get_turf(W)
					if (tr.z == sr.z && tr)
						var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						if (direct < 5)
							direct = "very strong"
						else
							if (direct < 10)
								direct = "strong"
							else
								if (direct < 20)
									direct = "weak"
								else
									direct = "very weak"
						temp += "[W.name]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				temp += "<B>Implant Signals:</B><BR>"
				for (var/obj/item/implant/tracking/W in GLOB.tracked_implants)
					if (!W.imp_in || !isliving(W.loc))
						continue
					else
						var/mob/living/M = W.loc
						if (M.stat == DEAD)
							if (M.timeofdeath + W.lifespan_postmortem < world.time)
								continue

					var/turf/tr = get_turf(W)
					if (tr.z == sr.z && tr)
						var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						if (direct < 20)
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									direct = "weak"
							temp += "[W.imp_in.name]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=[REF(src)];refresh=1'>Refresh</A><BR>"
			else
				temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else
			if (href_list["temp"])
				temp = null
		if (ismob(src.loc))
			attack_self(src.loc)
		else
			for(var/mob/M as() in viewers(1, src))
				if(M.client)
					src.attack_self(M)
	return


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
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/list/active_portal_pairs
	var/max_portal_pairs = 3
	var/atmos_link_override

/obj/item/hand_tele/Initialize()
	. = ..()
	active_portal_pairs = list()

/obj/item/hand_tele/pre_attack(atom/target, mob/user, params)
	if(try_dispel_portal(target, user))
		return FALSE
	return ..()

/obj/item/hand_tele/proc/try_dispel_portal(atom/target, mob/user)
	if(is_parent_of_portal(target))
		qdel(target)
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
	var/list/L = list(  )
	for(var/obj/machinery/computer/teleporter/com in GLOB.machines)
		if(com.target)
			var/area/A = get_area(com.target)
			if(!A || A.teleport_restriction)
				continue
			if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
				L["[get_area(com.target)] (Active)"] = com.target
			else
				L["[get_area(com.target)] (Inactive)"] = com.target
	var/list/turfs = list()
	for(var/turf/T as() in (RANGE_TURFS(10, src) - get_turf(src)))
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
	user.show_message("<span class='notice'>Locked In.</span>", MSG_AUDIBLE)
	var/list/obj/effect/portal/created = create_portal_pair(current_location, get_teleport_turf(get_turf(T)), src, 300, 1, null, atmos_link_override)
	if(!(LAZYLEN(created) == 2))
		return
	try_move_adjacent(created[1])
	active_portal_pairs[created[1]] = created[2]
	var/obj/effect/portal/c1 = created[1]
	var/obj/effect/portal/c2 = created[2]
	investigate_log("was used by [key_name(user)] at [AREACOORD(user)] to create a portal pair with destinations [AREACOORD(c1)] and [AREACOORD(c2)].", INVESTIGATE_PORTAL)
	add_fingerprint(user)

/obj/item/hand_tele/proc/on_portal_destroy(obj/effect/portal/P)
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
			var/list/safeLevels = SSmapping.levels_by_any_trait(list(ZTRAIT_SPACE_RUINS, ZTRAIT_LAVA_RUINS, ZTRAIT_STATION, ZTRAIT_MINING))
			head.forceMove(locate(rand(1, world.maxx), rand(1, world.maxy), pick(safeLevels)))
			itemUser.visible_message("<span class='suicide'>The portal snaps closed taking [user]'s head with it!</span>")
		else
			itemUser.visible_message("<span class='suicide'>[user] looks even further depressed as they realize they do not have a head...and suddenly dies of shame!</span>")
		return (BRUTELOSS)

/*
 * Syndicate Teleporter
 */

/obj/item/teleporter
	name = "syndicate teleporter"
	desc = "A Syndicate reverse-engineered version of the Nanotrasen portable handheld teleporter. It uses bluespace technology to translocate users, but lacks the advanced safety features of its counterpart. Warranty voided if exposed to an electromagnetic pulse."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi_tele"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10

	var/charges = 4
	var/max_charges = 4
	var/minimum_teleport_distance = 4
	var/maximum_teleport_distance = 8
	var/saving_throw_distance = 3
	var/recharge_time = 200 //20 Seconds
	var/recharging = FALSE

/obj/item/teleporter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] has [charges] out of [max_charges] charges left.</span>"

/obj/item/teleporter/attack_self(mob/user)
	..()
	attempt_teleport(user, FALSE)

/obj/item/teleporter/proc/check_charges()
	if(recharging)
		return
	if(charges < max_charges)
		addtimer(CALLBACK(src, .proc/recharge), recharge_time)
		recharging = TRUE

/obj/item/teleporter/proc/recharge()
	charges++
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
	var/turf/destination = get_teleport_loc(current_location,C,teleport_distance,0,0,0,0,0,0)
	var/list/bagholding = user.GetAllContents(/obj/item/storage/backpack/holding)

	if(isclosedturf(destination))
		if(!EMP_D && !(bagholding.len))
			panic_teleport(user, destination) //We're in a wall, engage emergency parallel teleport.
		else
			get_fragged(user, destination) //EMP teleported you into a wall? Wearing a BoH? You're dead.
	else
		telefrag(destination, user)
		do_teleport(C, destination, channel = TELEPORT_CHANNEL_FREE)
		charges--
		check_charges()
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(current_location)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
		playsound(destination, 'sound/effects/phasein.ogg', 25, 1)
		playsound(destination, "sparks", 50, 1)

/obj/item/teleporter/proc/panic_teleport(mob/user, turf/destination)
	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/turf/emergency_destination = get_teleport_loc(destination,C,0,0,1,saving_throw_distance,0,0,0)

	if(emergency_destination)
		telefrag(emergency_destination, user)
		do_teleport(C, emergency_destination, channel = TELEPORT_CHANNEL_FREE)
		charges--
		check_charges()
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(emergency_destination)
		playsound(emergency_destination, 'sound/effects/phasein.ogg', 25, 1)
		playsound(emergency_destination, "sparks", 50, 1)
	else //We tried to save. We failed. Death time.
		get_fragged(user, destination)

/obj/item/teleporter/proc/get_fragged(mob/user, turf/destination)
	var/turf/mobloc = get_turf(user)
	if(do_teleport(user, destination, channel = TELEPORT_CHANNEL_FREE, no_effects = TRUE))
		playsound(mobloc, "sparks", 50, TRUE)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(mobloc)
		new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(destination)
		playsound(destination, "sparks", 50, TRUE)
		playsound(destination, "sound/magic/disintegrate.ogg", 50, TRUE)
		to_chat(user, "<span class='userdanger'>You teleport into the wall, the teleporter tries to save you, but-</span>")
		destination.ex_act(2) //Destroy the wall
		user.gib()

/obj/item/teleporter/proc/telefrag(turf/fragging_location, mob/user)
	for(var/mob/living/M in fragging_location)//Hit everything in the turf
		M.apply_damage(20, BRUTE)
		M.Paralyze(30)
		to_chat(M, "<span class='userdanger'>[user] teleports into you, knocking you to the floor with the bluespace wave!</span>")

/obj/item/paper/teleporter
	name = "Teleporter Guide"
	icon_state = "paper"
	info = {"<b>Instructions on your new prototype syndicate teleporter:</b><br>
	<br>
	This experimental teleporter will teleport the user 4-8 meters in the direction they are facing. Anything you are pulling will not be teleported with you.<br>
	<br>
	It has 4 charges, and will recharge over time. No, sticking the teleporter into the tesla, an APC, a microwave, or an electrified door will not make it charge faster.<br>
	<br>
	<b>Warning:</b> Teleporting into walls will activate a failsafe teleport parallel up to 3 meters, but the user will be ripped apart and gibbed in the wall if it fails to find a safe location.<br>
	<br>
	Do not expose the teleporter to electromagnetic pulses, or possess a bag of holding while operating it. Unwanted malfunctions may occur.
"}
/obj/item/storage/box/syndie_kit/teleporter
	name = "syndicate teleporter kit"

/obj/item/storage/box/syndie_kit/teleporter/PopulateContents()
	new /obj/item/teleporter(src)
	new /obj/item/paper/teleporter(src)

/obj/effect/temp_visual/teleport_abductor/syndi_teleporter
	duration = 5

/obj/item/teleporter/admin
	charges = 999
	max_charges = 999
