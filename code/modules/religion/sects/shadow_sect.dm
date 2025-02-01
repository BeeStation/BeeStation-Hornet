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
		/datum/religion_rites/nigth_vision_aura,
		/datum/religion_rites/shadow_conversion,
		/datum/religion_rites/grand_ritual_one
		///datum/religion_rites/grand_ritual_two   // Grand rituals are added to this list by previus rituals
		///datum/religion_rites/grand_ritual_three // So the are here in effect, just hiden for now
	)


	altar_icon_state = "convertaltar-dark"
	var/light_reach = 1
	var/light_power = 0
	var/list/obelisks = list()
	var/obelisk_number = 0
	var/list/active_obelisks = list()
	var/active_obelisk_number = 0
	var/night_vision_active = FALSE
	var/grand_ritual_in_progres = FALSE
	var/grand_ritual_level = 0


#define DARKNESS_INVERSE_COLOR "#AAD84B" //The color of light has to be inverse, since we're using negative light power

//Shadow sect doesn't heal non shadows
/datum/religion_sect/shadow_sect/sect_bless(mob/living/blessed, mob/living/user)
	if(isshadow(blessed))
		var/mob/living/carbon/human/S = blessed
		var/datum/species/shadow/spiec = S.dna.species
		spiec.change_hearts_ritual(blessed)
		blessed.heal_overall_damage(5, 5, 20, BODYTYPE_ORGANIC)
		to_chat(user, "<span class='notice'>You bless [blessed] with the power of [GLOB.deity], healing them and spreding blessings.</span>")
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
	max_integrity = 200
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
	if(anchored)
		sect.active_obelisks -= src
		sect.active_obelisk_number -= 1
	for(var/X in affected_mobs)
		on_mob_leave(X)
	return ..()


/obj/structure/destructible/religion/shadow_obelisk/process(delta_time)
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

/obj/structure/destructible/religion/shadow_obelisk/proc/var3_bucle_togle() // this is ussles untill it is inherited by var3
	return

/obj/structure/destructible/religion/shadow_obelisk/attackby(obj/item/I, mob/living/user, params)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(istype(I, /obj/item/nullrod))
		if(sect.grand_ritual_in_progres)
			return
		if(anchored)
			src.unanchored_NV()
			anchored = !anchored
			sect.active_obelisk_number -= 1
			sect.active_obelisks -= src
			user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
			var3_bucle_togle()
			return
		else
			var/list/current_objects = view_or_range(5, src, "range")
			for(var/obj/structure/destructible/religion/shadow_obelisk/D in current_objects)
				if(D.anchored)
					to_chat(user,"<span class='warning'>You cant place obelisks so close to eachother!</span>")
					return
			anchored = !anchored
			sect.active_obelisks += src
			sect.active_obelisk_number += 1
			src.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
			user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
			var3_bucle_togle()
			return

	if(I.tool_behaviour == TOOL_WRENCH && isshadow(user))
		if(sect.grand_ritual_in_progres)
			return
		if (!anchored)
			var/list/current_objects = view_or_range(5, src, "range")
			for(var/obj/structure/destructible/religion/shadow_obelisk/D in current_objects)
				if(D.anchored)
					to_chat(user,"<span class='warning'>You cant place obelisks so close to eachother!</span>")
					return
			anchored = !anchored
			sect.active_obelisks += src
			sect.active_obelisk_number += 1
			src.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
			user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.do_attack_animation(src)
			var3_bucle_togle()
		else
			to_chat(user,"<span class='warning'>You feel like only nullrod coudl move this obelisk.</span>")
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
		"... Make an idol to eminate shadows ...")
	invoke_msg = "I summon forth an obelisk, to appease the darkness."
	favor_cost = 100


/datum/religion_rites/shadow_obelisk/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/cost = 100 * sect.obelisk_number + 100
	if(sect.favor < cost)
		to_chat(user, "<span class='warning'>Your obelisk are getting harder to summon, as more matterialise. You need [cost] favor.</span>")
		return FALSE
	return ..()

/datum/religion_rites/shadow_obelisk/invoke_effect(mob/living/user, atom/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/obj/structure/destructible/religion/shadow_obelisk/obelisk = new(altar_turf)
	var/cost = 100 * sect.obelisk_number * -1
	sect.adjust_favor(cost, user)
	sect.obelisks += obelisk
	sect.obelisk_number = sect.obelisk_number + 1
	obelisk.AddComponent(/datum/component/dark_favor, user)
	obelisk.transform_obelisc()
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
	if((sect.light_power <= -6 - 5 * sect.grand_ritual_level) || (sect.light_reach >= 8 + 7.5 * sect.grand_ritual_level))
		to_chat(user, "<span class='warning'>The shadows emanating from your idols is as strong as it could be.</span>")
		if(sect.grand_ritual_level != 3)
			to_chat(user, "<span class='warning'>Performing grand ritual woudl let more shadow move into this world.</span>")
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


/datum/religion_rites/nigth_vision_aura
	name = "Provide nigth vision"
	desc = "Grands obelisk aura of night vision, with lets people see in darknes. Any aditional casting will turn it on or off."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Spread out...",
		"... Seep into them ...",
		"... Infuse their sight ...")
	invoke_msg = "Shadows, reach your tendrils from my altar, and grand thy sight to people."
	favor_cost = 1000

/datum/religion_rites/nigth_vision_aura/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	sect.night_vision_active = !sect.night_vision_active


// Grand ritual section

/obj/structure/destructible/religion/shadow_obelisk/var1
	max_integrity = 300
	desc = "Grants favor from being shrouded in shadows. Bleses all tiles in its radius."
	var/spread_delay = 80
	var/last_spread = 0

/obj/structure/destructible/religion/shadow_obelisk/var1/process(delta_time)
	. = ..()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!anchored)
		return
	if(last_spread <= world.time)
		for(var/turf/T in circlerangeturfs(src, sect.light_reach))
			if(istype(T))
				if(T.get_lumcount() <= 0)
					T.Bless()
	last_spread = world.time + spread_delay

/obj/structure/destructible/religion/shadow_obelisk/var1/var2 // some cursed incheritence, but its the easiest way to do it
	max_integrity = 400
	desc = "Grants favor from being shrouded in shadows. Bleses all tiles in its radius. Heals all shadowpeople in area."
	var/heal_delay = 50
	var/last_heal = 0

/obj/structure/destructible/religion/shadow_obelisk/var1/var2/process(delta_time)
	. = ..()
	if(!anchored)
		return
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(sect.light_reach, src))
			if(L.health == L.maxHealth)
				continue
			if(!isshadow(L) && !L.mind?.holy_role)
				continue
			new /obj/effect/temp_visual/heal(get_turf(src), "#29005f")
			if(isshadow(L) || L.mind?.holy_role)
				L.adjustBruteLoss(-1*delta_time, 0)
				L.adjustToxLoss(-2*delta_time, 0)
				L.adjustOxyLoss(-2*delta_time, 0)
				L.adjustFireLoss(-1*delta_time, 0)
				L.adjustCloneLoss(-2*delta_time, 0)
				L.updatehealth()
				if(L.blood_volume < BLOOD_VOLUME_NORMAL)
					L.blood_volume += 1.0

/obj/structure/destructible/religion/shadow_obelisk/var1/var2/var3
	max_integrity = 500
	desc = "Grants favor from being shrouded in shadows. Bleses all tiles in its radius. Heals all shadowpeople in area. People bucled to the obelisk will turn into shadow people, while shadow people can use them to teleport"
	can_buckle = FALSE // it will be posible once archoned
	var/converting = 0
	var/in_use = FALSE


/obj/structure/destructible/religion/shadow_obelisk/var1/var2/var3/var3_bucle_togle()
	. = ..()
	if(anchored)
		can_buckle = TRUE
	else
		unbuckle_all_mobs(TRUE)
		can_buckle = FALSE

/obj/structure/destructible/religion/shadow_obelisk/var1/var2/var3/post_buckle_mob(mob/living/M)
	. = ..()
	if(isshadow(M))
		unbuckle_mob(M, TRUE)
		visible_message(span_warning("[M.name] seems to fall through obelisk."))
		return

	if(!ishuman(M))
		unbuckle_mob(M, TRUE)
		visible_message(span_warning("Obelisk cant hold [M.name] in place."))
		return

	to_chat(M,span_userdanger("You feel obelisk chanel all its shadows though you. If you dont get off, you will be changed irrevocable way."))

/obj/structure/destructible/religion/shadow_obelisk/var1/var2/var3/process(delta_time)
	if(LAZYLEN(buckled_mobs) != 0)
		converting += 1
		if (converting >= 30)
			converting = 0
			for(var/mob/living/carbon/human/buckled in buckled_mobs)
				buckled.visible_message(span_notice("[buckled.name] merged with shadows and droped from obelisk."), span_userdanger("Shadows infuse your body changing you into one of them."))
				buckled.set_species(/datum/species/shadow)
				unbuckle_mob(buckled, TRUE)
	else
		converting = 0
	. = ..()

/obj/structure/destructible/religion/shadow_obelisk/var1/var2/var3/attack_hand(mob/user)
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
		user.visible_message(span_notice("[user.name] walked into obelisk."), span_notice("You walk into obelisk."))
		do_teleport(user, local_obelisk_list[1], no_effects = TRUE)
		user.visible_message(span_notice("[user.name] walked out of obelisk."), span_notice("To emerge on the other side."))
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

	var/chosen_input = input(user,"What destination do you want to choose",null) as null|anything in assoc_list
	in_use = FALSE

	if(!chosen_input || !assoc_list[chosen_input])
		return

	user.visible_message(span_notice("[user.name] walked into obelisk."), span_notice("You walk into obelisk."))
	do_teleport(user ,assoc_list[chosen_input], no_effects = TRUE)
	user.visible_message(span_notice("[user.name] walked out of obelisk."), span_notice("To emerge on the other side."))


/obj/structure/destructible/religion/shadow_obelisk/proc/transform_obelisc()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	var/datum/component/dark_favor/component_prievius = GetComponent(/datum/component/dark_favor)
	var/our_turf = get_turf(src)
	var/user = component_prievius.return_creator()
	if(sect.grand_ritual_level == 1)
		var/obj/structure/destructible/religion/shadow_obelisk/var1/obelisk = new(our_turf)
		sect.obelisks += obelisk
		sect.obelisk_number = sect.obelisk_number + 1
		obelisk.AddComponent(/datum/component/dark_favor, user)
		obelisk.anchored = anchored
		if(anchored)
			sect.active_obelisks += obelisk
			sect.active_obelisk_number += 1
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
		Destroy()
	if(sect.grand_ritual_level == 2)
		var/obj/structure/destructible/religion/shadow_obelisk/var1/var2/obelisk = new(our_turf)
		sect.obelisks += obelisk
		sect.obelisk_number = sect.obelisk_number + 1
		obelisk.AddComponent(/datum/component/dark_favor, user)
		obelisk.anchored = anchored
		if(anchored)
			sect.active_obelisks += obelisk
			sect.active_obelisk_number += 1
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
		Destroy()
	if(sect.grand_ritual_level == 3)
		var/obj/structure/destructible/religion/shadow_obelisk/var1/var2/var3/obelisk = new(our_turf)
		sect.obelisks += obelisk
		sect.obelisk_number = sect.obelisk_number + 1
		obelisk.AddComponent(/datum/component/dark_favor, user)
		obelisk.anchored = anchored
		if(anchored)
			sect.active_obelisks += obelisk
			sect.active_obelisk_number += 1
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
		Destroy()

// Grand rituals themselves

/datum/religion_rites/grand_ritual_one
	name = "Grand ritual: Beconing shadows"
	desc = "Convice shadows to take intrest in your cult. They will cary information betwen thier kind and their mere presence will make the darknes holier."
	ritual_length = 35 SECONDS
	ritual_invocations = list(
		"Let the shadows combine...",
		"... Solidify and grow ...",
		"... Make an idol to eminate shadows ...")
	invoke_msg = "I summon forth an obelisk, to appease the darkness."
	favor_cost = 1000

/datum/religion_rites/grand_ritual_one/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!isshadow(user))
		to_chat(user, "<span class='warning'>How dare somone not of shadow kind, try to comunicate with shadows!.</span>")
		return FALSE
	if(!((sect.light_power <= -6 - 5 * sect.grand_ritual_level) || (sect.light_reach >= 8 + 7.5 * sect.grand_ritual_level)))
		to_chat(user, "<span class='warning'>You need to strengthen the shadows before you can begin the ritual. Expand shadows to their limits.</span>")
		return FALSE
	if(sect.active_obelisk_number < 5 * (sect.grand_ritual_level + 1))
		to_chat(user, "<span class='warning'>You need to archon the shadows to this reality. You need [5 * (sect.grand_ritual_level + 1)] active obelisks.</span>")
		return FALSE
	if(!can_afford(user))
		return FALSE
	var/turf/T = get_turf(religious_tool)
	if(!T.is_holy())
		to_chat(user, span_warning("The altar can only function in a holy area!"))
		return FALSE
	if(!GLOB.religious_sect.altar_anchored)
		to_chat(user, span_warning("The altar must be secured to the floor if you wish to perform the rite!"))
		return FALSE
	spawn()
		handle_obeliscs()
	return ..()

/datum/religion_rites/grand_ritual_one/invoke_effect(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.active_obelisk_number < 5 * (sect.grand_ritual_level + 1))
		to_chat(user, "<span class='warning'>Your obelisc have been destroed, destabilising the ritual!. You need to gather your strangth and try again.</span>")
		sect.adjust_favor(-1 * favor_cost)
		return FALSE

	sect.grand_ritual_level = 1
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		obelisk.transform_obelisc()
	for(var/mob/living/carbon/human/M in GLOB.mob_list)
		if(isshadow(M))
			M.heal_overall_damage(100, 100, 200)
			var/datum/species/shadow/spiec = M.dna.species
			spiec.change_hearts_ritual(M)
	sect.rites_list -= /datum/religion_rites/grand_ritual_one
	sect.rites_list += /datum/religion_rites/grand_ritual_two
	return ..()

/datum/religion_rites/grand_ritual_one/proc/handle_obeliscs()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_notice("You see shadows flicer in corner of your eye."))
		if(isshadow(M))
			to_chat(M, span_userdanger("You feel pull towards the obeliscs, you feel like it woudl be safer near them."))
	sleep(50)
	sect.grand_ritual_in_progres = TRUE
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(4, -10, DARKNESS_INVERSE_COLOR)
	sleep(300)
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	sect.grand_ritual_in_progres = FALSE


/datum/religion_rites/grand_ritual_two
	name = "Grand ritual: Infusing shadows"
	desc = "Start giving shadows a form in physical world. This will let them heal the vounds of their kin and protect them from sight or harm."
	ritual_length = 70 SECONDS
	ritual_invocations = list(
		"Let the shadows combine...",
		"... Solidify and grow ...",
		"... Make an idol to eminate shadows ...")
	invoke_msg = "I summon forth an obelisk, to appease the darkness."
	favor_cost = 10000

/datum/religion_rites/grand_ritual_two/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!isshadow(user))
		to_chat(user, "<span class='warning'>How dare somone not of shadow kind, try to comunicate with shadows!.</span>")
		return FALSE
	if(!((sect.light_power <= -6 - 5 * sect.grand_ritual_level) || (sect.light_reach >= 8 + 7.5 * sect.grand_ritual_level)))
		to_chat(user, "<span class='warning'>You need to strengthen the shadows before you can begin the ritual. Expand shadows to their limits.</span>")
		return FALSE
	if(sect.active_obelisk_number < 5 * (sect.grand_ritual_level + 1))
		to_chat(user, "<span class='warning'>You need to archon the shadows to this reality. You need [5 * (sect.grand_ritual_level + 1)] active obelisks.</span>")
		return FALSE
	if(!can_afford(user))
		return FALSE
	var/turf/T = get_turf(religious_tool)
	if(!T.is_holy())
		to_chat(user, span_warning("The altar can only function in a holy area!"))
		return FALSE
	if(!GLOB.religious_sect.altar_anchored)
		to_chat(user, span_warning("The altar must be secured to the floor if you wish to perform the rite!"))
		return FALSE
	spawn()
		handle_obeliscs()
	return ..()

/datum/religion_rites/grand_ritual_two/invoke_effect(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.active_obelisk_number < 5 * (sect.grand_ritual_level + 1))
		to_chat(user, "<span class='warning'>Your obelisc have been destroed, destabilising the ritual!. You need to gather your strangth and try again.</span>")
		sect.adjust_favor(-1 * favor_cost)
		return FALSE

	sect.grand_ritual_level = 2
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		obelisk.transform_obelisc()
	for(var/mob/living/carbon/human/M in GLOB.mob_list)
		if(isshadow(M))
			M.fully_heal()
			var/datum/species/shadow/spiec = M.dna.species
			spiec.change_hearts_ritual(M)
	sect.rites_list -= /datum/religion_rites/grand_ritual_two
	sect.rites_list += /datum/religion_rites/grand_ritual_three
	return ..()

/datum/religion_rites/grand_ritual_two/proc/handle_obeliscs()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_notice("Shadows seem to flicer in corner of your eye."))
		if(isshadow(M))
			to_chat(M, span_userdanger("You feel pull towards the obeliscs, you feel like it woudl be safer near them."))
	sleep(50)
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_notice("You are sure now that shadows are moving"))
	sleep(50)
	sect.grand_ritual_in_progres = TRUE
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(4, -15, DARKNESS_INVERSE_COLOR)
	sleep(600)
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	sect.grand_ritual_in_progres = FALSE

/datum/religion_rites/grand_ritual_three
	name = "Grand ritual: Welcoming shadows"
	desc = "Final grand ritual. Let shadows come into this world fully, leting their tender care resurect any kin, help them move and let others join thier glorius family. BE WARNED gathering all shadows for this rite will let the light spread much further than normal."
	ritual_length = 105 SECONDS
	ritual_invocations = list(
		"Let the shadows combine...",
		"... Solidify and grow ...",
		"... Make an idol to eminate shadows ...")
	invoke_msg = "I summon forth an obelisk, to appease the darkness."
	favor_cost = 100000

/datum/religion_rites/grand_ritual_three/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!isshadow(user))
		to_chat(user, "<span class='warning'>How dare somone not of shadow kind, try to comunicate with shadows!.</span>")
		return FALSE
	if(!((sect.light_power <= -6 - 5 * sect.grand_ritual_level) || (sect.light_reach >= 8 + 7.5 * sect.grand_ritual_level)))
		to_chat(user, "<span class='warning'>You need to strengthen the shadows before you can begin the ritual. Expand shadows to their limits.</span>")
		return FALSE
	if(sect.active_obelisk_number < 5 * (sect.grand_ritual_level + 2))
		to_chat(user, "<span class='warning'>You need to archon the shadows to this reality. You need [5 * (sect.grand_ritual_level + 2)] active obelisks.</span>")
		return FALSE
	if(!can_afford(user))
		return FALSE
	var/turf/T = get_turf(religious_tool)
	if(!T.is_holy())
		to_chat(user, span_warning("The altar can only function in a holy area!"))
		return FALSE
	if(!GLOB.religious_sect.altar_anchored)
		to_chat(user, span_warning("The altar must be secured to the floor if you wish to perform the rite!"))
		return FALSE
	spawn()
		handle_obeliscs()
	return ..()


/datum/religion_rites/grand_ritual_three/invoke_effect(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.active_obelisk_number < 5 * (sect.grand_ritual_level + 2))
		to_chat(user, "<span class='warning'>Your obelisc have been destroed, destabilising the ritual!. You need to gather your strangth and try again.</span>")
		sect.adjust_favor(-1 * favor_cost)
		return FALSE

	sect.grand_ritual_level = 3
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		obelisk.transform_obelisc()
	for(var/mob/living/carbon/human/M in GLOB.mob_list)
		if(isshadow(M))
			M.revive(full_heal = TRUE)
			var/datum/species/shadow/spiec = M.dna.species
			spiec.change_hearts_ritual(M)
	sect.rites_list -= /datum/religion_rites/grand_ritual_three
	return ..()

/datum/religion_rites/grand_ritual_three/proc/handle_obeliscs()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_notice("Shadows seem to flicer in corner of your eye."))
		if(isshadow(M))
			to_chat(M, span_userdanger("YOU KNOW THAT YOU NEED TO RUN TO CLOSEST OBELISK IF YOU WANT TO LIVE."))
	sleep(50)
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_notice("You are sure now that shadows are moving"))
	sleep(50)
	for(var/mob/living/M in GLOB.mob_list)
		to_chat(M, span_notice("Shadows are all flowing towards some point, leaving only light bechind!"))
	sleep(50)
	sect.grand_ritual_in_progres = TRUE
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(4, -30, DARKNESS_INVERSE_COLOR)
	var/list/turf/changed_turfs
	for(var/turf/T in GLOB.station_turfs)
		if(T.light_power == 0)
			changed_turfs += T
			T.light_power = 3
			T.light_range = 3
	sleep(900)
	for(var/obj/structure/destructible/religion/shadow_obelisk/obelisk in sect.obelisks)
		if(obelisk.anchored)
			obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	for(var/turf/T in changed_turfs)
		if(istype(T))
			changed_turfs += T
			T.light_power = 0
			T.light_range = 1
	sect.grand_ritual_in_progres = FALSE

#undef DARKNESS_INVERSE_COLOR
