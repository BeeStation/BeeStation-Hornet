/obj/item/ammo_casing/energy/wormhole
	projectile_type = /obj/item/projectile/beam/wormhole
	e_cost = 0
	harmful = FALSE
	fire_sound = 'sound/weapons/pulse3.ogg'
	select_name = "blue"
	//Weakref to the gun that shot us
	var/datum/weakref/gun

/obj/item/ammo_casing/energy/wormhole/orange
	projectile_type = /obj/item/projectile/beam/wormhole/orange
	select_name = "orange"

/obj/item/ammo_casing/energy/wormhole/Initialize(mapload, obj/item/gun/energy/wormhole_projector/wh)
	. = ..()
	gun = WEAKREF(wh)

/obj/item/ammo_casing/energy/wormhole/throw_proj()
	. = ..()
	if(istype(BB, /obj/item/projectile/beam/wormhole))
		var/obj/item/projectile/beam/wormhole/WH = BB
		WH.gun = gun
