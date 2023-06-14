#define OPERATIVE_DESC "Congratulations, agent. You have been chosen to join the Syndicate \
	Nuclear Operative strike team. Your mission, whether or not you choose \
	to accept it, is to destroy Nanotrasen's most advanced research facility! \
	That's right, you're going to Space Station 13. \
	Retrieve the nuclear authentication disk, use it to activate the nuclear \
	fission explosive, and destroy the station."

/datum/role_preference/antagonist/nuclear_operative
	name = "Nuclear Operative"
	description = OPERATIVE_DESC
	gamemode = /datum/game_mode/nuclear

/datum/role_preference/midround_ghost/nuclear_operative
	name = "Nuclear Operative (Assailant)"
	description = OPERATIVE_DESC
	role_key = ROLE_OPERATIVE

#undef OPERATIVE_DESC
