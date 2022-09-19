/obj/machinery/power/shuttle_shield_generator
	name = "shield generator"
	desc = "A localised gravitational-based shield generator that provides shuttles with protection from deep space hazards."
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "shield"
	density = TRUE

	var/connected = FALSE

	var/shield_health = 0
	var/max_shield_health = 100

	//50kW per health
	var/current_power_stored = 0
	var/power_per_health = 50

	//Can gain 2 shield health per second
	var/charge_rate = 100

	//Shield bubble overlay
	var/mutable_appearance/shield_bubble

/obj/machinery/power/shuttle_shield_generator/Initialize(mapload)
	. = ..()
	//Check our area
	var/area/shuttle/current_area = get_area(src)
	if(istype(current_area) && current_area.mobile_port)
		var/datum/shuttle_data/shuttle_data = SSorbits.get_shuttle_data(current_area.mobile_port.id)
		shuttle_data?.register_shield_generator(src)
	create_shield_bubble()

/obj/machinery/power/shuttle_shield_generator/Destroy()
	//Remove our health from the shuttle object
	SEND_SIGNAL(src, COMSIG_SHUTTLE_SHIELD_HEALTH_CHANGE, shield_health, 0)
	shield_health = 0
	. = ..()

/obj/machinery/power/shuttle_shield_generator/examine(mob/user)
	. = ..()
	if(connected)
		. += "<span class='notice'>A mounted display panel reads: '[shield_health] / [max_shield_health]'.</span>"
	else
		. += "<span class='warning'>A mounted display panel reads: 'DISCONNECTED'.</span>"

/// Calculate the shield generator's power
/obj/machinery/power/shuttle_shield_generator/RefreshParts()
	//Reset Values
	max_shield_health = 0
	power_per_health = 0
	charge_rate = 0
	//2 Capacitors
	//Charge Rate:
	//- Basic Level (2): 50 (1 shield health per second)
	//- Top Level (8): 400 (8 shield health per second)
	//Shield Health:
	//- Basic Level (2): Max Shield Health: 100
	//- Top Levecl (8): Max Shield Health : 300
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		charge_rate += C.rating * (350 / 6)
		max_shield_health += C.rating * (200 / 6)
	charge_rate -= 200/3
	max_shield_health += 100/3
	shield_health = min(shield_health, max_shield_health)
	//1 micro laser
	//Power Per Health:
	//- Basic Level (2): 50
	//- Top Level (8): 30
	for(var/obj/item/stock_parts/micro_laser/C in component_parts)
		power_per_health += C.rating * (-20/6)
	power_per_health += 160/3
	current_power_stored = min(current_power_stored, power_per_health)

/obj/machinery/power/shuttle_shield_generator/process(delta_time)
	//Consume Power
	take_power(delta_time)
	//Update Shield
	process_shield(delta_time)

/obj/machinery/power/shuttle_shield_generator/proc/give_shield(amount)
	var/previous_health = shield_health
	shield_health = CLAMP(shield_health + amount, 0, max_shield_health)
	SEND_SIGNAL(src, COMSIG_SHUTTLE_SHIELD_HEALTH_CHANGE, previous_health, shield_health)

/obj/machinery/power/shuttle_shield_generator/proc/process_shield(delta_time)
	//Not enough power stored
	if(current_power_stored < power_per_health)
		return
	//Shield is at full health
	if(shield_health >= max_shield_health)
		return
	//Update shield health
	var/required_health = max_shield_health - shield_health
	var/available_health = current_power_stored / power_per_health
	var/delta_health = min(required_health, available_health)
	var/consumed_power = delta_health * power_per_health
	give_shield(delta_health)
	current_power_stored -= consumed_power

/obj/machinery/power/shuttle_shield_generator/proc/take_power(delta_time)
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(!C)
		connected = FALSE
		return
	connected = TRUE
	var/datum/powernet/powernet = C.powernet
	if(!powernet)
		return
	//Consume power
	var/surplus = max(powernet.avail - powernet.load, 0)
	var/available_power = min(charge_rate * delta_time, surplus, 2 * charge_rate - current_power_stored)
	if(available_power)
		powernet.load += available_power
		current_power_stored += available_power

/obj/machinery/power/shuttle_shield_generator/proc/create_shield_bubble()
	if (shield_bubble)
		CRASH("Attempted to deploy a shield bubble while a shield bubble was already active.")
	shield_bubble = mutable_appearance('icons/effects/512x512.dmi', "shield", SHIELD_BUBBLE_LAYER, SHIELD_BUBBLE_PLANE)
	shield_bubble.pixel_x = -256
	shield_bubble.pixel_y = -256
