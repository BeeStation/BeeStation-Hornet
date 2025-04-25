/datum/religion_sect/shadow_sect
	starter = FALSE
	name = "Shadow"
	desc = "A sect dedicated to the darkness. The manifested obelisks will generate favor from being in darkness."
	quote = "Turn out the lights, and let the darkness cover the world!"
	tgui_icon = "moon"
	alignment = ALIGNMENT_EVIL
	favor = 0
	max_favor = 100000
	desired_items = list(
		/obj/item/flashlight)
	rites_list = list(
		/datum/religion_rites/shadow_obelisk,
		/datum/religion_rites/expand_shadows,
		/datum/religion_rites/night_vision_aura,
		/datum/religion_rites/shadow_conversion
	)


	altar_icon_state = "convertaltar-dark"
	var/light_reach = 1
	var/light_power = 0
	var/list/obelisks = list()
	var/obelisk_number = 0
	var/night_vision_active = FALSE


#define DARKNESS_INVERSE_COLOR "#AAD84B" //The color of light has to be inverse, since we're using negative light power

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
	max_integrity = 300
	damage_deflection = 10
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/list/affected_mobs = list()


/obj/structure/destructible/religion/shadow_obelisk/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/structure/destructible/religion/shadow_obelisk/Destroy()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	sect.obelisk_number = sect.obelisk_number - 1
	sect.obelisks -= src
	STOP_PROCESSING(SSobj, src)
	for(var/X in affected_mobs)
		on_mob_leave(X)
	return ..()


/obj/structure/destructible/religion/shadow_obelisk/process()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!src.anchored)
		if (length(affected_mobs) != 0)
			affected_mobs -= affected_mobs
		return
	var/list/current_mobs = view_or_range(sect.light_reach, src, "range")
	for(var/mob/living/mob_in_range in current_mobs)
		if(!(mob_in_range in affected_mobs))
			on_mob_enter(mob_in_range)
			affected_mobs[mob_in_range] = 0

		affected_mobs[mob_in_range]++
		on_mob_effect(mob_in_range)

	for(var/M in affected_mobs - current_mobs)
		on_mob_leave(M)
		affected_mobs -= M


/obj/structure/destructible/religion/shadow_obelisk/proc/on_mob_enter(mob/living/affected_mob)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.night_vision_active)
		if(!HAS_TRAIT_FROM(affected_mob,TRAIT_NIGHT_VISION,FROM_SHADOW_SECT))
			ADD_TRAIT(affected_mob,TRAIT_NIGHT_VISION, FROM_SHADOW_SECT)


/obj/structure/destructible/religion/shadow_obelisk/proc/on_mob_effect(mob/living/affected_mob)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.night_vision_active)
		if(HAS_TRAIT_FROM(affected_mob,TRAIT_NIGHT_VISION,FROM_SHADOW_SECT))
			return
		else
			ADD_TRAIT(affected_mob,TRAIT_NIGHT_VISION, FROM_SHADOW_SECT)
	else
		if(!HAS_TRAIT_FROM(affected_mob,TRAIT_NIGHT_VISION,FROM_SHADOW_SECT))
			return
		else
			REMOVE_TRAIT(affected_mob,TRAIT_NIGHT_VISION, FROM_SHADOW_SECT)


/obj/structure/destructible/religion/shadow_obelisk/proc/on_mob_leave(mob/living/affected_mob)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/is_in_range_obelisk = FALSE
	if(!sect.night_vision_active)
		if(HAS_TRAIT_FROM(affected_mob,TRAIT_NIGHT_VISION,FROM_SHADOW_SECT))
			REMOVE_TRAIT(affected_mob,TRAIT_NIGHT_VISION, FROM_SHADOW_SECT)
			return
	for(var/obj/structure/destructible/religion/shadow_obelisk/D in sect.obelisks)
		if (D.anchored)
			if(get_dist(D, affected_mob) <= sect.light_reach)
				is_in_range_obelisk = TRUE
				break
	if(!is_in_range_obelisk)
		if(HAS_TRAIT_FROM(affected_mob,TRAIT_NIGHT_VISION,FROM_SHADOW_SECT))
			REMOVE_TRAIT(affected_mob,TRAIT_NIGHT_VISION, FROM_SHADOW_SECT)


/obj/structure/destructible/religion/shadow_obelisk/proc/unanchored_NV()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	for(var/mob/each_mob in range(src,sect.light_reach))
		on_mob_leave(each_mob)
	src.set_light(0, 0, DARKNESS_INVERSE_COLOR)


/obj/structure/destructible/religion/shadow_obelisk/attackby(obj/item/I, mob/living/user, params)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(istype(I, /obj/item/nullrod))
		if(anchored)
			src.unanchored_NV()
			anchored = !anchored
			user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
			return
		else
			var/list/current_objects = view_or_range(5, src, "range")
			for(var/obj/structure/destructible/religion/shadow_obelisk/D in current_objects)
				if(D.anchored)
					to_chat(user,"<span class='warning'>You can't place obelisks so close to each other!</span>")
					return
			anchored = !anchored
			src.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
			user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
			return
	if(I.tool_behaviour == TOOL_WRENCH && isshadow(user))
		if (!anchored)
			var/list/current_objects = view_or_range(5, src, "range")
			for(var/obj/structure/destructible/religion/shadow_obelisk/D in current_objects)
				if(D.anchored)
					to_chat(user,"<span class='warning'>You can't place obelisks so close to each other!</span>")
					return
			anchored = !anchored
			src.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
			user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
		else
			to_chat(user,"<span class='warning'>You feel like only a nullrod could move this obelisk.</span>")
		return
	return ..()



// Favor generator component. Used on the altar and obelisks
/datum/component/dark_favor
	var/mob/living/creator
	var/obj/structure/par


/datum/component/dark_favor/Initialize(mob/living/L)
	. = ..()
	if(!L)
		return
	creator = L
	par = parent
	START_PROCESSING(SSobj, src)


/datum/component/dark_favor/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)


/datum/component/dark_favor/process(delta_time)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!par.anchored)
		return
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
	ritual_length = 15 SECONDS
	ritual_invocations = list(
		"Let the shadows combine...",
		"... Solidify and grow ...",
		"... Make an idol to emanate shadows ...")
	invoke_msg = "I summon forth an obelisk, to appease the darkness."
	favor_cost = 100


/datum/religion_rites/shadow_obelisk/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/cost = 100 * sect.obelisk_number + 100
	if(sect.favor < cost)
		to_chat(user, "<span class='warning'>Your obelisks are getting harder to summon as more materialize. You need [cost] favor.</span>")
		return FALSE
	return ..()

/datum/religion_rites/shadow_obelisk/invoke_effect(mob/living/user, atom/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	var/obj/structure/destructible/religion/shadow_obelisk/obelisk = new(altar_turf)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/cost = 100 * sect.obelisk_number * -1
	sect.adjust_favor(cost, user)
	sect.obelisks += obelisk
	sect.obelisk_number = sect.obelisk_number + 1
	obelisk.AddComponent(/datum/component/dark_favor, user)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return ..()


/datum/religion_rites/expand_shadows
	name = "Shadow Expansion"
	desc = "Grow the reach of shadows extending from the altar, and any obelisks."
	ritual_length = 20 SECONDS
	ritual_invocations = list(
		"Spread out...",
		"... Kill the light ...",
		"... Encompass it all in darkness ...")
	invoke_msg = "Shadows, reach your tendrils from my altar, and extend thy domain."
	favor_cost = 200


/datum/religion_rites/expand_shadows/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/cost = 200 * sect.light_power * -1 + 200
	if(sect.favor < cost)
		to_chat(user, "<span class='warning'>The shadows emanating from your idols need more favor to expand. You need [cost].</span>")
		return FALSE
	if((sect.light_power <= -11) || (sect.light_reach >= 15))
		to_chat(user, "<span class='warning'>The shadows emanating from your idols are as strong as they could be.</span>")
		return FALSE
	return ..()


/datum/religion_rites/expand_shadows/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect)
		return
	var/cost = 200 * sect.light_power
	sect.adjust_favor(cost, user)
	sect.light_reach += 1.5
	sect.light_power -= 1
	religious_tool.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	for(var/obj/structure/destructible/religion/shadow_obelisk/D in sect.obelisks)
		if (D.anchored)
			D.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)


/datum/religion_rites/night_vision_aura
	name = "Provide night vision"
	desc = "Grants obelisks an aura of night vision which lets people see in darkness. Any additional casting will turn it on or off."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Spread out...",
		"... Seep into them ...",
		"... Infuse their sight ...")
	invoke_msg = "Shadows, reach your tendrils from my altar, and grant thy sight to people."
	favor_cost = 1000

/datum/religion_rites/night_vision_aura/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	sect.night_vision_active = !sect.night_vision_active


#undef DARKNESS_INVERSE_COLOR
