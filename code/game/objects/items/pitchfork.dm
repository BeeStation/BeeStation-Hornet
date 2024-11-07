/obj/item/pitchfork
	icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	block_level = 1
	block_upgrade_walk = 1
	w_class = WEIGHT_CLASS_BULKY
	item_flags = ISWEAPON
	attack_verb_continuous = list("attacks", "impales", "pierces")
	attack_verb_simple = list("attack", "impale", "pierce")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP
	bleed_force = BLEED_CUT
	max_integrity = 200
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30, STAMINA = 0, BLEED = 0)
	resistance_flags = FIRE_PROOF

/obj/item/pitchfork/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=7, force_wielded=15, block_power_wielded=25, icon_wielded="pitchfork1")

/obj/item/pitchfork/update_icon()
	icon_state = "pitchfork0"
	..()
