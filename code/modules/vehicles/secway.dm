#define MOVE_DELAY 0.75 //Move delay for circuits only

/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 100
	armor = list("melee" = 20, "bullet" = 15, "laser" = 10, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 0)
	key_type = /obj/item/key/security
	integrity_failure = 50

/obj/vehicle/ridden/secway/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(new /obj/item/circuit_component/secway()), SHELL_CAPACITY_SMALL)
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1.5
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))

/obj/vehicle/ridden/secway/obj_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/secway/process(delta_time)
	if(obj_integrity >= integrity_failure)
		return PROCESS_KILL
	if(DT_PROB(10, delta_time))
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()

/obj/vehicle/ridden/secway/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(obj_integrity < max_integrity)
			if(W.use_tool(src, user, 0, volume = 50, amount = 1))
				user.visible_message("<span class='notice'>[user] repairs some damage to [name].</span>", "<span class='notice'>You repair some damage to \the [src].</span>")
				obj_integrity += min(10, max_integrity-obj_integrity)
				if(obj_integrity == max_integrity)
					to_chat(user, "<span class='notice'>It looks to be fully repaired now.</span>")
		return TRUE
	return ..()

/obj/vehicle/ridden/secway/obj_destruction()
	explosion(src, -1, 0, 2, 4, flame_range = 3)
	return ..()

/obj/vehicle/ridden/secway/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/vehicle/ridden/secway/bullet_act(obj/item/projectile/P)
	if(prob(60) && buckled_mobs)
		for(var/mob/M in buckled_mobs)
			M.bullet_act(P)
		return TRUE
	return ..()

//Largely copied from Drone but this would be so awesome
/obj/item/circuit_component/secway
	display_name = "Secway"
	display_desc = "Vroom Vroom!"

	/// The inputs to allow for the Secway to move
	var/datum/port/input/north
	var/datum/port/input/east
	var/datum/port/input/south
	var/datum/port/input/west

	// Done like this so that travelling diagonally is more simple
	COOLDOWN_DECLARE(north_delay)
	COOLDOWN_DECLARE(east_delay)
	COOLDOWN_DECLARE(south_delay)
	COOLDOWN_DECLARE(west_delay)


/obj/item/circuit_component/secway/Initialize(mapload)
	. = ..()
	north = add_input_port("Move North", PORT_TYPE_SIGNAL)
	east = add_input_port("Move East", PORT_TYPE_SIGNAL)
	south = add_input_port("Move South", PORT_TYPE_SIGNAL)
	west = add_input_port("Move West", PORT_TYPE_SIGNAL)


/obj/item/circuit_component/secway/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/obj/vehicle/ridden/secway/shell = parent.shell
	if(!istype(shell))
		return

	var/direction

	if(COMPONENT_TRIGGERED_BY(north, port) && COOLDOWN_FINISHED(src, north_delay))
		direction = NORTH
		COOLDOWN_START(src, north_delay, MOVE_DELAY)
	else if(COMPONENT_TRIGGERED_BY(east, port) && COOLDOWN_FINISHED(src, east_delay))
		direction = EAST
		COOLDOWN_START(src, east_delay, MOVE_DELAY)
	else if(COMPONENT_TRIGGERED_BY(south, port) && COOLDOWN_FINISHED(src, south_delay))
		direction = SOUTH
		COOLDOWN_START(src, south_delay, MOVE_DELAY)
	else if(COMPONENT_TRIGGERED_BY(west, port) && COOLDOWN_FINISHED(src, west_delay))
		direction = WEST
		COOLDOWN_START(src, west_delay, MOVE_DELAY)

	if(!direction)
		return

	if(shell.Process_Spacemove(direction))
		step(shell, direction)

#undef MOVE_DELAY
