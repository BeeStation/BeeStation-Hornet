/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter0"
	base_icon_state = "igniter"
	plane = FLOOR_PLANE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/igniter
	armor_type = /datum/armor/machinery_igniter
	resistance_flags = FIRE_PROOF
	var/id = null
	var/on = FALSE


/datum/armor/machinery_igniter
	melee = 50
	bullet = 30
	laser = 70
	energy = 50
	bomb = 20
	fire = 100
	acid = 70

/obj/machinery/igniter/incinerator_toxmix
	id = INCINERATOR_TOXMIX_IGNITER

/obj/machinery/igniter/incinerator_atmos
	id = INCINERATOR_ATMOS_IGNITER

/obj/machinery/igniter/incinerator_syndicatelava
	id = INCINERATOR_SYNDICATELAVA_IGNITER

/obj/machinery/igniter/on
	on = TRUE
	icon_state = "igniter1"

/obj/machinery/igniter/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || panel_open)
		return
	add_fingerprint(user)

	use_power(50)
	on = !( on )
	update_appearance()

/obj/machinery/igniter/process()	//ugh why is this even in process()?
	if (on && !(machine_stat & NOPOWER) )
		var/turf/location = loc
		if (isturf(location))
			location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/igniter/Initialize(mapload)
	. = ..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/attackby(obj/item/I, mob/living/user, params)

	if(default_deconstruction_screwdriver(user, "igniter_o", "igniter[on]", I))
		on = FALSE
		return
	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/igniter/update_icon_state()
	icon_state = "[base_icon_state][(machine_stat & NOPOWER) ? 0 : on]"
	return ..()

/obj/machinery/igniter/add_context_self(datum/screentip_context/context, mob/user)
	context.add_generic_deconstruction_actions(src)
	if (!panel_open)
		context.add_attack_hand_action("Turn [on ? "Off" : "On"]")

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	base_icon_state = "migniter"
	resistance_flags = FIRE_PROOF
	layer = ABOVE_WINDOW_LAYER
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/datum/effect_system/spark_spread/spark_system

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/sparker, 26)

/obj/machinery/sparker/toxmix
	id = INCINERATOR_TOXMIX_IGNITER

/obj/machinery/sparker/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)
	spark_system.attach(src)

/obj/machinery/sparker/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/sparker/update_icon_state()
	if(disable)
		icon_state = "[base_icon_state]-d"
		return ..()
	icon_state = "[base_icon_state][powered() ? null : "-p"]"
	return ..()

/obj/machinery/sparker/powered()
	if(disable)
		return FALSE
	return ..()

/obj/machinery/sparker/screwdriver_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	tool.play_tool_sound(src, 50)
	disable = !disable
	if (disable)
		user.visible_message("[user] has disabled \the [src]!", span_notice("You disable the connection to \the [src]."))
	if (!disable)
		user.visible_message("[user] has reconnected \the [src]!", span_notice("You fix the connection to \the [src]."))
	update_appearance()
	return TRUE

/obj/machinery/sparker/attack_silicon()
	if (anchored)
		return ignite()

/obj/machinery/sparker/proc/ignite()
	if (!(powered()))
		return

	if ((disable) || (last_spark && world.time < last_spark + 50))
		return


	flick("[initial(icon_state)]-spark", src)
	spark_system.start()
	last_spark = world.time
	use_power(1000)
	var/turf/location = loc
	if (isturf(location))
		location.hotspot_expose(1000,2500,1)
	return 1

/obj/machinery/sparker/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(machine_stat & (BROKEN|NOPOWER)))
		ignite()
