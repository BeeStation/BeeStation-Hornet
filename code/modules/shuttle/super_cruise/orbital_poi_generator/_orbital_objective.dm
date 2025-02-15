/datum/orbital_objective
	var/name = "Null Objective"
	var/datum/orbital_object/z_linked/beacon/ruin/linked_beacon
	var/payout = 0
	var/completed = FALSE
	var/min_payout = 0
	var/max_payout = 0
	var/id = 0
	var/station_name
	var/static/objective_num = 0
	var/static/datum/bank_account/bound_bank_account = ACCOUNT_SCI_ID

/datum/orbital_objective/New()
	. = ..()
	id = objective_num ++
	station_name = new_station_name()

	if(!istype(bound_bank_account))
		bound_bank_account = SSeconomy.get_budget_account(bound_bank_account)

/datum/orbital_objective/proc/on_assign(obj/machinery/computer/objective/objective_computer)
	return

/datum/orbital_objective/proc/generate_objective_stuff(turf/chosen_turf)
	return

/datum/orbital_objective/proc/check_failed()
	return TRUE

/datum/orbital_objective/proc/get_text()
	return ""

/datum/orbital_objective/proc/generate_payout()
	payout = rand(min_payout, max_payout)

/datum/orbital_objective/proc/generate_attached_beacon()
	linked_beacon = new
	linked_beacon.name = "(OBJECTIVE) [linked_beacon.name]"
	linked_beacon.linked_objective = src

/datum/orbital_objective/proc/complete_objective()
	if(completed)
		//Delete
		QDEL_NULL(SSorbits.current_objective)
		return
	completed = TRUE
	//Handle payout
	SSeconomy.distribute_funds(payout)
	bound_bank_account.adjust_currency(ACCOUNT_CURRENCY_EXPLO, payout)
	//Announcement
	if(length(GLOB.announcement_systems))
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		var/department_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_SUPPLY, RADIO_CHANNEL_SERVICE)
		announcer.announce("EXPLORATION_PAYOUT", channels = department_channels, exploration_payout = payout)
	//Delete
	QDEL_NULL(SSorbits.current_objective)
