/obj/item/ammo_casing/energy/ion
	projectile_type = /obj/item/projectile/ion
	select_name = "ion"
	fire_sound = 'sound/weapons/ionrifle.ogg'

/obj/item/ammo_casing/energy/declone
	projectile_type = /obj/item/projectile/energy/declone
	select_name = "declone"
	fire_sound = 'sound/weapons/pulse3.ogg'
	
/obj/item/ammo_casing/energy/declone/weak
	projectile_type = /obj/item/projectile/energy/declone/weak

/obj/item/ammo_casing/energy/flora
	fire_sound = 'sound/effects/stealthoff.ogg'
	harmful = FALSE

/obj/item/ammo_casing/energy/flora/yield
	projectile_type = /obj/item/projectile/energy/florayield
	select_name = "yield"

/obj/item/ammo_casing/energy/flora/mut
	projectile_type = /obj/item/projectile/energy/floramut
	select_name = "mutation"

/obj/item/ammo_casing/energy/temp
	projectile_type = /obj/item/projectile/temp
	select_name = "freeze"
	e_cost = 100
	fire_sound = 'sound/weapons/pulse3.ogg'

/obj/item/ammo_casing/energy/temp/hot
	projectile_type = /obj/item/projectile/temp/hot
	select_name = "bake"

/obj/item/ammo_casing/energy/meteor
	projectile_type = /obj/item/projectile/meteor
	select_name = "goddamn meteor"

/obj/item/ammo_casing/energy/net
	projectile_type = /obj/item/projectile/energy/net
	select_name = "netting"
	pellets = 6
	variance = 40
	harmful = FALSE

/obj/item/ammo_casing/energy/trap
	projectile_type = /obj/item/projectile/energy/trap
	select_name = "snare"
	harmful = FALSE

/obj/item/ammo_casing/energy/instakill
	projectile_type = /obj/item/projectile/beam/instakill
	e_cost = 0
	select_name = "DESTROY"

/obj/item/ammo_casing/energy/instakill/blue
	projectile_type = /obj/item/projectile/beam/instakill/blue

/obj/item/ammo_casing/energy/instakill/red
	projectile_type = /obj/item/projectile/beam/instakill/red

/obj/item/ammo_casing/energy/tesla_revolver
	fire_sound = 'sound/magic/lightningbolt.ogg'
	e_cost = 200
	select_name = "stun"
	projectile_type = /obj/item/projectile/energy/tesla/revolver

// HoS ballistic gun settings

/obj/item/ammo_casing/energy/hos
	fire_sound = 'sound/weapons/revolver357shot.ogg'
	name = "integrated miniature 3D printer"
	desc = "A miniaturised 3D printer, capable of running off an energy gun cell to produce .454 bullets for immediate use."
	select_name = "boolet"
	projectile_type = /obj/item/projectile/bullet/hos

/obj/item/ammo_casing/energy/hos/hv
	fire_sound = 'sound/weapons/rifleshot.ogg'
	e_cost = 150
	select_name = ".454HV"
	projectile_type = /obj/item/projectile/bullet/hos/hv

/obj/item/ammo_casing/energy/hos/trac
	e_cost = 400
	select_name = ".454TRAC"
	projectile_type = /obj/item/projectile/bullet/c38/trac/hos

/obj/item/ammo_casing/energy/hos/light
	fire_sound = 'sound/weapons/gunshot.ogg'
	e_cost = 100
	select_name = ".454AR"
	pellets = 3
	variance = 20
	projectile_type = /obj/item/projectile/bullet/pellet/hos

/obj/item/ammo_casing/energy/hos/breach
	fire_sound = 'sound/weapons/gunshot.ogg'
	e_cost = 120
	select_name = ".454B"
	projectile_type = /obj/item/projectile/bullet/shotgun_breaching/hos

/obj/item/ammo_casing/energy/temp/hos
	e_cost = 60

/obj/item/ammo_casing/energy/ion/hos
	e_cost = 200
