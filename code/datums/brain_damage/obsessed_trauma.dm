/// The amount of time spent near a target until the obsession trauma reveals its true form to health scanners
#define OBSESSION_REVEAL_TIME				5 MINUTES
#define OBSESSION_INSANITY_FLAVOR_COOLDOWN	1.5 MINUTES

/datum/brain_trauma/special/obsessed
	name = "Psychotic Schizophrenia"
	desc = "Patient has a subtype of delusional disorder, becoming irrationally attached to someone."
	scan_desc = "monophobia" // It pretends to be monophobia until the revelation threshold is hit, in which case [scan_desc] will show the true nature of this trauma, setting it to [revealed_scan_desc].
	gain_text = "If you see this message, make a github issue report. The trauma initialized wrong."
	lose_text = "<span class='warning'>The voices in your head fall silent.</span>"
	can_gain = TRUE
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM | TRAUMA_SPECIAL_CURE_PROOF
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	var/datum/mind/obsession
	var/datum/objective/spendtime/attachedobsessedobj
	var/datum/antagonist/obsessed/antagonist
	var/regex/name_regex
	var/viewing = FALSE //it's a lot better to store if the owner is watching the obsession than checking it twice between two procs
	var/saw_dead = FALSE
	var/revealed = FALSE
	var/child_trauma = FALSE
	var/static/revealed_scan_desc = "psychotic schizophrenic delusions"

	var/total_time_creeping = 0 //just for roundend fun
	var/time_spent_away = 0
	var/obsession_hug_count = 0
	COOLDOWN_DECLARE(insanity_message_cooldown)

/datum/brain_trauma/special/obsessed/New(obsession_or_old_trauma)
	. = ..()
	if(istype(obsession_or_old_trauma, /datum/brain_trauma/special/obsessed))
		var/datum/brain_trauma/special/obsessed/old_trauma = obsession_or_old_trauma
		if(!old_trauma.antagonist || !old_trauma.obsession)
			return
		scan_desc = old_trauma.scan_desc
		resilience = old_trauma.resilience
		obsession = old_trauma.obsession
		attachedobsessedobj = old_trauma.attachedobsessedobj
		antagonist = old_trauma.antagonist
		antagonist.trauma = src
		revealed = old_trauma.revealed
		total_time_creeping = old_trauma.total_time_creeping
		time_spent_away = old_trauma.time_spent_away
		child_trauma = TRUE
	else if(istype(obsession_or_old_trauma, /datum/mind))
		obsession = obsession_or_old_trauma

/datum/brain_trauma/special/obsessed/on_gain()
	//setup, linking, etc//
	if(!obsession)//admins didn't set one
		obsession = find_obsession()
		if(!obsession)//we didn't find one
			lose_text = ""
			qdel(src)
			return
	setup_name_regex()
	RegisterSignal(obsession, COMSIG_MIND_CRYOED, PROC_REF(on_obsession_cryoed))
	RegisterSignal(owner.mind, COMSIG_MIND_TRANSFER_TO, PROC_REF(on_mind_transfer))
	gain_text = "<span class='warning'>You hear a sickening, raspy voice in your head. It wants one small task of you...</span>"
	if(QDELETED(antagonist))
		antagonist = owner.mind.add_antag_datum(new /datum/antagonist/obsessed(src))
	..()
	if(!length(antagonist.objectives))
		//antag stuff//
		antagonist.forge_objectives()
		antagonist.greet()

/datum/brain_trauma/special/obsessed/on_life()
	var/mob/living/obsession_body = obsession.current
	if(prob(2) && owner.client && !COOLDOWN_FINISHED(src, insanity_message_cooldown))
		insanity_message()
		COOLDOWN_START(src, insanity_message_cooldown, OBSESSION_INSANITY_FLAVOR_COOLDOWN)
	if(!istype(obsession_body))
		viewing = FALSE
		return
	if(!in_view_range(owner, obsession_body))
		viewing = FALSE //they are further than our viewrange they are not viewing us
		out_of_view()
		return//so we're not searching everything in view every tick
	viewing = (owner in viewers(owner.client?.view || world.view, obsession_body))
	if(viewing)
		if(obsession_body.stat == DEAD)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "obsession", /datum/mood_event/obsessed_saw_dead, obsession.name)
			saw_dead = TRUE
			return
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "obsession", /datum/mood_event/obsessed_creeping, obsession.name)
		if(saw_dead) // HOLY SHIT THEY'RE ALIVE!!! THANK GOODNESS!!
			saw_dead = FALSE
			var/datum/component/mood/mood = owner.GetComponent(/datum/component/mood)
			mood.setSanity(SANITY_MAXIMUM, maximum = SANITY_MAXIMUM)
		total_time_creeping += 2 SECONDS
		if(!revealed && (total_time_creeping >= OBSESSION_REVEAL_TIME))
			reveal()
		time_spent_away = 0
		if(attachedobsessedobj)//if an objective needs to tick down, we can do that since traumas coexist with the antagonist datum
			attachedobsessedobj.timer -= 2 SECONDS //mob subsystem ticks every 2 seconds(?), remove 20 deciseconds from the timer. sure, that makes sense.
	else
		out_of_view()

/datum/brain_trauma/special/obsessed/on_clone()
	return new /datum/brain_trauma/special/obsessed(src)

/datum/brain_trauma/special/obsessed/proc/on_mind_transfer(datum/_source, mob/living/carbon/old_mob, mob/living/carbon/new_mob)
	SIGNAL_HANDLER
	if(!istype(new_mob) || new_mob.has_trauma_type(type))
		return
	new_mob.gain_trauma(on_clone())
	if(istype(old_mob))
		qdel(src)

/datum/brain_trauma/special/obsessed/proc/reveal()
	revealed = TRUE
	scan_desc = revealed_scan_desc
	to_chat(owner, "<span class='obsession big italics'>... <span class='name obsessedshadow'>[obsession.name]</span> ... [obsession.current.p_they(TRUE)] [obsession.current.p_are()] yours ...</span>", type = MESSAGE_TYPE_INFO, avoid_highlighting = TRUE)
	owner.log_message("reached the obsession reveal threshold", LOG_GAME)

/datum/brain_trauma/special/obsessed/proc/insanity_message()
	switch(rand(1, 3))
		if(1)
			to_chat(owner, "<span class='obsession italics'>... <span class='name obsessedshadow'>[unhinged(obsession.name)]</span>!!!</span>", type = MESSAGE_TYPE_INFO, avoid_highlighting = TRUE)
		if(2)
			to_chat(owner, "<span class='obsession italics'>... Nobody is allowed to [pick("touch", "hurt", "abuse", "corrupt", "upset")] my [pick("dearest", "beloved", "darling", "precious")] <span class='name obsessedshadow'>[obsession.current.first_name()]</span> ...<span>", type = MESSAGE_TYPE_INFO, avoid_highlighting = TRUE)
		if(3)
			to_chat(owner, "<span class='obsession italics'>... I cannot trust anyone... they are all out to [pick("separate", "hurt", "destroy", "shatter")] me and my [pick("dearest", "beloved", "darling", "precious")] <span class='name obsessedshadow'>[obsession.current.first_name()]</span> ...</span>", type = MESSAGE_TYPE_INFO, avoid_highlighting = TRUE)

/datum/brain_trauma/special/obsessed/proc/out_of_view()
	time_spent_away += 2 SECONDS
	var/moodlet = (time_spent_away > 3 MINUTES) ? /datum/mood_event/obsessed_not_creeping_severe : /datum/mood_event/obsessed_not_creeping
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "obsession", moodlet, obsession.name)

/datum/brain_trauma/special/obsessed/on_lose()
	. = ..()
	if(antagonist?.trauma == src)
		UnregisterSignal(obsession, COMSIG_MIND_CRYOED)
		antagonist.trauma = null
		antagonist.cured = TRUE
		if(!QDELETED(owner))
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "obsession")
			var/datum/component/mood/mood = owner.GetComponent(/datum/component/mood)
			if(mood.sanity < SANITY_NEUTRAL)
				mood.setSanity(SANITY_NEUTRAL)

/datum/brain_trauma/special/obsessed/on_hug(mob/living/hugger, mob/living/hugged)
	if(hugged == obsession.current)
		obsession_hug_count++

/datum/brain_trauma/special/obsessed/handle_hearing(datum/source, list/hearing_args)
	if(name_regex)
		hearing_args[HEARING_RAW_MESSAGE] = name_regex.Replace(hearing_args[HEARING_RAW_MESSAGE], "<span class='name obsessedshadow'>$1</span>")

/datum/brain_trauma/special/obsessed/proc/on_obsession_cryoed()
	SIGNAL_HANDLER

	UnregisterSignal(obsession, COMSIG_MIND_CRYOED)
	var/message = "You get the feeling <span class='name'>[obsession.name]</span> is no longer within reach."
	var/new_obsession = find_obsession()
	if(!new_obsession)//we didn't find one
		lose_text = "<span class='warning'>[message] The voices in your head fall silent.</span>"
		qdel(src)
		return
	set_new_obsession(new_obsession)

/datum/brain_trauma/special/obsessed/proc/set_new_obsession(datum/mind/new_obsession)
	if(QDELETED(new_obsession))
		return
	if(!QDELETED(obsession))
		UnregisterSignal(obsession, COMSIG_MIND_CRYOED)
	obsession = new_obsession
	RegisterSignal(obsession, COMSIG_MIND_CRYOED, PROC_REF(on_obsession_cryoed))
	reset_variables()
	to_chat(owner, "<span class='warning'>The voices have a new task for you...</span>")
	antagonist.obsession = obsession
	antagonist.objectives.Cut()
	antagonist.forge_objectives()
	to_chat(owner, "<span class='obsession bold'>You don't know their connection, but The Voices compel you to stalk <span class='name obsessedshadow'>[obsession.name]</span>, forcing them into a state of constant paranoia.</span>")
	owner.mind.announce_objectives()

/datum/brain_trauma/special/obsessed/proc/reset_variables()
	if(!QDELETED(owner))
		SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "obsession")
		var/datum/component/mood/mood = owner.GetComponent(/datum/component/mood)
		if(mood.sanity < SANITY_NEUTRAL)
			mood.setSanity(SANITY_NEUTRAL)
	scan_desc = initial(scan_desc)
	QDEL_NULL(attachedobsessedobj)
	name_regex = null
	saw_dead = FALSE
	viewing = FALSE
	revealed = FALSE
	total_time_creeping = 0
	time_spent_away = 0
	obsession_hug_count = 0

/datum/brain_trauma/special/obsessed/proc/find_obsession()
	var/chosen_victim
	var/list/possible_targets = list()
	var/list/viable_minds = list()
	for(var/mob/living/carbon/human/potential_target in GLOB.player_list)
		var/turf/target_turf = get_turf(potential_target)
		// No self-obsessions
		if(potential_target == owner)
			continue
		// No mindless mobs
		if(QDELETED(potential_target.mind))
			continue
		// No brainless mobs (hopefully this shouldn't be a thing anyways) or highly brain-damaged mobs
		var/obj/item/organ/brain/pt_brain = potential_target.getorgan(/obj/item/organ/brain)
		if(QDELETED(pt_brain) || CHECK_BITFIELD(pt_brain.organ_flags, ORGAN_FAILING) || pt_brain.damage >= pt_brain.high_threshold)
			continue
		// No changelings or transform sting victims (too confusing)
		if(potential_target.mind.has_antag_datum(/datum/antagonist/changeling) || potential_target.has_status_effect(STATUS_EFFECT_LING_TRANSFORMATION))
			continue
		// No dead or dying people
		if(potential_target.stat == DEAD || potential_target.InCritical())
			continue
		// No SSD people
		if(!potential_target.client || potential_target.client.is_afk())
			continue
		// No off-station roles
		if(!SSjob.name_occupations[potential_target.mind.assigned_role])
			continue
		// No off-station people
		if(!target_turf || !is_station_level(target_turf.z))
			continue
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

/datum/brain_trauma/special/obsessed/proc/setup_name_regex()
	var/obsession_name = trim(obsession?.name)
	if(!length(obsession_name))
		return
	var/static/regex/split_regex = new(@"[\s\-]+", "ig")
	var/list/name_parts = splittext(obsession_name, split_regex)
	var/list/quoted_name_parts = list(REGEX_QUOTE(obsession_name))
	for(var/part in name_parts)
		if(length(part) <= 2)
			continue
		quoted_name_parts |= REGEX_QUOTE(part)
	if(!length(quoted_name_parts))
		return
	name_regex = new("\\b([quoted_name_parts.Join("|")])\\b", "gi")

#undef OBSESSION_INSANITY_FLAVOR_COOLDOWN
#undef OBSESSION_REVEAL_TIME
