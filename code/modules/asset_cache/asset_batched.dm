#define SPR_SIZE "size_id"
#define SPR_IDX "position"
#define SPR_ENTRY "icon"
#define SPRSZ_COUNT "count"
#define SPRSZ_WIDTH "width"
#define SPRSZ_HEIGHT "height"

/datum/asset/spritesheet_batched
	_abstract = /datum/asset/spritesheet_batched
	var/name
	/// List of arguments to pass into queuedInsert
	/// Exists so we can queue icon insertion, mostly for stuff like preferences
	var/list/to_generate = list()
	/// "32x32" -> list(10, 32, 32)
	var/list/sizes = list()
	/// "foo_bar" -> list("32x32", 5, entry_obj)
	var/list/sprites = list()
	var/fully_generated = FALSE

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
/datum/asset/spritesheet_batched/proc/transform(color=null)
	RETURN_TYPE(/datum/icon_transformer)
	var/datum/icon_transformer/transform = new()
	if(color)
		transform.blend_color(color, BLEND_MULTIPLY)
	return transform

/// Constructs an icon entry.
/datum/asset/spritesheet_batched/proc/icon_entry(sprite_name, icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE, datum/icon_transformer/transform=null, color=null)
	return new /datum/icon_batch_entry(sprite_name, I, icon_state, dir, frame, moving, transform, color)

/// Takes icon entries and generates a set of size ID and positions for the overall spritesheet
/datum/asset/spritesheet_batched/proc/insert_icon(datum/icon_batch_entry/entry)
	if (!entry.icon_file)
		to_chat(world, "Hey no icon exists 1")
		return
	var/icon/I = icon(entry.icon_file, icon_state=entry.icon_state, dir=entry.dir, frame=entry.frame, moving=entry.moving)
	if(!I || !length(icon_states(I))) // direction or state specified doesn't exist
		// TODO: log this to the world log in debug mode.
		to_chat(world, "Hey no icon exists")
		return
	var/width = I.Width()
	var/height = I.Height()
	var/size_id = "[width]x[height]"
	var/size = sizes[size_id]
	var/sprite_name = entry.sprite_name

	if (sprites[sprite_name])
		CRASH("duplicate sprite \"[sprite_name]\" in sheet [name] ([type])")

	if (size)
		var/position = size[SPRSZ_COUNT]++
		sprites[sprite_name] = list(SPR_SIZE = size_id, SPR_IDX = position, SPR_ENTRY = entry.to_list())
	else
		sizes[size_id] = size = list(SPRSZ_COUNT = 1, SPRSZ_WIDTH = width, SPRSZ_HEIGHT = height)
		sprites[sprite_name] = list(SPR_SIZE = size_id, SPR_IDX = 0, SPR_ENTRY = entry.to_list())

/datum/asset/spritesheet_batched/should_refresh()
	return TRUE

/datum/asset/spritesheet_batched/register()
	SHOULD_NOT_OVERRIDE(TRUE)

	if (!name)
		CRASH("spritesheet [type] cannot register without a name")

	create_spritesheets()
	realize_spritesheets()

/datum/asset/spritesheet_batched/proc/create_spritesheets()
	var/list/paths = collect_typepaths()
	for(var/path in paths)
		var/datum/icon_batch_entry/entry = typepath_to_icon_entry(path)
		if(!entry)
			continue
		insert_icon(entry)

/datum/asset/spritesheet_batched/proc/realize_spritesheets()
	var/result = rustg_iconforge_generate("data/spritesheets/", name, json_encode(sizes), json_encode(sprites))
	to_chat(world, result)
	rustg_file_write(json_encode(sprites), "test.json")
	for(var/size_id in sizes)
		SSassets.transport.register_asset("[name]_[size_id].png", fcopy_rsc("data/spritesheets/[name]_[size_id].png"))
	var/res_name = "spritesheet_[name].css"
	var/fname = "data/spritesheets/[res_name]"

	fdel(fname)
	text2file(generate_css(), fname)
	SSassets.transport.register_asset(res_name, fcopy_rsc(fname))
	fdel(fname)

	fully_generated = TRUE
	// If we were ever in there, remove ourselves
	SSasset_loading.dequeue_asset(src)

/datum/asset/spritesheet_batched/queued_generation()
	realize_spritesheets()

/datum/asset/spritesheet_batched/ensure_ready()
	if(!fully_generated)
		realize_spritesheets()
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
		var/size = sizes[size_id]
		var/width = size[SPRSZ_WIDTH]
		var/height = size[SPRSZ_HEIGHT]
		out += ".[name][size_id]{display:inline-block;width:[width]px;height:[height]px;background:url('[get_background_url("[name]_[size_id].png")]') no-repeat;}"

	for (var/sprite_id in sprites)
		var/sprite = sprites[sprite_id]
		var/size_id = sprite[SPR_SIZE]
		var/idx = sprite[SPR_IDX]
		var/size = sizes[size_id]

		var/width_small = size[SPRSZ_WIDTH]
		var/height_small = size[SPRSZ_HEIGHT]
		var/x = idx * width_small
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
#undef SPR_ENTRY
#undef SPRSZ_COUNT
#undef SPRSZ_WIDTH
#undef SPRSZ_HEIGHT
