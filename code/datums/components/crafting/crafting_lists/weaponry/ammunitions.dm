
/// Ammunition Crafting

/datum/crafting_recipe/meteorslug
	name = "Meteorslug Shell"
	result = /obj/item/ammo_casing/shotgun/meteorslug
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/rcd_ammo = 1,
		/obj/item/stock_parts/manipulator = 2
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/pulseslug
	name = "Pulse Slug Shell"
	result = /obj/item/ammo_casing/shotgun/pulseslug
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/stock_parts/capacitor/adv = 2,
		/obj/item/stock_parts/micro_laser/ultra = 1
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/dragonsbreath
	name = "Dragonsbreath Shell"
	result = /obj/item/ammo_casing/shotgun/dragonsbreath
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/datum/reagent/phosphorus = 5
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/frag12
	name = "FRAG-12 Shell"
	result = /obj/item/ammo_casing/shotgun/frag12
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/datum/reagent/glycerol = 5,
		/datum/reagent/toxin/acid = 5,
		/datum/reagent/toxin/acid/fluacid = 5
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/ionslug
	name = "Ion Scatter Shell"
	result = /obj/item/ammo_casing/shotgun/ion
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/stock_parts/micro_laser/ultra = 1,
		/obj/item/stock_parts/subspace/crystal = 1
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/improvisedslug
	name = "Improvised Shotgun Shell"
	result = /obj/item/ammo_casing/shotgun/improvised
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 1,
		/datum/reagent/fuel = 10
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/improvisedglassslug
	name = "Glasspack Shotgun Shell"
	result = /obj/item/ammo_casing/shotgun/improvised/glasspack
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 1,
		/datum/reagent/fuel = 10
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/laserslug
	name = "Scatter Laser Shell"
	result = /obj/item/ammo_casing/shotgun/laserslug
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/ammo_casing/shotgun/techshell = 1,
		/obj/item/stock_parts/capacitor/adv = 1,
		/obj/item/stock_parts/micro_laser/high = 1
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/a762improv
	name = "Improvised 7.62 Cartridge"
	result = /obj/item/ammo_casing/a762/improv
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 1,
		/datum/reagent/fuel = 10
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/a762hotload
	name = "Hot-Loaded 7.62 Cartridge"
	result = /obj/item/ammo_casing/a762/improv/hotload
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 1,
		/datum/reagent/blackpowder = 10
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/improv9mm_pack
	name = "Improvised 9mm Ammo Pack"
	result = /obj/item/ammo_box/pouch/c9mm/improv
	time = 1.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 2,
		/obj/item/stack/rods = 3,
		/obj/item/stack/cable_coil = 3,
		/datum/reagent/fuel = 20,
		/obj/item/paper = 1
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/improv10mm_pack
	name = "Improvised 10mm Ammo Pack"
	result = /obj/item/ammo_box/pouch/c10mm/improv
	time = 1.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 2,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/cable_coil = 2,
		/datum/reagent/fuel = 20,
		/obj/item/paper = 1
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/improv38_pack
	name = "Improvised .38 Ammo Pack"
	result = /obj/item/ammo_box/pouch/c38/improv
	time = 1.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 2,
		/obj/item/stack/rods = 2,
		/obj/item/stack/cable_coil = 2,
		/datum/reagent/fuel = 20,
		/obj/item/paper = 1
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/improv357
	name = "Improvised .357 Cartridge"
	result = /obj/item/ammo_casing/a357/improv
	time = 0.5 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 2,
		/datum/reagent/blackpowder = 10
	)
	category = CAT_WEAPON_AMMO
	dangerous_craft = TRUE

/datum/crafting_recipe/pipesmg_mag
	name = "Pipe Repeater Magazine"
	result = /obj/item/ammo_box/magazine/pipem9mm
	time = 5 SECONDS
	tool_behaviors = list(TOOL_WELDER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/grenade/chem_grenade = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/package_wrap = 3
	)
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/arrow //1 metal sheet = 2 rods= 2 arrows
	name = "Arrow"
	result = /obj/item/ammo_casing/caseless/arrow/wood
	time = 3 SECONDS
	reqs = list(
		/obj/item/stack/sheet/wood = 1,
		/obj/item/stack/sheet/silk = 1,
		/obj/item/stack/rods = 1
	)
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/bone_arrow
	name = "Bone Arrow"
	result = /obj/item/ammo_casing/caseless/arrow/bone
	time = 3 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 1,
		/obj/item/stack/sheet/sinew = 1,
		/obj/item/ammo_casing/caseless/arrow/ash = 1
	)
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/ashen_arrow
	name = "Ashen arrow"
	result = /obj/item/ammo_casing/caseless/arrow/ash
	tool_behaviors = list(TOOL_WELDER)
	time = 3 SECONDS
	reqs = list(/obj/item/ammo_casing/caseless/arrow/wood = 1)
	category = CAT_WEAPON_AMMO

/datum/crafting_recipe/bronze_arrow
	name = "Bronze arrow"
	result = /obj/item/ammo_casing/caseless/arrow/bronze
	time = 3 SECONDS
	reqs = list(
		/obj/item/stack/sheet/wood = 1,
		/obj/item/stack/sheet/bronze = 1,
		/obj/item/stack/sheet/silk = 1
	)
	category = CAT_WEAPON_AMMO
