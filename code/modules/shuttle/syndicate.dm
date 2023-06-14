#define SYNDICATE_CHALLENGE_TIMER 12000 //20 minutes

/obj/machinery/computer/shuttle_flight/syndicate
	name = "syndicate shuttle terminal"
	desc = "The terminal used to control the syndicate transport shuttle."
	circuit = /obj/item/circuitboard/computer/syndicate_shuttle
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	req_access = list(ACCESS_SYNDICATE)
	shuttleId = "syndicate"
	possible_destinations = "syndicate_away;syndicate_z5;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s;syndicate_custom"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/shuttle_flight/syndicate/recall
	name = "syndicate shuttle recall terminal"
	desc = "Use this if your friends left you behind."
	request_shuttle_message = "Recall Infiltrator"
	recall_docking_port_id = "syndicate_away"

/obj/machinery/computer/shuttle_flight/syndicate/ui_act(action, params)
	if(!usr.canUseTopic(src))
		return
	var/obj/item/circuitboard/computer/syndicate_shuttle/board = circuit
	if(board.challenge && world.time < SYNDICATE_CHALLENGE_TIMER)
		to_chat(usr, "<span class='warning'>You've issued a combat challenge to the station! You've got to give them at least [DisplayTimeText(SYNDICATE_CHALLENGE_TIMER - world.time)] more to allow them to prepare.</span>")
		return FALSE
	board.moved = TRUE
	. = ..()

/obj/machinery/computer/shuttle_flight/syndicate/allowed(mob/M)
	if(issilicon(M) && !(FACTION_SYNDICATE in M.faction))
		return FALSE
	return ..()

/obj/machinery/computer/shuttle_flight/syndicate/drop_pod
	name = "syndicate assault pod control"
	desc = "Controls the drop pod's launch system."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	light_color = LIGHT_COLOR_BLUE
	req_access = list(ACCESS_SYNDICATE)
	shuttleId = "steel_rain"
	possible_destinations = null
	clockwork = TRUE //it'd look weird
	recall_docking_port_id = "null"	//Make it a recall shuttle, with no default dest
	request_shuttle_message = "INITIATE ASSAULT"

#undef SYNDICATE_CHALLENGE_TIMER
