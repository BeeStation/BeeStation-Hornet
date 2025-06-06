/mob/living/simple_animal/hostile/killertomato
	name = "Killer Tomato"
	desc = "It's a horrifyingly enormous beef tomato, and it's packing extra beef!"
	icon_state = "tomato"
	icon_living = "tomato"
	icon_dead = "tomato_dead"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 30
	health = 30
	see_in_dark = 3
	butcher_results = list(/obj/item/food/meat/slab/killertomato = 2)
	response_help_continuous = "prods"
	response_help_simple = "prod"
	response_disarm_continuous = "pushes aside"
	response_disarm_simple = "push aside"
	response_harm_continuous = "smacks"
	response_harm_simple = "smack"
	melee_damage = 10
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list(FACTION_PLANTS)

	mobchatspan = "headofsecurity"
	discovery_points = 1000

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500
	gold_core_spawnable = HOSTILE_SPAWN
	var/frenzythreshold = 5 //how many tomatoes can this tomato see on screen before going berserk

/mob/living/simple_animal/hostile/killertomato/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/killertomato/CanAttack(atom/the_target)
	var/tomatosseen = 0
	for(var/mob/living/simple_animal/hostile/killertomato/T in oview(7, src))
		tomatosseen += 1
	if(tomatosseen >= frenzythreshold)
		attack_same = TRUE
	. = ..()

