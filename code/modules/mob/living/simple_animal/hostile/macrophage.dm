/mob/living/simple_animal/hostile/macrophage
	name = "Germ"
	desc = "A giant virus!"
	icon_state = "macrovirus_small"
	speak_emote = list("Blubbers")
	emote_hear = list("Blubbers")
	melee_damage = 1
	attacktext = "pierces"
	response_help  = "shoos"
	response_disarm = "swats away"
	response_harm   = "squashes"
	maxHealth = 6
	health = 6
	spacewalk = TRUE
	faction = list("hostile")
	move_to_delay = 0
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	del_on_death = TRUE
	var/aggressive = FALSE
	var/datum/disease/base_disease = null
	var/list/infections = list()
	discovery_points = 2000

/mob/living/simple_animal/hostile/macrophage/CanAttack(atom/the_target)
	. = ..()
	if(!.)
		return FALSE
	var/alreadyinfected = FALSE
	if(isliving(the_target))
		var/mob/living/M = the_target
		for(var/datum/disease/D in M.diseases)
			if(D.GetDiseaseID() == base_disease.GetDiseaseID())
				if(aggressive)
					if(D.stage >= 4)
						alreadyinfected = TRUE
				else
					alreadyinfected = TRUE
	if(alreadyinfected)
		return FALSE

/mob/living/simple_animal/hostile/macrophage/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run = FALSE)
	. = ..()
	EXTRAPOLATOR_ACT_ADD_DISEASES(., base_disease)
	if(!dry_run && !EXTRAPOLATOR_ACT_CHECK(., EXTRAPOLATOR_ACT_PRIORITY_SPECIAL) && extrapolator.create_culture(user, base_disease))
		user.visible_message("<span class='danger'>[user] stabs [src] with [extrapolator], sucking it up!</span>", \
				"<span class='danger'>You stab [src] with [extrapolator]'s probe, destroying it!</span>")
		dust()
		EXTRAPOLATOR_ACT_SET(., EXTRAPOLATOR_ACT_PRIORITY_SPECIAL)

/mob/living/simple_animal/hostile/macrophage/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/M = target
		if(M.can_inject(src))
			for(var/datum/disease/D in infections)
				if(M.ForceContractDisease(D)) //we already check spread type in the macrophage creation proc
					to_chat(src, "<span class ='notice'>You infect [M] with [D]!</span>")
		else if(aggressive)
			M.visible_message("<span class='danger'>the [src] begins penetrating [M]' protection!</span>", \
	 				 "<span class='danger'>[src] begins penetrating your protection!</span>")
			if(do_after(src, 1.5 SECONDS, M))
				for(var/datum/disease/D in infections)
					if(M.ForceContractDisease(D))
						to_chat(src, "<span class ='notice'>You infect [M] with [D]!</span>")
				to_chat(M, "<span class ='userdanger'>[src] pierces your protection, and you feel a sharp stab!</span>")

/mob/living/simple_animal/hostile/macrophage/proc/shrivel()
	visible_message("<span class='danger'>the [src] shrivels up and dies!</span>")
	dust()

/mob/living/simple_animal/hostile/macrophage/aggro
	name = "Giant Germ"
	desc = "An incredibly huge virus!"
	icon_state = "macrovirus_large"
	melee_damage = 5
	maxHealth = 12
	health = 12
	pass_flags = PASSTABLE | PASSGRILLE
	density = TRUE
	aggressive = TRUE

/mob/living/simple_animal/hostile/macrophage/aggro/vector

/mob/living/simple_animal/hostile/macrophage/aggro/vector/Initialize(mapload)
	.=..()
	var/datum/disease/advance/random/macrophage/D = new
	health += D.resistance
	maxHealth += D.resistance
	melee_damage += max(0, D.resistance)
	infections += D
	base_disease = D

