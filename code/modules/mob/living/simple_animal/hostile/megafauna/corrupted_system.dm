/mob/living/simple_animal/hostile/megafauna/corrupted_system
	name = "Corrupted System"
	desc = "Once an experimental mecha carrying an advanced mining AI, now it's out for blood."
	health = 2500
	maxHealth = 2500
	movement_type = GROUND
	attacktext = "drills"
	attack_sound = 'sound/weapons/drill.ogg'
	icon = 'icons/mob/lavaland/rogue.dmi'
	icon_state = "rogue"
	icon_living = "rogue"
	speak_emote = list("screeches")
	mob_biotypes = MOB_ROBOTIC
	gps_name = "Corrupted Signal"
	melee_damage = 30
	speed = 2
	move_to_delay = 10
	ranged_cooldown_time = 80
	ranged = 1
	del_on_death = 1
	crusher_loot = list(/obj/structure/closet/crate/necropolis/corrupted_system/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/corrupted_system)
	deathmessage = "sparkles and emits corrupted screams in agony, falling on the ground."
	anger_modifier = 0
	mob_biotypes = MOB_ROBOTIC
	var/special = FALSE
	wander = FALSE
	faction = list("mining", "boss")
	weather_immunities = list("lava","ash")
	blood_volume = 0
	var/min_sparks = 1
	var/max_sparks = 4

/obj/item/projectile/plasma/rogue
	dismemberment = 0
	damage = 25
	range = 9
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	color = "#0091ff"

/mob/living/simple_animal/hostile/megafauna/corrupted_system/devour(mob/living/L)
	if(!L)
		return
	visible_message(
		"<span class='danger'>[src] drills [L]!</span>",
		"<span class='userdanger'>You drill the [L], activating restoration procedures!</span>")
	if(!is_station_level(z) || client)
		adjustBruteLoss(-L.maxHealth/2)
	L.gib()
	..()

/mob/living/simple_animal/hostile/megafauna/corrupted_system/adjustHealth(amount, updating_health, forced)
	. = ..()
	if(.)
		anger_modifier = round(clamp(((maxHealth - health) / 42),0,60))
		move_to_delay = clamp(round((src.health/src.maxHealth) * 10), 2.5, 8)
		wander = FALSE
		do_sparks(rand(min_sparks,max_sparks), FALSE, src)

/mob/living/simple_animal/hostile/megafauna/corrupted_system/OpenFire(target)
	if(special)
		return FALSE
	ranged_cooldown = world.time + max((ranged_cooldown_time - anger_modifier), 30)
	switch(anger_modifier)
		if(0 to 25)
			if(prob(50))
				INVOKE_ASYNC(src, .proc/plasmashot, target)
				if(prob(80))
					sleep(6)
					INVOKE_ASYNC(src, .proc/plasmashot, target)
					if(prob(50))
						sleep(6)
						INVOKE_ASYNC(src, .proc/plasmashot, target)
			else
				animate(src, color = "#0091ff", time = 3)
				sleep(4)
				INVOKE_ASYNC(src, .proc/shockwave, src.dir, 7, 2.5)
				animate(src, color = initial(color), time = 3)
		if(25 to 50)
			if(prob(60))
				special = TRUE
				INVOKE_ASYNC(src, .proc/plasmaburst, target, FALSE)
				sleep(6)
				INVOKE_ASYNC(src, .proc/plasmaburst, target, TRUE)
				sleep(3)
				if(prob(50))
					sleep(6)
					INVOKE_ASYNC(src, .proc/plasmashot, target, FALSE)
					if(prob(50))
						sleep(6)
						INVOKE_ASYNC(src, .proc/plasmashot, target, FALSE)
				special = FALSE
			else
				special = TRUE
				animate(src, color = "#0091ff", time = 3)
				sleep(4)
				INVOKE_ASYNC(src, .proc/shockwave, WEST, 10, TRUE)
				INVOKE_ASYNC(src, .proc/shockwave, EAST, 10, TRUE)
				sleep(7)
				INVOKE_ASYNC(src, .proc/shockwave, NORTH, 10, TRUE)
				INVOKE_ASYNC(src, .proc/shockwave, SOUTH, 10, TRUE)
				animate(src, color = initial(color), time = 5)
				special = FALSE
		if(50 to INFINITY)
			if(prob(75))
				if(prob(60))
					INVOKE_ASYNC(src, .proc/plasmaburst, target)
					special = TRUE
					animate(src, color = "#0091ff", time = 3)
					sleep(5)
					INVOKE_ASYNC(src, .proc/shockwave, src.dir, 15)
					if(prob(60))
						sleep(5)
						INVOKE_ASYNC(src, .proc/plasmaburst, target)
						sleep(5)
						INVOKE_ASYNC(src, .proc/plasmaburst, target)
						if(prob(50))
							sleep(5)
							INVOKE_ASYNC(src, .proc/plasmaburst, target)
					animate(src, color = initial(color), time = 3)
					special = FALSE
				else
					var/turf/up = locate(x, y + 10, z)
					var/turf/down = locate(x, y - 10, z)
					var/turf/left = locate(x - 10, y, z)
					var/turf/right = locate(x + 10, y, z)
					animate(src, color = "#0091ff", time = 3)
					special = TRUE
					sleep(3)
					INVOKE_ASYNC(src, .proc/plasmaburst, left, TRUE)
					INVOKE_ASYNC(src, .proc/plasmaburst, right, FALSE)
					sleep(3)
					INVOKE_ASYNC(src, .proc/plasmashot, up, FALSE)
					INVOKE_ASYNC(src, .proc/plasmashot, down, FALSE)
					sleep(10)
					animate(src, color = initial(color), time = 3)
					special = FALSE
					if(prob(35))
						animate(src, color = "#0091ff", time = 3)
						sleep(3)
						special = TRUE
						for(var/dire in GLOB.cardinals)
							INVOKE_ASYNC(src, .proc/shockwave, dire, 7, TRUE, 3)
							sleep(6)
						animate(src, color = initial(color), time = 3)
						special = FALSE
			else
				special = TRUE
				INVOKE_ASYNC(src, .proc/ultishockwave, 7, 5)
				sleep(10)
				special = FALSE

/mob/living/simple_animal/hostile/megafauna/corrupted_system/Move()
	. = ..()
	if(special)
		return FALSE
	playsound(src.loc, 'sound/mecha/mechmove01.ogg', 200, 1, 2, 1)

/mob/living/simple_animal/hostile/megafauna/corrupted_system/Bump(atom/A)
	. = ..()
	if(ismineralturf(A))
		var/turf/closed/mineral/M = A
		new /obj/effect/temp_visual/kinetic_blast(M)
		M.gets_drilled(src)

/mob/living/simple_animal/hostile/megafauna/corrupted_system/proc/plasmashot(atom/target)
	var/path = get_dist(src, target)
	if(path > 2)
		if(!target)
			return
		visible_message("<span class='boldwarning'>[src] raises it's plasma lance!</span>")
		sleep(3)
		var/turf/startloc = get_turf(src)
		var/obj/item/projectile/P = new /obj/item/projectile/plasma/rogue(startloc)
		playsound(src, 'sound/weapons/laser.ogg', 100, TRUE)
		P.preparePixelProjectile(target, startloc)
		P.firer = src
		P.original = target
		var/set_angle = Get_Angle(src, target)
		P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/corrupted_system/proc/plasmaburst(atom/target)
	var/list/theline = get_dist(src, target)
	if(theline > 2)
		if(!target)
			return
		visible_message("<span class='boldwarning'>[src] raises it's plasma lance!</span>")
		var/ogangle = Get_Angle(src, target)
		sleep(7)
		var/turf/startloc = get_turf(src)
		var/obj/item/projectile/P = new /obj/item/projectile/plasma/rogue(startloc)
		var/turf/otherangle = (ogangle + 45)
		var/turf/otherangle2 = (ogangle - 45)
		playsound(src, 'sound/weapons/laser.ogg', 100, TRUE)
		P.preparePixelProjectile(target, startloc)
		P.firer = src
		P.original = target
		P.fire(ogangle)
		var/obj/item/projectile/X = new /obj/item/projectile/plasma/rogue(startloc)
		playsound(src, 'sound/weapons/laser.ogg', 100, TRUE)
		X.preparePixelProjectile(target, startloc)
		X.firer = src
		X.original = target
		X.fire(otherangle)
		var/obj/item/projectile/Y = new /obj/item/projectile/plasma/rogue(startloc)
		playsound(src, 'sound/weapons/laser.ogg', 100, TRUE)
		Y.preparePixelProjectile(target, startloc)
		Y.firer = src
		Y.original = target
		Y.fire(otherangle2)

/mob/living/simple_animal/hostile/megafauna/corrupted_system/proc/knockdown(range = 2)
	visible_message("<span class='boldwarning'>[src] smashes into the ground!</span>")
	var/list/hit_things = list()
	sleep(7)
	for(var/turf/T in oview(range, src))
		if(!T)
			return
		new /obj/effect/temp_visual/small_smoke/halfsecond(T)
		for(var/mob/living/L in T.contents)
			if(L != src && !(L in hit_things))
				if(!faction_check(faction, L.faction))
					var/throwtarget = get_edge_target_turf(src, get_dir(src, L))
					L.safe_throw_at(throwtarget, 10, 1, src)
					L.Stun(20)
					L.apply_damage_type(40, BRUTE)
					hit_things += L
	sleep(3)

/mob/living/simple_animal/hostile/megafauna/corrupted_system/proc/shockwave(direction, range, wave_duration = 1.5)
	visible_message("<span class='boldwarning'>[src] smashes the ground!</span>")
	sleep(7)
	var/list/hit_things = list()
	var/turf/T = get_turf(src)
	var/ogdir = direction
	var/turf/otherT = get_step(T, turn(ogdir, 90))
	var/turf/otherT2 = get_step(T, turn(ogdir, -90))
	if(!T)
		return
	for(var/i in 1 to range)
		new /obj/effect/temp_visual/small_smoke/halfsecond(T)
		new /obj/effect/temp_visual/small_smoke/halfsecond(otherT)
		new /obj/effect/temp_visual/small_smoke/halfsecond(otherT2)
		for(var/mob/living/L in T.contents)
			if(L != src && !(L in hit_things))
				var/throwtarget = get_edge_target_turf(T, get_dir(T, L))
				L.safe_throw_at(throwtarget, 5, 1, src)
				L.Stun(10)
				L.apply_damage_type(10, BRUTE)
				hit_things += L
		for(var/mob/living/L in otherT.contents)
			if(L != src && !(L in hit_things))
				var/throwtarget = get_edge_target_turf(otherT, get_dir(otherT, L))
				L.safe_throw_at(throwtarget, 5, 1, src)
				L.Stun(10)
				L.apply_damage_type(10, BRUTE)
				hit_things += L
		for(var/mob/living/L in otherT2.contents)
			if(L != src && !(L in hit_things))
				var/throwtarget = get_edge_target_turf(otherT2, get_dir(otherT2, L))
				L.safe_throw_at(throwtarget, 5, 1, src)
				L.Stun(10)
				L.apply_damage_type(10, BRUTE)
				hit_things += L
		T = get_step(T, ogdir)
		otherT = get_step(otherT, ogdir)
		otherT2 = get_step(otherT2, ogdir)
		sleep(wave_duration)

/mob/living/simple_animal/hostile/megafauna/corrupted_system/proc/ultishockwave(range, iteration_duration = 5)
	visible_message("<span class='boldwarning'>[src] smashes the ground around them!</span>")
	sleep(10)
	var/list/hit_things = list()
	for(var/i in 1 to range)
		for(var/turf/T in (view(i, src) - view(i - 1, src)))
			if(!T)
				return
			new /obj/effect/temp_visual/small_smoke/halfsecond(T)
			for(var/mob/living/L in T.contents)
				if(L != src && !(L in hit_things) && !faction_check(L.faction, faction))
					var/throwtarget = get_edge_target_turf(T, get_dir(T, L))
					L.safe_throw_at(throwtarget, 5, 1, src)
					L.Stun(10)
					L.apply_damage_type(15, BRUTE)
					hit_things += L
		sleep(iteration_duration)