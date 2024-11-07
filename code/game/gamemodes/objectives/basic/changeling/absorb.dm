//Changeling Objectives

/datum/objective/absorb
	name = "absorb"
	var/absorbedcount = 0

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	var/n_p = 1 //autowin
	var/list/datum/mind/owners = get_owners()
	if (SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/mob/dead/new_player/P in GLOB.player_list)
			if(P.client && P.ready == PLAYER_READY_TO_PLAY && !(P.mind in owners))
				n_p ++
	else if (SSticker.IsRoundInProgress())
		for(var/mob/living/carbon/human/P in GLOB.player_list)
			if(P.client && !(P.mind.has_antag_datum(/datum/antagonist/changeling)) && !(P.mind in owners))
				n_p ++
	target_amount = min(target_amount, n_p)

	update_explanation_text()
	return target_amount

/datum/objective/absorb/update_explanation_text()
	. = ..()
	explanation_text = "Extract [target_amount] compatible genome\s."

/datum/objective/absorb/admin_edit(mob/admin)
	var/count = input(admin,"How many people to absorb?","absorb",target_amount) as num|null
	if(count)
		target_amount = count
	update_explanation_text()

/datum/objective/absorb/check_completion()
	absorbedcount = 0
	for(var/datum/mind/M as() in get_owners())
		if(!M)
			continue
		var/datum/antagonist/changeling/changeling = M.has_antag_datum(/datum/antagonist/changeling)
		if(!changeling || !changeling.stored_profiles)
			continue
		absorbedcount += changeling.absorbedcount
	return (absorbedcount >= target_amount) || ..()

/datum/objective/absorb/get_completion_message()
	var/span = check_completion() ? "grentext" : "redtext"
	return "[explanation_text] <span class='[span]'>[absorbedcount] lifeform\s absorbed!</span>"

/datum/objective/absorb_most
	name = "absorb most"
	explanation_text = "Extract more compatible genomes than any other Changeling."

/datum/objective/absorb_most/check_completion()
	var/absorbedcount = 0
	for(var/datum/mind/M as() in get_owners())
		if(!M)
			continue
		var/datum/antagonist/changeling/changeling = M.has_antag_datum(/datum/antagonist/changeling)
		if(!changeling || !changeling.stored_profiles)
			continue
		absorbedcount += changeling.absorbedcount

	for(var/datum/antagonist/changeling/changeling2 in GLOB.antagonists)
		if(!changeling2.owner || changeling2.owner == owner || !changeling2.stored_profiles || changeling2.absorbedcount < absorbedcount)
			continue
		return ..()
	return TRUE
