/datum/role_preference
	var/name
	/// A brief description of this role, to display in the preferences menu.
	var/description
	/// The ROLE_X define for this preference. Optional, but must have a poll_ignore_key otherwise.
	var/role_key
	/// The main gamemode that spawns this ROLE_X roundstart.
	/// This is used to get exp_living requirements by the prefs menu.
	/// TODO tgui-prefs replace this
	var/gamemode
	/// The POLL_IGNORE_X define for this preference. Optional, but must have a role_key otherwise.
	var/poll_ignore_key
	/// What heading to display this entry under in the preferences menu. Use ROLE_PREFERENCE_CATEGORY defines.
	var/category
	/// If this preference is enabled by default. This should be true for ghost polled antagonists,
	/// but disabled for roundstart, latejoin, or midround assigned antagonists.
	var/enabled_by_default = FALSE
	/// The base abstract path for this subtype.
	var/abstract_type = /datum/role_preference

/// Includes latejoin and roundstart antagonists
/datum/role_preference/antagonist
	category = ROLE_PREFERENCE_CATEGORY_ANAGONIST
	abstract_type = /datum/role_preference/antagonist

/// Includes autotraitor and gamemode midround assignments - being forced into an antagonist during a round (does not apply to conversion antags).
/datum/role_preference/midround_living
	category = ROLE_PREFERENCE_CATEGORY_MIDROUND_LIVING
	abstract_type = /datum/role_preference/midround_living

/// Includes anything polled from ghosts.
/datum/role_preference/midround_ghost
	category = ROLE_PREFERENCE_CATEGORY_MIDROUND_GHOST
	abstract_type = /datum/role_preference/midround_ghost
	enabled_by_default = TRUE
