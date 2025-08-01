/datum/controller/configuration
	name = "Configuration"

	var/directory = CONFIG_DIRECTORY

	var/warned_deprecated_configs = FALSE
	var/hiding_entries_by_type = TRUE	//Set for readability, admins can set this to FALSE if they want to debug it
	var/list/entries
	var/list/entries_by_type

	var/list/maplist
	var/datum/map_config/defaultmap

	var/motd

	/// If the configuration is loaded
	var/loaded = FALSE

	var/static/regex/ic_filter_regex
	var/static/regex/ooc_filter_regex

	var/list/fail2topic_whitelisted_ips
	var/list/protected_cids

/datum/controller/configuration/proc/admin_reload()
	if(IsAdminAdvancedProcCall())
		return
	log_admin("[key_name_admin(usr)] has forcefully reloaded the configuration from disk.")
	message_admins("[key_name_admin(usr)] has forcefully reloaded the configuration from disk.")
	full_wipe()
	Load(world.params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

/datum/controller/configuration/proc/Load(_directory)
	if(IsAdminAdvancedProcCall())		//If admin proccall is detected down the line it will horribly break everything.
		return
	if(_directory)
		directory = _directory

	if(!fexists("[directory]/config.txt") && fexists("[directory]/example/config.txt"))
		directory = "[directory]/example"

	if(entries)
		CRASH("/datum/controller/configuration/Load() called more than once!")
	InitEntries()
	if(fexists("[directory]/config.txt") && LoadEntries("config.txt") <= 1)
		var/list/legacy_configs = list("game_options.txt", "dbconfig.txt", "comms.txt")
		for(var/I in legacy_configs)
			if(fexists("[directory]/[I]"))
				log_config("No $include directives found in config.txt! Loading legacy [legacy_configs.Join("/")] files...")
				for(var/J in legacy_configs)
					LoadEntries(J)
				break
	loadmaplist(CONFIG_MAPS_FILE)
	LoadTopicRateWhitelist()
	LoadProtectedIDs()
	LoadChatFilter()

	loaded = TRUE

	if (Master)
		Master.OnConfigLoad()

/datum/controller/configuration/proc/full_wipe()
	if(IsAdminAdvancedProcCall())
		return
	entries_by_type.Cut()
	QDEL_LIST_ASSOC_VAL(entries)
	entries = null
	QDEL_LIST_ASSOC_VAL(maplist)
	maplist = null
	QDEL_NULL(defaultmap)

/datum/controller/configuration/Destroy()
	full_wipe()
	config = null

	return ..()

/datum/controller/configuration/proc/InitEntries()
	var/list/_entries = list()
	entries = _entries
	var/list/_entries_by_type = list()
	entries_by_type = _entries_by_type

	for(var/I in typesof(/datum/config_entry))	//typesof is faster in this case
		var/datum/config_entry/E = I
		if(initial(E.abstract_type) == I)
			continue
		E = new I
		var/esname = E.name
		var/datum/config_entry/test = _entries[esname]
		if(test)
			log_config("Error: [test.type] has the same name as [E.type]: [esname]! Not initializing [E.type]!")
			qdel(E)
			continue
		_entries[esname] = E
		_entries_by_type[I] = E

/datum/controller/configuration/proc/RemoveEntry(datum/config_entry/CE)
	entries -= CE.name
	entries_by_type -= CE.type

/datum/controller/configuration/proc/LoadEntries(filename, list/stack = list())
	if(IsAdminAdvancedProcCall())
		return

	var/filename_to_test = world.system_type == MS_WINDOWS ? LOWER_TEXT(filename) : filename
	if(filename_to_test in stack)
		log_config("Warning: Config recursion detected ([english_list(stack)]), breaking!")
		return
	stack = stack + filename_to_test

	log_config("Loading config file [filename]...")
	var/list/lines = world.file2list("[directory]/[filename]")
	var/list/_entries = entries
	for(var/L in lines)
		L = trim(L)
		if(!L)
			continue

		var/firstchar = L[1]
		if(firstchar == "#")
			continue

		var/lockthis = firstchar == "@"
		if(lockthis)
			L = copytext(L, length(firstchar) + 1)

		var/pos = findtext(L, " ")
		var/entry = null
		var/value = null

		if(pos)
			entry = LOWER_TEXT(copytext(L, 1, pos))
			value = copytext(L, pos + length(L[pos]))
		else
			entry = LOWER_TEXT(L)

		if(!entry)
			continue

		if(entry == "$include")
			if(!value)
				log_config("Warning: Invalid $include directive: [value]")
			else
				LoadEntries(value, stack)
				++.
			continue

		var/datum/config_entry/E = _entries[entry]
		if(!E)
			log_config("Unknown setting in configuration: '[entry]'")
			continue

		if(lockthis)
			E.protection |= CONFIG_ENTRY_LOCKED

		if(E.deprecated_by)
			var/datum/config_entry/new_ver = entries_by_type[E.deprecated_by]
			var/new_value = E.DeprecationUpdate(value)
			var/good_update = istext(new_value)
			log_config("Entry [entry] is deprecated and will be removed soon. Migrate to [new_ver.name]![good_update ? " Suggested new value is: [new_value]" : ""]")
			if(!warned_deprecated_configs)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(message_admins), "This server is using deprecated configuration settings. Please check the logs and update accordingly."), 0)
				warned_deprecated_configs = TRUE
			if(good_update)
				value = new_value
				E = new_ver
			else
				warning("[new_ver.type] is deprecated but gave no proper return for DeprecationUpdate()")

		var/validated = E.ValidateAndSet(value)
		if(!validated)
			log_config("Failed to validate setting \"[value]\" for [entry]")
		else
			if(E.modified && !E.dupes_allowed)
				log_config("Duplicate setting for [entry] ([value], [E.resident_file]) detected! Using latest.")

		E.resident_file = filename

		if(validated)
			E.modified = TRUE

	++.

/datum/controller/configuration/can_vv_get(var_name)
	return (var_name != NAMEOF(src, entries_by_type) || !hiding_entries_by_type) && ..()

/datum/controller/configuration/vv_edit_var(var_name, var_value)
	var/list/banned_edits = list(NAMEOF(src, entries_by_type), NAMEOF(src, entries), NAMEOF(src, directory))
	return !(var_name in banned_edits) && ..()

/datum/controller/configuration/stat_entry()
	var/list/tab_data = list()
	tab_data["[name]"] = list(
		text="Edit",
		action = "statClickDebug",
		params=list(
			"targetRef" = REF(src),
			"class"="config",
		),
		type=STAT_BUTTON,
	)
	return tab_data

/datum/controller/configuration/proc/Get(entry_type)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	if(!entries_by_type)
		CRASH("Tried to retrieve config value before it was loaded or it was nulled.")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_HIDDEN) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Get" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
		log_admin_private("Config access of [entry_type] attempted by [key_name(usr)]")
		return
	return E.config_entry_value

/datum/controller/configuration/proc/Set(entry_type, new_val)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to set an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_LOCKED) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Set" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
		log_admin_private("Config rewrite of [entry_type] to [new_val] attempted by [key_name(usr)]")
		return
	return E.ValidateAndSet("[new_val]")

/datum/controller/configuration/proc/LoadMOTD()
	motd = rustg_file_read("[directory]/motd.txt")
	var/tm_info = GLOB.revdata.GetTestMergeInfo()
	if(motd || tm_info)
		motd = motd ? "[motd]<br>[tm_info]" : tm_info

/datum/controller/configuration/proc/loadmaplist(filename)
	log_config("Loading config file [filename]...")
	filename = "[directory]/[filename]"
	var/list/Lines = world.file2list(filename)

	var/datum/map_config/currentmap = null
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(t[1] == "#")
			continue

		var/pos = findtext(t, " ")
		var/command = null
		var/data = null

		if(pos)
			command = LOWER_TEXT(copytext(t, 1, pos))
			data = copytext(t, pos + length(t[pos]))
		else
			command = LOWER_TEXT(t)

		if(!command)
			continue

		if (!currentmap && command != "map")
			continue

		switch (command)
			if ("map")
				currentmap = load_map_config("[data]", MAP_DIRECTORY)
				if(currentmap.defaulted)
					log_config("Failed to load map config for [data]!")
					currentmap = null
			if ("minplayers","minplayer")
				currentmap.config_min_users = text2num(data)
			if ("maxplayers","maxplayer")
				currentmap.config_max_users = text2num(data)
			if ("weight","voteweight")
				currentmap.voteweight = text2num(data)
			if ("default","defaultmap")
				defaultmap = currentmap
			if ("votable")
				currentmap.votable = TRUE
			if ("endmap")
				LAZYINITLIST(maplist)
				maplist[currentmap.map_name] = currentmap
				currentmap = null
			if ("disabled")
				currentmap = null
			else
				log_config("Unknown command in map vote config: '[command]'")

/datum/controller/configuration/proc/LoadTopicRateWhitelist()
	LAZYINITLIST(fail2topic_whitelisted_ips)
	if(!fexists("[directory]/topic_rate_limit_whitelist.txt"))
		log_config("Error 404: topic_rate_limit_whitelist.txt not found!")
		return

	log_config("Loading config file topic_rate_limit_whitelist.txt...")

	for(var/line in world.file2list("[directory]/topic_rate_limit_whitelist.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		fail2topic_whitelisted_ips[line] = 1

/datum/controller/configuration/proc/LoadProtectedIDs()
	var/jsonfile = rustg_file_read("[directory]/protected_cids.json")
	if(!jsonfile)
		log_config("Error 404: protected_cids.json not found!")
		return

	log_config("Loading config file protected_cids.json...")

	protected_cids = json_decode(jsonfile)

/datum/controller/configuration/proc/LoadChatFilter()
	var/list/in_character_filter = list()
	var/list/ooc_filter = list()

	if(!fexists("[directory]/ooc_filter.txt"))
		log_config("Error 404: ooc_filter.txt not found!")
		return

	if(!fexists("[directory]/in_character_filter.txt"))
		log_config("Error 404: in_character_filter.txt not found!")
		return

	log_config("Loading config file ooc_filter.txt...")

	for(var/line in world.file2list("[directory]/ooc_filter.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		in_character_filter += REGEX_QUOTE(line) //Anything banned in OOC is also probably banned in IC
		ooc_filter += REGEX_QUOTE(line)

	ooc_filter_regex = ooc_filter.len ? regex("\\b([jointext(ooc_filter, "|")])\\b", "i") : null


	log_config("Loading config file in_character_filter.txt...")

	for(var/line in world.file2list("[directory]/in_character_filter.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		in_character_filter += REGEX_QUOTE(line)

	ic_filter_regex = in_character_filter.len ? regex("\\b([jointext(in_character_filter, "|")])\\b", "i") : null

