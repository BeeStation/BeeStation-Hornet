/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/// Moved to _DEFINES/tgui.dm

/// Time of telemetry request
/datum/tgui_panel/var/telemetry_requested_at
/// Time of telemetry analysis completion
/datum/tgui_panel/var/telemetry_analyzed_at
/// List of previous client connections
/datum/tgui_panel/var/list/telemetry_connections
/// Telemetry Status
/datum/tgui_panel/var/telemetry_status = TGUI_TELEMETRY_STAT_NOT_REQUESTED
/// Telemetry Notices
/datum/tgui_panel/var/list/telemetry_notices
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
			LAZYSET(telemetry_notices, "TELEM_OVERSEND", "<span class='highlight'>OVER_SEND|Telemetry was sent multiple times.</span>")
			telemetry_status = TGUI_TELEMETRY_STAT_OVERSEND
		return
	if(telemetry_analyzed_at)
		message_admins("[key_name(client)] sent telemetry more than once.")
		LAZYSET(telemetry_notices, "TELEM_OVERSEND", "<span class='highlight'>OVER_SEND|Telemetry was sent multiple times.</span>")
		telemetry_status = TGUI_TELEMETRY_STAT_OVERSEND
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
		message_admins("[key_name(client)] was kicked for sending a huge telemetry payload")
		qdel(client)
		return
	if(len < TGUI_TELEMETRY_MAX_CONNECTIONS)
		if(len < (TGUI_TELEMETRY_MAX_CONNECTIONS * 0.5))
			LAZYSET(telemetry_notices, "TELEMETRY_NONMAXCON", "<span class='highlight'>TOO_SHORT|User only has ([len]) records. Data may be extremely unreliable.</span>")
		else
			LAZYSET(telemetry_notices, "TELEMETRY_NONMAXCON", "<span class='highlight'>UNDER_MAX|User has less than [TGUI_TELEMETRY_MAX_CONNECTIONS] entries in history ([len]).</span>")

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
			LAZYSET(telemetry_notices, "TELEM_GUEST_[i]", "<span class='highlight'>CONN_ID:[i]|Entry is a guest user. This entry has been skipped.</span>")
			skipped_entries++
			LAZYADD(all_cids, row["computer_id"])
			continue
		// Check for a malformed history object
		if(!row || row.len < 3 || (!row["ckey"] || !row["address"] || !row["computer_id"]))
			if(row && row["ckey"] && row["computer_id"]) //Is the address the only invalid field?
				LAZYSET(telemetry_notices, "TELEM_NOADDR_[i]", "<span class='highlight'>CONN_ID:[i]|Entry has no address. User may be a developer.</span>")
				LAZYADD(all_ckeys, row["ckey"])
				LAZYADD(all_ips, "127.0.0.1")
				LAZYADD(all_cids, row["computer_id"])
				has_dev_ip = 1
				continue
			LAZYSET(telemetry_notices, "TELEM_CORRUPT_[i]", "<span class='highlight'>CONN_ID:[i]|Entry corrupt. Data may be damaged or tampered with.</span>")
			skipped_entries++
			continue
		//Check for bans.
		if(world.IsBanned(row["ckey"], row["address"], row["computer_id"], "tgui_telemetry", real_bans_only = TRUE))
			if(!first_found_ban)
				first_found_ban = row
			LAZYSET(telemetry_notices,"TELEM_BANNED_[i]", "<span class='bad'>CONN_ID:[i]|BANNED ACCOUNT IN HISTORY! Matched: [row["ckey"]], [row["address"]], [row["computer_id"]]</span>")
		//Check for protected CIDs
		if(config.protected_cids.Find(row["computer_id"]))
			LAZYSET(telemetry_notices, "TELEM_PROTECTED_[i]", "<span class='bad'>CONN_ID:[i]|[row["computer_id"]] is protected, Reason: [config.protected_cids[row["computer_id"]]]</span>")
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
	all_ckeys = uniqueList(all_ckeys)
	all_ips = uniqueList(all_ips)
	all_cids = uniqueList(all_cids)
	switch(length(all_ckeys))
		if(2)
			LAZYSET(telemetry_notices, TGUI_TELEM_CKEY_WARNING, "<span class='average'>KEY_COUNT|User has more than one CKEY in history.</span>")
		if(3 to INFINITY)
			if(length(all_ckeys) == len)
				LAZYSET(telemetry_notices, TGUI_TELEM_CKEY_WARNING, "<span class='bad'>KEY_COUNT|<b>EVERY ENTRY IN HISTORY HAS A DIFFERENT CKEY!</b></span>")
			else
				LAZYSET(telemetry_notices, TGUI_TELEM_CKEY_WARNING, "<span class='bad'>KEY_COUNT|User has multiple CKEYs in history!</span>")
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
				LAZYSET(telemetry_notices, TGUI_TELEM_IP_WARNING, "<span class='average'>IPA_COUNT|User has changed IPs at least once.</span>")
		if(3 to INFINITY)
			if(length(all_ips) == len)
				LAZYSET(telemetry_notices, TGUI_TELEM_IP_WARNING, "<span class='average'>IPA_COUNT|All IPs different. VPN Likely.</span>")
			else
				LAZYSET(telemetry_notices, TGUI_TELEM_IP_WARNING, "<span class='average'>IPA_COUNT|User has changed IPs at least once.</span>")
	switch(length(all_cids))
		if(2)
			LAZYSET(telemetry_notices, TGUI_TELEM_CID_WARNING, "<span class='average'>CID_COUNT|User has changed CIDs once.")
		if(3 to INFINITY)
			if(length(all_cids) == len)
				LAZYSET(telemetry_notices, TGUI_TELEM_CID_WARNING, "<span class='bad'>CID_COUNT|<b>EVERY ENTRY IN HISTORY HAS A DIFFERENT CID!</b></span>")
			else
				LAZYSET(telemetry_notices, TGUI_TELEM_CID_WARNING, "<span class='bad'>CID_COUNT|User has more than two CIDs in history.</span>")

/// Render the stats to PP
/datum/tgui_panel/proc/show_notices()
	//Yes this code was in fact just dragged out and thrown in a different file.
	. += "<br><b>Telemetry Status:</b>"
	switch(telemetry_status)
		if(TGUI_TELEMETRY_STAT_NOT_REQUESTED)
			. += "<span class='bad'>Telemetry Request Not Sent. Call a coder.</span>"
		if(TGUI_TELEMETRY_STAT_AWAITING)
			. += "<span class='highlight'>Telemetry Awaiting.</span>"
		if(TGUI_TELEMETRY_STAT_ANALYZED, TGUI_TELEMETRY_STAT_OVERSEND)
			. += "Analyzed Successfully."
			. += "<br><b>Telemetry Alerts:</b>"
			if(!length(telemetry_notices))
				. += "<span class='good'>No Alerts.</span>"
				return
			. += "<br><pre><ul>"
			for(var/notice in telemetry_notices)
				. += "<li>[telemetry_notices[notice]]</li>"
			. += "</pre></ul>"
		if(TGUI_TELEMETRY_STAT_MISSING)
			. += "<span class='bad'>Telemetry Data Missing!</span>"
		else
			. += "<span class='bad'>Telemetry datum in invalid state ID [isnum(telemetry_status) ? telemetry_status : "!!NAN!!, CALL A CODER"]. Call a coder.</span>"
