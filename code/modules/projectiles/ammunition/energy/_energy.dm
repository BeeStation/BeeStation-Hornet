/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew."
	caliber = "energy"
	projectile_type = /obj/projectile/energy
	/// The amount of energy a cell needs to expend to create this shot
	var/e_cost = 1000 WATT
	var/select_name = "energy"
	fire_sound = 'sound/weapons/laser.ogg'
	heavy_metal = FALSE
