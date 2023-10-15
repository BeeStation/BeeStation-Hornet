/obj/machinery/computer/fluff
	name = "Useless computer"
	desc = "This terminal has some kind of software that is pretty much useless..."

/obj/machinery/computer/fluff/old
	name = "Useless old computer"
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null

	//remember, no smoothing
	base_icon_state = null
	smoothing_flags = null
	smoothing_groups = null
	canSmoothWith = null
	desc = "This computer is REALLY old."
	clockwork = TRUE //it'd look weird, but it's useless in this context
	broken_overlay_emissive = TRUE
