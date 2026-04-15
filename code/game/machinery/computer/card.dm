/obj/machinery/computer/card
	name = "id console"

/obj/machinery/computer/card/Initialize(mapload)// Hello world
	. = ..()

	// Hello child
	var/obj/machinery/modular_computer/console/preset/command/replacement = new(loc)
	replacement.setDir(dir)
	return INITIALIZE_HINT_QDEL // Bye world

// I know, I know, this is ass. But it works.
/obj/machinery/computer/card/centcom
	name = "centcom id console"

/obj/machinery/computer/card/minor
	name = "department id console"

/obj/machinery/computer/card/minor/hos
/obj/machinery/computer/card/minor/cmo
/obj/machinery/computer/card/minor/rd
/obj/machinery/computer/card/minor/ce
