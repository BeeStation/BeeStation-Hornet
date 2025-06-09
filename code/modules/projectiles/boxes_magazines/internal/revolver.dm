/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/rev38/rubber
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy

/obj/item/ammo_box/magazine/internal/cylinder/rev38/random
	start_empty = TRUE //We have to handle adding dynamic ammo types on init

/obj/item/ammo_box/magazine/internal/cylinder/rev38/random/Initialize(mapload)
	var/obj/item/ammo_casing/c38/boolet
	var/list/possible_boolets = typesof(/obj/item/ammo_casing/c38) -/obj/item/ammo_casing/c38/dart -/obj/item/ammo_casing/caseless/mime
	for(var/i in 1 to max_ammo)
		boolet = pick(possible_boolets)
		stored_ammo += new boolet(src)
	. = ..()

/obj/item/ammo_box/magazine/internal/der38
	name = "derringer internal chambering"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 2

/obj/item/ammo_box/magazine/internal/der38/twelveshooter
	max_ammo = 12

/obj/item/ammo_box/magazine/internal/cylinder/rev762
	name = "\improper Nagant revolver cylinder"
	ammo_type = /obj/item/ammo_casing/n762
	caliber = "n762"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/rus357
	name = "\improper Russian revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 6
	multiload = FALSE

/obj/item/ammo_box/magazine/internal/rus357/Initialize(mapload)
	stored_ammo += new ammo_type(src)
	. = ..()
