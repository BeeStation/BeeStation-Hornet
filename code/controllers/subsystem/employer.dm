/**
 * SSemployer
 *
 * Procs of interest:
 *   - get_employer(id)                    — look up an employer datum by id
 *   - get_employer_id_for_department(id)  — look up which employer owns a department
 *   - build_tgui_payload()                — serialise employers for a TGUI UI
 */
SUBSYSTEM_DEF(employer)
	name = "Employers"
	init_stage = INITSTAGE_EARLY
	flags = SS_NO_FIRE

	/// Every successfully-instantiated /datum/employer_group, sorted by pref_order ascending
	var/list/employer_datums

/datum/controller/subsystem/employer/Initialize(timeofday)
	employer_datums = list()
	var/list/seen_ids = list()
	var/list/seen_depts = list()

	for(var/datum/employer_group/each_type as anything in subtypesof(/datum/employer_group))
		var/datum/employer_group/employer = new each_type()

		if(!employer.id)
			stack_trace("Employer group [each_type] has no id; skipping.")
			continue
		if(seen_ids[employer.id])
			stack_trace("Duplicate employer id '[employer.id]' on [each_type].")
			continue
		seen_ids[employer.id] = TRUE

		// Warn (but still register) on department collisions.
		for(var/dept_id in employer.department_ids)
			if(seen_depts[dept_id])
				stack_trace("Department '[dept_id]' is claimed by both \
					'[seen_depts[dept_id]]' and '[employer.id]'.")
				continue
			seen_depts[dept_id] = employer.id

		employer_datums += employer

	// Selection-sort by pref_order ascending. The list is tiny, so this is fine.
	var/list/sorted = list()
	while(length(employer_datums))
		var/datum/employer_group/best
		for(var/datum/employer_group/candidate as anything in employer_datums)
			if(!best || candidate.pref_order < best.pref_order)
				best = candidate
		sorted += best
		employer_datums -= best
	employer_datums = sorted

	return SS_INIT_SUCCESS

/// Returns the /datum/employer_group for the given id, or null if not found.
/datum/controller/subsystem/employer/proc/get_employer(id)
	if(!id)
		return null
	for(var/datum/employer_group/employer as anything in employer_datums)
		if(employer.id == id)
			return employer
	return null

/// Returns the employer_id (string) that owns the given dept_id, or null.
/datum/controller/subsystem/employer/proc/get_employer_id_for_department(dept_id)
	if(!dept_id)
		return null
	for(var/datum/employer_group/employer as anything in employer_datums)
		if(dept_id in employer.department_ids)
			return employer.id
	return null

/// Returns a list thingy for shipping to TGUI.
/datum/controller/subsystem/employer/proc/build_tgui_payload()
	var/list/payload = list()
	var/list/order   = list()

	for(var/datum/employer_group/employer as anything in employer_datums)
		order += employer.id
		payload[employer.id] = list(
			"id"               = employer.id,
			"display_name"     = employer.display_name,
			"lore"             = employer.lore,
			"colour"           = employer.colour,
			"logo_icon"        = employer.logo_icon ? "[employer.logo_icon]" : null,
			"logo_icon_state"  = employer.logo_icon_state,
			"department_ids"   = employer.department_ids.Copy(),
		)

	return list("employers" = payload, "employer_order" = order)
