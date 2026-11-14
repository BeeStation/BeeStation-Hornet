/// Disable to use builtin DM-based generation.
/// IconForge is 250x times faster but requires storing the icons in tmp/ and may result in higher asset transport.
/// Note that the builtin GAGS editor still uses the 'legacy' generation to allow for debugging.
#define USE_RUSTG_ICONFORGE_GAGS

PROCESSING_SUBSYSTEM_DEF(greyscale)
	name = "Greyscale"
	ss_flags = SS_BACKGROUND
	init_stage = INITSTAGE_EARLY
	wait = 3 SECONDS

	var/list/datum/greyscale_config/configurations = list()
	var/list/datum/greyscale_layer/layer_types = list()
	/// Shared colour recipes using build-generated geometry, never viewer copies.
	var/list/datum/greyscale_config/directional_configs = list()
	var/list/directional_icons = list()
#ifdef USE_RUSTG_ICONFORGE_GAGS
	/// Cache containing a list of [UID (config path + colors)] -> [DMI file / RSC object] in the tmp directory from iconforge
	var/list/gags_cache = list()
#endif

/datum/controller/subsystem/processing/greyscale/Initialize()
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

#ifdef USE_RUSTG_ICONFORGE_GAGS
	var/list/job_ids = list()
#endif

	// This final verification step is for things that need other greyscale configurations to be finished loading
	for(var/greyscale_type as anything in configurations)
		CHECK_TICK
		var/datum/greyscale_config/config = configurations[greyscale_type]
		config.CrossVerify()
#ifdef USE_RUSTG_ICONFORGE_GAGS
		job_ids += rustg_iconforge_load_gags_config_async(greyscale_type, config.raw_json_string, config.string_icon_file)

	UNTIL(jobs_completed(job_ids))
#endif
	return SS_INIT_SUCCESS

#ifdef USE_RUSTG_ICONFORGE_GAGS
/datum/controller/subsystem/processing/greyscale/proc/jobs_completed(list/job_ids)
	for(var/job in job_ids)
		var/result = rustg_iconforge_check(job)
		if(result == RUSTG_JOB_NO_RESULTS_YET)
			return FALSE
		if(result != "OK")
			stack_trace("Error during rustg_iconforge_load_gags_config job: [result]")
		job_ids -= job
	return TRUE
#endif

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
#ifdef USE_RUSTG_ICONFORGE_GAGS
	var/uid = "[replacetext(replacetext(type, "/datum/greyscale_config/", ""), "/", "-")]-[colors]"
	var/cached_file = gags_cache[uid]
	if(cached_file)
		return cached_file
	var/output_path = "tmp/gags/icons/gags-[uid].dmi"
	var/iconforge_output = rustg_iconforge_gags(type, colors, output_path)
	// Handle errors from IconForge
	if(iconforge_output != "OK")
		CRASH(iconforge_output)
	// We'll just explicitly do fcopy_rsc here, so the game doesn't have to do it again later from the cached file.
	var/rsc_gags_icon = fcopy_rsc(file(output_path))
	gags_cache[uid] = rsc_gags_icon
	GLOB.brandish_assets.register_greyscale(rsc_gags_icon, text2path(type), colors)
	return rsc_gags_icon
#else
	var/resource = configurations[type].Generate(colors)
	GLOB.brandish_assets.register_greyscale(resource, text2path(type), colors)
	return resource
#endif

/// Recolour an existing native geometry bank. Ordinary clothing/machines keep
/// their normal GAGS output; only a caller with an explicit geometry policy
/// reaches this path. The cache is shared across all atoms and clients.
/datum/controller/subsystem/processing/greyscale/proc/GetColoredGeometryIcon(config_type, colors, kind, direction, prefix)
	var/datum/greyscale_config/original = configurations["[config_type]"]
	var/replacement = GLOB.brandish_assets.icon_for(original.icon_file, kind, direction, prefix)
	if(!replacement || replacement == original.icon_file)
		return GetColoredIconByType(config_type, colors)
	var/key = geometry_config(config_type, kind, direction, prefix)
	var/uid = md5("[key]|[colors]")
	if(directional_icons[uid])
		return directional_icons[uid]
	var/resource
#ifdef USE_RUSTG_ICONFORGE_GAGS
	var/output_path = "tmp/gags/icons/geometry-[uid].dmi"
	var/result = rustg_iconforge_gags(key, colors, output_path)
	if(result != "OK")
		CRASH(result)
	resource = fcopy_rsc(file(output_path))
#else
	resource = directional_configs[key].Generate(colors)
#endif
	directional_icons[uid] = resource
	GLOB.brandish_assets.register_greyscale(resource, config_type, colors)
	return resource

/// Clone references as well as the top-level recipe, so nested layers use the
/// same coordinate policy. Original editor recipes and their caches stay intact.
/datum/controller/subsystem/processing/greyscale/proc/geometry_config(config_type, kind, direction, prefix)
	var/datum/greyscale_config/original = configurations["[config_type]"]
	var/key = "geometry-[md5("[config_type]|[kind]|[direction]|[prefix]|[original.raw_json_string]|[original.icon_file_hash]")]"
	if(directional_configs[key])
		return key
	var/datum/greyscale_config/converted = new config_type
	converted.icon_file = GLOB.brandish_assets.icon_for(original.icon_file, kind, direction, prefix) || original.icon_file
	converted.string_icon_file = "[converted.icon_file]"
	converted.Refresh()
	directional_configs[key] = converted
	for(var/datum/greyscale_layer/reference/reference in converted.flat_all_layers)
		var/reference_key = geometry_config(reference.reference_type.type, kind, direction, prefix)
		converted.raw_json_string = replacetext(converted.raw_json_string, json_encode("[reference.reference_type.type]"), json_encode(reference_key))
		reference.reference_type = directional_configs[reference_key]
#ifdef USE_RUSTG_ICONFORGE_GAGS
	var/result = rustg_iconforge_load_gags_config(key, converted.raw_json_string, converted.string_icon_file)
	if(result != "OK")
		CRASH(result)
#endif
	return key

/datum/controller/subsystem/processing/greyscale/proc/GetColoredIconByTypeUniversalIcon(type, list/colors, target_icon_state)
	if(!ispath(type, /datum/greyscale_config))
		CRASH("An invalid greyscale configuration was given to `GetColoredIconByTypeUniversalIcon()`: [type]")
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	else if(!istext(colors))
		CRASH("Invalid colors were given to `GetColoredIconByTypeUniversalIcon()`: [colors]")
	return configurations[type].GenerateUniversalIcon(colors, target_icon_state)

/datum/controller/subsystem/processing/greyscale/proc/ParseColorString(color_string)
	. = list()
	var/list/split_colors = splittext(color_string, "#")
	for(var/color in 2 to length(split_colors))
		. += "#[split_colors[color]]"

#undef USE_RUSTG_ICONFORGE_GAGS
