
/datum/starter_ship_template
	/// The template that this ship will spawn
	var/datum/map_template/spawned_template
	/// The amount of points that this template will cost
	var/template_cost
	/// The list of job roles available on this ship
	var/list/job_roles = list(
		/datum/job/assistant
	)
