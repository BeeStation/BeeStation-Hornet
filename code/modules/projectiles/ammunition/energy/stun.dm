/obj/item/ammo_casing/energy/electrode
	name = "Taser cartridge"
	desc = "Standard-issue APS-Arc taser cartridge. Easily repacked with pre-prepared load-assemblies. Some text is stamped into the polymer body: 'ATTENTION: DO NOT LOSE.'"
	icon_state = "taser_cartridge"
	projectile_type = /obj/projectile/energy/electrode
	select_name = "stun"
	fire_sound = 'sound/weapons/taser.ogg'
	e_cost = 2000 WATT
	harmful = FALSE

/obj/item/ammo_casing/energy/electrode/spec
	e_cost = 1000 WATT

/obj/item/ammo_casing/energy/electrode/hos
	e_cost = 4000 WATT

/obj/item/ammo_casing/energy/electrode/old
	e_cost = 10000 WATT

/obj/item/ammo_casing/energy/electrode/turret
	projectile_type = /obj/projectile/energy/electrode/turret

/obj/item/ammo_casing/energy/electrode/broken
	projectile_type = /obj/projectile/energy/electrode/broken

/obj/item/ammo_casing/energy/disabler
	projectile_type = /obj/projectile/beam/disabler
	select_name = "disable"
	e_cost = 400 WATT
	fire_sound = 'sound/weapons/taser2.ogg'
	harmful = FALSE

/obj/item/ammo_casing/energy/disabler/hos
	projectile_type = /obj/projectile/beam/disabler
	e_cost = 500 WATT
