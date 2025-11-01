///Lavaproof, fireproof, fast mech with low armor and higher energy consumption, cannot strafe and has an internal ore box.
/obj/vehicle/sealed/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger engineer. Its reinforced tire tracks can travel safely on lava, but are slower on the metalic station floor."
	name = "\improper Clarke"
	icon_state = "clarke"
	base_icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 200
	movedelay = 1.25
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	deflect_chance = 10
	step_energy_drain = 15 //slightly higher energy drain since you movin those wheels FAST
	armor_type = /datum/armor/working_clarke
	max_equip = 7
	wreckage = /obj/structure/mecha_wreckage/clarke
	enter_delay = 40
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | OMNIDIRECTIONAL_ATTACKS
	internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	allow_diagonal_movement = FALSE
	pivot_step = TRUE
	var/fast_pressure_step_in = 1.25
	var/slow_pressure_step_in = 3.5

/datum/armor/working_clarke
	melee = 20
	bullet = 10
	laser = 20
	energy = 10
	bomb = 60
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/working/clarke/Initialize(mapload)
	. = ..()
	box = new(src)
	var/obj/item/mecha_parts/mecha_equipment/orebox_manager/ME = new(src)
	ME.attach(src)

/obj/vehicle/sealed/mecha/working/clarke/Destroy()
	box.dump_box_contents()
	return ..()

/obj/vehicle/sealed/mecha/working/clarke/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && !HAS_TRAIT(H, TRAIT_DIAGNOSTIC_HUD))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.add_hud_to(H)
		ADD_TRAIT(H, TRAIT_DIAGNOSTIC_HUD, VEHICLE_TRAIT)

/obj/vehicle/sealed/mecha/working/clarke/remove_occupant(mob/living/carbon/H)
	if(isliving(H) && HAS_TRAIT_FROM(H, TRAIT_DIAGNOSTIC_HUD, VEHICLE_TRAIT))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.remove_hud_from(H)
		REMOVE_TRAIT(H, TRAIT_DIAGNOSTIC_HUD, VEHICLE_TRAIT)
	return ..()

/obj/vehicle/sealed/mecha/working/clarke/mmi_moved_inside(obj/item/mmi/M, mob/user)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		var/mob/living/brain/B = M.brainmob
		hud.add_hud_to(B)

/obj/vehicle/sealed/mecha/working/clarke/Move()
	. = ..()
	update_pressure()

/**
  * Makes the mecha go faster and halves the mecha drill cooldown if in Lavaland pressure.
  *
  * Checks for Lavaland pressure, if that works out the mech's speed is equal to fast_pressure_step_in and the cooldown for the mecha drill is halved. If not it uses slow_pressure_step_in and drill cooldown is normal.
  */
/obj/vehicle/sealed/mecha/working/clarke/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		movedelay = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		movedelay = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)

//Ore Box Controls

///Special equipment for the Clarke mech, handles moving ore without giving the mech a hydraulic clamp and cargo compartment.
/obj/item/mecha_parts/mecha_equipment/orebox_manager
	name = "ore storage module"
	desc = "An automated ore box management device."
	icon = 'icons/obj/mining.dmi'
	icon_state = "bin"
	selectable = FALSE
	detachable = FALSE
	/// Var to avoid istype checking every time the topic button is pressed. This will only work inside Clarke mechs.
	var/obj/vehicle/sealed/mecha/working/clarke/hostmech

/obj/item/mecha_parts/mecha_equipment/orebox_manager/attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	if(istype(M, /obj/vehicle/sealed/mecha/working/clarke))
		hostmech = M

/obj/item/mecha_parts/mecha_equipment/orebox_manager/detach()
	hostmech = null //just in case
	return ..()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/Topic(href,href_list)
	. = ..()
	if(!hostmech || !hostmech.box)
		return
	hostmech.box.dump_box_contents()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/get_equip_info()
	return "[..()] [hostmech?.box ? "<a href='byond://?src=[REF(src)];mode=0'>Unload Cargo</a>" : "Error"]"
