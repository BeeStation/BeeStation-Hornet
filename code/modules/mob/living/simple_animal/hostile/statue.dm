// A mob which only moves when it isn't being watched by living beings.

/mob/living/simple_animal/hostile/statue
	name = "statue" // matches the name of the statue with the flesh-to-stone spell
	desc = "An incredibly lifelike marble carving. Its eyes seem to follow you.." // same as an ordinary statue with the added "eye following you" description
	icon = 'icons/obj/statue.dmi'
	icon_state = "human_male"
	icon_living = "human_male"
	icon_dead = "human_male"
	gender = NEUTER
	combat_mode = TRUE
	mob_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)

	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"

	speed = -1
	maxHealth = 50000
	health = 50000
	healable = 0

	obj_damage = 100
	melee_damage = 70
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list(FACTION_STATUE)
	move_to_delay = 0 // Very fast

	animate_movement = NO_STEPS // Do not animate movement, you jump around as you're a scary statue.
	hud_possible = list(ANTAG_HUD)

	see_in_dark = 13
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	vision_range = 12
	aggro_vision_range = 12

	search_objects = 1 // So that it can see through walls

	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	hardattacks = TRUE

	var/cannot_be_seen = 1
	var/mob/living/creator = null

	discovery_points = 10000

// No movement while seen code.

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/hostile/statue)

/mob/living/simple_animal/hostile/statue/Initialize(mapload, var/mob/living/creator)
	. = ..()
	// Give spells
	var/datum/action/spell/aoe/flicker_lights/flicker = new(src)
	flicker.Grant(src)
	var/datum/action/spell/aoe/blindness/blind = new(src)
	blind.Grant(src)
	var/datum/action/spell/night_vision/night_vision = new(src)
	night_vision.Grant(src)

	// Set creator
	if(creator)
		src.creator = creator

/mob/living/simple_animal/hostile/statue/med_hud_set_health()
	return //we're a statue we're invincible

/mob/living/simple_animal/hostile/statue/med_hud_set_status()
	return //we're a statue we're invincible

/mob/living/simple_animal/hostile/statue/Move(turf/NewLoc)
	if(can_be_seen(NewLoc))
		if(client)
			to_chat(src, span_warning("You cannot move, there are eyes on you!"))
		return 0
	return ..()

/mob/living/simple_animal/hostile/statue/Life()
	..()
	if(!client && target) // If we have a target and we're AI controlled
		var/mob/watching = can_be_seen()
		// If they're not our target
		if(watching && watching != target)
			// This one is closer.
			if(get_dist(watching, src) > get_dist(target, src))
				LoseTarget()
				GiveTarget(watching)

/mob/living/simple_animal/hostile/statue/AttackingTarget()
	if(can_be_seen(get_turf(loc)))
		if(client)
			to_chat(src, span_warning("You cannot attack, there are eyes on you!"))
		return FALSE
	else
		return ..()

/mob/living/simple_animal/hostile/statue/DestroyPathToTarget()
	if(!can_be_seen(get_turf(loc)))
		..()

/mob/living/simple_animal/hostile/statue/face_atom()
	if(!can_be_seen(get_turf(loc)))
		..()

/mob/living/simple_animal/hostile/statue/proc/can_be_seen(turf/destination)
	if(!cannot_be_seen)
		return null
	// Check for darkness
	var/turf/T = get_turf(loc)
	if(T && destination && T.lighting_object)
		if(T.get_lumcount()<0.1 && destination.get_lumcount()<0.1) // No one can see us in the darkness, right?
			return null
		if(T == destination)
			destination = null

	// We aren't in darkness, loop for viewers.
	var/list/check_list = list(src)
	if(destination)
		check_list += destination

	// This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/M in viewers(getexpandedview(world.view, 1, 1), check))
			if(M != src && M.client && CanAttack(M) && !M.has_unlimited_silicon_privilege && !M.is_blind())
				return M
		for(var/obj/vehicle/sealed/mecha/M in view(getexpandedview(world.view, 1, 1), check)) //assuming if you can see them they can see you
			for(var/O in M.occupants)
				var/mob/mechamob = O
				if(mechamob?.client && !mechamob.is_blind())
					return mechamob
	return null

// Cannot talk

/mob/living/simple_animal/hostile/statue/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	return 0

// Turn to dust when gibbed

/mob/living/simple_animal/hostile/statue/gib()
	dust()


// Stop attacking clientless mobs

/mob/living/simple_animal/hostile/statue/CanAttack(atom/the_target)
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(!L.client && !L.ckey)
			return 0
	return ..()

// Don't attack your creator if there is one

/mob/living/simple_animal/hostile/statue/ListTargets()
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/netherworld/statue/sentience_act()
	faction -= "neutral"

// Statue powers

// Flicker lights
/datum/action/spell/aoe/flicker_lights
	name = "Flicker Lights"
	desc = "You will trigger a large amount of lights around you to flicker."

	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	aoe_radius = 14

/datum/action/spell/aoe/flicker_lights/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/obj/machinery/light/nearby_light in range(aoe_radius, center))
		if(!nearby_light.on)
			continue

		things += nearby_light

	return things

/datum/action/spell/aoe/flicker_lights/cast_on_thing_in_aoe(obj/machinery/light/victim, atom/caster)
	victim.flicker()

//Blind AOE
/datum/action/spell/aoe/blindness
	name = "Blindness"
	desc = "Your prey will be momentarily blind for you to advance on them."

	cooldown_time = 1 MINUTES
	spell_requirements = NONE
	aoe_radius = 14

/datum/action/spell/aoe/blindness/on_cast(mob/user, atom/target)
	user.visible_message(span_danger("[user] glares their eyes."))
	return ..()

/datum/action/spell/aoe/blindness/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/nearby_mob in range(aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue

		things += nearby_mob

	return things

/datum/action/spell/aoe/blindness/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	victim.set_blindness(4)
