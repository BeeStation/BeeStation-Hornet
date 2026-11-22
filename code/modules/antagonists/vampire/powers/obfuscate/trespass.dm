/datum/action/cooldown/vampire/targeted/trespass
	name = "Trespass"
	desc = "Become mist and advance two tiles in one direction. Useful for skipping past doors and barricades."
	button_icon_state = "power_tres"
	power_explanation = "Click anywhere from 1-2 tiles away from you to teleport.\n\
		This power goes through all obstacles except Walls.\n\
		Higher levels decrease the sound played from using the Power, and increase the speed of the transition."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 30
	cooldown_time = 8 SECONDS
	prefire_message = "Select a destination."
	//target_range = 2
	var/turf/target_turf // We need to decide where we're going based on where we clicked. It's not actually the tile we clicked.
	level_current = 1

/datum/action/cooldown/vampire/targeted/trespass/two
	level_current = 2
	vitaecost = 50

/datum/action/cooldown/vampire/targeted/trespass/three
	level_current = 3
	vitaecost = 70

/datum/action/cooldown/vampire/targeted/trespass/can_use()
	. = ..()
	if(!.)
		return FALSE

	if(HAS_TRAIT(owner, TRAIT_NO_TRANSFORM))
		return FALSE
	if(!get_turf(owner))
		return FALSE

/datum/action/cooldown/vampire/targeted/trespass/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Can't trespass to the same tile we're already on
	if(target_atom.loc == owner.loc)
		return FALSE
	// Check if path is obstructed
	var/turf/starting_turf = get_turf(owner)
	var/turf/ending_turf = isturf(target_atom) ? target_atom : get_turf(target_atom)
	var/this_dir
	for(var/i = 1 to 2)
		// Keep Prev Direction if we've reached final turf
		if(starting_turf != ending_turf)
			this_dir = get_dir(starting_turf, ending_turf)
		starting_turf = get_step(starting_turf, this_dir)
		// Walls block trespass
		if(iswallturf(starting_turf))
			var/wallwarning = (i == 1) ? "in the way" : "at your destination"
			owner.balloon_alert(owner, "There is a wall [wallwarning].")
			return FALSE

	target_turf = starting_turf

/datum/action/cooldown/vampire/targeted/trespass/FireTargetedPower(atom/target_atom)
	. = ..()

	// Find target turf, at or below Atom
	var/mob/living/carbon/user = owner
	var/turf/my_turf = get_turf(owner)

	user.visible_message(
		span_warning("[user]'s form dissipates into a cloud of mist!"),
		span_notice("You disspiate into formless mist."),
	)
	// Effect Origin
	var/sound_strength = max(40, 100 - level_current * 20)
	playsound(get_turf(owner), 'sound/magic/summon_karp.ogg', sound_strength, 1)
	var/datum/effect_system/steam_spread/vampire/puff = new /datum/effect_system/steam_spread()
	puff.set_up(3, 0, my_turf)
	puff.start()

	var/mist_delay = max(5, 20 - level_current * 2.5) // Level up and do this faster.

	// Freeze Me
	user.Stun(mist_delay, ignore_canstun = TRUE)
	user.density = FALSE
	var/invis_was = user.invisibility
	user.invisibility = INVISIBILITY_MAXIMUM

	// Wait...
	sleep(mist_delay / 2)
	// Move & Freeze
	if(isturf(target_turf))
		do_teleport(owner, target_turf, no_effects=TRUE, channel = TELEPORT_CHANNEL_QUANTUM) // in teleport.dm?
	user.Stun(mist_delay / 2, ignore_canstun = TRUE)

	// Wait...
	sleep(mist_delay / 2)
	// Un-Hide & Freeze
	user.dir = get_dir(my_turf, target_turf)
	user.Stun(mist_delay / 2, ignore_canstun = TRUE)
	user.density = 1
	user.invisibility = invis_was

	check_witnesses()
	// Effect Destination
	playsound(get_turf(owner), 'sound/magic/summon_karp.ogg', 60, 1)
	puff = new /datum/effect_system/steam_spread()
	puff.set_up(3, 0, target_turf)
	puff.start()
