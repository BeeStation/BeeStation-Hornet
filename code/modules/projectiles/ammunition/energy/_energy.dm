/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew."
	caliber = "energy"
	projectile_type = /obj/projectile/energy
	var/e_cost = 0	//The amount of energy a cell needs to expend to create this shot. This is calculated automatically based on shots per kw
	var/shots_per_kw = 10
	var/select_name = "energy"
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy
	heavy_metal = FALSE

/obj/item/ammo_casing/energy/Initialize(mapload)
	. = ..()
	if(shots_per_kw)
		e_cost = 1 KILOWATT / shots_per_kw
