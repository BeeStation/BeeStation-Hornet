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
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/hamster = 1)
	childtype = /mob/living/simple_animal/pet/hamster
	animal_species = /mob/living/simple_animal/pet/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE

/mob/living/simple_animal/pet/hamster/vector
	name = "Vector"
	desc = "It's Vector the hamster. Definitely not a source of deadly diseases."
	var/datum/disease/vector_disease

/mob/living/simple_animal/pet/hamster/vector/Initialize()
	. = ..()
	if(prob(1))
		vector_disease = pick(/datum/disease/cold, /datum/disease/flu, /datum/disease/fluspanish)
		AddComponent(/datum/component/infective, vector_disease)
