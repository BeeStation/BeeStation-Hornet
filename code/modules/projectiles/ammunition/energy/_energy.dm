/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew."
	caliber = "energy"
	projectile_type = /obj/projectile/energy
	var/e_cost = 1000 WATT	//The amount of energy a cell needs to expend to create this shot. This is calculated automatically based on shots per 10 kW
	var/select_name = "energy"
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy
	heavy_metal = FALSE
