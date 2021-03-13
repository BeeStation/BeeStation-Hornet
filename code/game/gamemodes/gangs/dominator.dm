#define DOM_BLOCKED_SPAM_CAP 6
#define DOM_REQUIRED_TURFS 30
#define DOM_HULK_HITS_REQUIRED 10

/obj/machinery/dominator
	name = "dominator"
	desc = "A visibly sinister device. Looks like you can break it if you hit it enough."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = TRUE
	anchored = TRUE
	layer = HIGH_OBJ_LAYER
	max_integrity = 300
	integrity_failure = 100
	move_resist = INFINITY
	armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 10, "acid" = 70, "stamina" = 0)
	var/datum/team/gang/gang
	var/operating = FALSE	//false=standby or broken, true=takeover
	var/warned = FALSE	//if this device has set off the warning at <3 minutes yet
	var/spam_prevention = DOM_BLOCKED_SPAM_CAP //first message is immediate
	var/datum/effect_system/spark_spread/spark_system
	var/obj/effect/countdown/dominator/countdown

/obj/machinery/dominator/Initialize()
	. = ..()
	set_light(2)
	GLOB.poi_list |= src
	spark_system = new
	spark_system.set_up(5, TRUE, src)
	countdown = new(src)
	update_icon()

/obj/machinery/dominator/Destroy()
	if(!(stat & BROKEN))
		set_broken()
	GLOB.poi_list.Remove(src)
	gang = null
	QDEL_NULL(spark_system)
	QDEL_NULL(countdown)
	return ..()

/obj/machinery/dominator/emp_act(severity)
	take_damage(100, BURN, "energy", 0)
	..()

/obj/machinery/dominator/hulk_damage()
	return (max_integrity - integrity_failure) / DOM_HULK_HITS_REQUIRED

/obj/machinery/dominator/tesla_act()
	qdel(src)

/obj/machinery/dominator/update_icon()
	cut_overlays()
	if(!(stat & BROKEN))
		icon_state = "dominator-active"
		if(operating)
			var/mutable_appearance/dominator_overlay = mutable_appearance('icons/obj/machines/dominator.dmi', "dominator-overlay")
			if(gang)
				dominator_overlay.color = gang.color
			add_overlay(dominator_overlay)
		else
			icon_state = "dominator"
		if(obj_integrity/max_integrity < 0.66)
			add_overlay("damage")
	else
		icon_state = "dominator-broken"

/obj/machinery/dominator/examine(mob/user)
	..()
	if(stat & BROKEN)
		return

	if(gang && gang.domination_time != NOT_DOMINATING)
		if(gang.domination_time > world.time)
			to_chat(user, "<span class='notice'>Hostile Takeover in progress. Estimated [gang.domination_time_remaining()] seconds remain.</span>")
		else
			to_chat(user, "<span class='notice'>Hostile Takeover of [station_name()] successful. Have a great day.</span>")
	else
		to_chat(user, "<span class='notice'>System on standby.</span>")
	to_chat(user, "<span class='danger'>System Integrity: [round((obj_integrity/max_integrity)*100,1)]%</span>")

/obj/machinery/dominator/process()
	if(gang && gang.domination_time != NOT_DOMINATING)
		var/time_remaining = gang.domination_time_remaining()
		if(time_remaining > 0)
			if(excessive_walls_check())
				gang.domination_time += 20
				playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
				if(spam_prevention < DOM_BLOCKED_SPAM_CAP)
					spam_prevention++
				else
					gang.message_gangtools("Warning: There are too many walls around your gang's dominator, its signal is being blocked!")
					say("Error: Takeover signal is currently blocked! There are too many walls within 3 standard units of this device.")
					spam_prevention = 0
				return
			. = TRUE
			playsound(loc, 'sound/items/timer.ogg', 10, 0)
			if(!warned && (time_remaining < 180))
				warned = TRUE
				var/area/domloc = get_area(loc)
				gang.message_gangtools("Less than 3 minutes remains in hostile takeover. Defend your dominator at [domloc.map_name]!")
				for(var/G in GLOB.gangs)
					var/datum/team/gang/tempgang = G
					if(tempgang != gang)
						tempgang.message_gangtools("WARNING: [gang.name] Gang takeover imminent. Their dominator at [domloc.map_name] must be destroyed!",1,1)
		else
			Cinematic(CINEMATIC_MALF,world)
			gang.winner = TRUE
			SSticker.force_ending = TRUE

	if(!.)
		return PROCESS_KILL

/obj/machinery/dominator/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/bang.ogg', 50, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/dominator/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.)
		if(obj_integrity/max_integrity > 0.66)
			if(prob(damage_amount*2))
				spark_system.start()
		else if(!(stat & BROKEN))
			spark_system.start()
			update_icon()


/obj/machinery/dominator/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		set_broken()

/obj/machinery/dominator/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(stat & BROKEN))
			set_broken()
		new /obj/item/stack/sheet/plasteel(src.loc)
	qdel(src)

/obj/machinery/dominator/attacked_by(obj/item/I, mob/living/user)
	add_fingerprint(user)
	..()

/obj/machinery/dominator/attack_hand(mob/user)
	if(operating || (stat & BROKEN))
		examine(user)
		return

	var/datum/team/gang/tempgang

	var/datum/antagonist/gang/GA = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(GA)
		tempgang = GA.gang
	if(!tempgang)
		examine(user)
		return

	if(tempgang.domination_time != NOT_DOMINATING)
		to_chat(user, "<span class='warning'>Error: Hostile Takeover is already in progress.</span>")
		return

	if(!tempgang.dom_attempts)
		to_chat(user, "<span class='warning'>Error: Unable to breach station network. Firewall has logged our signature and is blocking all further attempts.</span>")
		return

	var/time = round(tempgang.determine_domination_time()/60,0.1)
	if(alert(user,"A takeover will require [time] minutes.\nYour gang will be unable to gain influence while it is active.\nThe entire station will likely be alerted to it once it starts.\nYou have [tempgang.dom_attempts] attempt(s) remaining. Are you ready?","Confirm","Ready","Later") == "Ready")
		if((tempgang.domination_time != NOT_DOMINATING) || !tempgang.dom_attempts || !in_range(src, user) || !isturf(loc))
			return 0

		var/area/A = get_area(loc)
		var/locname = A.map_name

		gang = tempgang
		gang.dom_attempts --
		priority_announce("Network breach detected in [locname]. The [gang.name] Gang is attempting to seize control of the station!","Network Alert")
		gang.domination()
		SSshuttle.registerHostileEnvironment(src)
		name = "[gang.name] Gang [name]"
		operating = TRUE
		update_icon()

		countdown.color = gang.color
		countdown.start()

		set_light(3)
		START_PROCESSING(SSmachines, src)

		gang.message_gangtools("Hostile takeover in progress: Estimated [time] minutes until victory.[gang.dom_attempts ? "" : " This is your final attempt."]")
		for(var/G in GLOB.gangs)
			var/datum/team/gang/vagos = G
			if(vagos != gang)
				vagos.message_gangtools("Enemy takeover attempt detected in [locname]: Estimated [time] minutes until our defeat.",1,1)

/obj/machinery/dominator/proc/excessive_walls_check() // why the fuck was this even a global proc...
	var/open = FALSE
	if(isclosedturf(loc))
		return TRUE
	for(var/turf/open/T in view(3, src))
		open++
	if(open < DOM_REQUIRED_TURFS)
		return TRUE
	else
		return FALSE

/obj/machinery/dominator/proc/set_broken()
	if(gang)
		gang.domination_time = NOT_DOMINATING

		var/takeover_in_progress = FALSE
		for(var/G in GLOB.gangs)
			var/datum/team/gang/ballas = G
			if(ballas.domination_time != NOT_DOMINATING)
				takeover_in_progress = TRUE
				break
		if(!takeover_in_progress)
			var/was_stranded = SSshuttle.emergency.mode == SHUTTLE_STRANDED
			if(!was_stranded)
				priority_announce("All hostile activity within station systems has ceased.","Network Alert")

			if(get_security_level() == "delta")
				set_security_level("red")

		SSshuttle.clearHostileEnvironment(src)
		gang.message_gangtools("Hostile takeover cancelled: Dominator is no longer operational.[gang.dom_attempts ? " You have [gang.dom_attempts] attempt remaining." : " The station network will have likely blocked any more attempts by us."]",1,1)

	set_light(0)
	operating = FALSE
	stat |= BROKEN
	update_icon()
	STOP_PROCESSING(SSmachines, src)

#undef DOM_BLOCKED_SPAM_CAP
#undef DOM_REQUIRED_TURFS
#undef DOM_HULK_HITS_REQUIRED
