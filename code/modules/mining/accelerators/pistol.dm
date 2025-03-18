/obj/item/gun/energy/recharge/kinetic_accelerator/glock
	name = "proto-kinetic pistol"
	desc = "A mini-version of a standard kinetic accelerator that can handle double the modules, but is known to lock-up due if you have some certain module combinations."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "kineticpistol"
	no_charge_state = "kineticpistol_empty"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/glock)
	can_bayonet = FALSE
	max_mod_capacity = 200

/obj/item/ammo_casing/energy/kinetic/glock
	projectile_type = /obj/projectile/kinetic/glock

/obj/projectile/kinetic/glock
	name = "light kinetic force"
	damage = 10
