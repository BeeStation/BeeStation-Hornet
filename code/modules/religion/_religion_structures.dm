/obj/structure/altar_of_gods
	name = "\improper Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags_self = LETPASSTHROW
	can_buckle = TRUE
	buckle_lying = 90 //we turn to you!
	resistance_flags = INDESTRUCTIBLE
	///Avoids having to check global everytime by referencing it locally.
	var/datum/religion_sect/sect_to_altar

/obj/structure/altar_of_gods/Initialize(mapload)
	. = ..()
	reflect_sect_in_icons()
	AddElement(/datum/element/climbable)
	AddComponent(/datum/component/religious_tool, ALL, FALSE, CALLBACK(src, PROC_REF(reflect_sect_in_icons)))

/obj/structure/altar_of_gods/attack_hand(mob/living/user)
	if(!Adjacent(user) || !user.pulling)
		return ..()
	if(!isliving(user.pulling))
		return ..()
	var/mob/living/pushed_mob = user.pulling
	if(pushed_mob.buckled)
		to_chat(user, span_warning("[pushed_mob] is buckled to [pushed_mob.buckled]!"))
		return ..()
	to_chat(user, span_notice("You try to coax [pushed_mob] onto [src]..."))
	if(!do_after(user,(5 SECONDS),target = pushed_mob))
		return ..()
	pushed_mob.forceMove(loc)
	return ..()

/obj/structure/altar_of_gods/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		if(user.mind?.holy_role == NONE)
			to_chat(user, span_warning("Only the faithful may control the disposition of [src]!"))
			return
		anchored = !anchored
		if(GLOB.religious_sect)
			GLOB.religious_sect.altar_anchored = anchored //Having more than one altar of the gods is only possible through adminbus so this should screw with normal gameplay
		user.visible_message(span_notice("[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I]."), span_notice("You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I]."))
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
