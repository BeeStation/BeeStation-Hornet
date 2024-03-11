PROCESSING_SUBSYSTEM_DEF(greyscale)
	name = "Greyscale"
	flags = SS_BACKGROUND
	init_order = INIT_ORDER_GREYSCALE
	wait = 3 SECONDS

	var/list/datum/greyscale_config/configurations = list()
	var/list/datum/greyscale_layer/layer_types = list()
	var/list/gags_cache = list()

/datum/controller/subsystem/processing/greyscale/Initialize(start_timeofday)
	for(var/datum/greyscale_layer/fake_type as anything in subtypesof(/datum/greyscale_layer))
		layer_types[initial(fake_type.layer_type)] = fake_type

	for(var/greyscale_type in subtypesof(/datum/greyscale_config))
		var/datum/greyscale_config/config = new greyscale_type()
		configurations["[greyscale_type]"] = config

	// We do this after all the types have been loaded into the listing so reference layers don't care about init order
	for(var/greyscale_type in configurations)
		CHECK_TICK
		var/datum/greyscale_config/config = configurations[greyscale_type]
		config.Refresh()

	var/list/job_ids = list()
	// This final verification step is for things that need other greyscale configurations to be finished loading
	for(var/greyscale_type as anything in configurations)
		CHECK_TICK
		var/datum/greyscale_config/config = configurations[greyscale_type]
		config.CrossVerify()
		job_ids += rustg_iconforge_load_gags_config_async(greyscale_type, config.raw_json_string, config.string_icon_file)

	UNTIL(jobs_completed(job_ids))
	return ..()

/datum/controller/subsystem/processing/greyscale/proc/jobs_completed(list/job_ids)
	for(var/job in job_ids)
		var/result = rustg_iconforge_check(job)
		if(result == RUSTG_JOB_NO_RESULTS_YET)
			return FALSE
		if(result != "OK")
			stack_trace("Error during rustg_iconforge_load_gags_config job: [result]")
		job_ids -= job
	return TRUE

/datum/controller/subsystem/processing/greyscale/proc/RefreshConfigsFromFile()
	for(var/i in configurations)
		configurations[i].Refresh(TRUE)

/datum/controller/subsystem/processing/greyscale/proc/GetColoredIconByType(type, list/colors)
	if(!ispath(type, /datum/greyscale_config))
		CRASH("An invalid greyscale configuration was given to `GetColoredIconByType()`: [type]")
	if(!initialized)
		CRASH("GetColoredIconByType() called before greyscale subsystem initialized!")
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	else if(!istext(colors))
		CRASH("Invalid colors were given to `GetColoredIconByType()`: [colors]")
	var/uid = "[replacetext(replacetext(type, "/datum/greyscale_config", ""), "/", "-")]-[colors]"
	var/cached = gags_cache[uid]
	if(cached)
		return cached
	var/path = "tmp/gags/gags-[uid].dmi"
	var/err = rustg_iconforge_gags(type, colors, path)
	if(err != "OK")
		CRASH(err)
	// We'll just explicitly do fcopy_rsc here, so the game doesn't have to do it again from the cached file.
	var/result = fcopy_rsc(file(path))
	gags_cache[uid] = result
	return result //configurations[type].Generate(colors)

/datum/controller/subsystem/processing/greyscale/proc/GetColoredIconEntryByType(type, list/colors, target_icon_state)
	if(!ispath(type, /datum/greyscale_config))
		CRASH("An invalid greyscale configuration was given to `GetColoredIconEntryByType()`: [type]")
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	else if(!istext(colors))
		CRASH("Invalid colors were given to `GetColoredIconEntryByType()`: [colors]")
	return configurations[type].Generate_entry(colors, target_icon_state)

/datum/controller/subsystem/processing/greyscale/proc/ParseColorString(color_string)
	. = list()
	var/list/split_colors = splittext(color_string, "#")
	for(var/color in 2 to length(split_colors))
		. += "#[split_colors[color]]"
