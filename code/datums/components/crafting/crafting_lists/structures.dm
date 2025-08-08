
/// Structures crafting, should always be CRAFT_ONE_PER_TURF, but it don't warrant it's own sub category yet

/datum/crafting_recipe/personal_locker
	name = "Personal Locker"
	result = /obj/structure/closet/secure_closet/personal/empty
	time = 10 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/electronics/airlock = 1,
		/obj/item/stack/cable_coil = 2
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/shutters
	name = "Shutters"
	result = /obj/machinery/door/poddoor/shutters/preopen
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL, TOOL_WIRECUTTER, TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/electronics/airlock = 1
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/glassshutters
	name = "Windowed Shutters"
	result = /obj/machinery/door/poddoor/shutters/window/preopen
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL, TOOL_WIRECUTTER, TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/rglass = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/electronics/airlock = 1
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/radshutters
	name = "Radiation Shutters"
	result = /obj/machinery/door/poddoor/shutters/radiation/preopen
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL, TOOL_WIRECUTTER, TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/electronics/airlock = 1,
		/obj/item/stack/sheet/mineral/uranium = 2
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/blast_doors
	name = "Blast Door"
	result = /obj/machinery/door/poddoor/preopen
	time = 15 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL, TOOL_WIRECUTTER, TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/plasteel = 15,
		/obj/item/stack/cable_coil = 15,
		/obj/item/electronics/airlock = 1
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/showercurtain
	name = "Shower Curtains"
	result = /obj/structure/curtain
	time = 3 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = 	list(
		/obj/item/stack/sheet/cotton/cloth = 2,
		/obj/item/stack/sheet/plastic = 2,
		/obj/item/stack/rods = 1
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/aquarium
	name = "Aquarium"
	result = /obj/structure/aquarium
	time = 7.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/iron = 15,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/aquarium_kit = 1
	)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/mod_core_standard
	name = "MOD core (Standard)"
	result = /obj/item/mod/core/standard
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 10 SECONDS
	reqs = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/organ/heart/ethereal = 1,
		)
	category = CAT_MISC

/datum/crafting_recipe/mod_core_ethereal
	name = "MOD core (Ethereal)"
	result = /obj/item/mod/core/ethereal
	tool_behaviors = list(TOOL_SCREWDRIVER)
	time = 10 SECONDS
	reqs = list(
		/datum/reagent/consumable/liquidelectricity = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/syringe = 1,
		)
	category = CAT_MISC

/datum/crafting_recipe/guillotine
	name = "Guillotine"
	result = /obj/structure/guillotine
	time = 15 SECONDS // Building a functioning guillotine takes time
	reqs = list(
		/obj/item/stack/sheet/plasteel = 3,
		/obj/item/stack/sheet/wood = 20,
		/obj/item/stack/cable_coil = 10
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WELDER)
	category = CAT_STRUCTURE
	dangerous_craft = TRUE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/mirror
	name = "Wall Mirror Frame"
	result = /obj/item/wallframe/mirror
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/sheet/mineral/silver = 1,
		/obj/item/stack/sheet/glass = 2
	)
	tool_behaviors = list(TOOL_WRENCH)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_ONE_PER_TURF

/datum/crafting_recipe/blackcoffin
	name = "Black Coffin"
	result = /obj/structure/closet/crate/coffin/blackcoffin
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/cotton/cloth = 1,
		/obj/item/stack/sheet/wood = 5,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 15 SECONDS
	category = CAT_FURNITURE

/datum/crafting_recipe/securecoffin
	name = "Secure Coffin"
	result = /obj/structure/closet/crate/coffin/securecoffin
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/iron = 5,
	)
	time = 15 SECONDS
	category = CAT_FURNITURE

/datum/crafting_recipe/metalcoffin
	name = "Metal Coffin"
	result = /obj/structure/closet/crate/coffin/metalcoffin
	tool_behaviors = list(TOOL_WRENCH, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 6,
		/obj/item/stack/rods = 2,
	)
	time = 10 SECONDS
	category = CAT_FURNITURE

/datum/crafting_recipe/air_sensor
	name = "Monitored Air Sensor"
	result = /obj/item/air_sensor
	time = 1 SECONDS
	reqs = list(
		/obj/item/analyzer = 1,
		/obj/item/stack/sheet/iron = 1,
		)
	blacklist = list(/obj/item/analyzer/ranged)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	category = CAT_ATMOSPHERIC

/datum/crafting_recipe/weightmachine
	name = "Chest press machine"
	result = /obj/structure/weightmachine
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/rods = 6,
		/obj/item/barbell/stacklifting = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/weightmachine/weightlifter
	name = "Inline bench press"
	result = /obj/structure/weightmachine/weightlifter
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/rods = 6,
		/obj/item/barbell = 1,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

/datum/crafting_recipe/punching_bag
	name = "Punching bag"
	result = /obj/structure/punching_bag
	time = 6 SECONDS
	reqs = list(
	/obj/item/stack/sheet/cotton/cloth = 10,
	)
	tool_behaviors = list(TOOL_WIRECUTTER)
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF
