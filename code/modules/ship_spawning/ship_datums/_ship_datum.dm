
/datum/starter_ship_template
	var/faction_flags
	/// The template that this ship will spawn
	var/datum/map_template/shuttle/spawned_template
	/// The amount of points that this template will cost
	var/template_cost
	/// The list of job roles available on this ship
	/// There should be at least one spawn point for each
	/// role, or players will spawn in random locations.
	var/list/job_roles = list(
		/datum/job/captain = 1,
		/datum/job/medical_doctor = 2,
		/datum/job/security_officer = 2,
		/datum/job/station_engineer = 4,
		/datum/job/assistant = INFINITY,
	)
	var/description = ""

/datum/starter_ship_template/New()
	. = ..()
	for (var/template_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[template_id]
		if (template.type == spawned_template)
			spawned_template = template
			return
	spawned_template = null

/datum/map_template/shuttle/ship
	prefix = "_maps/shuttles/"
	port_id = "ships"
	can_be_bought = FALSE
