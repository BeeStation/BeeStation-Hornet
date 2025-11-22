SUBSYSTEM_DEF(society)
	name = "Vampire Society"
	wait = 5 MINUTES	// For some reason this actually fires at HALF this time.
	flags = SS_NO_INIT | SS_BACKGROUND | SS_TICKER
	can_fire = FALSE

	// Are we currently polling?
	var/currently_polling = FALSE

	// Ref to the prince datum
	var/datum/weakref/princedatum

/datum/controller/subsystem/society/fire(resumed = FALSE)
	var/time_elapsed = world.time - SSticker.round_start_time

	// Don't ask them before at least some time has passed from round start. Give them some time to acclimatize.
	// Make sure this is at least one minute shorter than the wait time.
	if (time_elapsed < 4 MINUTES)
		return

	if(!princedatum && !currently_polling)
		poll_for_prince()

/datum/controller/subsystem/society/proc/poll_for_prince()
	//Build a list of mobs in GLOB.all_vampires
	var/list/vampire_living_candidates = list()

	for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
		var/currentmob = vampire.owner?.current

		if(!isliving(currentmob)) //Are we mob/living?
			continue

		var/mob/living/livingmob = currentmob
		if(livingmob.stat != CONSCIOUS) // Are we alive?
			continue

		message_admins("[vampire.owner?.current?.client?.get_exp_living(TRUE)]")

		vampire_living_candidates += currentmob

		to_chat(vampire.owner.current, span_announce("* Vampire Tip: Polite kindred society is almost always governed by a powerful Prince. A Prince enforces order and preserves the masquerade. Read up on vampire society in your info panel."))

	currently_polling = TRUE
	var/list/pollers = SSpolling.poll_candidates(
		question = "You are eligible for princedom.",
		poll_time = 2 MINUTES,
		flash_window = TRUE,
		group = vampire_living_candidates,
		role_name_text = "Prince",
		amount_to_pick = length(GLOB.all_vampires),
		announce_chosen = FALSE,
		custom_response_messages = list(
			POLL_RESPONSE_SIGNUP = "You have made your bid for princedom. <br>* Note: Princedom has certain expectations placed upon you. If you are not in a position to enforce the masquerade, consider letting someone else take this burden.",
			POLL_RESPONSE_UNREGISTERED = "You have removed your bid to princedom."
		)
		)
	currently_polling = FALSE

	var/datum/antagonist/vampire/chosen_datum
	var/mob/living/chosen_candidate

	// We have to do this shit because the polling proc doesn't always return a list. Sometimes it just returns a mob.
	var/list/candidates = list()
	candidates += pollers

	for(var/mob/living/current_candidate in candidates) // Pick the ideal one from the list.
		var/datum/antagonist/vampire/current_datum = IS_VAMPIRE(current_candidate)

		if(!chosen_candidate)	// If we are the first in line, just be the prince by default
			chosen_candidate = current_candidate
			chosen_datum = IS_VAMPIRE(current_candidate)
			continue

		if(current_datum.get_princely_score() >= chosen_datum.get_princely_score())
			chosen_candidate = current_candidate
			chosen_datum = IS_VAMPIRE(current_candidate)

	if(chosen_datum)
		chosen_datum.princify()
		princedatum = WEAKREF(chosen_datum)
		for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
			to_chat(vampire.owner.current, span_narsiesmall("[chosen_datum.owner.current] has claimed the role of Prince!"))
