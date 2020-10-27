/mob/living/simple_animal/hostile/megafauna/colossus/hard
	name = "enraged colossus"
	desc = "A very, very angry monstrous creature protected by heavy shielding."
	health = 3000
	maxHealth = 3000

	armour_penetration = 60
	melee_damage = 60
	speed = 2

	crusher_loot = list(/obj/structure/closet/crate/necropolis/colossus/hard/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/colossus/hard)

	abyss_born = FALSE

	var/projectile_speed_multiplier = 1

/obj/item/projectile/colossus/death_orb
	name = "death orb"
	icon_state = "gumball"
	damage = 20
	speed = 6
	armour_penetration = 100
	homing_turn_speed = 30
	damage_type = BRUTE

/obj/item/projectile/death_orb/proc/orb_explosion(projectile_speed_multiplier)
	for(var/i in 0 to 5)
		var/angle = i * 60
		var/turf/startloc = get_turf(src)
		var/turf/endloc = get_turf(original)
		if(!startloc || !endloc)
			break
		var/obj/item/projectile/colossus/P = new(startloc)
		P.preparePixelProjectile(endloc, startloc, null, angle + rand(-10, 10))
		P.firer = firer
		if(original)
			P.original = original
		P.fire()
	qdel(src)

/obj/item/projectile/colossus/death
	name ="destroying bolt"
	damage = 100 //Welp... Don't touch it!
	armour_penetration = 100
	speed = 12
	eyeblur = 0
	damage_type = BRUTE

/mob/living/simple_animal/hostile/megafauna/colossus/hard/proc/shoot_death_projectile(turf/marker, set_angle)
	if(!isnum(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus/death(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/colossus/hard/proc/shoot_sphere_projectile(turf/marker, set_angle)
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus/death_orb(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)
	return P


/mob/living/simple_animal/hostile/megafauna/colossus/hard/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 2)
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_death_projectile(E)

/mob/living/simple_animal/hostile/megafauna/colossus/hard/proc/shpere_shots()
	for(var/tdir in GLOB.alldirs)
		var/turf/T = get_step(src, tdir)
		var/obj/item/projectile/death_orb/orb = shoot_sphere_projectile(T)
		addtimer(CALLBACK(orb, /obj/item/projectile/death_orb/proc/orb_explosion, 1), 20)
		orb.set_homing_target(target)
		playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, 1)
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/colossus/hard/proc/homing_line()
	for(var/i in 1 to 20)
		var/turf/T = get_turf(target)
		shoot_projectile(T)
		sleep(2)

/mob/living/simple_animal/hostile/megafauna/colossus/hard/OpenFire()
	anger_modifier = clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + 120

	if(enrage(target))
		if(move_to_delay == initial(move_to_delay))
			visible_message("<span class='colossus'>\"<b>You can't dodge.</b>\"</span>")
		ranged_cooldown = world.time + 30
		telegraph()
		dir_shots(GLOB.alldirs)
		move_to_delay = 3
		return
	else
		move_to_delay = initial(move_to_delay)

	if(prob(20+anger_modifier)) //Major attack
		telegraph()

		if(health < maxHealth/3)
			double_spiral()
		else
			visible_message("<span class='colossus'>\"<b>Judgement.</b>\"</span>")
			INVOKE_ASYNC(src, .proc/spiral_shoot, pick(TRUE, FALSE))

	if(prob(anger_modifier + 10))
		INVOKE_ASYNC(src, .proc/homing_line)
	else if(prob(25))
		shpere_shots()

	else if(prob(20))
		ranged_cooldown = world.time + 2
		random_shots()
	else
		if(prob(70))
			ranged_cooldown = world.time + 10
			blast()
		else
			ranged_cooldown = world.time + 20
			INVOKE_ASYNC(src, .proc/alternating_dir_shots)