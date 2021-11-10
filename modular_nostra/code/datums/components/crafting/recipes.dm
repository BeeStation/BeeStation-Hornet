/datum/crafting_recipe/crowbar
	name = "Makeshift Crowbar"
	result = /obj/item/crowbar/makeshift
	reqs = list(/obj/item/stack/rods = 2)
	time = 40
	category = CAT_MISC

/datum/crafting_recipe/screwdriver
	name = "Makeshift Screwdriver"
	result = /obj/item/screwdriver/makeshift
	reqs = list(/obj/item/stack/rods = 1)
	tools = list(TOOL_WIRECUTTER)
	time = 20
	category = CAT_MISC

/datum/crafting_recipe/wirecutters
	name = "Makeshift Wirecutters"
	result = /obj/item/wirecutters/makeshift
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/stack/cable_coil = 2)
	tools = list(TOOL_CROWBAR, TOOL_WRENCH)
	time = 50
	category = CAT_MISC

/datum/crafting_recipe/wrench
	name = "Makeshift Wrench"
	result = /obj/item/wrench/makeshift
	reqs = list(/obj/item/stack/rods = 2)
	tools = list(TOOL_CROWBAR)
	time = 30
	category = CAT_MISC

/datum/crafting_recipe/emergency_welder
	name = "Makeshift Welder"
	result = /obj/item/weldingtool/makeshift
	reqs = list(/obj/item/stack/rods = 3,
				/obj/item/assembly/igniter = 1,
				/obj/item/tank/internals/emergency_oxygen = 1,
				/obj/item/stack/cable_coil = 5)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 30
	category = CAT_MISC
