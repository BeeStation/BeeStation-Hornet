// HoS ballistic gun settings, these are technically energy projectiles, even if they shoot ballistic projectiles

/obj/item/ammo_casing/energy/ballistic/hos // Calling it "energy ballistic" is a fucking abomination, but it's technically both
	fire_sound = 'sound/weapons/revolver357shot.ogg'
	name = "integrated miniature 3D printer"
	desc = "A miniaturised 3D printer, capable of running off an energy gun cell to produce printed bullets for immediate use."
	e_cost = 800
	select_name = "Lethals"
	projectile_type = /obj/projectile/bullet/hos

/obj/item/ammo_casing/energy/ballistic/hos/pellet
	fire_sound = 'sound/weapons/gunshot.ogg'
	e_cost = 700
	select_name = "Less-Lethals"
	projectile_type = /obj/projectile/bullet/hos/pellet

/obj/item/ammo_casing/energy/ballistic/hos/breach
	fire_sound = 'sound/weapons/gunshot.ogg'
	e_cost = 3000
	select_name = "Breaching"
	projectile_type = /obj/projectile/bullet/shotgun_breaching/hos
