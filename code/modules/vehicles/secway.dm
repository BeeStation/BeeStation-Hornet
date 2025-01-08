
/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 100
	armor_type = /datum/armor/ridden_secway
	key_type = /obj/item/key/security
	integrity_failure = 0.5


/datum/armor/ridden_secway
	melee = 20
	bullet = 15
	laser = 10
	bomb = 30
	fire = 60
	acid = 60

/obj/vehicle/ridden/secway/Initialize(mapload)
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1.5
	D.empable = TRUE
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))

/obj/vehicle/ridden/secway/atom_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/secway/process(delta_time)
	if(atom_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(DT_PROB(10, delta_time))
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()

/obj/vehicle/ridden/secway/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(atom_integrity < max_integrity)
			if(W.use_tool(src, user, 0, volume = 50, amount = 1))
				user.visible_message("<span class='notice'>[user] repairs some damage to [name].</span>", "<span class='notice'>You repair some damage to \the [src].</span>")
				atom_integrity += min(10, max_integrity-atom_integrity)
				if(atom_integrity == max_integrity)
					to_chat(user, "<span class='notice'>It looks to be fully repaired now.</span>")
		return TRUE
	return ..()

/obj/vehicle/ridden/secway/atom_destruction()
	explosion(src, -1, 0, 2, 4, flame_range = 3)
	return ..()

/obj/vehicle/ridden/secway/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/vehicle/ridden/secway/bullet_act(obj/projectile/P)
	if(prob(60) && buckled_mobs)
		for(var/mob/M in buckled_mobs)
			M.bullet_act(P)
		return TRUE
	return ..()
