// 10mm (Stechkin)

/obj/item/ammo_casing/c10mm
	name = "10mm bullet casing"
	desc = "A 10mm bullet casing."
	caliber = "10mm"
	projectile_type = /obj/projectile/bullet/c10mm

/obj/item/ammo_casing/c10mm/improv
	name = "improvised 10mm bullet casing"
	desc = "A handmade 10mm bullet casing."
	caliber = "10mm"
	projectile_type = /obj/projectile/bullet/c10mm/improv
	randomspread = TRUE
	variance = 10 //Shit ammo is inaccurate.

/obj/item/ammo_casing/c10mm/ap
	name = "10mm armor-piercing bullet casing"
	desc = "A 10mm armor-piercing bullet casing."
	projectile_type = /obj/projectile/bullet/c10mm_ap

/obj/item/ammo_casing/c10mm/hp
	name = "10mm hollow-point bullet casing"
	desc = "A 10mm hollow-point bullet casing."
	projectile_type = /obj/projectile/bullet/c10mm_hp

/obj/item/ammo_casing/c10mm/fire
	name = "10mm incendiary bullet casing"
	desc = "A 10mm incendiary bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c10mm

// 9mm (Stechkin APS)

/obj/item/ammo_casing/c9mm
	name = "9mm bullet casing"
	desc = "A 9mm bullet casing."
	caliber = "9mm"
	projectile_type = /obj/projectile/bullet/c9mm

/obj/item/ammo_casing/c9mm/improv
	name = "improvised 9mm bullet casing"
	desc = "A handmade 9mm bullet casing."
	randomspread = TRUE
	variance = 10 //Shit ammo is inaccurate.

/obj/item/ammo_casing/c9mm/ap
	name = "9mm armor-piercing bullet casing"
	desc = "A 9mm armor-piercing bullet casing."
	projectile_type =/obj/projectile/bullet/c9mm_ap

/obj/item/ammo_casing/c9mm/inc
	name = "9mm incendiary bullet casing"
	desc = "A 9mm incendiary bullet casing."
	projectile_type = /obj/projectile/bullet/incendiary/c9mm

/obj/item/ammo_casing/c9mm/hp
	name = "9mm hollow-point bullet casing"
	desc = "A 9mm hollow-point bullet casing."
	projectile_type = /obj/projectile/bullet/c9mm_hp

/obj/item/ammo_casing/c9mm/rubber
	name = "9mm rubber bullet casing"
	desc = "A 9mm rubber bullet casing."
	icon_state = "sP-casing"
	projectile_type = /obj/projectile/bullet/c9mm_rubber

/obj/item/ammo_casing/c9mm/laser
	name = "9mm NT-LC"
	desc = "A 9mm laser bullet casing."
	icon_state = "lc-casing"
	projectile_type = /obj/projectile/beam/laser/l9mm

/obj/item/ammo_casing/c9mm/disabler
	name = "9mm NT-DLC"
	desc = "A 9mm disabler bullet casing."
	icon_state = "dlc-casing"
	projectile_type = /obj/projectile/beam/laser/l9mm/disabler

// .50AE (Desert Eagle)

/obj/item/ammo_casing/a50AE
	name = ".50AE bullet casing"
	desc = "A .50AE bullet casing."
	caliber = ".50"
	projectile_type = /obj/projectile/bullet/a50AE

