/obj/machinery/computer/weapons
	name = "weapons control console"
	desc = "a computer for controlling the weapon systems of your shuttle."
	var/list/weapon_weakrefs = list()	//A list of weakrefs to the weapon systems
	var/shuttle_id = "exploration"	//The shuttle we are connected to
