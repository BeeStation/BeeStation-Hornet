// Shadow sect - Original code by DingoDongler, Remade by Wikimody

/datum/religion_sect/shadow_sect
	starter = FALSE
	name = "Shadow"
	desc = "A sect dedicated to the darkness. The manifested obelisks will generate favor from being in darkness."
	quote = "Turn out the lights, and let the darkness cover the world!"
	tgui_icon = "moon"
	alignment = ALIGNMENT_EVIL
	favor = 0
	max_favor = 50000
	desired_items = list(
		/obj/item/flashlight)
	rites_list = list(
		/datum/religion_rites/expand_shadows,
		/datum/religion_rites/shadow_obelisk,
		/datum/religion_rites/shadow_conversion
	)


	altar_icon_state = "convertaltar-dark"
	var/light_reach = 1
	var/light_power = 0
	var/list/obelisks = list()
	var/obelisk_number = 0
	var/night_vision_active = FALSE


//Shadow sect doesn't heal
/datum/religion_sect/shadow_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE


/datum/religion_sect/shadow_sect/on_sacrifice(obj/item/N, mob/living/L)
	if(!istype(N, /obj/item/flashlight))
		return
	adjust_favor(20, L)
	to_chat(L, "<span class='notice'>You offer [N] to [GLOB.deity], pleasing them and gaining 20 favor in the process.</span>")
	qdel(N)
	return TRUE


// Shadow sect construction
/obj/structure/destructible/religion/shadow_obelisk
	name = "Shadow Obelisk"
	desc = "Grants favor from being shrouded in shadows."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "shadow-obelisk"
	anchored = FALSE
	break_message = "<span class='warning'>The Obelisk crumbles before you!</span>"


/obj/structure/destructible/religion/shadow_obelisk/Destroy()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	sect.obelisk_number = sect.obelisk_number - 1
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/structure/destructible/religion/shadow_obelisk/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		anchored = !anchored
		user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.do_attack_animation(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH && isshadow(user))
		if (!anchored)
			anchored = !anchored
			user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
		else
			to_chat(user,"<span class='notice'>You feel like only nullrod coudl move this obelisc.</span>")
		return
	return ..()


// Favor generator component. Used on the altar and obelisks
/datum/component/dark_favor
	var/mob/living/creator


/datum/component/dark_favor/Initialize(mob/living/L)
	. = ..()
	if(!L)
		return
	creator = L
	START_PROCESSING(SSobj, src)


/datum/component/dark_favor/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)


/datum/component/dark_favor/process(delta_time)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!istype(parent, /atom) || !istype(creator) || !istype(sect))
		return
	var/atom/P = parent
	var/turf/T = P.loc
	if(!istype(T))
		return
	var/light_amount = T.get_lumcount()
	var/favor_gained = max(1 - light_amount, 0) * delta_time
	sect.adjust_favor(favor_gained, creator)


/**** Shadow rites ****/
#define DARKNESS_INVERSE_COLOR "#AAD84B" //The color of light has to be inverse, since we're using negative light power


/datum/religion_rites/shadow_conversion
	name = "Shadowperson Conversion"
	desc = "Converts a humanoid into a shadowperson, a race blessed by darkness."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Let the darkness seep into you...",
		"... And cover you, envelope you ...",
		"... And make you one with it ...")
	invoke_msg = "... And let you be born again!"
	favor_cost = 1200


/datum/religion_rites/shadow_conversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>You're going to convert the one buckled on [movable_reltool].</span>")
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return FALSE
		if(isshadow(user))
			to_chat(user,"<span class='warning'>You've already converted yourself. To convert others, they must be buckled to [movable_reltool].</span>")
			return FALSE
		to_chat(user,"<span class='warning'>You're going to convert yourself with this ritual.</span>")
	return ..()


/datum/religion_rites/shadow_conversion/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/shadow)
	rite_target.visible_message("<span class='notice'>[rite_target] has been converted by the rite of [name]!</span>")
	return TRUE


/datum/religion_rites/shadow_obelisk
	name = "Obelisk Manifestation"
	desc = "Creates an obelisk that generates favor when in a dark area."
	ritual_length = 20 SECONDS
	ritual_invocations = list(
		"Let the shadows combine...",
		"... Solidify and grow ...",
		"... Make an idol to eminate shadows ...")
	invoke_msg = "I summon forth an obelisk, to appease the darkness."
	favor_cost = 100


/datum/religion_rites/shadow_obelisk/invoke_effect(mob/living/user, atom/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	var/obj/structure/destructible/religion/shadow_obelisk/obelisk = new(altar_turf)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	sect.obelisks += obelisk
	sect.obelisk_number = sect.obelisk_number + 1
	obelisk.AddComponent(/datum/component/dark_favor, user)
	obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return ..()


/datum/religion_rites/expand_shadows
	name = "Shadow Expansion"
	desc = "Grow the reach of shadows extending from the altar, and any obelisks."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Spread out...",
		"... Kill the light ...",
		"... Encompass it all in darkness ...")
	invoke_msg = "Shadows, reach your tendrils from my altar, and extend thy domain."
	favor_cost = 200


/datum/religion_rites/expand_shadows/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if((sect.light_power <= -10) || (sect.light_reach >= 15))
		to_chat(user, "<span class='warning'>The shadows emanating from your idols is as strong as it could be.</span>")
		return FALSE
	return ..()


/datum/religion_rites/expand_shadows/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect)
		return
	sect.light_reach += 1.5
	sect.light_power -= 1
	religious_tool.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	for(var/obj/structure/destructible/religion/shadow_obelisk/D in sect.obelisks)
		D.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)



#undef DARKNESS_INVERSE_COLOR
