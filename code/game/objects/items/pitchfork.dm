/obj/item/pitchfork
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "pitchfork"
	desc = "A simple tool used for moving hay."
	force = 7
	throwforce = 15
	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK

	w_class = WEIGHT_CLASS_BULKY
	item_flags = ISWEAPON
	attack_verb_continuous = list("attacks", "impales", "pierces")
	attack_verb_simple = list("attack", "impale", "pierce")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_CUT
	max_integrity = 200
	armor_type = /datum/armor/item_pitchfork
	resistance_flags = FIRE_PROOF


/datum/armor/item_pitchfork
	fire = 100
	acid = 30

/obj/item/pitchfork/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=7, force_wielded=15, block_power_wielded=25, icon_wielded="pitchfork1")

/obj/item/pitchfork/update_icon()
	icon_state = "pitchfork0"
	..()

/obj/item/pitchfork/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(ISWIELDED(src))
		return ..()
	return FALSE
