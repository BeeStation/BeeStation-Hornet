/datum/icon_batch_entry
	var/sprite_name
	var/icon/icon_file
	var/icon_state
	var/dir
	var/frame
	var/moving
	var/transform

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
		src.transform = T.generate()
	else if(!isnull(transform))
		src.transform = transform.generate() // convert to a list
	else // null = empty list
		src.transform = list()

/datum/icon_batch_entry/proc/to_list()
	return list("icon_file" = "[icon_file]", "icon_state" = icon_state, "dir" = dir, "frame" = frame, "moving" = moving, "transform" = transform)

/datum/icon_batch_entry/proc/to_json()
	return json_encode(to_list())

/datum/icon_transformer
	var/list/transforms = null

/datum/icon_transformer/New()
	transforms = list()

/datum/icon_transformer/proc/blend_color(color, blend_mode)
	transforms += list(list("type" = "ColorTransform", "color" = color, "blend_mode" = blend_mode))

/datum/icon_transformer/proc/generate()
	return transforms
