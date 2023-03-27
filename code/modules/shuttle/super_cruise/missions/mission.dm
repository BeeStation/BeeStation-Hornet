
/datum/mission
	var/name
	var/description
	var/payment
	var/successful = FALSE

/// Returns true/false depending if the mission failed to generate or not
/datum/mission/proc/try_generate()
	return FALSE

/datum/mission/proc/succeed(obj/docking_port/mobile/ship)
	successful = TRUE
	var/datum/bank_account/target_account = SSeconomy.get_bank_account_by_id(ship.id)
	target_account.adjust_money(payment)
	qdel(src)
