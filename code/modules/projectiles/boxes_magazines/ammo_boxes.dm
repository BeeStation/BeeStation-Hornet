/obj/item/ammo_box/a357
	name = "speed loader (.357)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/a357/match
	name = "speed loader (.357 Match)"
	desc = "Designed to quickly reload revolvers. These rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/a357/match

/obj/item/ammo_box/c38
	name = "speed loader (.38)"
	desc = "Designed to quickly reload revolvers."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	multiple_sprites = 1
	custom_materials = list(/datum/material/iron = 20000)

/obj/item/ammo_box/c38/empty
	start_empty = TRUE

/obj/item/ammo_box/c38/trac
	name = "speed loader (.38 TRAC)"
	desc = "Designed to quickly reload revolvers. TRAC bullets embed a tracking implant within the target's body."
	ammo_type = /obj/item/ammo_casing/c38/trac

/obj/item/ammo_box/c38/match
	name = "speed loader (.38 Match)"
	desc = "Designed to quickly reload revolvers. These rounds are manufactured within extremely tight tolerances, making them easy to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match

/obj/item/ammo_box/c38/match/bouncy
	name = "speed loader (.38 Bouncy Rubber)"
	desc = "Designed to quickly reload revolvers. These rounds are incredibly bouncy and MOSTLY nonlethal, making them great to show off trickshots with."
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy

/obj/item/ammo_box/c38/dumdum
	name = "speed loader (.38 DumDum)"
	desc = "Designed to quickly reload revolvers. DumDum rounds shatter on impact and shred the target's innards, likely getting caught inside."
	ammo_type = /obj/item/ammo_casing/c38/dumdum

/obj/item/ammo_box/c38/hotshot
	name = "speed loader (.38 Hot Shot)"
	desc = "Designed to quickly reload revolvers. Hot Shot rounds contain an incendiary payload."
	ammo_type = /obj/item/ammo_casing/c38/hotshot

/obj/item/ammo_box/c38/iceblox
	name = "speed loader (.38 Iceblox)"
	desc = "Designed to quickly reload revolvers. Iceblox rounds contain a cryogenic payload."
	ammo_type = /obj/item/ammo_casing/c38/iceblox

/obj/item/ammo_box/c38/dart
	name = "speed loader (.38 Blister)"
	desc = "Designed to quickly reload revolvers. Blister rounds can be injected with up to 10 units of chemicals."
	ammo_type = /obj/item/ammo_casing/c38/dart

/obj/item/ammo_box/c38/emp
	name = "speed loader (.38 BLK_OUT)"
	desc = "Designed to quickly reload revolvers. 'BLK_OUT' rounds unleash a small EMP on impact."
	ammo_type = /obj/item/ammo_casing/c38/emp

/obj/item/ammo_box/c38/mime
	name = "speed loader (.38 finger)"
	max_ammo = 6
	desc = "Designed to quickly reload your fingers with lethal rounds."
	item_flags = DROPDEL
	ammo_type = /obj/item/ammo_casing/caseless/mime/lethal

/obj/item/ammo_box/pouch/c38
	name = "ammo pouch (.38)"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 4

/obj/item/ammo_box/c38_box
	name = "ammo box (.38)"
	icon_state = "38base"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6

/obj/item/ammo_box/c38_boxrubber
	name = "ammo box (.38 Rubber)"
	icon_state = "38rubber"
	ammo_type = /obj/item/ammo_casing/c38/match/bouncy
	max_ammo = 6

/obj/item/ammo_box/c38_boxtrac
	name = "ammo box (.38 TRAC)"
	icon_state = "38trac"
	ammo_type = /obj/item/ammo_casing/c38/trac
	max_ammo = 6

/obj/item/ammo_box/c38_boxhotshot
	name = "ammo box (.38 Hot Shot)"
	icon_state = "38hotshot"
	ammo_type = /obj/item/ammo_casing/c38/hotshot
	max_ammo = 6

/obj/item/ammo_box/c38_boxiceblox
	name = "ammo box (.38 Iceblox)"
	icon_state = "38iceblox"
	ammo_type = /obj/item/ammo_casing/c38/iceblox
	max_ammo = 6

/obj/item/ammo_box/c38_boxdumdum
	name = "ammo box (.38 DumDum)"
	icon_state = "38dumdum"
	ammo_type = /obj/projectile/bullet/c38/dumdum
	max_ammo = 6

/obj/item/ammo_box/c38_boxmatch
	name = "ammo box (.38 Match)"
	icon_state = "38match"
	ammo_type = /obj/projectile/bullet/c38/match
	max_ammo = 6

/obj/item/ammo_box/pouch/c38/improv
	name = "ammo pouch (improv .38)"
	ammo_type = /obj/item/ammo_casing/c38/improv

/obj/item/ammo_box/c9mm
	name = "ammo box (9mm)"
	icon_state = "9mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 30

/obj/item/ammo_box/pouch/c9mm
	name = "ammo pouch (9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 6

/obj/item/ammo_box/pouch/c9mm/improv
	name = "ammo pouch (improv 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/improv

/obj/item/ammo_box/c10mm
	name = "ammo box (10mm)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 20

/obj/item/ammo_box/pouch/c10mm
	name = "ammo pouch (10mm)"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 4

/obj/item/ammo_box/pouch/c10mm/improv
	name = "ammo pouch (improv 10mm)"
	ammo_type = /obj/item/ammo_casing/c10mm/improv

/obj/item/ammo_box/c45
	name = "ammo box (.45)"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 20

/obj/item/ammo_box/c38/box
	name = "ammo box (.38)"
	desc = "A small pack of .38 cartridges"
	icon_state = "357OLD"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 7
	multiple_sprites = 1
	custom_materials = list(/datum/material/iron = 22000)
	bullet_cost = list(/datum/material/iron = 21000)
	base_cost = list(/datum/material/iron = 1000)

/obj/item/ammo_box/a40mm
	name = "ammo box (40mm grenades)"
	icon_state = "40mm"
	ammo_type = /obj/item/ammo_casing/a40mm
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_box/a762
	name = "stripper clip (7.62mm)"
	desc = "A stripper clip."
	icon_state = "762"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 5
	multiple_sprites = 1

/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mmR)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

/obj/item/ammo_box/foambox
	name = "ammo box (Foam Darts)"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foambox"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	max_ammo = 40
	custom_materials = list(/datum/material/iron = 500)

/obj/item/ammo_box/foambox/riot
	icon_state = "foambox_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	custom_materials = list(/datum/material/iron = 50000)

/obj/item/ammo_box/c46
	name = "ammo box (4.6x30mm)"
	icon_state = "46x30base"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 20

/obj/item/ammo_box/c46rubber
	name = "ammo box (4.6x30mm Rubber)"
	icon_state = "46x30rubber"
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber
	max_ammo = 20

/obj/item/ammo_box/c46ap
	name = "ammo box (4.6x30mm AP)"
	icon_state = "46x30ap"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap
	max_ammo = 20

/obj/item/ammo_box/c46inc
	name = "ammo box (4.6x30mm IC)"
	icon_state = "46x30ic"
	ammo_type = /obj/item/ammo_casing/c46x30mm/inc
	max_ammo = 20

/obj/item/ammo_box/c46improvised
	name = "ammo box (4.6x30mm Improvised)"
	icon_state = "46x30improvised"
	ammo_type = /obj/item/ammo_casing/c46x30mm/improvised
	max_ammo = 20
