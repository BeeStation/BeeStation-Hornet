/datum/action/cooldown/vampire/vassal_fold
	name = "Reconvert Ex-Vassal"
	desc = "Bring an Ex-Vassal back into the fold."
	button_icon_state = "power_torpor"
	power_explanation = "Use this power while you are grabbing an ex-Vassal to bring them back into the fold."
	power_flags = NONE
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 50
	cooldown_time = 10 SECONDS

/datum/action/cooldown/vampire/vassal_fold/can_use(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/target = owner.pulling
	var/datum/antagonist/ex_vassal/former_vassal = IS_EX_VASSAL(target)
	if(!isliving(target))
		return FALSE
	if(!former_vassal)
		owner.balloon_alert(owner, "not a former vassal!")
		return FALSE
	if(former_vassal?.revenge_vassal)
		owner.balloon_alert(owner, "already converted!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/vassal_fold/ActivatePower()
	var/mob/living/target = owner.pulling
	if(!target)
		return FALSE
	var/datum/antagonist/ex_vassal/former_vassal = IS_EX_VASSAL(target)
	if(!former_vassal  || former_vassal?.revenge_vassal)
		return FALSE

	if(do_after(owner, 5 SECONDS, target))
		former_vassal.return_to_fold(IS_REVENGE_VASSAL(owner))
	DeactivatePower()
