
/datum/wires/emitter
	proper_name = "Emitter"
	holder_type = /obj/machinery/power/emitter

/datum/wires/emitter/New(atom/holder)
	wires = list(WIRE_ACTIVATE,WIRE_INTERFACE,WIRE_POWER)
	..()

/datum/wires/emitter/on_pulse(wire)
	var/obj/machinery/power/emitter/E = holder
	switch(wire)
		if(WIRE_ACTIVATE)
			E.fire_beam_pulse()
		if(WIRE_INTERFACE)
			E.mode = !E.mode
			E.set_projectile()
		if(WIRE_POWER)
			if(!E.welded || !E.powernet)
				return FALSE
			E.active = !E.active
			if(!E.active)
				E.shot_number = 0
				E.fire_delay = E.maximum_fire_delay
			message_admins("Emitter turned [E.active ? "ON" : "OFF"] by signal in [ADMIN_VERBOSEJMP(E)]")
			log_game("Emitter turned [E.active ? "ON" : "OFF"] by signal in [AREACOORD(E)]")
			E.investigate_log("turned [E.active ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"] by signal at [AREACOORD(E)]", INVESTIGATE_ENGINES)
			E.update_appearance()

