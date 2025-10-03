// .357 (Syndie Revolver)

/obj/item/ammo_casing/a357
	name = ".357 bullet casing"
	desc = "A .357 bullet casing."
	caliber = "357"
	projectile_type = /obj/projectile/bullet/a357

/obj/item/ammo_casing/a357/match
	name = ".357 match bullet casing"
	desc = "A .357 bullet casing, manufactured to exceedingly high standards."
	projectile_type = /obj/projectile/bullet/a357/match

/obj/item/ammo_casing/a357/improv
	name = "improv .357 bullet casing"
	desc = "An improvised .357 bullet casing."
	projectile_type = /obj/projectile/bullet/a357
	variance = 8
	gun_damage = 50

// 7.62x38mmR (Nagant Revolver)

/obj/item/ammo_casing/n762
	name = "7.62x38mmR bullet casing"
	desc = "A 7.62x38mmR bullet casing."
	caliber = "n762"
	projectile_type = /obj/projectile/bullet/n762

// .38 (Detective's Gun)

/obj/item/ammo_casing/c38
	name = ".38 bullet casing"
	desc = "A .38 bullet casing."
	caliber = "38"
	projectile_type = /obj/projectile/bullet/c38

/obj/item/ammo_casing/c38/trac
	name = ".38 TRAC bullet casing"
	desc = "A .38 \"TRAC\" bullet casing."
	projectile_type = /obj/projectile/bullet/c38/trac

/obj/item/ammo_casing/c38/hotshot
	name = ".38 Hot Shot bullet casing"
	desc = "A .38 Hot Shot bullet casing."
	projectile_type = /obj/projectile/bullet/c38/hotshot

/obj/item/ammo_casing/c38/iceblox
	name = ".38 Iceblox bullet casing"
	desc = "A .38 Iceblox bullet casing."
	projectile_type = /obj/projectile/bullet/c38/iceblox

/obj/item/ammo_casing/c38/match
	name = ".38 Match bullet casing"
	desc = "A .38 bullet casing, manufactured to exceedingly high standards."
	projectile_type = /obj/projectile/bullet/c38/match

/obj/item/ammo_casing/c38/match/bouncy
	name = ".38 Bouncy Rubber bullet casing"
	desc = "A .38 bouncy rubber bullet casing, manufactured to exceedingly high standards."
	projectile_type = /obj/projectile/bullet/c38/match/bouncy

/obj/item/ammo_casing/c38/dumdum
	name = ".38 DumDum bullet casing"
	desc = "A .38 DumDum bullet casing."
	projectile_type = /obj/projectile/bullet/c38/dumdum

/obj/item/ammo_casing/c38/dart
	name = ".38 'Blister' bullet casing"
	desc = "A specialized .38 bullet casing that can be injected with up to 10 units of any chemical."
	icon_state = "sP-casing"
	projectile_type = /obj/projectile/bullet/dart/c38
	var/reagent_amount = 10

/obj/item/ammo_casing/c38/dart/Initialize(mapload)
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)

/obj/item/ammo_casing/c38/improv
	name = "improv .38 bullet casing"
	desc = "An improvised .38 bullet casing."
	projectile_type = /obj/projectile/bullet/c38
	variance = 5
	gun_damage = 50

/obj/item/ammo_casing/caseless/mime
	name = "invisible .38 bullet casing"
	icon_state = null
	desc = "You shouldn't be seeing this."
	caliber = "38"
	projectile_type = /obj/projectile/bullet/c38/mime
	exists = FALSE

/obj/item/ammo_casing/caseless/mime/lethal
	projectile_type = /obj/projectile/bullet/c38/mime_lethal
