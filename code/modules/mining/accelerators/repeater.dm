/obj/item/gun/energy/recharge/kinetic_accelerator/repeater
	name = "proto-kinetic repeater"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure and has a built-in repeater module that lets it shooter rapidly in a short period of time."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "kineticrepeater"
	no_charge_state = "kineticrepeater_empty"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/repeater)
	max_mod_capacity = 60

/obj/item/ammo_casing/energy/kinetic/repeater
	projectile_type = /obj/projectile/kinetic/repeater
	e_cost = 150 //about three shots

/obj/projectile/kinetic/repeater
	name = "rapid kinetic force"
	damage = 20
	range = 4
