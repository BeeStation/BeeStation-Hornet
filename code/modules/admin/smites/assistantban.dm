/datum/smite/assistantban
	name = "Kill Via Assistant"
	var/mob/living/simple_animal/hostile/banassistant/assassin // Track the spawned assistant

/datum/smite/assistantban/effect(client/user, mob/living/target)
	if(!target.client)
		to_chat(user, span_warning("Target must be a player!"))
		return
	. = ..()
	// Find a spawn location just outside view
	var/turf/spawn_turf = find_valid_spawn(target)
	if(!spawn_turf)
		to_chat(user, span_warning("Failed to find valid spawn location!"))
		return
	var/mob/living/simple_animal/hostile/banassistant/H = new(spawn_turf)
	H.smitetarget = target
	H.status_flags = GODMODE
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
	assassin = H

/datum/smite/assistantban/proc/find_valid_spawn(mob/target)
	if(!target || !isturf(target.loc))
		return get_turf(target) // Fallback if invalid target
	var/turf/center = get_turf(target)
	var/list/turf/startlocs = list()
	for(var/turf/open/T in view(getexpandedview(world.view, 2, 2),target))
		startlocs += T
	for(var/turf/open/T in view(world.view,target))
		startlocs -= T
	if(!startlocs.len)
		return get_turf(target)
	for(var/turf/T in shuffle(startlocs))
		// Skip if in direct view
		if(T in view(world.view, target))
			continue
		// Check if valid floor turf with path
		if(isfloorturf(T) && !T.is_blocked_turf())
			if(get_path_to(T, center, max_distance = 30))
				return T
	return get_turf(target) // Final fallback

/datum/smite/assistantban/proc/on_target_death(mob/living/target)
	if(assassin)
		assassin.visible_message(span_boldred("[assassin] dissolves into static, his job done!"))
		QDEL_NULL(assassin)

////////////////////////////////////////////.


/mob/living/simple_animal/hostile/banassistant
	name = "Unknown Assistant"
	desc = "If you're being chased by this guy, you've done something wrong."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "banassist"
	icon_living = "banassist"
	icon_dead = "banassist"
	icon_gib = "banassist"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 1
	speed = 0
	move_to_delay = 2
	stat_attack = DEAD
	robust_searching = 1
	maxHealth = 10000
	health = 10000
	melee_damage = 12
	armour_penetration = 100
	obj_damage = 0
	environment_smash = 0
	attack_verb_continuous = "robusts"
	attack_verb_simple = "robust"
	attack_sound = 'sound/weapons/smash.ogg'
	combat_mode = TRUE
	loot = null
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	rapid_melee = 2
	hardattacks = TRUE
	spacewalk = TRUE
	footstep_type = FOOTSTEP_MOB_SHOE
	vision_range = 1
	aggro_vision_range = 10
	var/mob/living/smitetarget = null
	emote_taunt = list("grins")
	speak = list("Asshole!","Awww, what a shame!","HAH!","Weakling!","I'm gonna beat you into the ground!","Get robusted!")
	speak_chance = 25
	taunt_chance = 55


/mob/living/simple_animal/hostile/banassistant/ListTargets()
	if(smitetarget && !QDELETED(smitetarget))
		return list(smitetarget)
	return list()

/mob/living/simple_animal/hostile/banassistant/Found(atom/A)
	if(A == smitetarget && !QDELETED(smitetarget))
		if(get_dist(src, A) > 10)
			do_teleport(src, get_turf(A))
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/banassistant/CanAttack(mob/the_target)
	if(the_target != smitetarget || QDELETED(smitetarget))
		return FALSE
	if(see_invisible < the_target.invisibility)
		return FALSE
	if(ismob(the_target) && (the_target.status_flags & GODMODE))
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/banassistant/FindTarget(list/possible_targets, HasTargetsList)
	if(!smitetarget || QDELETED(smitetarget))
		LoseTarget()
		return null
	if(get_dist(src, smitetarget) > 10)
		do_teleport(src, get_turf(smitetarget))
	GiveTarget(smitetarget)
	return smitetarget

//////////// Syndicate variant - No godmode

/datum/smite/assistantbansyndie
	name = "Kill Via Syndicate"
	var/mob/living/simple_animal/hostile/banassistant/syndicate/assassin // Track the spawned assistant

/datum/smite/assistantbansyndie/effect(client/user, mob/living/target)
	if(!target.client)
		to_chat(user, span_warning("Target must be a player!"))
		return
	. = ..()
	// Find a spawn location just outside view
	var/turf/spawn_turf = find_valid_spawn(target)
	if(!spawn_turf)
		to_chat(user, span_warning("Failed to find valid spawn location!"))
		return
	var/mob/living/simple_animal/hostile/banassistant/syndicate/H = new(spawn_turf)
	H.smitetarget = target
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
	assassin = H

/datum/smite/assistantbansyndie/proc/find_valid_spawn(mob/target)
	if(!target || !isturf(target.loc))
		return get_turf(target) // Fallback if invalid target
	var/turf/center = get_turf(target)
	var/list/turf/startlocs = list()
	for(var/turf/open/T in view(getexpandedview(world.view, 2, 2),target))
		startlocs += T
	for(var/turf/open/T in view(world.view,target))
		startlocs -= T
	if(!startlocs.len)
		return get_turf(target)
	for(var/turf/T in shuffle(startlocs))
		// Skip if in direct view
		if(T in view(world.view, target))
			continue
		// Check if valid floor turf with path
		if(isfloorturf(T) && !T.is_blocked_turf())
			if(get_path_to(T, center, max_distance = 30))
				return T
	return get_turf(target) // Final fallback

/datum/smite/assistantbansyndie/proc/on_target_death(mob/living/target)
	if(assassin)
		assassin.visible_message(span_boldred("[assassin] dissolves into static, his job done!"))
		QDEL_NULL(assassin)

/mob/living/simple_animal/hostile/banassistant/syndicate
	icon_state = "syndicate_space"
	icon_living = "syndicate_space"
	icon_dead = "syndicate_space"
	icon_gib = "syndicate_space"
	name = "Unknown Syndicate Agent"
	maxHealth = 150
	health = 150
	melee_damage = 15
	armour_penetration = 50
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	speak = list("Give us the nuke disk!","Stop running!","HAH!","Weakling!","I'm gonna beat you into the ground!","You'll never stop us!")

//////////// Security variant - No godmode

/datum/smite/assistantbansec
	name = "Kill Via Security"
	var/mob/living/simple_animal/hostile/banassistant/security/assassin // Track the spawned assistant

/datum/smite/assistantbansec/effect(client/user, mob/living/target)
	if(!target.client)
		to_chat(user, span_warning("Target must be a player!"))
		return
	. = ..()
	// Find a spawn location just outside view
	var/turf/spawn_turf = find_valid_spawn(target)
	if(!spawn_turf)
		to_chat(user, span_warning("Failed to find valid spawn location!"))
		return
	var/mob/living/simple_animal/hostile/banassistant/security/H = new(spawn_turf)
	H.smitetarget = target
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
	assassin = H

/datum/smite/assistantbansec/proc/find_valid_spawn(mob/target)
	if(!target || !isturf(target.loc))
		return get_turf(target) // Fallback if invalid target
	var/turf/center = get_turf(target)
	var/list/turf/startlocs = list()
	for(var/turf/open/T in view(getexpandedview(world.view, 2, 2),target))
		startlocs += T
	for(var/turf/open/T in view(world.view,target))
		startlocs -= T
	if(!startlocs.len)
		return get_turf(target)
	for(var/turf/T in shuffle(startlocs))
		// Skip if in direct view
		if(T in view(world.view, target))
			continue
		// Check if valid floor turf with path
		if(isfloorturf(T) && !T.is_blocked_turf())
			if(get_path_to(T, center, max_distance = 30))
				return T
	return get_turf(target) // Final fallback

/datum/smite/assistantbansec/proc/on_target_death(mob/living/target)
	if(assassin)
		assassin.visible_message(span_boldred("[assassin] dissolves into static, his job done!"))
		QDEL_NULL(assassin)

/mob/living/simple_animal/hostile/banassistant/security
	icon_state = "nanotrasen"
	icon_living = "nanotrasen"
	icon_dead = "nanotrasen"
	icon_gib = "nanotrasen"
	name = "Unknown Security Officer"
	speed = 1
	maxHealth = 100
	health = 100
	melee_damage = 10
	armour_penetration = 25
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	speak = list("Stop right there, criminal scum!","Dead or alive you're coming with me.","You have the right to shut the fuck up.","Prepare for justice!","I am, the LAW!")
