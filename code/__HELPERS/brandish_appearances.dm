/// World appearance policies and runtime greyscale recipe integration.
/atom
	/// Explicit geometry policy for non-turf artwork; null keeps native sprites.
	var/brandish_icon_mode

/turf/open/floor
	brandish_icon_mode = "surface"

/obj/effect/decal/cleanable
	brandish_icon_mode = "surface"

/datum/brandish_asset_registry/runtime
	var/list/greyscale_sources = list()
	var/list/fixed_surface_overlays = list()

/// State names encode their world connections; never inherit a machine's
/// sprite direction. Return a copy so per-device colors/layers remain local.
/datum/brandish_asset_registry/runtime/proc/world_surface_appearance(resource, state, tint = null, layer = FLOAT_LAYER)
	if(!supports(resource, "surface"))
		return mutable_appearance(resource, state, layer, color = tint)
	var/image/appearance = image(icon = icon_for(resource, "surface", NORTH) || resource, icon_state = state, dir = NORTH, layer = layer)
	appearance.color = tint
	return appearance

/// Topology masks (e.g. smart pipes) use dir as a connection bitfield.
/// A shared explicit-direction overlay keeps that gameplay value untouched.
/datum/brandish_asset_registry/runtime/proc/fixed_surface_overlay(resource, state)
	if(!enabled)
		return null
	var/key = "[resource]|[state]"
	if(fixed_surface_overlays[key])
		return fixed_surface_overlays[key]
	var/bank = icon_for(resource, "surface", NORTH)
	if(!bank || bank == resource)
		return null
	var/image/appearance = image(icon = bank, icon_state = state, dir = NORTH, layer = FLOAT_LAYER)
	fixed_surface_overlays[key] = appearance
	return appearance

/datum/brandish_asset_registry/runtime/icon_for(source, kind, direction, prefix)
	if(!enabled)
		return source_for(source)
	var/list/recipe = greyscale_sources[source]
	if(recipe)
		return SSgreyscale.GetColoredGeometryIcon(recipe[1], recipe[2], kind, direction, prefix)
	return ..()

/datum/brandish_asset_registry/runtime/source_for(resource)
	var/list/recipe = greyscale_sources[resource]
	if(recipe)
		return SSgreyscale.GetColoredIconByType(recipe[1], recipe[2])
	return ..()

/datum/brandish_asset_registry/runtime/proc/register_greyscale(resource, config, colors)
	prepare()
	var/datum/greyscale_config/recipe = SSgreyscale.configurations["[config]"]
	var/list/entry = aliases[recipe.icon_file]
	if(!entry || (!entry["surface"] && !entry["smooth"] && !entry["corner"]))
		return
	greyscale_sources[resource] = list(config, colors)

/// Shared policy for standalone world appearances (underlays/vis overlays).
/// Explicit smoothing states take precedence over flat ground textures.
/datum/brandish_asset_registry/runtime/proc/appearance_icon(resource, state, direction)
	prepare()
	if(!enabled)
		return source_for(resource)
	var/list/entry = aliases[resource]
	if(!entry)
		return resource
	for(var/prefix in entry["prefixes"])
		if(findtext(state, "[prefix]-") == 1)
			return icon_for(resource, "smooth", direction, prefix) || resource
	if(entry["corner"] && (findtext(state, "d-") == 1 || (length(state) > 2 && copytext(state, 2, 3) == "-")))
		return icon_for(resource, "corner", direction) || resource
	return icon_for(resource, "surface", direction) || resource

/// A shared native-direction overlay, selected by the renderer per viewer.
/datum/brandish_asset_registry/runtime/proc/foreground_for(resource, state, layer)
	prepare()
	if(!enabled)
		return null
	var/list/entry = aliases[resource]
	if(entry?["foreground"])
		return mutable_appearance(entry["foreground"], state, layer)
