
	/obj/item/mop/sharp
	desc = "A mop with a sharpened handle. Careful!"
	name = "sharpened mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 10
	throwforce = 15
	throw_speed = 5
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "stabbed", "shanked", "jousted")
	resistance_flags = FLAMMABLE
	sharpness = IS_SHARP
	sharpness = IS_SHARP
	armour_penetration = 10
	embedding = list("embedded_impact_pain_multiplier" = 3)

//Basically a slightly worse spear.

	/datum/crafting_recipe/sharpmop
	name = "Sharpened Mop"
	result = /obj/item/mop/sharp
	time = 30
	reqs = list(/obj/item/mop = 1,
						/obj/item/shard = 1)
	category = CAT_WEAPONRY
	tools = list(TOOL_WIRECUTTER)