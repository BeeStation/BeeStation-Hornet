///Lavaproof, fireproof, fast mech with low armor and higher energy consumption, cannot strafe and has an internal ore box.
/obj/vehicle/sealed/mecha/clarke
	desc = "Combining man and machine for a better, stronger engineer. Its reinforced tire tracks can travel safely on lava, but are slower on the metalic station floor."
	name = "\improper Clarke"
	icon_state = "clarke"
	base_icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 200
	movedelay = 1.25
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	step_energy_drain = 12 //slightly higher energy drain since you movin those wheels FAST
	armor_type = /datum/armor/mecha_clarke
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/orebox_manager),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 5,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	wreckage = /obj/structure/mecha_wreckage/clarke
	mech_type = EXOSUIT_MODULE_CLARKE
	enter_delay = 40
	mecha_flags = IS_ENCLOSED | HAS_LIGHTS | OMNIDIRECTIONAL_ATTACKS
	accesses = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	allow_diagonal_movement = FALSE
	pivot_step = TRUE
	var/fast_pressure_step_in = 1.25
	var/slow_pressure_step_in = 3.5

/datum/armor/mecha_clarke
	melee = 20
	bullet = 10
	laser = 20
	energy = 10
	bomb = 60
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/clarke/Initialize(mapload)
	. = ..()
	ore_box = new(src)

/obj/vehicle/sealed/mecha/clarke/atom_destruction()
	if(ore_box)
		INVOKE_ASYNC(ore_box, TYPE_PROC_REF(/obj/structure/ore_box, dump_box_contents))
	return ..()

/obj/vehicle/sealed/mecha/clarke/Move()
	. = ..()
	update_pressure()

/**
  * Makes the mecha go faster and halves the mecha drill cooldown if in Lavaland pressure.
  *
  * Checks for Lavaland pressure, if that works out the mech's speed is equal to fast_pressure_step_in and the cooldown for the mecha drill is halved. If not it uses slow_pressure_step_in and drill cooldown is normal.
  */
/obj/vehicle/sealed/mecha/clarke/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		movedelay = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in flat_equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		movedelay = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in flat_equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)

/obj/vehicle/sealed/mecha/clarke/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && !HAS_TRAIT(H, TRAIT_DIAGNOSTIC_HUD))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.add_hud_to(H)
		ADD_TRAIT(H, TRAIT_DIAGNOSTIC_HUD, VEHICLE_TRAIT)

/obj/vehicle/sealed/mecha/clarke/remove_occupant(mob/living/carbon/H)
	if(isliving(H) && HAS_TRAIT_FROM(H, TRAIT_DIAGNOSTIC_HUD, VEHICLE_TRAIT))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.remove_hud_from(H)
		REMOVE_TRAIT(H, TRAIT_DIAGNOSTIC_HUD, VEHICLE_TRAIT)
	return ..()

/obj/vehicle/sealed/mecha/clarke/mmi_moved_inside(obj/item/mmi/M, mob/user)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		var/mob/living/brain/B = M.brainmob
		hud.add_hud_to(B)

//Ore Box Controls

///Special equipment for the Clarke mech, handles moving ore without giving the mech a hydraulic clamp and cargo compartment.
/obj/item/mecha_parts/mecha_equipment/orebox_manager
	name = "ore storage module"
	desc = "An automated ore box management device."
	icon_state = "mecha_bin"
	equipment_slot = MECHA_UTILITY
	detachable = FALSE

/obj/item/mecha_parts/mecha_equipment/orebox_manager/attach(obj/vehicle/sealed/mecha/mecha, attach_right = FALSE)
	. = ..()
	ADD_TRAIT(chassis, TRAIT_OREBOX_FUNCTIONAL, TRAIT_MECH_EQUIPMENT(type))

/obj/item/mecha_parts/mecha_equipment/orebox_manager/detach(atom/moveto)
	REMOVE_TRAIT(chassis, TRAIT_OREBOX_FUNCTIONAL, TRAIT_MECH_EQUIPMENT(type))
	return ..()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/get_snowflake_data()
	var/list/contents = chassis.ore_box?.contents
	var/list/contents_grouped = list()
	for(var/obj/item/stack/ore/item as anything in contents)
		if(isnull(contents_grouped[item.icon_state]))
			var/ore_data = list()
			ore_data["name"] = item.name
			ore_data["icon"] = item.icon_state
			ore_data["amount"] = item.amount
			contents_grouped[item.icon_state] = ore_data
		else
			contents_grouped[item.icon_state]["amount"] += item.amount
	var/list/data = list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_OREBOX_MANAGER,
		"contents" = contents_grouped,
		)
	return data

/obj/item/mecha_parts/mecha_equipment/orebox_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE
	if(action == "dump")
		var/obj/structure/ore_box/cached_ore_box = chassis.ore_box
		if(isnull(cached_ore_box))
			return FALSE
		cached_ore_box.dump_box_contents()
		playsound(chassis, 'sound/weapons/tap.ogg', 50, TRUE)
		log_message("Dumped [cached_ore_box].", LOG_MECHA)
		return TRUE
