/obj/item/gun/energy/recharge/kinetic_accelerator/shotgun
	name = "proto-kinetic shotgun"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure and has been made to shoot thrice at once."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "kineticshotgun"
	base_icon_state = "kineticshotgun"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shotgun)
	max_mod_capacity = 60

/obj/item/ammo_casing/energy/kinetic/shotgun
	projectile_type = /obj/projectile/kinetic/shotgun
	pellets = 3
	variance = 50

/obj/projectile/kinetic/shotgun
	name = "split kinetic force"
	damage = 20
