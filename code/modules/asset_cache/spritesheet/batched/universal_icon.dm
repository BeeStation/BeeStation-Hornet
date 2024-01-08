/// This is intended to replace /icon, allowing rustg to generate icons much faster than DM can at scale.
/// Construct these with the uni_icon() proc, in the same manner as BYOND's icon() proc.
/// Additionally supports a number of transform procs (lowercase, rather than BYOND's uppercase)
/// such as Crop, Scale, and Blend (as blend_icon/blend_color).
/datum/universal_icon
	var/icon/icon_file
	var/icon_state
	var/dir
	var/frame
	var/datum/icon_transformer/transform

/// Don't instantiate these yourself, use uni_icon.
/datum/universal_icon/New(icon/icon_file, icon_state="", dir=SOUTH, frame=1, datum/icon_transformer/transform=null, color=null)
	#ifdef UNIT_TESTS
	// This check is kinda slow and shouldn't fail unless a developer makes a mistake. So it'll get caught in unit tests.
	if(!isicon(icon_file) || !isfile(icon_file) || "[icon_file]" == "/icon")
		// bad! use 'icons/path_to_dmi.dmi' format only
		CRASH("FATAL: universal_icon was provided icon_file: [icon_file] - icons provided to batched spritesheets MUST be DMI files, they cannot be /image, /icon, or other runtime generated icons.")
	#endif
	src.icon_file = icon_file
	src.icon_state = icon_state
	src.dir = dir
	src.frame = frame
	if(isnull(transform) && !isnull(color) && uppertext(color) != "#FFFFFF")
		var/datum/icon_transformer/T = new()
		if(color)
			T.blend_color(color, ICON_MULTIPLY)
		src.transform = T
	else if(!isnull(transform))
		src.transform = transform
	else // null = empty list
		src.transform = null

/datum/universal_icon/proc/copy()
	RETURN_TYPE(/datum/universal_icon)
	var/datum/universal_icon/new_icon = new(icon_file, icon_state, dir, frame)
	if(!isnull(src.transform))
		new_icon.transform = src.transform.copy()
	return new_icon

/datum/universal_icon/proc/blend_color(color, blend_mode)
	if(!transform)
		transform = new
	transform.blend_color(color, blend_mode)
	return src

/datum/universal_icon/proc/blend_icon(datum/universal_icon/icon_object, blend_mode)
	if(!transform)
		transform = new
	transform.blend_icon(icon_object, blend_mode)
	return src

/datum/universal_icon/proc/scale(width, height)
	if(!transform)
		transform = new
	transform.scale(width, height)
	return src

/datum/universal_icon/proc/crop(x1, y1, x2, y2)
	if(!transform)
		transform = new
	transform.crop(x1, y1, x2, y2)
	return src

/datum/universal_icon/proc/to_list()
	RETURN_TYPE(/list)
	return list("icon_file" = "[icon_file]", "icon_state" = icon_state, "dir" = dir, "frame" = frame, "transform" = !isnull(transform) ? transform.to_list() : list())

/proc/universal_icon_from_list(list/input_in)
	RETURN_TYPE(/datum/universal_icon)
	var/list/input = input_in.Copy() // copy, since icon_transformer_from_list will mutate the list.
	return uni_icon(input["icon_file"], input["icon_state"], input["dir"], input["frame"], icon_transformer_from_list(input["transform"]))

/datum/universal_icon/proc/to_json()
	return json_encode(to_list())

/datum/universal_icon/proc/to_icon()
	RETURN_TYPE(/icon)
	var/icon/self = icon(src.icon_file, src.icon_state, dir=src.dir, frame=src.frame)
	if(istype(src.transform))
		src.transform.apply(self)
	return self

/datum/icon_transformer
	var/list/transforms = null

/datum/icon_transformer/New()
	transforms = list()

/// Applies the contained set of transforms to an icon
/datum/icon_transformer/proc/apply(icon/target)
	RETURN_TYPE(/icon)
	for(var/transform in src.transforms)
		switch(transform["type"])
			if(RUSTG_ICONFORGE_BLEND_COLOR)
				target.Blend(target["color"], target["blend_mode"])
			if(RUSTG_ICONFORGE_BLEND_ICON)
				var/datum/universal_icon/icon_object = target["icon"]
				if(!istype(icon_object))
					stack_trace("Invalid icon found in icon transformer during apply()! [icon_object]")
					continue
				target.Blend(icon_object.to_icon(), target["blend_mode"])
			if(RUSTG_ICONFORGE_SCALE)
				target.Scale(target["width"], target["height"])
			if(RUSTG_ICONFORGE_CROP)
				target.Crop(target["x1"], target["y1"], target["x2"], target["y2"])
	return target

/datum/icon_transformer/proc/copy()
	RETURN_TYPE(/datum/icon_transformer)
	var/datum/icon_transformer/new_transformer = new()
	new_transformer.transforms = list()
	for(var/transform in src.transforms)
		new_transformer.transforms += list(deep_copy_list_alt(transform))
	return new_transformer

/datum/icon_transformer/proc/blend_color(color, blend_mode)
	transforms += list(list("type" = RUSTG_ICONFORGE_BLEND_COLOR, "color" = color, "blend_mode" = blend_mode))

/datum/icon_transformer/proc/blend_icon(datum/universal_icon/icon_object, blend_mode)
	transforms += list(list("type" = RUSTG_ICONFORGE_BLEND_ICON, "icon" = icon_object, "blend_mode" = blend_mode))

/datum/icon_transformer/proc/scale(width, height)
	transforms += list(list("type" = RUSTG_ICONFORGE_SCALE, "width" = width, "height" = height))

/datum/icon_transformer/proc/crop(x1, y1, x2, y2)
	transforms += list(list("type" = RUSTG_ICONFORGE_CROP, "x1" = x1, "y1" = y1, "x2" = x2, "y2" = y2))

/datum/icon_transformer/proc/to_list()
	RETURN_TYPE(/list)
	var/list/transforms_out = list()
	for(var/transform in src.transforms.Copy())
		var/this_transform = transform
		if(transform["type"] == RUSTG_ICONFORGE_BLEND_ICON)
			var/datum/universal_icon/icon_object = this_transform["icon"]
			if(!istype(icon_object))
				stack_trace("Invalid icon found in icon transformer during to_list()! [icon_object]")
				continue
			this_transform["icon"] = icon_object.to_list()
		transforms_out += list(this_transform)
	return transforms_out

/proc/icon_transformer_from_list(list/input)
	RETURN_TYPE(/datum/icon_transformer)
	var/list/transforms = list()
	for(var/transform in input)
		var/this_transform = transform
		if(transform["type"] == RUSTG_ICONFORGE_BLEND_ICON)
			this_transform["icon"] = universal_icon_from_list(transform["icon"])
		transforms += list(this_transform)
	var/datum/icon_transformer/transformer = new()
	transformer.transforms = transforms
	return transformer

/// Constructs a transformer, with optional color multiply pre-added.
/proc/color_transform(color=null)
	RETURN_TYPE(/datum/icon_transformer)
	var/datum/icon_transformer/transform = new()
	if(color)
		transform.blend_color(color, ICON_MULTIPLY)
	return transform

/// Converts a GAGS item to a universal icon by generating blend operations.
/proc/gags_to_universal_icon(obj/item/path)
	RETURN_TYPE(/datum/universal_icon)
	if(!ispath(path, /obj/item) || !initial(path.greyscale_config) || !initial(path.greyscale_colors))
		CRASH("gags_to_universal_icon() received an invalid path!")
	var/datum/greyscale_config/config = initial(path.greyscale_config)
	var/colors = initial(path.greyscale_colors)
	var/datum/universal_icon/entry = SSgreyscale.GetColoredIconEntryByType(config, colors, initial(path.icon_state))
	return entry

/// Gets the relevant universal icon for an atom, when displayed in TGUI. (see: icon_state_preview)
/// Supports GAGS items and colored items.
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

