/obj/machinery/archive_server
	name = "station archive server"
	desc = "A computer system running on hibernation mode, containing encrypted data about what happened to this station and its inhabitants."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_color = LIGHT_COLOR_RED
	light_on = FALSE
	processing_flags = START_PROCESSING_MANUALLY

/obj/machinery/archive_server/process(delta_time)
	. = ..()
