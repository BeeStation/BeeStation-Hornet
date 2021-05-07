
/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 100
	armor = list("melee" = 20, "bullet" = 15, "laser" = 10, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 0)
	key_type = /obj/item/key/security
	integrity_failure = 50
	light_source_type = FANCY_LIGHTING
	var/sirens = FALSE

/obj/vehicle/ridden/secway/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1.5
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))

/obj/vehicle/ridden/secway/obj_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/secway/process()
	if(obj_integrity >= integrity_failure)
		return PROCESS_KILL
	if(prob(20))
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

/obj/vehicle/ridden/secway/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/ridden/sirens, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/ridden/secway/proc/play_sirens_async()
	if(sirens)
		return
	sirens = TRUE
	var/light_red = FALSE
	set_light(l_range = 4)
	while(sirens)
		playsound(src, 'sound/items/weeoo1.ogg', 100, FALSE, 4)
		for(var/i in 1 to 3)
			set_light(l_color = light_red ? "#FF0000" : "#0000FF")
			light_red = !light_red
			sleep(5)
	set_light(l_range = 0)
