
// CENTCOM

/area/centcom
	name = "CentCom"
	icon_state = "centcom"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	teleport_restriction = TELEPORT_ALLOW_NONE
	blob_allowed = FALSE //Should go without saying, no blobs should take over centcom as a win condition.
	flags_1 = NONE

/area/centcom/control
	name = "CentCom Docks"

/area/centcom/evac
	name = "CentCom Recovery Ship"

/area/centcom/supply
	name = "CentCom Supply Shuttle Dock"

/area/centcom/ferry
	name = "CentCom Transport Shuttle Dock"

/area/centcom/prison
	name = "Admin Prison"

/area/centcom/holding
	name = "Holding Facility"

/area/centcom/supplypod/supplypod_temp_holding
	name = "Supplypod Shipping lane"
	icon_state = "supplypod_flight"

/area/centcom/supplypod
	name = "Supplypod Facility"
	icon_state = "supplypod"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/centcom/supplypod/podStorage
	name = "Supplypod Storage"
	icon_state = "supplypod_holding"

/area/centcom/supplypod/loading
	name = "Supplypod Loading Facility"
	icon_state = "supplypod_loading"
	var/loading_id = ""

/area/centcom/supplypod/loading/Initialize()
	. = ..() 
	if(!loading_id)
		CRASH("[type] created without a loading_id")
	if(GLOB.supplypod_loading_bays[loading_id])
		CRASH("Duplicate loading bay area: [type] ([loading_id])")
	GLOB.supplypod_loading_bays[loading_id] = src

/area/centcom/supplypod/loading/one
	name = "Bay #1"
	loading_id = "1"

/area/centcom/supplypod/loading/two
	name = "Bay #2"
	loading_id = "2"

/area/centcom/supplypod/loading/three
	name = "Bay #3"
	loading_id = "3"

/area/centcom/supplypod/loading/four
	name = "Bay #4"
	loading_id = "4"

/area/centcom/supplypod/loading/ert
	name = "ERT Bay"
	loading_id = "5"
//THUNDERDOME

/area/tdome
	name = "Thunderdome"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE

/area/tdome/arena
	name = "Thunderdome Arena"
	icon_state = "thunder"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/tdome/arena_source
	name = "Thunderdome Arena Template"
	icon_state = "thunder"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "green"

/area/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"


//ENEMY

//Wizard
/area/wizard_station
	name = "Wizard's Den"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	teleport_restriction = TELEPORT_ALLOW_NONE
	flags_1 = NONE

//Abductors
/area/abductor_ship
	name = "Abductor Ship"
	icon_state = "yellow"
	requires_power = FALSE
	teleport_restriction = TELEPORT_ALLOW_ABDUCTORS
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE

//Syndicates
/area/syndicate_mothership
	name = "Syndicate Mothership"
	icon_state = "syndie-ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	teleport_restriction = TELEPORT_ALLOW_NONE
	blob_allowed = FALSE //Not... entirely sure this will ever come up... but if the bus makes blobs AND ops, it shouldn't aim for the ops to win.
	flags_1 = NONE
	ambient_effects = HIGHSEC

/area/syndicate_mothership/control
	name = "Syndicate Control Room"
	icon_state = "syndie-control"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/syndicate_mothership/elite_squad
	name = "Syndicate Elite Squad"
	icon_state = "syndie-elite"

//CAPTURE THE FLAG

/area/ctf
	name = "Capture the Flag"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY

/area/ctf/control_room
	name = "Control Room A"

/area/ctf/control_room2
	name = "Control Room B"

/area/ctf/central
	name = "Central"

/area/ctf/main_hall
	name = "Main Hall A"

/area/ctf/main_hall2
	name = "Main Hall B"

/area/ctf/corridor
	name = "Corridor A"

/area/ctf/corridor2
	name = "Corridor B"

/area/ctf/flag_room
	name = "Flag Room A"

/area/ctf/flag_room2
	name = "Flag Room B"

// REEBE

/area/reebe
	name = "Reebe"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	teleport_restriction = TELEPORT_ALLOW_CLOCKWORK
	hidden = TRUE
	ambient_effects = REEBE

/area/reebe/city_of_cogs
	name = "Reebe - City of Cogs"
	icon_state = "purple"
	hidden = FALSE
	var/playing_ambience = FALSE
