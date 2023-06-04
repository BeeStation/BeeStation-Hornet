/mob/living/simple_animal/mothroach
	name = "mothroach"
	desc = "An ancient ancestor of the moth that surprisingly looks like the crossbreed of a moth and a cockroach."
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	held_state = "mothroach"
	held_lh = 'icons/mob/pets_held_lh.dmi'
	held_rh = 'icons/mob/pets_held_rh.dmi'
	head_icon = 'icons/mob/pets_held.dmi'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/mothroach = 3, /obj/item/stack/sheet/animalhide/mothroach = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	density = TRUE
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	mob_size = MOB_SIZE_SMALL
	health = 5
	maxHealth = 5
	speed = 1.25
	mobility_flags = MOBILITY_FLAGS_DEFAULT
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	ventcrawler = VENTCRAWLER_ALWAYS

	verb_say = "flutters"
	verb_ask = "flutters inquisitively"
	verb_exclaim = "flutters loudly"
	verb_yell = "flutters loudly"
	response_help = "pets"
	speak_emote = list("flutters")
	emote_hear = list("flutters.")
	speak_chance = 1
	attacked_sound = 'sound/voice/moth/scream_moth.ogg'

	faction = list("neutral")

/mob/living/simple_animal/mothroach/update_resting()
	. = ..()
	if(resting)
		icon_state = "mothroach_rest"
	else
		icon_state = "mothroach"
