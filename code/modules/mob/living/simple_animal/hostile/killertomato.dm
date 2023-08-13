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
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/killertomato = 2)
	response_help  = "prods"
	response_disarm = "pushes aside"
	response_harm   = "smacks"
	melee_damage = 10
	attacktext = "slams"
	attack_sound = 'sound/weapons/punch1.ogg'
	ventcrawler = VENTCRAWLER_ALWAYS
	faction = list("plants")

	mobchatspan = "headofsecurity"
	discovery_points = 1000

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500
	gold_core_spawnable = HOSTILE_SPAWN
	var/frenzythreshold = 5 //how many tomatoes can this tomato see on screen before going berserk
	var/is_frenzy = FALSE
	var/last_frenzy_check = 0

/mob/living/simple_animal/hostile/killertomato/CanAttack(atom/the_target)
	if (last_frenzy_check + 5 SECONDS < world.time)
		var/tomatosseen = 0
		for(var/mob/living/simple_animal/hostile/killertomato/T in orange(5, src))
			tomatosseen += 1
		is_frenzy = (tomatosseen >= frenzythreshold)
		last_frenzy_check = world.time
	if(is_frenzy && istype(the_target, /mob/living/simple_animal/hostile/killertomato))
		attack_same = TRUE
	. = ..()
	// Reset the attack same flag
	attack_same = initial(attack_same)
