//Blocks an attempt to connect before even creating our client datum thing.

//How many new ckey matches before we revert the stickyban to it's roundstart state
//These are exclusive, so once it goes over one of these numbers, it reverts the ban
#define STICKYBAN_MAX_MATCHES 15
#define STICKYBAN_MAX_EXISTING_USER_MATCHES 3 //ie, users who were connected before the ban triggered
#define STICKYBAN_MAX_ADMIN_MATCHES 1

GLOBAL_LIST_EMPTY(ckey_redirects)

/world/IsBanned(key, address, computer_id, type, real_bans_only=FALSE, from_auth=FALSE)
	debug_world_log("isbanned(): SRC:'[src]', USR:'[usr]' ARGS:'[args.Join("', '")]'")
	if (!key || (!real_bans_only && ((!address && !from_auth) || !computer_id))) // allow null IP from auth system (for localhost)
		if(real_bans_only)
			return FALSE
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]'. (If you continue to get this error, please restart byond or contact byond support.)")

	if (type == "world")
		return ..() //shunt world topic banchecks to purely to byond's internal ban system

	var/admin = FALSE
	var/ckey = ckey(key)
	var/client/C = GLOB.directory[ckey]
#ifdef DISABLE_BYOND_AUTH
	if(!CONFIG_GET(flag/enable_guest_external_auth))
		return list("reason"="misconfigured", "desc"="The server is not currently authenticating BYOND connections and does not have any authentication methods enabled. \
		This is insecure, nobody may connect.")
	if (C && ckey == C.ckey && CONFIG_GET(flag/enable_guest_external_auth) && !real_bans_only && !from_auth)
		// Note that it's probably possible to scrape connected CKEYs with this check, but whatever it's public anyway
		// We have no way of verifying their connection CKEY is who they say they are, and no way to change their CKEY before login
		return list("reason"="already connected", "desc"="A player is currently connected with your connection CKEY. Connect with a different CKEY or as a guest.")
#endif
	if (C && ckey == C.ckey && computer_id == C.computer_id && address == C.address && !from_auth)
		return //don't recheck connected clients unless it's from the auth system

	//IsBanned can get re-called on a user in certain situations, this prevents that leading to repeated messages to admins.
	var/static/list/checkedckeys = list()
	//magic voodo to check for a key in a list while also adding that key to the list without having to do two associated lookups
	var/message = !checkedckeys[ckey]++

	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		admin = TRUE

	var/is_connecting = !C || from_auth

	//Whitelist
	if(!real_bans_only && is_connecting && CONFIG_GET(flag/usewhitelist))
		if(!check_whitelist(ckey))
			if (admin)
				log_admin("The admin [key] has been allowed to bypass the whitelist")
				if (message)
					message_admins(span_adminnotice("The admin [key] has been allowed to bypass the whitelist"))
					addclientmessage(ckey,span_adminnotice("You have been allowed to bypass the whitelist"))
			else
				log_access("Failed Login: [key] - Not on whitelist")
				return list("reason"="whitelist", "desc" = "\nReason: You are not on the white list for this server")

	//Guest Checking
	if(!real_bans_only && is_connecting && IS_GUEST_KEY(key))
		if (CONFIG_GET(flag/guest_ban) && !CONFIG_GET(flag/enable_guest_external_auth))
			log_access("Failed Login: [key] - Guests not allowed")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")
#ifndef DISABLE_BYOND_AUTH
		if (CONFIG_GET(flag/panic_bunker) && SSdbcore.Connect() && !(CONFIG_GET(flag/enable_guest_external_auth) && CONFIG_GET(flag/panic_bunker_interview)))
			log_access("Failed Login: [key] - Guests not allowed during panic bunker")
			return list("reason"="guest", "desc"="\nReason: Sorry but the server is currently not accepting connections from never before seen players or guests. If you have played on this server with a byond account before, please log in to the byond account you have played from.")
#endif
	if(!real_bans_only && is_connecting && is_external_auth_key(key) && !from_auth)
		return list("reason"="token key", "desc"="\nReason: Connected directly with a token CKEY (BYOND accounts with keys following the token CKEY format are not allowed).")
	if(CONFIG_GET(flag/panic_bunker) && CONFIG_GET(flag/panic_bunker_interview) && !CONFIG_GET(flag/panic_bunker_interview_retries) && GLOB.interviews.denied_ckeys.Find(ckey))
		log_access("Failed Login: [key] - Interview denied")
		return list("reason"="interview", "desc"="\nReason: You failed an interview while the panic bunker is enabled. Try again during the next round or after the panic bunker is disabled.")

	//Population Cap Checking
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(!real_bans_only && is_connecting && extreme_popcap && !admin)
		var/popcap_value = GLOB.clients_unsafe.len
		if(popcap_value >= extreme_popcap && !GLOB.joined_player_list.Find(ckey))
			if((!CONFIG_GET(flag/byond_member_bypass_popcap) || !world.IsSubscribed(ckey, "BYOND")) && !IS_PATRON(ckey))
				var/redirect_address = CONFIG_GET(string/redirect_address)
				if(redirect_address != "")
					log_access("Failed Login: [key] - Population cap reached. Redirecting to overflow server.")
					GLOB.ckey_redirects += ckey
				else
					log_access("Failed Login: [key] - Population cap reached")
					return list("reason"="popcap", "desc"= "\nReason: [CONFIG_GET(string/extreme_popcap_message)]")

	if(CONFIG_GET(flag/sql_enabled))
		if(!SSdbcore.Connect())
			var/msg = "Ban database connection failure. Key [ckey] not checked"
			log_world(msg)
			if (message)
				message_admins(msg)
		else
			var/list/ban_details = is_banned_from_with_details(ckey, address, computer_id, "Server")
			for(var/i in ban_details)
				if(admin)
					if(text2num(i["applies_to_admins"]))
						var/msg = "Admin [key] is admin banned, and has been disallowed access."
						log_admin(msg)
						if (message)
							message_admins(msg)
					else
						var/msg = "Admin [key] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]]."
						log_admin(msg)
						if (message)
							message_admins(msg)
							addclientmessage(ckey,span_adminnotice("Admin [key] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]]."))
						continue
				var/expires = "This is a permanent ban."
				var/global_ban = "This is a global ban from all of our servers."
				if(i["expiration_time"])
					expires = " The ban is for [DisplayTimeText(text2num(i["duration"]) MINUTES)] and expires on [i["expiration_time"]] (server time)."
				if(!text2num(i["global_ban"]))
					global_ban = "This is a single-server ban, and only applies to [i["server_name"]]."
				var/desc = {"You, or another user of this computer or connection ([i["key"]]) is banned from playing here.
				The ban reason is: [i["reason"]].
				This ban (BanID #[i["id"]]) was applied by [i["admin_key"]] on [i["bantime"]] during round ID [i["round_id"]].
				[global_ban]
				[expires]"}
				log_access("Failed Login: [key] [computer_id] [address] - Banned (#[i["id"]]) [text2num(i["global_ban"]) ? "globally" : "locally"]")
				return list("reason"="Banned","desc"="[desc]")

	var/list/ban = ..()	//default pager ban stuff

	if (ban)
		if (!admin)
			. = ban
		if (real_bans_only)
			return
		var/bannedckey = "ERROR"
		if (ban["ckey"])
			bannedckey = ban["ckey"]

		var/newmatch = FALSE
		var/list/cachedban = SSstickyban.cache[bannedckey]
		//rogue ban in the process of being reverted.
		if (cachedban && (cachedban["reverting"] || cachedban["timeout"]))
			world.SetConfig("ban", bannedckey, null)
			return null

		if (cachedban && ckey != bannedckey)
			newmatch = TRUE
			if (cachedban["keys"])
				if (cachedban["keys"][ckey])
					newmatch = FALSE
			if (cachedban["matches_this_round"][ckey])
				newmatch = FALSE

		if (newmatch && cachedban)
			var/list/newmatches = cachedban["matches_this_round"]
			var/list/pendingmatches = cachedban["matches_this_round"]
			var/list/newmatches_connected = cachedban["existing_user_matches_this_round"]
			var/list/newmatches_admin = cachedban["admin_matches_this_round"]

			if (C)
				newmatches_connected[ckey] = ckey
				newmatches_connected = cachedban["existing_user_matches_this_round"]
				pendingmatches[ckey] = ckey
				sleep(STICKYBAN_ROGUE_CHECK_TIME)
				pendingmatches -= ckey
			if (admin)
				newmatches_admin[ckey] = ckey

			if (cachedban["reverting"] || cachedban["timeout"])
				return null

			newmatches[ckey] = ckey


			if (\
				newmatches.len+pendingmatches.len > STICKYBAN_MAX_MATCHES || \
				newmatches_connected.len > STICKYBAN_MAX_EXISTING_USER_MATCHES || \
				newmatches_admin.len > STICKYBAN_MAX_ADMIN_MATCHES \
			)

				var/action
				if (ban["fromdb"])
					cachedban["timeout"] = TRUE
					action = "putting it on timeout for the remainder of the round"
				else
					cachedban["reverting"] = TRUE
					action = "reverting to its roundstart state"

				world.SetConfig("ban", bannedckey, null)

				//we always report this
				log_game("Stickyban on [bannedckey] detected as rogue, [action]")
				message_admins("Stickyban on [bannedckey] detected as rogue, [action]")
				//do not convert to timer.
				spawn (5)
					world.SetConfig("ban", bannedckey, null)
					sleep(1)
					world.SetConfig("ban", bannedckey, null)
					if (!ban["fromdb"])
						cachedban = cachedban.Copy() //so old references to the list still see the ban as reverting
						cachedban["matches_this_round"] = list()
						cachedban["existing_user_matches_this_round"] = list()
						cachedban["admin_matches_this_round"] = list()
						cachedban -= "reverting"
						SSstickyban.cache[bannedckey] = cachedban
						world.SetConfig("ban", bannedckey, list2stickyban(cachedban))
				return null

		if (ban["fromdb"])
			if(SSdbcore.Connect())
				INVOKE_ASYNC(SSdbcore, TYPE_PROC_REF(/datum/controller/subsystem/dbcore, QuerySelect), list(
					SSdbcore.NewQuery(
						"INSERT INTO [format_table_name("stickyban_matched_ckey")] (matched_ckey, stickyban) VALUES (:ckey, :bannedckey) ON DUPLICATE KEY UPDATE last_matched = now()",
						list("ckey" = ckey, "bannedckey" = bannedckey)
					),
					SSdbcore.NewQuery(
						"INSERT INTO [format_table_name("stickyban_matched_ip")] (matched_ip, stickyban) VALUES (INET_ATON(:address), :bannedckey) ON DUPLICATE KEY UPDATE last_matched = now()",
						list("address" = address, "bannedckey" = bannedckey)
					),
					SSdbcore.NewQuery(
						"INSERT INTO [format_table_name("stickyban_matched_cid")] (matched_cid, stickyban) VALUES (:computer_id, :bannedckey) ON DUPLICATE KEY UPDATE last_matched = now()",
						list("computer_id" = computer_id, "bannedckey" = bannedckey)
					)
				), FALSE, TRUE)


		//byond will not trigger isbanned() for "global" host bans,
		//ie, ones where the "apply to this game only" checkbox is not checked (defaults to not checked)
		//So it's safe to let admins walk thru host/sticky bans here
		if (admin)
			log_admin("The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]")
			if (message)
				message_admins(span_adminnotice("The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]"))
				addclientmessage(ckey,span_adminnotice("You have been allowed to bypass a matching host/sticky ban on [bannedckey]"))
			return null

		if (C) //user is already connected!.
			to_chat(C, "You are about to get disconnected for matching a sticky ban after you connected. If this turns out to be the ban evasion detection system going haywire, we will automatically detect this and revert the matches. if you feel that this is the case, please wait EXACTLY 6 seconds then reconnect using file -> reconnect to see if the match was automatically reversed.")

		var/desc = "\nReason:(StickyBan) You, or another user of this computer or connection ([bannedckey]) is banned from playing here. The ban reason is:\n[ban["message"]]\nThis ban was applied by [ban["admin"]]\nThis is a BanEvasion Detection System ban, if you think this ban is a mistake, please wait EXACTLY 6 seconds, then try again before filing an appeal.\n"
		. = list("reason" = "Stickyban", "desc" = desc)
		log_access("Failed Login: [key] [computer_id] [address] - StickyBanned [ban["message"]] Target Username: [bannedckey] Placed by [ban["admin"]]")

	return .


#undef STICKYBAN_MAX_MATCHES
#undef STICKYBAN_MAX_EXISTING_USER_MATCHES
#undef STICKYBAN_MAX_ADMIN_MATCHES
