
/datum/starter_ship_template
	/// The template that this ship will spawn
	var/datum/map_template/shuttle/spawned_template
	/// The amount of points that this template will cost
	var/template_cost
	/// The list of job roles available on this ship
	var/list/job_roles = list(
		/datum/job/captain = 1,
		/datum/job/assistant = 4,
	)

/datum/starter_ship_template/New()
	. = ..()
	for (var/template_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[template_id]
		if (template.type == spawned_template)
			spawned_template = template
			return
	spawned_template = null
