/datum/screentip_cache
	/// Lazy assoc list, type => screen tip cache
	/// If we have a parent screentip that changes depending on
	/// the mob type, then we look it up in here
	var/list/cache_states = null
	var/attack_hand
	var/message
	var/tool_message
	var/generated = TRUE
