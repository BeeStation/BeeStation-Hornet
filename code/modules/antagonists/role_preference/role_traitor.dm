#define TRAITOR_DESC "An unpaid debt. A score to be settled. Maybe you were just in the wrong \
	place at the wrong time. Whatever the reasons, you were selected to \
	infiltrate Space Station 13. Start with a set of sinister objectives and an uplink to purchase \
	items to get the job done."

/datum/role_preference/antagonist/traitor
	name = "Traitor"
	description = TRAITOR_DESC
	role_key = ROLE_TRAITOR
	gamemode = /datum/game_mode/traitor

/datum/role_preference/midround_living/traitor
	name = "Traitor (Sleeper Agent)"
	description = TRAITOR_DESC
	role_key = ROLE_TRAITOR

#undef TRAITOR_DESC
