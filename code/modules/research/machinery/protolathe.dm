/obj/machinery/rnd/production/protolathe
	name = "protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe
	categories = list(
								"Power Designs",
								"Medical Designs",
								"Bluespace Designs",
								"Stock Parts",
								"Equipment",
								"Tool Designs",
								"Mining Designs",
								"Electronics",
								"Weapons",
								"Ammo",
								"Firing Pins",
								"Circuitry"
								)
	production_animation = "protolathe_n"
	allowed_buildtypes = PROTOLATHE
	consoleless_interface = TRUE
	requires_console = FALSE

/obj/machinery/rnd/production/protolathe/disconnect_console()
	linked_console.linked_lathe = null
	..()
