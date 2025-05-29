/datum/component/nanites
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/mob/living/host_mob
	/// The amount of nanites in the system
	var/nanite_volume = 0
	/// How many nanites we generate per second, up to the nutrition rate
	var/regen_rate = 1
	/// Multiplier to cooldowns
	var/cooldown_multiplier = 1
	/// How much nanite consumption applies to nutrition (at 20%, 5 nanites consumed = 1 nutrition consumed)
	var/nutrition_rate = 0.2
	/// The amount of nanites we produce relative to the mobs hunger level
	var/max_production_ratio = 1
	/// At what point will nanites be unable to trigger.
	var/safety_threshold = 50
	/// 0 if not connected to the cloud, 1-100 to set a determined cloud backup to draw from
	var/cloud_id = 0
	/// if false, won't sync to the cloud
	var/cloud_active = TRUE
	var/list/datum/nanite_program/programs = list()
	var/max_programs = NANITE_PROGRAM_LIMIT
	COOLDOWN_DECLARE(next_sync)
	COOLDOWN_DECLARE(emp_disabled)

	var/list/datum/nanite_program/protocol/protocols = list() /// Separate list of protocol programs, to avoid looping through the whole programs list when cheking for conflicts
	var/start_time = 0 ///Timestamp to when the nanites were first inserted in the host
	var/stealth = FALSE //if TRUE, does not appear on HUDs and health scans
	var/diagnostics = TRUE //if TRUE, displays program list when scanned by nanite scanners

/datum/component/nanites/Initialize(amount = 100, cloud = 0)
	if(!isliving(parent) && !istype(parent, /datum/nanite_cloud_backup))
		return COMPONENT_INCOMPATIBLE

	nanite_volume = amount
	cloud_id = cloud

	//Nanites without hosts are non-interactive through normal means
	if(isliving(parent))
		host_mob = parent

		if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes) && !HAS_TRAIT(host_mob, TRAIT_NANITECOMPATIBLE)) //Shouldn't happen, but this avoids HUD runtimes in case a silicon gets them somehow.
			return COMPONENT_INCOMPATIBLE

		start_time = world.time

		host_mob.hud_set_nanite_indicator()
		START_PROCESSING(SSnanites, src)

		if(cloud_id && cloud_active)
			cloud_sync()

/datum/component/nanites/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HAS_NANITES, PROC_REF(confirm_nanites))
	RegisterSignal(parent, COMSIG_NANITE_IS_STEALTHY, PROC_REF(check_stealth))
	RegisterSignal(parent, COMSIG_NANITE_DELETE, PROC_REF(delete_nanites))
	RegisterSignal(parent, COMSIG_NANITE_UI_DATA, PROC_REF(nanite_ui_data))
	RegisterSignal(parent, COMSIG_NANITE_GET_PROGRAMS, PROC_REF(get_programs))
	RegisterSignal(parent, COMSIG_NANITE_SET_VOLUME, PROC_REF(set_volume))
	RegisterSignal(parent, COMSIG_NANITE_ADJUST_VOLUME, PROC_REF(adjust_nanites))
	RegisterSignal(parent, COMSIG_NANITE_SET_CLOUD, PROC_REF(set_cloud))
	RegisterSignal(parent, COMSIG_NANITE_SET_CLOUD_SYNC, PROC_REF(set_cloud_sync))
	RegisterSignal(parent, COMSIG_NANITE_SET_SAFETY, PROC_REF(set_safety))
	RegisterSignal(parent, COMSIG_NANITE_SET_REGEN, PROC_REF(set_regen))
	RegisterSignal(parent, COMSIG_NANITE_ADD_PROGRAM, PROC_REF(add_program))
	RegisterSignal(parent, COMSIG_NANITE_SCAN, PROC_REF(nanite_scan))
	RegisterSignal(parent, COMSIG_NANITE_SYNC, PROC_REF(sync))

	if(isliving(parent))
		RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
		RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_death))
		RegisterSignal(parent, COMSIG_MOB_TRIED_ACCESS, PROC_REF(check_access))
		RegisterSignal(parent, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_shock))
		RegisterSignal(parent, COMSIG_SPECIES_GAIN, PROC_REF(check_viable_biotype))
		RegisterSignal(parent, COMSIG_NANITE_SIGNAL, PROC_REF(receive_signal))
		RegisterSignal(parent, COMSIG_NANITE_COMM_SIGNAL, PROC_REF(receive_comm_signal))

/datum/component/nanites/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HAS_NANITES,
								COMSIG_NANITE_IS_STEALTHY,
								COMSIG_NANITE_DELETE,
								COMSIG_NANITE_UI_DATA,
								COMSIG_NANITE_GET_PROGRAMS,
								COMSIG_NANITE_SET_VOLUME,
								COMSIG_NANITE_ADJUST_VOLUME,
								COMSIG_NANITE_SET_CLOUD,
								COMSIG_NANITE_SET_CLOUD_SYNC,
								COMSIG_NANITE_SET_SAFETY,
								COMSIG_NANITE_SET_REGEN,
								COMSIG_NANITE_ADD_PROGRAM,
								COMSIG_NANITE_SCAN,
								COMSIG_NANITE_SYNC,
								COMSIG_ATOM_EMP_ACT,
								COMSIG_MOB_DEATH,
								COMSIG_MOB_TRIED_ACCESS,
								COMSIG_LIVING_ELECTROCUTE_ACT,
								COMSIG_LIVING_MINOR_SHOCK,
								COMSIG_MOVABLE_HEAR,
								COMSIG_SPECIES_GAIN,
								COMSIG_NANITE_SIGNAL,
								COMSIG_NANITE_COMM_SIGNAL))

/datum/component/nanites/Destroy()
	STOP_PROCESSING(SSnanites, src)
	QDEL_LIST(programs)
	if(host_mob)
		set_nanite_bar(TRUE)
		host_mob.hud_set_nanite_indicator()
	host_mob = null
	return ..()

/datum/component/nanites/InheritComponent(datum/component/nanites/new_nanites, i_am_original, amount, cloud)
	if(new_nanites)
		adjust_nanites(amount = new_nanites.nanite_volume)
	else
		adjust_nanites(amount = amount) //just add to the nanite volume

/datum/component/nanites/process(delta_time)
	if(!IS_IN_STASIS(host_mob))
		var/nanites_gained = (regen_rate + (SSresearch.science_tech.researched_nodes["nanite_harmonic"] ? HARMONIC_REGEN_BOOST : 0)) * delta_time
		// Cannot gain more nanites than we have nutrition
		nanites_gained = min(nanites_gained, (host_mob.nutrition * max_production_ratio) - nanite_volume)
		// Gain nanites
		adjust_nanites(amount = nanites_gained)
		// Consume hunger
		host_mob.adjust_nutrition(-nanites_gained * nutrition_rate * 0.1)
		add_research()
		for(var/datum/nanite_program/program as anything in programs)
			program.on_process()
		if(cloud_id && cloud_active && COOLDOWN_FINISHED(src, next_sync))
			cloud_sync()
			COOLDOWN_START(src, next_sync, NANITE_SYNC_DELAY)
	set_nanite_bar()


/// Deletes nanites!
/datum/component/nanites/proc/delete_nanites()
	SIGNAL_HANDLER

	qdel(src)

/// Syncs the nanite component to another, making it so programs are the same with the same programming (except activation status)
/datum/component/nanites/proc/sync(datum/signal_source, datum/component/nanites/source, full_overwrite = TRUE, copy_settings = TRUE, copy_activation = FALSE)
	SIGNAL_HANDLER

	var/list/programs_to_remove = programs.Copy()
	var/list/programs_to_add = source.programs.Copy()
	for(var/datum/nanite_program/current_program as anything in programs)
		for(var/datum/nanite_program/new_program as anything in programs_to_add)
			if(current_program.type == new_program.type)
				programs_to_remove -= current_program
				programs_to_add -= new_program
				new_program.copy_programming(current_program, copy_activation)
				break
	if(full_overwrite)
		for(var/X in programs_to_remove)
			qdel(X)
	if(copy_settings)
		cloud_active = source.cloud_active
		cloud_id = source.cloud_id
		safety_threshold = source.safety_threshold
	for(var/X in programs_to_add)
	for(var/datum/nanite_program/program as anything in programs_to_add)
		add_program(new_program = program.copy())

/// Syncs the nanites to their assigned cloud copy, if it is available. If it is not, there is a small chance of a software error instead.
/datum/component/nanites/proc/cloud_sync()
	if(cloud_id)
		var/datum/nanite_cloud_backup/backup = SSnanites.get_cloud_backup(cloud_id)
		if(backup)
			var/datum/component/nanites/cloud_copy = backup.nanites
			if(cloud_copy)
				sync(source = cloud_copy)
				return
	//Without cloud syncing nanites can accumulate errors and/or defects
	if(prob(8) && programs.len)
		var/datum/nanite_program/NP = pick(programs)
		NP.software_error()

/// Adds a nanite program, replacing existing unique programs of the same type. A source program can be specified to copy its programming onto the new one.
/datum/component/nanites/proc/add_program(datum/source, datum/nanite_program/new_program, datum/nanite_program/source_program)
	SIGNAL_HANDLER

	for(var/datum/nanite_program/program as anything in programs)
		if(program.unique && program.type == new_program.type)
			qdel(program)
	if(programs.len >= max_programs)
		return COMPONENT_PROGRAM_NOT_INSTALLED
	if(source_program)
		source_program.copy_programming(new_program)
	programs += new_program
	new_program.on_add(src)
	return COMPONENT_PROGRAM_INSTALLED

/datum/component/nanites/proc/consume_nanites(amount, force = FALSE)
	if(!force && safety_threshold && (nanite_volume - amount < safety_threshold))
		return FALSE
	host_mob.adjust_nutrition(-amount)
	adjust_nanites(amount = -amount)
	return (nanite_volume > 0)

/// Modifies the current nanite volume, then checks if the nanites are depleted or exceeding the maximum amount
/datum/component/nanites/proc/adjust_nanites(datum/source, amount)
	SIGNAL_HANDLER
	nanite_volume = min(nanite_volume + amount, host_mob.nutrition * max_production_ratio)

/// Updates the nanite volume bar visible in diagnostic HUDs
/datum/component/nanites/proc/set_nanite_bar(remove = FALSE)
	var/image/holder = host_mob.hud_list[DIAG_NANITE_FULL_HUD]
	var/icon/I = icon(host_mob.icon, host_mob.icon_state, host_mob.dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = null
	if(remove || stealth)
		return //bye icon
	var/nanite_percent = (nanite_volume / NUTRITION_LEVEL_FULL) * 100
	nanite_percent = clamp(CEILING(nanite_percent, 10), 10, 100)
	holder.icon_state = "nanites[nanite_percent]"

/datum/component/nanites/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER

	// Lose some nanites
	adjust_nanites(amount = -(rand(50, 200)))
	// Freeze the nanites for this amount of time
	COOLDOWN_START(src, emp_disabled, 60 SECONDS / severity)
	// Run EMP effects
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		NP.on_emp(severity)


/datum/component/nanites/proc/on_shock(datum/source, shock_damage, shock_source, siemens_coeff = 1, safety = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	SIGNAL_HANDLER

	if(illusion || shock_damage < 1)
		return

	if(!HAS_TRAIT_NOT_FROM(host_mob, TRAIT_SHOCKIMMUNE, "nanites"))
		adjust_nanites(amount = -(rand(50, 200)))			// Lose 50 - 200 nanites

/datum/component/nanites/proc/check_stealth(datum/source)
	SIGNAL_HANDLER

	return stealth

/datum/component/nanites/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	for(var/datum/nanite_program/program as anything in programs)
		program.on_death(gibbed)

/datum/component/nanites/proc/receive_signal(datum/source, code, signal_source = "an unidentified source")
	SIGNAL_HANDLER

	for(var/datum/nanite_program/program as anything in programs)
		program.receive_nanite_signal(code, signal_source)

/datum/component/nanites/proc/receive_comm_signal(datum/source, comm_code, comm_message, comm_source = "an unidentified source")
	SIGNAL_HANDLER

	for(var/datum/nanite_program/comm/program in programs)
		program.receive_comm_signal(comm_code, comm_message, comm_source)

/datum/component/nanites/proc/check_viable_biotype()
	SIGNAL_HANDLER

	if(!(MOB_ORGANIC in host_mob.mob_biotypes) && !(MOB_UNDEAD in host_mob.mob_biotypes) && !HAS_TRAIT(host_mob, TRAIT_NANITECOMPATIBLE))
		qdel(src) //bodytype no longer sustains nanites

/datum/component/nanites/proc/check_access(datum/source, obj/O)
	SIGNAL_HANDLER

	for(var/datum/nanite_program/access/access_program in programs)
		if(access_program.activated)
			return O.check_access_list(access_program.nanite_access)
		else
			return FALSE
	return FALSE

/datum/component/nanites/proc/set_volume(datum/source, amount)
	SIGNAL_HANDLER

	nanite_volume = clamp(amount, 0, host_mob.nutrition * max_production_ratio)

/datum/component/nanites/proc/set_cloud(datum/source, amount)
	SIGNAL_HANDLER

	cloud_id = clamp(amount, 0, 100)

/datum/component/nanites/proc/set_cloud_sync(datum/source, method)
	SIGNAL_HANDLER

	switch(method)
		if(NANITE_CLOUD_TOGGLE)
			cloud_active = !cloud_active
		if(NANITE_CLOUD_DISABLE)
			cloud_active = FALSE
		if(NANITE_CLOUD_ENABLE)
			cloud_active = TRUE

/datum/component/nanites/proc/set_safety(datum/source, amount)
	SIGNAL_HANDLER

	safety_threshold = clamp(amount, 0, NUTRITION_LEVEL_FULL)

/datum/component/nanites/proc/set_regen(datum/source, amount)
	SIGNAL_HANDLER

	regen_rate = amount

/datum/component/nanites/proc/confirm_nanites()
	SIGNAL_HANDLER

	return TRUE //yup i exist

/datum/component/nanites/proc/get_data(list/nanite_data)
	nanite_data["nanite_volume"] = nanite_volume
	nanite_data["max_nanites"] = NUTRITION_LEVEL_FULL
	nanite_data["cloud_id"] = cloud_id
	nanite_data["regen_rate"] = regen_rate
	nanite_data["safety_threshold"] = safety_threshold
	nanite_data["stealth"] = stealth

/datum/component/nanites/proc/get_programs(datum/source, list/nanite_programs)
	SIGNAL_HANDLER

	nanite_programs |= programs

/datum/component/nanites/proc/add_research()
	var/research_value = NANITE_BASE_RESEARCH
	if(!ishuman(host_mob))
		if(!iscarbon(host_mob))
			research_value *= 0.4
		else
			research_value *= 0.8
	if(!host_mob.client)
		research_value *= 0.5
	if(host_mob.stat == DEAD)
		research_value *= 0.75
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_NANITES = research_value))

/datum/component/nanites/proc/nanite_scan(datum/source, mob/user, full_scan)
	SIGNAL_HANDLER

	var/list/message = list()

	if(!full_scan)
		. = TRUE
		if(!stealth)
			message += span_infobold("Nanites Detected")
			message += span_info("Saturation: [nanite_volume]/[NUTRITION_LEVEL_FULL]")
	else
		message += span_infobold("Nanites Detected")
		message += span_info("================")
		var/nanites_gained = (regen_rate + (SSresearch.science_tech.researched_nodes["nanite_harmonic"] ? HARMONIC_REGEN_BOOST : 0)) * delta_time
		message += span_info("Saturation: [nanite_volume]/[NUTRITION_LEVEL_FULL] ([nanites_gained >= 0 ? "+[nanites_gained]" : nanites_gained]/s)")
		message += span_info("Safety Threshold: [safety_threshold]")
		message += span_info("Cloud ID: [cloud_id ? cloud_id : "None"]")
		message += span_info("Cloud Sync: [cloud_active ? "Active" : "Disabled"]")
		message += span_info("================")
		message += span_info("Program List:")
		if(!diagnostics)
			message += span_alert("Diagnostics Disabled")
		else
			for(var/datum/nanite_program/program as anything in programs)
				if (program.next_trigger > world.time)
					var/cooldown = "(Cooldown: [DisplayTimeText((program.next_trigger - world.time) * cooldown_multiplier)])"
					message += span_info("<b>[program.name]</b> | [program.activated ? span_green("Active [cooldown]") : span_red("Inactive [cooldown]")]")
				else
					message += span_info("<b>[program.name]</b> | [program.activated ? span_green("Active") : span_red("Inactive")]")
				for(var/datum/nanite_rule/rule as anything in program.rules)
					message += "<span class='[rule.check_rule() ? "green" : "red"]'>[GLOB.TAB][rule.display()]</span>"
		. = TRUE
	if(length(message))
		to_chat(user, examine_block(jointext(message, "\n")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/datum/component/nanites/proc/nanite_ui_data(datum/source, list/data, scan_level)
	SIGNAL_HANDLER

	data["has_nanites"] = TRUE
	data["nanite_volume"] = nanite_volume
	data["regen_rate"] = regen_rate + (SSresearch.science_tech.researched_nodes["nanite_harmonic"] ? HARMONIC_REGEN_BOOST : 0)
	data["safety_threshold"] = safety_threshold
	data["cloud_id"] = cloud_id
	data["cloud_active"] = cloud_active
	var/list/mob_programs = list()
	var/id = 1
	for(var/datum/nanite_program/program as anything in programs)
		var/list/mob_program = list()
		mob_program["name"] = program.name
		mob_program["desc"] = program.desc
		mob_program["id"] = id

		if(scan_level >= 2)
			mob_program["activated"] = program.activated
			mob_program["use_rate"] = program.use_rate
			mob_program["can_trigger"] = program.can_trigger
			mob_program["trigger_cost"] = program.trigger_cost
			mob_program["trigger_cooldown"] = program.trigger_cooldown / 10
			mob_program["maximum_duration"] = program.maximum_duration / 10

		if(scan_level >= 3)
			mob_program["timer_restart"] = program.timer_restart / 10
			mob_program["timer_shutdown"] = program.timer_shutdown / 10
			mob_program["timer_trigger_delay"] = program.timer_trigger_delay / 10
			var/list/extra_settings = program.get_extra_settings_frontend()
			mob_program["extra_settings"] = extra_settings
			if(LAZYLEN(extra_settings))
				mob_program["has_extra_settings"] = TRUE
			else
				mob_program["has_extra_settings"] = FALSE

		if(scan_level >= 4)
			mob_program["activation_code"] = program.activation_code
			mob_program["deactivation_code"] = program.deactivation_code
			mob_program["kill_code"] = program.kill_code
			mob_program["trigger_code"] = program.trigger_code
			var/list/rules = list()
			var/rule_id = 1
			for(var/datum/nanite_rule/nanite_rule as anything in program.rules)
				var/list/rule = list()
				rule["display"] = nanite_rule.display()
				rule["program_id"] = id
				rule["id"] = rule_id
				rules += list(rule)
				rule_id++
			mob_program["rules"] = rules
			if(LAZYLEN(rules))
				mob_program["has_rules"] = TRUE
		id++
		mob_programs += list(mob_program)
	data["mob_programs"] = mob_programs
