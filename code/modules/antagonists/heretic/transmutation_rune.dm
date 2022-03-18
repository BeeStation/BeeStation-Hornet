/obj/effect/heretic_rune
	name = "Generic rune"
	desc = "A flowing circle of shapes and runes is etched into the floor, filled with a thick black tar-like fluid."
	anchored = TRUE
	icon_state = ""
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	///Used mainly for summoning ritual to prevent spamming the rune to create millions of monsters.
	var/is_in_use = FALSE

/obj/effect/heretic_rune/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "heretic_rune", silicon_image)

/obj/effect/heretic_rune/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += "<span class='notice'>Allows you to transmute objects by invoking the rune after collecting the prerequisites overhead.</span>"
	. += "<span class='notice'>You can use your <i>Mansus Grasp</i> on the rune to remove it.</span>"

/obj/effect/heretic_rune/can_interact(mob/living/user)
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC(user))
		return FALSE
	if(is_in_use)
		return FALSE
	return TRUE

/obj/effect/heretic_rune/interact(mob/living/user)
	. = ..()
	INVOKE_ASYNC(src, .proc/try_rituals, user)
	return TRUE

/**
 * Wrapper for do_rituals to ensure is_in_use
 * is enabled and disabled before and after.
 */
/obj/effect/heretic_rune/proc/try_rituals(mob/living/user)
	is_in_use = TRUE

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	do_rituals(user, flatten_list(heretic_datum.researched_knowledge))

	is_in_use = FALSE

/**
 * Attempt to invoke a ritual from the past list of knowledges.
 *
 * Arguments
 * * user - the heretic / the person who invoked the rune
 * * knowledge_list - a non-assoc list of heretic_knowledge datums.
 *
 * returns TRUE if any rituals passed succeeded, FALSE if they all failed.
 */
/obj/effect/heretic_rune/proc/do_rituals(mob/living/user, list/knowledge_list)
	if(!length(knowledge_list))
		CRASH("[type] do_rituals called without any passed knowledge!")

	var/list/atom/movable/atoms_in_range = list()

	for(var/atom/close_atom as anything in range(1, src))
		if(!ismovable(close_atom))
			continue
		if(close_atom.invisibility)
			continue
		if(close_atom == user)
			continue

		atoms_in_range += close_atom

	for(var/datum/heretic_knowledge/knowledge as anything in knowledge_list)

		// It's not a ritual, we don't care.
		if(!LAZYLEN(knowledge.required_atoms))
			continue

		// A copy of our requirements list.
		// We decrement the values of to determine if enough of each key is present.
		var/list/requirements_list = knowledge.required_atoms.Copy()
		// A list of all atoms we've selected to use in this recipe.
		var/list/selected_atoms = list()

		// Do the snowflake check to see if we can continue or not.
		// selected_atoms is passed and can be modified by this proc.
		if(!knowledge.recipe_snowflake_check(user, atoms_in_range, selected_atoms, loc))
			continue

		// Now go through all our nearby atoms and see which are good for our ritual.
		for(var/atom/nearby_atom as anything in atoms_in_range)
			// Go through all of our required atoms
			for(var/req_type in requirements_list)
				// We already have enough of this type, skip
				if(requirements_list[req_type] <= 0)
					continue
				if(!istype(nearby_atom, req_type))
					continue

				// This item is a valid type.
				// Add it to our selected atoms list
				// and decrement the value of our requirements list
				selected_atoms |= nearby_atom
				requirements_list[req_type]--

		// All of the atoms have been checked, let's see if the ritual was successful
		var/requirements_fulfilled = TRUE
		for(var/req_type in requirements_list)
			if(requirements_list[req_type] <= 0)
				continue

			// One if our requirements wasn't entirely filled
			// This ritual failed, move on to the next one
			requirements_fulfilled = FALSE
			break

		if(!requirements_fulfilled)
			continue

		// If we made it here, the ritual succeeded
		// Do the animations and feedback
		flick("[icon_state]_active", src)
		playsound(user, 'sound/magic/castsummon.ogg', 75, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)

		// We temporarily make all of our chosen atoms invisible,
		// as some rituals may sleep, and we don't want people
		// to be able to run off with ritual items.
		for(var/atom/to_disappear as anything in selected_atoms)
			to_disappear.invisibility = INVISIBILITY_ABSTRACT

		// on_finished_recipe may sleep in the case of some rituals like summons.
		if(knowledge.on_finished_recipe(user, selected_atoms, loc))
			knowledge.cleanup_atoms(selected_atoms)

		// Re-appear anything left in the list
		for(var/atom/to_appear as anything in selected_atoms)
			to_appear.invisibility = initial(to_appear.invisibility)

		loc.balloon_alert(user, "ritual complete")
		return TRUE

	loc.balloon_alert(user, "ritual failed!")
	return FALSE

/obj/effect/heretic_rune/big
	name = "transmutation rune"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "eldritch_rune1"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
