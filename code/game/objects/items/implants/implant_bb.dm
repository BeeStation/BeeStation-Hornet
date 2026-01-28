/obj/item/implant/bloodbrother
	name = "communication implant"
	desc = "Use this to communicate with your fellow blood brother(s)."
	icon = 'icons/obj/radio.dmi'
	icon_state = "headset"
	/// BB implant colour is different per team, and is set by brother antag datum
	var/span_implant_colour = "cfc_redpurple"
	/// All other implants that this communicates to
	var/list/linked_implants
	/// If implanted into someone who isn't a blood brother, this will convert them to the team
	var/datum/team/brother_team/linked_team

/obj/item/implant/bloodbrother/Initialize(mapload)
	. = ..()
	linked_implants = list()

/obj/item/implant/bloodbrother/can_be_implanted_in(mob/living/target)
	return target.mind && (target.mind in linked_team.valid_converts)

/obj/item/implant/bloodbrother/on_implanted(mob/living/user)
	. = ..()
	if (!user.mind)
		return
	// Determine if we have the antag datum
	for (var/datum/antagonist/brother/brother in user.mind.antag_datums)
		if (brother.get_team() == linked_team)
			return
	var/datum/dynamic_ruleset/ruleset_origin = null
	// Link to all implants
	for(var/datum/mind/M in linked_team.members) // Link the implants of all team members
		var/obj/item/implant/bloodbrother/T = locate() in M.current.implants
		link_implant(T)
		var/datum/antagonist/brother/brother_antag_datum = M.has_antag_datum(/datum/antagonist/brother)
		if (!ruleset_origin && brother_antag_datum)
			ruleset_origin = brother_antag_datum.spawning_ruleset
	// Remove mindshields
	for(var/obj/item/implant/mindshield/mindshield in user.implants)
		qdel(mindshield)
	// Become a blood brother
	user.mind.add_antag_datum(/datum/antagonist/brother, linked_team, ruleset_origin)
	linked_team.update_name()
	log_objective("[key_name(user)] was made into a blood brother via implanting.")

/obj/item/implant/bloodbrother/activate()
	. = ..()
	if(linked_implants.len)
		var/input = stripped_input(imp_in, "Enter a message to communicate to your blood brother(s).", "Radio Implant", "")
		if(!input || imp_in.stat == DEAD)
			return
		if(CHAT_FILTER_CHECK(input))
			to_chat(imp_in, span_warning("The message contains prohibited words!"))
			return
		input = imp_in.treat_message_min(input)

		var/my_message = "<span class='[span_implant_colour]'><b><i>[imp_in.mind.name]:</i></b></span> [input]" //add sender, color source with syndie color
		var/ghost_message = "<span class='[span_implant_colour]'><b><i>[imp_in.mind.name] -> Blood Brothers:</i></b></span> [input]"
		// Reminder: putting a font color directly is bad because color has different readability by your chat theme white/dark
		// This should be eventually changed to a form of `<span class="red">`, so that a color has a good readability for a chat theme.

		to_chat(imp_in, my_message) // Sends message to the user
		for(var/obj/item/implant/bloodbrother/i in linked_implants) // Sends message to all linked implnats
			var/M = i.imp_in
			to_chat(M, my_message)
		for(var/M in GLOB.dead_mob_list) // Sends message to ghosts
			var/link = FOLLOW_LINK(M, imp_in)
			to_chat(M, "[link] [ghost_message]")

		imp_in.log_talk(input, LOG_SAY, tag="Blood Brother Implant")
	else
		to_chat(imp_in, span_bold("There are no linked implants!"))

/obj/item/implant/bloodbrother/removed(mob/living/source, silent, destroyed)
	. = ..()
	// If we were deleted through destruction (and not surgery) then do nothing
	if (destroyed)
		return
	if (!source.mind)
		qdel(src)
		return
	// Check to see if we can remove the implant
	for (var/datum/antagonist/brother/brother in source.mind.antag_datums)
		if (brother.get_team() == linked_team)
			// Implant removal resisted
			if (istype(brother, /datum/antagonist/brother/prime))
				source.visible_message(span_warning("[source] seems to resist the implant!"), span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
				qdel(src)
				return
			// Non-prime brothers can return to their original self
			// This is because important roles like sec CAN be converted.
			source.mind.remove_antag_datum(brother)
			return
	// If we did not remove an antag datum, destroy the implant
	qdel(src)

/obj/item/implant/bloodbrother/Destroy()
	. = ..()
	for(var/obj/item/implant/bloodbrother/i in linked_implants) // Removes this implant from the list of implants
		i.linked_implants -= src
	QDEL_NULL(linked_implants)

/obj/item/implant/bloodbrother/proc/link_implant(obj/item/implant/bloodbrother/BB)
	if(BB)
		if(BB == src) // Don't want to put this implant into itself
			return
		linked_implants |= BB
		BB.linked_implants |= src

/obj/item/implant/bloodbrother/proc/update_colour()
	if(linked_team.team_id <= length(GLOB.color_list_blood_brothers))
		span_implant_colour = GLOB.color_list_blood_brothers[linked_team.team_id]
	else
		span_implant_colour = "cfc_redpurple"
		stack_trace("Blood brother teams exist more than [length(GLOB.color_list_blood_brothers)] teams, and colour preset is ran out")

/obj/item/implant/bloodbrother/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Donk Corp(tm) Initiate Communication Implant<BR>
				<b>Life:</b> Indefinite.<BR>
				<b>Important Notes: <font color='red'>Illegal</font></B><BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small, directly linked radio device along with a small speaker and microphone. Allows communication between two similar implants.<BR>"}
	return dat

/obj/item/implanter/bloodbrother
	name = "implanter (communication)"
	imp_type = /obj/item/implant/bloodbrother

/obj/item/implanter/bloodbrother/Initialize(mapload, datum/team/brother_team)
	. = ..()
	if (brother_team)
		var/obj/item/implant/bloodbrother/implant = imp
		implant.linked_team = brother_team
		implant.update_colour()
