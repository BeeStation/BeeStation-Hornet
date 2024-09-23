/obj/machinery/plumbing/disposer
	name = "chemical disposer"
	desc = "Breaks down chemicals and annihilates them."
	icon_state = "disposal"
	active_power_usage = 70
	///we remove 5 reagents per second
	var/disposal_rate = 5

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/plumbing/disposer)

/obj/machinery/plumbing/disposer/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)
	update_appearance() //so the input/output pipes will overlay properly during init

/obj/machinery/plumbing/disposer/process(delta_time)
	if(machine_stat & NOPOWER)
		return
	if(reagents.total_volume)
		if(icon_state != initial(icon_state) + "_working") //threw it here instead of update icon since it only has two states
			icon_state = initial(icon_state) + "_working"
		reagents.remove_any(disposal_rate * delta_time)
	else
		if(icon_state != initial(icon_state))
			icon_state = initial(icon_state)

