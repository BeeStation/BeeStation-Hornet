/obj/item/twohanded/clockwork
	name = "Clockwork Weapon"
	desc = "Something"
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 4
	armour_penetration = 10
	materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = IS_SHARP
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	var/clockwork_desc = ""

/obj/item/twohanded/clockwork/brass_spear
	name = "brassspear"
	desc = "A strong spear made of brass."
	icon_state = "ratvarian_spear"
	embedding = list("embedded_impact_pain_multiplier" = 3)
	force = 12
	throwforce = 26
	armour_penetration = 18

/obj/item/twohanded/clockwork/brass_battlehammer
	name = "brass battle-hammer"
	desc = "A powerful hamer "
	icon_state = "ratvarian_spear"
	force = 24
	throwforce = 24
	armour_penetration = 6
	sharpness = IS_BLUNT
	attack_verb = list("bashed", "smitted", "hammered", "attacked")

/obj/item/twohanded/clockwork/brass_sword
	name = "brass longsword"
	desc = "A large sword made of brass."
	icon_state = "ratvarian_spear"
	force = 20
	throwforce = 20
	armour_penetration = 12
	attack_verb = list("attacked", "slashed", "cut", "torn", "gored")
