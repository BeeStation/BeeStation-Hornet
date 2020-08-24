/mob/living/simple_animal/hostile/retaliate/dolphin
	name = "space dolphin"
	desc = "A dolphin in space."
	icon = 'icons/mob/animal.dmi'
	icon_state = "dolphin"
	icon_living = "dolphin"
	icon_dead = "dolphin_dead"
	icon_gib = "dolphin_gib"
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/dolphinmeat = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25
	a_intent = "harm"
	spacewalk = TRUE

	environment_smash = 0
	melee_damage = 15
	pass_flags = PASSTABLE
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("chitters", "squeeks", "clicks")

	//Space dolphins aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

/mob/living/simple_animal/hostile/retaliate/dolphin/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/retaliate/dolphin/AttackingTarget()
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustStaminaLoss(8)
