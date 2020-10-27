/mob/living/simple_animal/hostile/megafauna/dragon/hard
	name = "enraged ash drake"
	desc = "A very enraged guardian of the necropolis. Better run."
	health = 3000
	maxHealth = 3000

	armour_penetration = 60
	melee_damage = 60

	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/hard/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/dragon/hard)

	abyss_born = FALSE

/mob/living/simple_animal/hostile/megafauna/dragon/hard/fire_rain()
	if(!target)
		return
	target.visible_message("<span class='boldwarning'>Fire rains from the sky!</span>")

	fire_splash(1)
	sleep(10)
	fire_splash(2)
	sleep(10)
	fire_splash(1)

/mob/living/simple_animal/hostile/megafauna/dragon/hard/proc/fire_splash(var/counter = 1)
	if(!target)
		return
	for(var/turf/turf in circlerangeturfs(get_turf(target), 9))
		if((turf.x % counter || turf.y % counter) && !(turf.x % counter && turf.y % counter))
			new /obj/effect/temp_visual/target(turf)



/mob/living/simple_animal/hostile/megafauna/dragon/hard/lava_swoop(var/amount = 30)
	if(health < maxHealth * 0.5)
		return swoop_attack(lava_arena = TRUE, swoop_cooldown = 60)
	INVOKE_ASYNC(src, .proc/lava_pools, amount)
	swoop_attack(FALSE, target, 1000) // longer cooldown until it gets reset below
	SLEEP_CHECK_DEATH(0)
	fire_cone()
	if(health < maxHealth*0.5)
		SLEEP_CHECK_DEATH(10)
		fire_cone()
		SLEEP_CHECK_DEATH(10)
		fire_spiral()
	SetRecoveryTime(40)

/mob/living/simple_animal/hostile/megafauna/dragon/hard/proc/fire_spiral()
	if(!target)
		return

	var/list/blacklisted = list()

	for(var/radius = 1 to 6)
		for(var/turf/turf in circlerangeturfs(get_turf(src), radius))
			if(turf in blacklisted)
				continue
			blacklisted.Add(turf)
			turf.hotspot_expose(700,50,1)
			for(var/mob/living/L in turf.contents)
				if(L == src)
					continue
					L.adjustFireLoss(20)
					to_chat(L, "<span class='userdanger'>You're hit by [src]'s fire breath!</span>")
			sleep(0.2)
		sleep(2)