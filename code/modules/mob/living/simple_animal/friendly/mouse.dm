/mob/living/simple_animal/mouse
	name = "mouse"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeak!","SQUEAK!","Squeak?")
	speak_emote = list("squeaks")
	speak_language = /datum/language/metalanguage
	emote_hear = list("squeaks.")
	emote_see = list("runs in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	faction = list(FACTION_RAT)
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	var/body_color //brown, gray and white, leave blank for random
	gold_core_spawnable = FRIENDLY_SPAWN
	var/chew_probability = 1
	chat_color = "#82AF84"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	/// A list of diseases carried by this rat.
	var/list/datum/disease/rat_diseases = list()

/mob/living/simple_animal/mouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/animal_variety, "mouse", pick("brown","gray","white"), FALSE)
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg' = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever
	if(prob(75))
		var/datum/disease/advance/dormant_disease = new /datum/disease/advance/random(rand(1, 6), 9, 1, infected = src) // Dormant desiese
		dormant_disease.dormant = TRUE
		dormant_disease.spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
		rat_diseases += dormant_disease
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.icon_dead = "mouse_[body_color]_splat"
	death()

/mob/living/simple_animal/mouse/death(gibbed, toast)
	if(!ckey)
		..(1)
		if(!gibbed)
			var/obj/item/food/deadmouse/M = new(loc)
			M.rat_diseases = rat_diseases
			M.icon_state = icon_dead
			M.name = name
			if(toast)
				M.add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
				M.desc = "It's toast."
		qdel(src)
	else
		..(gibbed)

/mob/living/simple_animal/mouse/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER

	if( ishuman(AM) )
		if(!stat)
			var/mob/M = AM
			to_chat(M, span_notice("[icon2html(src, M)] Squeak!"))

/mob/living/simple_animal/mouse/handle_automated_action()
	if(prob(chew_probability))
		var/turf/open/floor/F = get_turf(src)
		if(istype(F) && F.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				if(C.avail())
					visible_message(span_warning("[src] chews through the [C]. It's toast!"))
					playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
					C.deconstruct()
					death(toast=1)
				else
					C.deconstruct()
					visible_message(span_warning("[src] chews through the [C]."))

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	body_color = "white"
	icon_state = "mouse_white"
	held_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"
	held_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	gold_core_spawnable = NO_SPAWN

/obj/item/food/deadmouse
	name = "dead mouse"
	desc = "It looks like somebody dropped the bass on it. A lizard's favorite meal. May contain diseases."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray_dead"
	bite_consumption = 3
	eatverbs = list("devour")
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GORE | MEAT | RAW
	grind_results = list(
		/datum/reagent/blood = 20,
		/datum/reagent/liquidgibs = 5
	)
	decomp_req_handle = TRUE
	decomp_type = /obj/item/food/deadmouse/moldy
	var/list/datum/disease/rat_diseases = list()

/obj/item/food/deadmouse/moldy
	name = "moldy dead mouse"
	desc = "A dead rodent, consumed by mold and rot. There is a slim chance that a lizard might still eat it."
	icon_state = "mouse_gray_dead"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/mold = 10
	)
	foodtypes = GORE | MEAT | RAW | GROSS
	grind_results = list(
		/datum/reagent/blood = 20,
		/datum/reagent/liquidgibs = 5,
		/datum/reagent/consumable/mold = 10
	)
	preserved_food = TRUE


/obj/item/food/deadmouse/attackby(obj/item/I, mob/living/user, params)
	if(I.is_sharp() && user.combat_mode)
		if(isturf(loc))
			new /obj/item/food/meat/slab/mouse(loc)
			to_chat(user, span_notice("You butcher [src]."))
			qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a surface to butcher it!"))
	else
		return ..()

/obj/item/food/deadmouse/on_grind()
	reagents.clear_reagents()
