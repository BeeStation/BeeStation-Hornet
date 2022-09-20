/obj/machinery/computer/clockwork_research
	name = "clockwork research station"
	desc = "A computer that commands a high-powered relay that grants an impressive level of knowledge to those who use it."
	icon_screen = "ratvar1"
	icon_keyboard = "ratvar_key1"
	icon_state = "ratvarcomputer"
	clockwork = TRUE

/obj/machinery/computer/clockwork_research/ui_data(mob/user)
	var/data = list()
	data["unlocked_projects"] = list()
	data["available_projects"] = list()
