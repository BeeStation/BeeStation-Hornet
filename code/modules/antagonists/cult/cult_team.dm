/datum/team/cult
	name = "Bloodcult"

	///Blood mark target
	var/atom/blood_target
	///Image of the blood mark target
	var/image/blood_target_image
	///Timer for the blood mark to expire
	var/blood_target_reset_timer

	///Has a vote been called for a leader?
	var/cult_vote_called = FALSE
	///The antag datum of the cult's leader, if one has been elected.
	var/datum/antagonist/cult/cult_leader_datum
	///Has the mass teleport been used yet?
	var/reckoning_complete = FALSE
	///Has the cult risen, and gotten red eyes?
	var/cult_risen = FALSE
	///Has the cult ascended, and gotten halos?
	var/cult_ascendent = FALSE
	/// Everyone that joined the cult via convertion, doesn't matter if they got deconverted
	var/list/ever_members = list()

/datum/team/cult/add_member(datum/mind/new_member)
	. = ..()
	ever_members |= new_member

/datum/team/cult/proc/is_sacrifice_target(datum/mind/mind)
	for(var/datum/objective/sacrifice/sac_objective in objectives)
		if(mind == sac_objective.target)
			return TRUE
	return FALSE

/// Sets a blood target for the cult.
/datum/team/cult/proc/set_blood_target(atom/new_target, mob/marker, duration = 90 SECONDS)
	if(QDELETED(new_target))
		CRASH("A null or invalid target was passed to set_blood_target.")

	if(blood_target_reset_timer)
		return FALSE

	blood_target = new_target
	RegisterSignal(blood_target, COMSIG_QDELETING, PROC_REF(unset_blood_target_and_timer))
	var/area/target_area = get_area(new_target)

	blood_target_image = image('icons/effects/mouse_pointers/cult_target.dmi', new_target, "glow", ABOVE_MOB_LAYER)
	blood_target_image.appearance_flags = RESET_COLOR
	blood_target_image.pixel_x = -new_target.pixel_x
	blood_target_image.pixel_y = -new_target.pixel_y

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		to_chat(cultist.current, span_bold(span_cultlarge("[marker] has marked [blood_target] in the [target_area.name] as the cult's top priority, get there immediately!")))
		cultist.current.playsound_local(null, pick('sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg'), 100)
		cultist.current.client.images += blood_target_image

	blood_target_reset_timer = addtimer(CALLBACK(src, PROC_REF(unset_blood_target)), duration, TIMER_STOPPABLE)
	return TRUE

/// Unsets out blood target, clearing the images from all the cultists.
/datum/team/cult/proc/unset_blood_target()
	blood_target_reset_timer = null

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		if(QDELETED(blood_target))
			to_chat(cultist.current, span_bold(span_cultlarge("The blood mark's target is lost!")))
		else
			to_chat(cultist.current, span_bold(span_cultlarge("The blood mark has expired!")))
		cultist.current.client.images -= blood_target_image

	UnregisterSignal(blood_target, COMSIG_QDELETING)
	blood_target = null

	QDEL_NULL(blood_target_image)

/// Unsets our blood target when they get deleted.
/datum/team/cult/proc/unset_blood_target_and_timer(datum/source)
	SIGNAL_HANDLER

	deltimer(blood_target_reset_timer)
	unset_blood_target()

/datum/team/cult/proc/check_size()
	if(cult_ascendent)
		return
	var/alive = 0
	var/cultplayers = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			if(IS_CULTIST(M))
				++cultplayers
			else
				++alive
	ASSERT(cultplayers) //we shouldn't be here.
	var/ratio = alive ? cultplayers/alive : 1
	if(ratio > CULT_RISEN && !cult_risen)
		for(var/datum/mind/mind as anything in members)
			if(mind.current)
				mind.current.playsound_local(null, 'sound/effects/antag/bloodcult/bloodcult_eyes.ogg', 100)
				to_chat(mind.current, span_cultlarge(span_warning("The veil weakens as your cult grows, your eyes begin to glow...")))
				log_game("The blood cult was given red eyes at cult population of [cultplayers].")
				mind.current.AddElement(/datum/element/cult_eyes)
		cult_risen = TRUE
		log_game("The blood cult has risen with [cultplayers] players.")

	if(ratio > CULT_ASCENDENT && !cult_ascendent)
		for(var/datum/mind/mind as anything in members)
			if(mind.current)
				mind.current.playsound_local(null, 'sound/effects/antag/bloodcult/bloodcult_halos.ogg', 100)
				to_chat(mind.current, span_cultlarge(span_warning("Your cult is ascendent and the red harvest approaches - you cannot hide your true nature for much longer!!")))
				log_game("The blood cult was given halos at cult population of [cultplayers].")
				mind.current.AddElement(/datum/element/cult_halo)
		cult_ascendent = TRUE
		log_game("The blood cult has ascended with [cultplayers] players.")

/datum/team/cult/proc/setup_objectives()
	add_objective(new /datum/objective/sacrifice(), find_target = TRUE)
	add_objective(new /datum/objective/eldergod())

/datum/team/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			return FALSE
	return TRUE

/datum/team/cult/roundend_report()
	var/list/parts = list()

	if(check_cult_victory())
		parts += span_greentextbig("The cult has succeeded! Nar'Sie has snuffed out another torch in the void!")
	else
		parts += span_redtextbig("The staff managed to stop the cult! Dark words and heresy are no match for Nanotrasen's finest!")

	if(objectives.len)
		parts += "<b>The cultists' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			parts += "<b>Objective #[count]</b>: [objective.get_completion_message()]"
			count++

	if(length(ever_members))
		parts += span_header("The cultists were:")
		var/list/cultist_lines = list("<ul class='playerlist'>")
		for(var/datum/mind/cultist as anything in ever_members)
			//Anyone still in ever_members but no longer in members was cleansed of the faith at some point.
			var/status_override = (cultist in members) ? null : span_bluetext("was deconverted")
			cultist_lines += "<li>[printplayer(cultist, status_override = status_override)]</li>"
		cultist_lines += "</ul>"
		parts += cultist_lines.Join()
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
