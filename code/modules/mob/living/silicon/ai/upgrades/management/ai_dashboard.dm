/datum/ai_dashboard
	var/mob/living/silicon/ai/owner

	var/available_projects

	//What we're currently using, not what we're being granted by the ai data core
	var/list/cpu_usage
	var/list/ram_usage

	var/completed_projects

	var/running_projects

/datum/ai_dashboard/New(mob/living/silicon/ai/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner
	available_projects = list()
	completed_projects = list()
	running_projects = list()
	cpu_usage = list()
	ram_usage = list()

	for(var/path in subtypesof(/datum/ai_project))
		available_projects += new path(owner, src)


/datum/ai_dashboard/proc/is_interactable(mob/user)
	if(user != owner || owner.incapacitated())
		return FALSE
	if(owner.control_disabled)
		to_chat(user, "<span class = 'warning'>Wireless control is disabled.</span>")
		return FALSE
	return TRUE

/datum/ai_dashboard/ui_status(mob/user)
	if(is_interactable(user))
		return ..()
	return UI_CLOSE

/datum/ai_dashboard/ui_state(mob/user)
	return GLOB.always_state

/datum/ai_dashboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiDashboard")
		ui.open()

/datum/ai_dashboard/ui_data(mob/user)
	if(!owner || user != owner)
		return
	var/list/data = list()

	data["current_cpu"] = GLOB.ai_os.cpu_assigned[owner] ? GLOB.ai_os.cpu_assigned[owner] : 0
	data["current_ram"] = GLOB.ai_os.ram_assigned[owner] ? GLOB.ai_os.ram_assigned[owner] : 0

	var/total_cpu_used = 0
	for(var/I in cpu_usage)
		total_cpu_used += cpu_usage[I]

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	data["used_cpu"] = total_cpu_used
	data["used_ram"] = total_ram_used

	data["max_cpu"] = GLOB.ai_os.total_cpu
	data["max_ram"] = GLOB.ai_os.total_ram

	data["categories"] = GLOB.ai_project_categories
	data["available_projects"] = list()

	var/turf/current_turf = get_turf(owner)

	data["integrity"] = owner.health

	data["location_name"] = get_area(current_turf)

	data["location_coords"] = "[current_turf.x], [current_turf.y], [current_turf.z]"
	var/datum/gas_mixture/env = current_turf.return_air()
	data["temperature"] = env.return_temperature()

	for(var/datum/ai_project/AP as anything in available_projects)
		data["available_projects"] += list(list("name" = AP.name, "description" = AP.description, "ram_required" = AP.ram_required, "available" = AP.canResearch(), "research_cost" = AP.research_cost, "research_progress" = AP.research_progress,
		"assigned_cpu" = cpu_usage[AP.name] ? cpu_usage[AP.name] : 0, "research_requirements" = AP.research_requirements, "category" = AP.category))


	data["completed_projects"] = list()
	for(var/datum/ai_project/P as anything in completed_projects)
		data["completed_projects"] += list(list("name" = P.name, "description" = P.description, "ram_required" = P.ram_required, "running" = P.running, "category" = P.category))

	return data

/datum/ai_dashboard/ui_act(action, params)
	if(..())
		return
	if(!is_interactable(usr))
		return

	switch(action)
		if("run_project")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(!project || !run_project(project))
				to_chat(owner, "<span class = 'warning'>Unable to run the program '[params["project_name"]].'</span>")
			else
				to_chat(owner, "<span class = 'notice'>Spinning up instance of [params["project_name"]]...</span>")
				. = TRUE
		if("stop_project")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])
			if(project)
				stop_project(project)
				to_chat(owner, "<span class = 'notice'>Instance of [params["project_name"]] succesfully ended.</span>")
				. = TRUE
		if("allocate_cpu")
			var/datum/ai_project/project = get_project_by_name(params["project_name"])

			if(!project || !set_project_cpu(project, text2num(params["amount"])))
				to_chat(owner, "<span class = 'warning'>Unable to add CPU to [params["project_name"]]. Either not enough free CPU or project is unavailable.</span>")
			. = TRUE

/datum/ai_dashboard/proc/get_project_by_name(project_name, only_available = FALSE)
	for(var/datum/ai_project/AP as anything in available_projects)
		if(AP.name == project_name)
			return AP
	if(!only_available)
		for(var/datum/ai_project/AP as anything in completed_projects)
			if(AP.name == project_name)
				return AP

	return FALSE

/datum/ai_dashboard/proc/set_project_cpu(datum/ai_project/project, amount)
	var/current_cpu = GLOB.ai_os.cpu_assigned[owner] ? GLOB.ai_os.cpu_assigned[owner] : 0
	if(!project.canResearch())
		return FALSE

	if(amount < 0)
		return FALSE

	var/total_cpu_used = 0
	for(var/I in cpu_usage)
		if(I == project.name)
			continue
		total_cpu_used += cpu_usage[I]


	if((current_cpu - total_cpu_used) >= amount)
		cpu_usage[project.name] = amount
		return TRUE
	return FALSE


/datum/ai_dashboard/proc/run_project(datum/ai_project/project)
	var/current_ram = GLOB.ai_os.ram_assigned[owner] ? GLOB.ai_os.ram_assigned[owner] : 0

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]

	if(current_ram - total_ram_used >= project.ram_required && project.canRun())
		project.run_project()
		ram_usage[project.name] += project.ram_required
		return TRUE
	return FALSE

/datum/ai_dashboard/proc/stop_project(datum/ai_project/project)
	project.stop()
	if(ram_usage[project.name])
		ram_usage[project.name] -= project.ram_required
		return project.ram_required

	return FALSE

/datum/ai_dashboard/proc/has_completed_projects(project_name)
	for(var/datum/ai_project/P as anything in completed_projects)
		if(P.name == project_name)
			return TRUE
	return FALSE


/datum/ai_dashboard/proc/finish_project(datum/ai_project/project, notify_user = TRUE)
	available_projects -= project
	completed_projects += project
	cpu_usage[project.name] = 0
	if(notify_user)
		to_chat(owner, "<span class = 'notice'>[project] has been completed. User input required.</span>")


//Stuff is handled in here per tick :)
/datum/ai_dashboard/proc/tick(seconds)
	var/current_cpu = GLOB.ai_os.cpu_assigned[owner] ? GLOB.ai_os.cpu_assigned[owner] : 0
	var/current_ram = GLOB.ai_os.ram_assigned[owner] ? GLOB.ai_os.ram_assigned[owner] : 0

	var/total_ram_used = 0
	for(var/I in ram_usage)
		total_ram_used += ram_usage[I]
	var/total_cpu_used = 0
	for(var/I in cpu_usage)
		total_cpu_used += cpu_usage[I]

	var/reduction_of_resources = FALSE


	if(total_ram_used > current_ram)
		for(var/I in ram_usage)
			var/datum/ai_project/project = get_project_by_name(I)
			total_ram_used -= stop_project(project)
			reduction_of_resources = TRUE
			if(total_ram_used <= current_ram)
				break
		if(total_ram_used > current_ram)
			message_admins("this is still broken. dashboard-ram")

	if(total_cpu_used > current_cpu)
		var/amount_needed = total_cpu_used - current_cpu
		for(var/I in cpu_usage)

			if(cpu_usage[I] >= amount_needed)
				cpu_usage[I] -= amount_needed
				reduction_of_resources = TRUE
				total_cpu_used -= amount_needed
				break
			if(cpu_usage[I])
				total_cpu_used -= cpu_usage[I]
				amount_needed -= cpu_usage[I]
				cpu_usage[I] = 0
				reduction_of_resources = TRUE
				if(total_cpu_used <= current_cpu)
					break
		if(total_cpu_used > current_cpu)
			message_admins("this is still broken. dashboard-cpu")

	if(reduction_of_resources)
		to_chat(owner, "<span class = 'warning'>Lack of computational capacity. Some programs may have been stopped.</span>")

	for(var/project_being_researched in cpu_usage)
		if(!cpu_usage[project_being_researched])
			continue
		var/used_cpu = round(cpu_usage[project_being_researched] * seconds, 1)
		var/datum/ai_project/project = get_project_by_name(project_being_researched, TRUE)
		if(!project)
			cpu_usage[project_being_researched] = 0
			continue
		project.research_progress += used_cpu
		if(project.research_progress > project.research_cost)
			finish_project(project)
