/datum/clockcult/scripture/abscond
	name = "Abscond"
	desc = "Return you and anyone you are dragging back to Reebe."
	tip = "Transports you and anyone you are dragging to Reebe."
	invokation_text = list("As we bid farewell, and return to the stars...", "we shall find our way home.")
	invokation_time = 2.5 SECONDS
	button_icon_state = "Abscond"
	power_cost = 5
	category = SPELLTYPE_SERVITUDE

	/// The client's screen color before we messed with it
	var/previous_client_color

/datum/clockcult/scripture/abscond/recite(text_point, wait_time, stop_at = 0)
	if(text_point == 1)
		previous_client_color = invoker.client.color
		animate(invoker.client, color = "#AF0AAF", time = invokation_time)
	return ..()

/datum/clockcult/scripture/abscond/on_invoke_success()
	try_warp_servant(invoker, get_turf(pick(GLOB.servant_spawns)), bring_dragging = TRUE)

	var/prev_alpha = invoker.alpha
	invoker.alpha = 0
	animate(invoker, alpha = prev_alpha, time = 1 SECONDS)
	return ..()

/datum/clockcult/scripture/abscond/on_invoke_end()
	if(invoker.client)
		animate(invoker.client, color = previous_client_color, time = invokation_time)
	return ..()
