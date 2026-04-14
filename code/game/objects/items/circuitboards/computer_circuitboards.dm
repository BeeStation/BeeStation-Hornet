/obj/item/circuitboard/computer
	abstract_type = /obj/item/circuitboard/computer
	name_extension = "(Computer Board)"

//Command boards

/obj/item/circuitboard/computer/aiupload
	name = "AI Upload"
	icon_state = "command"
	build_path = /obj/machinery/computer/upload/ai

/obj/item/circuitboard/computer/borgupload
	name = "Cyborg Upload"
	icon_state = "command"
	build_path = /obj/machinery/computer/upload/borg

/obj/item/circuitboard/computer/bsa_control
	name = "Bluespace Artillery Controls"
	icon_state = "command"
	build_path = /obj/machinery/computer/bsa_control

/obj/item/circuitboard/computer/card
	name = "ID Console"
	icon_state = "command"
	build_path = /obj/machinery/computer/card

/obj/item/circuitboard/computer/card/centcom
	name = "CentCom ID Console"
	icon_state = "command"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/computer/card/minor
	name = "Department Management Console"
	icon_state = "command"
	build_path = /obj/machinery/computer/card/minor
	var/counting = 1
	var/list/dept_list = list(
		NONE, // This means ALL department - don't be scared.
		DEPT_BITFLAG_SEC,
		DEPT_BITFLAG_MED,
		DEPT_BITFLAG_SCI,
		DEPT_BITFLAG_ENG)
	var/list/dept_list_name = list(
		"General",
		"Security",
		"Medical",
		"Science",
		"Engineering")

/obj/item/circuitboard/computer/card/minor/screwdriver_act(mob/living/user, obj/item/tool)
	counting = (counting == length(dept_list)) ? 1 : (counting + 1)
	to_chat(user, span_notice("You set the board to \"[dept_list_name[counting]]\"."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/computer/card/minor/examine(user)
	. = ..()
	. += span_info("Currently set to \"[dept_list[counting]]\".")

/obj/item/circuitboard/computer/communications
	name = "Communications Console"
	icon_state = "command"
	desc = "Can be modified using a screwdriver."
	build_path = /obj/machinery/computer/communications
	var/insecure = FALSE // Forbids shuttles that are set as illegal.

/obj/item/circuitboard/computer/communications/screwdriver_act(mob/living/user, obj/item/tool)
	insecure = !insecure
	if(insecure)
		desc = "Tampering has removed some safety features from this circuit board. A screwdriver can undo this."
		to_chat(user, span_notice("You disable the shuttle safety features of the board."))
	else
		desc = "Can be modified using a screwdriver."
		to_chat(user, span_notice("You re-enable the shuttle safety features of the board."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

//Engineering

/obj/item/circuitboard/computer/apc_control
	name = "Power Flow Control Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/apc_control

/obj/item/circuitboard/computer/atmos_alert
	name = "Atmospheric Alert Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/computer/atmos_control
	name = "Atmospheric Control"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_control

/obj/item/circuitboard/computer/atmos_control/nocontrol
	name = "Atmospheric Monitor"
	build_path = /obj/machinery/computer/atmos_control/nocontrol

/obj/item/circuitboard/computer/atmos_control/noreconnect
	name = "Atmospheric Control"
	build_path = /obj/machinery/computer/atmos_control/noreconnect

/obj/item/circuitboard/computer/atmos_control/fixed
	name = "Atmospheric Monitor"
	build_path = /obj/machinery/computer/atmos_control/fixed

/obj/item/circuitboard/computer/atmos_control/nocontrol/master
	name = "Station Atmospheric Monitor"
	build_path = /obj/machinery/computer/atmos_control/nocontrol/master

/obj/item/circuitboard/computer/atmos_control/nocontrol/incinerator
	name = "Incinerator Chamber Monitor"
	build_path = /obj/machinery/computer/atmos_control/nocontrol/incinerator

/obj/item/circuitboard/computer/atmos_control/toxinsmix
	name = "Toxins Chamber Monitor"
	build_path = /obj/machinery/computer/atmos_control/toxinsmix

/obj/item/circuitboard/computer/atmos_control/oxygen_tank
	name = "Oxygen Supply Control"
	build_path = /obj/machinery/computer/atmos_control/oxygen_tank

/obj/item/circuitboard/computer/atmos_control/plasma_tank
	name = "Plasma Supply Control"
	build_path = /obj/machinery/computer/atmos_control/plasma_tank

/obj/item/circuitboard/computer/atmos_control/air_tank
	name = "Mixed Air Supply Control"
	build_path = /obj/machinery/computer/atmos_control/air_tank

/obj/item/circuitboard/computer/atmos_control/mix_tank
	name = "Gas Mix Supply Control"
	build_path = /obj/machinery/computer/atmos_control/mix_tank

/obj/item/circuitboard/computer/atmos_control/nitrous_tank
	name = "Nitrous Oxide Supply Control"
	build_path = /obj/machinery/computer/atmos_control/nitrous_tank

/obj/item/circuitboard/computer/atmos_control/nitrogen_tank
	name = "Nitrogen Supply Control"
	build_path = /obj/machinery/computer/atmos_control/nitrogen_tank

/obj/item/circuitboard/computer/atmos_control/carbon_tank
	name = "Carbon Dioxide Supply Control"
	build_path = /obj/machinery/computer/atmos_control/carbon_tank

/obj/item/circuitboard/computer/atmos_control/bz_tank
	name = "BZ Supply Control"
	build_path = /obj/machinery/computer/atmos_control/bz_tank

/obj/item/circuitboard/computer/atmos_control/hypernoblium_tank
	name = "Hypernoblium Supply Control"
	build_path = /obj/machinery/computer/atmos_control/hypernoblium_tank

/obj/item/circuitboard/computer/atmos_control/nitrium_tank
	name = "Nitrium Supply Control"
	build_path = /obj/machinery/computer/atmos_control/nitrium_tank

/obj/item/circuitboard/computer/atmos_control/pluoxium_tank
	name = "Pluoxium Supply Control"
	build_path = /obj/machinery/computer/atmos_control/pluoxium_tank

/obj/item/circuitboard/computer/atmos_control/tritium_tank
	name = "Tritium Supply Control"
	build_path = /obj/machinery/computer/atmos_control/tritium_tank

/obj/item/circuitboard/computer/atmos_control/water_vapor
	name = "Water Vapor Supply Control"
	build_path = /obj/machinery/computer/atmos_control/water_vapor

/obj/item/circuitboard/computer/auxiliary_base
	name = "Auxiliary Base Management Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/auxiliary_base

/obj/item/circuitboard/computer/base_construction
	name = "Auxiliary Mining Base Construction Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/camera_advanced/base_construction

/obj/item/circuitboard/computer/comm_monitor
	name = "Telecommunications Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/monitor

/obj/item/circuitboard/computer/comm_server
	name = "Telecommunications Server Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/server

/obj/item/circuitboard/computer/message_monitor
	name = "Message Monitor"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/message_monitor

/obj/item/circuitboard/computer/powermonitor
	name = "Power Monitor" //name fixed 250810
	icon_state = "engineering"
	build_path = /obj/machinery/computer/monitor

/obj/item/circuitboard/computer/powermonitor/secret
	name = "Outdated Power Monitor" //Variant used on ruins to prevent them from showing up on PDA's.
	build_path = /obj/machinery/computer/monitor/secret

/obj/item/circuitboard/computer/sat_control
	name = "Satellite Network Control"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/sat_control

/obj/item/circuitboard/computer/solar_control
	name = "Solar Control"  //name fixed 250810
	icon_state = "engineering"
	build_path = /obj/machinery/power/solar_control
	custom_price = 150

/obj/item/circuitboard/computer/stationalert
	name = "Station Alerts Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/computer/teleporter
	name = "Teleporter Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/teleporter

/obj/item/circuitboard/computer/turbine_computer
	name = "Turbine Computer"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/turbine_control
	name = "Turbine Control"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/control_rods
	name = "RBMK Reactor Control Rod Console"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/reactor/control_rods

//Generic

/obj/item/circuitboard/computer/advanced_camera
	name = "Advanced Camera Console"
	icon_state = "generic"
	build_path = /obj/machinery/computer/camera_advanced/syndie

/obj/item/circuitboard/computer/advanced_camera/cyan
	name = "Advanced Camera Console: Cyan"
	build_path = /obj/machinery/computer/camera_advanced/bounty_hunter

/obj/item/circuitboard/computer/advanced_camera/darkblue
	name = "Advanced Camera Console: Dark Blue"
	build_path = /obj/machinery/computer/camera_advanced/wizard

/obj/item/circuitboard/computer/arcade/amputation
	name = "Mediborg's Amputation Adventure"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/amputation

/obj/item/circuitboard/computer/arcade/battle
	name = "Arcade Battle"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/battle

/obj/item/circuitboard/computer/arcade/orion_trail
	name = "Orion Trail"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/orion_trail

/obj/item/circuitboard/computer/holodeck // Not going to let people get this, but it's just here for future
	name = "Holodeck Control"
	icon_state = "generic"
	build_path = /obj/machinery/computer/holodeck

/obj/item/circuitboard/computer/libraryconsole
	name = "Library Visitor Console"
	icon_state = "generic"
	build_path = /obj/machinery/computer/libraryconsole

/obj/item/circuitboard/computer/libraryconsole/screwdriver_act(mob/living/user, obj/item/tool)
	if(build_path == /obj/machinery/computer/libraryconsole/bookmanagement)
		name = "Library Visitor Console [name_extension]"
		build_path = /obj/machinery/computer/libraryconsole
		to_chat(user, span_notice("Defaulting access protocols."))
	else
		name = "Book Inventory Management Console [name_extension]"
		build_path = /obj/machinery/computer/libraryconsole/bookmanagement
		to_chat(user, span_notice("Access protocols successfully updated."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/computer/olddoor
	name = "DoorMex"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/computer/pod
	name = "Massdriver control"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/computer/slot_machine
	name = "Slot Machine"
	icon_state = "generic"
	build_path = /obj/machinery/computer/slot_machine

/obj/item/circuitboard/computer/swfdoor
	name = "Magix"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old/swf

//Not inhereting the hackability from shuttle subtypes
/obj/item/circuitboard/computer/syndicate_shuttle
	name = "Syndicate Shuttle Console"
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
	name = "ProComp Executive"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old/syndicate

//Medical

/obj/item/circuitboard/computer/cloning
	name = "Cloning Console"
	icon_state = "medical"
	build_path = /obj/machinery/computer/cloning

/obj/item/circuitboard/computer/crew
	name = "Crew Monitoring Console"
	icon_state = "medical"
	build_path = /obj/machinery/computer/crew

/obj/item/circuitboard/computer/records/medical
	name = "Medical Records Console"
	icon_state = "medical"
	build_path = /obj/machinery/computer/records/medical

/obj/item/circuitboard/computer/operating
	name = "Operating Computer"
	icon_state = "medical"
	build_path = /obj/machinery/computer/operating

/obj/item/circuitboard/computer/pandemic
	name = "PanD.E.M.I.C. 2200"
	icon_state = "medical"
	build_path = /obj/machinery/computer/pandemic

/obj/item/circuitboard/computer/cloning/prototype
	name = "Prototype Cloning Console"
	icon_state = "medical"
	build_path = /obj/machinery/computer/cloning/prototype

/obj/item/circuitboard/computer/scan_consolenew
	name = "DNA Machine"
	icon_state = "medical"
	build_path = /obj/machinery/computer/scan_consolenew

//Science

/obj/item/circuitboard/computer/aifixer
	name = "AI Integrity Restorer"
	icon_state = "science"
	build_path = /obj/machinery/computer/aifixer

/obj/item/circuitboard/computer/launchpad_console
	name = "Launchpad Control"
	icon_state = "science"
	build_path = /obj/machinery/computer/launchpad

/obj/item/circuitboard/computer/mech_bay_power_console
	name = "Mech Bay Power Control"
	icon_state = "science"
	build_path = /obj/machinery/computer/mech_bay_power_console

/obj/item/circuitboard/computer/mecha_control
	name = "Exosuit Control"
	icon_state = "science"
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/computer/nanite_chamber_control
	name = "Nanite Chamber Control"
	icon_state = "science"
	build_path = /obj/machinery/computer/nanite_chamber_control

/obj/item/circuitboard/computer/nanite_cloud_controller
	name = "Nanite Cloud Controller"
	icon_state = "science"
	build_path = /obj/machinery/computer/nanite_cloud_controller

/obj/item/circuitboard/computer/rdconsole
	name = "R&D Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/rdconsole
	req_access = list(ACCESS_TOX)

	/// If FALSE, techweb nodes researched from this console are broadcasted to their respective radio channels.
	var/silence_announcements = FALSE
	/// Whether or not the console is locked. This var doesn't exist on the console level and is checked here.
	var/locked = TRUE

/obj/item/circuitboard/computer/rdconsole/unlocked
	locked = FALSE

/obj/item/circuitboard/computer/rdconsole/examine(mob/user)
	. = ..()
	. += span_info("The board is configured to [silence_announcements ? "silence" : "announce"] researched nodes on radio.")
	. += span_notice("The board mode can be changed with a <b>multitool</b>.")
	. += span_notice("The board is [locked ? "locked" : "unlocked"], and can be [locked ? "unlocked" : "locked"] with an ID that has research access.")

/obj/item/circuitboard/computer/rdconsole/multitool_act(mob/living/user, obj/item/tool)
	if(obj_flags & EMAGGED)
		balloon_alert(user, "board mode is broken!")
		return
	silence_announcements = !silence_announcements
	balloon_alert(user, "announcements [silence_announcements ? "enabled" : "disabled"]")
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/computer/rdconsole/on_emag(mob/user)
	if (locked)
		to_chat(user, span_notice("You magnetically trigger the locking mechanism, causing it to unlock."))
		locked = FALSE

	silence_announcements = FALSE
	if (!(obj_flags & EMAGGED)) // the check in question checks for the EMAGGED bitflag. no need to repeat messages
		to_chat(user, span_notice("You overload the node announcement chip, forcing every node to be announced on the common channel."))
	return ..()

/obj/item/circuitboard/computer/rdconsole/attackby(obj/item/attacking_item, mob/living/user, params)
	if (user.combat_mode || !isidcard(attacking_item))
		return ..()
	if (!check_access(attacking_item))
		balloon_alert(user, "no access!")
		return

	locked = !locked
	balloon_alert(user, locked ? "locked" : "unlocked")
	user.visible_message(
		message = span_notice("[user] unlocks \the [src] with \the [attacking_item]."),
		self_message = span_notice("You unlock \the [src] with \the [attacking_item]."),
		blind_message = span_hear("You hear a soft beep."),
	)

/obj/item/circuitboard/computer/rdservercontrol
	name = "R&D Server Control"
	icon_state = "science"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/computer/research
	name = "Research Monitor"
	icon_state = "science"
	build_path = /obj/machinery/computer/security/research

/obj/item/circuitboard/computer/robotics
	name = "Robotics Control"
	icon_state = "science"
	build_path = /obj/machinery/computer/robotics

/obj/item/circuitboard/computer/xenobiology
	name = "Xenobiology Console"
	icon_state = "science"
	build_path = /obj/machinery/computer/camera_advanced/xenobio

//Security

/obj/item/circuitboard/computer/gulag_teleporter_console
	name = "Labor Camp Teleporter Console"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner/gulag_teleporter_computer

/obj/item/circuitboard/computer/prisoner
	name = "Prisoner Management Console"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner

/obj/item/circuitboard/computer/records/security
	name = "Security Records Console"
	icon_state = "security"
	build_path = /obj/machinery/computer/records/security

/obj/item/circuitboard/computer/security
	name = "Security Camera Console"
	icon_state = "security"
	build_path = /obj/machinery/computer/security

/obj/item/circuitboard/computer/warrant
	name = "Security Warrant Console"
	icon_state = "security"
	build_path = /obj/machinery/computer/warrant

//Service

// there's nothing here :(

//Supply

/obj/item/circuitboard/computer/objective
	name = "Nanotrasen Objective Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/objective

/obj/item/circuitboard/computer/bounty
	name = "Nanotrasen Bounty Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/bounty

/obj/item/circuitboard/computer/cargo
	name = "Supply Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo
	var/contraband = FALSE

/obj/item/circuitboard/computer/cargo/multitool_act(mob/living/user, obj/item/tool)
	if(obj_flags & EMAGGED)
		to_chat(user, span_notice("The spectrum chip is unresponsive."))
		return

	contraband = !contraband
	to_chat(user, span_notice("Receiver spectrum set to [contraband ? "Broad" : "Standard"]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/computer/cargo/on_emag(mob/user)
	. = ..()
	contraband = TRUE
	to_chat(user, span_notice("You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband."))

/obj/item/circuitboard/computer/cargo/configure_machine(obj/machinery/computer/cargo/machine)
	if(!istype(machine))
		CRASH("Cargo board attempted to configure incorrect machine type: [machine] ([machine?.type])")

	machine.contraband = contraband
	if (obj_flags & EMAGGED)
		machine.obj_flags |= EMAGGED
	else
		machine.obj_flags &= ~EMAGGED

/obj/item/circuitboard/computer/cargo/express
	name = "Express Supply Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo/express

/obj/item/circuitboard/computer/cargo/express/on_emag(mob/user)
	. = ..()
	to_chat(user, span_notice("You change the routing protocols, allowing the Drop Pod to land anywhere on the station."))

/obj/item/circuitboard/computer/cargo/request
	name = "Supply Request Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo/request

/obj/item/circuitboard/computer/mining
	name = "Outpost Status Display"
	icon_state = "supply"
	build_path = /obj/machinery/computer/security/mining

//Shuttles

/obj/item/circuitboard/computer/shuttle
	var/hacked = FALSE

/obj/item/circuitboard/computer/shuttle/multitool_act(mob/living/user, obj/item/tool)
	hacked = !hacked
	if(hacked)
		to_chat(user, span_notice("You disable the circuitboard's ID scanning protocols."))
	else
		to_chat(user, span_notice("You reset the circuitboard's ID scanning protocols."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/computer/shuttle/white_ship
	name = "White Ship Control"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship

/obj/item/circuitboard/computer/shuttle/white_ship/pod
	name = "Salvage Pod Control"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship/pod

/obj/item/circuitboard/computer/shuttle/white_ship/pod/recall
	name = "Salvage Pod Recall Control"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship/pod/recall

/obj/item/circuitboard/computer/shuttle/flight_control
	name = "Shuttle Flight Control"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/custom_shuttle

/obj/item/circuitboard/computer/shuttle/labor_shuttle
	name = "Labor Shuttle Console"
	icon_state = "security"
	build_path = /obj/machinery/computer/shuttle_flight/labor

/obj/item/circuitboard/computer/shuttle/labor_shuttle/one_way
	name = "Prisoner Shuttle Console"
	build_path = /obj/machinery/computer/shuttle_flight/labor/one_way

/obj/item/circuitboard/computer/ferry
	name = "Transport Ferry Control"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle_flight/ferry

/obj/item/circuitboard/computer/ferry/request
	name = "Transport Ferry Console"
	build_path = /obj/machinery/computer/shuttle_flight/ferry/request

/obj/item/circuitboard/computer/shuttle/mining_shuttle
	name = "Mining Shuttle Console"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle_flight/mining

/obj/item/circuitboard/computer/shuttle/science_shuttle
	name = "Science Shuttle Console"
	build_path = /obj/machinery/computer/shuttle_flight/science

/obj/item/circuitboard/computer/shuttle/exploration_shuttle
	name = "Exploration Shuttle Console"
	build_path = /obj/machinery/computer/shuttle_flight/custom_shuttle/exploration

/obj/item/circuitboard/computer/shuttle/monastery_shuttle
	name = "Monastery Shuttle Console"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/monastery_shuttle
