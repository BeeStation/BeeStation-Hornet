/datum/crafting_recipe/iron_butt
	name = "Prosthetic Butt"
	result = /obj/item/organ/butt/iron
	reqs = list(	/obj/item/stack/sheet/iron = 6,
					/obj/item/stack/cable_coil = 1)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	time = 15
	category = CAT_MISC

/datum/crafting_recipe/yes_slip
	name = "Yes-Slip Shoes"
	result = /obj/item/clothing/shoes/yes_slip
	time = 20
	reqs = list(	/obj/item/reagent_containers/food/snacks/grown/banana = 2,
					/datum/reagent/lube = 100,
					/obj/item/stack/cable_coil = 1)
	tools = list(/obj/item/reagent_containers/food/snacks/grown/banana)
	category = CAT_CLOTHING
