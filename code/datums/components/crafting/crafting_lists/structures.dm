
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

/datum/crafting_recipe/blackcoffin
	name = "Black Coffin"
	result = /obj/structure/closet/crate/coffin/blackcoffin
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/cotton/cloth = 1,
		/obj/item/stack/sheet/mineral/wood = 5,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 15 SECONDS
	category = CAT_STRUCTURE

/datum/crafting_recipe/securecoffin
	name = "Secure Coffin"
	result = /obj/structure/closet/crate/coffin/securecoffin
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/iron = 5,
	)
	time = 15 SECONDS
	category = CAT_STRUCTURE

/datum/crafting_recipe/meatcoffin
	name = "Meat Coffin"
	result = /obj/structure/closet/crate/coffin/meatcoffin
	tools = list(TOOL_KNIFE, TOOL_ROLLINGPIN)
	reqs = list(
		/obj/item/food/meat/slab = 5,
		/obj/item/restraints/handcuffs/cable = 1,
	)
	time = 15 SECONDS
	category = CAT_STRUCTURE
	always_available = FALSE //only for the elite vampires

/datum/crafting_recipe/metalcoffin
	name = "Metal Coffin"
	result = /obj/structure/closet/crate/coffin/metalcoffin
	tools = list(TOOL_WRENCH, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 6,
		/obj/item/stack/rods = 2,
	)
	time = 10 SECONDS
	category = CAT_STRUCTURE

/datum/crafting_recipe/vassalrack
	name = "Persuasion Rack"
	result = /obj/structure/bloodsucker/vassalrack
	tools = list(TOOL_WELDER, TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 3,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/restraints/handcuffs/cable = 2,
	)
	time = 15 SECONDS
	category = CAT_STRUCTURE
	always_available = FALSE

/datum/crafting_recipe/candelabrum
	name = "Candelabrum"
	result = /obj/structure/bloodsucker/candelabrum
	tools = list(TOOL_WELDER, TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/iron = 3,
		/obj/item/stack/rods = 1,
		/obj/item/candle = 1,
	)
	time = 10 SECONDS
	category = CAT_STRUCTURE
	always_available = FALSE

/datum/crafting_recipe/bloodthrone
	name = "Blood Throne"
	result = /obj/structure/bloodsucker/bloodthrone
	tools = list(TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/cotton/cloth = 3,
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/sheet/mineral/wood = 1,
	)
	time = 5 SECONDS
	category = CAT_STRUCTURE
	always_available = FALSE
