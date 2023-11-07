// 7.62 (Nagant Rifle)

/obj/item/ammo_casing/a762
	name = "7.62 bullet casing"
	desc = "A 7.62 bullet casing."
	icon_state = "762-casing"
	caliber = "a762"
	projectile_type = /obj/projectile/bullet/a762

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

// .41 Cal (Pipe Pistol/Rifle)
/obj/item/ammo_casing/a41
	name = ".41 cartridge"
	desc = "A .41 caliber brass cartridge"
	caliber = "a41"
	icon_state = "a41metal"
	projectile_type = /obj/projectile/bullet/a41

/obj/item/ammo_casing/a41/improv
	name = ".41 improvised cartridge"
	desc = "A handmade .41 caliber cartidge, made from metal and some other scraps. It reeks of welding fuel."
	icon_state = "a41improv"
	projectile_type = /obj/projectile/bullet/a41/improv

/obj/item/ammo_casing/a41/improv/softslug
	name = ".41 copper-core cartridge"
	desc = "A handmade .41 cartridge. The bullet has been replaced with a bored out makeshift copper slug."
	projectile_type = /obj/projectile/bullet/a41/improv/copper

/obj/item/ammo_casing/a41/improv/hotload
	name = ".41 hotload cartridge"
	desc = "A higher quality handmade .41 cartridge. It smells like charcoal."
	projectile_type = /obj/projectile/bullet/a41/improv/hotload
