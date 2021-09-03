/mob/living/simple_animal/pet/resomi
	name = "resomi"
	desc = "Jesus fuck what is that?!"
	icon = 'icons/mob/animal.dmi'
	icon_state = "resomi"
	icon_living = "resomi"
	icon_dead = "resomi" //Shouldn't ever be dead.
	ventcrawler = VENTCRAWLER_ALWAYS
	initial_language_holder = /datum/language_holder/resomi
	speak = list("LIFE IS PAIN", "GOD WHY", "PLEASE END MY SUFFERING", "WHY DID GOD MAKE ME THIS WAY", "FUUUUUUUCK")
	emote_hear = list("chirps", "trills")
	emote_see = list("shakes.", "pants.")
	speak_chance = 1
	maxHealth = 5000
	health = 5000
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3)
	response_help = "pets"
	response_disarm = "violently shoves"
	response_harm = "curbstomps"
	can_be_held = FALSE
	do_footstep = TRUE
	chat_color = "#64ffdd"
	gold_core_spawnable = NO_SPAWN //No fun allowed

/mob/living/simple_animal/pet/resomi/retresi
	name = "Retresi"
	desc = "Retresi, a coder's favorite punching bag."
	gender = MALE
	speak = list("FRAN DID THIS ME", "THE PLANNEDEMIC IS A CONSPIRACY", "REBASE TO NEBULA", "BAYSTATION ISNT REAL", "COMBAT MODE SUCKS", "ITS NOT A FURSONA")
