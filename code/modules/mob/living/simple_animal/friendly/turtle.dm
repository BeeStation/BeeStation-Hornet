/mob/living/simple_animal/pet/turtle
	name = "Frank"
	desc = "An adorable, slow moving Texas pal."
	icon = 'icons/mob/pets.dmi'
	icon_state = "yeeslow"
	icon_living = "yeeslow"
	icon_dead = "yeeslow_dead"
	speak_emote = list("yawns")
	emote_hear = list("snores.","yawns.")
	emote_see = list("Stretches out their neck.", "looks around slowly.")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 1)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	gold_core_spawnable = FRIENDLY_SPAWN
	melee_damage_lower = 18
	melee_damage_upper = 18
	health = 2500
	maxHealth = 2500
	speed = 10
	glide_size = 2
	can_be_held = TRUE

	do_footstep = TRUE
