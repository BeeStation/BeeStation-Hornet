GLOBAL_VAR(antag_prototypes)

//Things to do somewhere in the future (If you're reading this feel free to do any of these)
//Add HrefTokens to these
//Make this template or at least remove + "<br>" with joins where you can grasp the big picture.
//Span classes for the headers, wrap sections in div's and style them.
//Move common admin commands to /mob (maybe integrate with vv dropdown so the list is one thing with some flag where to show it)
//Move objective initialization/editing stuff from mind to objectives and completely remove mind.objectives

/proc/cmp_antagpanel(datum/antagonist/A,datum/antagonist/B)
	var/a_cat = initial(A.antagpanel_category)
	var/b_cat = initial(B.antagpanel_category)
	if(!a_cat && !b_cat)
		return sorttext(initial(A.name),initial(B.name))
	return sorttext(b_cat,a_cat)

/datum/mind/proc/add_antag_wrapper(antag_type,mob/user)
	var/datum/antagonist/new_antag = new antag_type()
	new_antag.admin_add(src,user)
	//If something gone wrong/admin-add assign another antagonist due to whatever clean it up
	if(!new_antag.owner)
		qdel(new_antag)

/datum/antagonist/proc/antag_panel()
	var/antag_panel_title = "<span style='font-size: 20px; margin: 8px; height: 0px; display: block;'><b> Antagonist Info : [name];</b></span>"
	var/list/commands = list()
	for(var/command in get_admin_commands())
		commands += "<a href='byond://?src=[REF(src)];command=[command]'>[command]</a>"

	var/list/parts = list()
	for(var/each in list(antag_panel_title, commands.Join(""), antag_panel_data(), antag_panel_objectives(), antag_panel_memory()))
		if(length(each))
			parts += each
	parts += "<hr>"

	return parts.Join("<br>")

/datum/antagonist/proc/antag_panel_objectives()
	var/result = "<i><b>Objectives</b></i>:  (<a href='byond://?src=[REF(owner)];obj_add=1;target_antag=[REF(src)]'>Add objective</a><a href='byond://?src=[REF(owner)];obj_announce=1'>Announce objectives</a>)<br>"
	if (!length(objectives))
		result += "<i>(no objectives)</i><br>"
	else
		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			result += "<B>[obj_count]</B>: <font color=[objective.check_completion() ? "green" : "white"]>[objective.explanation_text]</font> <a href='byond://?src=[REF(owner)];obj_edit=[REF(objective)]'>Edit</a> <a href='byond://?src=[REF(owner)];obj_delete=[REF(objective)]'>Delete</a> <a href='byond://?src=[REF(owner)];obj_completed=[REF(objective)]'><font color=[objective.completed ? "green" : "red"]>[objective.completed ? "Mark as incomplete" : "Mark as complete"]</font></a><br>"
			obj_count++
	return result

/datum/antagonist/proc/antag_panel_memory()
	var/out = "<b><i>Antagonist Memory</i></b>:      (<a href='byond://?src=[REF(src)];memory_edit=1'>Edit memory</a>)<br>"
	if(length(antag_memory))
		out += antag_memory
	else
		out += "<i>(empty)</i>"
	return out

/datum/mind/proc/get_common_admin_commands()
	var/common_commands = "<span>Common Commands: </span>"
	if(ishuman(current))
		common_commands += "<a href='byond://?src=[REF(src)];common=undress'>undress</a>"
	else if(iscyborg(current))
		var/mob/living/silicon/robot/R = current
		if(R.emagged)
			common_commands += "<a href='byond://?src=[REF(src)];silicon=Unemag'>Unemag</a>"
	else if(isAI(current))
		var/mob/living/silicon/ai/A = current
		if (A.connected_robots.len)
			for (var/mob/living/silicon/robot/R in A.connected_robots)
				if (R.emagged)
					common_commands += "<a href='byond://?src=[REF(src)];silicon=unemagcyborgs'>Unemag slaved cyborgs</a>"
					break
	return common_commands

/datum/mind/proc/get_special_statuses()
	var/list/result = LAZYCOPY(special_statuses)
	if(!current)
		result += span_bad("No body!")
	if(current && HAS_TRAIT(current, TRAIT_MINDSHIELD))
		result += span_good("Mindshielded")
	//Move these to mob
	if(iscyborg(current))
		var/mob/living/silicon/robot/robot = current
		if (robot.emagged)
			result += span_bad("Emagged")
	return result.Join(" | ")

/datum/mind/proc/traitor_panel()
	if(!SSticker.HasRoundStarted())
		alert("Not before round-start!", "Alert")
		return
	if(QDELETED(src))
		alert("This mind doesn't have a mob, or is deleted! For some reason!", "Edit Memory")
		return

	var/out = "[TOOLTIP_CSS_SETUP]<span style='font-size: 24px; margin: 8px; height: 0px; display: block;'><B>[name]</B>[(current && (current.real_name!=name))?" (as [current.real_name])":""]</span><br>"
	out += " - Mind currently owned by key: [full_key()] [active?"(synced)":"(not synced)"]<br>"
	out += " - Assigned role: [assigned_role]. <a href='byond://?src=[REF(src)];role_edit=1'>Edit</a><br>"
	out += " - Faction and special role: <b><font color='red'>[special_role]</font></b><br>"

	var/special_statuses = get_special_statuses()
	if(length(special_statuses))
		out += " - Special Statuses: [special_statuses]<br>"

	//// Initializing antag panel texts ////
	if(!GLOB.antag_prototypes)
		GLOB.antag_prototypes = list()
		for(var/antag_type in subtypesof(/datum/antagonist))
			var/datum/antagonist/A = new antag_type
			var/cat_id = A.antagpanel_category
			if(!GLOB.antag_prototypes[cat_id])
				GLOB.antag_prototypes[cat_id] = list(A)
			else
				GLOB.antag_prototypes[cat_id] += A
	sortTim(GLOB.antag_prototypes,GLOBAL_PROC_REF(cmp_text_asc),associative=TRUE)

	var/list/sections = list()
	var/list/priority_sections = list()

	for(var/antag_category in GLOB.antag_prototypes)
		var/category_header = "<tr><td><i><b>[antag_category]:</b></i></td><td>"
		var/list/antag_header_parts = list(category_header)

		var/datum/antagonist/current_antag
		var/list/possible_admin_antags = list()

		for(var/datum/antagonist/prototype in GLOB.antag_prototypes[antag_category])
			var/datum/antagonist/A = has_antag_datum(prototype.type, FALSE)
			if(A)
				//We got the antag
				if(!current_antag)
					current_antag = A
				else
					continue //Let's skip subtypes of what we already shown.
			else if(prototype.show_in_antagpanel)
				if(prototype.can_be_owned(src))
					possible_admin_antags += "<a href='byond://?src=[REF(src)];add_antag=[prototype.type]' title='[prototype.type]'>[prototype.name]</a>"
				else
					possible_admin_antags += "<a class='linkOff'>[prototype.name]</a>"
			else
				//We don't have it and it shouldn't be shown as an option to be added.
				continue

		if(!current_antag) //Show antagging options
			if(possible_admin_antags.len)
				antag_header_parts += possible_admin_antags.Join("")
			else
				//If there's no antags to show in this category skip the section completely
				antag_header_parts += "</td></tr>"
				continue
		else //Show removal and current one
			priority_sections |= antag_category
			antag_header_parts += span_bad("[current_antag.name]")
			antag_header_parts += " - <a href='byond://?src=[REF(src)];remove_antag=[REF(current_antag)]'>Remove</a>"

		//We aren't antag of this category, grab first prototype to check the prefs (This is pretty vague but really not sure how else to do this)
		var/datum/antagonist/pref_source = current_antag
		if(!pref_source)
			for(var/datum/antagonist/prototype in GLOB.antag_prototypes[antag_category])
				if(!prototype.show_in_antagpanel)
					continue
				pref_source = prototype
				break
		if(pref_source.banning_key)
			if(is_banned_from(src.key, pref_source.banning_key))
				antag_header_parts += span_bad("<b>\[BANNED\]</b>")
			else if(current?.client)
				var/list/related_preferences = list()
				for(var/datum/role_preference/role_pref_type as anything in GLOB.role_preference_entries)
					if(initial(role_pref_type.antag_datum) == pref_source.type)
						related_preferences += role_pref_type
				if(length(related_preferences) == 1)
					antag_header_parts += current.client.role_preference_enabled(related_preferences[1]) ? "(Enabled in Prefs)" : "(Disabled in Prefs)"
				else if(length(related_preferences) >= 1)
					for(var/datum/role_preference/preftype as anything in related_preferences)
						antag_header_parts += "<br> - <b>[initial(preftype.name)]:</b> [current.client.role_preference_enabled(preftype) ? "(Enabled Pref)" : "(Disabled Pref)"]"
		antag_header_parts += "</td></tr>"

		//Traitor : None | Traitor | IAA
		//	Command1 | Command2 | Command3
		//	Secret Word : Banana
		//	Objectives:
		//		1.Do the thing [a][b]
		//		[a][b]
		//	Memory:
		//		Uplink Code: 777 Alpha
		var/cat_section = antag_header_parts.Join("")
		if(current_antag)
			cat_section += current_antag.antag_panel()
		sections[antag_category] = cat_section

	out += "<hr>"
	out += "<style>table, td {border:1px solid grey;}</style>" // bit clunky snowflake
	out += "<table style='width:auto; border:1px solid black;'>"
	for(var/s in priority_sections)
		out += sections[s]
	for(var/s in sections - priority_sections)
		out += sections[s]
	out += "</table>"
	//// End of antag panel texts ////

	//Uplink
	out += "<hr>"
	if(ishuman(current))
		var/uplink_info = "<i><b>Uplink</b></i>:"
		var/datum/component/uplink/U = find_syndicate_uplink()
		if(U)
			uplink_info += "<a href='byond://?src=[REF(src)];common=takeuplink'>take</a>"
			if (check_rights(R_FUN, 0))
				uplink_info += ", <a href='byond://?src=[REF(src)];common=crystals'>[U.telecrystals]</a> TC"
			else
				uplink_info += ", [U.telecrystals] TC"
		else
			uplink_info += "<a href='byond://?src=[REF(src)];common=uplink'>give</a>"
		uplink_info += "." //hiel grammar

		out += uplink_info + "<br>"

	//Common Memory
	out += "<hr>"
	var/common_memory = "<b><i>Common Memory</i></b>      (<a href='byond://?src=[REF(src)];memory_edit=1'>Edit Memory</a>)</span><br>"
	if(memory)
		common_memory += memory
	out += common_memory + "<br>"
	//Other stuff
	out += "<hr>"
	out += get_common_admin_commands()

	var/datum/browser/panel = new(usr, "traitorpanel", "", 600, 600)
	panel.set_content(out)
	panel.open()
	return
