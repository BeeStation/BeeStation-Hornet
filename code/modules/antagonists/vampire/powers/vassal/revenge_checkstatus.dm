/datum/action/cooldown/vampire/vassal_checkstatus
	name = "Check Vassals"
	desc = "Check each ex vassal's status"
	button_icon_state = "power_mez"
	power_explanation = "Use this power to check the health and location of all allied vassals"
	power_flags = NONE
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 10
	cooldown_time = 10 SECONDS

/datum/action/cooldown/vampire/vassal_checkstatus/can_use(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE

	var/datum/antagonist/vassal/revenge/revenge_vassal = IS_REVENGE_VASSAL(owner)
	if(!revenge_vassal?.ex_vassals.len)
		owner.balloon_alert(owner, "no vassals!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/vassal_checkstatus/ActivatePower()
	var/datum/antagonist/vassal/revenge/revenge_vassal = IS_REVENGE_VASSAL(owner)
	for(var/datum/antagonist/ex_vassal/former_vassals as anything in revenge_vassal.ex_vassals)
		var/turf/open/floor/target_area = get_area(owner)
		var/information = "[former_vassals.owner.current] has [round(COOLDOWN_TIMELEFT(former_vassals, blood_timer) / 600)] minutes left of Blood \
			[target_area ? "- currently at [target_area]." : "- their location is unknown!"] \
			[former_vassals.owner.current.stat == DEAD ? "- DEAD." : ""]"

		to_chat(owner, information)

	DeactivatePower()
