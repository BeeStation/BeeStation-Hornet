/***************** WELCOME TO MECHA.DM, ENJOY YOUR STAY *****************/

/**
 * Mechs are now (finally) vehicles, this means you can make them multicrew
 * They can also grant select ability buttons based on occupant bitflags
 *
 * Movement is handled through vehicle_move() which is called by relaymove
 * Clicking is done by way of signals registering to the entering mob
 * NOTE: MMIS are NOT mobs but instead contain a brain that is, so you need special checks
 * AI also has special checks becaus it gets in and out of the mech differently
 * Always call remove_occupant(mob) when leaving the mech so the mob is removed properly
 *
 * For multi-crew, you need to set how the occupants receive ability bitflags corresponding to their status on the vehicle(i.e: driver, gunner etc)
 * Abilities can then be set to only apply for certain bitflags and are assigned as such automatically
 *
 * Clicks are wither translated into mech_melee_attack (see mech_melee_attack.dm)
 * Or are used to call action() on equipped gear
 * Cooldown for gear is on the mech because exploits
 */
/obj/vehicle/sealed/mecha
	name = "exosuit"
	desc = "Exosuit"
	icon = 'icons/mecha/mecha.dmi'
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 300
	armor_type = /datum/armor/sealed_mecha
	movedelay = 1 SECONDS
	force = 5
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	COOLDOWN_DECLARE(mecha_bump_smash)
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	light_power = 1
	light_range = 4
	generic_canpass = FALSE
	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_TRACK_HUD)
	mouse_pointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'

	//Beestation stuff
	///applied on_entered() by things which slow or restrict mech movement. Resets to zero at the end of every movement
	var/step_restricted = 0

	///How much energy the mech will consume each time it moves. this is the current active energy consumed
	var/step_energy_drain = 8
	///How much energy we drain each time we mechpunch someone
	var/melee_energy_drain = 15
	///Power we use to have the lights on
	var/light_energy_drain = 2
	///Modifiers for directional damage reduction
	var/list/facing_modifiers = list(MECHA_FRONT_ARMOUR = 0.5, MECHA_SIDE_ARMOUR = 1, MECHA_BACK_ARMOUR = 1.5)
	///if we cant use our equipment(such as due to EMP)
	var/equipment_disabled = FALSE
	/// Keeps track of the mech's cell
	var/obj/item/stock_parts/cell/cell
	/// Keeps track of the mech's scanning module
	var/obj/item/stock_parts/scanning_module/scanmod
	/// Keeps track of the mech's capacitor
	var/obj/item/stock_parts/capacitor/capacitor
	/// Keeps track of the mech's servo motor
	var/obj/item/stock_parts/manipulator/servo
	///Contains flags for the mecha
	var/mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS

	///Spark effects are handled by this datum
	var/datum/effect_system/spark_spread/spark_system = new
	///How powerful our lights are
	var/lights_power = 6
	///Just stop the mech from doing anything
	var/completely_disabled = FALSE
	///Whether this mech is allowed to move diagonally
	var/allow_diagonal_movement = TRUE
	///Whether this mech moves into a direct as soon as it goes to move. Basically, turn and step in the same key press.
	var/pivot_step = FALSE
	///Whether or not the mech destroys walls by running into it.
	var/bumpsmash = FALSE

	///////////ATMOS
	///Whether the cabin exchanges gases with the environment
	var/cabin_sealed = FALSE
	///Internal air mix datum
	var/datum/gas_mixture/cabin_air
	///Volume of the cabin
	var/cabin_volume = TANK_STANDARD_VOLUME * 3

	///List of installed remote tracking beacons, including AI control beacons
	var/list/trackers = list()

	var/max_temperature = 25000

	///Bitflags for internal damage
	var/internal_damage = NONE
	/// damage amount above which we can take internal damages
	var/internal_damage_threshold = 15
	/// % chance for internal damage to occur
	var/internal_damage_probability = 20
	/// list of possibly dealt internal damage for this mech type
	var/possible_int_damage = MECHA_INT_FIRE|MECHA_INT_TEMP_CONTROL|MECHA_CABIN_AIR_BREACH|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	/// damage threshold above which we take component damage
	var/component_damage_threshold = 10

	///Stores the DNA enzymes of a carbon so tht only they can access the mech
	//var/dna_lock
	/// A list of all granted accesses
	var/list/accesses = list()
	/// If the mech should require ALL or only ONE of the listed accesses
	var/one_access = TRUE

	///Typepath for the wreckage it spawns when destroyed
	var/wreckage
	///single flag for the type of this mech, determines what kind of equipment can be attached to it
	var/mech_type

	///assoc list: key-typepathlist before init, key-equipmentlist after
	var/list/equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	///assoc list: max equips for modules key-count
	var/list/max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 2,
		MECHA_POWER = 1,
		MECHA_ARMOR = 0,
	)
	///flat equipment for iteration
	var/list/flat_equipment

	///Handles an internal ore box for mining mechs
	var/obj/structure/ore_box/ore_box

	///Whether our steps are silent due to no gravity
	var/step_silent = FALSE
	///Sound played when the mech moves
	var/stepsound = 'sound/mecha/mechstep.ogg'
	///Sound played when the mech walks
	var/turnsound = 'sound/mecha/mechturn.ogg'

	///Cooldown duration between melee punches
	var/melee_cooldown = 10

	///TIme taken to leave the mech
	var/exit_delay = 2 SECONDS
	///Time you get knocked down for if you get forcible ejected by the mech exploding
	var/destruction_knockdown_duration = 4 SECONDS
	///In case theres a different iconstate for AI/MMI pilot(currently only used for ripley)
	var/silicon_icon_state = null
	///Currently ejecting, and unable to do things
	var/is_currently_ejecting = FALSE
	//Safety for weapons. Won't fire if enabled, and toggled by middle click.
	var/weapons_safety = FALSE

	var/datum/effect_system/smoke_spread/smoke_system = new

	////Action vars
	///Ref to any active thrusters we might have
	var/obj/item/mecha_parts/mecha_equipment/thrusters/active_thrusters

	///Bool for energy shield on/off
	var/defense_mode = FALSE

	///Bool for leg overload on/off
	var/overclock_mode = FALSE
	///Whether it is possible to toggle overclocking from the cabin
	var/can_use_overclock = FALSE
	///Speed and energy usage modifier for leg overload
	var/overclock_coeff = 1.5
	///Current leg actuator temperature. Increases when overloaded, decreases when not.
	var/overclock_temp = 0
	///Temperature threshold at which actuators may start causing internal damage
	var/overclock_temp_danger = 15
	///Whether the mech has an option to enable safe overclocking
	var/overclock_safety_available = FALSE
	///Whether the overclocking turns off automatically when overheated
	var/overclock_safety = FALSE

	//Bool for zoom on/off
	var/zoom_mode = FALSE

	///Remaining smoke charges
	var/smoke_charges = 5
	///Cooldown between using smoke
	var/smoke_cooldown = 10 SECONDS

	///check for phasing, if it is set to text (to describe how it is phasing: "flying", "phasing") it will let the mech walk through walls.
	var/phasing = ""
	///Power we use every time we phaze through something
	var/phasing_energy_drain = 200
	///icon_state for flick() when phazing
	var/phase_state = ""

	///Whether we are strafing
	var/strafe = FALSE

	///Cooldown length between bumpsmashes
	var/smashcooldown = 3

	///Bool for whether this mech can only be used on lavaland
	var/lavaland_only = FALSE

	/// ref to screen object that displays in the middle of the UI
	var/atom/movable/screen/mech_view/ui_view

	/// Theme of the mech TGUI
	var/ui_theme = "ntos"
	/// Module selected by default when mech UI is opened
	var/ui_selected_module_index

/datum/armor/sealed_mecha
	melee = 20
	bullet = 10
	bomb = 10
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/Initialize(mapload, built_manually)
	. = ..()
	ui_view = new(null, src)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

	spark_system.set_up(2, 0, src)
	spark_system.attach(src)

	smoke_system.set_up(3, src)
	smoke_system.attach(src)

	cabin_air = new(cabin_volume)

	if(!built_manually)
		populate_parts()
	update_access()
	wires = new /datum/wires/mecha(src)
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	log_message("[src.name] created.", LOG_MECHA)
	GLOB.mechas_list += src //global mech list
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()
	update_appearance()

	become_hearing_sensitive(trait_source = ROUNDSTART_TRAIT)
	//ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, ROUNDSTART_TRAIT) //protects pilots from ashstorms.
	for(var/key in equip_by_category)
		if(key == MECHA_L_ARM || key == MECHA_R_ARM)
			var/path = equip_by_category[key]
			if(!path)
				continue
			var/obj/item/mecha_parts/mecha_equipment/thing = new path
			thing.attach(src, key == MECHA_R_ARM)
			continue
		for(var/path in equip_by_category[key])
			var/obj/item/mecha_parts/mecha_equipment/thing = new path
			thing.attach(src, FALSE)
			equip_by_category[key] -= path

	AddElement(/datum/element/atmos_sensitive)
	AddElement(/datum/element/falling_hazard, damage = 80, hardhat_safety = FALSE, crushes = TRUE)
	AddElement(/datum/element/hostile_machine)

//separate proc so that the ejection mechanism can be easily triggered by other things, such as admins
/obj/vehicle/sealed/mecha/proc/Eject(mob/living/silicon/ai/unlucky_ai)

	for(var/mob/living/occupant as anything in occupants)
		if(isAI(occupant))
			var/mob/living/silicon/ai/ai = occupant
			if(!ai.linked_core) // we probably shouldnt gib AIs with a core
				unlucky_ai = occupant
				ai.investigate_log("has been gibbed by having their mech destroyed.", INVESTIGATE_DEATHS)
				ai.gib() //No wreck, no AI to recover
			else
				mob_exit(ai, silent = TRUE, forced = TRUE) // so we dont ghost the AI
		else
			occupant.Stun(2 SECONDS)
			occupant.Knockdown(destruction_knockdown_duration)
			occupant.throwing = TRUE //This is somewhat hacky, but is the best option available to avoid chasm detection for the split second between the next two lines
			occupant.forceMove(get_turf(loc))
			occupant.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(5, 8),rand(5, 8)) //resets the throwing variable above. Random values are independant on purpose to give variance to damage on wallslams and the distance the occupant is ejected.
			occupant.visible_message(span_userdanger("[occupant] is forcefully ejected from the mech!"), span_userdanger("You are forcefully ejected from the mech!"), null, COMBAT_MESSAGE_RANGE)
			playsound(src, 'sound/machines/scanbuzz.ogg', 60, FALSE)
			playsound(src, 'sound/vehicles/carcannon1.ogg', 150, TRUE)

/obj/vehicle/sealed/mecha/Destroy()
	Eject()
	if(LAZYLEN(flat_equipment))
		for(var/obj/item/mecha_parts/mecha_equipment/equip as anything in flat_equipment)
			equip.detach(loc)
			qdel(equip)

	STOP_PROCESSING(SSobj, src)
	LAZYCLEARLIST(flat_equipment)

	QDEL_NULL(ore_box)

	QDEL_NULL(cell)
	QDEL_NULL(scanmod)
	QDEL_NULL(capacitor)
	QDEL_NULL(servo)
	QDEL_NULL(cabin_air)
	QDEL_NULL(spark_system)
	QDEL_NULL(smoke_system)
	QDEL_NULL(ui_view)
	QDEL_NULL(wires)

	GLOB.mechas_list -= src //global mech list
	return ..()

///Add parts on mech spawning. Skipped in manual construction.
/obj/vehicle/sealed/mecha/proc/populate_parts()
	cell = new /obj/item/stock_parts/cell/high(src)
	scanmod = new /obj/item/stock_parts/scanning_module(src)
	capacitor = new /obj/item/stock_parts/capacitor(src)
	servo = new /obj/item/stock_parts/manipulator(src)
	update_part_values()

/obj/vehicle/sealed/mecha/CheckParts(list/parts_list)
	. = ..()
	cell = locate(/obj/item/stock_parts/cell) in contents
	diag_hud_set_mechcell()
	scanmod = locate(/obj/item/stock_parts/scanning_module) in contents
	capacitor = locate(/obj/item/stock_parts/capacitor) in contents
	servo = locate(/obj/item/stock_parts/manipulator) in contents
	update_part_values()

/obj/vehicle/sealed/mecha/atom_destruction()
	spark_system?.start()
	loc.assume_air(cabin_air)

	var/mob/living/silicon/ai/unlucky_ai
	Eject(unlucky_ai)

	if(wreckage)
		var/obj/structure/mecha_wreckage/WR = new wreckage(loc, unlucky_ai)
		for(var/obj/item/mecha_parts/mecha_equipment/E in flat_equipment)
			if(E.detachable && prob(30))
				WR.crowbar_salvage += E
				E.detach(WR) //detaches from src into WR
				E.active = TRUE
			else
				E.detach(loc)
				qdel(E)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.use(rand(0, cell.charge), TRUE)
			cell = null
	return ..()

/obj/vehicle/sealed/mecha/update_icon_state()
	icon_state = get_mecha_occupancy_state()
	return ..()

/**
 * Toggles Weapons Safety
 *
 * Handles enabling or disabling the safety function.
 */
/obj/vehicle/sealed/mecha/proc/set_safety(mob/user)
	weapons_safety = !weapons_safety
	SEND_SOUND(user, sound('sound/machines/beep.ogg', volume = 25))
	balloon_alert(user, "equipment [weapons_safety ? "safe" : "ready"]")
	set_mouse_pointer()
	SEND_SIGNAL(src, COMSIG_MECH_SAFETIES_TOGGLE, user, weapons_safety)

/**
 * Updates the pilot's mouse cursor override.
 *
 * If the mech's weapons safety is enabled, there should be no override, and the user gets their regular mouse cursor. If safety
 * is off but the mech's equipment is disabled (such as by EMP), the cursor should be the red disabled version. Otherwise, if
 * safety is off and the equipment is functional, the cursor should be the regular green cursor. This proc sets the cursor.
 * correct and then updates it for each mob in the occupants list.
 */
/obj/vehicle/sealed/mecha/proc/set_mouse_pointer()
	if(weapons_safety)
		mouse_pointer = ""
	else
		if(equipment_disabled)
			mouse_pointer = 'icons/effects/mouse_pointers/mecha_mouse-disable.dmi'
		else
			mouse_pointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'

	for(var/mob/mob_occupant as anything in occupants)
		mob_occupant.update_mouse_pointer()

//override this proc if you need to split up mecha control between multiple people (see savannah_ivanov.dm)
/obj/vehicle/sealed/mecha/auto_assign_occupant_flags(mob/M)
	if(driver_amount() < max_drivers)
		add_control_flags(M, FULL_MECHA_CONTROL)

/obj/vehicle/sealed/mecha/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	if(mecha_flags & IS_ENCLOSED)
		initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_cabin_seal, VEHICLE_CONTROL_SETTINGS)
	if(can_use_overclock)
		initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_overclock)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_safeties, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/strafe, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/mecha/proc/get_mecha_occupancy_state()
	if((mecha_flags & SILICON_PILOT) && silicon_icon_state)
		return silicon_icon_state
	if(LAZYLEN(occupants))
		return base_icon_state
	return "[base_icon_state]-open"

/obj/vehicle/sealed/mecha/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	if(!phasing || get_charge() <= phasing_energy_drain || throwing)
		return ..()
	if(phase_state)
		flick(phase_state, src)
	var/turf/destination_turf = get_step(loc, movement_dir)
	var/area/destination_area = destination_turf.loc
	if(destination_area.teleport_restriction >= TELEPORT_ALLOW_NONE)
		return FALSE
	return TRUE

/obj/vehicle/sealed/mecha/get_cell()
	return cell

/obj/vehicle/sealed/mecha/rust_heretic_act()
	take_damage(500,  BRUTE)
	return TRUE

/obj/vehicle/sealed/mecha/proc/restore_equipment()
	equipment_disabled = FALSE
	for(var/occupant in occupants)
		var/mob/mob_occupant = occupant
		SEND_SOUND(mob_occupant, sound('sound/items/timer.ogg', volume=50))
		to_chat(mob_occupant, span_notice("Equipment control unit has been rebooted successfully."))
	set_mouse_pointer()

/obj/vehicle/sealed/mecha/proc/update_part_values() ///Updates the values given by scanning module and capacitor tier, called when a part is removed or inserted.
	update_energy_drain()

	if(capacitor)
		var/datum/armor/stock_armor = get_armor_by_type(armor_type)
		var/initial_energy = stock_armor.get_rating(ENERGY)
		set_armor_rating(ENERGY, initial_energy + (capacitor.rating * 5))
		overclock_temp_danger = initial(overclock_temp_danger) * capacitor.rating
	else
		overclock_temp_danger = initial(overclock_temp_danger)


////////////////////////////////////////////////////////////////////////////////

/obj/vehicle/sealed/mecha/examine(mob/user)
	. = ..()
	if(LAZYLEN(flat_equipment))
		. += span_notice("It's equipped with:")
		for(var/obj/item/mecha_parts/mecha_equipment/ME as anything in flat_equipment)
			if(istype(ME, /obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay))
				continue
			. += span_notice("[icon2html(ME, user)] \A [ME].")
	if(mecha_flags & PANEL_OPEN)
		if(servo)
			. += span_notice("Micro-servos reduce movement power usage by [100 - round(100 / servo.rating)]%")
		else
			. += span_warning("It's missing a micro-servo.")
		if(capacitor)
			. += span_notice("Capacitor increases armor against energy attacks by [capacitor.rating * 5].")
		else
			. += span_warning("It's missing a capacitor.")
		if(!scanmod)
			. += span_warning("It's missing a scanning module.")
	if(mecha_flags & IS_ENCLOSED)
		return
	if(mecha_flags & SILICON_PILOT)
		. += span_notice("[src] appears to be piloting itself...")
	else
		for(var/occupante in occupants)
			. += span_notice("You can see [occupante] inside.")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			for(var/held_item in H.held_items)
				if(!isgun(held_item))
					continue
				. += span_warning("It looks like you can hit the pilot directly if you target the center or above.")
				break //in case user is holding two guns

/obj/vehicle/sealed/mecha/generate_integrity_message()
	var/examine_text = ""
	var/integrity = atom_integrity*100/max_integrity

	switch(integrity)
		if(85 to 100)
			examine_text = "It's fully intact."
		if(65 to 85)
			examine_text = "It's slightly damaged."
		if(45 to 65)
			examine_text = "It's badly damaged."
		if(25 to 45)
			examine_text = "It's heavily damaged."
		else
			examine_text = "It's falling apart."

	return examine_text

///Locate an internal tack in the utility modules
/obj/vehicle/sealed/mecha/proc/get_internal_tank()
	var/obj/item/mecha_parts/mecha_equipment/air_tank/module = locate(/obj/item/mecha_parts/mecha_equipment/air_tank) in equip_by_category[MECHA_UTILITY]
	return module?.internal_tank

//processing internal damage, temperature, air regulation, alert updates, lights power use.
/obj/vehicle/sealed/mecha/process(delta_time)
	if(overclock_mode || overclock_temp > 0)
		process_overclock_effects(delta_time)
	if(internal_damage)
		process_internal_damage_effects(delta_time)
	if(cabin_sealed)
		process_cabin_air(delta_time)
	if(length(occupants))
		process_occupants(delta_time)
	process_constant_power_usage(delta_time)

/obj/vehicle/sealed/mecha/proc/process_overclock_effects(delta_time)
	if(!overclock_mode && overclock_temp > 0)
		overclock_temp -= delta_time
		return
	overclock_temp = min(overclock_temp + delta_time, overclock_temp_danger * 2)
	if(overclock_temp < overclock_temp_danger)
		return
	if(overclock_temp >= overclock_temp_danger && overclock_safety)
		toggle_overclock(FALSE)
		return
	var/damage_chance = 100 * ((overclock_temp - overclock_temp_danger) / (overclock_temp_danger * 2))
	if(DT_PROB(damage_chance, delta_time))
		do_sparks(5, TRUE, src)
		try_deal_internal_damage(damage_chance)
		take_damage(delta_time, BURN, 0, 0)

/obj/vehicle/sealed/mecha/proc/process_internal_damage_effects(delta_time)
	if(internal_damage & MECHA_INT_FIRE)
		if(!(internal_damage & MECHA_INT_TEMP_CONTROL) && DT_PROB(2.5, delta_time))
			clear_internal_damage(MECHA_INT_FIRE)
		if(cabin_air && cabin_sealed && cabin_air.return_volume()>0)
			if(cabin_air.return_pressure() > (PUMP_DEFAULT_PRESSURE * 30) && !(internal_damage & MECHA_CABIN_AIR_BREACH))
				set_internal_damage(MECHA_CABIN_AIR_BREACH)
			cabin_air.temperature = min(6000+T0C, cabin_air.temperature+rand(5,7.5)*delta_time)
			if(cabin_air.return_temperature() > max_temperature/2)
				take_damage(delta_time*2/round(max_temperature/cabin_air.return_temperature(),0.1), BURN, 0, 0)

	if(internal_damage & MECHA_CABIN_AIR_BREACH && cabin_air && cabin_sealed) //remove some air from cabin_air
		var/datum/gas_mixture/leaked_gas = cabin_air.remove_ratio(DT_PROB_RATE(0.05, delta_time))
		if(loc)
			loc.assume_air(leaked_gas)
		else
			qdel(leaked_gas)

	if(internal_damage & MECHA_INT_SHORT_CIRCUIT && get_charge())
		spark_system.start()
		use_power(min(10 * delta_time, cell.charge))
		cell.maxcharge -= min(10 * delta_time, cell.maxcharge)

/obj/vehicle/sealed/mecha/proc/process_cabin_air(delta_time)
	if(!(internal_damage & MECHA_INT_TEMP_CONTROL) && cabin_air && cabin_air.return_volume() > 0)
		var/heat_capacity = cabin_air.heat_capacity()
		var/required_energy = abs(T20C - cabin_air.temperature) * heat_capacity
		required_energy = min(required_energy, 1000)
		if(required_energy < 1)
			return
		var/delta_temperature = required_energy / heat_capacity
		if(delta_temperature)
			if(cabin_air.temperature < T20C)
				cabin_air.temperature += delta_temperature
			else
				cabin_air.temperature -= delta_temperature

/obj/vehicle/sealed/mecha/proc/process_occupants(delta_time)
	for(var/mob/living/occupant as anything in occupants)
		if(!(mecha_flags & IS_ENCLOSED) && occupant?.incapacitated) //no sides mean it's easy to just sorta fall out if you're incapacitated.
			visible_message(span_warning("[occupant] tumbles out of the cockpit!"))
			mob_exit(occupant, randomstep = TRUE) //bye bye
			continue
		if(cell)
			var/cellcharge = cell.maxcharge ? cell.charge / cell.maxcharge : 0 //Division by 0 protection
			switch(cellcharge)
				if(0.75 to INFINITY)
					occupant.clear_alert("charge")
				if(0.5 to 0.75)
					occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 1)
				if(0.25 to 0.5)
					occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 2)
				if(0.01 to 0.25)
					occupant.throw_alert("charge", /atom/movable/screen/alert/lowcell, 3)
				else
					occupant.throw_alert("charge", /atom/movable/screen/alert/emptycell)

		var/integrity = atom_integrity/max_integrity*100
		switch(integrity)
			if(30 to 45)
				occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 1)
			if(15 to 35)
				occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 2)
			if(-INFINITY to 15)
				occupant.throw_alert("mech damage", /atom/movable/screen/alert/low_mech_integrity, 3)
			else
				occupant.clear_alert("mech damage")
		var/atom/checking = occupant.loc
		// recursive check to handle all cases regarding very nested occupants,
		// such as brainmob inside brainitem inside MMI inside mecha
		while (!isnull(checking))
			if (isturf(checking))
				// hit a turf before hitting the mecha, seems like they have
				// been moved out
				occupant.clear_alert("charge")
				occupant.clear_alert("mech damage")
				occupant = null
				break
			else if (checking == src)
				break  // all good
			checking = checking.loc
	//Diagnostic HUD updates
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()

/obj/vehicle/sealed/mecha/proc/process_constant_power_usage(seconds_per_tick)
	if(mecha_flags & LIGHTS_ON && !use_power(light_energy_drain * seconds_per_tick))
		mecha_flags &= ~LIGHTS_ON
		set_light_on(mecha_flags & LIGHTS_ON)
		playsound(src,'sound/machines/clockcult/brass_skewer.ogg', 40, TRUE)
		log_message("Toggled lights off due to the lack of power.", LOG_MECHA)

///Called when a driver clicks somewhere. Handles everything like equipment, punches, etc.
/obj/vehicle/sealed/mecha/proc/on_mouseclick(mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		set_safety(user)
		return COMSIG_MOB_CANCEL_CLICKON
	if(weapons_safety)
		return
	if(isAI(user)) //For AIs: If safeties are off, use mech functions. If safeties are on, use AI functions.
		. = COMSIG_MOB_CANCEL_CLICKON
	if(modifiers[SHIFT_CLICK]) //Allows things to be examined.
		return
	if(!isturf(target) && !isturf(target.loc)) // Prevents inventory from being drilled
		return
	if(completely_disabled || is_currently_ejecting || (mecha_flags & CANNOT_INTERACT))
		return
	if(phasing)
		balloon_alert(user, "not while [phasing]!")
		return
	if(user.incapacitated)
		return
	if(!get_charge())
		return
	if(src == target)
		return
	var/dir_to_target = get_dir(src,target)
	if(!(mecha_flags & OMNIDIRECTIONAL_ATTACKS) && dir_to_target && !(dir_to_target & dir))//wrong direction
		return
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		target = pick(view(3,target))
	var/mob/living/livinguser = user
	if(!(livinguser in return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)))
		balloon_alert(user, "wrong seat for equipment!")
		return
	var/obj/item/mecha_parts/mecha_equipment/selected
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		selected = equip_by_category[MECHA_R_ARM]
	else
		selected = equip_by_category[MECHA_L_ARM]
	if(selected)
		if(!Adjacent(target) && (selected.range & MECHA_RANGED))
			if(HAS_TRAIT(livinguser, TRAIT_PACIFISM) && selected.harmful)
				to_chat(livinguser, span_warning("You don't want to harm other living beings!"))
				return
			if(SEND_SIGNAL(src, COMSIG_MECHA_EQUIPMENT_CLICK, livinguser, target) & COMPONENT_CANCEL_EQUIPMENT_CLICK)
				return
			INVOKE_ASYNC(selected, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment, action), user, target, modifiers)
			return
		if(Adjacent(target) && (selected.range & MECHA_MELEE))
			if(isliving(target) && selected.harmful && HAS_TRAIT(livinguser, TRAIT_PACIFISM))
				to_chat(livinguser, span_warning("You don't want to harm other living beings!"))
				return
			if(SEND_SIGNAL(src, COMSIG_MECHA_EQUIPMENT_CLICK, livinguser, target) & COMPONENT_CANCEL_EQUIPMENT_CLICK)
				return
			INVOKE_ASYNC(selected, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment, action), user, target, modifiers)
			return
	if(!(livinguser in return_controllers_with_flag(VEHICLE_CONTROL_MELEE)))
		to_chat(livinguser, "<span class='warning'>You're in the wrong seat to interact with your hands.</span>")
		return
	var/on_cooldown = TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MELEE_ATTACK)
	var/adjacent = Adjacent(target)
	if(SEND_SIGNAL(src, COMSIG_MECHA_MELEE_CLICK, livinguser, target, on_cooldown, adjacent) & COMPONENT_CANCEL_MELEE_CLICK)
		return
	if(on_cooldown || !adjacent)
		return
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		target = pick(oview(1,src))

	if(!has_charge(melee_energy_drain))
		return
	use_power(melee_energy_drain)

	target.mech_melee_attack(src, user)
	TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MELEE_ATTACK, melee_cooldown)

///Displays a special speech bubble when someone inside the mecha speaks
/obj/vehicle/sealed/mecha/proc/display_speech_bubble(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/list/speech_bubble_recipients = list()
	for(var/mob/listener in get_hearers_in_view(7, src))
		if(listener.client)
			speech_bubble_recipients += listener.client

	var/image/mech_speech = image('icons/mob/talk.dmi', src, "machine[say_test(speech_args[SPEECH_MESSAGE])]",MOB_LAYER+1)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay_global), mech_speech, speech_bubble_recipients, 3 SECONDS)

/obj/vehicle/sealed/mecha/on_emag(mob/user)
	..()
	playsound(src, "sparks", 100, 1)
	to_chat(user, span_warning("You short out the mech suit's internal controls."))
	equipment_disabled = TRUE
	log_message("System emagged detected", LOG_MECHA, color="red")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/vehicle/sealed/mecha, restore_equipment)), 15 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/////////////////////////////////////
//////////// AI piloting ////////////
/////////////////////////////////////

/obj/vehicle/sealed/mecha/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	//Allows the Malf to scan a mech's status and loadout, helping it to decide if it is a worthy chariot.
	if(user.can_dominate_mechs)
		examine(user) //Get diagnostic information!
		for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)
			to_chat(user, span_danger("Warning: Tracking Beacon detected. Enter at your own risk. Beacon Data:"))
			to_chat(user, "[B.get_mecha_info()]")
			break
		//Nothing like a big, red link to make the player feel powerful!
		to_chat(user, "<a href='byond://?src=[REF(user)];ai_take_control=[REF(src)]'>[span_userdanger("ASSUME DIRECT CONTROL?")]</a><br>")
		return
	examine(user)
	if(length(return_drivers()) > 0)
		to_chat(user, span_warning("This exosuit has a pilot and cannot be controlled."))
		return
	var/can_control_mech = FALSE
	for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in trackers)
		can_control_mech = TRUE
		to_chat(user, "[span_notice("[icon2html(src, user)] Status of [name]:")]\n[A.get_mecha_info()]")
		break
	if(!can_control_mech)
		to_chat(user, span_warning("You cannot control exosuits without AI control beacons installed."))
		return
	to_chat(user, "<a href='byond://?src=[REF(user)];ai_take_control=[REF(src)]'>[span_boldnotice("Take control of exosuit?")]</a><br>")

/obj/vehicle/sealed/mecha/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return

	//Transfer from core or card to mech. Proc is called by mech.
	switch(interaction)
		if(AI_TRANS_TO_CARD) //Upload AI from mech to AI card.
			if(!(mecha_flags & PANEL_OPEN)) //Mech must be in maint mode to allow carding.
				to_chat(user, span_warning("[name] must have maintenance protocols active in order to allow a transfer."))
				return
			var/list/ai_pilots = list()
			for(var/mob/living/silicon/ai/aipilot in occupants)
				ai_pilots += aipilot
			if(!ai_pilots.len) //Mech does not have an AI for a pilot
				to_chat(user, span_warning("No AI detected in the [name] onboard computer."))
				return
			if(ai_pilots.len > 1) //Input box for multiple AIs, but if there's only one we'll default to them.
				AI = input(user,"Which AI do you wish to card?", "AI Selection") as null|anything in sort_list(ai_pilots)
			else
				AI = ai_pilots[1]
			if(!AI)
				return
			if(!(AI in occupants) || !user.Adjacent(src))
				return //User sat on the selection window and things changed.

			AI.ai_restore_power()//So the AI initially has power.
			AI.control_disabled = TRUE
			AI.radio_enabled = FALSE
			AI.disconnect_shell()
			remove_occupant(AI)
			mecha_flags  &= ~SILICON_PILOT
			AI.forceMove(card)
			card.AI = AI
			AI.controlled_equipment = null
			AI.remote_control = null
			to_chat(AI, "You have been downloaded to a mobile storage device. Wireless connection offline.")
			to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")
			return

		if(AI_MECH_HACK) //Called by AIs on the mech
			AI.linked_core = new /obj/structure/AIcore/deactivated(AI.loc)
			if(AI.can_dominate_mechs && LAZYLEN(occupants)) //Oh, I am sorry, were you using that?
				to_chat(AI, span_warning("Occupants detected! Forced ejection initiated!"))
				to_chat(occupants, span_danger("You have been forcibly ejected!"))
				for(var/ejectee in occupants)
					mob_exit(ejectee, silent = TRUE, randomstep = TRUE, forced = TRUE) //IT IS MINE, NOW. SUCK IT, RD!
				AI.can_shunt = FALSE //ONE AI ENTERS. NO AI LEAVES.

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to a mech.
			AI = card.AI
			if(!AI)
				to_chat(user, span_warning("There is no AI currently installed on this device."))
				return
			if(AI.deployed_shell) //Recall AI if shelled so it can be checked for a client
				AI.disconnect_shell()
			if(AI.stat || !AI.client)
				to_chat(user, span_warning("[AI.name] is currently unresponsive, and cannot be uploaded."))
				return
			if(LAZYLEN(occupants) >= max_occupants) //Normal AIs cannot steal mechs!
				to_chat(user, span_warning("Access denied. [name] is [LAZYLEN(occupants) >= max_occupants ? "currently fully occupied" : "secured with a DNA lock"]."))
				return
			AI.control_disabled = FALSE
			AI.radio_enabled = TRUE
			to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			card.AI = null
	ai_enter_mech(AI)

//Hack and From Card interactions share some code, so leave that here for both to use.
/obj/vehicle/sealed/mecha/proc/ai_enter_mech(mob/living/silicon/ai/AI)
	AI.ai_restore_power()
	mecha_flags |= SILICON_PILOT
	moved_inside(AI)
	AI.cancel_camera()
	AI.controlled_equipment = src
	AI.remote_control = src
	to_chat(AI, AI.can_dominate_mechs ? span_announce("Takeover of [name] complete! You are now loaded onto the onboard computer. Do not attempt to leave the station sector!") :\
		span_notice("You have been uploaded to a mech's onboard computer."))
	to_chat(AI, span_reallybigboldnotice("Use Middle-Mouse or the action button in your HUD to toggle equipment safety. Clicks with safety enabled will pass AI commands."))

///Handles an actual AI (simple_animal mecha pilot) entering the mech
/obj/vehicle/sealed/mecha/proc/aimob_enter_mech(mob/living/simple_animal/hostile/syndicate/mecha_pilot/pilot_mob)
	if(!pilot_mob?.Adjacent(src))
		return
	if(LAZYLEN(occupants))
		return
	LAZYSET(occupants, pilot_mob, NONE)
	pilot_mob.mecha = src
	pilot_mob.forceMove(src)
	update_appearance()

///Handles an actual AI (simple_animal mecha pilot) exiting the mech
/obj/vehicle/sealed/mecha/proc/aimob_exit_mech(mob/living/simple_animal/hostile/syndicate/mecha_pilot/pilot_mob)
	LAZYREMOVE(occupants, pilot_mob)
	if(pilot_mob.mecha == src)
		pilot_mob.mecha = null
	pilot_mob.forceMove(get_turf(src))
	update_appearance()

/obj/vehicle/sealed/mecha/remove_air(amount)
	if((mecha_flags & IS_ENCLOSED) && cabin_sealed)
		return cabin_air.remove(amount)
	return ..()

/obj/vehicle/sealed/mecha/return_air()
	if((mecha_flags & IS_ENCLOSED) && cabin_sealed)
		return cabin_air
	return ..()

/obj/vehicle/sealed/mecha/return_analyzable_air()
	return cabin_air

///fetches pressure of the gas mixture we are using
/obj/vehicle/sealed/mecha/proc/return_pressure()
	var/datum/gas_mixture/air = return_air()
	return air?.return_pressure()

///fetches temp of the gas mixture we are using
/obj/vehicle/sealed/mecha/return_temperature()
	var/datum/gas_mixture/air = return_air()
	return air?.return_temperature()

///makes cabin unsealed, dumping cabin air outside or airtight filling the cabin with external air mix
/obj/vehicle/sealed/mecha/proc/set_cabin_seal(mob/user, cabin_sealed)
	if(!(mecha_flags & IS_ENCLOSED))
		balloon_alert(user, "cabin can't be sealed!")
		log_message("Tried to seal cabin. This mech can't be airtight.", LOG_MECHA)
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_CABIN_SEAL))
		balloon_alert(user, "on cooldown!")
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_CABIN_SEAL, 1 SECONDS)

	src.cabin_sealed = cabin_sealed

	var/datum/gas_mixture/environment_air = loc.return_air()
	if(!isnull(environment_air))
		if(cabin_sealed)
			// Fill cabin with air
			environment_air.pump_gas_to(cabin_air, environment_air.return_pressure())
		else
			// Dump cabin air
			var/datum/gas_mixture/removed_gases = cabin_air.remove_ratio(1)
			if(loc)
				loc.assume_air(removed_gases)
			else
				qdel(removed_gases)

	var/obj/item/mecha_parts/mecha_equipment/air_tank/tank = locate(/obj/item/mecha_parts/mecha_equipment/air_tank) in equip_by_category[MECHA_UTILITY]
	for(var/mob/occupant as anything in occupants)
		var/datum/action/action = locate(/datum/action/vehicle/sealed/mecha/mech_toggle_cabin_seal) in occupant.actions
		if(!isnull(tank) && cabin_sealed && tank.auto_pressurize_on_seal)
			if(!tank.active)
				tank.set_active(TRUE)
			else
				action.button_icon_state = "mech_cabin_pressurized"
				action.update_buttons()
		else
			action.button_icon_state = "mech_cabin_[cabin_sealed ? "closed" : "open"]"
			action.update_buttons()

		balloon_alert(occupant, "cabin [cabin_sealed ? "sealed" : "unsealed"]")
	log_message("Cabin [cabin_sealed ? "sealed" : "unsealed"].", LOG_MECHA)
	playsound(src, 'sound/machines/airlock.ogg', 50, TRUE)

/obj/vehicle/sealed/mecha/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(mecha_flags & HAS_LIGHTS)
		visible_message(span_danger("[src]'s lights burn out!"))
		mecha_flags &= ~HAS_LIGHTS
		set_light_on(FALSE)
		for(var/occupant in occupants)
			remove_action_type_from_mob(/datum/action/vehicle/sealed/mecha/mech_toggle_lights, occupant)
		playsound(src, 'sound/items/welder.ogg', 50, 1)

/// Apply corresponding accesses
/obj/vehicle/sealed/mecha/proc/update_access()
	req_access = one_access ? list() : accesses
	req_one_access = one_access ? accesses : list()

/// Electrocute user from power celll
/obj/vehicle/sealed/mecha/proc/shock(mob/living/user)
	if(!istype(user) || get_charge() < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	return electrocute_mob(user, cell, src, 0.7, TRUE)

/// Toggle mech overclock with a button or by hacking
/obj/vehicle/sealed/mecha/proc/toggle_overclock(forced_state = null)
	if(!isnull(forced_state))
		if(overclock_mode == forced_state)
			return
		overclock_mode = forced_state
	else
		overclock_mode = !overclock_mode
	log_message("Toggled overclocking.", LOG_MECHA)

	for(var/mob/occupant as anything in occupants)
		var/datum/action/act = locate(/datum/action/vehicle/sealed/mecha/mech_overclock) in occupant.actions
		if(!act)
			continue
		act.button_icon_state = "mech_overload_[overclock_mode ? "on" : "off"]"
		balloon_alert(occupant, "overclock [overclock_mode ? "on":"off"]")
		act.update_buttons()

	if(overclock_mode)
		movedelay = movedelay / overclock_coeff
		visible_message(span_notice("[src] starts heating up, making humming sounds."))
	else
		movedelay = initial(movedelay)
		visible_message(span_notice("[src] cools down and the humming stops."))
	update_energy_drain()

/// Update the energy drain according to parts and status
/obj/vehicle/sealed/mecha/proc/update_energy_drain()
	if(servo)
		step_energy_drain = initial(step_energy_drain) / servo.rating
	else
		step_energy_drain = 2 * initial(step_energy_drain)
	if(overclock_mode)
		step_energy_drain *= overclock_coeff

	if(capacitor)
		phasing_energy_drain = initial(phasing_energy_drain) / capacitor.rating
		melee_energy_drain = initial(melee_energy_drain) / capacitor.rating
		light_energy_drain = initial(light_energy_drain) / capacitor.rating
	else
		phasing_energy_drain = initial(phasing_energy_drain)
		melee_energy_drain = initial(melee_energy_drain)
		light_energy_drain = initial(light_energy_drain)

/// Toggle lights on/off
/obj/vehicle/sealed/mecha/proc/toggle_lights(forced_state = null, mob/user)
	if(!(mecha_flags & HAS_LIGHTS))
		if(user)
			balloon_alert(user, "mech has no lights!")
		return
	if((!(mecha_flags & LIGHTS_ON) && forced_state != FALSE) && get_charge() < light_energy_drain)
		if(user)
			balloon_alert(user, "no power for lights!")
		return
	mecha_flags ^= LIGHTS_ON
	set_light_on(mecha_flags & LIGHTS_ON)
	playsound(src,'sound/machines/clockcult/brass_skewer.ogg', 40, TRUE)
	log_message("Toggled lights [(mecha_flags & LIGHTS_ON)?"on":"off"].", LOG_MECHA)
	for(var/mob/occupant as anything in occupants)
		var/datum/action/act = locate(/datum/action/vehicle/sealed/mecha/mech_toggle_lights) in occupant.actions
		if(mecha_flags & LIGHTS_ON)
			act.button_icon_state = "mech_lights_on"
		else
			act.button_icon_state = "mech_lights_off"
		balloon_alert(occupant, "lights [mecha_flags & LIGHTS_ON ? "on":"off"]")
		act.update_buttons()
