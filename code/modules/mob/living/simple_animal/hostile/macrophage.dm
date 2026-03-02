/mob/living/simple_animal/hostile/macrophage
	name = "Germ"
	desc = "A giant virus!"
	icon_state = "macrovirus_small"
	speak_emote = list("Blubbers")
	emote_hear = list("Blubbers")
	melee_damage = 1
	attack_verb_continuous = "pierces"
	attack_verb_simple = "pierce"
	response_help_continuous = "shoos"
	response_help_simple = "shoo"
	response_disarm_continuous = "swats away"
	response_disarm_simple = "swat away"
	response_harm_continuous = "squashes"
	response_harm_simple = "squash"
	maxHealth = 6
	health = 6
	faction = list(FACTION_PLANTS)
	move_to_delay = 0
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	del_on_death = TRUE
	var/aggressive = FALSE
	var/datum/disease/base_disease = null
	var/list/infections = list()
	discovery_points = 2000

/mob/living/simple_animal/hostile/macrophage/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

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

/mob/living/simple_animal/hostile/macrophage/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/M = target
		if(M.can_inject(src))
			for(var/datum/disease/D in infections)
				if(M.ForceContractDisease(D)) //we already check spread type in the macrophage creation proc
					to_chat(src, span_notice("You infect [M] with [D]!"))
		else if(aggressive)
			M.visible_message(span_danger("the [src] begins penetrating [M]' protection!"), \
					span_danger("[src] begins penetrating your protection!"))
			if(do_after(src, 1.5 SECONDS, M))
				for(var/datum/disease/D in infections)
					if(M.ForceContractDisease(D))
						to_chat(src, span_notice("You infect [M] with [D]!"))
				to_chat(M, span_userdanger("[src] pierces your protection, and you feel a sharp stab!"))

/mob/living/simple_animal/hostile/macrophage/proc/shrivel()
	visible_message(span_danger("the [src] shrivels up and dies!"))
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

