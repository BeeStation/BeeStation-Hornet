/mob/living/simple_animal/hostile/ant
	name = "giant ant"
	desc = "A writhing mass of ants, glued together to make an adorable pet!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "ant"
	icon_living = "ant"
	icon_dead = "ant_dead"
	speak = list("BZZZZT!", "CHTCHTCHT!", "Bzzz", "ChtChtCht")
	speak_emote = list("buzzes", "chitters")
	emote_hear = list("buzzes.", "clacks.")
	emote_see = list("shakes their head.", "twitches their antennae.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	gender = PLURAL // We are Ven-ant
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	minbodytemp = 200
	maxbodytemp = 400
	melee_damage = 8
	obj_damage = 5
	attack_sound = 'sound/weapons/bite.ogg'
	butcher_results = list(/obj/effect/decal/cleanable/ants = 3) //It's just a bunch of ants glued together into a larger ant
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list("neutral")
	can_be_held = FALSE
	health = 100
	maxHealth = 100
	light_range = 1.5 // Bioluminescence!
	light_color = "#d43229" // The ants that comprise the giant ant still glow red despite the sludge.

