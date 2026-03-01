/datum/antagonist/abductor
	name = "Abductor"
	roundend_category = "abductors"
	antagpanel_category = "Abductor"
	banning_key = ROLE_ABDUCTOR
	show_in_antagpanel = FALSE //should only show subtypes
	show_to_ghosts = TRUE
	required_living_playtime = 4
	var/datum/team/abductor_team/team
	var/sub_role
	var/outfit
	var/landmark_type
	var/greet_text

/datum/antagonist/abductor/agent
	name = "Abductor Agent"
	sub_role = "Agent"
	outfit = /datum/outfit/abductor/agent
	landmark_type = /obj/effect/landmark/abductor/agent
	greet_text = "Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve."
	show_in_antagpanel = TRUE
	ui_name = "AntagInfoAbductorAgent"

/datum/antagonist/abductor/scientist
	name = "Abductor Scientist"
	sub_role = "Scientist"
	outfit = /datum/outfit/abductor/scientist
	landmark_type = /obj/effect/landmark/abductor/scientist
	greet_text = "Use your experimental console and surgical equipment to monitor your agent and experiment upon abducted humans."
	show_in_antagpanel = TRUE
	ui_name = "AntagInfoAbductorScientist"

/datum/antagonist/abductor/scientist/solo
	name = "Lone Abductor"
	outfit = /datum/outfit/abductor/scientist/solo

/datum/antagonist/abductor/create_team(datum/team/abductor_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/abductor/get_team()
	return team

/datum/antagonist/abductor/on_gain()
	owner.special_role = ROLE_ABDUCTOR
	owner.assigned_role = ROLE_ABDUCTOR
	objectives += team.objectives
	for(var/datum/objective/O in objectives)
		log_objective(owner.current, O.explanation_text)
	finalize_abductor()
	ADD_TRAIT(owner, TRAIT_ABDUCTOR_TRAINING, ABDUCTOR_ANTAGONIST)
	return ..()

/datum/antagonist/abductor/on_removal()
	if(owner.current)
		to_chat(owner.current,span_userdanger("You are no longer the [owner.special_role]!"))
	owner.special_role = null
	REMOVE_TRAIT(owner, TRAIT_ABDUCTOR_TRAINING, ABDUCTOR_ANTAGONIST)
	return ..()

/datum/antagonist/abductor/greet()
	to_chat(owner.current, span_notice("You are the [owner.special_role]!"))
	to_chat(owner.current, span_notice("With the help of your teammate, kidnap and experiment on station crew members!"))
	to_chat(owner.current, span_notice("There are two of you! One can monitor cameras while the other infiltrates the station."))
	to_chat(owner.current, span_notice("Choose a worthy disguise and plan your targets carefully! Humans will kill you on sight."))
	to_chat(owner.current, span_notice("[greet_text]"))
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Abductor",
		"Capture and experiment on members of the crew, without being spotted.")

/datum/antagonist/abductor/ui_static_data(mob/user)
	. = ..()
	.["mothership"] = team.name

/datum/antagonist/abductor/proc/finalize_abductor()
	//Equip
	var/mob/living/carbon/human/H = owner.current
	H.set_species(/datum/species/abductor)
	var/obj/item/organ/tongue/abductor/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	T.mothership = "[team.name]"

	H.real_name = "[team.name] [sub_role]"
	H.equipOutfit(outfit)

	//Teleport to ship
	for(var/obj/effect/landmark/abductor/LM in GLOB.landmarks_list)
		if(istype(LM, landmark_type) && LM.team_number == team.team_number)
			H.forceMove(LM.loc)
			break

	update_abductor_icons_added(owner,"abductor")

/datum/antagonist/abductor/scientist/on_gain()
	ADD_TRAIT(owner, TRAIT_ABDUCTOR_SCIENTIST_TRAINING, ABDUCTOR_ANTAGONIST)
	ADD_TRAIT(owner, TRAIT_ABDUCTOR_SURGEON, ABDUCTOR_ANTAGONIST)
	. = ..()

/datum/antagonist/abductor/scientist/on_removal()
	REMOVE_TRAIT(owner, TRAIT_ABDUCTOR_SCIENTIST_TRAINING, ABDUCTOR_ANTAGONIST)
	REMOVE_TRAIT(owner, TRAIT_ABDUCTOR_SURGEON, ABDUCTOR_ANTAGONIST)
	. = ..()

/datum/antagonist/abductor/admin_add(datum/mind/new_owner,mob/admin)
	var/list/current_teams = list()
	for(var/datum/team/abductor_team/T in get_all_teams(/datum/team/abductor_team))
		current_teams[T.name] = T
	var/choice = input(admin,"Add to which team ?") as null|anything in (current_teams + "new team")
	if (choice == "new team")
		team = new
	else if(choice in current_teams)
		team = current_teams[choice]
	else
		return
	new_owner.add_antag_datum(src)
	log_admin("[key_name(usr)] made [key_name(new_owner)] [name] on [choice]!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(new_owner)] [name] on [choice] !")

/datum/antagonist/abductor/get_admin_commands()
	. = ..()
	.["Equip"] = CALLBACK(src,PROC_REF(admin_equip))

/datum/antagonist/abductor/proc/admin_equip(mob/admin)
	if(!ishuman(owner.current))
		to_chat(admin, span_warning("This only works on humans!"))
		return
	var/mob/living/carbon/human/H = owner.current
	var/gear = alert(admin,"Agent or Scientist Gear","Gear","Agent","Scientist")
	if(gear)
		if(gear=="Agent")
			H.equipOutfit(/datum/outfit/abductor/agent)
		else
			H.equipOutfit(/datum/outfit/abductor/scientist)

/datum/team/abductor_team
	member_name = "abductor"
	var/team_number
	var/list/datum/mind/abductees = list()
	var/static/team_count = 1

/datum/team/abductor_team/New()
	..()
	var/static/list/left_team_names = GLOB.greek_letters.Copy() //TODO Ensure unique and actual alieny names (this is a TO-DO from 2018)
	team_number = team_count++
	if(length(left_team_names))
		name = "Mothership [pick_n_take(left_team_names)]"
	else
		name = "No.[team_number] Mothership [pick(GLOB.greek_letters)]"
	add_objective(new/datum/objective/experiment)

/datum/team/abductor_team/is_solo()
	return FALSE

/datum/team/abductor_team/proc/add_objective(datum/objective/O)
	O.team = src
	O.update_explanation_text()
	objectives += O
	for(var/datum/mind/abductor_mind in members)
		log_objective(abductor_mind, O.explanation_text)

/datum/team/abductor_team/roundend_report()
	var/list/result = list()

	var/won = TRUE
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			won = FALSE
	if(won)
		result += span_greentextbig("[name] team fulfilled its mission!")
	else
		result += span_redtextbig("[name] team failed its mission.")

	result += span_header("The abductors of [name] were:")
	for(var/datum/mind/abductor_mind in members)
		result += printplayer(abductor_mind)
	result += printobjectives(objectives)

	return "<div class='panel redborder'>[result.Join("<br>")]</div>"

/datum/antagonist/abductee
	name = "Abductee"
	roundend_category = "abductees"
	antagpanel_category = "Abductee"
	banning_key = UNBANNABLE_ANTAGONIST

/datum/antagonist/abductee/on_gain()
	give_objective()
	. = ..()

/datum/antagonist/abductee/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/abductee.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner, span_warning("<b>Your mind snaps!</b>"))
	to_chat(owner, "<big>[span_warning("<b>You can't remember how you got here...</b>")]</big>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Abductee", "Something isn't right with your brain, you feel like there is something you have to do no matter what...")

/datum/antagonist/abductee/proc/give_objective()
	var/mob/living/carbon/human/H = owner.current

	// Give the base objective
	var/datum/objective/abductee/base_objective = new()
	base_objective.owner = owner
	objectives += base_objective


	//pick flavor objective
	var/datum/objective/abductee/extra_objective
	switch(rand(1,10))
		if(6 to 10)
			extra_objective = new /datum/objective/abductee/fearful()
		if(3 to 5)
			extra_objective = new /datum/objective/abductee/violent()
		if(1 to 2)
			extra_objective = new /datum/objective/abductee/paranoid()

	extra_objective.owner = owner
	objectives += extra_objective
	log_objective(H, extra_objective.explanation_text)

/datum/antagonist/abductee/apply_innate_effects(mob/living/mob_override)
	update_abductor_icons_added(mob_override ? mob_override.mind : owner,"abductee")

/datum/antagonist/abductee/remove_innate_effects(mob/living/mob_override)
	update_abductor_icons_removed(mob_override ? mob_override.mind : owner)

// LANDMARKS
/obj/effect/landmark/abductor
	var/team_number = 1

/obj/effect/landmark/abductor/agent
	icon_state = "abductor_agent"
/obj/effect/landmark/abductor/scientist
	icon_state = "abductor"

// OBJECTIVES
/datum/objective/experiment
	target_amount = 6

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	for(var/obj/machinery/abductor/experiment/E in GLOB.machines)
		if(!istype(team, /datum/team/abductor_team))
			return ..()
		var/datum/team/abductor_team/T = team
		if(E.team_number == T.team_number)
			return (E.points >= target_amount) || ..()
	return ..()

/datum/antagonist/proc/update_abductor_icons_added(datum/mind/alien_mind,hud_type)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
	hud.join_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, hud_type)

/datum/antagonist/proc/update_abductor_icons_removed(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
	hud.leave_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, null)
