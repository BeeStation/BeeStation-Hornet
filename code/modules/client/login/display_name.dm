/// Gets the key of this user, or their external display name.
/// Make sure you differentiate display names from BYOND keys by using client.external_method as a tag
/client/proc/display_name()
	if(src.key_is_external && istype(src.external_method))
		return src.external_method.format_display_name(src.external_display_name)
	return src.key

/// Gets the key of this user, or their external display name.
/// Includes a span suitable for use in chat to differentiate external methods.
/client/proc/display_name_chat()
	if(src.key_is_external && istype(src.external_method))
		return "<span class='chat16x16 badge-badge_[src.external_method.get_badge_id()]' style='vertical-align: -3px;'></span> [src.external_method.format_display_name(src.external_display_name)]"
	return src.key

/// Returns "key (@display_name)" (both)
/datum/mind/proc/full_key()
	return "[key][!isnull(display_name) && display_name != key ? " ([display_name])" : ""]"

/// Returns key or @display_name (exclusive)
/datum/mind/proc/display_key()
	return !isnull(display_name) ? display_name : key

/// Returns key or (span icon) @display_name (exclusive)
/datum/mind/proc/display_key_chat()
	return !isnull(display_name_chat) ? display_name_chat : key
