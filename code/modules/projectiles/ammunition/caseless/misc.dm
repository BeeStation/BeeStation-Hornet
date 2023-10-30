/obj/item/ammo_casing/caseless/laser
	name = "laser casing"
	desc = "You shouldn't be seeing this."
	caliber = "laser"
	icon_state = "s-casing-live"
	projectile_type = /obj/projectile/beam
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/item/ammo_casing/caseless/laser/gatling
	projectile_type = /obj/projectile/beam/weak/penetrator
	variance = 0.8
	click_cooldown_override = 1

// Musket Ammunition (Muzzleloaded, ~technically~ this is just the projectile.)
/obj/item/ammo_casing/caseless/musket
	name = "musket ball"
	desc = "A crudely hewn musket ball, with a paper wrapping"
	caliber = "musket"
	icon_state = "a41metal"
	projectile_type = /obj/projectile/bullet/musket
	randomspread = TRUE
	variance = 8

/obj/item/ammo_casing/caseless/musket/shot
	name = "handfull of shot"
	desc = "A handful of metal ball bearings, with a paper wrapping"
	icon_state = "a41metal"
	projectile_type = /obj/projectile/bullet/pellet/musket
	pellets = 8
	randomspread = FALSE
	variance = 18
