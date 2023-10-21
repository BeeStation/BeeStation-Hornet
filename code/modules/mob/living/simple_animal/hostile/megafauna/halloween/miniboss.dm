/mob/living/simple_animal/hostile/megafauna/unshaped
	name = "Unshaped"
	desc = "A monstrous creature protected by blessings of Nar'Sie"
	health = 1200
	maxHealth = 1200
	attacktext = "slashes"
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
	deathmessage = "stops moving"
	deathsound = 'sound/creatures/halloween/Unshaped/NBDeath.ogg'
	wander = FALSE
	var/target_counter
	var/phase = 1
	var/rune_sound
	var/speed_sound
	var/speed_cast
	var/tele_cast
	var/target_sound

/mob/living/simple_animal/hostile/megafauna/unshaped/Initialize()
	. = ..()
	rotate_sound("all")

/mob/living/simple_animal/hostile/megafauna/unshaped/proc/rotate_sound(rotate_type)
	switch(rotate_type + "[phase]")
		if("all1", "all2")
			rotate_sound("attack")
			rotate_sound("rune")
			rotate_sound("speedup")
			rotate_sound("speedcast")
			rotate_sound("telecast")
			rotate_sound("target")
		if("attack1")
			attack_sound = pick('sound/creatures/halloween/Unshaped/NBAttack1.ogg',
								'sound/creatures/halloween/Unshaped/NBAttack2.ogg',
								'sound/creatures/halloween/Unshaped/NBAttack3.ogg')
		if("attack2")
			attack_sound = pick('sound/creatures/halloween/Unshaped/NBP2Attack1.ogg',
								'sound/creatures/halloween/Unshaped/NBP2Attack2.ogg',
								'sound/creatures/halloween/Unshaped/NBP2Attack3.ogg')
		if("target1")
			target_sound = pick('sound/creatures/halloween/Unshaped/NBAlert1.ogg',
								'sound/creatures/halloween/Unshaped/NBAlert2.ogg',
								'sound/creatures/halloween/Unshaped/NBAlert3.ogg',
								'sound/creatures/halloween/Unshaped/NBAlert3.ogg')

		if("target2")
			target_sound = pick('sound/creatures/halloween/Unshaped/NBP2Alert1.ogg',
								'sound/creatures/halloween/Unshaped/NBP2Alert2.ogg',
								'sound/creatures/halloween/Unshaped/NBP2Alert3.ogg')

		if("rune1", "rune2")
			rune_sound = pick('sound/creatures/halloween/Unshaped/NBRune1.ogg',
								'sound/creatures/halloween/Unshaped/NBRune2.ogg')

		if("speedup1", "speedup2")
			speed_sound = pick('sound/creatures/halloween/Unshaped/NBSpeedFX1.ogg',
								'sound/creatures/halloween/Unshaped/NBSpeedFX2.ogg',
								'sound/creatures/halloween/Unshaped/NBSpeedFX3.ogg')

		if("speedcast1")
			speed_cast = pick('sound/creatures/halloween/Unshaped/NBSpeed1.ogg',
								'sound/creatures/halloween/Unshaped/NBSpeed2.ogg',
								'sound/creatures/halloween/Unshaped/NBSpeed3.ogg')

		if("speedcast2")
			speed_cast = pick('sound/creatures/halloween/Unshaped/NBP2Speed1.ogg',
								'sound/creatures/halloween/Unshaped/NBP2Speed2.ogg')

		if("telecast2") //There is no telecast1
			tele_cast = pick('sound/creatures/halloween/Unshaped/NBteleport1.ogg',
								'sound/creatures/halloween/Unshaped/NBteleport2.ogg',
								'sound/creatures/halloween/Unshaped/NBteleport3.ogg')

/mob/living/simple_animal/hostile/megafauna/unshaped/Life(delta_time)
	. = ..()
	if(!.)
		return
	target_counter += delta_time
	if(target)
		target_counter += delta_time
		if(target_counter > 20)
			target_counter = 0
			FindTarget()
			if(phase > 1)
				tele_to_target()

	if(move_to_delay < initial(move_to_delay))
		ranged_cooldown = world.time + (7 - phase) SECONDS
		move_to_delay++

/mob/living/simple_animal/hostile/megafauna/unshaped/attack_basic_mob()
	playsound(src, attack_sound, 135)
	attack_sound = null //we want to override modulation
	..()
	rotate_sound("attack")

/mob/living/simple_animal/hostile/megafauna/unshaped/FindTarget()
	if(phase == 1) //Plays after teleport in phase 2
		playsound(src, target_sound, 135)
		rotate_sound("target")
	return ..()

/mob/living/simple_animal/hostile/megafauna/unshaped/death(gibbed)
	..()
	apply_damage(5000)
	if(phase < 2)
		phase_shift()
		var/mob/living/simple_animal/hostile/megafauna/unshaped/phase_two = new(loc)
		phase_two.phase = 2
		phase_two.icon_state = "miniboss_2"
		phase_two.update_icon()
		phase_two.deathmessage = "falls over and stops moving, the magic dissapating from its corpse"
		phase_two.apply_damage(400)
		phase_two.FindTarget()
		phase_two.OpenFire()
		phase_two.tele_to_target()
		qdel(src)

/mob/living/simple_animal/hostile/megafauna/unshaped/proc/phase_shift()
	sleep(6 SECONDS)
	for(var/mob/living/L in range(src, 30))
		to_chat(L, "<span class='userdanger'>You are held in place by an unseen force!</span>")
		L.Immobilize(30 SECONDS)
		playsound(L, 'sound/creatures/halloween/Unshaped/HeartBeat.ogg', 30)

	sleep(20)
	playsound(src, 'sound/creatures/halloween/Unshaped/HeartBeat.ogg', 40, FALSE, 35)
	var/obj/effect/rune/narsie/rune = new(loc)
	rune.color = COLOR_DARK_RED
	sleep(20)

	playsound(src, 'sound/creatures/halloween/Unshaped/HeartBeat.ogg', 50, FALSE, 40)
	set_light(4, -1)
	sleep(10)
	set_light(6, -2)
	playsound(src, 'sound/creatures/halloween/Unshaped/NBPhase.ogg', 300)
	sleep(9)
	playsound(src, 'sound/creatures/halloween/Unshaped/HeartBeat.ogg', 60, FALSE, 45)
	set_light(8, -2)
	sleep(8)
	set_light(10, -3)
	sleep(7)
	playsound(src, 'sound/creatures/halloween/Unshaped/HeartBeat.ogg', 60, FALSE, 50)
	set_light(12, -3)
	sleep(7)
	set_light(14, -5)
	sleep(7)
	playsound(src, 'sound/creatures/halloween/Unshaped/HeartBeat.ogg', 60, FALSE, 50)
	set_light(16, -6)
	for(var/i = 1, i < 10, i++)
		if(i < 3)
			playsound(src, 'sound/creatures/halloween/Unshaped/HeartBeat.ogg', 60, FALSE, 55)
		sleep(10)
		set_light(16+i*2, -6)

	for(var/mob/living/L in range(12, src))
		to_chat(L, "<span class='userdanger'>Suddenly a blinding flash erupts from the darkness</span>")
		L.flash_act()
	qdel(rune)
	for(var/mob/living/L in range(src, 30))
		L.SetImmobilized(1 SECONDS)

/mob/living/simple_animal/hostile/megafauna/unshaped/AttackingTarget()
	..()
	if(phase > 1)
		FindTarget()
		move_to_delay = 2 //Keep the boost going, but run to the next target.
		if(prob(33))
			maul_victim(target)
	else
		move_to_delay = initial(move_to_delay)

/mob/living/simple_animal/hostile/megafauna/unshaped/proc/tele_to_target()
	ranged_cooldown = world.time + 3 SECONDS
	stop_automated_movement = TRUE
	SSmove_manager.stop_looping(src)

	var/obj/effect/rune/teleport/rune = new(target.loc)
	rune.icon = 'icons/mob/halloween/rune.dmi'
	rune.icon_state = "rune"
	rune.color = COLOR_DARK_RED
	playsound(src, rune_sound, 135)
	rotate_sound("rune")
	say("Totumdedol harf'mir")
	playsound(src, tele_cast, 135)
	sleep(4)

	playsound(rune, 'sound/magic/castsummon.ogg', 50, TRUE)
	sleep(8)

	forceMove(rune.loc)
	qdel(rune)
	stop_automated_movement = FALSE
	Goto(target,move_to_delay,minimum_distance)

	sleep(15)
	rotate_sound("target")
	playsound(src, target_sound, 135)


/mob/living/simple_animal/hostile/megafauna/unshaped/OpenFire()
	ranged_cooldown = world.time + (7 - phase) SECONDS
	stop_automated_movement = TRUE
	SSmove_manager.stop_looping(src)

	var/obj/effect/rune/empower/rune = new(loc)
	rune.icon = 'icons/mob/halloween/rune.dmi'
	rune.icon_state = "rune"
	rune.color = COLOR_DARK_RED
	playsound(src, rune_sound, 135)
	rotate_sound("rune")
	sleep(5)

	say("Nar'Sie gal'fwe")
	playsound(src, speed_cast, 135)
	rotate_sound("speedcast")
	sleep(15)

	playsound(src, speed_sound, 100)
	rotate_sound("speedup")
	qdel(rune)
	move_to_delay = 1
	stop_automated_movement = FALSE
	Goto(target,move_to_delay,minimum_distance)

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
