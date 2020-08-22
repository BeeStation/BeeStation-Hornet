SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	wait = 6000
	flags = SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_BLACKBOX

	var/list/feedback = list()	//list of datum/feedback_variable
	var/list/first_death = list() //the first death of this round, assoc. vars keep track of different things
	var/triggertime = 0
	var/sealed = FALSE	//time to stop tracking stats?
	var/list/versions = list("antagonists" = 3,
							"admin_secrets_fun_used" = 2,
							"explosion" = 2,
							"time_dilation_current" = 3,
							"science_techweb_unlock" = 2,
							"round_end_stats" = 2,
							"testmerged_prs" = 2) //associative list of any feedback variables that have had their format changed since creation and their current version, remember to update this

/datum/controller/subsystem/blackbox/Initialize()
	triggertime = world.time
	record_feedback("amount", "random_seed", Master.random_seed)
	record_feedback("amount", "dm_version", DM_VERSION)
	record_feedback("amount", "dm_build", DM_BUILD)
	record_feedback("amount", "byond_version", world.byond_version)
	record_feedback("amount", "byond_build", world.byond_build)
	. = ..()

//poll population
/datum/controller/subsystem/blackbox/fire()
	set waitfor = FALSE	//for population query

	CheckPlayerCount()

	if(CONFIG_GET(flag/use_exp_tracking))
		if((triggertime < 0) || (world.time > (triggertime +3000)))	//subsystem fires once at roundstart then once every 10 minutes. a 5 min check skips the first fire. The <0 is midnight rollover check
			update_exp(10,FALSE)

/datum/controller/subsystem/blackbox/proc/CheckPlayerCount()
	set waitfor = FALSE

	if(!SSdbcore.Connect())
		return
	var/playercount = 0
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			playercount += 1
	var/admincount = GLOB.admins.len


	var/datum/DBQuery/query_record_playercount = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("legacy_population")] (playercount, admincount, time, server_name, server_ip, server_port, round_id)
		VALUES (:playercount, :admincount, :time, :server_name, INET_ATON(:server_ip), :server_port, :round_id)
	"}, list(
		"playercount" = playercount,
		"admincount" = admincount,
		"time" = SQLtime(),
		"server_name" = CONFIG_GET(string/serversqlname),
		"server_ip" = world.internet_address || "0",
		"server_port" = "[world.port]",
		"round_id" = GLOB.round_id,
	))
	query_record_playercount.Execute()
	qdel(query_record_playercount)

/datum/controller/subsystem/blackbox/Recover()
	feedback = SSblackbox.feedback
	sealed = SSblackbox.sealed

//no touchie
/datum/controller/subsystem/blackbox/vv_get_var(var_name)
	if(var_name == "feedback")
		return debug_variable(var_name, deepCopyList(feedback), 0, src)
	return ..()

/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("feedback")
			return FALSE
		if("sealed")
			if(var_value)
				return Seal()
			return FALSE
	return ..()

//Recorded on subsystem shutdown
/datum/controller/subsystem/blackbox/proc/FinalFeedback()
	record_feedback("tally", "ahelp_stats", GLOB.ahelp_tickets.active_tickets.len, "unresolved")
	for (var/obj/machinery/telecomms/message_server/MS in GLOB.telecomms_list)
		if (MS.pda_msgs.len)
			record_feedback("tally", "radio_usage", MS.pda_msgs.len, "PDA")
		if (MS.rc_msgs.len)
			record_feedback("tally", "radio_usage", MS.rc_msgs.len, "request console")

	for(var/player_key in GLOB.player_details)
		var/datum/player_details/PD = GLOB.player_details[player_key]
		record_feedback("tally", "client_byond_version", 1, PD.byond_version)

/datum/controller/subsystem/blackbox/Shutdown()
	sealed = FALSE
	FinalFeedback()

	if (!SSdbcore.Connect())
		return

	var/list/special_columns = list(
		"datetime" = "NOW()"
	)
	var/list/sqlrowlist = list()
	for (var/datum/feedback_variable/FV in feedback)
		sqlrowlist += list(list(
			"round_id" = GLOB.round_id,
			"key_name" = FV.key,
			"key_type" = FV.key_type,
			"version" = versions[FV.key] || 1,
			"json" = json_encode(FV.json)
		))

	if (!length(sqlrowlist))
		return

	SSdbcore.MassInsert(format_table_name("feedback"), sqlrowlist, ignore_errors = TRUE, delayed = TRUE, special_columns = special_columns)

/datum/controller/subsystem/blackbox/proc/Seal()
	if(sealed)
		return FALSE
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name_admin(usr)] sealed the blackbox!")
	log_game("Blackbox sealed[IsAdminAdvancedProcCall() ? " by [key_name(usr)]" : ""].")
	sealed = TRUE
	return TRUE

/datum/controller/subsystem/blackbox/proc/LogBroadcast(freq)
	if(sealed)
		return
	switch(freq)
		if(FREQ_COMMON)
			record_feedback("tally", "radio_usage", 1, "common")
		if(FREQ_SCIENCE)
			record_feedback("tally", "radio_usage", 1, "science")
		if(FREQ_COMMAND)
			record_feedback("tally", "radio_usage", 1, "command")
		if(FREQ_MEDICAL)
			record_feedback("tally", "radio_usage", 1, "medical")
		if(FREQ_ENGINEERING)
			record_feedback("tally", "radio_usage", 1, "engineering")
		if(FREQ_SECURITY)
			record_feedback("tally", "radio_usage", 1, "security")
		if(FREQ_SYNDICATE)
			record_feedback("tally", "radio_usage", 1, "syndicate")
		if(FREQ_SERVICE)
			record_feedback("tally", "radio_usage", 1, "service")
		if(FREQ_SUPPLY)
			record_feedback("tally", "radio_usage", 1, "supply")
		if(FREQ_CENTCOM)
			record_feedback("tally", "radio_usage", 1, "centcom")
		if(FREQ_AI_PRIVATE)
			record_feedback("tally", "radio_usage", 1, "ai private")
		if(FREQ_CTF_RED)
			record_feedback("tally", "radio_usage", 1, "CTF red team")
		if(FREQ_CTF_BLUE)
			record_feedback("tally", "radio_usage", 1, "CTF blue team")
		else
			record_feedback("tally", "radio_usage", 1, "other")

/datum/controller/subsystem/blackbox/proc/find_feedback_datum(key, key_type)
	for(var/datum/feedback_variable/FV in feedback)
		if(FV.key == key)
			return FV

	var/datum/feedback_variable/FV = new(key, key_type)
	feedback += FV
	return FV
/*
feedback data can be recorded in 5 formats:
"text"
	used for simple single-string records i.e. the current map
	further calls to the same key will append saved data unless the overwrite argument is true or it already exists
	when encoded calls made with overwrite will lack square brackets
	calls: 	SSblackbox.record_feedback("text", "example", 1, "sample text")
			SSblackbox.record_feedback("text", "example", 1, "other text")
	json: {"data":["sample text","other text"]}
"amount"
	used to record simple counts of data i.e. the number of ahelps received
	further calls to the same key will add or subtract (if increment argument is a negative) from the saved amount
	calls:	SSblackbox.record_feedback("amount", "example", 8)
			SSblackbox.record_feedback("amount", "example", 2)
	json: {"data":10}
"tally"
	used to track the number of occurances of multiple related values i.e. how many times each type of gun is fired
	further calls to the same key will:
	 	add or subtract from the saved value of the data key if it already exists
		append the key and it's value if it doesn't exist
	calls:	SSblackbox.record_feedback("tally", "example", 1, "sample data")
			SSblackbox.record_feedback("tally", "example", 4, "sample data")
			SSblackbox.record_feedback("tally", "example", 2, "other data")
	json: {"data":{"sample data":5,"other data":2}}
"nested tally"
	used to track the number of occurances of structured semi-relational values i.e. the results of arcade machines
	similar to running total, but related values are nested in a multi-dimensional array built
	the final element in the data list is used as the tracking key, all prior elements are used for nesting
	all data list elements must be strings
	further calls to the same key will:
	 	add or subtract from the saved value of the data key if it already exists in the same multi-dimensional position
		append the key and it's value if it doesn't exist
	calls: 	SSblackbox.record_feedback("nested tally", "example", 1, list("fruit", "orange", "apricot"))
			SSblackbox.record_feedback("nested tally", "example", 2, list("fruit", "orange", "orange"))
			SSblackbox.record_feedback("nested tally", "example", 3, list("fruit", "orange", "apricot"))
			SSblackbox.record_feedback("nested tally", "example", 10, list("fruit", "red", "apple"))
			SSblackbox.record_feedback("nested tally", "example", 1, list("vegetable", "orange", "carrot"))
	json: {"data":{"fruit":{"orange":{"apricot":4,"orange":2},"red":{"apple":10}},"vegetable":{"orange":{"carrot":1}}}}
	tracking values associated with a number can't merge with a nesting value, trying to do so will append the list
	call:	SSblackbox.record_feedback("nested tally", "example", 3, list("fruit", "orange"))
	json: {"data":{"fruit":{"orange":{"apricot":4,"orange":2},"red":{"apple":10},"orange":3},"vegetable":{"orange":{"carrot":1}}}}
"associative"
	used to record text that's associated with a value i.e. coordinates
	further calls to the same key will append a new list to existing data
	calls:	SSblackbox.record_feedback("associative", "example", 1, list("text" = "example", "path" = /obj/item, "number" = 4))
			SSblackbox.record_feedback("associative", "example", 1, list("number" = 7, "text" = "example", "other text" = "sample"))
	json: {"data":{"1":{"text":"example","path":"/obj/item","number":"4"},"2":{"number":"7","text":"example","other text":"sample"}}}

Versioning
	If the format of a feedback variable is ever changed, i.e. how many levels of nesting are used or a new type of data is added to it, add it to the versions list
	When feedback is being saved if a key is in the versions list the value specified there will be used, otherwise all keys are assumed to be version = 1
	versions is an associative list, remember to use the same string in it as defined on a feedback variable, example:
	list/versions = list("round_end_stats" = 4,
						"admin_toggle" = 2,
						"gun_fired" = 2)
*/
/datum/controller/subsystem/blackbox/proc/record_feedback(key_type, key, increment, data, overwrite)
	if(sealed || !key_type || !istext(key) || !isnum_safe(increment || !data))
		return
	var/datum/feedback_variable/FV = find_feedback_datum(key, key_type)
	switch(key_type)
		if("text")
			if(!istext(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			if(overwrite)
				FV.json["data"] = data
			else
				FV.json["data"] |= data
		if("amount")
			FV.json["data"] += increment
		if("tally")
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"]["[data]"] += increment
		if("nested tally")
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"] = record_feedback_recurse_list(FV.json["data"], data, increment)
		if("associative")
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			var/pos = length(FV.json["data"]) + 1
			FV.json["data"]["[pos]"] = list() //in 512 "pos" can be replaced with "[FV.json["data"].len+1]"
			for(var/i in data)
				if(islist(data[i]))
					FV.json["data"]["[pos]"]["[i]"] = data[i] //and here with "[FV.json["data"].len]"
				else
					FV.json["data"]["[pos]"]["[i]"] = "[data[i]]"
		else
			CRASH("Invalid feedback key_type: [key_type]")

/datum/controller/subsystem/blackbox/proc/record_feedback_recurse_list(list/L, list/key_list, increment, depth = 1)
	if(depth == key_list.len)
		if(L.Find(key_list[depth]))
			L["[key_list[depth]]"] += increment
		else
			var/list/LFI = list(key_list[depth] = increment)
			L += LFI
	else
		if(!L.Find(key_list[depth]))
			var/list/LGD = list(key_list[depth] = list())
			L += LGD
		L["[key_list[depth-1]]"] = .(L["[key_list[depth]]"], key_list, increment, ++depth)
	return L

/datum/feedback_variable
	var/key
	var/key_type
	var/list/json = list()

/datum/feedback_variable/New(new_key, new_key_type)
	key = new_key
	key_type = new_key_type

/* Ticket logging
/datum/controller/subsystem/blackbox/proc/LogAhelp(ticket, action, message, recipient, sender)
	if(!SSdbcore.Connect())
		return

	var/datum/DBQuery/query_log_ahelp = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("ticket")] (ticket, action, message, recipient, sender, server_ip, server_port, round_id, timestamp)
		VALUES (:ticket, :action, :message, :recipient, :sender, INET_ATON(:server_ip), :server_port, :round_id, :time)
	"}, list("ticket" = ticket, "action" = action, "message" = message, "recipient" = recipient, "sender" = sender, "server_ip" = world.internet_address || "0", "server_port" = world.port, "round_id" = GLOB.round_id, "time" = SQLtime()))
	query_log_ahelp.Execute()
	qdel(query_log_ahelp)
*/

/datum/controller/subsystem/blackbox/proc/ReportDeath(mob/living/L)
	set waitfor = FALSE
	if(sealed)
		return
	if(!L || !L.key || !L.mind)
		return
	if(!L.suiciding && !first_death.len)
		first_death["name"] = "[(L.real_name == L.name) ? L.real_name : "[L.real_name] as [L.name]"]"
		first_death["role"] = null
		if(L.mind.assigned_role)
			first_death["role"] = L.mind.assigned_role
		first_death["area"] = "[AREACOORD(L)]"
		first_death["damage"] = "<font color='#FF5555'>[L.getBruteLoss()]</font>/<font color='orange'>[L.getFireLoss()]</font>/<font color='lightgreen'>[L.getToxLoss()]</font>/<font color='lightblue'>[L.getOxyLoss()]</font>/<font color='pink'>[L.getCloneLoss()]</font>"
		first_death["last_words"] = L.last_words

	if(!SSdbcore.Connect())
		return

	var/datum/DBQuery/query_report_death = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("death")] (pod, x_coord, y_coord, z_coord, mapname, server_name, server_ip, server_port, round_id, tod, job, special, name, byondkey, laname, lakey, bruteloss, fireloss, brainloss, oxyloss, toxloss, cloneloss, staminaloss, last_words, suicide)
		VALUES (:pod, :x_coord, :y_coord, :z_coord, :map, :server_name, INET_ATON(:internet_address), :port, :round_id, :time, :job, :special, :name, :key, :laname, :lakey, :brute, :fire, :brain, :oxy, :tox, :clone, :stamina, :last_words, :suicide)
	"}, list(
		"name" = L.real_name,
		"key" = L.ckey,
		"job" = L.mind.assigned_role,
		"special" = L.mind.special_role,
		"pod" = get_area_name(L, TRUE),
		"laname" = L.lastattacker,
		"lakey" = L.lastattackerckey,
		"brute" = L.getBruteLoss(),
		"fire" = L.getFireLoss(),
		"brain" = L.getOrganLoss(ORGAN_SLOT_BRAIN) || BRAIN_DAMAGE_DEATH, //getOrganLoss returns null without a brain but a value is required for this column
		"oxy" = L.getOxyLoss(),
		"tox" = L.getToxLoss(),
		"clone" = L.getCloneLoss(),
		"stamina" = L.getStaminaLoss(),
		"x_coord" = L.x,
		"y_coord" = L.y,
		"z_coord" = L.z,
		"last_words" = L.last_words,
		"suicide" = L.suiciding,
		"map" = SSmapping.config.map_name,
		"internet_address" = world.internet_address || "0",
		"port" = "[world.port]",
		"server_name" = CONFIG_GET(string/serversqlname),
		"round_id" = GLOB.round_id,
		"time" = SQLtime(),
	))
	if(query_report_death)
		query_report_death.Execute(async = TRUE)
		qdel(query_report_death)
