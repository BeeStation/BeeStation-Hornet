/datum/objective/escape
	name = "escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody."

/datum/objective/escape/check_completion()
	// Require all owners escape safely.
	for(var/datum/mind/M as() in get_owners())
		if(!considered_escaped(M))
			return ..()
	return TRUE

/datum/objective/escape/single
	name = "escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."
	team_explanation_text = "Have at least one of your members escape on the shuttle or escape pod alive and without being in custody."

/datum/objective/escape/single/check_completion()
	// Require all owners escape safely.
	for(var/datum/mind/M as() in get_owners())
		if(considered_escaped(M))
			return TRUE
	return ..()

/datum/objective/escape/escape_with_identity
	name = "escape with identity"
	var/target_real_name // Has to be stored because the target's real_name can change over the course of the round
	var/target_missing_id

/datum/objective/escape/escape_with_identity/is_valid_target(datum/mind/possible_target)
	for(var/datum/mind/M as() in get_owners())
		var/datum/antagonist/changeling/C = M.has_antag_datum(/datum/antagonist/changeling)
		if(!C)
			continue
		var/datum/mind/T = possible_target
		if(!istype(T) || !C.can_absorb_dna(T.current, verbose=FALSE))
			return FALSE
	return ..()

/datum/objective/escape/escape_with_identity/update_explanation_text()
	if(target && target.current)
		target_real_name = target.current.real_name
		explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role]"
		var/mob/living/carbon/human/H
		if(ishuman(target.current))
			H = target.current
		if(H && H.get_id_name() != target_real_name)
			target_missing_id = 1
		else
			explanation_text += " while wearing their identification card"
		explanation_text += "." //Proper punctuation is important!
	else
		explanation_text = "Free Objective."

/datum/objective/escape/escape_with_identity/check_completion()
	if(!target || !target_real_name)
		return TRUE
	for(var/datum/mind/M as() in get_owners())
		if(!ishuman(M.current) || !considered_escaped(M))
			continue
		var/mob/living/carbon/human/H = M.current
		if(H.dna.real_name == target_real_name && (H.get_id_name() == target_real_name || target_missing_id))
			return TRUE
	return ..()

/datum/objective/escape/escape_with_identity/admin_edit(mob/admin)
	admin_simple_target_pick(admin)
