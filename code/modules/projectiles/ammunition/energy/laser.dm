/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/projectile/beam/laser
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/gatlinggun
	e_cost = 10 WATT

/obj/item/ammo_casing/energy/lasergun
	projectile_type = /obj/projectile/beam/laser
	e_cost = 710 WATT
	select_name = "kill"

/obj/item/ammo_casing/energy/lasergun/cyborg
	e_cost = 1000 WATT

/obj/item/ammo_casing/energy/lasergun/repeater
	e_cost = 500 WATT

/obj/item/ammo_casing/energy/lasergun/captain
	e_cost = 1000 WATT

/obj/item/ammo_casing/energy/lasergun/old
	projectile_type = /obj/projectile/beam/laser
	e_cost = 2000 WATT
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/hos
	e_cost = 1200 WATT

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/projectile/beam/practice
	select_name = "practice"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/scatter
	projectile_type = /obj/projectile/beam/scatter
	pellets = 5
	variance = 25
	select_name = "scatter"

/obj/item/ammo_casing/energy/laser/scatter/disabler
	projectile_type = /obj/projectile/beam/disabler
	pellets = 3
	variance = 15
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/heavy
	projectile_type = /obj/projectile/beam/laser/heavylaser
	select_name = "anti-vehicle"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/ammo_casing/energy/laser/pulse
	projectile_type = /obj/projectile/beam/pulse
	e_cost = 2000 WATT
	select_name = "DESTROY"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/projectile/beam/lasertag/bluetag
	select_name = "bluetag"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/bluetag/update_overlays()
	. = ..()
	return

/obj/item/ammo_casing/energy/laser/bluetag/hitscan
	projectile_type = /obj/projectile/beam/lasertag/bluetag/hitscan

/obj/item/ammo_casing/energy/laser/bluetag/update_overlays()
	. = ..()
	return

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/projectile/beam/lasertag/redtag
	select_name = "redtag"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/redtag/hitscan
	projectile_type = /obj/projectile/beam/lasertag/redtag/hitscan

/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/projectile/beam/xray
	e_cost = 500 WATT
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/projectile/beam/mindflayer
	select_name = "MINDFUCK"
	fire_sound = 'sound/weapons/laser.ogg'
