#define OBJECTIVE_STALK "spendtime"
#define OBJECTIVE_PHOTOGRAPH "polaroid"
#define OBJECTIVE_STEAL "heirloom"
#define OBJECTIVE_JEALOUS "jealous"

/datum/antagonist/obsessed
	name = "Obsessed"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	job_rank = ROLE_OBSESSED
	show_name_in_check_antagonists = TRUE
	roundend_category = "obsessed"
	var/datum/mind/target
	var/mob/living/carbon/human/human_target
	var/total_time_stalking
	var/time_spent_away
	var/seen_alive = TRUE

/datum/antagonist/obsessed/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/creepalert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner, "<span class='userdanger'>You are the Obsessed!</span>")
	to_chat(owner, "<B>The Voices have reached out to you, and are using you to complete their evil deeds.</B>")
	to_chat(owner, "<B>You don't know their connection, but The Voices compel you to stalk [target], forcing them into a state of constant paranoia.</B>")
	to_chat(owner, "<B>The Voices will retaliate if you fail to complete your tasks or spend too long away from your target.</B>")
	to_chat(owner, "<span class='boldannounce'>This role does NOT enable you to otherwise surpass what's deemed creepy behavior per the rules.</span>")//ironic if you know the history of the antag
	owner.current.client?.tgui_panel?.give_antagonist_popup("Obsession",
		"Stalk [human_target.real_name] and force them into a constant state of paranoia.")

/datum/antagonist/obsessed/on_gain()
	find_target()
	if(!target)
		qdel(src)
		return
	//We need to find target first before calling parent here
	. = ..()
	forge_objectives()
	RegisterSignal(owner.current, COMSIG_GLOB_MOB_DEATH, .proc/OnDeath)
	RegisterSignal(owner.current, COMSIG_LIVING_REVIVE, .proc/OnRevival)
	RegisterSignal(human_target, COMSIG_PARENT_QDELETING, .proc/TargetDeleted)
	START_PROCESSING(SSprocessing, src)

/datum/antagonist/obsessed/on_removal()
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(owner.current, COMSIG_GLOB_MOB_DEATH)
	UnregisterSignal(owner.current, COMSIG_LIVING_REVIVE)
	if(human_target)
		UnregisterSignal(human_target, COMSIG_PARENT_QDELETING)
		if(!seen_alive && human_target.stat != DEAD)
			UnregisterSignal(human_target, COMSIG_LIVING_REVIVE)
	to_chat(owner, "<span class='notice'>Your mind clears out!")
	to_chat(owner, "<span class='userdanger'>You are no longer Obsessed!")
	owner.current.client?.tgui_panel?.clear_antagonist_popup()
	return ..()

/datum/antagonist/obsessed/process(delta_time)
	if(!human_target || get_dist(get_turf(owner.current), get_turf(human_target)) > 7)//we're simply out of range
		if(seen_alive)	//we know our target lives
			time_spent_away += SSprocessing.wait * delta_time
			if(time_spent_away > 3 MINUTES)
				SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "obsession", /datum/mood_event/notcreepingsevere)
			else
				SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "obsession", /datum/mood_event/notcreeping)
		return
	//If running this every tick we're 7 tiles from target is too expensive, just assume we see him
	if(human_target in oviewers(7, owner.current))	//we're in range and we can see our target
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "obsession", /datum/mood_event/creeping)
		if(human_target.stat == DEAD)	//we saw them dead
			seen_alive = FALSE
			to_chat(owner, "<span class='danger'>[human_target.real_name] is dead!")
			RegisterSignal(human_target, COMSIG_LIVING_REVIVE, .proc/OnTargetRevive)
			STOP_PROCESSING(SSprocessing, src)
		else if(!seen_alive)
				to_chat(owner, "<span class='danger'>[human_target.real_name] is alive again!")
				seen_alive = TRUE	//we saw them alive again
		total_time_stalking += SSprocessing.wait * delta_time
		time_spent_away = 0
	else if(seen_alive)		//we're near so we acumulate the time slower
		time_spent_away += SSprocessing.wait * delta_time / 2

/datum/antagonist/obsessed/proc/OnDeath()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)

/datum/antagonist/obsessed/proc/OnRevival()
	SIGNAL_HANDLER
	START_PROCESSING(SSprocessing, src)

/datum/antagonist/obsessed/proc/OnTargetRevive()
	SIGNAL_HANDLER
	START_PROCESSING(SSprocessing, src)
	UnregisterSignal(human_target, COMSIG_LIVING_REVIVE)

/datum/antagonist/obsessed/proc/TargetDeleted()
	SIGNAL_HANDLER
	if(!seen_alive && human_target.stat != DEAD)
		UnregisterSignal(human_target, COMSIG_LIVING_REVIVE)
	human_target = null
	seen_alive = FALSE
	STOP_PROCESSING(SSprocessing, src)

/datum/antagonist/obsessed/proc/add_objective(datum/objective/O)
	O.owner = owner
	O.target = target
	objectives += O
	log_objective(owner, O.explanation_text)

/datum/antagonist/obsessed/proc/remove_objective(datum/objective/O)
	objectives -= O
	qdel(O)

/datum/antagonist/obsessed/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_obsession_icons_added(M)

/datum/antagonist/obsessed/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_obsession_icons_removed(M)

/datum/antagonist/obsessed/proc/forge_objectives()
	var/list/objectives_left = list(OBJECTIVE_STALK, OBJECTIVE_PHOTOGRAPH, OBJECTIVE_JEALOUS)
	var/datum/objective/assassinate/obsessed/kill = new

	if(HAS_TRAIT(human_target, TRAIT_HEIRLOOOM))
		objectives_left += OBJECTIVE_STEAL	//we stealing their heirloom

	for(var/i in 1 to 3)
		var/chosen_objective = pick_n_take(objectives_left)
		switch(chosen_objective)
			if(OBJECTIVE_STALK)
				var/datum/objective/spendtime/spendtime = new(human_target.name)
				add_objective(spendtime)
			if(OBJECTIVE_PHOTOGRAPH)
				var/datum/objective/polaroid/polaroid = new
				add_objective(polaroid)
			if(OBJECTIVE_STEAL)
				var/datum/quirk/family_heirloom/F = locate(/datum/quirk/family_heirloom) in human_target.roundstart_quirks
				var/datum/objective/heirloom_thief/heirloom_thief = new(F.heirloom)
				add_objective(heirloom_thief)
			if(OBJECTIVE_JEALOUS)
				var/datum/objective/assassinate/jealous/jealous = new(target)
				if(jealous)
					add_objective(jealous)

	add_objective(kill)
	kill.target = target
	for(var/datum/objective/O as() in objectives)
		O.update_explanation_text()

	owner.announce_objectives()

/datum/antagonist/obsessed/proc/find_target()
	var/list/possible_targets = list()

	//I'm going to assume every mob in player list has a mind attached to it
	for(var/mob/M as() in GLOB.player_list)
		if(M.stat == DEAD || !ishuman(M) || M.mind.antag_datums?.len || M.mind == owner)	//It's better for antags to not become targets of obsession
			continue
		possible_targets |= M

	if(!possible_targets.len)
		return
	human_target = pick(possible_targets)
	target = human_target.mind

/datum/antagonist/obsessed/roundend_report_header()
	return 	"<span class='header'>Someone became obsessed!</span><br>"

/datum/antagonist/obsessed/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(total_time_stalking > 0)
		report += "<span class='greentext'>The [name] spent a total of [DisplayTimeText(total_time_stalking)] being near [target]!</span>"
	else
		report += "<span class='redtext'>The [name] did not go near their obsession the entire round! That's extremely impressive, but you are a shit [name]!</span>"

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

//////////////////////////////////////////////////
///CREEPY objectives (few chosen per obsession)///
//////////////////////////////////////////////////

/datum/objective/assassinate/obsessed //just a creepy version of assassinate

/datum/objective/assassinate/obsessed/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Murder [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."

/datum/objective/assassinate/jealous //assassinate, but it changes the target to someone else in the previous target's department. cool, right?

/datum/objective/assassinate/jealous/New(datum/mind/new_target)
	. = ..()
	find_coworker(new_target)

/datum/objective/assassinate/jealous/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Murder [target.name], their coworker."

/datum/objective/assassinate/jealous/proc/find_coworker(datum/mind/oldmind)
	if(!oldmind.assigned_role)
		return
	var/list/prefered_coworkers = list()
	var/list/other_coworkers = list()
	var/prefered_roles
	//don't think there's better way to find department
	if(oldmind.assigned_role in GLOB.security_positions)
		prefered_roles = GLOB.security_positions
	else if(oldmind.assigned_role in GLOB.engineering_positions)
		prefered_roles = GLOB.engineering_positions
	else if(oldmind.assigned_role in GLOB.medical_positions)
		prefered_roles = GLOB.medical_positions
	else if(oldmind.assigned_role in GLOB.science_positions)
		prefered_roles = GLOB.science_positions
	else if(oldmind.assigned_role in GLOB.supply_positions)
		prefered_roles = GLOB.supply_positions
	//Gimmicks are special, there might be not enough of them to find coworker and civilians are technically their coworkers
	else if((oldmind.assigned_role in GLOB.civilian_positions) || (oldmind.assigned_role in GLOB.gimmick_positions))
		prefered_roles = GLOB.civilian_positions

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!SSjob.GetJob(H.mind.assigned_role) || H.mind == oldmind|| H.mind.antag_datums.len)
			continue //the jealousy target has to have a job, and not be the obsession or obsessed.
		if(H.mind.assigned_role in prefered_roles)
			prefered_coworkers += H
			continue
		other_coworkers += H.mind

	var/mob/living/carbon/human/H
	if(prefered_coworkers.len)//find someone in the same department
		H = pick(prefered_coworkers)
	else if(other_coworkers.len)//find someone who works on the station
		H = pick(other_coworkers)

	if(H)
		target = H.mind
		return
	qdel(src)

/datum/objective/spendtime //spend some time around someone, handled by the obsessed trauma since that ticks
	name = OBJECTIVE_STALK
	var/timer = 5 MINUTES
	var/target_name

/datum/objective/spendtime/New(name)
	. = ..()
	target_name = name

/datum/objective/spendtime/update_explanation_text()
	if(timer == initial(timer))//just so admins can mess with it
		timer += pick(-600, 0)
	if(!owner.has_antag_datum(/datum/antagonist/obsessed))
		qdel(src)
		return
	explanation_text = "Spend [DisplayTimeText(timer)] around [target_name] while they're alive."


/datum/objective/spendtime/check_completion()
	var/datum/antagonist/obsessed/O = owner.has_antag_datum(/datum/antagonist/obsessed)
	return completed || (O?.total_time_stalking >= timer)

/datum/objective/polaroid //take a picture of the target with you in it.
	name = OBJECTIVE_PHOTOGRAPH

/datum/objective/polaroid/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Escape with a photo of [target], taken while they're alive."

/datum/objective/polaroid/check_completion()
	if(..())
		return TRUE
	var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
	for(var/obj/item/photo/P in all_items)
		if(P.picture && (target.current in P.picture.mobs_seen) && !(target.current in P.picture.dead_seen))
			return TRUE
	return FALSE

/datum/objective/heirloom_thief
	name = OBJECTIVE_STEAL
	var/datum/weakref/target_ref

/datum/objective/heirloom_thief/New(obj/item/target)
	target_ref = WEAKREF(target)	//item might be deleted at any point so it's unsafe to store strong refence

/datum/objective/heirloom_thief/update_explanation_text()
	..()
	var/obj/item/I = target_ref.resolve()
	if(I)
		explanation_text = "Steal [target.name]'s family heirloom, [I] they cherish."

/datum/objective/heirloom_thief/check_completion()
	if(..())
		return TRUE
	var/obj/item/I = target_ref.resolve()
	if(I && isliving(owner?.current))
		return (I in owner.current.GetAllContents())
	return FALSE

/datum/antagonist/obsessed/proc/update_obsession_icons_added(mob/living/carbon/human/obsessed)
	var/datum/atom_hud/antag/creephud = GLOB.huds[ANTAG_HUD_OBSESSED]
	creephud.join_hud(obsessed)
	set_antag_hud(obsessed, "obsessed")

/datum/antagonist/obsessed/proc/update_obsession_icons_removed(mob/living/carbon/human/obsessed)
	var/datum/atom_hud/antag/creephud = GLOB.huds[ANTAG_HUD_OBSESSED]
	creephud.leave_hud(obsessed)
	set_antag_hud(obsessed, null)

#undef OBJECTIVE_STALK
#undef OBJECTIVE_PHOTOGRAPH
#undef OBJECTIVE_STEAL
#undef OBJECTIVE_JEALOUS
