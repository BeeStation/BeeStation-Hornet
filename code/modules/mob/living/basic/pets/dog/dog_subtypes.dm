//Less exciting dog breeds

/mob/living/basic/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "They're a pug."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/food/meat/slab/pug = 3)
	cult_icon_state = "pug_cult"
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "pug"
	held_state = "pug"

/mob/living/basic/pet/dog/pug/mcgriff
	name = "McGriff"
	desc = "This dog can tell something smells around here, and that something is CRIME!"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier
	name = "\improper bull terrier"
	real_name = "bull terrier"
	desc = "They're a bull terrier."
	icon = 'icons/mob/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3) // Would feel redundant to add more new dog meats.
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "bullterrier"
	held_state = "bullterrier"

/mob/living/basic/pet/dog/bullterrier/tyson
	name = "Tyson"
	real_name = "Tyson"
	gender = MALE
	desc = "A sturdy bullterrier with a friendly but watchful demeanor. His intelligent eyes belies his trustworthiness, despite what a goofy face and frame might suggest."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/corgi/capybara
	name = "\improper capybara"
	real_name = "capybara"
	desc = "It's a capybara."
	icon_state = "capybara"
	icon_living = "capybara"
	icon_dead = "capybara_dead"
	held_state = null
	can_be_held = FALSE
	butcher_results = list()

/mob/living/basic/pet/dog/corgi/capybara/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("Bark!", "Squee!", "Squee."))
	speech.emote_hear = string_list(list("barks!", "squees!", "squeaks!", "yaps.", "squeaks."))
	speech.emote_see = string_list(list("shakes its head.", "medidates on peace.", "looks to be in peace.", "shivers."))
