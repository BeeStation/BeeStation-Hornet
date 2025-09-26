/*
Slimecrossing Mobs
	Mobs and effects added by the slimecrossing system.
	Collected here for clarity.
*/

/// Slime transformation power - from Burning Black
/datum/action/spell/shapeshift/slime_form
	name = "Slime Transformation"
	desc = "Transform from a human to a slime, or back again!"
	button_icon_state = "transformslime"
	cooldown_time = 0 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	convert_damage = TRUE
	convert_damage_type = CLONE
	possible_shapes = list(/mob/living/simple_animal/slime/transformed_slime)

	/// If TRUE, we self-delete (remove ourselves) the next time we turn back into a human
	var/remove_on_restore = FALSE

/datum/action/spell/shapeshift/slime_form/do_unshapeshift(mob/living/caster)
	. = ..()
	if(!.)
		return

	if(remove_on_restore)
		qdel(src)

/// Transformed slime - from Burning Black
/mob/living/simple_animal/slime/transformed_slime

// Just in case.
/mob/living/simple_animal/slime/transformed_slime/Reproduce()
	to_chat(src, span_warning("I can't reproduce..."))
	return

/// Slime Transformation Power, but turns you into an oozeling. Gained from Transformative Green
/datum/action/spell/oozeling_evolve
	name = "Oozeling Evolution"
	desc = "Transforms you into an oozeling, from your slime form. A one-way trip."
	button_icon_state = "transformslime"
	cooldown_time = 0 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_MIND

//i think i hate this proc. abandon all hope ye who refactor here.
/datum/action/spell/oozeling_evolve/on_cast(mob/living/user)
	..()
	var/mob/living/simple_animal/slime/evolver = owner
	var/colour = evolver.colour
	var/ooze_colour = null
	switch((colour))
		if(SLIME_TYPE_ORANGE)
			ooze_colour = "FFA500"
		if(SLIME_TYPE_PURPLE)
			ooze_colour = "B19CD9"
		if(SLIME_TYPE_BLUE)
			ooze_colour = "ADD8E6"
		if(SLIME_TYPE_METAL)
			ooze_colour = "7E7E7E"
		if(SLIME_TYPE_YELLOW)
			ooze_colour = "FFFF00"
		if(SLIME_TYPE_DARK_PURPLE)
			ooze_colour = "551A8B"
		if(SLIME_TYPE_DARK_BLUE)
			ooze_colour = "0000FF"
		if(SLIME_TYPE_SILVER)
			ooze_colour = "D3D3D3"
		if(SLIME_TYPE_BLUESPACE)
			ooze_colour = "32CD32"
		if(SLIME_TYPE_SEPIA)
			ooze_colour = "704214"
		if(SLIME_TYPE_CERULEAN)
			ooze_colour = "2956B2"
		if(SLIME_TYPE_PYRITE)
			ooze_colour = "#AFAD2"
		if(SLIME_TYPE_RED)
			ooze_colour = "FF0000"
		if(SLIME_TYPE_GREEN)
			ooze_colour = "00FF00"
		if(SLIME_TYPE_PINK)
			ooze_colour = "FF69B4"
		if(SLIME_TYPE_GOLD)
			ooze_colour = "FFD700"
		if(SLIME_TYPE_OIL)
			ooze_colour = "505050"
		if(SLIME_TYPE_BLACK)
			ooze_colour = "000000"
		if(SLIME_TYPE_LIGHT_PINK)
			ooze_colour = "FFB6C1"
		if(SLIME_TYPE_ADAMANTINE)
			ooze_colour = "008b8b"
		if(SLIME_TYPE_GREY)
			ooze_colour = "FFFFFF"
	var/mob/living/carbon/human/species/oozeling/new_ooze = new(owner.loc)
	new_ooze.dna.features["mcolor"] = ooze_colour
	new_ooze.name = owner.name
	new_ooze.real_name = owner.real_name
	new_ooze.underwear = "Nude"
	new_ooze.undershirt = "Nude"
	new_ooze.socks = "Nude"
	new_ooze.updateappearance(mutcolor_update = 1)
	if(owner.mind)
		owner.mind.transfer_to(new_ooze)
	qdel(evolver)
	qdel(src)

//Slime corgi - Chilling Pink
/mob/living/basic/pet/dog/corgi/puppy/slime
	name = "\improper slime corgi puppy"
	real_name = "slime corgi puppy"
	desc = "An unbearably cute pink slime corgi puppy."
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	can_be_shaved = FALSE
	gold_core_spawnable = NO_SPAWN
	speak_emote = list("blorbles", "bubbles", "borks")

/mob/living/basic/pet/dog/corgi/puppy/slime/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.emote_hear = string_list(list("bubbles!", "splorts.", "splops!"))
	speech.emote_see = string_list(list("gets goop everywhere.", "flops.", "jiggles!"))
