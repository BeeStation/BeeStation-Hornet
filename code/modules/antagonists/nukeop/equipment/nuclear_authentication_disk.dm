/obj/item/disk
	icon = 'icons/obj/module.dmi'
	w_class = WEIGHT_CLASS_TINY
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "datadisk0"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound =  'sound/items/handling/disk_pickup.ogg'

/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	persistence_replacement = /obj/item/disk/nuclear/fake
	max_integrity = 250
	armor_type = /datum/armor/disk_nuclear
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/fake = FALSE
	var/turf/lastlocation
	var/last_disk_move
	var/process_tick = 0
	investigate_flags = ADMIN_INVESTIGATE_TARGET
	COOLDOWN_DECLARE(weight_increase_cooldown)

/datum/armor/disk_nuclear
	bomb = 30
	fire = 100
	acid = 100

/obj/item/disk/nuclear/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bed_tuckable, 6, -6, 0)

	if(!fake)
		AddComponent(/datum/component/stationloving, !fake)
		AddElement(/datum/element/point_of_interest)
		last_disk_move = world.time
		START_PROCESSING(SSobj, src)
		//Global teamfinder signal trackable on the synd frequency.
		AddComponent(/datum/component/tracking_beacon, "synd", null, null, TRUE, "#ebeca1", TRUE, TRUE, "#818157")
		AddElement(/datum/element/trackable)

/obj/item/disk/nuclear/process()
	++process_tick
	if(fake)
		STOP_PROCESSING(SSobj, src)
		CRASH("A fake nuke disk tried to call process(). Who the fuck and how the fuck")
	var/turf/newturf = get_turf(src)
	if(newturf && lastlocation == newturf)
		/// How comfy is our disk?
		var/disk_comfort_level = 0

		//Go through and check for items that make disk comfy
		for(var/comfort_item in loc)
			if(istype(comfort_item, /obj/item/bedsheet) || istype(comfort_item, /obj/structure/bed))
				disk_comfort_level++

		if(COOLDOWN_FINISHED(src, weight_increase_cooldown) && last_disk_move < world.time - (5 MINUTES) && world.time > (30 MINUTES))
			var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
			if(istype(loneop) && loneop.occurrences < loneop.max_occurrences)
				loneop.weight += 5
				COOLDOWN_START(src, weight_increase_cooldown, (5 MINUTES))
				message_admins("[src] is stationary in [ADMIN_VERBOSEJMP(newturf)]. The weight of Lone Operative is now [loneop.weight].")
				log_game("[src] is stationary for too long in [loc_name(newturf)], and has increased the weight of the Lone Operative event to [loneop.weight].")
				if(disk_comfort_level >= 2 && (process_tick % 30) == 0)
					visible_message(span_notice("[src] sleeps soundly. Sleep tight, disky."))

	else
		lastlocation = newturf
		last_disk_move = world.time
		var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
		if(istype(loneop) && loneop.occurrences < loneop.max_occurrences && prob(loneop.weight))
			loneop.weight = max(loneop.weight - 1, 0)
			if(loneop.weight % 5 == 0 && SSticker.totalPlayers > 1)
				message_admins("[src] is on the move (currently in [ADMIN_VERBOSEJMP(newturf)]). The weight of Lone Operative is now [loneop.weight].")
			log_game("[src] being on the move has reduced the weight of the Lone Operative event to [loneop.weight].")

/obj/item/disk/nuclear/examine(mob/user)
	. = ..()
	if(!fake)
		return

	if(isobserver(user) || HAS_MIND_TRAIT(user, TRAIT_DISK_VERIFIER))
		. += span_warning("The serial numbers on [src] are incorrect.")

/obj/item/disk/nuclear/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/claymore/highlander) && !fake)
		var/obj/item/claymore/highlander/H = I
		if(H.nuke_disk)
			to_chat(user, span_notice("Wait... what?"))
			qdel(H.nuke_disk)
			H.nuke_disk = null
			return
		user.visible_message(span_warning("[user] captures [src]!"), span_userdanger("You've got the disk! Defend it with your life!"))
		forceMove(H)
		H.nuke_disk = src
		return TRUE
	return ..()

/obj/item/disk/nuclear/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is going delta! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/machines/alarm.ogg', 50, -1, TRUE)
	for(var/i in 1 to 100)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, add_atom_colour), (i % 2)? COLOR_VIBRANT_LIME : COLOR_RED, ADMIN_COLOUR_PRIORITY), i)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 101)
	return MANUAL_SUICIDE

/obj/item/disk/nuclear/proc/manual_suicide(mob/living/user)
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
	user.visible_message(span_suicide("[user] is destroyed by the nuclear blast!"))
	user.adjustOxyLoss(200)
	user.death(FALSE)

/obj/item/disk/nuclear/fake
	fake = TRUE

/obj/item/disk/nuclear/fake/obvious
	name = "cheap plastic imitation of the nuclear authentication disk"
	desc = "How anyone could mistake this for the real thing is beyond you."
