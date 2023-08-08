/datum/brain_trauma/special/obsessed
	name = "Psychotic Schizophrenia"
	desc = "Patient has a subtype of delusional disorder, becoming irrationally attached to someone."
	scan_desc = "psychotic schizophrenic delusions"
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = "<span class='warning'>The voices in your head fall silent.</span>"
	can_gain = TRUE
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM | TRAUMA_SPECIAL_CURE_PROOF
	resilience = TRAUMA_RESILIENCE_SURGERY
	var/datum/mind/obsession
	var/datum/objective/spendtime/attachedobsessedobj
	var/datum/antagonist/obsessed/antagonist
	var/viewing = FALSE //it's a lot better to store if the owner is watching the obsession than checking it twice between two procs

	var/total_time_creeping = 0 //just for roundend fun
	var/time_spent_away = 0
	var/obsession_hug_count = 0

/datum/brain_trauma/special/obsessed/on_gain()
	//setup, linking, etc//
	if(!obsession)//admins didn't set one
		obsession = find_obsession()
		if(!obsession)//we didn't find one
			lose_text = ""
			qdel(src)
			return
	RegisterSignal(obsession, COMSIG_MIND_CRYOED, PROC_REF(on_obsession_cryoed))
	gain_text = "<span class='warning'>You hear a sickening, raspy voice in your head. It wants one small task of you...</span>"
	antagonist = owner.mind.add_antag_datum(new /datum/antagonist/obsessed(src))
	..()
	//antag stuff//
	antagonist.forge_objectives(obsession)
	antagonist.greet()

/datum/brain_trauma/special/obsessed/on_life()
	var/mob/living/obsession_body = obsession.current
	if(!istype(obsession_body) || obsession_body.stat == DEAD)
		viewing = FALSE
		return
	if(get_dist(get_turf(owner), get_turf(obsession_body)) > 7)
		viewing = FALSE //they are further than our viewrange they are not viewing us
		out_of_view()
		return//so we're not searching everything in view every tick
	viewing = (owner in oviewers(7, obsession_body))
	if(viewing)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/creeping, obsession.name)
		total_time_creeping += 2 SECONDS
		time_spent_away = 0
		if(attachedobsessedobj)//if an objective needs to tick down, we can do that since traumas coexist with the antagonist datum
			attachedobsessedobj.timer -= 2 SECONDS //mob subsystem ticks every 2 seconds(?), remove 20 deciseconds from the timer. sure, that makes sense.
	else
		out_of_view()

/datum/brain_trauma/special/obsessed/proc/out_of_view()
	time_spent_away += 2 SECONDS
	if(time_spent_away > 3 MINUTES) //3 minutes
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/notcreepingsevere, obsession.name)
	else
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "creeping", /datum/mood_event/notcreeping, obsession.name)

/datum/brain_trauma/special/obsessed/on_lose()
	..()
	UnregisterSignal(obsession, COMSIG_MIND_CRYOED)
	antagonist?.trauma = null
	owner.mind.remove_antag_datum(/datum/antagonist/obsessed)

/datum/brain_trauma/special/obsessed/on_hug(mob/living/hugger, mob/living/hugged)
	if(hugged == obsession.current)
		obsession_hug_count++

/datum/brain_trauma/special/obsessed/proc/on_obsession_cryoed()
	SIGNAL_HANDLER

	UnregisterSignal(obsession, COMSIG_MIND_CRYOED)
	var/message = "You get the feeling [obsession] is no longer within reach."
	obsession = find_obsession()
	if(!obsession)//we didn't find one
		lose_text = "<span class='warning'>[message] The voices in your head fall silent.</span>"
		qdel(src)
		return
	RegisterSignal(obsession, COMSIG_MIND_CRYOED, PROC_REF(on_obsession_cryoed))
	to_chat(owner, "<span class='warning'>[message] The voices have a new task for you...</span>")
	antagonist.objectives = list()
	antagonist.forge_objectives(obsession)
	to_chat(owner, "<span class='bold'>You don't know their connection, but The Voices compel you to stalk [obsession.name], forcing them into a state of constant paranoia.</span>")
	owner.mind.announce_objectives()

/datum/brain_trauma/special/obsessed/proc/find_obsession()
	var/chosen_victim
	var/list/possible_targets = list()
	var/list/viable_minds = list()
	for(var/mob/living/carbon/human/potential_target in GLOB.player_list)
		var/turf/target_turf = get_turf(potential_target)
		if(potential_target != owner && potential_target.mind && potential_target.stat != DEAD && potential_target.client && !potential_target.client.is_afk() && SSjob.name_occupations[potential_target.mind.assigned_role] && target_turf && is_station_level(target_turf.z))
			viable_minds += potential_target.mind
	for(var/datum/mind/possible_target in viable_minds)
		var/weight = 10
		// MUCH less likely to get a target who's probably going to be off-station for most of the round
		if(possible_target.assigned_role in list(JOB_NAME_EXPLORATIONCREW, JOB_NAME_SHAFTMINER))
			weight = 1
		possible_targets[possible_target] = weight
	if(length(possible_targets))
		chosen_victim = pick_weight(possible_targets)
	return chosen_victim
