/obj/item/clothing/suit/space/swat
	name = "MK.I SWAT Suit"
	desc = "A tactical space suit first developed in a joint effort by the defunct IS-ERI and Nanotrasen in 20XX for military space operations. A tried and true workhorse, it is very difficult to move in but offers robust protection against all threats!"
	icon_state = "heavy"
	item_state = "swat_suit"
	allowed = list(
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/melee/tonfa,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals,
		/obj/item/knife/combat
	)
	armor = list(MELEE = 40,  BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 90, RAD = 20, FIRE = 100, ACID = 100, STAMINA = 60)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')
