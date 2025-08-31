/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	//description = "All crewmembers start to hallucinate the same thing."
	typepath = /datum/round_event/mass_hallucination
	weight = 10
	max_occurrences = 2
	min_players = 1
	//category = EVENT_CATEGORY_HEALTH

	/// For admins, what hallucination did we pick
	var/admin_forced_hallucination
	/// For admins, what arguments are we passing to said hallucination
	var/list/admin_forced_args

/datum/round_event_control/mass_hallucination/admin_setup(mob/admin)
	if(!check_rights(R_FUN))
		return ADMIN_CANCEL_EVENT

	var/force = tgui_alert(usr, "Do you want to force a hallucination?", name, list("Yes", "No", "Cancel"))
	if(force == "Cancel")
		return ADMIN_CANCEL_EVENT
	if(force != "Yes")
		return

	var/force_what = tgui_alert(usr, "Generic hallucination or Custom configured delusion? (Delusions are those which make people appear as other mobs)", name, list("Hallucination", "Custom Delusion", "Cancel"))
	switch(force_what)
		if("Cancel")
			return ADMIN_CANCEL_EVENT

		if("Hallucination")
			var/chosen = select_hallucination_type(admin, "What hallucination should be forced for [name]?", name)
			if(!chosen || !check_rights(R_FUN))
				return ADMIN_CANCEL_EVENT

			admin_forced_hallucination = chosen

		if("Custom Delusion")
			var/list/chosen_args = create_delusion(admin)
			if(!length(chosen_args) || !check_rights(R_FUN))
				return ADMIN_CANCEL_EVENT

			admin_forced_hallucination = chosen_args[1]
			admin_forced_args = chosen_args.Copy(3)

/datum/round_event/mass_hallucination
	fakeable = FALSE

/datum/round_event/mass_hallucination/start()
	var/datum/round_event_control/mass_hallucination/our_controller = control

	var/picked_hallucination = our_controller?.admin_forced_hallucination
	var/list/other_args = our_controller?.admin_forced_args

	if(!picked_hallucination)
		var/category_to_pick_from = rand(1, 10)
		switch(category_to_pick_from)
			if(1)
				// Send the same sound to everyone
				picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/fake_sound/normal)

			if(2)
				// Send the same sound to everyone, but weird
				picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/fake_sound/weird)

			if(3)
				// Send the same message to everyone
				picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/station_message)

			if(4)
				// Send the same delusion to everyone, but...
				picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset)
				// The delusion will affect everyone BUT the hallucinator.
				other_args = list(
					duration = 30 SECONDS,
					skip_nearby = FALSE,
					affects_us = FALSE,
					affects_others = TRUE,
					play_wabbajack = FALSE,
				)

			if(5)
				// Send the same delusion to everyone, but...
				picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset)
				// The delusion will affect only the hallucinator.
				other_args = list(
					duration = 45 SECONDS,
					skip_nearby = FALSE,
					affects_us = TRUE,
					affects_others = FALSE,
					play_wabbajack = TRUE,
				)

			if(6 to 10)
				// Send the same generic hallucination type to everyone
				var/static/list/generic_hallucinations = list(
					/datum/hallucination/bolts,
					/datum/hallucination/chat,
					/datum/hallucination/death,
					/datum/hallucination/fake_flood,
					/datum/hallucination/fire,
					/datum/hallucination/message,
					/datum/hallucination/oh_yeah,
					/datum/hallucination/xeno_attack,
				)

				picked_hallucination = pick(generic_hallucinations)

		if(!picked_hallucination)
			CRASH("[type] couldn't find a hallucination to play. (Got: [picked_hallucination], Picked category: [category_to_pick_from])")

	var/list/hallucination_args = list(picked_hallucination, "mass hallucination")
	if(islist(other_args))
		hallucination_args += other_args

	// We'll only hallucinate for carbons now, even though livings can hallucinate just fine in most cases.
	for(var/mob/living/carbon/hallucinating as anything in GLOB.carbon_list)
		// If they're on centcom, skip them entirely.
		if(is_centcom_level(hallucinating.z))
			continue
		// We can skip dead carbons as well
		if(hallucinating.stat == DEAD)
			continue
		// Hallucinations can have side effects on mobs, like being stunned,
		// so we'll play the hallucination to clientless mobs as well.
		// Unless the mob is off the station z-level. It's unlikely anyone will notice.
		if(hallucinating.z != 0 && !is_station_level(hallucinating.z) && !hallucinating.client)
			continue

		// Not using the wrapper here because we already have a list / arglist
		hallucinating._cause_hallucination(hallucination_args)

/datum/round_event/mass_hallucination/end()
	var/datum/round_event_control/mass_hallucination/our_controller = control
	our_controller.admin_forced_hallucination = null
	our_controller.admin_forced_args = null
