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
	if(world.time > telemetry_requested_at + TGUI_TELEMETRY_RESPONSE_WINDOW)
		message_admins("[key_name(client)] sent telemetry outside of the allocated time window.")
		if(telemetry_status == TGUI_TELEMETRY_STAT_ANALYZED) //Hey we already have a packet from you!
			LAZYADD(telemetry_notices, "<span class='highlight'>Telemetry was sent multiple times.</span>")
			telemetry_status = TGUI_TELEMETRY_STAT_OVERSEND
		return
	if(telemetry_analyzed_at)
		message_admins("[key_name(client)] sent telemetry more than once.")
		LAZYADD(telemetry_notices, "<span class='highlight'>Telemetry was sent multiple times.</span>")
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
		LAZYADD(telemetry_notices, "<span class='highlight'>User has less than [TGUI_TELEMETRY_MAX_CONNECTIONS] entries in history ([len]).</span>")

	//Process the data.
	var/list/first_found_ban
	var/list/all_ckeys
	var/list/all_cids
	var/list/all_ips
	var/skipped_entries
	for(var/i in 1 to len)
		if(QDELETED(client))
			// He got cleaned up before we were done
			return
		var/list/row = telemetry_connections[i]
		// Check for guest keys, these objects are probably either banned by default or are "corrupt" (Missing an address).
		if("guest[row["computer_id"]]" == row["ckey"])
			LAZYADD(telemetry_notices, "<span class='highlight'>Entry [i] is a guest user. This entry has been skipped.</span>")
			skipped_entries++
			LAZYADD(all_cids, row["computer_id"])
			continue
		// Check for a malformed history object
		if (!row || row.len < 3 || (!row["ckey"] || !row["address"] || !row["computer_id"]))
			if(row && row["ckey"] && row["computer_id"]) //Is the address the only invalid field?
				LAZYADD(telemetry_notices, "<span class='highlight'>Telemetry Entry [i] has no address. User may be a developer.</span>")
				LAZYADD(all_ckeys, row["ckey"])
				LAZYADD(all_ips, "127.0.0.1")
				LAZYADD(all_cids, row["computer_id"])
				continue
			LAZYADD(telemetry_notices, "<span class='highlight'>Telemetry Entry [i] corrupt. Data may be damaged or tampered with.</span>")
			skipped_entries++
			continue
		//Check for bans.
		if (world.IsBanned(row["ckey"], row["address"], row["computer_id"], "tgui_telemetry", real_bans_only = TRUE))
			if(!first_found_ban)
				first_found_ban = row
			LAZYADD(telemetry_notices, "<span class='bad'>BANNED ACCOUNT IN HISTORY! Matched: [row["ckey"]], [row["address"]], [row["computer_id"]]</span>")
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
			LAZYADD(telemetry_notices, "<span class='average'>User has more than one CKEY in history.</span>")
		if(3 to INFINITY)
			if(length(all_ckeys) == len)
				LAZYADD(telemetry_notices, "<span class='bad'><b>EVERY ENTRY IN HISTORY HAS A DIFFERENT CKEY!</b></span>")
			else
				LAZYADD(telemetry_notices, "<span class='bad'>User has multiple CKEYs in history!</span>")
	switch(length(all_ips))
		if(2 to INFINITY)
			if(length(all_ips) == len)
				LAZYADD(telemetry_notices, "<span class='bad'><b>EVERY ENTRY IN HISTORY HAS A DIFFERENT IP!</b></span>")
			else
				LAZYADD(telemetry_notices, "<span class='average'>User has changed IPs at least once in history.</span>")
	switch(length(all_cids))
		if(2)
			LAZYADD(telemetry_notices, "<span class='average'>User has changed CIDs once.")
		if(3 to INFINITY)
			if(length(all_cids) == len)
				LAZYADD(telemetry_notices, "<span class='bad'><b>EVERY ENTRY IN HISTORY HAS A DIFFERENT CID!</b></span>")
			else
				LAZYADD(telemetry_notices, "<span class='bad'>User has more than two CIDs in history.</span>")

/// Render the stats to some
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
			. += "<br><ul>"
			for(var/notice in telemetry_notices)
				. += "<li>[notice]</li>"
			. += "</ul>"
		if(TGUI_TELEMETRY_STAT_MISSING)
			. += "<span class='bad'>Telemetry Data Missing!</span>"
		else
			. += "<span class='bad'>Telemetry datum in invalid state ID [isnum(telemetry_status) ? telemetry_status : "!!NAN!!, CALL A CODER"]. Call a coder.</span>"
