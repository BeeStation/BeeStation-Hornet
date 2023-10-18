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
	maxHealth = 240
	health = 240
	obj_damage = 0
	melee_damage = 50 //extreme damage to anything that isn't a carbon... which shouldn't happen often, but it's prepared in any case.
	attacktext = "devours"
	attack_sound = 'sound/hallucinations/over_here2.ogg' //Cronch cronch bones
	vision_range = 9
	aggro_vision_range = 9
	a_intent = INTENT_HARM
	ranged = TRUE
	projectiletype = /obj/projectile/latcher_harpoon
	projectilesound = 'sound/weapons/pierce.ogg' //Laugh + spring load
	ranged_cooldown_time = 7 SECONDS
	var/mob/living/carbon/hooked_victim //the current victim, if they exist
	var/tether_active
	var/half_life = FALSE //for something we want to activate on every other life proc

/mob/living/simple_animal/hostile/latcher/Life()
	..()
	if(hooked_victim)
		target = hooked_victim //stay on the same target so long as someone is hooked
		ranged_cooldown = world.time + ranged_cooldown_time //Cooldown is maintained until victim is freed

		if(hooked_victim.pulledby)
			hooked_victim = null
			var/datum/beam/B = tether_active
			if(B)
				qdel(B)
			tether_active = null
			hooked_victim.SetKnockdown(1 SECONDS)
			hooked_victim.SetImmobilized(1 SECONDS)
			FindTarget() //pick a new target

		else
			if(half_life)
				step(hooked_victim,get_dir(hooked_victim,src))
				half_life = FALSE
			else
				half_life = TRUE
			hooked_victim.Knockdown(6 SECONDS)
			hooked_victim.Immobilize(6 SECONDS)

//THE MAUL PROC

/mob/living/simple_animal/hostile/latcher/AttackingTarget()
	if(iscarbon(target))
		if(prob(50)) //slower and inconsistent attack
			maul_target(target)
		//else play laughing sound instead of attacking sound
		return
	else
		..()


/mob/living/simple_animal/hostile/latcher/proc/maul_target(maul_target)
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

		fisherman.hooked_victim = hooked
		hooked.Paralyze(4 SECONDS)
		to_chat(hooked, "<span class='userdanger'>\The [fisherman] has impaled you and is reeling you in!</span>")
		fisherman.tether_active = fisherman.Beam(hooked, "latcher", time=INFINITY, maxdistance=9, beam_type=/obj/effect/ebeam)

	var/datum/beam/B = reel
	if(B)
		qdel(B)
	return ..()
