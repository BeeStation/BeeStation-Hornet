/datum/antagonist/brother/prime
	name = "First-Born Brother"
	var/give_conversion_implant = TRUE
	/// Text word of the uplink unlock code
	var/uplink_note
	/// Location of the stash
	var/stash_location

/datum/antagonist/brother/prime/ui_static_data(mob/user)
	var/list/data = ..()
	data["uplink_note"] = uplink_note
	data["stash_location"] = stash_location
	if (length(team.members) == 1)
		data["valid_converts"] = list()
		for (var/datum/mind/mind in team.valid_converts)
			data["valid_converts"] += mind.name
	return data

/datum/antagonist/brother/prime/greet()
	to_chat(owner.current, span_alertsyndie("You are the First-Born Blood Brother."))
	to_chat(owner.current, "The Syndicate only accepts those that have proven themselves and can work with a team. Unlock your uplink and head to the directives tab, you may have special equipment available under the 'recruit' directive which you can redeem.<br><b>You can only convert those with a susceptible mind! View your antag info or uplink to see your targets.</b>")
	owner.announce_objectives()
	give_meeting_area()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Blood Brother",
		"Use the implant that you have been given to recruit one of your three targets to serve as your brother.")

/datum/antagonist/brother/prime/finalize_brother()
	// Do normal stuff
	..()
	// Give them the self-implant
	var/obj/item/implant/bloodbrother/I = new /obj/item/implant/bloodbrother()
	I.linked_team = team
	I.implant(owner.current, null, TRUE, TRUE)
	I.update_colour()
	// Link the implants of all team members, in case any team-members already exist for some reason
	for(var/datum/mind/M in team.members)
		var/obj/item/implant/bloodbrother/T = locate() in M.current.implants
		I.link_implant(T)
	// Give them the conversion implant
	var/obj/item/implanter/bloodbrother/implanter = new /obj/item/implanter/bloodbrother(null, team)
	stash_location = generate_stash(list(
		implanter
	), list(owner), team)
	// Give them the uplink
	var/datum/mind/uplink_owner = pick(team.members)
	// Starts with a forced directive to recruit a brother
	var/datum/component/uplink/granted_uplink = uplink_owner.equip_standard_uplink(uplink_owner = src, telecrystals = 0, directive_flags = NONE)
	uplink_note = granted_uplink.unlock_text
	granted_uplink.reputation = 0
	// Makes it hard for blood brothers to be a significant force in the round
	granted_uplink.directive_tc_multiplier = 0.5
	generate_conversions(granted_uplink, implanter)

/datum/antagonist/brother/prime/proc/generate_conversions(datum/component/uplink/uplink, obj/item/implanter/bloodbrother/implanter)
	var/list/options = team.get_conversion_targets()
	// Failure states
	if (!length(options))
		uplink.directive_flags = BROTHER_DIRECTIVE_FLAGS
		// Get an assassination objective instead
		var/datum/priority_directive/assassination/selected = new /datum/priority_directive/assassination()
		if (!selected.can_run(list(uplink), SSticker.minds))
			// If the assassination objective doesn't work, directly get the reward
			uplink.telecrystals += 4
			uplink.reputation += 300
			send_uplink_message_to(uplink, "Recruitment probing has shown this station has a higher resilience to outside influence than we initially imagined, change of plans; some telecrystals have been injected into your uplink for you to spend.")
			return
		// Run the assassination directive
		selected.start(list(uplink))
		selected.reputation_reward = 300
		selected.tc_reward = 4 / uplink.directive_tc_multiplier
		SSdirectives.active_directives += selected
		send_uplink_message_to(uplink, "Recruitment probing has shown this station has a higher resilience to outside influence than we initially imagined, change of plans; you are going to have to do this alone. We've given you a mission that should help you to get started.")
		return
	// When people join, complete the team if possible
	team.listen_for_joiners()
	// Give the list of people that we can convert
	for (var/i in 1 to min(3, length(options)))
		team.add_valid_conversion(pick_n_take(options))
	// Give the directive
	give_directive(uplink, implanter)

/datum/antagonist/brother/prime/proc/give_directive(datum/component/uplink/uplink, obj/item/implanter/bloodbrother/implanter, list/conversion_targets)
	var/datum/priority_directive/recruit/selected = new /datum/priority_directive/recruit()
	selected.track_implanter(implanter)
	selected.update_details()
	selected.add_antagonist_team(list(uplink))
	selected.start(list(uplink))
	selected.reputation_reward = 300
	selected.tc_reward = 8
	SSdirectives.active_directives += selected

/datum/antagonist/brother/prime/no_conversion
	give_conversion_implant = FALSE
