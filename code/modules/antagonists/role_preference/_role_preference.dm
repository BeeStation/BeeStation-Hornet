/datum/role_preference
	var/name
	/// What heading to display this entry under in the preferences menu. Use ROLE_PREFERENCE_CATEGORY defines.
	var/category
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

/// Includes anything polled from ghosts that does antagonist stuff
/datum/role_preference/midround_ghost
	category = ROLE_PREFERENCE_CATEGORY_MIDROUND_GHOST
	abstract_type = /datum/role_preference/midround_ghost

/// Ghost roles that are non antagonists
/datum/role_preference/ghost_role
	category = ROLE_PREFERENCE_CATEGORY_GHOST_ROLES
	abstract_type = /datum/role_preference/ghost_role
