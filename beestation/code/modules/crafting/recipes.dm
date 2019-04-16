// Shank - Makeshift weapon that can embed on throw
/datum/crafting_recipe/shank
	name = "Shank"
	reqs = list(/obj/item/shard = 1,
					/obj/item/stack/cable_coil = 10) // 1 glass shard + 10 cable; needs a wirecutter to snip the cable.
	result = /obj/item/melee/shank
	tools = list(TOOL_WIRECUTTER)
	time = 20
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = TRUE
