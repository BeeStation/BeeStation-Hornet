/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter0"
	plane = FLOOR_PLANE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/igniter
	armor = list(MELEE = 50,  BULLET = 30, LASER = 70, ENERGY = 50, BOMB = 20, BIO = 0, RAD = 0, FIRE = 100, ACID = 70, STAMINA = 0)
	resistance_flags = FIRE_PROOF
	var/id = null
	var/on = FALSE

/obj/machinery/igniter/incinerator_toxmix
	id = INCINERATOR_TOXMIX_IGNITER

/obj/machinery/igniter/incinerator_atmos
	id = INCINERATOR_ATMOS_IGNITER

/obj/machinery/igniter/incinerator_syndicatelava
	id = INCINERATOR_SYNDICATELAVA_IGNITER

/obj/machinery/igniter/on
	on = TRUE
	icon_state = "igniter1"

/obj/machinery/igniter/attack_hand(mob/user)
	. = ..()
	if(. || panel_open)
		return
	add_fingerprint(user)

	use_power(50)
	on = !( on )
	update_icon()

/obj/machinery/igniter/process()	//ugh why is this even in process()?
	if (src.on && !(machine_stat & NOPOWER) )
		var/turf/location = src.loc
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

/obj/machinery/igniter/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "igniter0"
	else
		icon_state = "igniter[on]"

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	resistance_flags = FIRE_PROOF
	layer = ABOVE_WINDOW_LAYER
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/datum/effect_system/spark_spread/spark_system

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

/obj/machinery/sparker/update_icon()
	if(disable)
		icon_state = "[initial(icon_state)]-d"
	else if(powered())
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]-p"

/obj/machinery/sparker/powered()
	if(!disable)
		return FALSE
	return ..()

/obj/machinery/sparker/attackby(obj/item/W, mob/user, params)
	if (W.tool_behaviour == TOOL_SCREWDRIVER)
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("[user] has disabled \the [src]!", "<span class='notice'>You disable the connection to \the [src].</span>")
		if (!src.disable)
			user.visible_message("[user] has reconnected \the [src]!", "<span class='notice'>You fix the connection to \the [src].</span>")
			update_icon()
	else
		return ..()

/obj/machinery/sparker/attack_ai()
	if (anchored)
		return src.ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_spark && world.time < src.last_spark + 50))
		return


	flick("[initial(icon_state)]-spark", src)
	spark_system.start()
	last_spark = world.time
	use_power(1000)
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,2500,1)
	return 1

/obj/machinery/sparker/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(machine_stat & (BROKEN|NOPOWER)))
		ignite()
