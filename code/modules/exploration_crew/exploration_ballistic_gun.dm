/obj/item/gun/ballistic/rifle/leveraction/exploration
	name = "modern lever action rifle"
	desc = "Wood may have been replaced with carbon fibre, and the barrel with a space-proof, but this rifle is still ready to serve you at the final frontier."
	icon_state = "leverrifleshiny"
	mag_type = /obj/item/ammo_box/magazine/internal/leveraction/exploration
	no_pin_required = FALSE
	pin = /obj/item/firing_pin/off_station

/obj/item/ammo_box/magazine/internal/leveraction/exploration
	name = "lever action rifle internal magazine"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = list("38")
	max_ammo = 8
	multiload = FALSE

/obj/projectile/bullet/c38/exploration
	name = ".38 Prospector bullet"
	damage = 20
	ricochets_max = 2
	ricochet_chance = 80
	ricochet_auto_aim_angle = 40
	ricochet_auto_aim_range = 4

/obj/projectile/bullet/c38/exploration/prehit_pierce(atom/target)
	if(!iscarbon(target) && !issilicon(target))
		damage = 35
	return ..()

/obj/item/ammo_casing/c38/exploration
	name = ".38 Prospector bullet casing"
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = /obj/projectile/bullet/c38/exploration

/obj/item/ammo_box/c38/exploration
	name = "Ammo Box (.38 Prospector)"
	desc = "These rounds were designed for the purpose of eradicating threats from outer space."
	ammo_type = /obj/item/ammo_casing/c38/exploration
	icon_state = "38pbox"
	max_ammo = 24
	multiple_sprites = 0
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/c38/box/exploration
	name = "ammo box (.38Prospector)"
	desc = "A small pack of .38 Prospector cartridges"
	ammo_type = /obj/item/ammo_casing/c38/exploration
