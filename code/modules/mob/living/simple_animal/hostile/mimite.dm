#define MIMITE_COOLDOWN 60
#define MIMITE_VENT_COOLDOWN 100
#define MIMITE_STUCK_THRESHOLD 10

/mob/living/simple_animal/hostile/mimite
	name = "Mimite"
	desc = "A creature of unknown origin, it enjoys hiding in plain sight to ambush its prey"
	icon = 'icons/mob/animal.dmi'
	icon_state = "mimite"
	icon_living = "mimite"
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_ALWAYS
	combat_mode = TRUE
	melee_damage = 10
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	deathmessage = "splatters into a pile of black gunk!"
	del_on_death = TRUE

	speed = 3
	maxHealth = 50
	health = 50
	gender = NEUTER
	mob_biotypes = list(MOB_INORGANIC)
	wander = FALSE

	vision_range = 4
	aggro_vision_range = 4
	armour_penetration = 10
	rapid_melee = 2
	attack_sound = 'sound/effects/meatslap.ogg'
	emote_taunt = list("growls")
	speak_emote = list("chitters")
	taunt_chance = 30

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list(FACTION_MIMIC)
	move_to_delay = 3
	gold_core_spawnable = NO_SPAWN
	hardattacks = TRUE

	discovery_points = 8000

	var/static/list/blacklist_typecache = typecacheof(list(
	/atom/movable/screen,
	/obj/anomaly,
	/obj/eldritch/narsie,
	/obj/effect,
	/obj/machinery,
	/obj/structure,
	/obj/item/radio/intercom,
	/mob/camera,
	/obj/item/storage/secure/safe,
	/mob/living
	))
	var/atom/movable/form = null
	var/morphed = FALSE
	var/mimite_time = 0
	var/mimite_growth = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/replicate = TRUE
	var/venthunt = TRUE
	var/mimite_lastmove = null //Updates/Stores position of the mimite while it's moving
	var/mimite_stuck = 0	//If mimite_lastmove hasn't changed, this will increment until it reaches mimite_stuck_threshold
	var/attemptingventcrawl = FALSE
	var/eventongoing = TRUE
	var/remaining_replications = 4

/mob/living/simple_animal/hostile/mimite/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/point_of_interest)
	GLOB.all_mimites += src
	var/image/I = image(icon = 'icons/mob/hud.dmi', icon_state = "hudcultist", layer = DATA_HUD_PLANE, loc = src)
	I.alpha = 200
	I.appearance_flags = RESET_ALPHA
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/mimites, "hudcultist", I)

/mob/living/simple_animal/hostile/mimite/examine(mob/user)
	if(morphed && replicate && venthunt)
		. = form.examine(user)
		if(get_dist(user,src)<=4)
			. += span_warning("It doesn't look quite right...")
	else
		. = ..()

/mob/living/simple_animal/hostile/mimite/med_hud_set_health()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/mimite/med_hud_set_status()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[STATUS_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/mimite/proc/allowed(atom/movable/A) // make it into property/proc ? not sure if worth it
	return !is_type_in_typecache(A, blacklist_typecache) && (isobj(A) || ismob(A))

/mob/living/simple_animal/hostile/mimite/ShiftClickOn(atom/movable/A)
	if(mimite_time <= world.time && !stat)
		if(A == src)
			restore(TRUE)
			return
		if(allowed(A))
			assume(A)
	else
		to_chat(src, span_warning("Your chameleon skin is still repairing itself!"))

/mob/living/simple_animal/hostile/mimite/proc/assume(atom/movable/target)
	morphed = TRUE
	form = target

	visible_message(span_warning("[src] suddenly twists and changes shape, becoming a copy of [target]!"), \
					span_notice("You twist your body and assume the form of [target]."))
	appearance = target.appearance
	if(length(target.vis_contents))
		add_overlay(target.vis_contents)
	alpha = max(alpha, 150)	//fucking chameleons
	transform = initial(transform)
	pixel_y = base_pixel_y
	pixel_x = base_pixel_x
	density = target.density
	mobchatspan = initial(mobchatspan)

	mimite_time = world.time + MIMITE_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we're an object honest
	vision_range = 1
	aggro_vision_range = 1
	return

/mob/living/simple_animal/hostile/mimite/proc/restore(intentional = FALSE)
	if(!morphed)
		if(intentional)
			to_chat(src, span_warning("You're already in your normal form!"))
		return
	morphed = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	animate_movement = SLIDE_STEPS
	maptext = null
	density = initial(density)

	visible_message(span_warning("[src] suddenly collapses in on itself, turning into a strange shifting black mass!"), \
					span_notice("You reform to your normal body."))
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	vision_range = initial(vision_range)
	aggro_vision_range = initial(aggro_vision_range)
	cut_overlays()

	//Baseline stats
	melee_damage = initial(melee_damage)
	set_varspeed(initial(speed))

	mimite_time = world.time + MIMITE_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we are not an object


/mob/living/simple_animal/hostile/mimite/Aggro() // automated only
	..()
	restore()

/mob/living/simple_animal/hostile/mimite/AIShouldSleep(list/possible_targets)
	. = ..()
	if(.)
		if(!morphed)
			var/list/things = list()
			for(var/atom/A as() in view(src))
				if(allowed(A))
					things += A
			if(LAZYLEN(things) >= 1)
				var/atom/movable/T = pick(things)
				assume(T)
			else
				approachvent()

/mob/living/simple_animal/hostile/mimite/can_track(mob/living/user)
	if(morphed)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/mimite/AttackingTarget()
	if(morphed)
		restore()
	return ..()

//Ambush attack
/mob/living/simple_animal/hostile/mimite/attack_hand(mob/living/carbon/human/M)
	if(morphed)
		M.Knockdown(40)
		M.reagents.add_reagent(/datum/reagent/toxin/morphvenom/mimite, 5)
		to_chat(M, span_userdanger("[src] bites you!"))
		visible_message(span_danger("[src] violently bites [M]!"),\
				span_userdanger("You ambush [M]!"), null, COMBAT_MESSAGE_RANGE)
		restore()
	else
		..()

/mob/living/simple_animal/hostile/mimite/Life()
	. = ..()
	if(isturf(loc) && replicate)
		mimite_growth += rand(1,6)
		if(mimite_growth >= 350 && remaining_replications)
			if(!grow_as)
				grow_as = pick_weight(list(/mob/living/simple_animal/hostile/mimite = 50, /mob/living/simple_animal/hostile/mimite/ranged = 45, /mob/living/simple_animal/hostile/mimite/crate = 5))
			var/mob/living/simple_animal/hostile/mimite/S = new grow_as(src.loc)
			remaining_replications--
			S.remaining_replications = remaining_replications
			playsound(S.loc, 'sound/effects/meatslap.ogg', 60, TRUE)
			mimite_growth = 0
			approachvent()
	if(AIStatus == AI_STATUS_OFF || client)
		return
	if(venthunt && !attemptingventcrawl && mimite_time <= world.time && prob(25))
		approachvent()
	if(attemptingventcrawl && entry_vent)
		SSmove_manager.move_to(src, entry_vent, 1)
		tryventcrawl()
	if(isStuck())
		SSmove_manager.stop_looping(src)

/mob/living/simple_animal/hostile/mimite/proc/approachvent()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(6,src))
		if(!v.welded)
			entry_vent = v
			SSmove_manager.move_to(src, entry_vent, 1)
			break
	tryventcrawl()

/mob/living/simple_animal/hostile/mimite/proc/tryventcrawl()
	attemptingventcrawl = TRUE
	mimite_time = world.time + MIMITE_VENT_COOLDOWN
	if(QDELETED(entry_vent))
		entry_vent = null
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
			attemptingventcrawl = FALSE
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 3)
			var/list/vents = list()
			var/datum/pipenet/entry_vent_parent = entry_vent.parents[1]
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmos_machines)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				attemptingventcrawl = FALSE
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			var/travel_time = round(get_dist(loc, exit_vent.loc) * 2)
			travelling_in_vent = 1
			spawn(travel_time)
				if(!exit_vent || exit_vent.welded)
					forceMove(entry_vent)
					entry_vent = null
					attemptingventcrawl = FALSE
					travelling_in_vent = 0
					return
				else
					visible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
					span_italics("You hear something scampering through the ventilation ducts."))
					forceMove(exit_vent.loc)
					entry_vent = null
					attemptingventcrawl = FALSE
					travelling_in_vent = 0
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)
					SSmove_manager.move_away(src, exit_vent, 4)
	else
		entry_vent = null
		attemptingventcrawl = FALSE
		travelling_in_vent = 0
		return

/mob/living/simple_animal/hostile/mimite/proc/isStuck()
	//Check to see if the mimite is stuck due to things like windows or doors or windowdoors
	if(mimite_lastmove)
		if(mimite_lastmove == src.loc)
			if(MIMITE_STUCK_THRESHOLD >= ++mimite_stuck)
				mimite_stuck = 0
				mimite_lastmove = null
				return 1
		else
			mimite_lastmove = null
	else
		mimite_lastmove = src.loc
	return 0

/mob/living/simple_animal/hostile/mimite/death(gibbed)
	new /obj/effect/decal/cleanable/oil(get_turf(src))
	..()

/mob/living/simple_animal/hostile/mimite/Destroy()
	GLOB.all_mimites -= src
	..()

/mob/living/simple_animal/hostile/mimite/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "crate"
	icon_living = "crate"
	speak_emote = list("clatters")
	vision_range = 0
	aggro_vision_range = 0
	melee_damage = 15
	speed = 4
	move_to_delay = 4
	venthunt = FALSE
	morphed = TRUE

/mob/living/simple_animal/hostile/mimite/crate/AttackingTarget()
	cut_overlays()
	if(prob(50))
		add_overlay("[icon_state]_open")
	else
		add_overlay("[icon_state]_door")
	return ..()

/mob/living/simple_animal/hostile/mimite/crate/LoseTarget()
	..()
	cut_overlays()
	add_overlay("[icon_state]_door")

/mob/living/simple_animal/hostile/mimite/crate/Initialize(mapload)
	..()
	icon_state = pick("crate","weapon_crate","secgear_crate","private_crate")
	icon_living = icon_state
	add_overlay("[icon_state]_door")
	med_hud_set_health()
	med_hud_set_status()

//Ambush attack does extra knockdown as crate mimite
/mob/living/simple_animal/hostile/mimite/crate/attack_hand(mob/living/carbon/human/M)
	morphed = FALSE
	vision_range = 9
	aggro_vision_range = 9
	M.Knockdown(20)
	M.reagents.add_reagent(/datum/reagent/toxin/morphvenom/mimite, 10)
	to_chat(M, span_userdanger("[src] bites you!"))
	visible_message(span_danger("[src] violently bites [M]!"),\
			span_userdanger("You ambush [M]!"), null, COMBAT_MESSAGE_RANGE)
	cut_overlays()
	add_overlay("[icon_state]_open")
	..()

/mob/living/simple_animal/hostile/mimite/crate/assume(atom/movable/target)
	return FALSE

/mob/living/simple_animal/hostile/mimite/ranged
	name = "Ranged mimite"
	desc = "This mimite seems to be bursting with energy, beware of ranged shots!"
	ranged = TRUE
	vision_range = 7
	aggro_vision_range = 7
	speed = 7
	move_to_delay = 7
	rapid = 2
	approaching_target = TRUE
	minimum_distance = 1
	melee_queue_distance = 1
	projectiletype = /obj/projectile/beam/disabler


#undef MIMITE_COOLDOWN
#undef MIMITE_VENT_COOLDOWN
#undef MIMITE_STUCK_THRESHOLD
