/mob/living/simple_animal/hostile/warmless
	name = "A Warmless"
	desc = "A creature consumed by the deep cold of...something."
	icon_state = "warmless"
	icon_living = "warmless"
	icon_dead = "warmless_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	gender = MALE
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	response_disarm_continuous = "swings through"
	response_disarm_simple = "swing through"
	response_harm_continuous = "punches through"
	response_harm_simple = "punch through"
	emote_taunt = list("wails")
	taunt_chance = 25
	speed = 0
	maxHealth = 80
	health = 80
	spacewalk = TRUE
	stat_attack = HARD_CRIT
	robust_searching = 1

	obj_damage = 50
	melee_damage = 15
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	attack_sound = 'sound/creatures/psychhead.ogg'
	speak_emote = list("shrieks")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list(FACTION_ANOMALY)

	footstep_type = FOOTSTEP_MOB_BAREFOOT
	hardattacks = TRUE
