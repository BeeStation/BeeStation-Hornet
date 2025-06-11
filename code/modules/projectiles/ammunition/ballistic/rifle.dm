// 7.62 (Nagant Rifle / Pipe Rifle)

/obj/item/ammo_casing/a762
	name = "7.62 bullet casing"
	desc = "A 7.62 bullet casing."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/projectile/bullet/a762

/obj/item/ammo_casing/a762/improv
	name = "a762 improvised cartridge"
	desc = "A handmade 7.62 cartidge, made from metal and some other scraps. It reeks of welding fuel."
	icon_state = "762improv"
	projectile_type = /obj/projectile/bullet/a762/weak
	gun_damage = 50

/obj/item/ammo_casing/a762/improv/hotload
	name = "7.62 hotload cartridge"
	desc = "A higher quality handmade 7.62 cartridge. It smells like charcoal."
	projectile_type = /obj/projectile/bullet/a762
	gun_damage = 50

/obj/item/ammo_casing/a762/enchanted
	projectile_type = /obj/projectile/bullet/a762_enchanted

// 5.56mm (M-90gl Carbine)

/obj/item/ammo_casing/a556
	name = "5.56mm bullet casing"
	desc = "A 5.56mm bullet casing."
	caliber = "a556"
	projectile_type = /obj/projectile/bullet/a556

// 40mm (Grenade Launcher)

/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = "40mm"
	icon_state = "40mmHE"
	projectile_type = /obj/projectile/bullet/a40mm
