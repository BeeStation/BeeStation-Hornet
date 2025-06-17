
/**********************Mineral ores**************************/

/* Uranium ore */

/obj/item/stack/ore/uranium
	name = "uranium ore"
	desc = "The fuel of the late 20th century."
	icon_state = "uranium_ore"
	item_state = "uranium_ore"
	singular_name = "uranium ore chunk"
	points = 38
	material_flags = NONE
	mats_per_unit = list(/datum/material/uranium=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/uranium
	scan_state = "rock_Uranium"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/uranium

STACKSIZE_MACRO(/obj/item/stack/ore/uranium)

/* Iron ore */

/obj/item/stack/ore/iron
	name = "iron ore"
	desc = "The most abundant material around, yet so scarce."
	icon_state = "iron_ore"
	item_state = "iron_ore"
	singular_name = "iron ore chunk"
	points = 2
	mats_per_unit = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/iron
	scan_state = "rock_Iron"
	spreadChance = 20
	merge_type = /obj/item/stack/ore/iron

STACKSIZE_MACRO(/obj/item/stack/ore/iron)

/* "Glass" ore */

/obj/item/stack/ore/glass
	name = "sand pile"
	desc = "A pile of sandy quartz."
	icon_state = "sand"
	item_state = "sand"
	singular_name = "sand pile"
	points = 2
	mats_per_unit = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/glass
	w_class = WEIGHT_CLASS_TINY
	merge_type = /obj/item/stack/ore/glass

/obj/item/stack/ore/glass/get_recipes()
	return GLOB.sand_recipes

/obj/item/stack/ore/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !ishuman(hit_atom))
		return
	var/mob/living/carbon/human/C = hit_atom
	if(C.is_eyes_covered())
		C.visible_message(span_danger("[C]'s eye protection blocks the sand!"), span_warning("Your eye protection blocks the sand!"))
		return
	C.adjust_blurriness(6)
	C.adjustStaminaLoss(15)//the pain from your eyes burning does stamina damage
	C.confused += 5
	to_chat(C, span_userdanger("\The [src] gets into your eyes! The pain, it burns!"))
	qdel(src)

/obj/item/stack/ore/glass/ex_act(severity, target)
	if (severity == EXPLODE_NONE)
		return
	qdel(src)

GLOBAL_LIST_INIT(sand_recipes, list(\
		new /datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_TOOLS), \
		new /datum/stack_recipe("sandstone", /obj/item/stack/sheet/mineral/sandstone, 1, 1, 50, crafting_flags = NONE, category = CAT_MISC),\
		new /datum/stack_recipe("aesthetic volcanic floor tile", /obj/item/stack/tile/basalt, 2, 1, 50, crafting_flags = NONE, category = CAT_TILES)\
))

STACKSIZE_MACRO(/obj/item/stack/ore/glass)

/* Glass variant ore */

/obj/item/stack/ore/glass/basalt
	name = "volcanic ash"
	desc = "A pile of dark, smooth volcanic ash."
	icon_state = "volcanic_sand"
	icon_state = "volcanic_sand"
	singular_name = "volcanic ash pile"
	merge_type = /obj/item/stack/ore/glass/basalt

STACKSIZE_MACRO(/obj/item/stack/ore/glass/basalt)

/* Plasma ore */

/obj/item/stack/ore/plasma
	name = "plasma ore"
	desc = "The fuel of our times."
	icon_state = "plasma_ore"
	item_state = "plasma_ore"
	singular_name = "plasma ore chunk"
	points = 19
	mats_per_unit = list(/datum/material/plasma=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/plasma
	scan_state = "rock_Plasma"
	spreadChance = 8
	merge_type = /obj/item/stack/ore/plasma

/obj/item/stack/ore/plasma/welder_act(mob/living/user, obj/item/I)
	to_chat(user, span_warning("You can't hit a high enough temperature to smelt [src] properly!"))
	return TRUE

STACKSIZE_MACRO(/obj/item/stack/ore/plasma)

/* Copper ore */

/obj/item/stack/ore/copper
	name = "copper ore"
	desc = "The base for all your electronics."
	icon_state = "copper_ore"
	item_state = "Copper_ore"
	singular_name = "Copper ore chunk"
	points = 6
	mats_per_unit = list(/datum/material/copper=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/copper
	scan_state = "rock_Copper"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/copper

STACKSIZE_MACRO(/obj/item/stack/ore/copper)

/* Silver ore */

/obj/item/stack/ore/silver
	name = "silver ore"
	desc = "Purity in mineral form."
	icon_state = "silver_ore"
	item_state = "silver_ore"
	singular_name = "silver ore chunk"
	points = 20
	mats_per_unit = list(/datum/material/silver=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/silver
	scan_state = "rock_Silver"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/silver

STACKSIZE_MACRO(/obj/item/stack/ore/silver)

/* Gold ore */

/obj/item/stack/ore/gold
	name = "gold ore"
	desc = "A display of wealth and power."
	icon_state = "gold_ore"
	icon_state = "gold_ore"
	singular_name = "gold ore chunk"
	points = 23
	mats_per_unit = list(/datum/material/gold=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/gold
	scan_state = "rock_Gold"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/gold

STACKSIZE_MACRO(/obj/item/stack/ore/gold)

/* Diamonds ore */

/obj/item/stack/ore/diamond
	name = "diamond ore"
	desc = "Densly packed coal, wonder how it got here..."
	icon_state = "diamond_ore"
	item_state = "diamond_ore"
	singular_name = "diamond ore chunk"
	points = 63
	mats_per_unit = list(/datum/material/diamond=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/diamond
	scan_state = "rock_Diamond"
	merge_type = /obj/item/stack/ore/diamond

STACKSIZE_MACRO(/obj/item/stack/ore/diamond)

/* Bananium ore */

/obj/item/stack/ore/bananium
	name = "bananium ore"
	desc = "Unlike bananas, this ore is rather funny."
	icon_state = "bananium_ore"
	item_state = "bananium_ore"
	singular_name = "bananium ore chunk"
	points = 75
	mats_per_unit = list(/datum/material/bananium=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/bananium
	scan_state = "rock_Bananium"
	merge_type = /obj/item/stack/ore/bananium

STACKSIZE_MACRO(/obj/item/stack/ore/bananium)

/* Titanium ore */

/obj/item/stack/ore/titanium
	name = "titanium ore"
	desc = "A strong material for ship construction."
	icon_state = "titanium_ore"
	item_state = "titanium_ore"
	singular_name = "titanium ore chunk"
	points = 38
	mats_per_unit = list(/datum/material/titanium=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/titanium
	scan_state = "rock_Titanium"
	spreadChance = 5
	merge_type = /obj/item/stack/ore/titanium

STACKSIZE_MACRO(/obj/item/stack/ore/titanium)

/* Slag... ore? */

/obj/item/stack/ore/slag
	name = "slag"
	desc = "Completely useless."
	icon_state = "slag"
	item_state = "slag"
	singular_name = "slag chunk"
	merge_type = /obj/item/stack/ore/slag

STACKSIZE_MACRO(/obj/item/stack/ore/slag)
