/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave
	name = "proto-kinetic shockwave"
	desc = "A self recharging, weak shockwave-based mining tool, that deals increased damage in low pressure."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "kineticshockwave"
	no_charge_state = "kineticshockwave_empty"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shockwave)
	can_bayonet = FALSE
	max_mod_capacity = 60

/obj/item/ammo_casing/energy/kinetic/shockwave
	projectile_type = /obj/projectile/kinetic/shockwave
	pellets = 8
	variance = 360
	fire_sound = 'sound/weapons/emitter2.ogg'

/obj/projectile/kinetic/shockwave
	name = "concussive kinetic force"
	damage = 5
	range = 1
