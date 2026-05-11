/datum/objective/absorb
	name = "absorb"
	explanation_text = "Absorb %AMOUNT genetically compatible crew members."

/datum/objective/absorb/proc/set_absorb_amount()
	// 1 full absorption per 10 players
	target_amount = max(floor(length(GLOB.joined_player_list) * 0.1), 1)
	update_explanation_text()

/datum/objective/absorb/update_explanation_text()
	. = ..()
	explanation_text = "Absorb [target_amount] genetically compatible crew members."

/datum/objective/absorb/admin_edit(mob/admin)
	var/count = tgui_input_number(admin, "How many people to absorb?", "Absorb Amount", target_amount)
	if(isnull(count))
		return

	target_amount = count
	update_explanation_text()

/datum/objective/absorb/check_completion()
	var/absorptions = 0
	for(var/datum/mind/objective_owner as anything in get_owners())
		var/datum/antagonist/changeling/changeling = objective_owner.has_antag_datum(/datum/antagonist/changeling)
		if(!changeling)
			continue
		absorptions += changeling.absorbed_people
	return ..() || absorptions >= target_amount
