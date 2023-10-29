/mob/living/simple_animal/hostile/megafauna/harbinger
	name = "Harbinger"
	desc = "A monstrous creature protected by blessings of Nar'Sie"
	health = 800
	maxHealth = 800
	attacktext = "eviscerates"
	attack_sound = null //set later
	icon_state = "p1"
	icon_living = "p1"
	icon_dead = "p1"
	friendly = "stares down"
	icon = 'icons/mob/halloween/harbinger.dmi'
	speak_emote = list("roars")
	armour_penetration = 100
	melee_damage = 18
	speed = 10
	faction = list("hostile")
	weather_immunities = list("snow")
	move_to_delay = 1 SECONDS
	ranged = FALSE
	projectiletype = /obj/projectile/latcher_harpoon/harbinger
	pixel_x = -32
	base_pixel_x = -32
	del_on_death = FALSE
	gps_name = "Nar'sian Signal"
	achievement_type = null
	crusher_achievement_type = null
	score_achievement_type = null
	loot = null
	vision_range = 9
	aggro_vision_range = 18
	deathmessage = " "
	deathsound = null
	wander = FALSE
	var/phase = 1 //Current phase of boss determines current behavior
	var/passive_counter //used for passive actions which happen alongside delta_time
	var/target_counter
	var/list/ghost_touched_list = list()
	var/list/tethered_mobs = list()
	var/list/tethers_active = list()
	var/atom/movable/tether_center //hacky solution to tether issues.

	var/onkill_sound
	var/voice_sound
	var/summon_sound
	var/target_sound
	var/laugh_sound

	var/introduction = FALSE

/mob/living/simple_animal/hostile/megafauna/harbinger/Initialize()
	..()
	tether_center = new(loc)
	tether_center.invisibility = INVISIBILITY_ABSTRACT
	rotate_sound("all")

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/rotate_sound(type)
	switch(type + "[phase]")
		if("all1", "all2", "all3")
			rotate_sound("attack")
			rotate_sound("voice")
			rotate_sound("killed")
			rotate_sound("summon")
			rotate_sound("laugh")
			return
		if("attack1", "attack2") //unchanged between phases
			attack_sound = pick('sound/creatures/halloween/Harbinger/Attack/HP1Attack1.ogg',
								'sound/creatures/halloween/Harbinger/Attack/HP1Attack2.ogg')
		if("attack3")
			attack_sound = pick('sound/creatures/halloween/Harbinger/Attack/HP3Attack1.ogg',
								'sound/creatures/halloween/Harbinger/Attack/HP3Attack2.ogg')
		if("voice1")
			voice_sound = pick('sound/creatures/halloween/Harbinger/VoiceLines/HP1Lines1.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP1Lines2.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP1Lines3.ogg')
		if("voice2")
			voice_sound = pick('sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines1.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines2.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines3.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines4.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines5.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines6.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines7.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines8.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP2Lines9.ogg')
		if("voice3")
			voice_sound = pick('sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines1.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines2.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines3.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines4.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines5.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines6.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines7.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines8.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines9.ogg',
								'sound/creatures/halloween/Harbinger/VoiceLines/HP3Lines10.ogg')
		if("killed1")
			onkill_sound = pick('sound/creatures/halloween/Harbinger/OnKill/HP1OnKill1.ogg',
								'sound/creatures/halloween/Harbinger/OnKill/HP1OnKill2.ogg')
		if("killed2")
			onkill_sound = pick('sound/creatures/halloween/Harbinger/OnKill/HP2OnKill1.ogg',
								'sound/creatures/halloween/Harbinger/OnKill/HP2OnKill2.ogg')
		if("killed3")
			onkill_sound = pick('sound/creatures/halloween/Harbinger/OnKill/HP3OnKill1.ogg',
								'sound/creatures/halloween/Harbinger/OnKill/HP3OnKill2.ogg')
		if("summon1")
			summon_sound = pick('sound/creatures/halloween/Harbinger/Summon/HP1Summon1.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP1Summon2.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP1Summon3.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP1Summon4.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP1Summon5.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP1Summon6.ogg')
		if("summon2")
			summon_sound = pick('sound/creatures/halloween/Harbinger/Summon/HP2Summon1.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP2Summon2.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP2Summon3.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP2Summon4.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP2Summon5.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP2Summon6.ogg')
		if("summon3")
			summon_sound = pick('sound/creatures/halloween/Harbinger/Summon/HP3Summon1.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP3Summon2.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP3Summon3.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP3Summon4.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP3Summon5.ogg',
								'sound/creatures/halloween/Harbinger/Summon/HP3Summon6.ogg')
		if("laugh1")
			laugh_sound = pick('sound/creatures/halloween/Harbinger/Laugh/HP1Laugh1.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP1Laugh2.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP1Laugh3.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP1Laugh4.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP1Laugh5.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP1Laugh6.ogg')
		if("laugh2") //Currently unused
			laugh_sound = pick('sound/creatures/halloween/Harbinger/Laugh/HP2Laugh1.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP2Laugh2.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP2Laugh3.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP2Laugh4.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP2Laugh5.ogg')
		if("laugh3")
			laugh_sound = pick('sound/creatures/halloween/Harbinger/Laugh/HP3Laugh1.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP3Laugh2.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP3Laugh3.ogg',
								'sound/creatures/halloween/Harbinger/Laugh/HP3Laugh4.ogg')

/mob/living/simple_animal/hostile/megafauna/harbinger/death(gibbed)
	switch(phase)
		if(1)
			INVOKE_ASYNC(src, PROC_REF(phase_shift))
		if(2)
			INVOKE_ASYNC(src, PROC_REF(phase_shift))
		if(3)
			deathsound = 'sound/creatures/halloween/Harbinger/HDeath1.ogg'
			for(var/mob/living/tethered in tethered_mobs)
				var/datum/beam/B = tethers_active[tethered]
				if(B)
					qdel(B)
				tethers_active -= tethered
			tethered_mobs = list()
			qdel(tether_center)
	..()

/mob/living/simple_animal/hostile/megafauna/harbinger/Goto(target, delay, minimum_distance)
	. = ..()
	if(!introduction)
		take_overall_damage(1000) //cheap hack, but it works

/mob/living/simple_animal/hostile/megafauna/harbinger/Life(delta_time)
	. = ..()
	if(!.)
		return
	tether_center.forceMove(loc) //It just works.
	switch(phase)
		if(1) //Initial phase, summons aetherials and acts like a basic megafauna
			if(isturf(loc))
				var/turf/T = loc
				if(T.get_lumcount() >= 0.5)
					passive_counter += delta_time
					if(passive_counter >= 20 && target)
						new /mob/living/simple_animal/hostile/aetherial(target.loc)
						passive_counter = 0
						rotate_sound("summon")
						playsound(src, summon_sound, 135)
		if(2) //Second phase moves slower and tethers players, requiring coordination to overcome. Will now attack even those who are not the current target.
			passive_counter += delta_time
			if(passive_counter >= 30 && target)
				summon_carp(prob(50)) //50% chance of summoning two carp
				passive_counter = 0
		if(3) //Final phase sees the speed increase, and more increase over time.
			passive_counter += delta_time
			playsound(src, 'sound/creatures/halloween/Unshaped/HeartBeat.ogg', clamp(40 - (health/maxHealth * 100), 10, 30))
			if(passive_counter >= 40)
				new /obj/structure/abyssal_rift(loc)
				passive_counter = 0
				rotate_sound("summon")
				playsound(src, summon_sound, 135)
			apply_damage(length(ghost_touched_list))
			if(prob(length(ghost_touched_list)))
				ghost_touched_list -= pick(ghost_touched_list)
	if(target)
		target_counter += delta_time
		if(target_counter > 20)
			var/old_target = target
			FindTarget()
			if(phase == 2 && old_target != target && length(tethered_mobs) < 3) //Only tether if target actually changes, or else the fight is just over due to stunlock
				Shoot(old_target)

	if(length(tethered_mobs))
		for(var/mob/living/L in tethered_mobs)
			if(L.pulledby)
				release_target(L)
			else if(L.loc == loc && L != target)
				maul_target(L)
			else
				step(L,get_dir(L,src)) //Reeeeel them in
				L.Paralyze(6 SECONDS) //Reset their paralysis

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/phase_shift()
	stop_automated_movement = TRUE
	SSmove_manager.stop_looping(src)

	if(!introduction)
		introduction = TRUE
		playsound(src, 'sound/creatures/halloween/Harbinger/HP1Transition1.ogg', 200)
		sleep(15 SECONDS)
		revive(TRUE) //No damage dealt during introduction will count for anything.
		icon_dead = "p2"
		ranged = TRUE
	else
		phase++
		switch(phase)
			if(2)
			//	revive(TRUE) //Fully heal now, and again a bit later.
				playsound(src, 'sound/creatures/halloween/Harbinger/HP2Transition2.ogg', 200)
				var/obj/effect/rune/narsie/rune = new(loc)
				rune.color = COLOR_DARK_RED
				icon_state = "p2"
				icon_living = "p2"
				rotate_sound("all")
				update_icon()
				passive_counter = 0
				sleep(10 SECONDS)
				revive(TRUE)
				icon_dead = "p3"
				qdel(rune)

			if(3)
			//	revive(TRUE) //Fully heal now, and again a bit later
				playsound(src, 'sound/creatures/halloween/Harbinger/HP3Transition2.ogg', 200)
				var/obj/effect/rune/narsie/rune = new(loc)
				rune.color = COLOR_DARK_RED
				icon_state = "p3"
				icon_living = "p3"
				rotate_sound("all")
				update_icon()
				passive_counter = 0
				//break tethers for phase 3, it's too intense for anyone still living to be stunned
				for(var/mob/living/tethered in tethered_mobs)
					release_target(tethered)
					var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(tethered, src)))
					tethered.throw_at(throwtarget, 6, 6)
				sleep(10 SECONDS)
				revive(TRUE)
				icon_dead = "dead"
				qdel(rune)
				health = maxHealth
				set_observer_default_invisibility(0)
				notify_ghosts("Orbit the harbinger to weaken him, or orbit your allies to heal them!", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Orbit the Harbinger")

	Goto(target,move_to_delay,minimum_distance)

/mob/living/simple_animal/hostile/megafauna/harbinger/AttackingTarget()
	..()
	maul_target(target)

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/maul_target(maul_target)
	if(iscarbon(maul_target))
		var/mob/living/carbon/C = maul_target
		var/obj/item/bodypart/affecting
		rotate_sound("attack")
		playsound(src, attack_sound, 135)
		attack_sound = null //we want to override modulation
		if(phase == 3)
			for(var/limb in C.bodyparts)
				affecting = limb
				if(affecting.body_part == HEAD)
					affecting.dismember()
					sleep(1 SECONDS)
					rotate_sound("killed")
					playsound(src, onkill_sound, 135)
					break
		else
			var/list/parts = list()
			for(var/limb in C.bodyparts)
				affecting = limb //we recycle this later, don't worry
				if(affecting.body_part == HEAD || affecting.body_part == CHEST)
					continue
				parts += limb
			if(length(parts))
				affecting = pick(parts)
				affecting.dismember()
			else
				release_target(maul_target)
				devour(maul_target)
				sleep(1 SECONDS)
				rotate_sound("killed")
				playsound(src, onkill_sound, 135)

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/release_target(release_target)
	for(var/mob/living/L in tethered_mobs)
		if(L == release_target)
			tethered_mobs -= L
			var/datum/beam/B = tethers_active[L]
			if(B)
				qdel(B)
			tethers_active -= L
			L.SetParalyzed(1 SECONDS)


/mob/living/simple_animal/hostile/megafauna/harbinger/devour(mob/living/L)
	if(!L)
		return FALSE
	visible_message(
		"<span class='danger'>[src] consumes [L]!</span>",
		"<span class='userdanger'>You consume [L]!</span>")
	for(var/obj/item/W in L)
		if(!L.dropItemToGround(W))
			qdel(W)
	L.gib()

// SPECIAL ATTACK LOGIC

/mob/living/simple_animal/hostile/megafauna/harbinger/OpenFire()
	ranged_cooldown = world.time + (9 - phase) SECONDS
	move_to_delay = initial(move_to_delay)

	switch(phase)
		if(1)
			playsound(src, 'sound/creatures/halloween/Harbinger/HShotReady.ogg', 200, FALSE, 2)
			sleep(1 SECONDS)
			switch(random_attack_num)
				if(1)
					voice()
				if(2)
					shotgun(4)
				if(3)
					charge_at_target()
		if(2)
			playsound(src, 'sound/creatures/halloween/Harbinger/HShotReady.ogg', 200, FALSE, 2)
			sleep(1 SECONDS)
			move_to_delay = 2 SECONDS
			switch(random_attack_num)
				if(1)
					voice()
				if(2)
					shotgun(5)
				if(3)
					burst(4) //Aimed at non-target

		if(3)
			switch(health / maxHealth)
				if(0.1 to 0.15)
					move_to_delay = 6
				if(0.15 to 0.2)
					move_to_delay = 7
				if(0.2 to 0.25)
					move_to_delay = 8
				if(0.25 to 0.3)
					move_to_delay = 9
			switch(random_attack_num)
				if(1)
					voice()
					sleep(1 SECONDS)
					burst(6, TRUE) //also calls shotgun at the end
				if(2)
					voice()
					sleep(1 SECONDS)
					blastwave(TRUE) //two waves of projectiles
				if(3)
					voice()
					sleep(1 SECONDS)
					charge_at_target(TRUE) //two charges
	random_attack_num = pick(1, 2, 3)

// CHARGE ATTACK STOLEN SHAMELESSLY FROM LEGIONNAIRE, NEEDS POLISH IF TIME AVAILABLE

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/charge_at_target(extra)
	var/dir_to_target = get_dir(get_turf(src), get_turf(target))
	var/turf/T = get_step(get_turf(src), dir_to_target)
	for(var/i in 1 to 8)
		new /obj/effect/temp_visual/dragon_swoop/legionnaire(T)
		T = get_step(T, dir_to_target)
	rotate_sound("laugh")
	playsound(src, laugh_sound, 200, FALSE, 2)
	visible_message("<span class='boldwarning'>[src] prepares to charge!</span>")
	sleep(10)
	for(var/i in 1 to 8)
		T = get_step(get_turf(src), dir_to_target)
		if(T.density)
			break
		for(var/obj/O in T)
			if(O.density)
				return
		forceMove(T)
		var/list/hit_things = list()
		var/throwtarget = get_edge_target_turf(src, dir_to_target)
		for(var/mob/living/L in T.contents - hit_things - src)
			hit_things += L
			visible_message("<span class='boldwarning'>[src] rams [L] with great force!</span>")
			to_chat(L, "<span class='userdanger'>[src] rams you with great force!</span>")
			L.safe_throw_at(throwtarget, 10, 1, src)
			L.Paralyze(20)
			L.adjustBruteLoss(10)
		sleep(2)
	if(extra)
		charge_at_target()

// VOICE OF GOD, BUT THE GOD IS NAR'SIEvoice_of_narsie

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/voice_of_narsie(text, word)
	switch(word + "[phase]")
		if("BLOOD1")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP1Blood.ogg', 200)
		if("BLOOD2")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP2Blood.ogg', 200)
		if("BLOOD3")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP3Blood.ogg', 200)

		if("TRUTH1")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP1Truth.ogg', 200)
		if("TRUTH2")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP2Truth.ogg', 200)
		if("TRUTH3")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP3Truth.ogg', 200)

		if("NEAR1")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP1Near.ogg', 200)
		if("NEAR2")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP2Near.ogg', 200)
		if("NEAR3")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP3Near.ogg', 200)

		if("HITHER1")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP1Hither.ogg', 200)
		if("HITHER2")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP2Hither.ogg', 200)
		if("HITHER3")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP3Hither.ogg', 200)

		if("WORMS1")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP1Worms.ogg', 200)
		if("WORMS2")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP2Worms.ogg', 200)
		if("WORMS3")
			playsound(src, 'sound/creatures/halloween/Harbinger/VoiceOfGod/HP3Worms.ogg', 200)

		else
			rotate_sound("voice")
			playsound(src, voice_sound, 200)
			return

	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, "#C80000", 1)
			shake_camera(M, 4, 3)
	say("[text + word]!")
	visible_message("<span class='colossus'>\"<b>[word]!</b>\"</span>")

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/voice()
	var/list/mob/living/listeners = list()
	for(var/mob/living/L in hearers(8, get_turf(src)))
		if(L.can_hear() && L.stat != DEAD)
			if(L == src)
				continue
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(istype(H.ears, /obj/item/clothing/ears/earmuffs) && prob(50))
					continue //50% chance to block the command with earmuffs, but I doubt anyone will have those
			listeners += L

	switch(rand(1,6+phase)) //1 in 7 duds on phase one, 1 in 8 on phase two, 1 in 9 on phase three when the voice is going to be constantly spammed
		if(1)
			voice_of_narsie(pick("Crawl as ", "Fall like "), "WORMS")
			for(var/V in listeners)
				var/mob/living/L = V
				var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
				L.throw_at(throwtarget, 3, 1)
				L.Knockdown(2 SECONDS)

		if(2)
			voice_of_narsie(pick("Your end draws ", "The end is ", "Nar'sie is "), "NEAR")
			for(var/V in listeners)
				var/mob/living/L = V
				L.throw_at(get_step_towards(src, L), 1, 1)

		if(3)
			voice_of_narsie(pick("Offer your ", "relinquish your "), "BLOOD")
			if(isliving(target))
				var/mob/living/L = target
				L.apply_damage(30, forced = TRUE)

		if(4)
			voice_of_narsie(pick("See the ", "Your mind cannot handle the ", "Behold the "), "TRUTH")
			for(var/mob/living/carbon/C in listeners)
				new /datum/hallucination/delusion(C, TRUE, null, 150, 0 )

		if(5)
			voice_of_narsie(pick("Cast your weapons ", "Lay your resolve "), "HITHER")
			for(var/mob/living/carbon/C in listeners)
				C.throw_mode_on()

		else
			voice_of_narsie()

// CORE PROJECTILE USED FOR ALL PROJECTILE ATTACKS

/obj/projectile/harbinger
	name ="chaos bolt"
	icon_state= "bloodfire"
	damage = 5
	armour_penetration = 40
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/projectile/harbinger/Initialize()
	..()
	hitsound = pick('sound/creatures/halloween/Harbinger/HShotHit1.ogg',
					'sound/creatures/halloween/Harbinger/HShotHit2.ogg')


/obj/projectile/harbinger/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/L = target
		L.Paralyze(2.5 SECONDS)
		var/atom/throw_target = get_edge_target_turf(L, get_dir(src, get_step_away(L, firer)))
		L.safe_throw_at(throw_target, 1, 1)
	return ..()

// PROJECTILE PROCS USED TO FIRE ALL PROJECTILES

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/shoot_projectile(turf/marker, set_angle)
	if(!isnum_safe(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/projectile/P = new /obj/projectile/harbinger(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/aim_projectiles(set_angle)
	if(isnum_safe(set_angle))
		return set_angle

	var/turf/target_turf = get_turf(target)
	newtonian_move(get_dir(target_turf, src))
	var/angle_to_target = get_angle(src, target_turf)
	return angle_to_target

//ALL OF THE ACTUAL PROJECTILE ATTACKS

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/shotgun(pellets, extra, set_angle)
	playsound(src, 'sound/creatures/halloween/Harbinger/HShot1.ogg', 200, FALSE, 2)
	var/turf/target_turf = get_turf(target)
	var/list/shotgun_angles = list()
	for(var/i = 1, i < pellets, i++)
		shotgun_angles += rand(-15, 15)
	for(var/i = 1, i < length(shotgun_angles), i++)
		shoot_projectile(target_turf, aim_projectiles(set_angle) + shotgun_angles[i])

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/burst(pellets, extra, set_angle)
	var/old_target = target
	FindTarget()

	playsound(src, 'sound/creatures/halloween/Harbinger/HShot2.ogg', 200, FALSE, 2)
	var/turf/target_turf = get_turf(target)
	var/list/burst_angles = list()
	for(var/i = 1, i < pellets, i++)
		burst_angles += rand(-6, 6)
	for(var/i = 1, i < length(burst_angles), i++)
		sleep(4 - phase) //very rapid on final phase, not so much on second. This attack isn't used on first phase.
		shoot_projectile(target_turf, aim_projectiles(set_angle) + burst_angles[i])
	if(extra)
		sleep(5)
		shotgun(6)
	GiveTarget(old_target)

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/blastwave(extra)
	var/turf/U = get_turf(src)
	playsound(src, 'sound/creatures/halloween/Harbinger/HShot1.ogg', 200, FALSE, 2)
	for(var/T in RANGE_TURFS(10, U) - U)
		if(prob(5))
			shoot_projectile(T)
	if(extra)
		sleep(10)
		blastwave(FALSE)


// TETHER PROC UTILIZED IN PHASE TWO

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/bone_tether(atom/target)

	if(length(tethered_mobs) > 2)
		return //I doubt this can get to three, but just in case here's a failsafe
	if(!isliving(target))
		return //Also shouldn't happen but a good failsafe regardless.
	for(var/mob/living/L in tethered_mobs)
		if(L == target)
			return //failsafe again - if someone is tethered and also the current boss target, they are likely dead already.

	var/mob/living/L = target
	tethered_mobs += L
	L.Paralyze(6 SECONDS)
	to_chat(L, "<span class='userdanger'>\The [src] has impaled you and is reeling you in!</span>")
	tethers_active[L] = tether_center.Beam(L, "latcher", time=INFINITY, maxdistance=15, beam_type=/obj/effect/ebeam)

// CARP SUMMONING UTILIZED IN PHASE TWO

/mob/living/simple_animal/hostile/megafauna/harbinger/proc/summon_carp(extra)
	//Summons a weaker, but faster carp without the stun ability
	var/mob/living/simple_animal/hostile/ambush/summoned = new(loc)
	rotate_sound("summon")
	playsound(src, summon_sound, 135)
	summoned.name = "Abyssal Phantom" //This will revert if it exits combat
	summoned.alpha = 255
	summoned.move_to_delay = 6
	summoned.health = 35
	summoned.melee_damage = 10
	summoned.GiveTarget(target)
	FindTarget()
	if(extra)
		summon_carp()


// ABYSSAL RIFT, SUMMONED IN PHASE THREE

/obj/structure/abyssal_rift
	name = "abyssal rift"
	desc = "That can't be good..."
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 0)
	max_integrity = 200
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift_carpspawn"
	color = "red"
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_range = 12
	anchored = TRUE
	density = FALSE
	plane = MASSIVE_OBJ_PLANE
	var/current_mob_timer = 0
	var/notified_ghosts

/obj/structure/abyssal_rift/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/abyssal_rift/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/magic/lightningshock.ogg', 50, TRUE)

/obj/structure/abyssal_rift/process(delta_time)
	current_mob_timer += delta_time
	if(current_mob_timer >= 30 && !notified_ghosts)
		notify_ghosts("The abyssal rift is now active!", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Abyssal Rift Available")
		notified_ghosts = TRUE

/obj/structure/abyssal_rift/attack_ghost(mob/user)
	. = ..()
	summon_abyssal(user)

/obj/structure/abyssal_rift/proc/summon_abyssal(mob/user)
	if(current_mob_timer < 20)
		to_chat(user, "<span class='warning'>The rift has not stabilized yet!</span>")
		return FALSE
	var/help_baddie = alert("Become an abyssal and help the harbinger?", "Help the harbinger?", "Yes", "No")
	if(help_baddie == "No" || !src || QDELETED(src) || QDELETED(user))
		return FALSE

	var/mob/living/simple_animal/hostile/ambush/new_abyssal = new(loc)
	new_abyssal.Aggro()
	new_abyssal.key = user.key
	new_abyssal.melee_damage = 18
	to_chat(new_abyssal, "<span class='boldwarning'>You are thralled to the Harbinger and must help assist in the elimination of its enemies!</span>")
	qdel(src)


