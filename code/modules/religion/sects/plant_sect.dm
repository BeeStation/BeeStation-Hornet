/datum/religion_sect/plant_sect
	name = "Nature"
	desc = "A sect dedicated to nature, plants, and animals. Sacrificing seeds grants you favor."
	quote = "Living plant people? What has the world come to!"
	tgui_icon = "tree"
	alignment = ALIGNMENT_GOOD
	max_favor = 10000
	desired_items = list(
		/obj/item/seeds)
	rites_list = list(
		/datum/religion_rites/create_diona,
		/datum/religion_rites/create_sandstone,
		/datum/religion_rites/grass_generator,
		/datum/religion_rites/summon_animals)
	altar_icon_state = "convertaltar-green"

//plant bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/plant_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/plant_sect/on_sacrifice(obj/item/N, mob/living/L)
	if(!istype(N, /obj/item/seeds))
		return
	adjust_favor(25, L)
	to_chat(L, span_notice("You offer [N] to [GLOB.deity], pleasing them and gaining 25 favor in the process."))
	qdel(N)
	return TRUE



/obj/structure/destructible/religion/nature_pylon
	name = "Orb of Nature"
	desc = "A floating crystal that slowly heals all plantlife and holy creatures. It can be anchored with a null rod."
	icon_state = "nature_orb"
	anchored = FALSE
	light_range = 5
	light_color = LIGHT_COLOR_GREEN
	break_message = span_warning("The luminous green crystal shatters!")
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
			if(!isdiona(L) && !L.mind?.holy_role)
				continue
			new /obj/effect/temp_visual/heal(get_turf(src), "#47ac05")
			if(isdiona(L) || L.mind?.holy_role)
				L.adjustBruteLoss(-2*delta_time, 0)
				L.adjustToxLoss(-2*delta_time, 0)
				L.adjustOxyLoss(-2*delta_time, 0)
				L.adjustFireLoss(-2*delta_time, 0)
				L.adjustCloneLoss(-2*delta_time, 0)
				L.updatehealth()
				if(L.blood_volume < BLOOD_VOLUME_NORMAL)
					L.blood_volume += 1.0

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
				/turf/open/chasm,
				/turf/open/openspace,
				/turf/open/floor/plating/beach,
				/turf/open/indestructible,
				/turf/open/floor/prison,
			))
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
			to_chat(user, span_warning("Only the faithful may control the disposition of [src]!"))
			return
		anchored = !anchored
		user.visible_message(span_notice("[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I]."), span_notice("You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I]."))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.do_attack_animation(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		return
	return ..()


/**** Plant rites ****/
/datum/religion_rites/summon_animals
	name = "Create Life"
	desc = "Creates a few animals, this can range from butterflys to giant frogs! Please be careful."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Great Mother ...",
		"... bring us new life ...",
		"... to join with our nature ...",
		"... and live amongst us ...")
	invoke_msg = "... We summon thee, Animals from the Byond!" //might adjust to beyond due to ooc/ic/meta
	favor_cost = 500

/datum/religion_rites/summon_animals/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/bluespace_fissure/long(altar_turf)
	user.visible_message(span_notice("A tear in reality appears above the altar!"))
	return ..()

/datum/religion_rites/summon_animals/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	var/turf/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 8)
		var/mob/living/spawned_mob = create_random_mob(altar_turf, FRIENDLY_SPAWN)
		spawned_mob.faction |= FACTION_NEUTRAL
	playsound(altar_turf, 'sound/ambience/servicebell.ogg', 25, TRUE)
	if(prob(0.1))
		playsound(altar_turf, 'sound/effects/bamf.ogg', 100, TRUE)
		altar_turf.visible_message(span_boldwarning("A large form seems to be forcing its way into your reality via the portal [user] opened! RUN!!!"))
		new /mob/living/simple_animal/hostile/jungle/leaper(altar_turf)
	return ..()

/datum/religion_rites/create_sandstone
	name = "Create Sandstone"
	desc = "Create Sandstone for soil production to help create a plant garden."
	ritual_length = 35 SECONDS
	ritual_invocations = list(
		"Bring to us ...",
		"... the stone we need ...",
		"... so we can toil away ...")
	invoke_msg = "and spread many seeds."
	favor_cost = 800

/datum/religion_rites/create_sandstone/invoke_effect(mob/living/user, atom/religious_tool)
	new /obj/item/stack/sheet/mineral/sandstone/fifty(get_turf(religious_tool))
	playsound(get_turf(religious_tool), 'sound/effects/pop_expl.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/grass_generator
	name = "Blessing of Nature"
	desc = "Summon a moveable object that slowly generates grass and fairy-grass around itself while healing any Dionae or Holy people nearby."
	ritual_length = 60 SECONDS
	ritual_invocations = list(
		"Let the plantlife grow ...",
		"... let it grow across the land ...",
		"... far and wide it shall spread ...",
		"... show us true nature ...",
		"... and we shall worship it all ...")
	invoke_msg = "... in our own personal haven."
	favor_cost = 1000

/datum/religion_rites/grass_generator/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/open/T = get_turf(religious_tool)
	if(istype(T))
		new /obj/structure/destructible/religion/nature_pylon(T)
	return ..()

/datum/religion_rites/create_diona
	name = "Nature Conversion"
	desc = "Convert a human-esque individual into a being of nature. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"By the power of nature ...",
		"... We call upon you, in this time of need ...",
		"... to merge us with all that is natural ...")
	invoke_msg = "... May the grass be greener on the other side, show us what it means to be one with nature!!"
	favor_cost = 300

/datum/religion_rites/create_diona/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,span_warning("You're going to convert the one buckled on [movable_reltool]."))
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,span_warning("This rite requires a religious device that individuals can be buckled to."))
			return FALSE
		if(isdiona(user))
			to_chat(user,span_warning("You've already converted yourself. To convert others, they must be buckled to [movable_reltool]."))
			return FALSE
		to_chat(user,span_warning("You're going to convert yourself with this ritual."))
	return ..()

/datum/religion_rites/create_diona/invoke_effect(mob/living/user, atom/religious_tool)
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
	rite_target.set_species(/datum/species/diona)
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE
