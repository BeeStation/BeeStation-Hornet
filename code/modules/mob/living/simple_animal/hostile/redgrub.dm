/mob/living/simple_animal/hostile/redgrub
	name = "redgrub"
	desc = "A parasite that feeds off of slime cytoplasm and other toxic substances. Its meat is a delicacy when cooked."
	icon_state = "grub_1"
	icon_living = "grub_1"
	icon_dead = "grub_1_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	butcher_results = list(/obj/effect/decal/cleanable/insectguts = 1)
	damage_coeff = list(BRUTE = 1, BURN = 2, TOX = -1, CLONE = 0, STAMINA = 0, OXY = 0) //can't be eaten by slimes, and healed by toxin damage
	turns_per_move = 5
	maxHealth = 4
	health = 4
	melee_damage = 3
	obj_damage = 0
	attacktext = "bites"
	response_help  = "pets"
	response_disarm = "pokes"
	response_harm   = "squishes"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	faction = list("hostile")
	attack_sound = 'sound/effects/blobattack.ogg'
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	stat_attack = SOFT_CRIT
	gold_core_spawnable = NO_SPAWN //making these spawn from gold cores is kinda bad for xenobio. these grubs can be further implemented for it at a later date if someone wants to
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 360 //really, *really* dont like heat
	deathmessage = "curls up and stops moving."
	var/patience = 30
	var/growthstage = 1 //1-3.
	var/food = 0
	var/hibernating = FALSE //if they dont aggro, they hibernate until they do. They will allow themselves to be killed, butchered, or eaten.
	var/hibernationcounter = 0
	var/list/grubdisease = list()

/mob/living/simple_animal/hostile/redgrub/proc/isslimetarget(var/mob/living/M)
	if(isoozeling(M))
//	if(isslimeperson(M) || isluminescent(M) || isoozeling(M) || isstargazer(M)) // i hate this
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/redgrub/spawn_gibs() //redgrubs dont have much in the way of gibs or mess. just meat.
	new /obj/effect/decal/cleanable/insectguts(drop_location())
	playsound(drop_location(), 'sound/effects/blobattack.ogg', 60, TRUE)

/mob/living/simple_animal/hostile/redgrub/Initialize()
	. = ..()
	var/datum/disease/advance/A = new /datum/disease/advance/random(rand(3, 6), 9, rand(3,4), /datum/symptom/parasite)
	grubdisease += A
	food = rand(15, 50)

/mob/living/simple_animal/hostile/redgrub/PickTarget()
	var/newtarget = ..()
	if(CanAttack(newtarget))
		return newtarget

/mob/living/simple_animal/hostile/redgrub/Life()
	. = ..()
	if(stat)
		return
	switch(food)
		if(0)
			death()
		if(1 to 9)
			if(growthstage >= 2)
				shrink()
			else if(!target && !hibernating) //we're starving!
				togglehibernation()
		if(10 to 15)
			if(growthstage >= 2)
				shrink()
		if(16 to 24)
			if(growthstage >= 3)
				shrink()
		if(25 to 35)
			if(growthstage >= 3)
				shrink()
			if(growthstage <= 1)
				grow()
		if(36 to 49)
			if(growthstage <= 1)
				grow()
		if(50 to INFINITY)
			if(growthstage <= 2)
				grow()
	if(!hibernating && !target && food)
		food --
	if(hibernationcounter >= 10 && !target && !hibernating)
		togglehibernation()
	else if(target && hibernating)
		togglehibernation()
	else
		hibernationcounter ++

/mob/living/simple_animal/hostile/redgrub/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = TRUE)
	if(!LAZYLEN(grubdisease))
		return FALSE
	if(scan)
		E.scan(src, grubdisease, user)
	else
		E.extrapolate(src, grubdisease, user)
	return TRUE

/mob/living/simple_animal/hostile/redgrub/proc/togglehibernation()
	if(hibernating)
		hibernating = FALSE
		stop_automated_movement = 0
		hibernationcounter = 0
		if(target)
			visible_message("<span class='warning'>[src] uncurls and starts moving towards [target].</span>")
		else
			visible_message("<span class='warning'>[src] uncurls.</span>")
		switch(growthstage)
			if(1)
				icon_state = "grub_1"
				icon_living = "grub_1"
				icon_dead = "grub_1_dead"
			if(2)
				icon_state = "grub_2"
				icon_living = "grub_2"
				icon_dead = "grub_2_dead"
			if(3)
				icon_state = "grub_3"
				icon_living = "grub_3"
				icon_dead = "grub_3_dead"
	else
		visible_message("<span class='warning'>[src] curls up and stops moving.</span>") //fake death
		icon_state = icon_dead
		icon_living = icon_dead
		hibernating = TRUE
		stop_automated_movement = 1

/mob/living/simple_animal/hostile/redgrub/proc/grow()
	switch(growthstage)
		if(1)
			growthstage += 1
			maxHealth += 4
			melee_damage += 3
			icon_state = "grub_2"
			icon_living = "grub_2"
			icon_dead = "grub_2_dead"
		if(2)
			growthstage += 1
			maxHealth += 4
			melee_damage += 3
			icon_state = "grub_3"
			icon_living = "grub_3"
			icon_dead = "grub_3_dead"
		if(3)
			return FALSE

/mob/living/simple_animal/hostile/redgrub/proc/shrink()
	switch(growthstage)
		if(1)
			return FALSE
		if(2)
			growthstage -= 1
			maxHealth -= 4
			melee_damage -= 3
			icon_state = "grub_1"
			icon_living = "grub_1"
			icon_dead = "grub_1_dead"
		if(3)
			growthstage -= 1
			maxHealth -= 4
			melee_damage -= 3
			icon_state = "grub_2"
			icon_living = "grub_2"
			icon_dead = "grub_2_dead"

/mob/living/simple_animal/hostile/redgrub/CanAttack(atom/the_target)
	if(isliving(the_target))
		if(isslime(the_target) || isslimetarget(the_target))
			return ..()
	return FALSE

/mob/living/simple_animal/hostile/redgrub/harvest(mob/living/user) //used for extra objects etc. in butchering
	for(var/i in 1 to growthstage)
		var/obj/item/reagent_containers/food/snacks/meat/rawcutlet/grub/meat = new(src.loc)
		for(var/datum/disease/advance/A in grubdisease)
			if(A.spread_flags & DISEASE_SPREAD_FALTERED)
				grubdisease -= A
				if(!LAZYLEN(grubdisease))
					return
		meat.AddComponent(/datum/component/infective, grubdisease)
	return ..()

/mob/living/simple_animal/hostile/redgrub/attack_slime(mob/living/simple_animal/slime/M)//this is pretty unlikely to happen in game.
	if(!SSticker.HasRoundStarted()) //since i need to skip simple_animal/attack slime
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.buckled)
		if(M in buckled_mobs)
			M.Feedstop()
		return // can't attack while eating!

	if(HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, "<span class='notice'>You don't want to hurt anyone!</span>")
		return FALSE
	var/datum/status_effect/slimegrub/status = M.has_status_effect(STATUS_EFFECT_SLIMEGRUB)
	if(status)
		status.diseases += grubdisease
		status.deathcounter -= (40 * growthstage)
		status.spawnbonus += 1
	else
		var/datum/status_effect/slimegrub/newstatus = M.apply_status_effect(STATUS_EFFECT_SLIMEGRUB)
		newstatus.diseases += grubdisease
	M.visible_message("<span class='warning'>[M] swallows [src] whole!</span>", "<span class='userdanger'>[src] burrows into your cytoplasm when you bite it!</span>")
	qdel(src)

/mob/living/simple_animal/hostile/redgrub/environment_temperature_is_safe(datum/gas_mixture/environment)
	if(isliving(loc))
		var/mob/living/L = loc
		if(L.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
			return FALSE
	else
		return TRUE

/mob/living/simple_animal/hostile/redgrub/AttackingTarget()
	. = ..()
	if(. && isslimetarget(target))
		var/mob/living/carbon/human/M = target
		food += 10
		if(growthstage >= 3)
			M.visible_message("<span class='danger'>the [src] begins burrowing into [M]!</span>", \
						"<span class='userdanger'>[src] is trying to burrow into your cytoplasm!</span>")
			if(M.can_inject(src) && do_after(src, 15, M))
				for(var/datum/disease/D in grubdisease)
					if(D.spread_flags & DISEASE_SPREAD_FALTERED)
						continue
					M.ForceContractDisease(D)
				to_chat(M, "<span class ='userdanger'>[src] burrows into your cytoplasm!</span>")
				playsound(src.loc, 'sound/effects/blobattack.ogg', 60, TRUE)
				death()
				qdel(src)
