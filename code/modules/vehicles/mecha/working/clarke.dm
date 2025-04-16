///Lavaproof, fireproof, fast mech with low armor and higher energy consumption, cannot strafe and has an internal ore box.
/obj/vehicle/sealed/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger engineer. Can even resist lava!"
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


/datum/armor/working_clarke
	melee = 20
	bullet = 10
	laser = 20
	energy = 10
	bomb = 60
	rad = 70
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

/obj/vehicle/sealed/mecha/working/clarke/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_search_ruins)

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

#define SEARCH_COOLDOWN 1 MINUTES

/datum/action/vehicle/sealed/mecha/mech_search_ruins
	name = "Search for Ruins"
	button_icon_state = "mech_search_ruins" //This is missing from code itself
	COOLDOWN_DECLARE(search_cooldown)

/datum/action/vehicle/sealed/mecha/mech_search_ruins/on_activate(mob/user, atom/target)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		chassis.balloon_alert(owner, "on cooldown!")
		return
	if(!isliving(owner))
		return
	var/mob/living/living_owner = owner
	button_icon_state = "mech_search_ruins_cooldown"
	update_buttons()
	COOLDOWN_START(src, search_cooldown, SEARCH_COOLDOWN)
	addtimer(VARSET_CALLBACK(src, button_icon_state, "mech_search_ruins"), SEARCH_COOLDOWN)
	addtimer(CALLBACK(src, PROC_REF(update_buttons)), SEARCH_COOLDOWN)
	var/obj/pinpointed_ruin
	for(var/obj/effect/landmark/ruin/ruin_landmark as anything in GLOB.ruin_landmarks)
		if(ruin_landmark.z != chassis.z)
			continue
		if(!pinpointed_ruin || get_dist(ruin_landmark, chassis) < get_dist(pinpointed_ruin, chassis))
			pinpointed_ruin = ruin_landmark
	if(!pinpointed_ruin)
		chassis.balloon_alert(living_owner, "no ruins!")
		return
	var/datum/status_effect/agent_pinpointer/ruin_pinpointer = living_owner.apply_status_effect(/datum/status_effect/agent_pinpointer/ruin)
	ruin_pinpointer.RegisterSignal(living_owner, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/status_effect/agent_pinpointer/ruin, cancel_self))
	ruin_pinpointer.scan_target = pinpointed_ruin
	chassis.balloon_alert(living_owner, "pinpointing nearest ruin")

/datum/status_effect/agent_pinpointer/ruin
	duration = SEARCH_COOLDOWN * 0.5
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/ruin
	tick_interval = 3 SECONDS
	range_fuzz_factor = 0
	minimum_range = 5
	range_mid = 20
	range_far = 50

/datum/status_effect/agent_pinpointer/ruin/scan_for_target()
	return

/datum/status_effect/agent_pinpointer/ruin/proc/cancel_self(datum/source, atom/old_loc)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/agent_pinpointer/ruin
	name = "Ruin Target"
	desc = "Searching for valuables..."

#undef SEARCH_COOLDOWN
