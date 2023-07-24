//Command boards


/obj/item/circuitboard/computer/aiupload
	name = "AI upload (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/upload/ai

/obj/item/circuitboard/computer/borgupload
	name = "cyborg upload (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/upload/borg

/obj/item/circuitboard/computer/bsa_control
	name = "bluespace artillery controls (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/bsa_control

/obj/item/circuitboard/computer/card
	name = "ID console (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/card

/obj/item/circuitboard/computer/card/centcom
	name = "CentCom ID console (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/computer/card/minor
	name = "department management console (Computer Board)"
	icon_state = "command"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = 1
	var/list/dept_list = list("General","Security","Medical","Science","Engineering")

/obj/item/circuitboard/computer/card/minor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		target_dept = (target_dept == dept_list.len) ? 1 : (target_dept + 1)
		to_chat(user, "<span class='notice'>You set the board to \"[dept_list[target_dept]]\".</span>")
	else
		return ..()

/obj/item/circuitboard/computer/card/minor/examine(user)
	. = ..()
	. += "Currently set to \"[dept_list[target_dept]]\"."

/obj/item/circuitboard/computer/communications
	name = "communications console (Computer Board)"
	icon_state = "command"
	desc = "Can be modified using a screwdriver."
	build_path = /obj/machinery/computer/communications
	var/insecure = FALSE // Forbids shuttles that are set as illegal.

/obj/item/circuitboard/computer/communications/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		insecure = !insecure
		if(insecure)
			desc = "Tampering has removed some safety features from this circuit board. A screwdriver can undo this."
			to_chat(user, "<span class='notice'>You disable the shuttle safety features of the board.</span>")
		else
			desc = "Can be modified using a screwdriver."
			to_chat(user, "<span class='notice'>You re-enable the shuttle safety features of the board.</span>")
	else
		return ..()

//obj/item/circuitboard/computer/shield
//	name = "Shield Control (Computer Board)"
//	build_path = /obj/machinery/computer/stationshield


//Engineering


/obj/item/circuitboard/computer/apc_control
	name = "power flow control console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/apc_control

/obj/item/circuitboard/computer/atmos_alert
	name = "atmospheric alert console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/computer/atmos_control
	name = "atmospheric monitor console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_control

/obj/item/circuitboard/computer/atmos_control/tank
	name = "tank control console (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank

/obj/item/circuitboard/computer/atmos_control/tank/oxygen_tank
	name = "oxygen supply control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/oxygen_tank

/obj/item/circuitboard/computer/atmos_control/tank/plasma_tank
	name = "plasma supply control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/plasma_tank

/obj/item/circuitboard/computer/atmos_control/tank/air_tank
	name = "mixed air supply control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/air_tank

/obj/item/circuitboard/computer/atmos_control/tank/mix_tank
	name = "gas mix supply control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/mix_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitrous_tank
	name = "nitrous oxide supply control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitrous_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitrogen_tank
	name = "nitrogen supply control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitrogen_tank

/obj/item/circuitboard/computer/atmos_control/tank/carbon_tank
	name = "carbon dioxide supply control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/carbon_tank

/obj/item/circuitboard/computer/atmos_control/tank/incinerator
	name = "incinerator air control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/incinerator

/obj/item/circuitboard/computer/atmos_control/tank/sm_waste
	name = "supermatter waste control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/sm_waste

/obj/item/circuitboard/computer/atmos_control/tank/toxins_waste
	name = "toxins waste control (Computer Board)"
	build_path = /obj/machinery/computer/atmos_control/tank/toxins_waste_tank

/obj/item/circuitboard/computer/auxillary_base
	name = "auxillary base management console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/auxillary_base

/obj/item/circuitboard/computer/base_construction
	name = "aux mining base construction console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/camera_advanced/base_construction

/obj/item/circuitboard/computer/comm_monitor
	name = "telecommunications monitor (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/monitor

/obj/item/circuitboard/computer/comm_server
	name = "telecommunications server monitor (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/server

/obj/item/circuitboard/computer/message_monitor
	name = "message monitor (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/message_monitor

/obj/item/circuitboard/computer/powermonitor
	name = "power monitor (Computer Board)"  //name fixed 250810
	icon_state = "engineering"
	build_path = /obj/machinery/computer/monitor

/obj/item/circuitboard/computer/powermonitor/secret
	name = "outdated power monitor (Computer Board)" //Variant used on ruins to prevent them from showing up on PDA's.
	build_path = /obj/machinery/computer/monitor/secret

/obj/item/circuitboard/computer/sat_control
	name = "satellite network control (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/sat_control

/obj/item/circuitboard/computer/solar_control
	name = "solar control (Computer Board)"  //name fixed 250810
	icon_state = "engineering"
	build_path = /obj/machinery/power/solar_control

/obj/item/circuitboard/computer/stationalert
	name = "station alerts console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/computer/teleporter
	name = "teleporter console (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/teleporter

/obj/item/circuitboard/computer/turbine_computer
	name = "turbine computer (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/turbine_control
	name = "turbine control (Computer Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer


//Generic


/obj/item/circuitboard/computer/advanced_camera
	name = "advanced camera console (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/camera_advanced/syndie

/obj/item/circuitboard/computer/advanced_camera/cyan
	name = "advanced camera console: cyan (Computer Board)"
	build_path = /obj/machinery/computer/camera_advanced/bounty_hunter

/obj/item/circuitboard/computer/advanced_camera/darkblue
	name = "advanced camera console: darkblue (Computer Board)"
	build_path = /obj/machinery/computer/camera_advanced/wizard

/obj/item/circuitboard/computer/arcade/amputation
	name = "Mediborg's Amputation Adventure (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/amputation

/obj/item/circuitboard/computer/arcade/battle
	name = "arcade battle (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/battle

/obj/item/circuitboard/computer/arcade/orion_trail
	name = "Orion Trail (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/orion_trail

/obj/item/circuitboard/computer/holodeck// Not going to let people get this, but it's just here for future
	name = "holodeck control (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/holodeck

/obj/item/circuitboard/computer/libraryconsole
	name = "library visitor console (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/libraryconsole

/obj/item/circuitboard/computer/libraryconsole/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(build_path == /obj/machinery/computer/libraryconsole/bookmanagement)
			name = "Library Visitor Console (Computer Board)"
			build_path = /obj/machinery/computer/libraryconsole
			to_chat(user, "<span class='notice'>Defaulting access protocols.</span>")
		else
			name = "Book Inventory Management Console (Computer Board)"
			build_path = /obj/machinery/computer/libraryconsole/bookmanagement
			to_chat(user, "<span class='notice'>Access protocols successfully updated.</span>")
	else
		return ..()

/obj/item/circuitboard/computer/olddoor
	name = "DoorMex (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/computer/pod
	name = "mass driver launch control (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/computer/slot_machine
	name = "slot machine (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/slot_machine

/obj/item/circuitboard/computer/swfdoor
	name = "Magix (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old/swf

//Not inhereting the hackability from shuttle subtypes
/obj/item/circuitboard/computer/syndicate_shuttle
	name = "syndicate shuttle console (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/syndicate
	var/challenge = FALSE
	var/moved = FALSE

/obj/item/circuitboard/computer/syndicate_shuttle/Initialize(mapload)
	. = ..()
	GLOB.syndicate_shuttle_boards += src

/obj/item/circuitboard/computer/syndicate_shuttle/Destroy()
	GLOB.syndicate_shuttle_boards -= src
	return ..()

/obj/item/circuitboard/computer/syndicatedoor
	name = "ProComp Executive (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old/syndicate

//Medical

/obj/item/circuitboard/computer/cloning
	name = "cloning console (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/cloning
	var/list/records = list()

/obj/item/circuitboard/computer/crew
	name = "crew monitoring console (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/crew

/obj/item/circuitboard/computer/med_data
	name = "medical records console (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/med_data

/obj/item/circuitboard/computer/operating
	name = "operating computer (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/operating

/obj/item/circuitboard/computer/pandemic
	name = "PanD.E.M.I.C. 2200 (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/pandemic

/obj/item/circuitboard/computer/cloning/prototype
	name = "prototype cloning console (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/cloning/prototype

/obj/item/circuitboard/computer/scan_consolenew
	name = "DNA machine (Computer Board)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/scan_consolenew


//Science


/obj/item/circuitboard/computer/aifixer
	name = "AI integrity restorer console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/aifixer

/obj/item/circuitboard/computer/launchpad_console
	name = "launchpad control console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/launchpad

/obj/item/circuitboard/computer/mech_bay_power_console
	name = "mech bay power control console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/mech_bay_power_console

/obj/item/circuitboard/computer/mecha_control
	name = "exosuit control console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/computer/nanite_chamber_control
	name = "nanite chamber control (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/nanite_chamber_control

/obj/item/circuitboard/computer/nanite_cloud_controller
	name = "nanite cloud control (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/nanite_cloud_controller

/obj/item/circuitboard/computer/rdconsole
	name = "R&D console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/rdconsole/core

/obj/item/circuitboard/computer/rdconsole/production
	name = "R&D console - production only (Computer Board)"
	build_path = /obj/machinery/computer/rdconsole/production

/obj/item/circuitboard/computer/rdconsole/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(build_path == /obj/machinery/computer/rdconsole/core)
			name = "R&D Console - Robotics (Computer Board)"
			build_path = /obj/machinery/computer/rdconsole/robotics
			to_chat(user, "<span class='notice'>Access protocols successfully updated.</span>")
		else
			name = "R&D Console (Computer Board)"
			build_path = /obj/machinery/computer/rdconsole/core
			to_chat(user, "<span class='notice'>Defaulting access protocols.</span>")
	else
		return ..()

/obj/item/circuitboard/computer/rdservercontrol
	name = "R&D server control (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/computer/research
	name = "research monitor (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/security/research

/obj/item/circuitboard/computer/robotics
	name = "robotics control (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/robotics

/obj/item/circuitboard/computer/xenobiology
	name = "xenobiology console (Computer Board)"
	icon_state = "science"
	build_path = /obj/machinery/computer/camera_advanced/xenobio


//Security

/obj/item/circuitboard/computer/gulag_teleporter_console
	name = "labor camp teleporter console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner/gulag_teleporter_computer

/obj/item/circuitboard/computer/prisoner
	name = "prisoner management console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner

/obj/item/circuitboard/computer/secure_data
	name = "security records console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/secure_data

/obj/item/circuitboard/computer/security
	name = "security camera console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/security

/obj/item/circuitboard/computer/warrant
	name = "security warrant console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/warrant

//Service


//Supply

/obj/item/circuitboard/computer/objective
	name = "Nanotrasen objective console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/objective

/obj/item/circuitboard/computer/bounty
	name = "Nanotrasen bounty console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/bounty

/obj/item/circuitboard/computer/cargo
	name = "supply console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo
	var/contraband = FALSE

/obj/item/circuitboard/computer/cargo/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = !contraband
		to_chat(user, "<span class='notice'>Receiver spectrum set to [contraband ? "Broad" : "Standard"].</span>")
	else
		to_chat(user, "<span class='notice'>The spectrum chip is unresponsive.</span>")

/obj/item/circuitboard/computer/cargo/on_emag(mob/user)
	..()
	contraband = TRUE
	to_chat(user, "<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

/obj/item/circuitboard/computer/cargo/express
	name = "express supply console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo/express

/obj/item/circuitboard/computer/cargo/express/multitool_act(mob/living/user)
	if (!(obj_flags & EMAGGED))
		to_chat(user, "<span class='notice'>Routing protocols are already set to: \"factory defaults\".</span>")
	else
		to_chat(user, "<span class='notice'>You reset the routing protocols to: \"factory defaults\".</span>")
		obj_flags &= ~EMAGGED

/obj/item/circuitboard/computer/cargo/express/on_emag(mob/user)
	..()
	to_chat(user, "<span class='notice'>You change the routing protocols, allowing the Drop Pod to land anywhere on the station.</span>")

/obj/item/circuitboard/computer/cargo/request
	name = "supply request console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo/request

/obj/item/circuitboard/computer/mining
	name = "outpost status display (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/security/mining

//Shuttles

/obj/item/circuitboard/computer/shuttle
	var/hacked = FALSE

/obj/item/circuitboard/computer/shuttle/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		hacked = !hacked
		if(hacked)
			to_chat(user, "<span class='notice'>You disable the circuitboard's ID scanning protocols.</span>")
		else
			to_chat(user, "<span class='notice'>You reset the circuitboard's ID scanning protocols.</span>")
		return
	. = ..()

/obj/item/circuitboard/computer/shuttle/white_ship
	name = "white ship control (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship

/obj/item/circuitboard/computer/shuttle/white_ship/pod
	name = "salvage pod control (Computer Board)"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship/pod

/obj/item/circuitboard/computer/shuttle/white_ship/pod/recall
	name = "salvage pod recall control (Computer Board)"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship/pod/recall

/obj/item/circuitboard/computer/shuttle/flight_control
	name = "shuttle flight control (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/custom_shuttle

/obj/item/circuitboard/computer/shuttle/labor_shuttle
	name = "labor shuttle console (Computer Board)"
	icon_state = "security"
	build_path = /obj/machinery/computer/shuttle_flight/labor

/obj/item/circuitboard/computer/shuttle/labor_shuttle/one_way
	name = "prisoner shuttle console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle_flight/labor/one_way

/obj/item/circuitboard/computer/ferry
	name = "transport ferry control (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle_flight/ferry

/obj/item/circuitboard/computer/ferry/request
	name = "transport ferry console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle_flight/ferry/request

/obj/item/circuitboard/computer/shuttle/mining_shuttle
	name = "mining shuttle console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle_flight/mining

/obj/item/circuitboard/computer/shuttle/science_shuttle
	name = "science shuttle console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle_flight/science

/obj/item/circuitboard/computer/shuttle/exploration_shuttle
	name = "exploration shuttle console (Computer Board)"
	build_path = /obj/machinery/computer/shuttle_flight/custom_shuttle/exploration

/obj/item/circuitboard/computer/shuttle/monastery_shuttle
	name = "monastery shuttle console (Computer Board)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/monastery_shuttle
