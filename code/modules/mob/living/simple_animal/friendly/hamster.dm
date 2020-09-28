/mob/living/simple_animal/pet/hamster
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "bites"
	speak = list("Squeak", "SQUEAK!")
	speak_emote = list("squeak", "hisses", "squeals")
	emote_hear = list("squeaks.", "hisses.", "squeals.")
	emote_see = list("skitters", "examines it's claws", "rolls around")
	faction = list("hamster")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 3
	do_footstep = TRUE

	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS

	name = "\improper hamster"
	real_name = "hamster"
	desc = "It's a hamster."
	icon_state = "hamster"
	icon_living = "hamster"
	icon_dead = "hamster_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/hamster = 1)
	childtype = /mob/living/simple_animal/pet/hamster
	animal_species = /mob/living/simple_animal/pet/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	mobsay_color = "#D3B277"

/mob/living/simple_animal/pet/hamster/vector //now also viro's source of a solitary, shitty starter disease
	name = "Vector"
	desc = "It's Vector the hamster. Definitely not a source of deadly diseases."
	var/datum/disease/vector_disease
	var/list/extrapolatordisease = list()
	

/mob/living/simple_animal/pet/hamster/vector/Initialize()
	. = ..()
	if(prob(5))
		var/datum/disease/disease = pick(/datum/disease/cold, /datum/disease/flu, /datum/disease/fluspanish)
		vector_disease = new disease
		message_admins("Vector was roundstart infected with [vector_disease.name]. Don't lynch the virologist!")
		log_game("Vector was roundstart infected with [vector_disease.name].")
	var/datum/disease/advance/R = new /datum/disease/advance/random(rand(1, 3))
	extrapolatordisease += R

/mob/living/simple_animal/pet/hamster/vector/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = TRUE)
	if(!extrapolatordisease.len)
		return FALSE
	if(scan)
		E.scan(src, extrapolatordisease, user)
	else
		E.extrapolate(src, extrapolatordisease, user)
	return TRUE

/mob/living/simple_animal/pet/hamster/vector/Crossed(M as mob)
	if(isliving(M) && !isnull(vector_disease) && prob(20))
		var/mob/living/L = M
		if(!L.HasDisease(vector_disease)) //I'm not actually sure if this check is needed, but better to be safe than sorry
			L.ContactContractDisease(vector_disease)
	..()
