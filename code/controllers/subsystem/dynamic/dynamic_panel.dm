/datum/admins/proc/dynamic_panel()
	set name = "Dynamic Panel"
	set category = "Round"

	var/static/datum/dynamic_panel/dynamic_panel = new()
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

	data["valid_roundstart_rulesets"] = list()
	for(var/datum/dynamic_ruleset/roundstart/potential_ruleset in SSdynamic.roundstart_configured_rulesets)
		data["valid_roundstart_rulesets"] += list(list(
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

	data["valid_latejoin_rulesets"] = list()
	for(var/datum/dynamic_ruleset/latejoin/potential_ruleset in SSdynamic.latejoin_configured_rulesets)
		data["valid_latejoin_rulesets"] += list(list(
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
	data["roundstart_only_use_forced_rulesets"] = SSdynamic.roundstart_only_use_forced_rulesets
	data["roundstart_blacklist_forced_rulesets"] = SSdynamic.roundstart_blacklist_forced_rulesets

	data["roundstart_points"] = SSdynamic.roundstart_points
	data["roundstart_divergence"] = SSdynamic.roundstart_point_divergence
	data["roundstart_ready_amount"] = SSdynamic.roundstart_ready_amount
	data["has_round_started"] = SSticker.HasRoundStarted()

	data["roundstart_divergence_upper"] = SSdynamic.roundstart_divergence_percent_upper
	data["roundstart_divergence_lower"] = SSdynamic.roundstart_divergence_percent_lower
	data["roundstart_points_per_ready"] = SSdynamic.roundstart_points_per_ready
	data["roundstart_points_per_unready"] = SSdynamic.roundstart_points_per_unready
	data["roundstart_points_per_observer"] = SSdynamic.roundstart_points_per_observer

	data["forced_roundstart_rulesets"] = list()
	for(var/datum/dynamic_ruleset/roundstart/forced_ruleset in SSdynamic.roundstart_forced_rulesets)
		data["forced_roundstart_rulesets"] += list(list(
			"name" = forced_ruleset.name,
			"path" = forced_ruleset.type,
			"cost" = forced_ruleset.points_cost,
		))

	data["executed_roundstart_rulesets"] = list()
	for(var/datum/dynamic_ruleset/roundstart/executed_ruleset in SSdynamic.roundstart_executed_rulesets)
		data["executed_roundstart_rulesets"] += list(list(
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
	data["midround_grace_period"] = SSdynamic.midround_grace_period
	data["midround_failure_stallout"] = SSdynamic.midround_failure_stallout

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
	for(var/datum/dynamic_ruleset/latejoin/executed_ruleset in SSdynamic.latejoin_executed_rulesets)
		data["executed_latejoin_rulesets"] += list(list(
			"name" = executed_ruleset.name,
			"path" = executed_ruleset.type,
			"cost" = executed_ruleset.points_cost,
		))

	var/datum/dynamic_ruleset/latejoin/chosen_latejoin_ruleset = SSdynamic.latejoin_forced_ruleset
	if(chosen_latejoin_ruleset)
		data["current_latejoin_ruleset"] = list(
			"name" = chosen_latejoin_ruleset.name,
			"path" = chosen_latejoin_ruleset.type,
			"cost" = chosen_latejoin_ruleset.points_cost,
		)

	data["latejoin_probability"] = SSdynamic.latejoin_ruleset_probability
	data["latejoin_max"] = SSdynamic.latejoin_max_rulesets

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

		if("toggle_forced_extended")
			SSdynamic.forced_extended = !SSdynamic.forced_extended
			return TRUE

		// Storyteller
		if("reload_storytellers")
			SSdynamic.load_storytellers()
			return TRUE
		if("set_storyteller")
			var/new_storyteller = params["new_storyteller"]
			SSdynamic.set_storyteller(new_storyteller == "None" ? null : new_storyteller)

			message_admins("[key_name(usr)] set the dynamic storyteller to [new_storyteller]")
			log_dynamic("[key_name(usr)] set the dynamic storyteller to [new_storyteller]")
			return TRUE

		if("set_var")
			var/variable = params["variable"]
			var/new_state = params["new_state"]
			SSdynamic.vars[variable] = new_state

			message_admins("DYNAMIC: [key_name(usr)] set [variable] to [new_state]")
			log_dynamic("DYNAMIC: [key_name(usr)] set [variable] to [new_state]")
			return TRUE

		// Roundstart
		if("toggle_roundstart_points_override")
			SSdynamic.roundstart_points_override = !SSdynamic.roundstart_points_override

			if(SSdynamic.roundstart_points_override)
				var/forced_roundstart_points = params["forced_roundstart_points"]
				SSdynamic.roundstart_points = forced_roundstart_points
				message_admins("[key_name(usr)] has forced dynamic to use [forced_roundstart_points] roundstart points")
				log_dynamic("[key_name(usr)] has forced dynamic to use [forced_roundstart_points] roundstart points")
			else
				message_admins("[key_name(usr)] has let dynamic choose its own roundstart points again")
				log_dynamic("[key_name(usr)] has let dynamic choose its own roundstart points again")
			return TRUE

		if("toggle_roundstart_rulesets_override")
			SSdynamic.roundstart_only_use_forced_rulesets = !SSdynamic.roundstart_only_use_forced_rulesets

			// Invert the other one
			if(SSdynamic.roundstart_only_use_forced_rulesets)
				SSdynamic.roundstart_blacklist_forced_rulesets = FALSE

			if(SSdynamic.roundstart_only_use_forced_rulesets)
				var/list/forced_rulesets = list()
				for(var/datum/dynamic_ruleset/roundstart/forced_ruleset in SSdynamic.roundstart_forced_rulesets)
					forced_rulesets += forced_ruleset.name

				message_admins("[key_name(usr)] has forced only these roundstart rulesets: [forced_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has forced only these roundstart rulesets: [forced_rulesets.Join(", ")]")
			else
				message_admins("[key_name(usr)] has let dynamic choose its own roundstart rulesets again")
				log_dynamic("[key_name(usr)] has let dynamic choose its own roundstart rulesets again")
			return TRUE

		if("toggle_roundstart_blacklist_forced_rulesets")
			if(!length(SSdynamic.roundstart_forced_rulesets))
				message_admins("[key_name(usr)] tried to blacklist the forced rulesets, but there were none")
				log_dynamic("[key_name(usr)] tried to blacklist the forced rulesets, but there were none")
				return TRUE

			SSdynamic.roundstart_blacklist_forced_rulesets = !SSdynamic.roundstart_blacklist_forced_rulesets

			// Invert the other one
			if(SSdynamic.roundstart_blacklist_forced_rulesets)
				SSdynamic.roundstart_only_use_forced_rulesets = FALSE

			var/list/blacklisted_rulesets = list()
			for(var/datum/dynamic_ruleset/roundstart/blacklisted_ruleset in SSdynamic.roundstart_forced_rulesets)
				blacklisted_rulesets += blacklisted_ruleset.name

			if(SSdynamic.roundstart_blacklist_forced_rulesets)
				message_admins("[key_name(usr)] has blacklisted these roundstart rulesets: [blacklisted_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has blacklisted these roundstart rulesets: [blacklisted_rulesets.Join(", ")]")
			else
				message_admins("[key_name(usr)] has un-blacklisted these rulesets: [blacklisted_rulesets.Join(", ")]")
				log_dynamic("[key_name(usr)] has un-blacklisted these rulesets: [blacklisted_rulesets.Join(", ")]")
			return TRUE

		if("force_roundstart_ruleset")
			var/ruleset_text = params["forced_roundstart_ruleset"]
			var/datum/dynamic_ruleset/roundstart/ruleset_path = text2path(ruleset_text)
			if(!ispath(ruleset_path, /datum/dynamic_ruleset/roundstart) || ruleset_path == /datum/dynamic_ruleset/roundstart)
				message_admins("[key_name(usr)] tried to force/blacklist an invalid roundstart ruleset: [ruleset_text]")
				to_chat(usr, span_warning("Invalid ruleset: [ruleset_text]"))
				return TRUE

			// If it's already forced, unforce it, otherwise, force it.
			var/needs_to_force = TRUE
			for(var/datum/dynamic_ruleset/roundstart/forced_ruleset in SSdynamic.roundstart_forced_rulesets)
				if(forced_ruleset.type == ruleset_path)
					SSdynamic.roundstart_forced_rulesets -= forced_ruleset
					needs_to_force = FALSE
					message_admins("[key_name(usr)] has un[SSdynamic.roundstart_blacklist_forced_rulesets ? "blacklisted" : "forced"]: [ruleset_path::name]")
					log_dynamic("[key_name(usr)] has un[SSdynamic.roundstart_blacklist_forced_rulesets ? "blacklisted" : "forced"]: [ruleset_path::name]")

			if(!length(SSdynamic.roundstart_forced_rulesets))
				SSdynamic.roundstart_blacklist_forced_rulesets = FALSE

			if(needs_to_force)
				for(var/datum/dynamic_ruleset/roundstart/ruleset in SSdynamic.roundstart_configured_rulesets)
					if(ruleset.type == ruleset_path)
						SSdynamic.roundstart_forced_rulesets += ruleset
						message_admins("[key_name(usr)] has [SSdynamic.roundstart_blacklist_forced_rulesets ? "blacklisted" : "forced"]: [ruleset_path::name]")
						log_dynamic("[key_name(usr)] has [SSdynamic.roundstart_blacklist_forced_rulesets ? "blacklisted" : "forced"]: [ruleset_path::name]")
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

			var/result = SSdynamic.execute_ruleset(midround_ruleset)
			message_admins("[key_name(usr)] forced the midround ruleset ([midround_ruleset]) to execute - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
			log_dynamic("[key_name(usr)] forced the midround ruleset ([midround_ruleset]) to execute - [result == DYNAMIC_EXECUTE_SUCCESS ? "SUCCESS" : "FAIL"]")
			if(result == DYNAMIC_EXECUTE_SUCCESS)
				SSdynamic.midround_executed_rulesets += SSdynamic.midround_chosen_ruleset
			SSdynamic.midround_chosen_ruleset = null
			return TRUE

		// Latejoin
		if("set_latejoin_ruleset")
			var/ruleset_text = params["new_latejoin_ruleset"]
			var/datum/dynamic_ruleset/latejoin/ruleset_path = text2path(ruleset_text)
			if(!ispath(ruleset_path, /datum/dynamic_ruleset/latejoin) || ruleset_path == /datum/dynamic_ruleset/latejoin)
				message_admins("[key_name(usr)] tried to set an invalid latejoin ruleset: [ruleset_text]")
				to_chat(usr, span_warning("Invalid ruleset: [ruleset_text]"))
				return TRUE

			for(var/datum/dynamic_ruleset/latejoin/ruleset in SSdynamic.latejoin_configured_rulesets)
				if(ruleset.type == ruleset_path)
					SSdynamic.latejoin_forced_ruleset = ruleset
					break

			message_admins("[key_name(usr)] set the latejoin ruleset to [ruleset_path::name]")
			log_dynamic("[key_name(usr)] set the latejoin ruleset to [ruleset_path::name]")
			return TRUE

/datum/dynamic_panel/ui_status(mob/user, datum/ui_state/state)
	return check_rights_for(user.client, R_FUN) ? UI_INTERACTIVE : UI_CLOSE

/datum/dynamic_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DynamicPanel")
		ui.open()
