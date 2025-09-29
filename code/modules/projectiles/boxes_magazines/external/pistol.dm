/obj/item/ammo_box/magazine/m10mm
	name = "pistol magazine (10mm)"
	desc = "A gun magazine."
	icon_state = "9x19p"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = list("10mm")
	max_ammo = 8
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m10mm/fire
	name = "pistol magazine (10mm incendiary)"
	icon_state = "9x19pI"
	desc = "A gun magazine. Loaded with rounds which ignite the target."
	ammo_type = /obj/item/ammo_casing/c10mm/fire

/obj/item/ammo_box/magazine/m10mm/hp
	name = "pistol magazine (10mm HP)"
	icon_state = "9x19pH"
	desc= "A gun magazine. Loaded with hollow-point rounds, extremely effective against unarmored targets, but nearly useless against protective clothing."
	ammo_type = /obj/item/ammo_casing/c10mm/hp

/obj/item/ammo_box/magazine/m10mm/ap
	name = "pistol magazine (10mm AP)"
	icon_state = "9x19pA"
	desc= "A gun magazine. Loaded with rounds which penetrate armour, but are less effective against normal targets."
	ammo_type = /obj/item/ammo_casing/c10mm/ap

/obj/item/ammo_box/magazine/m45
	name = "handgun magazine (.45)"
	icon_state = "45-8"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = list(".45")
	max_ammo = 8

/obj/item/ammo_box/magazine/m45/update_icon()
	..()
	if (ammo_count() >= 8)
		icon_state = "45-8"
	else
		icon_state = "45-[ammo_count()]"

/obj/item/ammo_box/magazine/pistolm9mm
	name = "pistol magazine (9mm)"
	icon_state = "9x19p-8"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = list("9mm")
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/ap
	name = "pistol magazine (9mm AP)"
	icon_state = "9x19p-8"
	ammo_type = /obj/item/ammo_casing/c9mm/ap
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/inc
	name = "pistol magazine (9mm incendiary)"
	icon_state = "9x19p-8"
	ammo_type = /obj/item/ammo_casing/c9mm/inc
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/hp
	name = "pistol magazine (9mm HP)"
	icon_state = "9x19p-8"
	ammo_type = /obj/item/ammo_casing/c9mm/hp
	max_ammo = 15

/obj/item/ammo_box/magazine/pistolm9mm/update_icon()
	..()
	icon_state = "9x19p-[ammo_count() ? "8" : "0"]"

/obj/item/ammo_box/magazine/m50
	name = "handgun magazine (.50ae)"
	icon_state = "50ae"
	ammo_type = /obj/item/ammo_casing/a50AE
	caliber = list(".50")
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/magazine/x200law
	name = "pistol magazine (x200 LAW)"
	icon_state = "x200law-8"
	desc= "A gun magazine for x200 LAW ammo. The standard law-enforcement loading of the popular NPS-10. Has a handy digital counter built into it."
	ammo_type = /obj/item/ammo_casing/x200law
	caliber = list("x200 LAW")
	max_ammo = 8
	multiple_sprites = 1

/obj/item/ammo_box/magazine/x200law/update_icon()
	..()
	icon_state = "x200law-[CEILING(ammo_count(),2)]"

/obj/item/ammo_box/magazine/x200law/examine(mob/user)
	. = ..()
	. += span_notice("<i>You could examine it more thoroughly...</i>")

/obj/item/ammo_box/magazine/x200law/examine_more(mob/user)
	. = ..()
	. += "<i>Loaded with 8 shots of NT custom x200 LAW; steel-jacketed, low-velocity ammo. The lubricant they had to use because of the steel cartridges stains your hands terribly. Of course it's proprietary...</i>"

/obj/item/ammo_box/magazine/x200law/empty
	start_empty = TRUE
