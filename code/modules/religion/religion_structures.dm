/obj/structure/altar_of_gods
	name = "\improper Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	pass_flags_self = LETPASSTHROW
	can_buckle = TRUE
	buckle_lying = 90 //we turn to you!
	resistance_flags = INDESTRUCTIBLE
	///Avoids having to check global everytime by referencing it locally.
	var/datum/religion_sect/sect_to_altar

/obj/structure/altar_of_gods/Initialize(mapload)
	. = ..()
	reflect_sect_in_icons()

/obj/structure/altar_of_gods/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/religious_tool, ALL, FALSE, CALLBACK(src, PROC_REF(reflect_sect_in_icons)))

/obj/structure/altar_of_gods/attack_hand(mob/living/user)
	if(!Adjacent(user) || !user.pulling)
		return ..()
	if(!isliving(user.pulling))
		return ..()
	var/mob/living/pushed_mob = user.pulling
	if(pushed_mob.buckled)
		to_chat(user, "<span class='warning'>[pushed_mob] is buckled to [pushed_mob.buckled]!</span>")
		return ..()
	to_chat(user,"<span class='notice>You try to coax [pushed_mob] onto [src]...</span>")
	if(!do_after(user,(5 SECONDS),target = pushed_mob))
		return ..()
	pushed_mob.forceMove(loc)
	return ..()

/obj/structure/altar_of_gods/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		if(user.mind?.holy_role == NONE)
			to_chat(user, "<span class='warning'>Only the faithful may control the disposition of [src]!</span>")
			return
		anchored = !anchored
		if(GLOB.religious_sect)
			GLOB.religious_sect.altar_anchored = anchored //Having more than one altar of the gods is only possible through adminbus so this should screw with normal gameplay
		user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.do_attack_animation(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		return
	return ..()


/obj/structure/altar_of_gods/proc/reflect_sect_in_icons()
	if(GLOB.religious_sect)
		sect_to_altar = GLOB.religious_sect
		if(sect_to_altar.altar_icon)
			icon = sect_to_altar.altar_icon
		if(sect_to_altar.altar_icon_state)
			icon_state = sect_to_altar.altar_icon_state

/obj/structure/destructible/religion
	density = TRUE
	anchored = FALSE
	icon = 'icons/obj/religion.dmi'
	light_power = 2
	var/cooldowntime = 0
	break_sound = 'sound/effects/glassbr2.ogg'

/obj/structure/destructible/religion/nature_pylon
	name = "Orb of Nature"
	desc = "A floating crystal that slowly heals all plantlife and holy creatures. It can be anchored with a null rod."
	icon_state = "nature_orb"
	anchored = FALSE
	light_range = 5
	light_color = LIGHT_COLOR_GREEN
	break_message = "<span class='warning'>The luminous green crystal shatters!</span>"
	var/heal_delay = 20
	var/last_heal = 0
	var/spread_delay = 45
	var/last_spread = 0

/obj/structure/destructible/religion/nature_pylon/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/destructible/religion/nature_pylon/LateInitialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/religion/nature_pylon/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/structure/destructible/religion/nature_pylon/process(delta_time)
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(L.health == L.maxHealth)
				continue
			if(!ispodperson(L) && !L.mind?.holy_role)
				continue
			new /obj/effect/temp_visual/heal(get_turf(src), "#47ac05")
			if(ispodperson(L) || L.mind?.holy_role)
				L.adjustBruteLoss(-2*delta_time, 0)
				L.adjustToxLoss(-2*delta_time, 0)
				L.adjustOxyLoss(-2*delta_time, 0)
				L.adjustFireLoss(-2*delta_time, 0)
				L.adjustCloneLoss(-2*delta_time, 0)
				L.updatehealth()
				if(L.blood_volume < BLOOD_VOLUME_NORMAL)
					L.blood_volume += 1.0
			CHECK_TICK
	if(last_spread <= world.time)
		var/list/validturfs = list()
		var/list/natureturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/open/floor/grass))
				natureturfs |= T
				continue
			var/static/list/blacklisted_pylon_turfs = typecacheof(list(
				/turf/closed,
				/turf/open/floor/grass,
				/turf/open/space,
				/turf/open/lava,
				/turf/open/chasm))
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_spread = world.time + spread_delay

		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/open/floor/plating))
				T.PlaceOnTop(pick(/turf/open/floor/grass, /turf/open/floor/grass/fairy/green), flags = CHANGETURF_INHERIT_AIR)
			else
				T.ChangeTurf(pick(/turf/open/floor/grass, /turf/open/floor/grass/fairy/green), flags = CHANGETURF_INHERIT_AIR)
		else
			var/turf/open/floor/grass/F = safepick(natureturfs)
			if(F)
				new /obj/effect/temp_visual/religion/turf/floor(F)
			else
				// Are we in space or something? No grass turfs or
				// convertable turfs?
				last_spread = world.time + spread_delay*2

/obj/structure/destructible/religion/nature_pylon/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		if(user.mind?.holy_role == NONE)
			to_chat(user, "<span class='warning'>Only the faithful may control the disposition of [src]!</span>")
			return
		anchored = !anchored
		user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.do_attack_animation(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		return
	return ..()
