
//=======================
// Laser Weapons
//=======================

/obj/item/gun/ballistic/automatic/laser/laser_carbine
	name = "laser carbine"
	desc = "A fully automatic Nanotrasen carbine, capable of expelling high-energy, burning projectiles."
	icon_state = "oldrifle"
	item_state = "arg"
	pin = /obj/item/firing_pin/implant/pindicate
	mag_type = /obj/item/ammo_box/magazine/recharge
	can_suppress = FALSE
	actions_types = list()
	fire_sound = 'sound/weapons/laser.ogg'
	casing_ejector = FALSE
	full_auto = TRUE
	fire_rate = 2
	block_upgrade_walk = 1

//=======================
// Laser Weapon Ammunition
//=======================

/obj/item/ammo_box/magazine/recharge/laser
	icon_state = "oldrifle"
	multiple_sprites = 2
	ammo_type = /obj/item/ammo_casing/energy/laser/heavy

/obj/item/ammo_box/magazine/recharge/laser/high_cap
	name = "high capacity power pack"
	desc = "An upgraded, rechargable battery that serves as a magasine for laser carbines."
	icon_state = "riflehighcap"
	max_ammo = 38

/obj/item/ammo_box/magazine/recharge/laser/pulse
	name = "pulse power pack"
	desc = "A power pack for laser carbines, modified "
	max_ammo = 16
	ammo_type = /obj/item/ammo_casing/caseless/pulse
	icon_state = "pulseammo"

//=======================
// Tactical Energy Rifle
//=======================

/obj/item/gun/energy/e_gun/tactical
	name = "tactical energy gun"
	desc = "A military issue energy gun for elite Nanotrasen operatives, firing heavy laser rounds."
	icon_state = "energytac"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser/heavy)
	full_auto = TRUE
	fire_rate = 4

//=======================
// Pulse Rifle
//=======================

/obj/item/gun/energy/pulse/pistol/m1911/finite
	cell_type = "/obj/item/stock_parts/cell"
