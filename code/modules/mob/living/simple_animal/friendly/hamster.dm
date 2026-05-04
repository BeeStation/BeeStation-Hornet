/mob/living/simple_animal/pet/hamster
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "bites"
	response_harm_simple = "bite"
	speak = list("Squeak", "SQUEAK!")
	speak_emote = list("squeak", "hisses", "squeals")
	speak_language = /datum/language/metalanguage
	emote_hear = list("squeaks.", "hisses.", "squeals.")
	emote_see = list("skitters", "examines it's claws", "rolls around")
	faction = list(FACTION_NEUTRAL)
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 3
	footstep_type = FOOTSTEP_MOB_CLAW

	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL

	name = "\improper hamster"
	real_name = "hamster"
	desc = "It's a hamster."
	icon_state = "hamster"
	icon_living = "hamster"
	held_state = "hamster"
	icon_dead = "hamster_dead"
	butcher_results = list(/obj/item/food/meat/slab/hamster = 1)
	childtype = /mob/living/simple_animal/pet/hamster
	animal_species = /mob/living/simple_animal/pet/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	chat_color = "#D3B277"

/mob/living/simple_animal/pet/hamster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/pet/hamster/vector //now also viro's source of a solitary, shitty starter disease
	name = "Vector"
	desc = "It's Vector the hamster. Definitely not a source of deadly diseases."
	var/datum/disease/vector_disease
	var/list/datum/disease/extrapolator_diseases = list()

/mob/living/simple_animal/pet/hamster/vector/Initialize(mapload)
	. = ..()
	if(prob(5))
		var/datum/disease/disease = pick(/datum/disease/cold, /datum/disease/flu, /datum/disease/fluspanish)
		vector_disease = new disease
		message_admins("Vector was roundstart infected with [vector_disease.name]. Don't lynch the virologist!")
		log_game("Vector was roundstart infected with [vector_disease.name].")
	var/list/potential_guaranteed_symptoms = list()
	for(var/datum/symptom/symptom as anything in subtypesof(/datum/symptom))
		if(initial(symptom.level) == 9)
			potential_guaranteed_symptoms += symptom
	extrapolator_diseases += new /datum/disease/advance/random(max_symptoms = rand(2, 5), max_level = 9, min_level = 1 + rand(1, 3), guaranteed_symptoms = pick(potential_guaranteed_symptoms), infected = src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/pet/hamster/vector/proc/on_entered(datum/source, M as mob)
	SIGNAL_HANDLER

	if(isliving(M) && !isnull(vector_disease) && prob(20))
		var/mob/living/L = M
		if(!L.HasDisease(vector_disease)) //I'm not actually sure if this check is needed, but better to be safe than sorry
			L.ContactContractDisease(vector_disease)
