/obj/machinery/computer/shuttle_flight/white_ship
	name = "White Ship Console"
	desc = "Used to control the White Ship."
	circuit = /obj/item/circuitboard/computer/shuttle/white_ship
	shuttleId = "whiteship"
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_lavaland;whiteship_custom"

/obj/machinery/computer/shuttle_flight/white_ship/pod
	name = "Salvage Pod Console"
	desc = "Used to control the Salvage Pod."
	circuit = /obj/item/circuitboard/computer/shuttle/white_ship/pod
	shuttleId = "whiteship_pod"
	possible_destinations = "whiteship_pod_home;whiteship_pod_custom"

/obj/machinery/computer/shuttle_flight/white_ship/pod/recall
	name = "Salvage Pod Recall Console"
	desc = "Used to recall the Salvage Pod."
	circuit = /obj/item/circuitboard/computer/shuttle/white_ship/pod/recall
	possible_destinations = "whiteship_pod_home"
