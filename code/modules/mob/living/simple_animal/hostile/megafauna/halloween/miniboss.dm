/mob/living/simple_animal/hostile/megafauna/unshaped
	name = "Unshaped"
	desc = "A monstrous creature protected by blessings of Nar'Sie"
	health = 1200
	maxHealth = 1200
	attacktext = "slashes"
	attack_sound = 'sound/magic/clockwork/ratvar_attack.ogg'
	icon_state = "miniboss"
	icon_living = "miniboss"
	icon_dead = "miniboss_dead"
	friendly = "stares down"
	icon = 'icons/mob/halloween/unshaped.dmi'
	speak_emote = list("roars")
	armour_penetration = 100
	melee_damage = 18
	speed = 1
	faction = list("hostile")
	weather_immunities = list("snow")
	move_to_delay = 8
	stat_attack = SOFT_CRIT
	ranged = TRUE
	pixel_x = -16
	base_pixel_x = -16
	del_on_death = TRUE
	gps_name = "Nar'sian Signal"
	achievement_type = null
	crusher_achievement_type = null
	score_achievement_type = null
	loot = null
	vision_range = 9
	aggro_vision_range = 18
	del_on_death = FALSE
	deathmessage = null
	deathsound = "stops moving, but unstable magic courses around it!"
	wander = FALSE
	var/target_counter
	var/phase = 1

/mob/living/simple_animal/hostile/megafauna/unshaped/Life(delta_time)
	..()
	target_counter += delta_time
	if(target)
		target_counter += delta_time
		if(target_counter > 20)
			target_counter = 0
			FindTarget()
			if(phase > 1)
				tele_to_target()

	if(move_to_delay < initial(move_to_delay))
		ranged_cooldown = world.time + (health/maxHealth * 6 SECONDS)
		move_to_delay++

/mob/living/simple_animal/hostile/megafauna/unshaped/death(gibbed)
	..()
	apply_damage(5000)
	if(phase < 2)
		phase_shift()
		var/mob/living/simple_animal/hostile/megafauna/unshaped/phase_two = new(loc)
		phase_two.phase = 2
		phase_two.icon_state = "miniboss_2"
		phase_two.update_icon()
		phase_two.deathsound = 'sound/magic/demon_dies.ogg'
		phase_two.deathmessage = "falls over and stops moving, the magic dissapating from its corpse"
		phase_two.apply_damage(400)
		phase_two.FindTarget()
		phase_two.tele_to_target()
		qdel(src)

/mob/living/simple_animal/hostile/megafauna/unshaped/proc/phase_shift()
	playsound(src, 'sound/ambience/antag/bloodcult.ogg', 300)
	for(var/mob/living/L in range(src, 12))
		to_chat(L, "<span class='userdanger'>You are held in place by an unseen force!</span>")
		L.Stun(10 SECONDS)
	sleep(10)
	var/obj/effect/rune/narsie/rune = new(loc)
	rune.color = COLOR_DARK_RED
	playsound(get_turf(target), 'sound/effects/splat.ogg', 100)
	sleep(10)
	set_light(4, -1)
	sleep(10)
	set_light(6, -2)
	sleep(10)
	set_light(8, -2)
	sleep(10)
	set_light(10, -3)
	sleep(10)
	set_light(12, -3)
	sleep(10)
	set_light(14, -5)
	sleep(20)
	for(var/mob/living/L in range(12, src))
		to_chat(L, "<span class='userdanger'>Suddenly a blinding flash erupts from the darkness</span>")
		L.flash_act()
		playsound(get_turf(L), 'sound/effects/magic.ogg', 50)
	qdel(rune)

/mob/living/simple_animal/hostile/megafauna/unshaped/AttackingTarget()
	if(phase > 1)
		FindTarget()
		move_to_delay = 3
		if(prob(33))
			maul_victim(target)
	else
		move_to_delay = initial(move_to_delay)

/mob/living/simple_animal/hostile/megafauna/unshaped/proc/tele_to_target()
	SSmove_manager.stop_looping(src)

	var/obj/effect/rune/teleport/rune = new(loc)
	rune.icon = 'icons/mob/halloween/rune.dmi'
	rune.icon_state = "rune"
	rune.color = COLOR_DARK_RED

	playsound(get_turf(target), 'sound/effects/splat.ogg', 100)
	sleep(5)
	say("Totumdedol harf'mir")
	sleep(10)
	playsound(get_turf(src), 'sound/effects/magic.ogg', 100)
	forceMove(rune.loc)
	qdel(rune)

	SSmove_manager.add_to_loop(src)

/mob/living/simple_animal/hostile/megafauna/unshaped/OpenFire()
	ranged_cooldown = world.time + (health/maxHealth * 6 SECONDS)
	SSmove_manager.stop_looping(src)

	var/obj/effect/rune/empower/rune = new(loc)
	rune.icon = 'icons/mob/halloween/rune.dmi'
	rune.icon_state = "rune"
	rune.color = COLOR_DARK_RED

	playsound(get_turf(src), 'sound/effects/splat.ogg', 100)
	sleep(5)
	say("Nar'Sie gal'fwe")
	sleep(15)
	playsound(get_turf(src), 'sound/effects/magic.ogg', 100)
	qdel(rune)
	move_to_delay = 2

	SSmove_manager.add_to_loop(src)


/mob/living/simple_animal/hostile/megafauna/unshaped/proc/maul_victim(maul_target)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/affecting

		var/list/parts = list()
		for(var/limb in C.bodyparts)
			affecting = limb
			if(affecting.body_part == HEAD || affecting.body_part == CHEST)
				continue
			parts += limb
		if(length(parts))
			affecting = pick(parts)
			affecting.dismember()
