
/obj/item/mop/sharp
	desc = "A mop with a sharpened handle. Careful!"
	name = "sharpened mop"
	force = 10
	throwforce = 15
	throw_speed = 4
	attack_verb = list("mopped", "stabbed", "shanked", "jousted")
	sharpness = IS_SHARP
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
