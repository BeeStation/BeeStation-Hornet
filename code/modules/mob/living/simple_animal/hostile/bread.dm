/mob/living/simple_animal/hostile/breadloaf
	name = "mutant bread"
	desc = "THE BREAD ARE WALKING! RUN!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "mutantbread"
	icon_living = "mutantbread"
	icon_dead = "bread"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 30
	health = 30
	see_in_dark = 3
	butcher_results = list(/obj/item/reagent_containers/food/snacks/breadslice = 2)
	response_help  = "pokes"
	response_disarm = "passes"
	response_harm   = "breaks"
	melee_damage = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500
	gold_core_spawnable = HOSTILE_SPAWN
	var/mutations = 0
	var/mutationcap = 0
	var/mutability = 50
	var/stability = 30
	mobsay_color = "#CAA25B"

/mob/living/simple_animal/hostile/breadloaf/teleport_act()
	if(mutations == 0)
		mutationcap = rand(1,mutability)
		if(prob(90))
			mutationcap = max(1, (mutationcap - stability))
	if(mutations <= mutationcap)
		resize = 1.1
		maxHealth += 5
		health = maxHealth += 1
		melee_damage += 2
		mutations++

/mob/living/simple_animal/hostile/breadloaf/slice
	name = "mutant bread slice"
	desc = "THE BREAD ARE WALKING! RUN!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "mutantbreadslice"
	icon_living = "mutantbreadslice"
	icon_dead = "breadslice"
	butcher_results = null
	melee_damage = 8
	maxHealth = 20
	health = 20
	stability = 15
	mutability = 30
