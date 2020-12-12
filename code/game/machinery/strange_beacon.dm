/obj/machinery/strange_beacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "strange beacon"
	desc = "A strange bluespace beacon which brings in the electronic trash from other stations."
	use_power = IDLE_POWER_USE
	idle_power_usage = 25
	active_power_usage = 500
	obj_flags = CAN_BE_HIT
	circuit = /obj/item/circuitboard/machine/strange_beacon
	var/coolDown = 3600
	var/lastUse

/obj/machinery/strange_beacon/Initialize()
	. = ..()
	RefreshParts()

/obj/machinery/strange_beacon/RefreshParts()
	coolDown = 0
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		if(S.rating)
			coolDown += 3600/S.rating

/obj/machinery/strange_beacon/examine(mob/user)
	. = ..()
	if((in_range(user, src) || isobserver(user)) && panel_open)
		. += "<span class='notice'>The beacon's pannel is open </span>"

/obj/machinery/strange_beacon/interact(mob/user)
	..()
	if(lastUse+coolDown < world.time)
		new /obj/item/relic(loc)
		playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, TRUE)
		do_sparks(5,FALSE, src)
		lastUse = world.time
	else
		to_chat(user, "<span class='notice'>The beacon is still recharging.</span>")

/obj/machinery/strange_beacon/attackby(obj/item/G, mob/user, params)
	if(G.tool_behaviour == TOOL_SCREWDRIVER)
		if(!panel_open)
			panel_open = TRUE
		else
			panel_open = FALSE
	if(G.tool_behaviour == TOOL_CROWBAR && panel_open)
		default_deconstruction_crowbar(G)
