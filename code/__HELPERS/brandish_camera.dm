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
	/// Cached server policy; hot atom paths must not resolve config datums.
	var/enabled = TRUE

/datum/brandish_asset_registry/proc/prepare()
	if(aliases)
		return
	aliases = list()
	for(var/list/entry as anything in brandish_prebuilt_icons())
		aliases[entry["source"]] = entry
		for(var/kind in list("surface", "smooth", "corner"))
			var/list/banks = entry[kind]
			for(var/direction in banks)
				aliases[banks[direction]] = entry
	if(!length(aliases))
		enabled = FALSE

/datum/brandish_asset_registry/proc/configure(allow)
	enabled = allow && has_catalog()

/datum/brandish_asset_registry/proc/icon_for(source, kind, direction, prefix)
	prepare()
	var/list/entry = aliases[source]
	if(!entry || !enabled)
		return entry ? entry["source"] : source
	var/list/banks = entry[kind]
	if(kind == "smooth")
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

/// Recover the logical resource for serializers, recipes and reattachments.
/datum/brandish_asset_registry/proc/source_for(resource)
	prepare()
	var/list/entry = aliases[resource]
	return entry ? entry["source"] : resource

/// Move a known sprite-origin correction to screen coordinates. Call once at
/// initialization; any additional map placement remains in world pixel_x/y.
/atom/proc/brandish_screen_origin(offset_x, offset_y)
	pixel_x -= offset_x
	pixel_y -= offset_y
	pixel_w += offset_x
	pixel_z += offset_y
