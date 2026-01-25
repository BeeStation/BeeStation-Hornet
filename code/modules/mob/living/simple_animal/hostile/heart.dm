/mob/living/simple_animal/hostile/heart
	name = "Heart"
	desc = "A living heart. It's angry!"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	icon_living = "heart-on"
	icon_dead = "heart-on"
	gender = NEUTER
	turns_per_move = 5
	speak_emote = list("beats")
	emote_see = list("beats")
	combat_mode = TRUE
	maxHealth = 24
	health = 24
	speed = -1
	melee_damage = 15
	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "beats"
	response_disarm_simple = "beat"
	response_harm_continuous = "breaks"
	response_harm_simple = "break"
	density = FALSE
	attack_verb_continuous = "beats"
	attack_verb_simple = "beat"
	attack_sound = 'sound/effects/singlebeat.ogg'
	stat_attack = HARD_CRIT
	attack_same = 1
	gold_core_spawnable = HOSTILE_SPAWN
	see_in_dark = NIGHTVISION_FOV_RANGE
	deathmessage = "falls lifeless."
	del_on_death = TRUE
	loot = list(/obj/item/organ/heart)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500

/mob/living/simple_animal/hostile/heart/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
