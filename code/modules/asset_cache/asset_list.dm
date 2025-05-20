//These datums are used to populate the asset cache, the proc "register()" does this.
//Place any asset datums you create in asset_list_items.dm

//all of our asset datums, used for referring to these later
GLOBAL_LIST_EMPTY(asset_datums)

//get an assetdatum or make a new one
//does NOT ensure it's filled, if you want that use get_asset_datum()
/proc/load_asset_datum(type)
	return GLOB.asset_datums[type] || new type()

/proc/get_asset_datum(type)
	var/datum/asset/loaded_asset = GLOB.asset_datums[type] || new type()
	return loaded_asset.ensure_ready()

/datum/asset
	var/_abstract = /datum/asset
	var/cached_serialized_url_mappings
	var/cached_serialized_url_mappings_transport_type

	/// Whether or not this asset can be cached across rounds of the same commit under the `CACHE_ASSETS` config.
	/// This is not a *guarantee* the asset will be cached. Not all asset subtypes respect this field, and the
	/// config can, of course, be disabled.
	/// Disable this if your asset can change between rounds on the same exact version of the code.
	var/cross_round_cachable = FALSE

	/// Whether or not this asset should be loaded in the "early assets" SS
	var/early = FALSE

/datum/asset/New()
	GLOB.asset_datums[type] = src
	register()

/// Stub that allows us to react to something trying to get us
/// Not useful here, more handy for sprite sheets
/datum/asset/proc/ensure_ready()
	return src

/// Stub to hook into if your asset is having its generation queued by SSasset_loading
/datum/asset/proc/queued_generation()
	CRASH("[type] inserted into SSasset_loading despite not implementing /proc/queued_generation")

/datum/asset/proc/get_url_mappings()
	return list()

/// Returns a cached tgui message of URL mappings
/datum/asset/proc/get_serialized_url_mappings()
	if (isnull(cached_serialized_url_mappings) || cached_serialized_url_mappings_transport_type != SSassets.transport.type)
		cached_serialized_url_mappings = TGUI_CREATE_MESSAGE("asset/mappings", get_url_mappings())
		cached_serialized_url_mappings_transport_type = SSassets.transport.type

	return cached_serialized_url_mappings

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

/// Returns whether or not the asset should attempt to read from cache
/datum/asset/proc/should_refresh()
	return !cross_round_cachable || !CONFIG_GET(flag/cache_assets)

/// Immediately regenerate the asset, overwriting any cache.
/datum/asset/proc/regenerate()
	SHOULD_CALL_PARENT(FALSE)
	unregister()
	cached_serialized_url_mappings = null
	cached_serialized_url_mappings_transport_type = null
	register()

/// Unregisters any assets from the transport.
/datum/asset/proc/unregister()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("unregister() not implemented for asset [type]!")

/// If you don't need anything complicated.
/datum/asset/simple
	_abstract = /datum/asset/simple
	/// list of assets for this datum in the form of:
	/// asset_filename = asset_file. At runtime the asset_file will be
	/// converted into a asset_cache datum.
	var/assets = list()
	/// Set to true to have this asset also be sent via the legacy browse_rsc
	/// system when cdn transports are enabled?
	var/legacy = FALSE
	/// TRUE for keeping local asset names when browse_rsc backend is used
	var/keep_local_name = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		var/datum/asset_cache_item/ACI = SSassets.transport.register_asset(asset_name, assets[asset_name])
		if (!ACI)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		if (legacy)
			ACI.legacy = legacy
		if (keep_local_name)
			ACI.keep_local_name = keep_local_name
		assets[asset_name] = ACI

/datum/asset/simple/send(client)
	. = SSassets.transport.send_assets(client, assets)

/datum/asset/simple/get_url_mappings()
	. = list()
	for (var/asset_name in assets)
		.[asset_name] = SSassets.transport.get_asset_url(asset_name, assets[asset_name])

/datum/asset/simple/unregister()
	for (var/asset_name in assets)
		SSassets.transport.unregister_asset(asset_name)

// For registering or sending multiple others at once
/datum/asset/group
	_abstract = /datum/asset/group
	var/list/children

/datum/asset/group/register()
	for(var/type in children)
		load_asset_datum(type)

/datum/asset/group/send(client/C)
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		. = A.send(C) || .

/datum/asset/group/get_url_mappings()
	. = list()
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		. += A.get_url_mappings()

/datum/asset/group/unregister()
	for (var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		A.unregister()

// spritesheet implementation - coalesces various icons into a single .png file
// and uses CSS to select icons out of that file - saves on transferring some
// 1400-odd individual PNG files
#define SPR_SIZE 1
#define SPR_IDX 2
#define SPRSZ_COUNT 1
#define SPRSZ_ICON 2
#define SPRSZ_STRIPPED 3

/datum/asset/spritesheet
	_abstract = /datum/asset/spritesheet
	cross_round_cachable = TRUE
	var/name
	/// List of arguments to pass into queuedInsert
	/// Exists so we can queue icon insertion, mostly for stuff like preferences
	var/list/to_generate = list()
	var/list/sizes = list()    // "32x32" -> list(10, icon/normal, icon/stripped)
	var/list/sprites = list()  // "foo_bar" -> list("32x32", 5)
	var/list/cached_spritesheets_needed
	var/generating_cache = FALSE
	var/fully_generated = FALSE
	/// If this asset should be fully loaded on new
	/// Defaults to false so we can process this stuff nicely
	var/load_immediately = FALSE
	VAR_PRIVATE
		// Kept in state so that the result is the same, even when the files are created, for this run
		should_refresh = null

/datum/asset/spritesheet/proc/should_load_immediately()
#ifdef DO_NOT_DEFER_ASSETS
	return TRUE
#else
	return load_immediately
#endif

/datum/asset/spritesheet/should_refresh()
	if (..())
		return TRUE

	if (isnull(should_refresh))
		// `fexists` seems to always fail on static-time
		should_refresh = !fexists(css_cache_filename()) || !fexists(data_cache_filename())

	return should_refresh

/datum/asset/spritesheet/unregister()
	SSassets.transport.unregister_asset("spritesheet_[name].css")
	if(length(sizes))
		for(var/size_id in sizes)
			SSassets.transport.unregister_asset("[name]_[size_id].png")
	else
		for(var/sheet in cached_spritesheets_needed)
			SSassets.transport.unregister_asset(sheet)

/datum/asset/spritesheet/regenerate()
	unregister()
	sprites = list()
	fdel("[ASSET_CROSS_ROUND_CACHE_DIRECTORY]/spritesheet.[name].css")
	for(var/sheet in cached_spritesheets_needed)
		fdel("[ASSET_CROSS_ROUND_CACHE_DIRECTORY]/spritesheet.[sheet].png")
	fdel("data/spritesheets/spritesheet_[name].css")
	for(var/size_id in sizes)
		fdel("data/spritesheets/[name]_[size_id].png")
	sizes = list()
	to_generate = list()
	cached_serialized_url_mappings = null
	cached_serialized_url_mappings_transport_type = null
	fully_generated = FALSE
	var/old_load = load_immediately
	load_immediately = TRUE
	create_spritesheets()
	realize_spritesheets(yield = FALSE)
	load_immediately = old_load

/datum/asset/spritesheet/register()
	SHOULD_NOT_OVERRIDE(TRUE)

	if (!name)
		CRASH("spritesheet [type] cannot register without a name")

	if (!should_refresh() && read_from_cache())
		fully_generated = TRUE
		return

	// If it's cached, may as well load it now, while the loading is cheap
	if(CONFIG_GET(flag/cache_assets) && cross_round_cachable)
		load_immediately = TRUE

	create_spritesheets()
	if(should_load_immediately())
		realize_spritesheets(yield = FALSE)
	else
		SSasset_loading.queue_asset(src)

/datum/asset/spritesheet/proc/realize_spritesheets(yield)
	if(fully_generated)
		return
	while(length(to_generate))
		var/list/stored_args = to_generate[to_generate.len]
		to_generate.len--
		queuedInsert(arglist(stored_args))
		if(yield && TICK_CHECK)
			return

	ensure_stripped()
	for(var/size_id in sizes)
		var/size = sizes[size_id]
		var/file_path = size[SPRSZ_STRIPPED]
		var/file_hash = rustg_hash_file("md5", file_path)
		SSassets.transport.register_asset("[name]_[size_id].png", file_path, file_hash=file_hash)
	var/res_name = "spritesheet_[name].css"
	var/fname = "data/spritesheets/[res_name]"
	fdel(fname)
	var/css = generate_css()
	rustg_file_write(css, fname)
	var/css_hash = rustg_hash_string("md5", css)
	SSassets.transport.register_asset(res_name, fcopy_rsc(fname), file_hash=css_hash)
	fdel(fname)

	if (CONFIG_GET(flag/cache_assets) && cross_round_cachable)
		write_to_cache()
	fully_generated = TRUE
	// If we were ever in there, remove ourselves
	SSasset_loading.dequeue_asset(src)

/datum/asset/spritesheet/queued_generation()
	realize_spritesheets(yield = TRUE)

/datum/asset/spritesheet/ensure_ready()
	if(!fully_generated)
		realize_spritesheets(yield = FALSE)
	return ..()

/datum/asset/spritesheet/send(client/client)
	if (!name)
		return

	if (!should_refresh())
		return send_from_cache(client)

	var/all = list("spritesheet_[name].css")
	for(var/size_id in sizes)
		all += "[name]_[size_id].png"
	. = SSassets.transport.send_assets(client, all)

/datum/asset/spritesheet/get_url_mappings()
	if (!name)
		return

	if (!should_refresh())
		return get_cached_url_mappings()

	. = list("spritesheet_[name].css" = SSassets.transport.get_asset_url("spritesheet_[name].css"))
	for(var/size_id in sizes)
		.["[name]_[size_id].png"] = SSassets.transport.get_asset_url("[name]_[size_id].png")

/datum/asset/spritesheet/proc/ensure_stripped(sizes_to_strip = sizes)
	for(var/size_id in sizes_to_strip)
		var/size = sizes[size_id]
		if (size[SPRSZ_STRIPPED])
			continue

		// save flattened version
		var/fname = "data/spritesheets/[name]_[size_id].png"
		fcopy(size[SPRSZ_ICON], fname)
		var/error = rustg_dmi_strip_metadata(fname)
		if(length(error))
			stack_trace("Failed to strip [name]_[size_id].png: [error]")
		size[SPRSZ_STRIPPED] = icon(fname)
		fdel(fname)

/datum/asset/spritesheet/proc/generate_css()
	var/list/out = list()

	for (var/size_id in sizes)
		var/size = sizes[size_id]
		var/icon/tiny = size[SPRSZ_ICON]
		out += ".[name][size_id]{display:inline-block;width:[tiny.Width()]px;height:[tiny.Height()]px;background-image:url('[get_background_url("[name]_[size_id].png")]');background-repeat: no-repeat;}"

	for (var/sprite_id in sprites)
		var/sprite = sprites[sprite_id]
		var/size_id = sprite[SPR_SIZE]
		var/idx = sprite[SPR_IDX]
		var/size = sizes[size_id]

		var/icon/tiny = size[SPRSZ_ICON]
		var/icon/big = size[SPRSZ_STRIPPED]
		var/per_line = big.Width() / tiny.Width()
		var/x = (idx % per_line) * tiny.Width()
		var/y = round(idx / per_line) * tiny.Height()

		out += ".[name][size_id].[sprite_id]{background-position:-[x]px -[y]px;}"

	return out.Join("\n")

/datum/asset/spritesheet/proc/css_cache_filename()
	return "[ASSET_CROSS_ROUND_CACHE_DIRECTORY]/spritesheet.[name].css"

/datum/asset/spritesheet/proc/data_cache_filename()
	return "[ASSET_CROSS_ROUND_CACHE_DIRECTORY]/spritesheet.[name].json"

/datum/asset/spritesheet/proc/read_from_cache()
	return read_css_from_cache() && read_data_from_cache()

/datum/asset/spritesheet/proc/read_css_from_cache()
	var/replaced_css = file2text(css_cache_filename())

	var/regex/find_background_urls = regex(@"background:url\('%(.+?)%'\)", "g")
	while (find_background_urls.Find(replaced_css))
		var/asset_id = find_background_urls.group[1]
		var/file_path = "[ASSET_CROSS_ROUND_CACHE_DIRECTORY]/spritesheet.[asset_id]"
		// Hashing it here is a *lot* faster.
		var/hash = rustg_hash_file("md5", file_path)
		var/asset_cache_item = SSassets.transport.register_asset(asset_id, file_path, file_hash=hash)
		var/asset_url = SSassets.transport.get_asset_url(asset_cache_item = asset_cache_item)
		replaced_css = replacetext(replaced_css, find_background_urls.match, "background:url('[asset_url]')")
		LAZYADD(cached_spritesheets_needed, asset_id)

	var/replaced_css_filename = "data/spritesheets/spritesheet_[name].css"
	var/css_hash = rustg_hash_string("md5", replaced_css)
	rustg_file_write(replaced_css, replaced_css_filename)
	SSassets.transport.register_asset("spritesheet_[name].css", replaced_css_filename, file_hash=css_hash)

	fdel(replaced_css_filename)

	return TRUE

/datum/asset/spritesheet/proc/read_data_from_cache()
	var/json = json_decode(file2text(data_cache_filename()))

	if (islist(json["sprites"]))
		sprites = json["sprites"]

	return TRUE

/datum/asset/spritesheet/proc/send_from_cache(client/client)
	if (isnull(cached_spritesheets_needed))
		stack_trace("cached_spritesheets_needed was null when sending assets from [type] from cache")
		cached_spritesheets_needed = list()

	return SSassets.transport.send_assets(client, cached_spritesheets_needed + "spritesheet_[name].css")

/// Returns the URL to put in the background:url of the CSS asset
/datum/asset/spritesheet/proc/get_background_url(asset)
	if (generating_cache)
		return "%[asset]%"
	else
		return SSassets.transport.get_asset_url(asset)

/datum/asset/spritesheet/proc/write_to_cache()
	write_css_to_cache()
	write_data_to_cache()

/datum/asset/spritesheet/proc/write_css_to_cache()
	for (var/size_id in sizes)
		var/datum/asset_cache_item/temp = SSassets.cache["[name]_[size_id].png"]
		fcopy(temp.resource, "[ASSET_CROSS_ROUND_CACHE_DIRECTORY]/spritesheet.[name]_[size_id].png")

	generating_cache = TRUE
	var/mock_css = generate_css()
	generating_cache = FALSE

	rustg_file_write(mock_css, css_cache_filename())

/datum/asset/spritesheet/proc/write_data_to_cache()
	rustg_file_write(json_encode(list(
		"sprites" = sprites,
	)), data_cache_filename())

/datum/asset/spritesheet/proc/get_cached_url_mappings()
	var/list/mappings = list()
	mappings["spritesheet_[name].css"] = SSassets.transport.get_asset_url("spritesheet_[name].css")

	for (var/asset_name in cached_spritesheets_needed)
		mappings[asset_name] = SSassets.transport.get_asset_url(asset_name)

	return mappings

/// Override this in order to start the creation of the spritehseet.
/// This is where all your Insert, InsertAll, etc calls should be inside.
/datum/asset/spritesheet/proc/create_spritesheets()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("create_spritesheets() not implemented for [type]!")

/datum/asset/spritesheet/proc/Insert(sprite_name, icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE)
	if(should_load_immediately())
		queuedInsert(sprite_name, I, icon_state, dir, frame, moving)
	else
		to_generate += list(args.Copy())

// LEMON NOTE
// A GOON CODER SAYS BAD ICON ERRORS CAN BE THROWN BY THE "ICON CACHE"
// APPARENTLY IT MAKES ICONS IMMUTABLE
// LOOK INTO USING THE MUTABLE APPEARANCE PATTERN HERE
/datum/asset/spritesheet/proc/queuedInsert(sprite_name, icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE)
	I = icon(I, icon_state=icon_state, dir=dir, frame=frame, moving=moving)
	if (!I || !length(icon_states(I)))  // that direction or state doesn't exist
		return
	var/size_id = "[I.Width()]x[I.Height()]"
	var/size = sizes[size_id]

	if (sprites[sprite_name])
		CRASH("duplicate sprite \"[sprite_name]\" in sheet [name] ([type])")

	if (size)
		var/position = size[SPRSZ_COUNT]++
		var/icon/sheet = size[SPRSZ_ICON]
		var/icon/sheet_copy = icon(sheet)
		size[SPRSZ_STRIPPED] = null
		sheet_copy.Insert(I, icon_state=sprite_name)
		size[SPRSZ_ICON] = sheet_copy

		sprites[sprite_name] = list(size_id, position)
	else
		sizes[size_id] = size = list(1, I, null)
		sprites[sprite_name] = list(size_id, 0)

/datum/asset/spritesheet/proc/InsertAll(prefix, icon/I, list/directions)
	if (length(prefix))
		prefix = "[prefix]-"

	if (!directions)
		directions = list(SOUTH)

	for (var/icon_state_name in icon_states(I))
		for (var/direction in directions)
			var/prefix2 = (directions.len > 1) ? "[dir2text(direction)]-" : ""
			Insert("[prefix][prefix2][icon_state_name]", I, icon_state=icon_state_name, dir=direction)

/datum/asset/spritesheet/proc/css_tag()
	return {"<link rel="stylesheet" href="[css_filename()]" />"}

/datum/asset/spritesheet/proc/css_filename()
	return SSassets.transport.get_asset_url("spritesheet_[name].css")

/datum/asset/spritesheet/proc/icon_tag(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return {"<span class='[name][size_id] [sprite_name]'></span>"}

/datum/asset/spritesheet/proc/icon_class_name(sprite_name)
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
/datum/asset/spritesheet/proc/icon_size_id(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return "[name][size_id]"

#undef SPR_SIZE
#undef SPR_IDX
#undef SPRSZ_COUNT
#undef SPRSZ_ICON
#undef SPRSZ_STRIPPED


/datum/asset/spritesheet/simple
	_abstract = /datum/asset/spritesheet/simple
	var/list/assets

/datum/asset/spritesheet/simple/create_spritesheets()
	for (var/key in assets)
		Insert(key, assets[key])

//Generates assets based on iconstates of a single icon
/datum/asset/simple/icon_states
	_abstract = /datum/asset/simple/icon_states
	var/icon
	var/list/directions = list(SOUTH)
	var/frame = 1
	var/movement_states = FALSE

	var/prefix = "default" //asset_name = "[prefix].[icon_state_name].png"
	var/generic_icon_names = FALSE //generate icon filenames using generate_asset_name() instead the above format

/datum/asset/simple/icon_states/register(_icon = icon)
	for(var/icon_state_name in icon_states(_icon))
		for(var/direction in directions)
			var/asset = icon(_icon, icon_state_name, direction, frame, movement_states)
			if (!asset)
				continue
			asset = fcopy_rsc(asset) //dedupe
			var/prefix2 = (directions.len > 1) ? "[dir2text(direction)]." : ""
			var/asset_name = SANITIZE_FILENAME("[prefix].[prefix2][icon_state_name].png")
			if (generic_icon_names)
				asset_name = "[generate_asset_name(asset)].png"

			SSassets.transport.register_asset(asset_name, asset)

/datum/asset/simple/icon_states/multiple_icons
	_abstract = /datum/asset/simple/icon_states/multiple_icons
	var/list/icons

/datum/asset/simple/icon_states/multiple_icons/register()
	for(var/i in icons)
		..(i)

/// Namespace'ed assets (for static css and html files)
/// When sent over a cdn transport, all assets in the same asset datum will exist in the same folder, as their plain names.
/// Used to ensure css files can reference files by url() without having to generate the css at runtime, both the css file and the files it depends on must exist in the same namespace asset datum. (Also works for html)
/// For example `blah.css` with asset `blah.png` will get loaded as `namespaces/a3d..14f/f12..d3c.css` and `namespaces/a3d..14f/blah.png`. allowing the css file to load `blah.png` by a relative url rather then compute the generated url with get_url_mappings().
/// The namespace folder's name will change if any of the assets change. (excluding parent assets)
/datum/asset/simple/namespaced
	_abstract = /datum/asset/simple/namespaced
	/// parents - list of the parent asset or assets (in name = file assoicated format) for this namespace.
	/// parent assets must be referenced by their generated url, but if an update changes a parent asset, it won't change the namespace's identity.
	var/list/parents = list()

/datum/asset/simple/namespaced/register()
	if (legacy)
		assets |= parents
	var/list/hashlist = list()
	var/list/sorted_assets = sort_list(assets)

	for (var/asset_name in sorted_assets)
		var/datum/asset_cache_item/ACI = new(asset_name, sorted_assets[asset_name])
		if (!ACI?.hash)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		hashlist += ACI.hash
		sorted_assets[asset_name] = ACI
	var/namespace = md5(hashlist.Join())

	for (var/asset_name in parents)
		var/datum/asset_cache_item/ACI = new(asset_name, parents[asset_name])
		if (!ACI?.hash)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		ACI.namespace_parent = TRUE
		sorted_assets[asset_name] = ACI

	for (var/asset_name in sorted_assets)
		var/datum/asset_cache_item/ACI = sorted_assets[asset_name]
		if (!ACI?.hash)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		ACI.namespace = namespace

	assets = sorted_assets
	..()

/// Get a html string that will load a html asset.
/// Needed because byond doesn't allow you to browse() to a url.
/datum/asset/simple/namespaced/proc/get_htmlloader(filename)
	return url2htmlloader(SSassets.transport.get_asset_url(filename, assets[filename]))

/// A subtype to generate a JSON file from a list
/datum/asset/json
	_abstract = /datum/asset/json
	/// The filename, will be suffixed with ".json"
	var/name

/datum/asset/json/send(client)
	return SSassets.transport.send_assets(client, "[name].json")

/datum/asset/json/get_url_mappings()
	return list(
		"[name].json" = SSassets.transport.get_asset_url("[name].json"),
	)

/datum/asset/json/register()
	var/filename = "data/[name].json"
	fdel(filename)
	rustg_file_write(json_encode(generate()), filename)
	SSassets.transport.register_asset("[name].json", fcopy_rsc(filename))
	fdel(filename)

/// Returns the data that will be JSON encoded
/datum/asset/json/proc/generate()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("generate() not implemented for [type]!")

/datum/asset/json/unregister()
	SSassets.transport.unregister_asset("[name].json")
