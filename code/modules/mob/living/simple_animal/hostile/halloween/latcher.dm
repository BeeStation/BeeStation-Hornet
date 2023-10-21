/mob/living/simple_animal/hostile/latcher
	name = "Latcher"
	desc = "The remains of its previous victim can be seen rotting in its tendrils. If it grabs anyone, be sure to help them get free!"
	icon = 'icons/mob/halloween/latcher.dmi'
	icon_state = "latcher"
	icon_living = "latcher"
	icon_dead = "latcher_dead"
	icon_gib = null
	mob_biotypes = list(MOB_INORGANIC)
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 24 HOURS
	speed = 0
	wander = FALSE
	anchored = TRUE
	density = TRUE
	maxHealth = 500
	health = 500
	obj_damage = 0
	melee_damage = 50 //extreme damage to anything that isn't a carbon... which shouldn't happen often, but it's prepared in any case.
	attacktext = "devours"
	vision_range = 9
	aggro_vision_range = 9
	a_intent = INTENT_HARM
	ranged = TRUE
	projectiletype = /obj/projectile/latcher_harpoon
	ranged_cooldown_time = 7 SECONDS
	var/mob/living/carbon/hooked_victim //the current victim, if they exist
	var/tether_active
	var/half_life = FALSE //for something we want to activate on every other life proc
	var/reel_sound
	var/idle_sound
	var/laugh_sound
	var/mine_cooldown

/mob/living/simple_animal/hostile/latcher/Initialize()
	..()
	rotate_sound("all")

/mob/living/simple_animal/hostile/latcher/proc/rotate_sound(type)
	switch(type)
		if("all")
			deathsound = pick('sound/creatures/halloween/Latcher/LatcherDeath1.ogg',
								'sound/creatures/halloween/Latcher/LatcherDeath2.ogg',
								'sound/creatures/halloween/Latcher/LatcherDeath3.ogg',
								'sound/creatures/halloween/Latcher/LatcherDeath4.ogg')
			rotate_sound("attack")
			rotate_sound("idle")
			rotate_sound("spit")
			rotate_sound("reel")
			rotate_sound("laugh")
			return

		if("attack")
			attack_sound = pick('sound/creatures/halloween/Latcher/Chomp1.ogg',
								'sound/creatures/halloween/Latcher/Chomp2.ogg',
								'sound/creatures/halloween/Latcher/Chomp3.ogg')
			return

		if("idle")
			idle_sound = pick('sound/creatures/halloween/Latcher/LatcherIdle1.ogg',
								'sound/creatures/halloween/Latcher/LatcherIdle2.ogg',
								'sound/creatures/halloween/Latcher/LatcherIdle3.ogg',
								'sound/creatures/halloween/Latcher/LatcherIdle4.ogg')
			return

		if("spit")
			projectilesound = pick('sound/creatures/halloween/Latcher/LatcherSpit1.ogg',
									'sound/creatures/halloween/Latcher/LatcherSpit2.ogg',
									'sound/creatures/halloween/Latcher/LatcherSpit3.ogg')
			return

		if("reel")
			reel_sound = pick('sound/creatures/halloween/Latcher/REEL1.ogg',
								'sound/creatures/halloween/Latcher/REEL2.ogg',
								'sound/creatures/halloween/Latcher/REEL3.ogg',
								'sound/creatures/halloween/Latcher/REEL4.ogg')
			return

		if("laugh")
			laugh_sound = pick('sound/creatures/halloween/Latcher/LatcherEx1.ogg',
								'sound/creatures/halloween/Latcher/LatcherEx2.ogg',
								'sound/creatures/halloween/Latcher/LatcherEx3.ogg',
								'sound/creatures/halloween/Latcher/LatcherEx4.ogg')

/mob/living/simple_animal/hostile/latcher/Life()
	. = ..()
	if(hooked_victim)

		target = hooked_victim //stay on the same target so long as someone is hooked
		ranged_cooldown = world.time + ranged_cooldown_time //Cooldown is maintained until victim is freed

		if(hooked_victim.pulledby)
			release_target()
			FindTarget() //pick a new target

		else
			if(hooked_victim.loc != loc) //They will be allowed to run briefly, but quickly be reeled in again.
				if(half_life)
					playsound(loc, reel_sound, 200)
					rotate_sound("reel")
					step(hooked_victim,get_dir(hooked_victim,src))
					half_life = FALSE
				else
					half_life = TRUE
					playsound(loc, laugh_sound, 200)
					rotate_sound("laugh")
				hooked_victim.Knockdown(4 SECONDS)
				hooked_victim.Immobilize(4 SECONDS)
	else if(!target && prob(5))
		playsound(loc, idle_sound, 200)
		rotate_sound("idle")

/mob/living/simple_animal/hostile/latcher/death(gibbed)
	..()
	release_target()

/mob/living/simple_animal/hostile/latcher/attack_basic_mob()
	playsound(loc, attack_sound, 200)
	attack_sound = null //we want to override modulation
	..()
	rotate_sound("attack")

//THE MAUL PROC

/mob/living/simple_animal/hostile/latcher/AttackingTarget()
	if(iscarbon(target))
		if(target.loc != loc)
			return
		if(prob(50)) //slower and inconsistent attack
			maul_target(target)
		else if(prob(60))
			playsound(loc, laugh_sound, 200)
			rotate_sound("laugh")
		else
			playsound(hooked_victim, 'sound/creatures/halloween/Latcher/LatcherMINE.ogg', 300)
		return
	else
		..()


/mob/living/simple_animal/hostile/latcher/proc/maul_target(maul_target)
	playsound(loc, attack_sound, 200)
	rotate_sound("attack")
	if(iscarbon(maul_target))
		var/mob/living/carbon/C = maul_target
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
		else
			C.gib()
			release_target()

/mob/living/simple_animal/hostile/latcher/proc/release_target()
	if(hooked_victim)
		hooked_victim.SetKnockdown(1 SECONDS)
		hooked_victim.SetImmobilized(1 SECONDS)
	hooked_victim = null
	var/datum/beam/B = tether_active
	if(B)
		qdel(B)
	tether_active = null


/mob/living/simple_animal/hostile/latcher/OpenFire()
	..()
	rotate_sound("spit")

//THE BONE HARPOON

/obj/projectile/latcher_harpoon
	name = "latcher tendril"
	icon_state= "latcher_harpoon"
	damage = 20
	armour_penetration = 40
	speed = 0.1
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	var/reel

/obj/projectile/latcher_harpoon/Initialize()
	..()
	hitsound = pick('sound/creatures/halloween/Latcher/LProjectileHit1.ogg',
					'sound/creatures/halloween/Latcher/LProjectileHit2.ogg',
					'sound/creatures/halloween/Latcher/LProjectileHit3.ogg')

/obj/projectile/latcher_harpoon/fire()
	..()
	if(firer)
		reel = firer.Beam(src, "latcher", maxdistance=9)

/obj/projectile/latcher_harpoon/on_hit(atom/target, blocked = FALSE)
	//[firer] is the person who shot the projectile
	//[target] is the one being hit by it
	if(iscarbon(target) && istype(firer, /mob/living/simple_animal/hostile/latcher))
		var/mob/living/carbon/hooked = target
		var/mob/living/simple_animal/hostile/latcher/fisherman = firer

		playsound(fisherman, 'sound/creatures/halloween/Latcher/LatcherMINE.ogg', 400)

		fisherman.hooked_victim = hooked
		hooked.Paralyze(1 SECONDS)
		hooked.Knockdown(6 SECONDS)
		hooked.Immobilize(6 SECONDS)
		to_chat(hooked, "<span class='userdanger'>\The [fisherman] has impaled you and is reeling you in!</span>")
		fisherman.tether_active = fisherman.Beam(hooked, "latcher", time=INFINITY, maxdistance=9, beam_type=/obj/effect/ebeam)

	var/datum/beam/B = reel
	if(B)
		qdel(B)
	return ..()
