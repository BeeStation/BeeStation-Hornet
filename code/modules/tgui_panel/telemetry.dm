/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/// Moved to _DEFINES/tgui.dm


/datum/tgui_panel
	/// Time of telemetry request
	var/telemetry_requested_at
	/// Time of telemetry analysis completion
	var/telemetry_analyzed_at
	/// List of previous client connections
	var/list/telemetry_connections
	/// Telemetry Status
	var/telemetry_status = TGUI_TELEMETRY_STAT_NOT_REQUESTED
	/// Telemetry Notices
	var/list/telemetry_notices
	var/alert_low = FALSE
	var/alert_med = FALSE
	var/alert_high = FALSE

/**
 * private
 *
 * Requests some telemetry from the client.
 */
/datum/tgui_panel/proc/request_telemetry()
	telemetry_requested_at = world.time
	telemetry_analyzed_at = null
	telemetry_status = TGUI_TELEMETRY_STAT_AWAITING
	window.send_message("telemetry/request", list(
		"limits" = list(
			"connections" = TGUI_TELEMETRY_MAX_CONNECTIONS,
		),
	))
	addtimer(CALLBACK(src, PROC_REF(handle_telemetry_timeout)), TGUI_TELEMETRY_RESPONSE_WINDOW) // give [TGUI_TELEMETRY_RESPONSE_WINDOW] to send telemetry

/**
 * private
 *
 * Handles a timeout from telemetry (usually, the client has lost connection or is actively refusing to send telemetry)
 */
/datum/tgui_panel/proc/handle_telemetry_timeout()
	if(client && !QDELETED(client) && !telemetry_analyzed_at && telemetry_status <= TGUI_TELEMETRY_STAT_AWAITING && !broken)
		telemetry_status = TGUI_TELEMETRY_STAT_MISSING
		var/msg = "[key_name(client)] has timed out on the telemetry request. It's possible they are using a hacked client. Kicking them from the server."
		message_admins(msg)
		log_admin_private(msg)
		qdel(client)

/**
 * private
 *
 * Analyzes a telemetry packet.
 *
 * Is currently only useful for detecting ban evasion attempts.
 */
/datum/tgui_panel/proc/analyze_telemetry(payload)
	if(telemetry_status == TGUI_TELEMETRY_STAT_OVERSEND)
		return //Already noted for oversend, just fuck off.
	if(world.time > telemetry_requested_at + TGUI_TELEMETRY_RESPONSE_WINDOW)
		message_admins("[key_name(client)] sent telemetry outside of the allocated time window.")
		if(telemetry_status == TGUI_TELEMETRY_STAT_ANALYZED) //Hey we already have a packet from you!
			LAZYSET(telemetry_notices, "TELEM_OVERSEND", span_highlight("OVER_SEND|Telemetry was sent multiple times."))
			telemetry_status = TGUI_TELEMETRY_STAT_OVERSEND
			alert_high = TRUE
		return
	if(telemetry_analyzed_at)
		message_admins("[key_name(client)] sent telemetry more than once.")
		LAZYSET(telemetry_notices, "TELEM_OVERSEND", span_highlight("OVER_SEND|Telemetry was sent multiple times."))
		telemetry_status = TGUI_TELEMETRY_STAT_OVERSEND
		alert_high = TRUE
		return
	telemetry_analyzed_at = world.time
	telemetry_status = TGUI_TELEMETRY_STAT_ANALYZED
	if(!payload)
		return
	telemetry_connections = payload["connections"]
	var/len = length(telemetry_connections)
	if(len == 0)
		return
	if(len > TGUI_TELEMETRY_MAX_CONNECTIONS)
		alert_high = TRUE
		message_admins("[key_name(client)] was kicked for sending a huge telemetry payload")
		qdel(client)
		return
	if(len < TGUI_TELEMETRY_MAX_CONNECTIONS)
		if(len < (TGUI_TELEMETRY_MAX_CONNECTIONS * 0.5))
			LAZYSET(telemetry_notices, "TELEMETRY_NONMAXCON", span_highlight("TOO_SHORT|User only has ([len]) records. Data may be extremely unreliable."))
		else
			LAZYSET(telemetry_notices, "TELEMETRY_NONMAXCON", span_highlight("UNDER_MAX|User has less than [TGUI_TELEMETRY_MAX_CONNECTIONS] entries in history ([len])."))
		alert_low = TRUE

	//Process the data.
	var/list/first_found_ban
	var/list/all_ckeys
	var/list/all_cids
	var/list/all_ips
	var/skipped_entries
	var/has_dev_ip
	for(var/i in 1 to len)
		if(QDELETED(client))
			// He got cleaned up before we were done
			return
		var/list/row = telemetry_connections[i]
		// Check for guest keys, these objects are probably either banned by default or are "corrupt" (Missing an address).
		if("guest[row["computer_id"]]" == row["ckey"])
			LAZYSET(telemetry_notices, "TELEM_GUEST_[i]", span_highlight("CONN_ID:[i]|Entry is a guest user. This entry has been skipped."))
			skipped_entries++
			LAZYADD(all_cids, row["computer_id"])
			continue
		// Check for a malformed history object
		if(!row || row.len < 3 || (!row["ckey"] || !row["address"] || !row["computer_id"]))
			if(row && row["ckey"] && row["computer_id"]) //Is the address the only invalid field?
				LAZYSET(telemetry_notices, "TELEM_NOADDR_[i]", span_highlight("CONN_ID:[i]|Entry has no address. User may be a developer."))
				LAZYADD(all_ckeys, row["ckey"])
				LAZYADD(all_ips, "127.0.0.1")
				LAZYADD(all_cids, row["computer_id"])
				has_dev_ip = 1
				continue
			LAZYSET(telemetry_notices, "TELEM_CORRUPT_[i]", span_highlight("CONN_ID:[i]|Entry corrupt. Data may be damaged or tampered with."))
			alert_high = TRUE
			skipped_entries++
			continue
		//Check for bans.
		if(world.IsBanned(row["ckey"], row["address"], row["computer_id"], "tgui_telemetry", real_bans_only = TRUE))
			if(!first_found_ban)
				first_found_ban = row
			LAZYSET(telemetry_notices,"TELEM_BANNED_[i]", span_bad("CONN_ID:[i]|BANNED ACCOUNT IN HISTORY! Matched: [row["ckey"]], [row["address"]], [row["computer_id"]]"))
			alert_high = TRUE
		//Check for protected CIDs
		if(config.protected_cids.Find(row["computer_id"]))
			LAZYSET(telemetry_notices, "TELEM_PROTECTED_[i]", span_bad("CONN_ID:[i]|[row["computer_id"]] is protected, Reason: [config.protected_cids[row["computer_id"]]]"))
			alert_high = TRUE
		//Track changes.
		LAZYADD(all_ckeys, row["ckey"])
		LAZYADD(all_ips, row["address"])
		LAZYADD(all_cids, row["computer_id"])
		CHECK_TICK
	// At least one ban
	//Subtract the amount of skipped entries from len to account for possibly corrupt data
	len -= skipped_entries
	if(first_found_ban)
		var/msg = "[key_name(client)] has a banned account in connection history! (Matched: [first_found_ban["ckey"]], [first_found_ban["address"]], [first_found_ban["computer_id"]])"
		message_admins(msg)
		log_admin_private(msg)
	all_ckeys = unique_list(all_ckeys)
	all_ips = unique_list(all_ips)
	all_cids = unique_list(all_cids)
	switch(length(all_ckeys))
		if(2)
			LAZYSET(telemetry_notices, TGUI_TELEM_CKEY_WARNING, span_average("KEY_COUNT|User has more than one CKEY in history."))
			alert_med = TRUE
		if(3 to INFINITY)
			if(length(all_ckeys) == len)
				LAZYSET(telemetry_notices, TGUI_TELEM_CKEY_WARNING, span_bad("KEY_COUNT|<b>EVERY ENTRY IN HISTORY HAS A DIFFERENT CKEY!</b>"))
				alert_high = TRUE
			else
				LAZYSET(telemetry_notices, TGUI_TELEM_CKEY_WARNING, span_bad("KEY_COUNT|User has multiple CKEYs in history!"))
				alert_high = TRUE
	if(telemetry_notices?[TGUI_TELEM_CKEY_WARNING]) //Has a CKEY warning
		var/text_list_ckeys = ""
		var/first = 1
		for(var/entry in all_ckeys)
			text_list_ckeys += "[first ? null : ","][entry]"
			first = 0
		LAZYSET(telemetry_notices, "TGUI_CKEY_LIST", "ALL_CKEYS|[text_list_ckeys]")
	switch(length(all_ips))
		if(2)
			if(!has_dev_ip) //If it's a dev IP we don't care.
				LAZYSET(telemetry_notices, TGUI_TELEM_IP_WARNING, span_average("IPA_COUNT|User has changed IPs at least once."))
		if(3 to INFINITY)
			if(length(all_ips) == len)
				LAZYSET(telemetry_notices, TGUI_TELEM_IP_WARNING, span_average("IPA_COUNT|All IPs different. VPN Likely."))
				alert_low = TRUE
			else
				LAZYSET(telemetry_notices, TGUI_TELEM_IP_WARNING, span_average("IPA_COUNT|User has changed IPs at least once."))
	switch(length(all_cids))
		if(2)
			LAZYSET(telemetry_notices, TGUI_TELEM_CID_WARNING, span_average("CID_COUNT|User has changed CIDs once."))
		if(3 to INFINITY)
			if(length(all_cids) == len)
				LAZYSET(telemetry_notices, TGUI_TELEM_CID_WARNING, span_bad("CID_COUNT|<b>EVERY ENTRY IN HISTORY HAS A DIFFERENT CID!</b>"))
				alert_high = TRUE
			else
				LAZYSET(telemetry_notices, TGUI_TELEM_CID_WARNING, span_bad("CID_COUNT|User has more than two CIDs in history."))
				alert_med = TRUE

/// Render the stats to PP
/datum/tgui_panel/proc/show_notices()
	//Yes this code was in fact just dragged out and thrown in a different file.
	. += "<br><b>Telemetry Status:</b>"
	switch(telemetry_status)
		if(TGUI_TELEMETRY_STAT_NOT_REQUESTED)
			. += span_bad("Telemetry Request Not Sent. Call a coder.")
		if(TGUI_TELEMETRY_STAT_AWAITING)
			. += span_highlight("Telemetry Awaiting.")
		if(TGUI_TELEMETRY_STAT_ANALYZED, TGUI_TELEMETRY_STAT_OVERSEND)
			. += "Analyzed Successfully."
			. += "<br><b>Telemetry Alerts:</b>"
			if(!length(telemetry_notices))
				. += span_good("No Alerts.")
				return
			. += "<br><pre><ul>"
			for(var/notice in telemetry_notices)
				. += "<li>[telemetry_notices[notice]]</li>"
			. += "</pre></ul>"
		if(TGUI_TELEMETRY_STAT_MISSING)
			. += span_bad("Telemetry Data Missing!")
		else
			. += span_bad("Telemetry datum in invalid state ID [isnum(telemetry_status) ? telemetry_status : "!!NAN!!, CALL A CODER"]. Call a coder.")

/// Gets the alert level for telemetry notices, None "", Low "?", Med "!", or High "!!!"
/datum/tgui_panel/proc/get_alert_level()
	switch(telemetry_status)
		if(TGUI_TELEMETRY_STAT_NOT_REQUESTED)
			return "???"
		if(TGUI_TELEMETRY_STAT_AWAITING)
			return "..."
		if(TGUI_TELEMETRY_STAT_ANALYZED, TGUI_TELEMETRY_STAT_OVERSEND)
			if(alert_high)
				return "!!!"
			if(alert_med)
				return "!"
			if(alert_low)
				return "?"
			return ""
		if(TGUI_TELEMETRY_STAT_MISSING)
			return "???"
	return "Call a coder!"
