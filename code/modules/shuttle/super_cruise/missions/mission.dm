
/datum/mission
	var/id
	var/name
	var/description
	var/payment
	var/successful = FALSE
	var/datum/ship_lobby/associated_lobby
	var/datum/orbital_object/associated_object

/datum/mission/New()
	. = ..()
	var/static/i = 0
	id = i++

/datum/mission/Destroy(force, ...)
	. = ..()
	associated_lobby = null
	associated_object = null

/datum/mission/proc/accept(datum/ship_lobby/group)
	associated_lobby = group
	RegisterSignal(group, COMSIG_PARENT_QDELETING, PROC_REF(fail))
	associate_to_location(generate())

/// Returns true/false depending if the mission failed to generate or not
/datum/mission/proc/is_possible()
	return FALSE

/datum/mission/proc/generate()
	return

/datum/mission/proc/associate_to_location(datum/orbital_object/object)
	if (associated_object)
		UnregisterSignal(associated_object, COMSIG_PARENT_QDELETING)
	associated_object = object
	RegisterSignal(associated_object, COMSIG_PARENT_QDELETING, PROC_REF(fail))

/datum/mission/proc/fail()
	SIGNAL_HANDLER
	qdel(src)

/datum/mission/proc/succeed(obj/docking_port/mobile/ship)
	successful = TRUE
	var/datum/bank_account/target_account = SSeconomy.get_bank_account_by_id(ship.id)
	target_account.adjust_money(payment)
	qdel(src)
