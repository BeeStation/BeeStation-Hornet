GLOBAL_DATUM_INIT(brandish_assets, /datum/brandish_asset_registry, new)

// Built-in directional resources generated before compilation. Every atom uses
// a shared file; no /icon construction or per-viewer correction is needed.
#ifndef BRANDISH_GENERATED_ICONS
/// Direct DM/editor builds need no generated files. Keep original artwork and
/// disable the directional camera until built through tools/build/build.
/proc/brandish_prebuilt_icons()
	return list()
#endif

/datum/brandish_asset_registry
	var/list/aliases
	var/list/greyscale_sources = list()
	var/list/fixed_surface_overlays = list()
	/// Catalog availability, cached for hot appearance paths.
	var/enabled = TRUE

/datum/brandish_asset_registry/proc/prepare()
	if(aliases)
		return
	aliases = list()
	for(var/list/entry as anything in brandish_prebuilt_icons())
		aliases[entry["source"]] = entry
		for(var/kind in list(BRANDISH_MODE_ROTATE, BRANDISH_MODE_SMOOTH, BRANDISH_MODE_CORNER))
			var/list/banks = entry[kind]
			for(var/direction in banks)
				aliases[banks[direction]] = entry
	if(!length(aliases))
		enabled = FALSE

/// Valid resources resolve to a shared bank or their logical original.
/datum/brandish_asset_registry/proc/icon_for(source, kind, direction, prefix, state)
	if(!enabled)
		return source_for(source)
	var/list/recipe = greyscale_sources[source]
	if(recipe)
		return SSgreyscale.GetColoredGeometryIcon(recipe[1], recipe[2], kind, direction, prefix)
	prepare()
	var/list/entry = aliases[source]
	if(!entry || !enabled)
		return entry ? entry["source"] : source
	// Compact banks contain only selected geometry. Upright states (and
	// callers without a known state) retain the original resource.
	if(kind == BRANDISH_MODE_ROTATE)
		var/list/surface_states = entry["surfaceStates"]
		if(surface_states && !surface_states[state])
			return entry["source"]
	var/list/banks = entry[kind]
	if(kind == BRANDISH_MODE_SMOOTH)
		var/list/prefixes = entry["prefixes"]
		if(!prefixes || !prefixes[prefix])
			return entry["source"]
	// Preserve non-cardinal/zero physical dirs by leaving their original art.
	return banks?["[direction]"] || entry["source"]

/// Resource families such as view gates/masks require an explicit branch
/// when absent; icon_for alone always preserves the caller's original art.
/datum/brandish_asset_registry/proc/supports(resource, kind)
	prepare()
	var/list/entry = aliases[resource]
	return enabled && !!entry?[kind]

/datum/brandish_asset_registry/proc/has_catalog()
	prepare()
	return length(aliases) > 0

/// Availability flag without exposing registry storage to initialization callers.
/datum/brandish_asset_registry/proc/is_enabled()
	return enabled

/// Optional shared resource family; null means the caller keeps its native art.
/datum/brandish_asset_registry/proc/asset_for(resource, kind)
	prepare()
	var/list/entry = aliases[resource]
	return enabled ? entry?[kind] : null

/// Optional directional art, with the same original-resource fallback as icon_for.
/datum/brandish_asset_registry/proc/optional_icon(resource, kind, direction)
	prepare()
	var/list/entry = aliases[resource]
	if(!enabled || !entry?[kind])
		return null
	return icon_for(resource, kind, direction)

/// Recover the logical resource for serializers, recipes and reattachments.
/datum/brandish_asset_registry/proc/source_for(resource)
	var/list/recipe = greyscale_sources[resource]
	if(recipe)
		return SSgreyscale.GetColoredIconByType(recipe[1], recipe[2])
	prepare()
	var/list/entry = aliases[resource]
	return entry ? entry["source"] : resource


/// State names encode their world connections; never inherit a machine's
/// sprite direction. Return a copy so per-device colors/layers remain local.
/datum/brandish_asset_registry/proc/world_surface_appearance(resource, state, tint = null, layer = FLOAT_LAYER)
	if(!supports(resource, BRANDISH_MODE_ROTATE))
		return mutable_appearance(resource, state, layer, color = tint)
	var/image/appearance = image(icon = icon_for(resource, BRANDISH_MODE_ROTATE, NORTH, state = state), icon_state = state, dir = NORTH, layer = layer)
	appearance.color = tint
	return appearance

/// Topology masks (e.g. smart pipes) use dir as a connection bitfield.
/// A shared explicit-direction overlay keeps that gameplay value untouched.
/datum/brandish_asset_registry/proc/fixed_surface_overlay(resource, state)
	if(!enabled)
		return null
	var/key = "[resource]|[state]"
	if(fixed_surface_overlays[key])
		return fixed_surface_overlays[key]
	var/bank = icon_for(resource, BRANDISH_MODE_ROTATE, NORTH, state = state)
	if(!bank || bank == resource)
		return null
	var/image/appearance = image(icon = bank, icon_state = state, dir = NORTH, layer = FLOAT_LAYER)
	fixed_surface_overlays[key] = appearance
	return appearance

/datum/brandish_asset_registry/proc/register_greyscale(resource, config, colors)
	prepare()
	var/datum/greyscale_config/recipe = SSgreyscale.configurations["[config]"]
	var/list/entry = aliases[recipe.icon_file]
	if(!entry || (!entry[BRANDISH_MODE_ROTATE] && !entry[BRANDISH_MODE_SMOOTH] && !entry[BRANDISH_MODE_CORNER]))
		return
	greyscale_sources[resource] = list(config, colors)

/// Shared policy for standalone world appearances (underlays/vis overlays).
/// Explicit smoothing states take precedence over flat ground textures.
/datum/brandish_asset_registry/proc/appearance_icon(resource, state, direction)
	prepare()
	if(!enabled)
		return source_for(resource)
	var/list/entry = aliases[resource]
	if(!entry)
		return resource
	for(var/prefix in entry["prefixes"])
		if(findtext(state, "[prefix]-") == 1)
			return icon_for(resource, BRANDISH_MODE_SMOOTH, direction, prefix)
	if(entry[BRANDISH_MODE_CORNER] && BRANDISH_IS_CORNER_STATE(state))
		return icon_for(resource, BRANDISH_MODE_CORNER, direction)
	return icon_for(resource, BRANDISH_MODE_ROTATE, direction, state = state)

/// A shared native-direction overlay, selected by the renderer per viewer.
/datum/brandish_asset_registry/proc/foreground_for(resource, state, layer)
	prepare()
	if(!enabled)
		return null
	var/list/entry = aliases[resource]
	if(entry?[BRANDISH_ASSET_FOREGROUND])
		return mutable_appearance(entry[BRANDISH_ASSET_FOREGROUND], state, layer)

