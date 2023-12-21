/datum/icon_batch_entry
	var/sprite_name
	var/icon/icon_file
	var/icon_state
	var/dir
	var/frame
	var/moving
	var/datum/icon_transformer/transform

/datum/icon_batch_entry/New(sprite_name, icon/icon_file, icon_state="", dir=SOUTH, frame=1, moving=FALSE, datum/icon_transformer/transform=null, color=null)
	src.sprite_name = sprite_name
	if(!isicon(icon_file) || !isfile(icon_file) || "[icon_file]" == "/icon")
		qdel(src)
		// bad! use 'icons/path_to_dmi.dmi' format only
		CRASH("FATAL: [sprite_name] was provided icon_file: [icon_file] - icons provided to batched spritesheets MUST be DMI files, they cannot be /image, /icon, or other runtime generated icons.")
	src.icon_file = icon_file
	src.icon_state = icon_state
	src.dir = dir
	src.frame = frame
	src.moving = moving
	if(isnull(transform) && !isnull(color) && uppertext(color) != "#FFFFFF")
		var/datum/icon_transformer/T = new()
		if(color)
			T.blend_color(color, BLEND_MULTIPLY)
		src.transform = T
	else if(!isnull(transform))
		src.transform = transform
	else // null = empty list
		src.transform = null

/datum/icon_batch_entry/proc/copy()
	var/datum/icon_batch_entry/new_entry = new(sprite_name, icon_file, icon_state, dir, frame, moving)
	if(!isnull(src.transform))
		new_entry.transform = src.transform.copy()
	return new_entry

/datum/icon_batch_entry/proc/blend_color(color, blend_mode)
	if(!transform)
		transform = new
	transform.blend_color(color, blend_mode)

/datum/icon_batch_entry/proc/blend_icon(datum/icon_batch_entry/icon_object, blend_mode)
	if(!transform)
		transform = new
	transform.blend_icon(icon_object, blend_mode)

/datum/icon_batch_entry/proc/scale(width, height)
	if(!transform)
		transform = new
	transform.scale(width, height)

/datum/icon_batch_entry/proc/crop(x1, y1, x2, y2)
	if(!transform)
		transform = new
	transform.crop(x1, y1, x2, y2)

/datum/icon_batch_entry/proc/to_list()
	return list("icon_file" = "[icon_file]", "icon_state" = icon_state, "dir" = dir, "frame" = frame, "moving" = moving, "transform" = !isnull(transform) ? transform.generate() : list())

/datum/icon_batch_entry/proc/to_json()
	return json_encode(to_list())

/datum/icon_transformer
	var/list/transforms = null

/datum/icon_transformer/New()
	transforms = list()

/datum/icon_transformer/proc/copy()
	var/datum/icon_transformer/new_transformer = new()
	new_transformer.transforms = list()
	for(var/transform in src.transforms)
		new_transformer.transforms += list(deep_copy_list_alt(transform))
	return new_transformer

/datum/icon_transformer/proc/blend_color(color, blend_mode)
	transforms += list(list("type" = "BlendColorTransform", "color" = color, "blend_mode" = blend_mode))

/datum/icon_transformer/proc/blend_icon(datum/icon_batch_entry/icon_object, blend_mode)
	transforms += list(list("type" = "BlendIconTransform", "icon" = icon_object.to_list(), "blend_mode" = blend_mode))

/datum/icon_transformer/proc/scale(width, height)
	transforms += list(list("type" = "ScaleTransform", "width" = width, "height" = height))

/datum/icon_transformer/proc/crop(x1, y1, x2, y2)
	transforms += list(list("type" = "CropTransform", "x1" = x1, "y1" = y1, "x2" = x2, "y2" = y2))

/datum/icon_transformer/proc/generate()
	return transforms
