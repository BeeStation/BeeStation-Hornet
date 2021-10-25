#define OBJECTIVE_STALK "spendtime"
#define OBJECTIVE_PHOTOGRAPH "polaroid"
#define OBJECTIVE_HUG "hug"		//TO DO: replace it with something that isn't stupid
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

/datum/antagonist/obsessed/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/creepalert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner, "<span class='userdanger'>You are the Obsessed!</span>")
	to_chat(owner, "<B>The Voices have reached out to you, and are using you to complete their evil deeds.</B>")
	to_chat(owner, "<B>You don't know their connection, but The Voices compel you to stalk [target], forcing them into a state of constant paranoia.</B>")
	to_chat(owner, "<B>The Voices will retaliate if you fail to complete your tasks or spend too long away from your target.</B>")
	to_chat(owner, "<span class='boldannounce'>This role does NOT enable you to otherwise surpass what's deemed creepy behavior per the rules.</span>")//ironic if you know the history of the antag
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Obsession",
		"Stalk [target] and force them into a constant state of paranoia.")

/datum/antagonist/obsessed/on_gain()
	find_target()
	if(!target)
		qdel(src)
	forge_objectives()
	return ..()

/datum/antagonist/obsessed/on_removal()
	. = ..()
	to_chat(owner, "<span class='notice'>Your mind clears out!")
	to_chat(owner, "<span class='userdanger'>You are no longer Obsessed!")
	owner.current.client?.tgui_panel?.clear_antagonist_popup()

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
	var/list/objectives_left = list(OBJECTIVE_STALK, OBJECTIVE_PHOTOGRAPH, OBJECTIVE_HUG, OBJECTIVE_JEALOUS)
	var/datum/objective/assassinate/obsessed/kill = new

	if(HAS_TRAIT(target, TRAIT_HEIRLOOOM))
		objectives_left += OBJECTIVE_STEAL	//we stealing their heirloom

	for(var/i in 1 to 3)
		var/chosen_objective = pick_n_take(objectives_left)
		switch(chosen_objective)
			if(OBJECTIVE_STALK)
				var/datum/objective/spendtime/spendtime = new
				add_objective(spendtime)
			if(OBJECTIVE_PHOTOGRAPH)
				var/datum/objective/polaroid/polaroid = new
				add_objective(polaroid)
			if(OBJECTIVE_HUG)
				var/datum/objective/hug/hug = new
				add_objective(owner, hug)
			if(OBJECTIVE_STEAL)
				var/datum/quirk/family_heirloom/F = locate(/datum/quirk/family_heirloom) in target.roundstart_quirks
				var/datum/objective/heirloom_thief/heirloom_thief = new(F.heirloom)
				add_objective(heirloom_thief)
			if(OBJECTIVE_JEALOUS)
				var/datum/objective/assassinate/jealous/jealous = new(target)
				add_objective(jealous)

	add_objective(kill)
	kill.target = target
	for(var/datum/objective/O in objectives)
		O.update_explanation_text()

/datum/antagonist/obsessed/proc/find_target()
	var/chosen_victim
	var/list/possible_targets = list()

	//I'm going to assume every mob in player list has a mind attached to it
	for(var/mob/M as() in GLOB.player_list)
		if(M.stat == DEAD || !ishuman(M) || M.mind.antag_datums.len || M.mind == owner)	//It's better for antags to not become targets of obsession
			continue
		possible_targets |= M

	if(!possible_targets.len)
		return
	var/mob/M = pick(possible_targets)
	target = M.mind

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
	if(trauma)
		if(trauma.total_time_creeping > 0)
			report += "<span class='greentext'>The [name] spent a total of [DisplayTimeText(trauma.total_time_creeping)] being near [trauma.obsession]!</span>"
		else
			report += "<span class='redtext'>The [name] did not go near their obsession the entire round! That's extremely impressive, but you are a shit [name]!</span>"
	else
		report += "<span class='redtext'>The [name] had no trauma attached to their antagonist ways! Either it bugged out or an admin incorrectly gave this good samaritan antag and it broke! You might as well show yourself!!</span>"

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
		if(!SSjob.GetJob(H.mind.assigned_role) || H == oldmind.current || H.mind.antag_datums.len)
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
	var/timer = 1800 //5 minutes

/datum/objective/spendtime/update_explanation_text()
	if(timer == initial(timer))//just so admins can mess with it
		timer += pick(-600, 0)
	var/datum/antagonist/obsessed/creeper = owner.has_antag_datum(/datum/antagonist/obsessed)
	if(target && target.current && creeper)
		creeper.trauma.attachedobsessedobj = src
		explanation_text = "Spend [DisplayTimeText(timer)] around [target.name] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/spendtime/check_completion()
	return timer <= 0 || explanation_text == "Free Objective"


/datum/objective/hug//this objective isn't perfect. hugging the correct amount of times, then switching bodies, might fail the objective anyway. maybe i'll come back and fix this sometime.
	//Yeah no shit it isn't perfect, it's barely working at maximum
	name = OBJECTIVE_HUG
	var/hugs_needed

/datum/objective/hug/update_explanation_text()
	..()
	if(!hugs_needed)//just so admins can mess with it
		hugs_needed = rand(4,6)
	var/datum/antagonist/obsessed/creeper = owner.has_antag_datum(/datum/antagonist/obsessed)
	if(target && target.current && creeper)
		explanation_text = "Hug [target.name] [hugs_needed] times while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/hug/check_completion()
	var/datum/antagonist/obsessed/creeper = owner.has_antag_datum(/datum/antagonist/obsessed)
	if(!creeper || !creeper.trauma || !hugs_needed)
		return TRUE//free objective
	return creeper.trauma.obsession_hug_count >= hugs_needed

/datum/objective/polaroid //take a picture of the target with you in it.
	name = OBJECTIVE_PHOTOGRAPH

/datum/objective/polaroid/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Escape with a photo of [target], taken while they're alive."

/datum/objective/polaroid/check_completion()
	if(completed)
		return TRUE
	if(!isliving(owner.current) || owner.current.stat == DEAD)
		return FALSE
	var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
	for(var/obj/item/photo/P in all_items)
		if(P.picture && (target.current in P.picture.mobs_seen) && !(target.current in P.picture.dead_seen)) //TODO: fairly sure it doesn't work, so fix
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
	if(completed)
		return TRUE
	var/obj/item/I = target_ref.resolve()
	if(I && isliving(owner.current))
		for(var/obj/item/item in owner.current.GetAllContents())
			if(item == I)
				return TRUE

/datum/antagonist/obsessed/proc/update_obsession_icons_added(var/mob/living/carbon/human/obsessed)
	var/datum/atom_hud/antag/creephud = GLOB.huds[ANTAG_HUD_OBSESSED]
	creephud.join_hud(obsessed)
	set_antag_hud(obsessed, "obsessed")

/datum/antagonist/obsessed/proc/update_obsession_icons_removed(var/mob/living/carbon/human/obsessed)
	var/datum/atom_hud/antag/creephud = GLOB.huds[ANTAG_HUD_OBSESSED]
	creephud.leave_hud(obsessed)
	set_antag_hud(obsessed, null)

#undef OBJECTIVE_STALK
#undef OBJECTIVE_PHOTOGRAPH
#undef OBJECTIVE_HUG
#undef OBJECTIVE_STEAL
#undef OBJECTIVE_JEALOUS
