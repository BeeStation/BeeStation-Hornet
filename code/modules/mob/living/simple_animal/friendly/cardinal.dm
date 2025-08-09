/mob/living/simple_animal/cardinal
	name = "cardinal"
	desc = "A cardinal!"
	icon_state = "cardinal"
	icon_living = "cardinal"
	icon_dead = "cardinal_dead"
	turns_per_move = 10
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	friendly_verb_continuous = "nudges"
	friendly_verb_simple = "nudge"
	held_state = "cardinal"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("Chirp.","Chirp?","Squawk.","Squawk!")
	speak_emote = list("Chirps")
	speak_language = /datum/language/metalanguage
	emote_hear = list("chirps.")
	emote_see = list("pecks at the ground.","flaps its wings.")
	speak_chance = 2
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	mob_size = MOB_SIZE_SMALL
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab = 1)

