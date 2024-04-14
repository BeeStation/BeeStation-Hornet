/proc/build_appearance_var_list()
	. = list()
	var/list/unused_var_names = list(
		"vars", // /appearnace doesn't have internal "vars" variable. Even if it has, we have no reason to see it
		"appearance", // it only does self-reference
		"x","y","z", // these are always 0

		// we have no reason to show those, right?
		"active_timers",
		"comp_lookup",
		"signal_procs",
		"status_traits",
		"stat_tabs",
		"cooldowns",
		"datum_flags",
		"gender",
		"visibility",
		"verbs",
		)
	var/image/dummy_image = image(null, null)
	for(var/each in dummy_image.vars)
		if(each in unused_var_names)
			continue
		. += each
	del(dummy_image)
	dummy_image = null

/// appearance type needs a manual change because it doesn't have "vars" variable internally.
/// There's no way doing this in a fancier way.
/proc/debug_variable_appearance(var_name, image/appearance)
	try // somehow /appearance has vars variable.
		return "<li style='backgroundColor:white'>(STATIC) [var_name] = [_debug_variable_value(var_name, appearance.vars[var_name], 0, appearance)]</li>"
	catch
		pass()

	var/atom/movable/atom_appearance = appearance
	var/value
	try
		switch(var_name) // Welcome to this curse
			// real vars that appearance uses
			if("parent_type")
				value = appearance.parent_type
			if("type")
				value = appearance.type

			// appearance vars in DM document
			if("alpha")
				value = appearance.alpha
			if("appearance_flags")
				value = appearance.appearance_flags
			if("blend_mode")
				value = appearance.blend_mode
			if("color")
				value = appearance.color
			if("desc")
				value = appearance.desc
			if("gender")
				value = appearance.gender
			if("icon")
				value = appearance.icon
			if("icon_state")
				value = appearance.icon_state
			if("invisibility")
				value = appearance.invisibility
			if("infra_luminosity")
				value = atom_appearance.infra_luminosity
			if("filters")
				value = appearance.filters
			if("layer")
				value = appearance.layer
			if("luminosity")
				value = appearance.luminosity
			if("maptext")
				value = appearance.maptext
			if("maptext_width")
				value = appearance.maptext_width
			if("maptext_height")
				value = appearance.maptext_height
			if("maptext_x")
				value = appearance.maptext_x
			if("maptext_y")
				value = appearance.maptext_y
			if("mouse_over_pointer")
				value = appearance.mouse_over_pointer
			if("mouse_drag_pointer")
				value = appearance.mouse_drag_pointer
			if("mouse_drop_pointer")
				value = appearance.mouse_drop_pointer
			if("mouse_drop_zone")
				value = appearance.mouse_drop_zone
			if("mouse_opacity")
				value = appearance.mouse_opacity
			if("name")
				value = appearance.name
			if("opacity")
				value = appearance.opacity
			if("overlays")
				value = appearance.overlays
			if("override")
				value = appearance.override
			if("pixel_x")
				value = appearance.pixel_x
			if("pixel_y")
				value = appearance.pixel_y
			if("pixel_w")
				value = appearance.pixel_w
			if("pixel_z")
				value = appearance.pixel_z
			if("plane")
				value = appearance.plane
			if("render_source")
				value = appearance.render_source
			if("render_target")
				value = appearance.render_target
			if("suffix")
				value = appearance.suffix
			if("text")
				value = appearance.text
			if("transform")
				value = appearance.transform
			if("underlays")
				value = appearance.underlays


			// These are not undocumented ones but maybe it's trackable values
			if("animate_movement")
				value = atom_appearance.animate_movement
			if("cooldowns")
				value = atom_appearance.cooldowns
			if("datum_components")
				value = atom_appearance.datum_components
			if("datum_flags")
				value = atom_appearance.datum_flags
			if("density")
				value = atom_appearance.density

			if("dir")
				value = atom_appearance.dir

			if("gc_destroyed")
				value = atom_appearance.gc_destroyed
			if("glide_size")
				value = atom_appearance.glide_size

			if("pixel_step_size")
				value = "" //atom_appearance.pixel_step_size
				// DM compiler complains this

			// we wouldn't need these, but let's trackable anyway...
			if("screen_loc")
				value = atom_appearance.screen_loc
			if("sorted_verbs")
				value = atom_appearance.sorted_verbs
			if("tag")
				value = atom_appearance.tag
			if("tgui_shared_states")
				value = atom_appearance.tgui_shared_states
			if("verbs")
				value = atom_appearance.verbs
			if("weak_reference")
				value = atom_appearance.weak_reference
			if("cached_ref")
				value = appearance.cached_ref

			/// These variables are only available in some conditions.
			if("contents")
				value = atom_appearance.contents
			if("vis_contents")
				value = atom_appearance.vis_contents
			if("loc")
				value = atom_appearance.loc
			if("locs")
				value = atom_appearance.locs
			if("x")
				value = atom_appearance.x
			if("y")
				value = atom_appearance.y
			if("z")
				value = atom_appearance.z

			else
				return "<li style='backgroundColor:white'>(STATIC) [var_name] <font color='blue'>(Undefined var name in switch)</font></li>"
	catch
		return "<li style='backgroundColor:white'>(STATIC) <font color='blue'>[var_name] = (untrackable)</font></li>"
	return "<li style='backgroundColor:white'>(STATIC) [var_name] = [_debug_variable_value(var_name, value, 0, appearance, sanitize = TRUE, display_flags = NONE)]</li>"

/proc/vv_get_header_appearance(image/thing)
	. = list()
	. += "<b>[length(thing.icon) ? thing.icon || "null" : "(icon exists, but name is null)"]</b><br/>"
	if(thing.icon)
		. += thing.icon_state ? "\"[thing.icon_state]\"" : "(icon_state = null)"

/proc/get_appearance_vv_summary_name(image/thing)
	var/icon_file_name = thing.icon ? splittext("[thing.icon]", "/") : "null"
	if(islist(icon_file_name))
		icon_file_name = length(icon_file_name) ? icon_file_name[length(icon_file_name)] : "(null??)" // thing.icon exists but it's null????
	if(thing.icon_state)
		return "[icon_file_name]:[thing.icon_state]"
	else
		return "[icon_file_name]"
