/obj/item/gun/energy/recharge/kinetic_accelerator/railgun
	name = "proto-kinetic railgun"
	desc = "An extremely powerful, self recharging, ranged mining tool that does increased damage in low pressure, but has a very high cooldown."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "kineticrailgun"
	base_icon_state = "kineticrailgun"
	pin = /obj/item/firing_pin/off_station
	w_class = WEIGHT_CLASS_HUGE
	recharge_time = 3 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/railgun)
	weapon_weight = WEAPON_HEAVY
	can_bayonet = FALSE
	max_mod_capacity = 25
	recoil = 3

/obj/item/ammo_casing/energy/kinetic/railgun
	projectile_type = /obj/projectile/kinetic/railgun
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/projectile/kinetic/railgun
	name = "hyper kinetic force"
	damage = 100
	range = 7
	pressure_decrease = 0.10 // Pressured enviorments are a no go for the railgun
	speed = 0.1 // NYOOM
	projectile_piercing = PASSMOB
