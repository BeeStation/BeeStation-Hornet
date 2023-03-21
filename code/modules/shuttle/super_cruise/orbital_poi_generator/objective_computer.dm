/obj/machinery/computer/objective
	name = "station objective console"
	desc = "A networked console that downloads and displays currently assigned station objectives."
	icon_screen = "bounty"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_ORANGE
	req_access = list( )
	circuit = /obj/item/circuitboard/computer/objective

/obj/machinery/computer/objective/Initialize(mapload, obj/item/circuitboard/C)
	return INITIALIZE_HINT_QDEL
