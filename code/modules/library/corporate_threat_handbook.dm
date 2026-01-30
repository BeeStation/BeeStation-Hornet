// Threat designations:
// - Negligible:
//   - Minimal risk to crew or station operations. May require security attention or monitoring.
// - Minor:
//   - Low risk. Requires security attention but poses no significant threat to station integrity.
// - Moderate:
//   - Notable risk to crew safety. Direct security intervention required. Coordination with department heads advised.
// - Major:
//   - Significant threat to multiple crew members or critical systems. Full security mobilization required.
// - Severe:
//   - Extreme danger to station survival. All crew should be on high alert. Command-level response necessary.
// - Critical:
//   - Existential threat to the station. Evacuation protocols may be necessary. Maximum response authorized.


/obj/item/book/manual/tgui_handbook
	name = "Nanotrasen Incident Awareness Handbook"
	desc = "An official-looking, faintly mildewed handbook full of mandatory reading. The cover is stamped 'FOR INTERNAL DISTRIBUTION' and smells like recycled paper and burnt coffee."
	icon = 'icons/obj/library.dmi'
	icon_state = "security_briefing"
	author = "Nanotrasen Compliance & Workplace Readiness"
	title = "Incident Awareness & Threat Recognition (Crew Issue)"
	unique = TRUE
	/// Path to the config file containing threat entries
	var/config_file = "config/corporate_threats.json"
	/// Static list of threat entries, shared across all instances
	var/static/list/threat_entries
	/// The current page the book is turned to
	var/current_page = 0

/obj/item/book/manual/tgui_handbook/Initialize(mapload)
	. = ..()
	if(!threat_entries)
		load_threat_entries()

/obj/item/book/manual/tgui_handbook/proc/load_threat_entries()
	threat_entries = list()
	try
		var/json_data = file2text(config_file)
		if(!json_data)
			CRASH("Failed to read corporate threats config file")
		var/list/parsed = json_decode(json_data)
		if(!islist(parsed))
			CRASH("Corporate threats config file is not a valid list")
		// Build associative list keyed by label for sorting
		var/list/entries_by_label = list()
		for(var/list/entry in parsed)
			if(!entry["label"])
				continue
			entries_by_label[entry["label"]] = entry
		// Sort keys alphabetically and rebuild list
		var/list/sorted_keys = sort_list(entries_by_label)
		for(var/key in sorted_keys)
			threat_entries += list(entries_by_label[key])
	catch(var/exception/e)
		log_runtime("Failed to load corporate threats config: [e] on [e.file]:[e.line]")
		message_admins(span_boldannounce("Failed to load corporate threats config: [e] on [e.file]:[e.line]"))
		load_default_threats()

/obj/item/book/manual/tgui_handbook/proc/load_default_threats()
	// Fallback data in case config file fails to load
	threat_entries = list(
		list(
			"label" = "Unknown Threat",
			"threat_designation" = "Variable",
			"description" = "This handbook could not load its threat database. Please contact your supervisor for a replacement copy.",
			"signs" = list("Consult security personnel for guidance"),
			"advised_response" = "Report this malfunction to the nearest Nanotrasen representative."
		)
	)

/obj/item/book/manual/tgui_handbook/attack_self(mob/user)
	ui_interact(user)

/obj/item/book/manual/tgui_handbook/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CorporateThreatHandbook", name)
		ui.open()

/obj/item/book/manual/tgui_handbook/ui_state(mob/user)
	return GLOB.always_state

/obj/item/book/manual/tgui_handbook/ui_static_data(mob/user)
	var/list/data = list()
	data["threat_entries"] = threat_entries
	return data

/obj/item/book/manual/tgui_handbook/ui_data(mob/user)
	var/list/data = list()
	data["current_page"] = current_page
	return data

/obj/item/book/manual/tgui_handbook/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("turn_page")
			var/new_page = params["page"]
			if(isnum(new_page))
				current_page = new_page
				playsound(src, pick(
					'sound/items/paper/rustling/rustle1.ogg',
					'sound/items/paper/rustling/rustle2.ogg',
					'sound/items/paper/rustling/rustle3.ogg',
					'sound/items/paper/rustling/rustle4.ogg',
					'sound/items/paper/rustling/rustle5.ogg'), 50, TRUE)
				return TRUE
	return FALSE
