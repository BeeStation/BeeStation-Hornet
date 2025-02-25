/obj/vehicle/sealed/mecha/ripley
	desc = "Autonomous Power Loader Unit MK-I. Designed primarily around heavy lifting, the Ripley can be outfitted with utility equipment to fill a number of roles."
	name = "\improper APLU MK-I \"Ripley\""
	icon_state = "ripley"
	base_icon_state = "ripley"
	silicon_icon_state = "ripley-empty"
	movedelay = 1.5 //Move speed, lower is faster.
	max_temperature = 20000
	max_integrity = 200
	lights_power = 7
	armor_type = /datum/armor/mecha_ripley
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 4,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	mecha_flags = CAN_STRAFE | HAS_LIGHTS
	wreckage = /obj/structure/mecha_wreckage/ripley
	mech_type = EXOSUIT_MODULE_RIPLEY
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	accesses = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	enter_delay = 10 //can enter in a quarter of the time of other mechs
	exit_delay = 10
	/// Custom Ripley step and turning sounds (from TGMC)
	stepsound = 'sound/mecha/powerloader_step.ogg'
	turnsound = 'sound/mecha/powerloader_turn2.ogg'
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	/// Amount of Goliath hides attached to the mech
	var/hides = 0
	/// List of all things in Ripley's Cargo Compartment
	var/list/cargo
	/// How much things Ripley can carry in their Cargo Compartment
	var/cargo_capacity = 15
	/// How fast the mech is in low pressure
	var/fast_pressure_step_in = 1.5
	/// How fast the mech is in normal pressure
	var/slow_pressure_step_in = 2


/datum/armor/mecha_ripley
	melee = 40
	bullet = 20
	laser = 10
	energy = 20
	bomb = 40
	rad = 20
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/ripley/Move()
	. = ..()
	update_pressure()

/obj/vehicle/sealed/mecha/ripley/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 3 ,/obj/item/stack/sheet/animalhide/goliath_hide, /datum/armor/armor_plate_ripley_goliath)

/datum/armor/armor_plate_ripley_goliath
	melee = 10
	bullet = 5
	laser = 5

/obj/vehicle/sealed/mecha/ripley/Destroy()
	for(var/atom/movable/A in cargo)
		A.forceMove(drop_location())
		step_rand(A)
	QDEL_LIST(cargo)
	return ..()

/obj/vehicle/sealed/mecha/ripley/mk2
	desc = "Autonomous Power Loader Unit MK-II. This prototype Ripley is refitted with a pressurized cabin, trading its prior speed for atmospheric protection and armor."
	name = "\improper APLU MK-II \"Ripley\""
	icon_state = "ripleymkii"
	base_icon_state = "ripleymkii"
	fast_pressure_step_in = 1.75 //step_in while in low pressure conditions
	slow_pressure_step_in = 2.5 //step_in while in normal pressure conditions
	movedelay = 4
	max_temperature = 30000
	max_integrity = 250
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_TEMP_CONTROL|MECHA_CABIN_AIR_BREACH|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	armor_type = /datum/armor/mecha_ripley_mk2
	wreckage = /obj/structure/mecha_wreckage/ripley/mk2
	enter_delay = 40
	silicon_icon_state = null


/datum/armor/mecha_ripley_mk2
	melee = 40
	bullet = 20
	laser = 10
	energy = 20
	bomb = 40
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	base_icon_state = "deathripley"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 3 //step_in while in normal pressure conditions
	movedelay = 4
	lights_power = 7
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS
	enter_delay = 40
	silicon_icon_state = null
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/fake,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/ripley/deathripley/real
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE. FOR REAL"
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/ripley/mining
	desc = "An old, dusty mining Ripley."
	name = "\improper APLU \"Miner\""

/obj/vehicle/sealed/mecha/ripley/mining/Initialize(mapload)
	. = ..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	else //Add plasma cutter if no drill
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src, TRUE)

	take_damage(max_integrity * 0.5, sound_effect=FALSE) //Low starting health

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/vehicle/sealed/mecha/ripley/cargo/populate_parts()
	cell = new /obj/item/stock_parts/cell/high(src)
	//No scanmod for Big Bess
	capacitor = new /obj/item/stock_parts/capacitor(src)
	servo = new /obj/item/stock_parts/manipulator(src)
	update_part_values()

/obj/vehicle/sealed/mecha/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return FALSE
	return ..()

/obj/vehicle/sealed/mecha/ripley/contents_explosion(severity, target)
	for(var/i in cargo)
		var/obj/cargoobj = i
		if(prob(30/severity))
			LAZYREMOVE(cargo, cargoobj)
			cargoobj.forceMove(drop_location())
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector
	name = "Cargo compartment"
	desc = "Holds cargo loaded with a hydraulic clamp."
	icon_state = "mecha_bin"
	equipment_slot = MECHA_UTILITY
	detachable = FALSE

/obj/item/mecha_parts/mecha_equipment/ejector/get_snowflake_data()
	var/obj/vehicle/sealed/mecha/ripley/miner = chassis
	var/list/data = list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_EJECTOR,
		"cargo_capacity" = miner.cargo_capacity,
		"cargo" = list()
		)
	for(var/obj/crate in miner.cargo)
		data["cargo"] += list(list(
			"name" = crate.name,
			"ref" = REF(crate),
		))
	return data

/obj/item/mecha_parts/mecha_equipment/ejector/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE
	if(action == "eject")
		var/obj/vehicle/sealed/mecha/ripley/miner = chassis
		var/obj/crate = locate(params["cargoref"]) in miner.cargo
		if(!crate)
			return FALSE
		to_chat(miner.occupants, "[icon2html(src,  miner.occupants)][span_notice("You unload [crate].")]")
		crate.forceMove(drop_location())
		LAZYREMOVE(miner.cargo, crate)
		if(crate == miner.ore_box)
			miner.ore_box = null
		playsound(chassis, 'sound/weapons/tap.ogg', 50, TRUE)
		log_message("Unloaded [crate]. Cargo compartment capacity: [miner.cargo_capacity - LAZYLEN(miner.cargo)]", LOG_MECHA)
		return TRUE

/obj/vehicle/sealed/mecha/ripley/relay_container_resist(mob/living/user, obj/O)
	to_chat(user, span_notice("You lean on the back of [O] and start pushing so it falls out of [src]."))
	if(do_after(user, 300, target = O))
		if(!user || user.stat != CONSCIOUS || user.loc != src || O.loc != src )
			return
		to_chat(user, span_notice("You successfully pushed [O] out of [src]!"))
		O.forceMove(drop_location())
		LAZYREMOVE(cargo, O)
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to push [O] out of [src]!"))

/**
  * Makes the mecha go faster and halves the mecha drill cooldown if in Lavaland pressure.
  *
  * Checks for Lavaland pressure, if that works out the mech's speed is equal to fast_pressure_step_in and the cooldown for the mecha drill is halved. If not it uses slow_pressure_step_in and drill cooldown is normal.
  */
/obj/vehicle/sealed/mecha/ripley/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		movedelay = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in flat_equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown) * 0.5

	else
		movedelay = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in flat_equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)
