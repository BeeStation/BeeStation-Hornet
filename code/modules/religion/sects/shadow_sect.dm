/datum/religion_sect/shadow_sect
	starter = FALSE
	name = "Shadow"
	desc = "A sect dedicated to plunging everything into darkness. The rest of the station may not take kindly to putting all of the lights out."
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
		/datum/religion_rites/shadow_conversion,
		/datum/religion_rites/grand_ritual_one
		///datum/religion_rites/grand_ritual_two   // Grand rituals are added to this list by previous rituals
		///datum/religion_rites/grand_ritual_three // So they are here in effect, just hidden for now
	)


	altar_icon_state = "convertaltar-dark"
	var/light_reach = 1 // range of light for obelisks
	var/light_power = -1 // power of light for obelisks
	var/list/obelisks = list() // list of all obelisks
	var/obelisk_number = 0  // number of obelisks
	var/list/active_obelisks = list() // list of obelisks anchored to the floor aka "active"
	var/active_obelisks_number = 0 //number of anchored obelisks
	var/night_vision_active = FALSE // if night vision aura of obelisks is active
	var/grand_ritual_in_progress = FALSE // whether a grand ritual is being performed
	var/grand_ritual_level = 0 // what is the level of the last performed ritual (max is 3)


#define DARKNESS_INVERSE_COLOR "#AAD84B" //The color of light has to be inverse, since we're using negative light power

//Shadow sect doesn't heal non shadowpeople
/datum/religion_sect/shadow_sect/sect_bless(mob/living/blessed, mob/living/user)
	if(isshadow(blessed))
		var/mob/living/carbon/human/O = blessed
		var/datum/species/shadow/S = O.dna.species
		S.change_hearts_ritual(blessed)
		blessed.heal_overall_damage(5, 5, 20, BODYTYPE_ORGANIC)
		to_chat(user, span_notice("You bless [blessed] with the power of [GLOB.deity], healing them and spreading blessings."))
	return TRUE


/datum/religion_sect/shadow_sect/on_sacrifice(obj/item/N, mob/living/L)
	if(!istype(N, /obj/item/flashlight))
		return
	adjust_favor(20, L)
	to_chat(L, span_notice("You offer [N] to [GLOB.deity], pleasing them and gaining 20 favor in the process."))
	qdel(N)
	return TRUE

///Used to make obelisks flicker for the duration of a ritual. Flickering will persist for the duration even if the ritual is interrupted
/datum/religion_sect/shadow_sect/proc/flicker_obelisks(duration)
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in active_obelisks)
		obelisk.flickering = duration

///Check the conditions shared by the three grand rituals, condensed into a single proc to cut down on duplicate code
/datum/religion_sect/shadow_sect/proc/grand_ritual_checks(mob/living/user, atom/religious_tool, pre_ritual_check = FALSE)

	if(pre_ritual_check)
		if(!isblessedshadow(user))
			to_chat(user, span_warning("How dare someone not of blessed shadow kind try to communicate with shadows!"))
			return FALSE

		if(!(light_reach > 4 * (1 + grand_ritual_level)))
			to_chat(user, span_warning("You need to strengthen the shadows before you can begin the ritual. Expand shadows to their limits."))
			return FALSE

		if(!GLOB.religious_sect.altar_anchored)
			to_chat(user, span_warning("The altar must be secured to the floor if you wish to perform the rite!"))
			return FALSE

	if(active_obelisks_number < 5 + (grand_ritual_level * 10))
		if(pre_ritual_check)
			to_chat(user, span_warning("You need to anchor the shadows to this reality. You need [5 * (grand_ritual_level + 1)] active obelisks."))
		else
			to_chat(user, span_warning("Your obelisks have been destroyed, destabilizing the ritual! You need to gather your strength and try again."))
		return FALSE

	return TRUE

///Upgrades all obelisks and the sect's level after successful ritual
/datum/religion_sect/shadow_sect/proc/sect_level_up()

	///level up!
	grand_ritual_level++
	light_power--

	//Obelisk code
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in obelisks)
		obelisk.upgrade_obelisk()

	//Blessings of the ritual for people of shadow
	for(var/mob/living/carbon/human/M in GLOB.mob_list)
		if(isshadow(M))
			M.heal_overall_damage(25 * grand_ritual_level, 25 * grand_ritual_level, 200)
			if(isblessedshadow(M))
				var/datum/species/shadow/S = M.dna.species
				S.change_hearts_ritual(M)

// Shadow sect construction
/obj/structure/destructible/religion/shadow_obelisk
	name = "Shadow Obelisk"
	desc = "Idol to darkness, letting shadows enter the world."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "shadow_obelisk_1"
	anchored = FALSE
	break_message = span_warning("The Obelisk crumbles before you!")
	max_integrity = 20
	damage_deflection = 10
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/list/affected_mobs = list()
	var/flickering = 0

/obj/structure/destructible/religion/shadow_obelisk/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/structure/destructible/religion/shadow_obelisk/Destroy()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	sect.obelisk_number = sect.obelisk_number - 1
	sect.obelisks -= src
	STOP_PROCESSING(SSobj, src)
	if(anchored)
		sect.active_obelisks -= src
		sect.active_obelisks_number -= 1
	for(var/X in affected_mobs)
		on_mob_leave(X)
	return ..()


/obj/structure/destructible/religion/shadow_obelisk/process(delta_time)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!src.anchored)
		if (length(affected_mobs) != 0)
			affected_mobs -= affected_mobs
		return
	var/list/current_mobs = view(sect.light_reach, src)
	for(var/mob/living/mob_in_range in current_mobs)
		if(!(mob_in_range in affected_mobs))
			on_mob_enter(mob_in_range)
			affected_mobs[mob_in_range] = 0

		affected_mobs[mob_in_range]++
		on_mob_effect(mob_in_range)

	for(var/M in affected_mobs - current_mobs)
		on_mob_leave(M)
		affected_mobs -= M

	if(flickering > 0)
		flickering -= delta_time
		set_light(round(sect.light_reach / rand(1, 3)), sect.light_power, DARKNESS_INVERSE_COLOR)
	else
		set_light(round(sect.light_reach), sect.light_power, DARKNESS_INVERSE_COLOR)

/obj/structure/destructible/religion/shadow_obelisk/proc/on_mob_enter(mob/living/affected_mob)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.night_vision_active)
		if(!HAS_TRAIT_FROM(affected_mob,TRAIT_NIGHT_VISION,FROM_SHADOW_SECT))
			ADD_TRAIT(affected_mob,TRAIT_NIGHT_VISION, FROM_SHADOW_SECT)


/obj/structure/destructible/religion/shadow_obelisk/proc/on_mob_effect(mob/living/affected_mob)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.night_vision_active)
		if(!HAS_TRAIT_FROM(affected_mob,TRAIT_NIGHT_VISION,FROM_SHADOW_SECT))
			ADD_TRAIT(affected_mob,TRAIT_NIGHT_VISION, FROM_SHADOW_SECT)
	else
		if(HAS_TRAIT_FROM(affected_mob,TRAIT_NIGHT_VISION,FROM_SHADOW_SECT))
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

/obj/structure/destructible/religion/shadow_obelisk/proc/toggling_buckling_after_ritual_3() // this is useless until it is inherited by obelisk after 3 grand rituals
	return

/obj/structure/destructible/religion/shadow_obelisk/attackby(obj/item/I, mob/living/user, params)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(istype(I, /obj/item/nullrod))
		if(sect.grand_ritual_in_progress)
			to_chat(user,span_warning("You can't move an obelisk during a active ritual!"))
			return
		if(anchored)
			unanchored_NV()
			anchored = !anchored
			sect.active_obelisks_number -= 1
			sect.active_obelisks -= src
			user.visible_message(span_notice("[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I]."), span_notice("You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I]."))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
			toggling_buckling_after_ritual_3()
			return
		else
			var/list/current_objects = range(5, src)
			for(var/obj/structure/destructible/religion/shadow_obelisk/D in current_objects)
				if(D.anchored)
					to_chat(user,span_warning("You can't place obelisks so close to each other!"))
					return
			anchored = !anchored
			sect.active_obelisks += src
			sect.active_obelisks_number += 1
			set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
			user.visible_message(span_notice("[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I]."), span_notice("You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I]."))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
			toggling_buckling_after_ritual_3()
			return

	if(I.tool_behaviour == TOOL_WRENCH && isshadow(user))
		if(sect.grand_ritual_in_progress)
			to_chat(user,span_warning("You can't move the obelisk during a active ritual!"))
			return
		if (!anchored)
			var/list/current_objects = range(5, src)
			for(var/obj/structure/destructible/religion/shadow_obelisk/D in current_objects)
				if(D.anchored)
					to_chat(user,span_warning("You can't place obelisks so close to each other!"))
					return
			anchored = !anchored
			sect.active_obelisks += src
			sect.active_obelisks_number += 1
			set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
			user.visible_message(span_notice("[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I]."), span_notice("You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I]."))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
			toggling_buckling_after_ritual_3()
		else
			to_chat(user,span_warning("You feel like only a nullrod could move this obelisk."))
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
	var/favor_gained = max(0.5, sect.grand_ritual_level) * delta_time
	sect.adjust_favor(favor_gained)

/datum/component/dark_favor/proc/return_creator()
	return creator


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
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,span_warning("You are about to convert the one buckled to [movable_reltool]."))
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,span_warning("This rite requires a religious device that individuals can be buckled to."))
			return FALSE
		if(isblessedshadow(user))
			to_chat(user,span_warning("You've already converted yourself. To convert others, they must be buckled to [movable_reltool]."))
			return FALSE
		to_chat(user,span_warning("You're going to convert yourself with this ritual."))
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
	rite_target.set_species(/datum/species/shadow/blessed)
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE


/datum/religion_rites/shadow_obelisk
	name = "Obelisk Manifestation"
	desc = "Creates an obelisk that generates shadows and additional favor. The cost of this ritual increases with each obelisk."
	ritual_length = 15 SECONDS
	ritual_invocations = list(
		"Let the shadows combine...",
		"... Solidify and grow ...",
		"... Make an idol to emanate shadows ...")
	invoke_msg = "I summon forth an obelisk, to appease the darkness."
	favor_cost = 100


/datum/religion_rites/shadow_obelisk/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	//In case an obelisk is destroyed, set this again so we don't charge too much favor
	favor_cost = (100 * sect.obelisk_number) + 100
	if(favor_cost > sect.favor)
		to_chat(user, span_warning("You need at least [favor_cost] to perform this ritual now."))
		return FALSE
	return ..()

/datum/religion_rites/shadow_obelisk/invoke_effect(mob/living/user, atom/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/obj/structure/destructible/religion/shadow_obelisk/obelisk = new(altar_turf)
	sect.obelisks += obelisk
	sect.obelisk_number = sect.obelisk_number + 1
	obelisk.AddComponent(/datum/component/dark_favor, user)
	obelisk.upgrade_obelisk()
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)

	sect.adjust_favor(favor_cost)
	//set the cost so it updates the next time the interface is opened (if someone can make it do this that would be great)
	favor_cost = (100 * sect.obelisk_number) + 100
	return ..()


/datum/religion_rites/expand_shadows
	name = "Shadow Expansion"
	desc = "Grow the reach of shadows extending from the altar, and any obelisks. The cost of this ritual increases with each use."
	ritual_length = 20 SECONDS
	ritual_invocations = list(
		"Spread out...",
		"... Kill the light ...",
		"... Encompass it all in darkness ...")
	invoke_msg = "Shadows, reach your tendrils from my altar, and extend thy domain."
	favor_cost = 300


/datum/religion_rites/expand_shadows/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if((sect.light_reach > 4 * (1 + sect.grand_ritual_level)) || sect.grand_ritual_level == 3)
		to_chat(user, span_warning("The shadows emanating from your idols are as strong as they could be."))
		if(sect.grand_ritual_level != 3)
			to_chat(user, span_warning("Performing a grand ritual would let more shadows move into this world."))
		return FALSE
	if(favor_cost > sect.favor)
		to_chat(user, span_warning("You need at least [favor_cost] to perform this ritual now."))
		return FALSE
	sect.flicker_obelisks(ritual_length)
	return ..()

/datum/religion_rites/expand_shadows/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect)
		return

	sect.light_reach += 1
	religious_tool.set_light(ceil(sect.light_reach/3), sect.light_power, DARKNESS_INVERSE_COLOR)
	for(var/obj/structure/destructible/religion/shadow_obelisk/D in sect.obelisks)
		if (D.anchored)
			D.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)

	sect.adjust_favor(favor_cost)
	favor_cost = sect.light_reach * 300

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
	sect.adjust_favor(favor_cost)


// Grand ritual section

/obj/structure/destructible/religion/shadow_obelisk/after_rit_1
	icon_state = "shadow_obelisk_2"
	var/in_use = FALSE

/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/after_rit_2 // some cursed incheritence, but this is the easiest way to do it
	icon_state = "shadow_obelisk_3"

/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/after_rit_2/process(delta_time)
	. = ..()
	if(!anchored)
		return
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.grand_ritual_in_progress)
		return
	for(var/mob/living/L in view(6, src))
		if(L.health == L.maxHealth)
			continue
		if(!isshadow(L))
			continue
		var/turf/T = L.loc
		if(istype(T))
			var/light_amount = T.get_lumcount()
			if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD)
				continue
			L.heal_overall_damage(0.5 * delta_time, 0.5 * delta_time, 5 * delta_time, FALSE, TRUE)


/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/after_rit_2/after_rit_3
	icon_state = "shadow_obelisk_4"
	can_buckle = FALSE // it will be posible once anchored
	var/converting = 0


/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/after_rit_2/after_rit_3/toggling_buckling_after_ritual_3()
	. = ..()
	if(anchored)
		can_buckle = TRUE
	else
		unbuckle_all_mobs(TRUE)
		can_buckle = FALSE

/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/after_rit_2/after_rit_3/post_buckle_mob(mob/living/M)
	. = ..()
	if(isblessedshadow(M) || isnightmare(M))
		unbuckle_mob(M, TRUE)
		visible_message(span_warning("[M.name] seems to fall through the obelisk."))
		return

	if(isshadow(M))
		M.set_species(/datum/species/shadow/blessed)
		unbuckle_mob(M, TRUE)
		visible_message(span_warning("[M.name] seems to fall through the obelisk, taking in some of its power."))
		return

	if(!ishuman(M))
		unbuckle_mob(M, TRUE)
		visible_message(span_warning("Obelisk can't hold [M.name] in place."))
		return

	to_chat(M,span_userdanger("You feel the obelisk channel shadows through you. You feel yourself changing!"))

/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/after_rit_2/after_rit_3/process(delta_time)
	if(LAZYLEN(buckled_mobs) != 0)
		converting += 1
		if (converting >= 30)
			converting = 0
			for(var/mob/living/carbon/human/buckled in buckled_mobs)
				buckled.visible_message(span_notice("[buckled.name] merged with shadows and drops from the obelisk."), span_userdanger("Shadows infuse your body changing you into one of them."))
				buckled.set_species(/datum/species/shadow/blessed)
				unbuckle_mob(buckled, TRUE)
	else
		converting = 0
	. = ..()

/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/attack_hand(mob/user)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!isshadow(user) && !user.mind?.holy_role)
		return

	if(!anchored)
		return

	if(in_use)
		return

	var/list/local_obelisk_list = sect.active_obelisks.Copy()
	local_obelisk_list -= src
	if(!LAZYLEN(local_obelisk_list))
		return ..()

	if(local_obelisk_list.len == 1)
		user.visible_message(span_notice("[user.name] walks into the obelisk."), span_notice("You walk into the obelisk."))
		do_teleport(user, local_obelisk_list[1], no_effects = TRUE)
		user.visible_message(span_notice("[user.name] walks out of obelisk."), span_notice("To emerge on the other side."))
		return

	in_use = TRUE

	var/list/assoc_list = list()

	for(var/OB in local_obelisk_list)
		var/area/ob_area = get_area(OB)
		var/name = "[ob_area.name] shadow obelisk"
		var/counter = 0

		do
			counter++
		while(assoc_list["[name]([counter])"])

		name += "([counter])"

		assoc_list[name] = OB

	var/chosen_input = input(user,"Which obelisk you want to move to?",null) as null|anything in assoc_list
	in_use = FALSE

	if(!chosen_input || !assoc_list[chosen_input])
		return

	user.visible_message(span_notice("[user.name] walks into the obelisk."), span_notice("You walk into the obelisk."))
	do_teleport(user ,assoc_list[chosen_input], no_effects = TRUE)
	user.visible_message(span_notice("[user.name] walks out of the obelisk."), span_notice("To emerge on the other side."))

/obj/structure/destructible/religion/shadow_obelisk/proc/upgrade_obelisk()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/datum/component/dark_favor/component_previous = GetComponent(/datum/component/dark_favor)
	var/user = component_previous.return_creator()
	var/our_turf = get_turf(src)

	if(sect.grand_ritual_level == 1)
		var/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/obelisk = new(our_turf)
		sect.obelisks += obelisk
		sect.obelisk_number = sect.obelisk_number + 1
		obelisk.AddComponent(/datum/component/dark_favor, user)
		obelisk.anchored = anchored
		if(anchored)
			sect.active_obelisks += obelisk
			sect.active_obelisks_number += 1
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
		Destroy()
	if(sect.grand_ritual_level == 2)
		var/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/after_rit_2/obelisk = new(our_turf)
		sect.obelisks += obelisk
		sect.obelisk_number = sect.obelisk_number + 1
		obelisk.AddComponent(/datum/component/dark_favor, user)
		obelisk.anchored = anchored
		if(anchored)
			sect.active_obelisks += obelisk
			sect.active_obelisks_number += 1
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
		Destroy()
	if(sect.grand_ritual_level == 3)
		var/obj/structure/destructible/religion/shadow_obelisk/after_rit_1/after_rit_2/after_rit_3/obelisk = new(our_turf)
		sect.obelisks += obelisk
		sect.obelisk_number = sect.obelisk_number + 1
		obelisk.AddComponent(/datum/component/dark_favor, user)
		obelisk.anchored = anchored
		if(anchored)
			sect.active_obelisks += obelisk
			sect.active_obelisks_number += 1
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
		obelisk.toggling_buckling_after_ritual_3()
		Destroy()

// Grand rituals themselves

/datum/religion_rites/grand_ritual_one
	name = "Grand ritual: Beckoning shadows"
	desc = "Convince shadows to take interest in your sect. Travel freely between obelisks with assistance of the shadows."
	ritual_length = 35 SECONDS
	ritual_invocations = list(
		"Shadows hear me...",
		"... Come to your kin ...",
		"... Help us spread darkness ...")
	invoke_msg = "I summon you to our beacons!"
	favor_cost = 2000

/datum/religion_rites/grand_ritual_one/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE

	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect.grand_ritual_checks(user, religious_tool, TRUE))
		return FALSE
	spawn()
	sect.flicker_obelisks(ritual_length)

	return ..()

/datum/religion_rites/grand_ritual_one/invoke_effect(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect.grand_ritual_checks(user, religious_tool, FALSE))
		sect.adjust_favor(-1 * favor_cost)
		return FALSE

	sect.sect_level_up()
	sect.rites_list -= /datum/religion_rites/grand_ritual_one
	sect.rites_list += /datum/religion_rites/grand_ritual_two
	return ..()

/datum/religion_rites/grand_ritual_two
	name = "Grand ritual: Infusing shadows"
	desc = "Start giving shadows a form in physical world. This will let them better heal the wounds of their kin and protect them from sight or harm."
	ritual_length = 70 SECONDS
	ritual_invocations = list(
		"Shadows hear me...",
		"... Come to your kin ...",
		"... Help us spread darkness ...",
		"... Enter our obelisks ...",
		"... Share your blessings ...",
		"... Heal our wounds ...")
	invoke_msg = "I give you a body to help us!"
	favor_cost = 10000

/datum/religion_rites/grand_ritual_two/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE

	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect.grand_ritual_checks(user, religious_tool, TRUE))
		return FALSE
	spawn()
	sect.flicker_obelisks(ritual_length)
	return ..()

/datum/religion_rites/grand_ritual_two/invoke_effect(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect.grand_ritual_checks(user, religious_tool, FALSE))
		sect.adjust_favor(-1 * favor_cost)
		return FALSE

	sect.sect_level_up()
	sect.rites_list -= /datum/religion_rites/grand_ritual_two
	//sect.rites_list += /datum/religion_rites/grand_ritual_three
	return ..()

/datum/religion_rites/grand_ritual_two/proc/handle_obelisks()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	for(var/mob/living/M in GLOB.mob_list)
		if(isshadow(M))
			to_chat(M, span_userdanger("You feel pull towards the obelisks, you feel like it would be safer near them."))
		to_chat(M, span_notice("Shadows seem to flicker in corner of your eye."))
	sleep(50)
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_warning("You are sure now that shadows are moving"))
	sleep(50)
	sect.grand_ritual_in_progress = TRUE
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(4, -15, DARKNESS_INVERSE_COLOR)
	sleep(600)
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	sect.grand_ritual_in_progress = FALSE

/datum/religion_rites/grand_ritual_three
	name = "Grand ritual: Welcoming shadows"
	desc = "Final grand ritual. Let shadows come into this world fully, letting their tender care allow kin to resurrect, help them move and let others join their glorious family."
	ritual_length = 105 SECONDS
	ritual_invocations = list(
		"Shadows hear me...",
		"... Come to your kin ...",
		"... Help us spread darkness ...",
		"... Enter our obelisks ...",
		"... Share your blessings ...",
		"... Heal our wounds ...",
		"... Gather here ...",
		"... Enter our reality ...",
		"... Strengthen us all ...")
	invoke_msg = "IM THE GATEWAY FOR YOU TO USE!"
	favor_cost = 50000

/datum/religion_rites/grand_ritual_three/perform_rite(mob/living/user, atom/religious_tool)
	if(!can_afford(user))
		return FALSE

	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect.grand_ritual_checks(user, religious_tool, TRUE))
		return FALSE
	spawn()
	sect.flicker_obelisks(ritual_length)
	return ..()

/datum/religion_rites/grand_ritual_three/invoke_effect(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect.grand_ritual_checks(user, religious_tool, FALSE))
		sect.adjust_favor(-1 * favor_cost)
		return FALSE
	sect.sect_level_up()
	sect.rites_list -= /datum/religion_rites/grand_ritual_three
	return ..()

/datum/religion_rites/grand_ritual_three/proc/handle_obelisks()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	for(var/mob/living/M in GLOB.mob_list)
		if(isshadow(M))
			to_chat(M, span_userdanger("You feel pull towards the obelisks, you feel like it would be safer near them."))
		to_chat(M, span_notice("Shadows seem to flicker in corner of your eye."))
	sleep(50)
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_warning("You are sure now that shadows are moving"))
	sleep(50)
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_warningbold("Shadows are all flowing towards some point, leaving only light behind!"))
	sleep(50)
	sect.grand_ritual_in_progress = TRUE
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(4, -30, DARKNESS_INVERSE_COLOR)
	for(var/turf/T in GLOB.station_turfs)
		if(T.light_range == 0)
			T.light_power = 1
			T.light_range = 3
			T.set_light_color("#f4f942")
			T.update_light()
	sleep(900)
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	if(sect.grand_ritual_level == 3)
		for(var/mob/living/M in GLOB.mob_list)
			if(isshadow(M))
				to_chat(M, span_noticebold("Ritual was finished. Rejoice for shadows walk among us."))
			else
				to_chat(M, span_noticebold("Shadows seem to go back to normal, but their darkness is so much deeper then before."))
	else
		for(var/mob/living/M in GLOB.mob_list)
			if(isshadow(M))
				to_chat(M, span_dangerbold("Ritual failed, shadows are barred from entering this realm still."))
			else
				to_chat(M, span_noticebold("Shadows returned looking a litle defeated."))
	sect.grand_ritual_in_progress = FALSE
	for(var/turf/T in GLOB.station_turfs)
		if(T.light_range == 3 && T.light_power == 1 && T.light_color == "#f4f942")
			T.light_power = 1
			T.light_range = 0
			T.set_light_color(null)
			T.update_light()

#undef DARKNESS_INVERSE_COLOR
