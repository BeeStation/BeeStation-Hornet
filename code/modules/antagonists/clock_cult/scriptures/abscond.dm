//==================================//
// !       Abscond       ! //
//==================================//

/datum/clockcult/scripture/abscond
	name = "Abscond"
	desc = "Return you and anyone you are dragging back to Reebe."
	tip = "Transports you and anyone you are dragging to Reebe."
	button_icon_state = "Abscond"
	power_cost = 5
	invokation_time = 25
	invokation_text = list("As we bid farewell, and return to the stars...", "we shall find our way home.")
	category = SPELLTYPE_SERVITUDE
	var/client_color

/datum/clockcult/scripture/abscond/recital()
	client_color = invoker.client.color
	animate(invoker.client, color = "#AF0AAF", time = invokation_time)
	. = ..()

/datum/clockcult/scripture/abscond/invoke_success()
	var/turf/T = get_turf(pick(GLOB.servant_spawns))
	try_warp_servant(invoker, T, TRUE)
	var/prev_alpha = invoker.alpha
	invoker.alpha = 0
	animate(invoker, alpha=prev_alpha, time=10)
	if(invoker.client)
		animate(invoker.client, color = client_color, time = 25)

/datum/clockcult/scripture/abscond/invoke_fail()
	if(invoker?.client)
		animate(invoker.client, color = client_color, time = 10)
