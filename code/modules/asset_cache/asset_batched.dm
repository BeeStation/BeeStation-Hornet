#define SPR_SIZE "size_id"
#define SPR_IDX "position"

/datum/asset/spritesheet_batched
	_abstract = /datum/asset/spritesheet_batched
	var/name
	/// List of arguments to pass into queuedInsert
	/// Exists so we can queue icon insertion, mostly for stuff like preferences
	var/list/to_generate = list()
	/// list("32x32")
	var/list/sizes = list()
	/// "foo_bar" -> list("32x32", 5, entry_obj)
	var/list/sprites = list()

	// "foo_bar" -> entry_obj
	var/list/entries = list()
	var/fully_generated = FALSE
	/// If this asset should be fully loaded on new
	/// Defaults to false so we can process this stuff nicely
	var/load_immediately = FALSE
	/// If we should avoid propogating 'invalid dir' errors from rust-g. Because sometimes, you just don't know what dirs are valid.
	var/ignore_dir_errors = FALSE

	/// If there is currently an async job, its ID
	var/job_id = null

/datum/asset/spritesheet_batched/proc/should_load_immediately()
#ifdef DO_NOT_DEFER_ASSETS
	return TRUE
#else
	return load_immediately
#endif

/// Override this in order to start the creation of the spritehseet.
/// This is where you select a list of typepaths to perform operations or transformations on.
/datum/asset/spritesheet_batched/proc/collect_typepaths()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("collect_typepaths() not implemented for [type]!")

/// Override this as the second step of creating a spritesheet.
/// Provides an icon-schema in the form of a specialized list, given a typepath from collect_typepaths()
/datum/asset/spritesheet_batched/proc/typepath_to_icon_entry(type)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("collect_typepaths() not implemented for [type]!")

/// Constructs a transformer, with optional color multiply pre-added.
/datum/asset/spritesheet_batched/proc/colorize(color=null)
	RETURN_TYPE(/datum/icon_transformer)
	var/datum/icon_transformer/transform = new()
	if(color)
		transform.blend_color(color, ICON_MULTIPLY)
	return transform

/// Constructs an icon entry.
/datum/asset/spritesheet_batched/proc/icon_entry(sprite_name, icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE, datum/icon_transformer/transform=null, color=null)
	return new /datum/icon_batch_entry(sprite_name, I, icon_state, dir, frame, moving, transform, color)

/// Constructs an icon entry, with a blank sprite_name.
/proc/u_icon_entry(icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE, datum/icon_transformer/transform=null, color=null)
	return new /datum/icon_batch_entry("", I, icon_state, dir, frame, moving, transform, color)

/datum/asset/spritesheet_batched/proc/insert_icon(datum/icon_batch_entry/entry)
	if(should_load_immediately())
		queued_insert_icon(entry)
	else
		to_generate += list(args.Copy())

/datum/asset/spritesheet_batched/proc/queued_insert_icon(datum/icon_batch_entry/entry)
	entries[entry.sprite_name] = entry.to_list()

/datum/asset/spritesheet_batched/should_refresh()
	return TRUE

/datum/asset/spritesheet_batched/register()
	SHOULD_NOT_OVERRIDE(TRUE)

	if (!name)
		CRASH("spritesheet [type] cannot register without a name")

	create_spritesheets()
	if(should_load_immediately())
		realize_spritesheets(yield = FALSE)
	else
		SSasset_loading.queue_asset(src)

/datum/asset/spritesheet_batched/proc/create_spritesheets()
	var/list/paths = collect_typepaths()
	for(var/path in paths)
		var/datum/icon_batch_entry/entry = typepath_to_icon_entry(path)
		if(!entry)
			continue
		insert_icon(entry)

/datum/asset/spritesheet_batched/proc/insert_all_icons(prefix, icon/I, list/directions, prefix_with_dirs = TRUE)
	if (length(prefix))
		prefix = "[prefix]-"

	if (!directions)
		directions = list(SOUTH)

	for (var/icon_state_name in icon_states(I))
		for (var/direction in directions)
			var/prefix2 = (directions.len > 1 && prefix_with_dirs) ? "[dir2text(direction)]-" : ""
			insert_icon(icon_entry("[prefix][prefix2][icon_state_name]", I, icon_state_name, direction))

/datum/asset/spritesheet_batched/proc/realize_spritesheets(yield)
	if(fully_generated)
		return
	while(length(to_generate))
		var/list/stored_args = to_generate[to_generate.len]
		to_generate.len--
		queued_insert_icon(arglist(stored_args))
		if(yield && TICK_CHECK)
			return
	var/data_out
	if(yield || !isnull(job_id))
		if(isnull(job_id))
			var/data_in = json_encode(entries)
			job_id = rustg_iconforge_generate_async("data/spritesheets/", name, data_in)
		UNTIL((data_out = rustg_iconforge_check(job_id)) != RUSTG_JOB_NO_RESULTS_YET)
	else
		var/data_in = json_encode(entries)
		data_out = rustg_iconforge_generate("data/spritesheets/", name, data_in)
	if (data_out == RUSTG_JOB_ERROR)
		CRASH("Spritesheet [name] JOB PANIC")
	else if(findtext(data_out, "{", 1, 2) == 0)
		rustg_file_write(json_encode(entries), "[GLOB.log_directory]/spritesheet_debug_[name].json")
		CRASH("Spritesheet [name] UNKNOWN ERROR: [data_out]")
	var/data = json_decode(data_out)
	sizes = data["sizes"]
	sprites = data["sprites"]

	for(var/size_id in sizes)
		SSassets.transport.register_asset("[name]_[size_id].png", fcopy_rsc("data/spritesheets/[name]_[size_id].png"))
	var/res_name = "spritesheet_[name].css"
	var/fname = "data/spritesheets/[res_name]"

	fdel(fname)
	rustg_file_write(generate_css(), fname)
	SSassets.transport.register_asset(res_name, fcopy_rsc(fname))
	fdel(fname)

	fully_generated = TRUE
	// If we were ever in there, remove ourselves
	SSasset_loading.dequeue_asset(src)
	if(data["error"] && !(ignore_dir_errors && findtext(data["error"], "Invalid dir")))
		CRASH("Error during spritesheet generation for [name]: [data["error"]]")

/datum/asset/spritesheet_batched/queued_generation()
	realize_spritesheets(yield = TRUE)

/datum/asset/spritesheet_batched/ensure_ready()
	if(!fully_generated)
		realize_spritesheets(yield = FALSE)
	return ..()

/datum/asset/spritesheet_batched/send(client/client)
	if (!name)
		return

	var/all = list("spritesheet_[name].css")
	for(var/size_id in sizes)
		all += "[name]_[size_id].png"
	. = SSassets.transport.send_assets(client, all)

/datum/asset/spritesheet_batched/get_url_mappings()
	if (!name)
		return

	. = list("spritesheet_[name].css" = SSassets.transport.get_asset_url("spritesheet_[name].css"))
	for(var/size_id in sizes)
		.["[name]_[size_id].png"] = SSassets.transport.get_asset_url("[name]_[size_id].png")

/datum/asset/spritesheet_batched/proc/generate_css()
	var/list/out = list()

	for (var/size_id in sizes)
		var/size_split = splittext(size_id, "x")
		var/width = text2num(size_split[1])
		var/height = text2num(size_split[2])
		out += ".[name][size_id]{display:inline-block;width:[width]px;height:[height]px;background:url('[get_background_url("[name]_[size_id].png")]') no-repeat;}"

	for (var/sprite_id in sprites)
		var/sprite = sprites[sprite_id]
		var/size_id = sprite[SPR_SIZE]
		var/idx = sprite[SPR_IDX]

		var/size_split = splittext(size_id, "x")
		var/width = text2num(size_split[1])
		var/x = idx * width
		var/y = 0

		out += ".[name][size_id].[sprite_id]{background-position:-[x]px -[y]px;}"

	return out.Join("\n")

/// Returns the URL to put in the background:url of the CSS asset
/datum/asset/spritesheet_batched/proc/get_background_url(asset)
	return SSassets.transport.get_asset_url(asset)

/**
 * Third party helpers
 * ===================
 */

/datum/asset/spritesheet_batched/proc/css_tag()
	return {"<link rel="stylesheet" href="[css_filename()]" />"}

/datum/asset/spritesheet_batched/proc/css_filename()
	return SSassets.transport.get_asset_url("spritesheet_[name].css")

/datum/asset/spritesheet_batched/proc/icon_tag(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return {"<span class='[name][size_id] [sprite_name]'></span>"}

/datum/asset/spritesheet_batched/proc/icon_class_name(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return {"[name][size_id] [sprite_name]"}

/**
 * Returns the size class (ex design32x32) for a given sprite's icon
 *
 * Arguments:
 * * sprite_name - The sprite to get the size of
 */
/datum/asset/spritesheet_batched/proc/icon_size_id(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return "[name][size_id]"

#undef SPR_SIZE
#undef SPR_IDX
