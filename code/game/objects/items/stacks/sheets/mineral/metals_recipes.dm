/* Iron */

GLOBAL_LIST_INIT(metal_recipes, list ( \
	new/datum/stack_recipe("stool",										/obj/structure/chair/stool, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("bar stool",									/obj/structure/chair/stool/bar, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	new/datum/stack_recipe("chair",										/obj/structure/chair, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \

	null, \
	new/datum/stack_recipe_list("office chairs", list( \
		new/datum/stack_recipe("dark office chair",						/obj/structure/chair/office, 5, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
		new/datum/stack_recipe("light office chair",					/obj/structure/chair/office/light, 5, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
		)), \
	new/datum/stack_recipe_list("beds", list( \
		new/datum/stack_recipe("single bed",							/obj/structure/bed, 2, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new/datum/stack_recipe("double bed",							/obj/structure/bed/double, 2, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
		)), \
	new/datum/stack_recipe_list("comfy chairs", list( \
		new/datum/stack_recipe("comfy chair",							/obj/structure/chair/fancy/comfy, 2, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new/datum/stack_recipe("corporate chair",						/obj/structure/chair/fancy/corp, 2, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new/datum/stack_recipe("shuttle seat",							/obj/structure/chair/fancy/shuttle, 2, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		)), \
	new/datum/stack_recipe_list("old sofa", list(
		new /datum/stack_recipe("old sofa (middle)",					/obj/structure/chair/fancy/sofa/old, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("old sofa (left)",						/obj/structure/chair/fancy/sofa/old/left, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("old sofa (right)",						/obj/structure/chair/fancy/sofa/old/right, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("old sofa (concave corner)",			/obj/structure/chair/fancy/sofa/old/corner/concave, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("old sofa (convex corner)",				/obj/structure/chair/fancy/sofa/old/corner/convex, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		)), \
	new /datum/stack_recipe_list("corporate sofas", list( \
		new /datum/stack_recipe("corporate sofa (middle)",				/obj/structure/chair/fancy/sofa/corp, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("corporate sofa (left)",				/obj/structure/chair/fancy/sofa/corp/left, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("corporate sofa (right)",				/obj/structure/chair/fancy/sofa/corp/right, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("corporate sofa (concave corner)",		/obj/structure/chair/fancy/sofa/corp/corner/concave, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("corporate sofa (convex corner)",		/obj/structure/chair/fancy/sofa/corp/corner/convex, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		)), \
	new /datum/stack_recipe_list("benches", list( \
		new /datum/stack_recipe("bench (middle)",						/obj/structure/chair/fancy/bench, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("bench (left)",							/obj/structure/chair/fancy/bench/left, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("bench (right)",						/obj/structure/chair/fancy/bench/right, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		)), \
	new /datum/stack_recipe_list("corporate benches", list( \
		new /datum/stack_recipe("corporate bench (middle)",				/obj/structure/chair/fancy/bench/corporate, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("corporate bench (left)",				/obj/structure/chair/fancy/bench/corporate/left, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		new /datum/stack_recipe("corporate bench (right)",				/obj/structure/chair/fancy/bench/corporate/right, 1, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
		)),
	null, \
	new/datum/stack_recipe("rack parts",								/obj/item/rack_parts), \
	new/datum/stack_recipe("closet",									/obj/structure/closet, 2, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
	null, \
	new/datum/stack_recipe("canister",									/obj/machinery/portable_atmospherics/canister, 10, one_per_turf = TRUE, on_floor = TRUE, time = 1.5 SECONDS), \
	null, \
	new/datum/stack_recipe("floor tile",								/obj/item/stack/tile/plasteel, 1, 4, 20), \
	new/datum/stack_recipe("iron rod",									/obj/item/stack/rods, 1, 2, 60), \
	null, \
	new/datum/stack_recipe("wall girders",								/obj/structure/girder, 2, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	null, \
	new/datum/stack_recipe("computer frame",							/obj/structure/frame/computer, 5, one_per_turf = TRUE, on_floor = TRUE, time = 2.5 SECONDS), \
	new/datum/stack_recipe("modular console",							/obj/machinery/modular_computer/console/buildable/, 10, one_per_turf = TRUE, on_floor = TRUE, time = 2.5 SECONDS), \
	new/datum/stack_recipe("machine frame",								/obj/structure/frame/machine, 5, one_per_turf = TRUE, on_floor = TRUE, time = 2.5 SECONDS), \
	null, \
	new /datum/stack_recipe_list("airlock assemblies", list( \
		new /datum/stack_recipe("standard airlock assembly",			/obj/structure/door_assembly, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("public airlock assembly",				/obj/structure/door_assembly/door_assembly_public, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("command airlock assembly",				/obj/structure/door_assembly/door_assembly_com, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("security airlock assembly",			/obj/structure/door_assembly/door_assembly_sec, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("engineering airlock assembly",			/obj/structure/door_assembly/door_assembly_eng, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("mining airlock assembly",				/obj/structure/door_assembly/door_assembly_min, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("atmospherics airlock assembly",		/obj/structure/door_assembly/door_assembly_atmo, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("research airlock assembly",			/obj/structure/door_assembly/door_assembly_research, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("freezer airlock assembly",				/obj/structure/door_assembly/door_assembly_fre, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("science airlock assembly",				/obj/structure/door_assembly/door_assembly_science, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("medical airlock assembly",				/obj/structure/door_assembly/door_assembly_med, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("virology airlock assembly",			/obj/structure/door_assembly/door_assembly_viro, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("maintenance airlock assembly",			/obj/structure/door_assembly/door_assembly_mai, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("external airlock assembly",			/obj/structure/door_assembly/door_assembly_ext, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("external maintenance airlock assembly",/obj/structure/door_assembly/door_assembly_extmai, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("airtight hatch assembly",				/obj/structure/door_assembly/door_assembly_hatch, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new /datum/stack_recipe("maintenance hatch assembly",			/obj/structure/door_assembly/door_assembly_mhatch, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
	)), \
	null, \
	new/datum/stack_recipe("firelock frame",							/obj/structure/firelock_frame, 3, one_per_turf = TRUE, on_floor = TRUE, time = 5 SECONDS), \
	new/datum/stack_recipe("directional firelock frame",				/obj/structure/firelock_frame/border, 3, one_per_turf = FALSE, on_floor = TRUE, time = 5 SECONDS), \
	new/datum/stack_recipe("turret frame",								/obj/machinery/porta_turret_construct, 5, one_per_turf = TRUE, on_floor = TRUE, time = 2.5 SECONDS), \
	new/datum/stack_recipe("meatspike frame",							/obj/structure/kitchenspike_frame, 5, one_per_turf = TRUE, on_floor = TRUE, time = 2.5 SECONDS), \
	new/datum/stack_recipe("reflector frame",							/obj/structure/reflector, 5, one_per_turf = TRUE, on_floor = TRUE, time = 2.5 SECONDS), \
	null, \
	new/datum/stack_recipe("pestle",									/obj/item/pestle, 1, time = 5 SECONDS), \
	new/datum/stack_recipe("grenade casing",							/obj/item/grenade/chem_grenade), \
	new/datum/stack_recipe("light fixture frame",						/obj/item/wallframe/light_fixture, 2), \
	new/datum/stack_recipe("small light fixture frame",					/obj/item/wallframe/light_fixture/small, 1), \
	null, \
	new/datum/stack_recipe("apc frame",									/obj/item/wallframe/apc, 2), \
	new/datum/stack_recipe("air alarm frame",							/obj/item/wallframe/airalarm, 2), \
	new/datum/stack_recipe("airlock controller frame",					/obj/item/wallframe/advanced_airlock_controller, 2), \
	new/datum/stack_recipe("fire alarm frame",							/obj/item/wallframe/firealarm, 2), \
	new/datum/stack_recipe("extinguisher cabinet frame",				/obj/item/wallframe/extinguisher_cabinet, 2), \
	new/datum/stack_recipe("light switch frame",						/obj/item/wallframe/light_switch, 1), \
	new/datum/stack_recipe("button frame",								/obj/item/wallframe/button, 1), \
	null, \
	new/datum/stack_recipe("iron door",									/obj/structure/mineral_door/iron, 20, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("desk bell", 								/obj/structure/desk_bell, 2, time = 3 SECONDS), \
	new/datum/stack_recipe("filing cabinet", 							/obj/structure/filingcabinet, 2, one_per_turf = TRUE, on_floor = TRUE, time = 10 SECONDS), \
	new/datum/stack_recipe("floodlight frame",							/obj/structure/floodlight_frame, 5, one_per_turf = TRUE, on_floor = TRUE), \
	new/datum/stack_recipe("shower frame",								/obj/structure/showerframe, 2, time = 2 SECONDS), \
	new/datum/stack_recipe("sink frame",								/obj/structure/sinkframe, 2, time = 2 SECONDS), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/iron)

/obj/item/stack/sheet/iron/cyborg
	materials = list()
	is_cyborg = 1
	cost = 500

/* Plasteel */

GLOBAL_LIST_INIT(plasteel_recipes, list ( \
	new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, one_per_turf = TRUE, time = 5 ), \
	new/datum/stack_recipe("bomb assembly", /obj/machinery/syndicatebomb/empty, 10, time = 5 ), \
	new/datum/stack_recipe("dock tile", /obj/item/stack/tile/dock, 1, 4, 20), \
	new/datum/stack_recipe("dry dock tile", /obj/item/stack/tile/drydock, 2, 4, 20), \
	null, \
	new /datum/stack_recipe_list("airlock assemblies", list( \
		new/datum/stack_recipe("high security airlock assembly",		/obj/structure/door_assembly/door_assembly_highsecurity, 4, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
		new/datum/stack_recipe("vault door assembly",					/obj/structure/door_assembly/door_assembly_vault, 6, one_per_turf = 1, on_floor = 1, time = 5 SECONDS), \
	)), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plasteel)

/* Runed Metal */

GLOBAL_LIST_INIT(runed_metal_recipes, list ( \
	new/datum/stack_recipe("runed door",							/obj/machinery/door/airlock/cult, 1, one_per_turf = TRUE, on_floor = TRUE, time = 5 SECONDS), \
	new/datum/stack_recipe("runed girder",							/obj/structure/girder/cult, 1, one_per_turf = TRUE, on_floor = TRUE, time = 5 SECONDS), \
	null, \
	new/datum/stack_recipe("pylon",									/obj/structure/destructible/cult/pylon, 4, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	new/datum/stack_recipe("forge",									/obj/structure/destructible/cult/forge, 3, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	new/datum/stack_recipe("archives",								/obj/structure/destructible/cult/tome, 3, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	new/datum/stack_recipe("altar",									/obj/structure/destructible/cult/talisman, 3, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/runed_metal)

/* Brass */

GLOBAL_LIST_INIT(brass_recipes, list ( \
	new/datum/stack_recipe("wall gear",								/obj/structure/destructible/clockwork/wall_gear, 2,one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
	new/datum/stack_recipe("brass grille",							/obj/structure/grille/ratvar, 2, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
	new/datum/stack_recipe("brass floor tile",						/obj/item/stack/tile/mineral/brass, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("brass fulltile window",					/obj/structure/window/reinforced/clockwork/fulltile/unanchored, 4,on_floor = TRUE, window_checks=TRUE, time = 1 SECONDS), \
	new/datum/stack_recipe("brass directional window",				/obj/structure/window/reinforced/clockwork/unanchored, 2, on_floor = TRUE, window_checks=TRUE, time = 1 SECONDS), \
	new/datum/stack_recipe("brass windoor",							/obj/machinery/door/window/clockwork, 5, on_floor = TRUE, window_checks=TRUE, time = 4 SECONDS), \
	null, \
	new/datum/stack_recipe("pinion airlock",						/obj/machinery/door/airlock/clockwork, 5, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	new/datum/stack_recipe("pinion windowed airlock",				/obj/machinery/door/airlock/clockwork/glass, 5, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	null, \
	new/datum/stack_recipe("brass chair",							/obj/structure/chair/fancy/brass, 1, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	new/datum/stack_recipe("brass table frame",						/obj/structure/table_frame/brass, 1, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	null, \
	new/datum/stack_recipe("lever",									/obj/item/wallframe/clocktrap/lever, 1, one_per_turf = FALSE, on_floor = FALSE, time = 4 SECONDS), \
	new/datum/stack_recipe("timer",									/obj/item/wallframe/clocktrap/delay, 1, one_per_turf = FALSE, on_floor = FALSE, time = 4 SECONDS), \
	new/datum/stack_recipe("pressure sensor",						/obj/structure/destructible/clockwork/trap/pressure_sensor, 4, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	null, \
	new/datum/stack_recipe("brass skewer",							/obj/structure/destructible/clockwork/trap/skewer, 12, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
	new/datum/stack_recipe("brass flipper",							/obj/structure/destructible/clockwork/trap/flipper, 10, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/brass)

/obj/item/stack/sheet/brass/cyborg
	materials = list()
	is_cyborg = 1
	cost = 500

/* Bronze */

GLOBAL_LIST_INIT(bronze_recipes, list ( \
	new/datum/stack_recipe("wall gear", /obj/structure/girder/bronze, 2,, one_per_turf = TRUE, on_floor = TRUE, time = 2 SECONDS), \
	null, \
	new/datum/stack_recipe("directional bronze window",				/obj/structure/window/bronze/unanchored, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile bronze window",				/obj/structure/window/bronze/fulltile/unanchored, 2, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("pinion airlock assembly",				/obj/structure/door_assembly/door_assembly_bronze, 4, one_per_turf = TRUE, on_floor = TRUE, time = 5 SECONDS), \
	new/datum/stack_recipe("bronze pinion airlock assembly",		/obj/structure/door_assembly/door_assembly_bronze/seethru, 4, one_per_turf = TRUE, on_floor = TRUE, time = 5 SECONDS), \
	new/datum/stack_recipe("bronze floor tile",						/obj/item/stack/tile/mineral/bronze, 1, 4, 20), \
	null, \
	new/datum/stack_recipe("bronze hat",							/obj/item/clothing/head/bronze), \
	new/datum/stack_recipe("bronze suit",							/obj/item/clothing/suit/bronze), \
	new/datum/stack_recipe("bronze boots",							/obj/item/clothing/shoes/bronze), \
	null, \
	new/datum/stack_recipe("bronze chair",							/obj/structure/chair/fancy/brass/bronze, 1, one_per_turf = TRUE, on_floor = TRUE, time = 4 SECONDS), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/bronze)
