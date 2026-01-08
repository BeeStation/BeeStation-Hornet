/* Iron */

GLOBAL_LIST_INIT(metal_recipes, list ( \
	new/datum/stack_recipe("stool", /obj/structure/chair/stool, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_FURNITURE), \
	new/datum/stack_recipe("bar stool", /obj/structure/chair/stool/bar, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_FURNITURE), \

	null, \
	new/datum/stack_recipe_list("office chairs", list( \
		new/datum/stack_recipe("dark office chair", /obj/structure/chair/office, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_FURNITURE), \
		new/datum/stack_recipe("light office chair", /obj/structure/chair/office/light, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_FURNITURE), \
		)), \
	new/datum/stack_recipe_list("beds", list( \
		new/datum/stack_recipe("single bed", /obj/structure/bed, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new/datum/stack_recipe("double bed", /obj/structure/bed/double, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS, category = CAT_FURNITURE), \
		)), \
	new/datum/stack_recipe_list("comfy chairs", list( \
		new/datum/stack_recipe("comfy chair", /obj/structure/chair/fancy/comfy, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new/datum/stack_recipe("corporate chair", /obj/structure/chair/fancy/corp, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new/datum/stack_recipe("shuttle seat", /obj/structure/chair/fancy/shuttle, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		)), \
	new/datum/stack_recipe_list("old sofa", list(
		new /datum/stack_recipe("old sofa (middle)", /obj/structure/chair/fancy/sofa/old, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("old sofa (left)", /obj/structure/chair/fancy/sofa/old/left, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("old sofa (right)", /obj/structure/chair/fancy/sofa/old/right, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("old sofa (concave corner)", /obj/structure/chair/fancy/sofa/old/corner/concave, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("old sofa (convex corner)", /obj/structure/chair/fancy/sofa/old/corner/convex, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		)), \
	new /datum/stack_recipe_list("corporate sofas", list( \
		new /datum/stack_recipe("corporate sofa (middle)", /obj/structure/chair/fancy/sofa/corp, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("corporate sofa (left)", /obj/structure/chair/fancy/sofa/corp/left, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("corporate sofa (right)", /obj/structure/chair/fancy/sofa/corp/right, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("corporate sofa (concave corner)", /obj/structure/chair/fancy/sofa/corp/corner/concave, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("corporate sofa (convex corner)", /obj/structure/chair/fancy/sofa/corp/corner/convex, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		)), \
	new /datum/stack_recipe_list("benches", list( \
		new /datum/stack_recipe("bench (middle)", /obj/structure/chair/fancy/bench, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("bench (left)", /obj/structure/chair/fancy/bench/left, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("bench (right)", /obj/structure/chair/fancy/bench/right, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		)), \
	new /datum/stack_recipe_list("corporate benches", list( \
		new /datum/stack_recipe("corporate bench (middle)", /obj/structure/chair/fancy/bench/corporate, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("corporate bench (left)", /obj/structure/chair/fancy/bench/corporate/left, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		new /datum/stack_recipe("corporate bench (right)", /obj/structure/chair/fancy/bench/corporate/right, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS, category = CAT_FURNITURE), \
		)),
	null, \
	new/datum/stack_recipe("rack parts", /obj/item/rack_parts, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("crate shelf parts", /obj/item/rack_parts/shelf, category = CAT_EQUIPMENT), \
	new /datum/stack_recipe_list("closets", list( \
		new/datum/stack_recipe("closet", /obj/structure/closet, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("emergency closet", /obj/structure/closet/emcloset/empty, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("fire closet", /obj/structure/closet/firecloset/empty, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("radiation closet", /obj/structure/closet/radiation/empty, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("tool closet", /obj/structure/closet/toolcloset/empty, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("wardrobe closet", /obj/structure/closet/wardrobe/empty, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("bomb closet", /obj/structure/closet/bombcloset/empty, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_CONTAINERS), \
		new/datum/stack_recipe("weapon closet", /obj/structure/closet/gun_locker, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_CONTAINERS), \
		)),
	new /datum/stack_recipe_list("wall closets",	 list( \
		new/datum/stack_recipe("wall closet",								/obj/item/wallframe/wall_closet, 2, time = 1.5 SECONDS), \
		new/datum/stack_recipe("emergency wall closet",						/obj/item/wallframe/wall_closet/emergency, 2, time = 1.5 SECONDS), \
		new/datum/stack_recipe("fire-safety wall closet",							/obj/item/wallframe/wall_closet/fire, 2, time = 1.5 SECONDS), \
		new/datum/stack_recipe("tool wall closet",							/obj/item/wallframe/wall_closet/tool, 2, time = 1.5 SECONDS), \
		new/datum/stack_recipe("wall freezer",								/obj/item/wallframe/wall_closet/freezer, 2, time = 1.5 SECONDS), \
		)),
	null, \
	new/datum/stack_recipe("canister", /obj/machinery/portable_atmospherics/canister, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 1.5 SECONDS, category = CAT_ATMOSPHERIC), \
	null, \
	new/datum/stack_recipe("floor tile", /obj/item/stack/tile/iron, 1, 4, 20, category = CAT_TILES), \
	new/datum/stack_recipe("iron rod", /obj/item/stack/rods, 1, 2, 60, category = CAT_MISC), \
	null, \
	new/datum/stack_recipe("wall girders (anchored)", /obj/structure/girder, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS, category = CAT_STRUCTURE), \
	null, \
	new/datum/stack_recipe("computer frame", /obj/structure/frame/computer, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2.5 SECONDS, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("modular console", /obj/machinery/modular_computer/console/buildable/, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2.5 SECONDS, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("machine frame", /obj/structure/frame/machine, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2.5 SECONDS, category = CAT_EQUIPMENT), \
	null, \
	new /datum/stack_recipe_list("airlock assemblies", list( \
		new /datum/stack_recipe("standard airlock assembly", /obj/structure/door_assembly, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("personal airlock assembly", /obj/structure/door_assembly/personal, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("public airlock assembly", /obj/structure/door_assembly/door_assembly_public, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("command airlock assembly", /obj/structure/door_assembly/door_assembly_com, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("security airlock assembly", /obj/structure/door_assembly/door_assembly_sec, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("engineering airlock assembly", /obj/structure/door_assembly/door_assembly_eng, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("mining airlock assembly", /obj/structure/door_assembly/door_assembly_min, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("atmospherics airlock assembly", /obj/structure/door_assembly/door_assembly_atmo, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("research airlock assembly", /obj/structure/door_assembly/door_assembly_research, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("freezer airlock assembly", /obj/structure/door_assembly/door_assembly_fre, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("science airlock assembly", /obj/structure/door_assembly/door_assembly_science, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("medical airlock assembly", /obj/structure/door_assembly/door_assembly_med, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("virology airlock assembly", /obj/structure/door_assembly/door_assembly_viro, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_mai, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("external airlock assembly", /obj/structure/door_assembly/door_assembly_ext, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("external maintenance airlock assembly", /obj/structure/door_assembly/door_assembly_extmai, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("airtight hatch assembly", /obj/structure/door_assembly/door_assembly_hatch, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
		new /datum/stack_recipe("maintenance hatch assembly", /obj/structure/door_assembly/door_assembly_mhatch, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
	)), \
	null, \
	new/datum/stack_recipe("firelock frame", /obj/structure/firelock_frame, 3, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS), \
	new/datum/stack_recipe("turret frame", /obj/machinery/porta_turret_construct, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2.5 SECONDS, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("meatspike frame", /obj/structure/kitchenspike_frame, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2.5 SECONDS, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("reflector frame", /obj/structure/reflector, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2.5 SECONDS, category = CAT_EQUIPMENT), \
	null, \
	new/datum/stack_recipe("grenade casing", /obj/item/grenade/chem_grenade, crafting_flags = NONE, category = CAT_CHEMISTRY), \
	new/datum/stack_recipe("light fixture frame", /obj/item/wallframe/light_fixture, 2, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("small light fixture frame", /obj/item/wallframe/light_fixture/small, 1, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	null, \
	new/datum/stack_recipe("apc frame", /obj/item/wallframe/apc, 2, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("air alarm frame", /obj/item/wallframe/airalarm, 2, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("fire alarm frame", /obj/item/wallframe/firealarm, 2, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("extinguisher cabinet frame", /obj/item/wallframe/extinguisher_cabinet, 2, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("light switch frame", /obj/item/wallframe/light_switch, 1, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("button frame", /obj/item/wallframe/button, 1, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("prisoner interface frame", /obj/item/wallframe/genpop_interface, 5, crafting_flags = NONE, category = CAT_EQUIPMENT), \
	null, \
	new/datum/stack_recipe("iron door", /obj/structure/mineral_door/iron, 20, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_DOORS), \
	new/datum/stack_recipe("filing cabinet", /obj/structure/filingcabinet, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 10 SECONDS), \
	new/datum/stack_recipe("desk bell", /obj/structure/desk_bell, 2, time = 3 SECONDS, category = CAT_FURNITURE, category = CAT_FURNITURE), \
	new/datum/stack_recipe("floodlight frame", /obj/structure/floodlight_frame, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_EQUIPMENT), \
	new/datum/stack_recipe("pestle", /obj/item/pestle, 1, time = 5 SECONDS, crafting_flags = NONE, category = CAT_CHEMISTRY), \
	new/datum/stack_recipe("shower frame", /obj/structure/showerframe, 2, time = 2 SECONDS, crafting_flags = NONE, category = CAT_FURNITURE), \
	new/datum/stack_recipe("sink frame", /obj/structure/sinkframe, 2, time = 2 SECONDS, crafting_flags = NONE, category = CAT_FURNITURE), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/iron)

/* Plasteel */

GLOBAL_LIST_INIT(plasteel_recipes, list ( \
	new/datum/stack_recipe("AI core", /obj/structure/AIcore, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF, time = 5, category = CAT_ROBOT),
	new/datum/stack_recipe("bomb assembly", /obj/machinery/syndicatebomb/empty, 10, time = 5, crafting_flags = NONE, category = CAT_CHEMISTRY),
	new/datum/stack_recipe("dock tile", /obj/item/stack/tile/dock, 1, 4, 20, crafting_flags = NONE, category = CAT_TILES),
	new/datum/stack_recipe("dry dock tile", /obj/item/stack/tile/drydock, 2, 4, 20, crafting_flags = NONE, category = CAT_TILES),
	new/datum/stack_recipe("shutter assembly", /obj/machinery/door/poddoor/shutters/preopen/deconstructed, 5, time = 5 SECONDS, crafting_flags = CRAFT_ONE_PER_TURF, category = CAT_DOORS),
	null, \
	new /datum/stack_recipe_list("airlock assemblies", list( \
		new/datum/stack_recipe("high security airlock assembly", /obj/structure/door_assembly/door_assembly_highsecurity, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS),
		new/datum/stack_recipe("vault door assembly", /obj/structure/door_assembly/door_assembly_vault, 6, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 SECONDS, category = CAT_DOORS),
	)), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/plasteel)

/* Brass */

GLOBAL_LIST_INIT(brass_recipes, list (
	new/datum/stack_recipe("wall gear", /obj/structure/destructible/clockwork/wall_gear, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS),
	new/datum/stack_recipe("brass grille", /obj/structure/grille/ratvar, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS),
	new/datum/stack_recipe("brass floor tile", /obj/item/stack/tile/mineral/brass, 1, 4, 20, crafting_flags = NONE, category = CAT_TILES),
	null,
	new/datum/stack_recipe("brass fulltile window", /obj/structure/window/reinforced/clockwork/fulltile/unanchored, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_IS_FULLTILE, time = 1 SECONDS),
	new/datum/stack_recipe("brass directional window", /obj/structure/window/reinforced/clockwork/unanchored, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, time = 1 SECONDS),
	new/datum/stack_recipe("brass directional window corner", /obj/structure/window/reinforced/clockwork/corner/unanchored, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, time = 1 SECONDS),
	new/datum/stack_recipe("brass windoor", /obj/machinery/door/window/clockwork, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, time = 4 SECONDS),
	null,
	new/datum/stack_recipe("pinion airlock", /obj/machinery/door/airlock/clockwork, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS),
	new/datum/stack_recipe("pinion windowed airlock", /obj/machinery/door/airlock/clockwork/glass, 5, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS),
	null,
	new/datum/stack_recipe("brass chair", /obj/structure/chair/fancy/brass, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS),
	new/datum/stack_recipe("brass table frame", /obj/structure/table_frame/brass, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS),
	null,
	new/datum/stack_recipe("lever", /obj/item/wallframe/clocktrap/lever, 1, crafting_flags = CRAFT_CHECK_DENSITY, time = 4 SECONDS),
	new/datum/stack_recipe("timer", /obj/item/wallframe/clocktrap/delay, 1, crafting_flags = CRAFT_CHECK_DENSITY, time = 4 SECONDS),
	new/datum/stack_recipe("pressure sensor", /obj/structure/destructible/clockwork/trap/pressure_sensor, 4, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS),
	null,
	new/datum/stack_recipe("brass skewer", /obj/structure/destructible/clockwork/trap/skewer, 12, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS),
	new/datum/stack_recipe("brass flipper", /obj/structure/destructible/clockwork/trap/flipper, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS),
))

STACKSIZE_MACRO(/obj/item/stack/sheet/brass)

/obj/item/stack/sheet/brass/cyborg
	custom_materials = null
	is_cyborg = 1
	cost = 500

/* Bronze */

GLOBAL_LIST_INIT(bronze_recipes, list ( \
	new/datum/stack_recipe("wall gear", /obj/structure/girder/bronze, 2, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 2 SECONDS),
	null,
	new/datum/stack_recipe("directional bronze window", /obj/structure/window/bronze/unanchored, time = 0, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS),
	new/datum/stack_recipe("directional bronze window corner", /obj/structure/window/bronze/corner/unanchored, time = 0, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_CHECK_DIRECTION, category = CAT_WINDOWS),
	new/datum/stack_recipe("fulltile bronze window", /obj/structure/window/bronze/fulltile/unanchored, 2, time = 0, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ON_SOLID_GROUND | CRAFT_IS_FULLTILE, category = CAT_WINDOWS),
	new/datum/stack_recipe("pinion airlock assembly", /obj/structure/door_assembly/door_assembly_bronze, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_DOORS),
	new/datum/stack_recipe("bronze pinion airlock assembly", /obj/structure/door_assembly/door_assembly_bronze/seethru, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, category = CAT_DOORS),
	new/datum/stack_recipe("bronze floor tile", /obj/item/stack/tile/mineral/bronze, 1, 4, 20, crafting_flags = NONE, category = CAT_TILES),
	null,
	new/datum/stack_recipe("bronze hat", /obj/item/clothing/head/costume/bronze, category = CAT_CLOTHING),
	new/datum/stack_recipe("bronze suit", /obj/item/clothing/suit/costume/bronze, category = CAT_CLOTHING),
	new/datum/stack_recipe("bronze boots", /obj/item/clothing/shoes/bronze, category = CAT_CLOTHING),
	null,
	new/datum/stack_recipe("bronze chair", /obj/structure/chair/fancy/brass/bronze, 1, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 4 SECONDS, category = CAT_FURNITURE),
))

STACKSIZE_MACRO(/obj/item/stack/sheet/bronze)

/* Fleshy Mass */

GLOBAL_LIST_INIT(fleshymass_recipes, list ( \
	new/datum/stack_recipe("Persuasion rack", /obj/structure/vampire/vassalrack, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 ), \
	new/datum/stack_recipe("Candelabrum", /obj/structure/vampire/candelabrum, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 ), \
	new/datum/stack_recipe("Blood throne", /obj/structure/vampire/bloodthrone, 20, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 ), \
	new/datum/stack_recipe("Meat coffin", /obj/structure/closet/crate/coffin/meatcoffin, 20, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND, time = 5 ), \
))

STACKSIZE_MACRO(/obj/item/stack/sheet/fleshymass)
