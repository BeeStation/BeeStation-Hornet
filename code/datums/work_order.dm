/**
 * Work orders: jobs derived from station, and the claims people put against them.
 */

/// The "director" for a department. Going off of access as opposed to job singletons/datums/whatever.
GLOBAL_LIST_INIT(work_assign_access, list(
	"[/datum/department_group/engineering]" = ACCESS_CE,
))

/// Readout id + failure reason -> what the job actually is.
GLOBAL_LIST_INIT(work_order_tasks, list(
	// Life first, then power, then the things that only report on those.
	"[ALERT_LAYER_INTEGRITY]|breached" = list("task" = "Seal hull breach", "priority" = WORK_PRIORITY_CRITICAL),
	"[ALARM_ATMOS]|lowpressure" = list("task" = "Repressurise", "priority" = WORK_PRIORITY_CRITICAL),
	"[ALARM_ATMOS]|highpressure" = list("task" = "Vent overpressure", "priority" = WORK_PRIORITY_HIGH),
	"[ALERT_LAYER_GRID]|missing" = list("task" = "Replace APC", "priority" = WORK_PRIORITY_HIGH),
	"[ALERT_LAYER_GRID]|offline" = list("task" = "Repair APC", "priority" = WORK_PRIORITY_HIGH),
	"[ALERT_LAYER_GRID]|nocell" = list("task" = "Fit APC power cell", "priority" = WORK_PRIORITY_NORMAL),
	"[ALERT_LAYER_INTEGRITY]|damaged" = list("task" = "Repair structural damage", "priority" = WORK_PRIORITY_NORMAL),
	"[ALARM_ATMOS]|missing" = list("task" = "Replace air alarm", "priority" = WORK_PRIORITY_LOW),
	"[ALARM_ATMOS]|offline" = list("task" = "Repair air alarm", "priority" = WORK_PRIORITY_LOW),
	"[ALARM_FIRE]|missing" = list("task" = "Replace fire alarm", "priority" = WORK_PRIORITY_LOW),
	"[ALARM_FIRE]|offline" = list("task" = "Repair fire alarm", "priority" = WORK_PRIORITY_LOW),
))

/// The z-level everything on the alert map is scored against. Single z for now.
/proc/get_station_map_z()
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	return length(station_levels) ? station_levels[1] : null

/// A person's name vs their job
/datum/work_claim
	/// Who picked it up, by the name on their ID. Displayed by board
	var/claimant
	/// Who they actually are, so completion can find them wherever they've wandered off to.
	/// Could either attach to ckey or mind, but ckey works for this purpose for now
	var/claimant_ckey
	/// Who directed them to it, if anybody. Null if self assigned
	var/assigned_by
	var/assigned_by_ckey
	/// world.time the claim was made, so the board can show how long it's been sat on.
	var/claimed_at

/datum/work_claim/New(claimant, claimant_ckey, assigned_by, assigned_by_ckey)
	src.claimant = claimant
	src.claimant_ckey = claimant_ckey
	src.assigned_by = assigned_by
	src.assigned_by_ckey = assigned_by_ckey
	claimed_at = world.time

/// What became of a claim once it resolved.
/datum/work_record
	var/description
	var/claimant
	var/claimant_ckey
	/// Null if they took the job themselves
	var/assigned_by
	/// One of WORK_OUTCOME_COMPLETED, WORK_OUTCOME_DROPPED or WORK_OUTCOME_REASSIGNED.
	var/outcome
	var/claimed_at
	var/resolved_at

/datum/work_record/New(datum/work_claim/claim, description, outcome)
	src.description = description
	src.outcome = outcome
	claimant = claim.claimant
	claimant_ckey = claim.claimant_ckey
	assigned_by = claim.assigned_by
	claimed_at = claim.claimed_at
	resolved_at = world.time

/datum/work_claim/proc/get_assigner_mob()
	RETURN_TYPE(/mob)
	if(!assigned_by_ckey)
		return null
	return get_mob_by_ckey(assigned_by_ckey)

/datum/work_claim/proc/get_claimant_mob()
	RETURN_TYPE(/mob)
	if(!claimant_ckey)
		return null
	return get_mob_by_ckey(claimant_ckey)

/// Stable identity for a derived order
/proc/work_order_key(source_id, detail)
	return "[source_id]|[detail]"

/// Who may direct another person's work
/proc/can_assign_work(mob/user, department = /datum/department_group/engineering)
	if(!user)
		return FALSE
	var/required = GLOB.work_assign_access["[department]"]
	if(!required)
		return FALSE
	var/obj/item/card/id/id = user.get_idcard(FALSE)
	return id && (required in id.access)

/// Tells somebody they've been put on a job. Chat always lands, the beep is a bonus.
/proc/notify_work_assignment(mob/target, assigner, description)
	if(!target)
		return
	to_chat(target, span_notice("<b>[assigner]</b> has assigned you a work order: [description]."))

	if(!SSwork_orders.can_beep_for_work(target.ckey))
		return
	var/obj/item/modular_computer/device = locate() in target.GetAllContents()
	if(!device?.enabled)
		return
	for(var/datum/computer_file/program/alarm_monitor/monitor as anything in SSwork_orders.monitors)
		if(monitor.computer != device)
			continue
		monitor.alert_pending = TRUE
		device.alert_call(monitor, "Work order assigned: [description]", 'sound/machines/twobeep_high.ogg')
		return

/mob/proc/get_work_claimant_name()
	return name || "Unknown"

/// Humans sign with the name on their ID
/mob/living/carbon/human/get_work_claimant_name()
	return get_authentification_name()

//
// Coverage
//

/area/proc/reports_atmosphere()
	return expects_atmosphere && !outdoors

/area/proc/reports_power()
	return requires_power && !always_unpowered

/// Areas that are related to the station, but needed to be disqualified from showing up on workorders
/area/proc/raises_work_orders()
	// Areas can become space, and space can show up on the minimap otherwise...
	if(skip_minimap_rendering || outdoors)
		return FALSE
	// These show up in station, despite not being on map, so uh... blacklist
	return !istype(src, /area/shuttle)

/// Chambers are run to whatever pressure the work needs, so their alarms have the pressure thresholds pulled.
/obj/machinery/airalarm/proc/reports_pressure()
	var/datum/tlv/limits = tlv_collection?["pressure"]
	if(isnull(limits))
		return FALSE
	return limits.warning_min != TLV_VALUE_IGNORE || limits.warning_max != TLV_VALUE_IGNORE

/// Which areas have an air alarm, and which have one that can report.
/datum/controller/subsystem/work_orders/proc/get_air_alarm_coverage()
	if(air_coverage_cache && air_coverage_time == world.time)
		return air_coverage_cache

	var/list/present = list()
	var/list/working = list()
	var/list/unpowered = list()
	var/list/sensors = list()
	for(var/obj/machinery/airalarm/air_alarm as anything in GLOB.air_alarms)
		var/area/alarm_area = air_alarm.my_area
		if(isnull(alarm_area))
			continue
		present[alarm_area] = TRUE
		// Unpowered is the grid's problem
		if(air_alarm.machine_stat & NOPOWER)
			unpowered[alarm_area] = TRUE
			continue
		if(air_alarm.machine_stat & BROKEN)
			continue
		if(air_alarm.shorted || air_alarm.buildstage != AIR_ALARM_BUILD_COMPLETE)
			continue
		working[alarm_area] = TRUE
		// active_alarms[ALARM_ATMOS] latches and can sit green while the room is a vacuum.
		if(!sensors[alarm_area])
			sensors[alarm_area] = air_alarm

	air_coverage_cache = list("present" = present, "working" = working, "unpowered" = unpowered, "sensors" = sensors)
	air_coverage_time = world.time
	return air_coverage_cache

/// Null if this area has a fire alarm that can report, otherwise why it can't.
/area/proc/get_fire_alarm_coverage()
	if(!LAZYLEN(firealarms))
		return "missing"
	var/any_unpowered = FALSE
	for(var/obj/machinery/firealarm/fire_alarm as anything in firealarms)
		if(fire_alarm.machine_stat & NOPOWER)
			any_unpowered = TRUE
			continue
		if(fire_alarm.machine_stat & BROKEN)
			continue
		if(fire_alarm.buildstage != FIRE_ALARM_BUILD_SECURED)
			continue
		return null
	return any_unpowered ? "unpowered" : "offline"

/// Null if this APC is healthy, otherwise what's wrong with it.
/obj/machinery/power/apc/proc/get_coverage_state()
	if(machine_stat & BROKEN)
		return "offline"
	if(isnull(cell))
		return "nocell"
	return null

/area/proc/get_coverage_gaps(list/has_working_air_alarm)
	var/list/blind = list()
	var/list/baseline = SSwork_orders.coverage_baseline["[REF(src)]"]

	if(reports_atmosphere())
		if(!has_working_air_alarm[src])
			var/list/air = SSwork_orders.get_air_alarm_coverage()
			if(air["unpowered"][src])
				blind[ALARM_ATMOS] = "unpowered"
			else
				blind[ALARM_ATMOS] = air["present"][src] ? "offline" : "missing"
		var/fire_coverage = get_fire_alarm_coverage()
		if(fire_coverage)
			blind[ALARM_FIRE] = fire_coverage

	// Power alarms are raised by the APC, so both power readouts share its coverage.
	if(reports_power())
		var/apc_coverage = apc ? apc.get_coverage_state() : "missing"
		if(apc_coverage)
			blind[ALARM_POWER] = apc_coverage
			blind[ALERT_LAYER_GRID] = apc_coverage

	// Anything already broken at roundstart is how the map was built
	for(var/readout in blind)
		if(!(readout in baseline))
			blind[readout] = "asbuilt"

	return blind

/// "asbuilt" is how the map shipped. "unpowered" is the grid's fault
/proc/is_actionable_gap(reason)
	return reason && reason != "asbuilt" && reason != "unpowered"

// -----------------------------
//  Order derivation
// -----------------------------

/// Every outstanding job on the station. Settles once against everything the sources produced
/// source pruning its own would see the others as dead and fire false completions
/datum/controller/subsystem/work_orders/proc/get_orders()
	if(orders_cache && orders_time == world.time)
		return orders_cache

	var/list/orders = list()
	// Order key -> description, across every source.
	var/list/live_keys = list()

	derive_engineering_orders(orders, live_keys)

	settle_orders(live_keys)
	orders_cache = orders
	orders_time = world.time
	return orders_cache

/// Engineering source: alarm coverage regressions and structural damage
/datum/controller/subsystem/work_orders/proc/derive_engineering_orders(list/orders, list/live_keys)
	var/list/air = get_air_alarm_coverage()
	var/list/working_air = air["working"]

	// The integrity baseline is already every area with structure on the station z
	for(var/area_ref in integrity_baseline)
		var/area/checked_area = locate(area_ref)
		if(!istype(checked_area))
			continue

		var/list/blind = checked_area.get_coverage_gaps(working_air)
		var/list/faults = list()

		for(var/readout in blind)
			// Power alarms and the grid readout share one APC, so dont dupe the job
			if(readout == ALARM_POWER)
				continue
			if(!is_actionable_gap(blind[readout]))
				continue
			faults[readout] = blind[readout]

		// A breach outranks general wear: it is the same readout, and sealing comes first
		if(breached[area_ref])
			faults[ALERT_LAYER_INTEGRITY] = "breached"
		else if(integrity_damaged[area_ref])
			faults[ALERT_LAYER_INTEGRITY] = "damaged"

		// Only a job where a sensor can read it. A blind area is a coverage gap, raised above
		if(!faults[ALARM_ATMOS] && checked_area.reports_atmosphere())
			var/pressure_fault = check_pressure_fault(area_ref, air["sensors"][checked_area])
			if(pressure_fault)
				faults[ALARM_ATMOS] = pressure_fault

		for(var/readout in faults)
			var/list/definition = GLOB.work_order_tasks["[readout]|[faults[readout]]"]
			if(!definition)
				continue
			var/task = definition["task"]
			var/key = work_order_key(area_ref, readout)
			// store the description so completion can name it
			live_keys[key] = "[task] in [get_area_name(checked_area, TRUE)]"
			var/datum/work_claim/claim = claims[key]
			orders += list(list(
				"key" = key,
				"areaRef" = area_ref,
				"area" = get_area_name(checked_area, TRUE),
				"task" = task,
				"priority" = definition["priority"],
				"claimant" = claim?.claimant,
				"assignedBy" = claim?.assigned_by,
				"claimedAt" = claim ? claim.claimed_at : null,
			))
		CHECK_TICK

/// Diffs against the last set
/datum/controller/subsystem/work_orders/proc/settle_orders(list/live_keys)
	for(var/key in known_orders)
		if(live_keys[key])
			continue
		// whatever raised it is no longer true
		var/datum/work_claim/claim = claims[key]
		if(claim)
			if(claim.claimant_ckey)
				completed_by[claim.claimant_ckey] += 1
			var/mob/claimant_mob = claim.get_claimant_mob()
			if(claimant_mob)
				to_chat(claimant_mob, span_notice("Work order complete: [known_orders[key]]."))
			// Tell whoever assigned it too. "Your trunkmonkey did his job"
			var/mob/assigner = claim.get_assigner_mob()
			if(assigner && assigner != claimant_mob)
				to_chat(assigner, span_notice("[claim.claimant] completed the work order you assigned: [known_orders[key]]."))
			resolve_claim(key, WORK_OUTCOME_COMPLETED)

	var/raised = 0
	for(var/key in live_keys)
		if(!known_orders[key])
			raised++

	known_orders = live_keys.Copy()

	if(raised)
		announce_new_orders(raised)
