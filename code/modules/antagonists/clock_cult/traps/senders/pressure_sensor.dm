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
	alpha = 60
	layer = PRESSURE_PLATE_LAYER
	max_integrity = 5
	obj_integrity = 5

/datum/component/clockwork_trap/pressure_sensor
	sends_input = TRUE

/datum/component/clockwork_trap/pressure_sensor/Initialize()
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/clockwork_trap/pressure_sensor/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	//Item's in hands or boxes shouldn't trigger it
	if(!istype(AM.loc, /turf))
		return
	var/mob/living/M = AM
	if(istype(M))
		if(is_servant_of_ratvar(M))
			return
		if(M.incorporeal_move || M.is_flying())
			return
	else
		return
	trigger_connected()
	for(var/obj/structure/destructible/clockwork/trap/T in get_turf(parent))
		if(T != parent)
			SEND_SIGNAL(T, COMSIG_CLOCKWORK_SIGNAL_RECEIVED)
	playsound(get_turf(parent), 'sound/machines/click.ogg', 50)
