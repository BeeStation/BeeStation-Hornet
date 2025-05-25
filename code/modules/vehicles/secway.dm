
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
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/secway)

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

/obj/vehicle/ridden/secway/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(atom_integrity < max_integrity)
			if(W.use_tool(src, user, 0, volume = 50, amount = 1))
				user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to \the [src]."))
				atom_integrity += min(10, max_integrity-atom_integrity)
				if(atom_integrity == max_integrity)
					to_chat(user, span_notice("It looks to be fully repaired now."))
		return TRUE
	return ..()

/obj/vehicle/ridden/secway/atom_destruction()
	explosion(src, -1, 0, 2, 4, flame_range = 3)
	return ..()

/obj/vehicle/ridden/secway/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

//bullets will have a 60% chance to hit any riders
/obj/vehicle/ridden/secway/bullet_act(obj/projectile/P)
	if(!buckled_mobs || prob(60))
		return ..()
	for(var/mob/rider as anything in buckled_mobs)
		rider.bullet_act(P)
	return TRUE
