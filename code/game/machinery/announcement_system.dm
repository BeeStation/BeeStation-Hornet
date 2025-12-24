GLOBAL_LIST_EMPTY(announcement_systems)

/obj/machinery/announcement_system
	density = TRUE
	name = "\improper Automated Announcement System"
	desc = "An automated announcement system that handles minor announcements over the radio."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "AAS_On"
	base_icon_state = "AAS"

	verb_say = "coldly states"
	verb_ask = "queries"
	verb_exclaim = "alarms"

	idle_power_usage = 20
	active_power_usage = 50

	circuit = /obj/item/circuitboard/machine/announcement_system

	/// All possible announcements and their local configurations
	var/list/datum/aas_config_entry/config_entries = list()

	/// The headset that we use for broadcasting
	var/obj/item/radio/headset/radio
	/// AIs headset support all stations channels, but it may require an override for away site or syndie AASs.
	var/radio_type = /obj/item/radio/headset/silicon/ai

	var/greenlight = "Light_Green"
	var/pinklight = "Light_Pink"
	var/errorlight = "Error_Red"

/obj/machinery/announcement_system/Initialize(mapload)
	config_entries = init_subtypes(/datum/aas_config_entry, list())
	. = ..()
	radio = new radio_type(src)
	GLOB.announcement_systems += src
	update_appearance()

/obj/machinery/announcement_system/Destroy()
	QDEL_NULL(radio)
	QDEL_LAZYLIST(config_entries)
	GLOB.announcement_systems -= src // "OH GOD WHY ARE THERE 100,000 LISTED ANNOUNCEMENT SYSTEMS?!!"
	return ..()

/obj/machinery/announcement_system/update_icon_state()
	icon_state = "[base_icon_state]_[is_operational && !(machine_stat & EMPED) ? "On" : "Off"][panel_open ? "_Open" : null]"
	return ..()

/obj/machinery/announcement_system/update_overlays()
	. = ..()
	var/datum/aas_config_entry/entry = locate(/datum/aas_config_entry/arrival) in config_entries
	if(entry && entry.enabled)
		. += greenlight

	entry = locate(/datum/aas_config_entry/newhead) in config_entries
	if(entry && entry.enabled)
		. += pinklight

	if(machine_stat & EMPED)
		. += errorlight

/obj/machinery/announcement_system/update_icon_state()
	icon_state = "[base_icon_state]_[is_operational && !(machine_stat & EMPED) ? "On" : "Off"][panel_open ? "_Open" : null]"
	return ..()

/obj/machinery/announcement_system/screwdriver_act(mob/living/user, obj/item/tool)
	var/icon_state_assemble = "[base_icon_state]_[is_operational && !(machine_stat & EMPED) ? "On" : "Off"]"
	if(default_deconstruction_screwdriver(user, "[icon_state_assemble]_Open", icon_state_assemble, tool))
		return TRUE
	return FALSE

/obj/machinery/announcement_system/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/announcement_system/multitool_act(mob/living/user, obj/item/tool)
	if(!panel_open || !(machine_stat & EMPED))
		return FALSE
	to_chat(user, span_notice("You reset [src]'s firmware."))
	set_machine_stat(machine_stat & ~EMPED)
	update_appearance()
	return TRUE

/obj/machinery/announcement_system/emp_act(severity)
	. = ..()
	if(!(machine_stat & (NOPOWER|EMPED|BROKEN)) && !(. & EMP_PROTECT_SELF))
		act_up()

/obj/machinery/announcement_system/on_emag(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	act_up()
	balloon_alert(user, "announcement strings corrupted")

/// Does funny breakage stuff
/obj/machinery/announcement_system/proc/act_up()
	if (machine_stat & EMPED)
		return
	set_machine_stat(machine_stat | EMPED)
	update_appearance()
	for (var/datum/aas_config_entry/config in config_entries)
		config.act_up()

/obj/machinery/announcement_system/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AutomatedAnnouncement")
		ui.open()

/obj/machinery/announcement_system/ui_data()
	var/list/configs = list()
	for(var/datum/aas_config_entry/config in config_entries)
		configs += list(list(
			name = config.name,
			entryRef = REF(config),
			enabled = config.enabled,
			modifiable = config.modifiable,
			announcementLinesMap = config.announcement_lines_map,
			generalTooltip = config.general_tooltip,
			varsAndTooltipsMap = config.vars_and_tooltips_map
		))
	return list("config_entries" = configs)

/obj/machinery/announcement_system/ui_static_data(mob/user)
	var/list/data = list()

	data["max_announcement_len"] = MAX_AAS_LENGTH

	return data

/obj/machinery/announcement_system/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!usr.canUseTopic(src, !issilicon(usr)))
		return
	if(machine_stat & EMPED)
		visible_message(span_warning("[src] buzzes."), span_hear("You hear a faint buzz."))
		playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
		return

	add_fingerprint(usr)
	var/datum/aas_config_entry/config = locate(params["entryRef"]) in config_entries
	if(!config || !config.modifiable)
		return

	switch(action)
		if("Toggle")
			config.enabled = !config.enabled
			if (config.type in list(/datum/aas_config_entry/arrival, /datum/aas_config_entry/newhead))
				update_appearance()
			return TRUE
		if("Text")
			if(!(params["lineKey"] in config.announcement_lines_map))
				message_admins("[ADMIN_LOOKUPFLW(usr)] tried to set announcement line for nonexisting line in the [config.name] for AAS. Probably href injection. Received line: [html_encode(params["lineKey"])]")
				log_game("[key_name(usr)] tried to mess with AAS. For [config.name] he tried to edit nonexistend [params["lineKey"]]")
				return
			var/new_message = trim(html_encode(params["newText"]), MAX_MESSAGE_LEN)
			if(new_message)
				config.announcement_lines_map[params["lineKey"]] = new_message
				usr.log_message("updated [params["lineKey"]] line in the [config.name] to: [new_message]", LOG_GAME)
			return TRUE


/obj/machinery/announcement_system/can_interact(mob/user)
	. = ..()
	if (!.)
		return

	if (machine_stat & EMPED)
		to_chat(user, span_warning("[src]'s firmware appears to be malfunctioning!"))
		if (!isAI(user))	// Deus Ex Machina goes without multitool in his default complectation.
			to_chat(user, span_warning("However, you can reset it with <b>multitool</b>, while its <b>panel is open</b>!"))
		return FALSE

/// If AAS can't broadcast message, it shouldn't be picked by randomizer.
/obj/machinery/announcement_system/proc/has_supported_channels(list/channels)
	if (!LAZYLEN(channels) || (RADIO_CHANNEL_COMMON in channels))
		// Okay, I am not proud of this, but I don't want CentCom or Syndie AASs to broadcast on Common.
		// Because our overrides can just change radio withour creating new subtype we prefer to check both.
		return src.type == /obj/machinery/announcement_system && src.radio_type == /obj/machinery/announcement_system::radio_type
	for(var/channel in channels)
		if(radio.channels[channel])
			return TRUE
	return FALSE

/// Can AAS receive request for broadcast from you? Null source means yes.
/obj/machinery/announcement_system/proc/can_be_reached_from(atom/source)
	if(!source || !istype(source))
		return TRUE
	var/turf/source_turf = get_turf(source)
	if (!source_turf)
		return TRUE
	// Keep updated with broadcasting.dm (/datum/signal/subspace/vocal/New)
	// FFF (For Future Feature): think about adding radio relay support. Maybe implementing /datum/signal/subspace/aas_event or something similar.
	return z in source_turf.get_virtual_z_level()

/// Compiles the announcement message with the provided variables. Announcement line is optional.
/obj/machinery/announcement_system/proc/compile_config_message(aas_config_entry_type, list/variables_map, announcement_line, fail_if_disabled=FALSE)
	var/datum/aas_config_entry/config = locate(aas_config_entry_type) in config_entries
	if (!config || (fail_if_disabled && !config.enabled))
		return
	return config.compile_announce(variables_map, announcement_line)

/// Sends a message to the appropriate channels.
/obj/machinery/announcement_system/proc/broadcast(message, list/channels, command_span = FALSE)
	use_power(active_power_usage)
	if(!LAZYLEN(channels))
		radio.talk_into(src, message, null, command_span ? list(speech_span, SPAN_COMMAND) : null)
		return

	// For some reasons, radio can't recognize RADIO_CHANNEL_COMMON in channels, so we need to handle it separately.
	if (RADIO_CHANNEL_COMMON in channels)
		radio.talk_into(src, message, null, command_span ? list(speech_span, SPAN_COMMAND) : null)
		channels -= RADIO_CHANNEL_COMMON
	for(var/channel in channels)
		radio.talk_into(src, message, channel, command_span ? list(speech_span, SPAN_COMMAND) : null)

/// Announces configs entry message with the provided variables. Channels, announcement_line and command_span are optional.
/obj/machinery/announcement_system/proc/announce(aas_config_entry_type, list/variables_map, list/channels, announcement_line, command_span)
	var/msg = compile_config_message(aas_config_entry_type, variables_map, announcement_line, TRUE)
	if (msg)
		broadcast(msg, channels, command_span)

/// Returns a random announcement system that is operational, has the specified config entry, signal can reach source and radio supports any channel in list. All args are optional.
/proc/get_announcement_system(aas_config_entry_type, source, list/channels)
	if (!length(GLOB.announcement_systems))
		return null
	var/list/intact_aass = list()
	for(var/obj/machinery/announcement_system/announce as anything in GLOB.announcement_systems)
		if(!QDELETED(announce) && announce.is_operational && announce.has_supported_channels(channels) && announce.can_be_reached_from(source))
			if(aas_config_entry_type)
				var/datum/aas_config_entry/entry = locate(aas_config_entry_type) in announce.config_entries
				if(!entry || !entry.enabled)
					continue
			intact_aass += announce
	return length(intact_aass) ? pick(intact_aass) : null

/// Announces the provided message with the provided variables and config entry type. Only aas_config_entry_type and variables_map are mandatory. Other args are optional.
/proc/aas_config_announce(aas_config_entry_type, list/variables_map, source, list/channels, announcement_line, command_span)
	var/obj/machinery/announcement_system/announcer = get_announcement_system(aas_config_entry_type, source, channels)
	if (!announcer)
		return
	announcer.announce(aas_config_entry_type, variables_map, channels, announcement_line, command_span)

/datum/aas_config_entry
	var/name = "AAS configurable entry"
	// Should we broadcast this announcement?
	var/enabled = TRUE
	// The announcement message. Key will be displayed in the UI.
	var/list/announcement_lines_map = list("Message" = "This is a default announcement line.")
	// Goes before tooltips for vars, mainly used if announcement has no replacable vars
	var/general_tooltip
	// Contains all replacable vars and their tooltips
	var/list/vars_and_tooltips_map = list()
	// Can be changed or disabled by players
	var/modifiable = TRUE

/// Compiles the announcement message with the provided variables. Announcement line is optional, may be both index or line key.
/datum/aas_config_entry/proc/compile_announce(list/variables_map, announcement_line)
	var/announcement_message = LAZYACCESS(announcement_lines_map, announcement_line)
	// If index was provided LAZYACCESS will return us a key, not value
	if (isnum(announcement_line))
		announcement_message = announcement_lines_map[announcement_message]
	// Fallback - first line
	if (!announcement_message)
		announcement_message = announcement_lines_map[announcement_lines_map[1]]
	// Replace variables with their value
	for(var/variable in vars_and_tooltips_map)
		announcement_message = replacetext_char(announcement_message, "%[variable]", variables_map[variable] || "\[NO DATA\]")
	return announcement_message

/// Called when the announcement system is emagged or EMPed.
/datum/aas_config_entry/proc/act_up()
	SHOULD_CALL_PARENT(TRUE)

	// Please do not mess with entries, that players can't fix.
	if(!modifiable)
		return TRUE
	return FALSE

/*
	Global config entries for the announcement system.
*/

/datum/aas_config_entry/arrival
	name = "Global: Arrival Announcement"
	announcement_lines_map = list(
		"Message" = "%PERSON has signed up as %RANK",
	)
	vars_and_tooltips_map = list(
		"PERSON" = "will be replaced with their name.",
		"RANK" = "with their job.",
	)

/datum/aas_config_entry/arrival/act_up()
	. = ..()
	if (.)
		return

	announcement_lines_map["Message"] = pick(
		"#!@%ERR-34%2 CANNOT LOCAT@# JO# F*LE!",
		"CRITICAL ERROR 99.",
		"ERR)#: DA#AB@#E NOT F(*ND!",
	)

/datum/aas_config_entry/newhead
	name = "Departmental: Head Announcement"
	announcement_lines_map = list(
		"Message" = "%PERSON, %RANK, is the department head.",
	)
	vars_and_tooltips_map = list(
		"PERSON" = "will be replaced with their name.",
		"RANK" = "with their job.",
	)

/datum/aas_config_entry/newhead/act_up()
	. = ..()
	if (.)
		return

	announcement_lines_map["Message"] = pick(
		"OV#RL()D: \[UNKNOWN??\] DET*#CT)D!",
		"ER)#R - B*@ TEXT F*O(ND!",
		"AAS.exe is not responding. NanoOS is searching for a solution to the problem.",
	)

/datum/aas_config_entry/cryo
	name = "Global: Cryo Announcement"
	announcement_lines_map = list(
		"Message" = "%PERSON, %RANK has been moved to cryo storage.",
	)
	vars_and_tooltips_map = list(
		"PERSON" = "will be replaced with their name.",
		"RANK" = "with their job.",
	)

/datum/aas_config_entry/cryo/act_up()
	. = ..()
	if (.)
		return

	announcement_lines_map["Message"] = pick(
		"ERR: BI(METR*C FE*D&ACK LOST.",
		"SUBJECT DETEC#*- B#(!*@NG INCINERATION.",
		"CRYO SYS: TRANSFER COMPLETE.",
	)

/datum/aas_config_entry/intelligence_storage
	name = "Global: Intelligence Storage Announcement"
	announcement_lines_map = list(
		"Message" = "%SILICON has been moved to intelligence storage.",
	)
	vars_and_tooltips_map = list(
		"SILICON" = "will be replaced with its name.",
	)

/datum/aas_config_entry/intelligence_storage/act_up()
	. = ..()
	if (.)
		return

	announcement_lines_map["Message"] = pick(
		"ERR)#R: PERSONALITY MATRIX NOT RESPONDING.",
		"UNIT HAS BEEN SENT TO ANDROID HELL.", // GLaDOS
		"Attempting to reboot %SILICON, please standby... F#TAL ERR()%!",
	)

/datum/aas_config_entry/exploration_payout
	name = "Departmental: Exploration Payout"
	announcement_lines_map = list(
		"Message" = "Exploration objective completed. %PAYOUT credits have been distributed to the departmental budget.",
	)
	vars_and_tooltips_map = list(
		"PAYOUT" = "will be replaced with the payout amount per department.",
	)

/datum/aas_config_entry/exploration_payout/act_up()
	. = ..()
	if (.)
		return

	announcement_lines_map["Message"] = pick(
		replacetext(/datum/aas_config_entry/exploration_payout::announcement_lines_map["Message"], "%PAYOUT", "[rand(0, 1000000)]"),
		"ERR)#R: ROUNDING ADJUSTMENT APPLIED.",
		"AAS.exe is not responding. NanoOS is searching for a solution to the problem.",
	)

/datum/aas_config_entry/arrivals_broken
	name = "Engineering Alert: Arrivals Shuttle Malfunction Announcement"
	announcement_lines_map = list(
		"Message" = "The arrivals shuttle has been damaged. Docking for repairs...",
	)
	general_tooltip = "Broadcasted, when arrivals shuttle docks for repairs. No replaceable variables provided."
	modifiable = FALSE
