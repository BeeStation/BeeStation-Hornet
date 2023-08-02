/datum/role_preference
	var/name
	/// What heading to display this entry under in the preferences menu. Use ROLE_PREFERENCE_CATEGORY defines.
	var/category
	/// The Antagonist datum typepath for this entry, if there is one. Used to get data about the role for display (bans etc)
	var/datum/antagonist/antag_datum
	/// The base abstract path for this subtype.
	var/abstract_type = /datum/role_preference
	/// If this preference can vary between characters.
	var/per_character = FALSE

/// Includes latejoin and roundstart antagonists
/datum/role_preference/antagonist
	category = ROLE_PREFERENCE_CATEGORY_ANAGONIST
	abstract_type = /datum/role_preference/antagonist
	per_character = TRUE

/// Includes autotraitor and gamemode midround assignments - being forced into an antagonist during a round (does not apply to conversion antags).
/datum/role_preference/midround_living
	category = ROLE_PREFERENCE_CATEGORY_MIDROUND_LIVING
	abstract_type = /datum/role_preference/midround_living
	per_character = TRUE

/// Includes anything polled from ghosts that does antagonist stuff
/datum/role_preference/midround_ghost
	category = ROLE_PREFERENCE_CATEGORY_MIDROUND_GHOST
	abstract_type = /datum/role_preference/midround_ghost
