/mob/living/simple_animal/pet/dog/corgi/capybara
	name = "\improper capybara"
	real_name = "capybara"
	desc = "It's a capybara."
	icon_state = "capybara"
	icon_living = "capybara"
	icon_dead = "capybara"
	held_state = null
	butcher_results = list()
	childtype = list()

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

	animal_species = /mob/living/simple_animal/pet/dog

/mob/living/simple_animal/pet/dog/corgi/capybara/update_corgi_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("Bark!", "Squee!", "Squee.")
	speak_emote = list("barks", "squeaks")
	emote_hear = list("barks!", "squees!", "squeaks!", "yaps.", "squeaks.")
	emote_see = list("shakes its head.", "medidates on peace.", "looks to be in peace.", "shivers.")
	desc = initial(desc)
	set_light(0)

	if(inventory_head && inventory_head.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back && inventory_back.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)
