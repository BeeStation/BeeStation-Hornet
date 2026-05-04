/datum/admins/proc/dynamic_panel()
	set name = "Dynamic Panel"
	set category = "Round"

	var/static/datum/dynamic_panel/dynamic_panel = new
	dynamic_panel.ui_interact(usr)

/datum/dynamic_panel

/datum/dynamic_panel/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA_STATIC, PROC_REF(update_static_data))
	RegisterSignal(SSdcs, COMSIG_GLOB_UPDATE_DYNAMICPANEL_DATA, PROC_REF(ui_update))

/datum/dynamic_panel/ui_static_data(mob/user)
	var/list/data = list()

	data["possible_storytellers"] = list()
	for (var/storyteller_name in SSdynamic.dynamic_storyteller_jsons)
		data["possible_storytellers"] += storyteller_name

	data["gamemode_rulesets"] = list()
	for(var/datum/dynamic_ruleset/supplementary/potential_ruleset in SSdynamic.gamemode_configured_rulesets)
		data["gamemode_rulesets"] += list(list(
			"name" = potential_ruleset.name,
			"path" = potential_ruleset.type,
			"cost" = potential_ruleset.points_cost,
		))

	data["valid_supplementary_rulesets"] = list()
	for(var/datum/dynamic_ruleset/supplementary/potential_ruleset in SSdynamic.supplementary_configured_rulesets)
		data["valid_supplementary_rulesets"] += list(list(
			"name" = potential_ruleset.name,
			"path" = potential_ruleset.type,
			"cost" = potential_ruleset.points_cost,
		))

	data["valid_midround_rulesets"] = list()
	for(var/datum/dynamic_ruleset/midround/potential_ruleset in SSdynamic.midround_configured_rulesets)
		data["valid_midround_rulesets"] += list(list(
			"name" = potential_ruleset.name,
			"path" = potential_ruleset.type,
			"cost" = potential_ruleset.points_cost,
		))

	return data

/datum/dynamic_panel/ui_data(mob/user)
	var/list/data = list()

	// Other
	data["forced_extended"] = SSdynamic.forced_extended
	data["current_storyteller"] = SSdynamic.current_storyteller?["Name"]

	// Roundstart
	data["roundstart_points_override"] = SSdynamic.roundstart_points_override
	data["roundstart_ready_amount"] = SSdynamic.roundstart_ready_amount

	// Gamemode
	data["gamemode_whitelist_forced"] = SSdynamic.gamemode_whitelist_forced
	data["gamemode_blacklist_forced"] = SSdynamic.gamemode_blacklist_forced

	data["forced_gamemode_rulesets"] = list()
	for(var/datum/dynamic_ruleset/gamemode/forced_ruleset in SSdynamic.gamemode_forced_rulesets)
		data["forced_gamemode_rulesets"] += list(list(
			"name" = forced_ruleset.name,
			"path" = forced_ruleset.type,
			"cost" = forced_ruleset.points_cost,
		))

	data["valid_gamemode_rulesets"] = list()
	for(var/datum/dynamic_ruleset/gamemode/executed_ruleset in SSdynamic.gamemode_configured_rulesets)
		data["valid_gamemode_rulesets"] += list(list(
			"name" = executed_ruleset.name,
			"path" = executed_ruleset.type,
		))

	data["executed_gamemode_rulesets"] = list()
	for(var/datum/dynamic_ruleset/gamemode/executed_ruleset in SSdynamic.gamemode_executed_rulesets)
		data["executed_gamemode_rulesets"] += list(list(
			"name" = executed_ruleset.name,
			"path" = executed_ruleset.type,
		))

	// Supplementary

	data["supplementary_points"] = SSdynamic.supplementary_points
	data["supplementary_divergence"] = SSdynamic.supplementary_point_divergence
	data["has_round_started"] = SSticker.HasRoundStarted()
	if (SSdynamic.next_supplementary)
		data["supplementary_next"] = list(
			"name" = SSdynamic.next_supplementary.name,
			"path" = SSdynamic.next_supplementary.type,
			"cost" = SSdynamic.next_supplementary.points_cost,
		)

	data["supplementary_divergence_upper"] = SSdynamic.roundstart_divergence_percent_upper
	data["supplementary_divergence_lower"] = SSdynamic.roundstart_divergence_percent_lower
	data["supplementary_points_per_ready"] = SSdynamic.supplementary_points_per_ready
	data["supplementary_points_per_unready"] = SSdynamic.supplementary_points_per_unready
	data["supplementary_points_per_observer"] = SSdynamic.supplementary_points_per_observer

	data["supplementary_whitelist_forced"] = SSdynamic.supplementary_whitelist_forced
	data["supplementary_blacklist_forced"] = SSdynamic.supplementary_blacklist_forced

	data["forced_supplementary_rulesets"] = list()
	for(var/datum/dynamic_ruleset/supplementary/forced_ruleset in SSdynamic.supplementary_forced_rulesets)
		data["forced_supplementary_rulesets"] += list(list(
			"name" = forced_ruleset.name,
			"path" = forced_ruleset.type,
			"cost" = forced_ruleset.points_cost,
		))

	data["executed_supplementary_rulesets"] = list()
	for(var/datum/dynamic_ruleset/supplementary/executed_ruleset in SSdynamic.executed_supplementary_rulesets)
		data["executed_supplementary_rulesets"] += list(list(
			"name" = executed_ruleset.name,
			"path" = executed_ruleset.type,
			"cost" = executed_ruleset.points_cost,
		))

	// Midround
	var/datum/dynamic_ruleset/midround/chosen_midround_ruleset = SSdynamic.midround_chosen_ruleset
	if(chosen_midround_ruleset)
		data["current_midround_ruleset"] = list(
			"name" = chosen_midround_ruleset.name,
			"path" = chosen_midround_ruleset.type,
			"cost" = chosen_midround_ruleset.points_cost,
		)

	data["executed_midround_rulesets"] = list()
	for(var/datum/dynamic_ruleset/midround/executed_ruleset in SSdynamic.midround_executed_rulesets)
		data["executed_midround_rulesets"] += list(list(
			"name" = executed_ruleset.name,
			"path" = executed_ruleset.type,
			"cost" = executed_ruleset.points_cost,
		))

	data["current_midround_points"] = SSdynamic.midround_points
	data["midround_grace_period"] = SSdynamic.midround_grace_period / (1 MINUTES)
	data["midround_failure_stallout"] = SSdynamic.midround_failure_stallout / (1 MINUTES)

	data["living_delta"] = SSdynamic.midround_living_delta
	data["dead_delta"] = SSdynamic.midround_dead_delta
	data["dead_security_delta"] = SSdynamic.midround_dead_security_delta
	data["observer_delta"] = SSdynamic.midround_observer_delta
	data["linear_delta"] = SSdynamic.midround_linear_delta
	data["linear_delta_forced"] = SSdynamic.midround_linear_delta_forced

	data["logged_points"] = SSdynamic.logged_points["logged_points"]
	data["logged_points_living"] = SSdynamic.logged_points["logged_points_living"]
	data["logged_points_observer"] = SSdynamic.logged_points["logged_points_observer"]
	data["logged_points_dead"] = SSdynamic.logged_points["logged_points_dead"]
	data["logged_points_dead_security"] = SSdynamic.logged_points["logged_points_dead_security"]
	data["logged_points_antag"] = SSdynamic.logged_points["logged_points_antag"]
	data["logged_points_linear"] = SSdynamic.logged_points["logged_points_linear"]
	data["logged_points_linear_forced"] = SSdynamic.logged_points["logged_points_linear_forced"]

	data["logged_light_chance"] = SSdynamic.logged_chances["light"]
	data["logged_medium_chance"] = SSdynamic.logged_chances["medium"]
	data["logged_heavy_chance"] = SSdynamic.logged_chances["heavy"]

	// Latejoin
	data["executed_latejoin_rulesets"] = list()
	for(var/datum/dynamic_ruleset/supplementary/executed_ruleset in SSdynamic.executed_supplementary_rulesets)
		data["executed_latejoin_rulesets"] += list(list(
			"name" = executed_ruleset.name,
			"path" = executed_ruleset.type,
			"cost" = executed_ruleset.points_cost,
		))

	return data

/datum/dynamic_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		// Other
		if("vv")
			usr.client.debug_variables(SSdynamic)
			return TRUE
		if("reload_storytellers")
			SSdynamic.load_storytellers()
			return TRUE
		if("toggle_forced_extended")
			SSdynamic.forced_extended = !SSdynamic.forced_extended
			return TRUE
		// Midround
		if("set_storyteller")
			var/new_storyteller = params["new_storyteller"]
			SSdynamic.set_storyteller(new_storyteller == "None" ? null : new_storyteller)

			message_admins("[key_name(usr)] set the dynamic storyteller to [new_storyteller]")
			log_dynamic("[key_name(usr)] set the dynamic storyteller to [new_storyteller]")
			return TRUE

		// Roundstart
		if("set_roundstart_divergence_upper")
			var/new_divergence_upper = params["new_divergence_upper"]
			SSdynamic.roundstart_divergence_percent_upper = new_divergence_upper
			message_admins("[key_name(usr)] set the roundstart divergence upper range to [new_divergence_upper]")
			log_dynamic("[key_name(usr)] set the roundstart divergence upper range to [new_divergence_upper]")
			return TRUE
		if("set_roundstart_divergence_lower")
			var/new_divergence_lower = params["new_divergence_lower"]
			SSdynamic.roundstart_divergence_percent_lower = new_divergence_lower
			message_admins("[key_name(usr)] set the roundstart divergence lower range to [new_divergence_lower]")
			log_dynamic("[key_name(usr)] set the roundstart divergence lower range to [new_divergence_lower]")
			return TRUE

		if("set_supplementary_points")
			var/new_supplementary_points = params["new_supplementary_points"]
			SSdynamic.supplementary_points = new_supplementary_points
			message_admins("[key_name(usr)] set the supplementary points to [new_supplementary_points]")
			log_dynamic("[key_name(usr)] set the supplementary points to [new_supplementary_points]")
			return TRUE
		if("set_supplementary_points_per_ready")
			var/new_points_per_ready = params["new_points_per_ready"]
			SSdynamic.supplementary_points_per_ready = new_points_per_ready
			message_admins("[key_name(usr)] set the roundstart points per ready to [new_points_per_ready]")
			log_dynamic("[key_name(usr)] set the roundstart points per ready to [new_points_per_ready]")
			return TRUE
		if("set_supplementary_points_per_unready")
			var/new_points_per_unready = params["new_points_per_unready"]
			SSdynamic.supplementary_points_per_unready = new_points_per_unready
			message_admins("[key_name(usr)] set the roundstart points per unready to [new_points_per_unready]")
			log_dynamic("[key_name(usr)] set the roundstart points per unready to [new_points_per_unready]")
			return TRUE
		if("set_supplementary_points_per_observer")
			var/new_points_per_observer = params["new_points_per_observer"]
			SSdynamic.supplementary_points_per_observer = new_points_per_observer
			message_admins("[key_name(usr)] set the roundstart points per observer to [new_points_per_observer]")
			log_dynamic("[key_name(usr)] set the roundstart points per observer to [new_points_per_observer]")
			return TRUE

		if("toggle_roundstart_points_override")
			SSdynamic.roundstart_points_override = !SSdynamic.roundstart_points_override

			if(SSdynamic.roundstart_points_override)
				var/forced_roundstart_points = params["forced_roundstart_points"]
				SSdynamic.supplementary_points = forced_roundstart_points
				message_admins("[key_name(usr)] has forced dynamic to use [forced_roundstart_points] roundstart points")
				log_dynamic("[key_name(usr)] has forced dynamic to use [forced_roundstart_points] roundstart points")
			else
				message_admins("[key_name(usr)] has let dynamic choose its own roundstart points again")
				log_dynamic("[key_name(usr)] has let dynamic choose its own roundstart points again")
			return TRUE

		if("toggle_gamemode_whitelist_forced")
			SSdynamic.gamemode_whitelist_forced = !SSdynamic.gamemode_whitelist_forced

			// Invert the other one
			if(SSdynamic.gamemode_whitelist_forced)
				SSdynamic.gamemode_blacklist_forced = FALSE

			if(SSdynamic.gamemode_whitelist_forced)
				var/list/forced_rulesets = list()
				for(var/datum/dynamic_ruleset/gamemode/forced_ruleset in SSdynamic.gamemode_forced_rulesets)
					forced_rulesets += forced_ruleset.name

				message_admins("[key_name(usr)] has forced only these roundstart rulesets: [forced_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has forced only these roundstart rulesets: [forced_rulesets.Join(", ")]")
			else
				message_admins("[key_name(usr)] has let dynamic choose its own roundstart rulesets again")
				log_dynamic("[key_name(usr)] has let dynamic choose its own roundstart rulesets again")
			return TRUE

		if("toggle_gamemode_blacklist_forced")
			if(!length(SSdynamic.gamemode_forced_rulesets))
				message_admins("[key_name(usr)] tried to blacklist the forced rulesets, but there were none")
				log_dynamic("[key_name(usr)] tried to blacklist the forced rulesets, but there were none")
				return TRUE

			SSdynamic.gamemode_blacklist_forced = !SSdynamic.gamemode_blacklist_forced

			// Invert the other one
			if(SSdynamic.gamemode_blacklist_forced)
				SSdynamic.gamemode_whitelist_forced = FALSE

			var/list/blacklisted_rulesets = list()
			for(var/datum/dynamic_ruleset/gamemode/blacklisted_ruleset in SSdynamic.gamemode_forced_rulesets)
				blacklisted_rulesets += blacklisted_ruleset.name

			if(SSdynamic.gamemode_blacklist_forced)
				message_admins("[key_name(usr)] has blacklisted these roundstart rulesets: [blacklisted_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has blacklisted these roundstart rulesets: [blacklisted_rulesets.Join(", ")]")
			else
				message_admins("[key_name(usr)] has un-blacklisted these rulesets: [blacklisted_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has un-blacklisted these rulesets: [blacklisted_rulesets.Join(", ")]")
			return TRUE

		if("force_gamemode_ruleset")
			var/ruleset_text = params["forced_roundstart_ruleset"]
			var/datum/dynamic_ruleset/gamemode/ruleset_path = text2path(ruleset_text)
			if(!ispath(ruleset_path, /datum/dynamic_ruleset/gamemode) || ruleset_path == /datum/dynamic_ruleset/gamemode)
				message_admins("[key_name(usr)] tried to force/blacklist an invalid roundstart ruleset: [ruleset_text]")
				to_chat(usr, span_warning("Invalid ruleset: [ruleset_text]"))
				return TRUE

			// If it's already forced, unforce it, otherwise, force it.
			var/needs_to_force = TRUE
			for(var/datum/dynamic_ruleset/gamemode/forced_ruleset in SSdynamic.gamemode_forced_rulesets)
				if(forced_ruleset.type == ruleset_path)
					SSdynamic.gamemode_forced_rulesets -= forced_ruleset
					needs_to_force = FALSE
					message_admins("[key_name(usr)] has un[SSdynamic.gamemode_blacklist_forced ? "blacklisted" : "forced"]: [ruleset_path::name]")
					log_dynamic("[key_name(usr)] has un[SSdynamic.gamemode_blacklist_forced ? "blacklisted" : "forced"]: [ruleset_path::name]")

			if(!length(SSdynamic.gamemode_forced_rulesets))
				SSdynamic.gamemode_blacklist_forced = FALSE
			else if (!SSdynamic.gamemode_whitelist_forced && !SSdynamic.gamemode_blacklist_forced)
				// Turn on whitelisting if we have nothing selected
				SSdynamic.gamemode_whitelist_forced = TRUE

			if(needs_to_force)
				for(var/datum/dynamic_ruleset/gamemode/ruleset in SSdynamic.gamemode_configured_rulesets)
					if(ruleset.type == ruleset_path)
						SSdynamic.gamemode_forced_rulesets += ruleset
						message_admins("[key_name(usr)] has [SSdynamic.gamemode_blacklist_forced ? "blacklisted" : "forced"]: [ruleset_path::name]")
						log_dynamic("[key_name(usr)] has [SSdynamic.gamemode_blacklist_forced ? "blacklisted" : "forced"]: [ruleset_path::name]")
						break

			return TRUE

		if("toggle_supplementary_whitelist_forced")
			SSdynamic.supplementary_whitelist_forced = !SSdynamic.supplementary_whitelist_forced

			// Invert the other one
			if(SSdynamic.supplementary_whitelist_forced)
				SSdynamic.supplementary_whitelist_forced = FALSE

			if(SSdynamic.supplementary_whitelist_forced)
				var/list/forced_rulesets = list()
				for(var/datum/dynamic_ruleset/supplementary/forced_ruleset in SSdynamic.supplementary_forced_rulesets)
					forced_rulesets += forced_ruleset.name

				message_admins("[key_name(usr)] has forced only these roundstart rulesets: [forced_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has forced only these roundstart rulesets: [forced_rulesets.Join(", ")]")
			else
				message_admins("[key_name(usr)] has let dynamic choose its own roundstart rulesets again")
				log_dynamic("[key_name(usr)] has let dynamic choose its own roundstart rulesets again")
			return TRUE

		if("toggle_supplementary_blacklist_forced")
			if(!length(SSdynamic.supplementary_forced_rulesets))
				message_admins("[key_name(usr)] tried to blacklist the forced rulesets, but there were none")
				log_dynamic("[key_name(usr)] tried to blacklist the forced rulesets, but there were none")
				return TRUE

			SSdynamic.supplementary_blacklist_forced = !SSdynamic.supplementary_blacklist_forced

			// Invert the other one
			if(SSdynamic.supplementary_blacklist_forced)
				SSdynamic.supplementary_whitelist_forced = FALSE

			var/list/blacklisted_rulesets = list()
			for(var/datum/dynamic_ruleset/supplementary/blacklisted_ruleset in SSdynamic.supplementary_forced_rulesets)
				blacklisted_rulesets += blacklisted_ruleset.name

			if(SSdynamic.supplementary_blacklist_forced)
				message_admins("[key_name(usr)] has blacklisted these roundstart rulesets: [blacklisted_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has blacklisted these roundstart rulesets: [blacklisted_rulesets.Join(", ")]")
			else
				message_admins("[key_name(usr)] has un-blacklisted these rulesets: [blacklisted_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has un-blacklisted these rulesets: [blacklisted_rulesets.Join(", ")]")
			return TRUE

		if("force_roundstart_ruleset")
			var/ruleset_text = params["forced_roundstart_ruleset"]
			var/datum/dynamic_ruleset/supplementary/ruleset_path = text2path(ruleset_text)
			if(!ispath(ruleset_path, /datum/dynamic_ruleset/supplementary) || ruleset_path == /datum/dynamic_ruleset/supplementary)
				message_admins("[key_name(usr)] tried to force/blacklist an invalid roundstart ruleset: [ruleset_text]")
				to_chat(usr, span_warning("Invalid ruleset: [ruleset_text]"))
				return TRUE

			// If it's already forced, unforce it, otherwise, force it.
			var/needs_to_force = TRUE
			for(var/datum/dynamic_ruleset/supplementary/forced_ruleset in SSdynamic.supplementary_forced_rulesets)
				if(forced_ruleset.type == ruleset_path)
					SSdynamic.supplementary_forced_rulesets -= forced_ruleset
					needs_to_force = FALSE
					message_admins("[key_name(usr)] has un[SSdynamic.supplementary_blacklist_forced ? "blacklisted" : "forced"]: [ruleset_path::name]")
					log_dynamic("[key_name(usr)] has un[SSdynamic.supplementary_blacklist_forced ? "blacklisted" : "forced"]: [ruleset_path::name]")

			if(!length(SSdynamic.supplementary_forced_rulesets))
				SSdynamic.supplementary_blacklist_forced = FALSE
			else if (!SSdynamic.supplementary_whitelist_forced && !SSdynamic.supplementary_blacklist_forced)
				// Turn on whitelisting if we have nothing selected
				SSdynamic.supplementary_whitelist_forced = TRUE

			if(needs_to_force)
				for(var/datum/dynamic_ruleset/supplementary/ruleset in SSdynamic.supplementary_configured_rulesets)
					if(ruleset.type == ruleset_path)
						SSdynamic.supplementary_forced_rulesets += ruleset
						message_admins("[key_name(usr)] has [SSdynamic.supplementary_blacklist_forced ? "blacklisted" : "forced"]: [ruleset_path::name]")
						log_dynamic("[key_name(usr)] has [SSdynamic.supplementary_blacklist_forced ? "blacklisted" : "forced"]: [ruleset_path::name]")
						break

			return TRUE

		// Midround
		if("set_midround_ruleset")
			var/ruleset_text = params["new_midround_ruleset"]
			var/datum/dynamic_ruleset/midround/ruleset_path = text2path(ruleset_text)
			if(!ispath(ruleset_path, /datum/dynamic_ruleset/midround) || ruleset_path == /datum/dynamic_ruleset/midround)
				message_admins("[key_name(usr)] tried to set an invalid midround ruleset: [ruleset_text]")
				to_chat(usr, span_warning("Invalid ruleset: [ruleset_text]"))
				return TRUE

			for(var/datum/dynamic_ruleset/midround/ruleset in SSdynamic.midround_configured_rulesets)
				if(ruleset.type == ruleset_path)
					SSdynamic.midround_chosen_ruleset = ruleset
					break

			message_admins("[key_name(usr)] set the midround ruleset to [ruleset_path::name]")
			log_dynamic("[key_name(usr)] set the midround ruleset to [ruleset_path::name]")
			return TRUE
		if("execute_midround_ruleset")
			var/datum/dynamic_ruleset/midround/midround_ruleset = SSdynamic.midround_chosen_ruleset
			if(!midround_ruleset)
				return

			if (SSdynamic.midround_waiting_ruleset)
				SSdynamic.midround_waiting_ruleset.abort()
				SSdynamic.midround_waiting_ruleset = null

			var/result = SSdynamic.execute_ruleset(midround_ruleset)
			message_admins("[key_name(usr)] forced the midround ruleset ([midround_ruleset]) to execute - [DYNAMIC_EXECUTE_STRINGIFY(result)]")
			log_dynamic("[key_name(usr)] forced the midround ruleset ([midround_ruleset]) to execute - [DYNAMIC_EXECUTE_STRINGIFY(DYNAMIC_EXECUTE_SUCCESS)]")
			if (result == DYNAMIC_EXECUTE_WAITING)
				SSdynamic.midround_waiting_ruleset = midround_ruleset
			if(result == DYNAMIC_EXECUTE_SUCCESS)
				SSdynamic.midround_executed_rulesets += SSdynamic.midround_chosen_ruleset
			SSdynamic.midround_chosen_ruleset = null
			return TRUE

		if("set_midround_points")
			var/new_points = params["new_points"]
			SSdynamic.midround_points = new_points
			SSdynamic.logged_points["logged_points"] += new_points
			message_admins("[key_name(usr)] set the midround points to [new_points]")
			log_dynamic("[key_name(usr)] set the midround points to [new_points]")
			return TRUE
		if("set_midround_grace_period")
			var/new_grace_period = params["new_grace_period"]
			SSdynamic.midround_grace_period = new_grace_period MINUTES
			message_admins("[key_name(usr)] set the midround grace period to [new_grace_period] minutes")
			log_dynamic("[key_name(usr)] set the midround grace period to [new_grace_period] minutes")
			return TRUE
		if("set_midround_failure_stallout")
			var/new_midround_stallout = params["new_midround_stallout"]
			SSdynamic.midround_failure_stallout = new_midround_stallout MINUTES
			message_admins("[key_name(usr)] set the midround stallout time to [new_midround_stallout] minutes")
			log_dynamic("[key_name(usr)] set the midround grace period to [new_midround_stallout] minutes")
			return TRUE

		if("set_midround_living_delta")
			var/new_living_delta = params["new_living_delta"]
			SSdynamic.midround_living_delta = new_living_delta
			message_admins("[key_name(usr)] set the midround living delta to [new_living_delta]")
			log_dynamic("[key_name(usr)] set the midround living delta to [new_living_delta]")
			return TRUE
		if("set_midround_dead_delta")
			var/new_dead_delta = params["new_dead_delta"]
			SSdynamic.midround_dead_delta = new_dead_delta
			message_admins("[key_name(usr)] set the midround dead delta to [new_dead_delta]")
			log_dynamic("[key_name(usr)] set the midround dead delta to [new_dead_delta]")
			return TRUE
		if("set_midround_dead_security_delta")
			var/new_dead_security_delta = params["new_dead_security_delta"]
			SSdynamic.midround_dead_security_delta = new_dead_security_delta
			message_admins("[key_name(usr)] set the midround dead security delta to [new_dead_security_delta]")
			log_dynamic("[key_name(usr)] set the midround dead security delta to [new_dead_security_delta]")
			return TRUE
		if("set_midround_observer_delta")
			var/new_observer_delta = params["new_observer_delta"]
			SSdynamic.midround_observer_delta = new_observer_delta
			message_admins("[key_name(usr)] set the midround observer delta to [new_observer_delta]")
			log_dynamic("[key_name(usr)] set the midround observer delta to [new_observer_delta]")
			return TRUE
		if("set_midround_linear_delta")
			var/new_linear_delta = params["new_linear_delta"]
			SSdynamic.midround_linear_delta = new_linear_delta
			message_admins("[key_name(usr)] set the midround linear delta to [new_linear_delta]")
			log_dynamic("[key_name(usr)] set the midround linear delta to [new_linear_delta]")
			return TRUE
		if("set_midround_linear_delta_forced")
			var/new_linear_delta_forced = params["new_linear_delta_forced"]
			SSdynamic.midround_linear_delta_forced = new_linear_delta_forced
			message_admins("[key_name(usr)] set the forced midround linear delta to [new_linear_delta_forced]")
			log_dynamic("[key_name(usr)] set the forced midround linear delta to [new_linear_delta_forced]")
			return TRUE

		// Latejoin
		if("set_latejoin_ruleset")
			var/ruleset_text = params["new_latejoin_ruleset"]
			var/datum/dynamic_ruleset/supplementary/ruleset_path = text2path(ruleset_text)
			if(!ispath(ruleset_path, /datum/dynamic_ruleset/supplementary) || ruleset_path == /datum/dynamic_ruleset/supplementary)
				message_admins("[key_name(usr)] tried to set an invalid latejoin ruleset: [ruleset_text]")
				to_chat(usr, span_warning("Invalid ruleset: [ruleset_text]"))
				return TRUE

			for(var/datum/dynamic_ruleset/supplementary/ruleset in SSdynamic.supplementary_configured_rulesets)
				if(ruleset.type == ruleset_path)
					SSdynamic.next_supplementary = ruleset
					break

			message_admins("[key_name(usr)] set the latejoin ruleset to [ruleset_path::name]")
			log_dynamic("[key_name(usr)] set the latejoin ruleset to [ruleset_path::name]")
			return TRUE

/datum/dynamic_panel/ui_status(mob/user, datum/ui_state/state)
	return check_rights_for(user.client, R_DEBUG) ? UI_INTERACTIVE : UI_CLOSE

/datum/dynamic_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DynamicPanel")
		ui.open()
