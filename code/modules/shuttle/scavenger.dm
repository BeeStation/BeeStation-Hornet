/obj/machinery/computer/shuttle/scavenger
	name = "Scavenger Ship Console"
	desc = "Used to control the Scavenger Ship."
	circuit = /obj/item/circuitboard/computer/scavenger_ship
	shuttleId = "scavenger"
	possible_destinations = "scavenger_home;scavenger_custom"

/obj/machinery/computer/camera_advanced/shuttle_docker/scavenger
	name = "Scavenger Ship Navigation Computer"
	desc = "Used to designate a precise transit location for the scavenger Ship."
	shuttleId = "scavenger"
	lock_override = NONE
	shuttlePortId = "scavenger_custom"
	jumpto_ports = list("scavenger_home" = 1)
	view_range = 18
	x_offset = -6
	y_offset = -10
	designate_time = 50

/obj/docking_port/mobile/scavenger
	name = "scavenger ship"
	id = "scavenger"