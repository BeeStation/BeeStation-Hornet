#define SPR_SIZE "size_id"
#define SPR_IDX "position"

/datum/asset/spritesheet_batched
	_abstract = /datum/asset/spritesheet_batched
	var/name
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

/datum/asset/spritesheet_batched/proc/insert_icon(sprite_name, datum/universal_icon/entry)
	if(!istext(sprite_name) || length(sprite_name) == 0)
		CRASH("Invalid sprite_name \"[sprite_name]\" given to insert_icon()! Providing non-strings will break icon generation.")
	entries[sprite_name] = entry.to_list()

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

/// Call insert_icon or insert_all_icons here, building a spritesheet!
/datum/asset/spritesheet_batched/proc/create_spritesheets()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("create_spritesheets() not implemented for [type]!")

/datum/asset/spritesheet_batched/proc/insert_all_icons(prefix, icon/I, list/directions, prefix_with_dirs = TRUE)
	if (length(prefix))
		prefix = "[prefix]-"

	if (!directions)
		directions = list(SOUTH)

	for (var/icon_state_name in icon_states(I))
		for (var/direction in directions)
			var/prefix2 = (directions.len > 1 && prefix_with_dirs) ? "[dir2text(direction)]-" : ""
			insert_icon("[prefix][prefix2][icon_state_name]", uni_icon(I, icon_state_name, direction))

/datum/asset/spritesheet_batched/proc/realize_spritesheets(yield)
	if(fully_generated)
		return
	if(!length(entries))
		CRASH("Spritesheet [name] ([type]) is empty! What are you doing?")
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

/// Gets the relevant universal icon for an atom, when displayed in TGUI. (see: icon_state_preview)
/proc/get_display_icon_for(atom/A)
	if (!ispath(A, /atom))
		return FALSE
	var/icon_file = initial(A.icon)
	var/icon_state = initial(A.icon_state)
	if(ispath(A, /obj/item))
		var/obj/item/I = A
		if(initial(I.icon_state_preview))
			icon_state = initial(I.icon_state_preview)
		if(initial(I.greyscale_config) && initial(I.greyscale_colors))
			return gags_to_universal_icon(I)
	return uni_icon(icon_file, icon_state, color=initial(A.color))


