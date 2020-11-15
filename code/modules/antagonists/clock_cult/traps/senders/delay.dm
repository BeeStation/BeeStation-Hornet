/obj/item/wallframe/clocktrap/delay
	name = "clockwork timer"
	desc = "A small timer attatched to the wall. When input is received it will send an output signal half a second later."
	icon_state = "delayer"
	result_path = /obj/structure/destructible/clockwork/trap/delay

/obj/structure/destructible/clockwork/trap/delay
	name = "clockwork timer"
	desc = "A small timer attatched to the wall. When input is received it will send an output signal half a second later."
	icon_state = "delayer"
	component_datum = /datum/component/clockwork_trap/delay
	unwrench_path = /obj/item/wallframe/clocktrap/delay
	max_integrity = 15
	obj_integrity = 15

/datum/component/clockwork_trap/delay
	takes_input = TRUE
	sends_input = TRUE
	var/active = FALSE

/datum/component/clockwork_trap/delay/trigger()
	if(!..())
		return
	if(active)
		return
	active = TRUE
	flick("delayer_active", parent)
	addtimer(CALLBACK(src, .proc/finish), 5)

/datum/component/clockwork_trap/delay/proc/finish()
	active = FALSE
	trigger_connected()
