
/// Structures crafting, should always be one_per_turf = TRUE, but it don't warrant it's own sub category yet

/datum/crafting_recipe/personal_locker
	name = "Personal Locker"
	result = /obj/structure/closet/secure_closet/personal/empty
	time = 10 SECONDS
	tools = list(TOOL_WIRECUTTER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/electronics/airlock = 1,
		/obj/item/stack/cable_coil = 2
	)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/shutters
	name = "Shutters"
	result = /obj/machinery/door/poddoor/shutters/preopen
	time = 10 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL, TOOL_WIRECUTTER, TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/electronics/airlock = 1
	)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/glassshutters
	name = "Windowed Shutters"
	result = /obj/machinery/door/poddoor/shutters/window/preopen
	time = 10 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL, TOOL_WIRECUTTER, TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/rglass = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/electronics/airlock = 1
	)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/radshutters
	name = "Radiation Shutters"
	result = /obj/machinery/door/poddoor/shutters/radiation/preopen
	time = 10 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL, TOOL_WIRECUTTER, TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/electronics/airlock = 1,
		/obj/item/stack/sheet/mineral/uranium = 2
	)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/blast_doors
	name = "Blast Door"
	result = /obj/machinery/door/poddoor/preopen
	time = 15 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL, TOOL_WIRECUTTER, TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/plasteel = 15,
		/obj/item/stack/cable_coil = 15,
		/obj/item/electronics/airlock = 1
	)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/showercurtain
	name = "Shower Curtains"
	result = /obj/structure/curtain
	time = 3 SECONDS
	tools = list(TOOL_SCREWDRIVER)
	reqs = 	list(
		/obj/item/stack/sheet/cotton/cloth = 2,
		/obj/item/stack/sheet/plastic = 2,
		/obj/item/stack/rods = 1
	)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/aquarium
	name = "Aquarium"
	result = /obj/structure/aquarium
	time = 7.5 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/iron = 15,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/aquarium_kit = 1
	)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/guillotine
	name = "Guillotine"
	result = /obj/structure/guillotine
	time = 15 SECONDS // Building a functioning guillotine takes time
	reqs = list(
		/obj/item/stack/sheet/plasteel = 3,
		/obj/item/stack/sheet/wood = 20,
		/obj/item/stack/cable_coil = 10
	)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WELDER)
	category = CAT_STRUCTURE
	dangerous_craft = TRUE
	one_per_turf = TRUE

/datum/crafting_recipe/mirror
	name = "Wall Mirror Frame"
	result = /obj/item/wallframe/mirror
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/silver = 1,
		/obj/item/stack/sheet/glass = 2
	)
	tools = list(TOOL_WRENCH)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/weightmachine
	name = "Chest press machine"
	result = /obj/structure/weightmachine
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/rods = 6,
		/obj/item/barbell/stacklifting = 1,
	)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/weightmachine/weightlifter
	name = "Inline bench press"
	result = /obj/structure/weightmachine/weightlifter
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/rods = 6,
		/obj/item/barbell = 1,
	)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

/datum/crafting_recipe/punching_bag
	name = "Punching bag"
	result = /obj/structure/punching_bag
	time = 6 SECONDS
	reqs = list(
	/obj/item/stack/sheet/cotton/cloth = 10,
	)
	tools = list(TOOL_WIRECUTTER)
	category = CAT_STRUCTURE
	one_per_turf = TRUE

