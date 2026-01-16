/mob/living/simple_animal/hostile/faithless
	name = "The Faithless"
	desc = "The Wish Granter's faith in humanity, incarnate."
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
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
	stat_attack = HARD_CRIT
	robust_searching = 1

	obj_damage = 50
	melee_damage = 15
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	speak_emote = list("growls")

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list(FACTION_FAITHLESS)
	gold_core_spawnable = HOSTILE_SPAWN

	footstep_type = FOOTSTEP_MOB_SHOE
	hardattacks = TRUE

/mob/living/simple_animal/hostile/faithless/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/simple_animal/hostile/faithless/faithful
	name = "Faithsworn"
	desc = "A creature made of pure faith from shadowpeople."
	melee_damage = 20
	gold_core_spawnable = NO_SPAWN
	del_on_death = TRUE
