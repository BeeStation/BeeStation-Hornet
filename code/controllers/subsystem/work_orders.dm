// The work order board. Orders derive in work_order.dm

/// Percent of baseline. Raise under the first, clear over the second
#define AREA_INTEGRITY_RAISE_AT 90
#define AREA_INTEGRITY_CLEAR_AT 96
/// Enough to sweep the station in well under a minute.
#define AREA_INTEGRITY_SWEEP_BATCH 8
#define MAX_WORK_RECORDS 200
/// Stops mass assignment driving somebody to mute the program
#define WORK_NOTIFY_COOLDOWN (30 SECONDS)
/// kPa. Faults outside the first pair, clears inside the second
#define PRESSURE_FAULT_LOW WARNING_LOW_PRESSURE
#define PRESSURE_FAULT_HIGH WARNING_HIGH_PRESSURE
#define PRESSURE_CLEAR_LOW 80
#define PRESSURE_CLEAR_HIGH 250
/// Nothing else drives the board.
#define WORK_ORDER_REFRESH_FIRES 5

SUBSYSTEM_DEF(work_orders)
	name = "Work Orders"
	wait = 1 SECONDS

	/// Order key to /datum/work_claim, for jobs somebody has picked up.
	var/list/claims = list()

	// Roundstart baselines and live state, keyed by area ref
	var/list/coverage_baseline = list()
	var/list/integrity_baseline = list()
	var/list/integrity_current = list()
	var/list/integrity_damaged = list()
	var/list/space_baseline = list()
	var/list/breached = list()
	var/list/pressure_faulted = list()

	/// Order key to description. Lets new and completed jobs be spotted
	var/list/known_orders = list()
	/// ckey to completed count. On the ckey, not the mind, for disconnects
	var/list/completed_by = list()
	/// Running or not. A program that has never been opened never ticks
	var/list/monitors = list()

	/// Areas still to rescore this pass.
	var/list/sweep_queue = list()
	/// Counts down to the next board refresh.
	var/refresh_in = WORK_ORDER_REFRESH_FIRES

	/// Tick caches. On the subsystem rather than proc statics, for VV
	var/list/air_coverage_cache
	var/air_coverage_time = -1
	var/list/orders_cache
	var/orders_time = -1
	var/list/crew_cache
	var/crew_time = -1
	/// Which department crew_cache holds
	var/crew_cache_department

	/// Resolved claims, oldest first
	var/list/records = list()
	/// ckey to world.time of their last device beep
	var/list/notify_cooldowns = list()

/datum/controller/subsystem/work_orders/Initialize()
	// An APC that hasn't powered up yet would bake a coverage gap in for the whole round
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(capture_baselines)))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/work_orders/proc/capture_baselines()
	capture_coverage_baseline()
	capture_area_integrity_baseline()

/datum/controller/subsystem/work_orders/fire(resumed = FALSE)
	var/map_z = get_station_map_z()
	if(isnull(map_z))
		return

	if(!length(sweep_queue))
		for(var/area_ref in integrity_baseline)
			sweep_queue += area_ref

	// A full rescore every fire is too expensive
	var/swept = 0
	while(length(sweep_queue) && swept < AREA_INTEGRITY_SWEEP_BATCH)
		var/area_ref = sweep_queue[1]
		sweep_queue.Cut(1, 2)
		swept++
		var/area/checked_area = locate(area_ref)
		if(istype(checked_area))
			update_area_integrity(checked_area, area_ref, map_z)
		if(MC_TICK_CHECK)
			return

	refresh_in--
	if(refresh_in <= 0)
		refresh_in = WORK_ORDER_REFRESH_FIRES
		get_orders()

/datum/controller/subsystem/work_orders/proc/update_area_integrity(area/checked_area, area_ref, map_z)
	var/baseline = integrity_baseline[area_ref]
	if(!baseline)
		return
	// Same maths as /datum/objective/crew/integrity in engineering_objectives.dm
	var/list/survey = checked_area.get_structure_survey(map_z)
	var/percent = min(PERCENT(survey["score"] / baseline), 100)
	integrity_current[area_ref] = percent

	if(integrity_damaged[area_ref])
		if(percent >= AREA_INTEGRITY_CLEAR_AT)
			integrity_damaged -= area_ref
	else if(percent <= AREA_INTEGRITY_RAISE_AT)
		integrity_damaged[area_ref] = TRUE

	// a hole is a hole whatever share of the room it is
	if(survey["space"] > space_baseline[area_ref])
		breached[area_ref] = TRUE
	else
		breached -= area_ref

/datum/controller/subsystem/work_orders/proc/capture_area_integrity_baseline()
	integrity_baseline = list()
	integrity_current = list()
	integrity_damaged = list()
	space_baseline = list()
	breached = list()

	var/map_z = get_station_map_z()
	if(isnull(map_z))
		return

	for(var/area/checked_area as anything in GLOB.areas)
		if(!checked_area.raises_work_orders())
			continue
		var/list/survey = checked_area.get_structure_survey(map_z)
		if(survey["score"] > 0)
			var/area_ref = "[REF(checked_area)]"
			integrity_baseline[area_ref] = survey["score"]
			// Solars and exposed docks ship with a space count already
			space_baseline[area_ref] = survey["space"]
		CHECK_TICK

/// Gaps get judged against this
/datum/controller/subsystem/work_orders/proc/capture_coverage_baseline()
	coverage_baseline = list()
	var/list/working_air = get_air_alarm_coverage()["working"]

	for(var/area/checked_area as anything in GLOB.areas)
		if(!checked_area.raises_work_orders())
			continue
		var/list/healthy = list()
		if(checked_area.reports_atmosphere())
			if(working_air[checked_area])
				healthy += ALARM_ATMOS
			if(!checked_area.get_fire_alarm_coverage())
				healthy += ALARM_FIRE
		if(checked_area.reports_power() && checked_area.apc && !checked_area.apc.get_coverage_state())
			healthy += ALARM_POWER
			healthy += ALERT_LAYER_GRID
		if(length(healthy))
			coverage_baseline["[REF(checked_area)]"] = healthy
		CHECK_TICK

/datum/controller/subsystem/work_orders/proc/get_department_crew(department = /datum/department_group/engineering)
	if(crew_cache && crew_time == world.time && crew_cache_department == department)
		return crew_cache

	var/list/load = list()
	for(var/key in claims)
		var/datum/work_claim/claim = claims[key]
		if(claim.claimant_ckey)
			load[claim.claimant_ckey] += 1

	var/list/tally = get_record_tally()
	var/list/crew = list()
	for(var/mob/living/carbon/human/crewmember in GLOB.player_list)
		var/datum/job/role = crewmember.mind?.assigned_role
		if(!role || !(department in role.departments_list))
			continue
		var/crew_ckey = crewmember.ckey
		if(!crew_ckey)
			continue
		crew += list(list(
			"ckey" = crew_ckey,
			"name" = crewmember.get_work_claimant_name(),
			"job" = role.title,
			"openJobs" = load[crew_ckey] || 0,
			"completed" = tally[crew_ckey]?["completed"] || 0,
			"dropped" = tally[crew_ckey]?["dropped"] || 0,
		))

	crew_cache = crew
	crew_cache_department = department
	crew_time = world.time
	return crew_cache

/datum/controller/subsystem/work_orders/proc/announce_new_orders(count)
	for(var/datum/computer_file/program/alarm_monitor/monitor as anything in monitors)
		monitor.notify_new_orders(count)

/// Runs on board refresh, not the structural sweep. A venting room can't wait 30s.
/datum/controller/subsystem/work_orders/proc/check_pressure_fault(area_ref, obj/machinery/airalarm/sensor)
	//check air alarm pressure thresholds
	if(isnull(sensor) || !sensor.reports_pressure())
		pressure_faulted -= area_ref
		return null
	var/datum/gas_mixture/environment = sensor.get_enviroment()
	if(isnull(environment))
		pressure_faulted -= area_ref
		return null

	var/pressure = environment.return_pressure()
	if(pressure_faulted[area_ref])
		if(pressure > PRESSURE_CLEAR_LOW && pressure < PRESSURE_CLEAR_HIGH)
			pressure_faulted -= area_ref
			return null
	else if(pressure > PRESSURE_FAULT_LOW && pressure < PRESSURE_FAULT_HIGH)
		return null
	else
		pressure_faulted[area_ref] = TRUE

	return pressure <= PRESSURE_FAULT_LOW ? "lowpressure" : "highpressure"

/// Files a resolved claim
/datum/controller/subsystem/work_orders/proc/resolve_claim(key, outcome)
	var/datum/work_claim/claim = claims[key]
	if(!claim)
		return
	records += new /datum/work_record(claim, known_orders[key] || key, outcome)
	SSblackbox.record_feedback("tally", "work_orders_resolved", 1, outcome)
	if(length(records) > MAX_WORK_RECORDS)
		records.Cut(1, length(records) - MAX_WORK_RECORDS + 1)
	claims -= key

/// TRUE if this person is due another beep
/datum/controller/subsystem/work_orders/proc/can_beep_for_work(target_ckey)
	if(!target_ckey)
		return FALSE
	var/last = notify_cooldowns[target_ckey]
	if(last && world.time < last + WORK_NOTIFY_COOLDOWN)
		return FALSE
	notify_cooldowns[target_ckey] = world.time
	return TRUE

/datum/controller/subsystem/work_orders/proc/get_record_tally()
	var/list/tally = list()
	for(var/datum/work_record/record as anything in records)
		if(!record.claimant_ckey)
			continue
		var/list/entry = tally[record.claimant_ckey]
		if(!entry)
			entry = list("completed" = 0, "dropped" = 0)
			tally[record.claimant_ckey] = entry
		if(record.outcome == WORK_OUTCOME_COMPLETED)
			entry["completed"] += 1
		else if(record.outcome == WORK_OUTCOME_DROPPED)
			entry["dropped"] += 1
	return tally

#undef AREA_INTEGRITY_RAISE_AT
#undef AREA_INTEGRITY_CLEAR_AT
#undef AREA_INTEGRITY_SWEEP_BATCH
#undef WORK_ORDER_REFRESH_FIRES
#undef PRESSURE_FAULT_LOW
#undef PRESSURE_FAULT_HIGH
#undef PRESSURE_CLEAR_LOW
#undef PRESSURE_CLEAR_HIGH
#undef MAX_WORK_RECORDS
#undef WORK_NOTIFY_COOLDOWN
