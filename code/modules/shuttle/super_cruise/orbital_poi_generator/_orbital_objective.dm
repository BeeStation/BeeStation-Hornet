#define REWARD_MONEY "MONEY"

/datum/orbital_objective
	//Static variables
	var/static/objective_num = 0

	//Type dependant
	var/name = "Null Objective"
	var/min_payout = 0
	var/max_payout = 0
	var/weight = 0

	//Instance dependent
	var/payout = 0
	var/completed = FALSE
	var/id = 0
	var/station_name

/datum/orbital_objective/New()
	. = ..()
	id = objective_num ++
	station_name = new_station_name()

/datum/orbital_objective/proc/on_assign(obj/machinery/computer/objective/objective_computer)
	return

/datum/orbital_objective/proc/check_failed()
	return TRUE

/datum/orbital_objective/proc/get_text()
	return ""

/datum/orbital_objective/proc/announce()
	priority_announce(get_text(), "Central Command Report", SSstation.announcer.get_rand_report_sound())

/datum/orbital_objective/proc/generate_payout()
	payout = rand(min_payout, max_payout)

/datum/orbital_objective/proc/generate_attached_beacon()
	return

/datum/orbital_objective/proc/complete_objective()
	if (SSorbits.current_objective == src)
		SSorbits.current_objective = null
	if(completed)
		return
	completed = TRUE
	//Handle payout
	SSeconomy.distribute_funds(payout)
	//Announcement
	priority_announce("Central Command priority objective completed. [payout] credits have been distributed across departmental budgets.", "Central Command Report", SSstation.announcer.get_rand_report_sound())
	//Objective completed
	SSorbits.completed_objectives += src
