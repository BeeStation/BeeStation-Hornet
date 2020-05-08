#define DASH_COOLDOWN 10 SECONDS

/mob/living/simple_animal/hostile/aeon_guardian
	name = "The Aeon"
	desc = "The companion of the one who touched heaven, guarding his master eternally."
	icon = 'icons/mob/aeon.dmi'
	icon_state = "aeon"
	icon_living = "aeon"
	health = INFINITY
	maxHealth = INFINITY
	movement_type = FLYING
	mob_biotypes = list(MOB_INORGANIC, MOB_SPIRIT)
	melee_damage_lower = 10
	melee_damage_upper = 25
	wander = FALSE
	var/mob/living/simple_animal/hostile/megafauna/aeon/master
	var/next_dash = 0
	var/list/mob_dist_tracking = list()

/mob/living/simple_animal/hostile/aeon_guardian/PickTarget(list/Targets)
	if(loc == master)
		return
	var/mob/living/closest_mob
	// Target the closest mob to the master
	for(var/mob/living/L in range(world.view, master))
		if(L.stat == DEAD || !L.ckey || L == master || L == src)
			continue
		if(!closest_mob)
			closest_mob = L
		else
			if(get_dist(master, L) > get_dist(master, closest_mob))
				closest_mob = L
	if(!closest_mob) // No targets, bye bye.
		LoseTarget()
		new /obj/effect/temp_visual/guardian/phase/out(loc)
		forceMove(master)
		return
	return closest_mob

/mob/living/simple_animal/hostile/aeon_guardian/handle_automated_action()
	if(loc == master)
		return FALSE
	. = ..()
	if(.)
		var/mob/living/runner
		for(var/mob/living/L in range(world.view, master))
			if(L.stat == DEAD || !L.ckey || L == master || L == src)
				continue
			var/dist = get_dist(master, L)
			if(dist >= (mob_dist_tracking[L] * 0.8) && (!target || get_dist(master, target) > dist) && (!runner || get_dist(master, runner) > dist))
				runner = L
			mob_dist_tracking[L] = dist
		if(runner)
			GiveTarget(runner)
			if(next_dash >= world.time && prob(80))
				Dash()

/mob/living/simple_animal/hostile/aeon_guardian/proc/Dash()
	if(!target)
		return
	visible_message("<span class='danger'>[src] dashes to intercept [target]!</span>")
	forceMove(get_step(get_turf(target), get_dir(target, master)))
	playsound(src, 'sound/effects/vector_rush.ogg', 100, FALSE)
	face_atom(target)
	AttackingTarget()
	next_dash = world.time + DASH_COOLDOWN

/mob/living/simple_animal/hostile/megafauna/aeon
	name = "The Forgotten One"
	desc = "An ancient adventurer, forever cursed to guard an cursed artifact after grasping for heaven across the Abyss."
	health = 1500
	maxHealth = 1500
	icon_state = "one"
	icon_living = "one"
	icon = 'icons/mob/aeon.dmi'
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	movement_type = GROUND
	speak_emote = list("gasps")
	speed = 3
	loot = list(/obj/item/stand_arrow)
	wander = FALSE
	del_on_death = TRUE
	gps_name = "Lost Signal"
	var/mob/living/simple_animal/hostile/aeon_guardian/guardian

/mob/living/simple_animal/hostile/megafauna/aeon/Initialize(mapload)
	. = ..()
	guardian = new(src)
	guardian.master = src
