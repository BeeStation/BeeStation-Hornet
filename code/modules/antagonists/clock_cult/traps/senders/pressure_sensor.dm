/obj/item/clockwork/trap_placer/pressure_sensor
	name = "pressure plate"
	desc = "I wonder what happens if you step on it."
	icon_state = "pressure_sensor"
	result_path = /obj/structure/destructible/clockwork/trap/pressure_sensor

/obj/structure/destructible/clockwork/trap/pressure_sensor
	name = "pressure plate"
	desc = "I wonder what happens if you step on it."
	icon_state = "pressure_sensor"
	unwrench_path = /obj/item/clockwork/trap_placer/pressure_sensor
	component_datum = /datum/component/clockwork_trap/pressure_sensor
	alpha = 80
	layer = PRESSURE_PLATE_LAYER

/datum/component/clockwork_trap/pressure_sensor
	sends_input = TRUE

/datum/component/clockwork_trap/pressure_sensor/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/crossed)

/datum/component/clockwork_trap/pressure_sensor/proc/crossed(atom/movable/AM)
	trigger_connected()
	playsound(get_turf(parent), 'sound/machines/click.ogg', 50)
