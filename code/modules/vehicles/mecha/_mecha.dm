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
	name = "mecha"
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
	///What direction will the mech face when entered/powered on? Defaults to South.
	var/dir_in = SOUTH
	///How much energy the mech will consume each time it moves. This variable is a backup for when leg actuators affect the energy drain.
	var/normal_step_energy_drain = 10

	//Beestation stuff
	///applied on_entered() by things which slow or restrict mech movement. Resets to zero at the end of every movement
	var/step_restricted = 0

	///How much energy the mech will consume each time it moves. this is the current active energy consumed
	var/step_energy_drain = 10
	///How much energy we drain each time we mechpunch someone
	var/melee_energy_drain = 15
	///The minimum amount of energy charge consumed by leg overload
	var/overload_step_energy_drain_min = 100
	///chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	var/deflect_chance = 10
	///Modifiers for directional armor
	var/list/facing_modifiers = list(MECHA_FRONT_ARMOUR = 1.5, MECHA_SIDE_ARMOUR = 1, MECHA_BACK_ARMOUR = 0.5)
	///if we cant use our equipment(such as due to EMP)
	var/equipment_disabled = FALSE
	/// Keeps track of the mech's cell
	var/obj/item/stock_parts/cell/cell
	/// Keeps track of the mech's scanning module
	var/obj/item/stock_parts/scanning_module/scanmod
	/// Keeps track of the mech's capacitor
	var/obj/item/stock_parts/capacitor/capacitor
	///Whether the mechs maintenance protocols are on or off
	var/construction_state = MECHA_LOCKED
	///Contains flags for the mecha
	var/mecha_flags = ADDING_ACCESS_POSSIBLE | CANSTRAFE | IS_ENCLOSED | HAS_LIGHTS

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
	///Whether we are currrently drawing from the internal tank
	var/use_internal_tank = FALSE
	///The setting of the valve on the internal tank
	var/internal_tank_valve = ONE_ATMOSPHERE
	///The internal air tank obj of the mech
	var/obj/machinery/portable_atmospherics/canister/air/internal_tank
	///Internal air mix datum
	var/datum/gas_mixture/cabin_air
	///The connected air port, if we have one
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port

	///Special version of the radio, which is unsellable
	var/obj/item/radio/mech/radio
	var/list/trackers = list()

	var/max_temperature = 25000
	///Bitflags for internal damage
	var/internal_damage = NONE
	///health percentage below which internal damage is possible
	var/internal_damage_threshold = 50

	///required access level for mecha operation
	var/list/operation_req_access = list()
	///required access to change internal components
	var/list/internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE)

	///Typepath for the wreckage it spawns when destroyed
	var/wreckage

	var/list/equipment = list()
	///Current active equipment
	var/obj/item/mecha_parts/mecha_equipment/selected
	///Current active equipment
	var/max_equip = 3

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
	///Whether outside viewers can see the pilot inside
	var/enclosed = TRUE
	///In case theres a different iconstate for AI/MMI pilot(currently only used for ripley)
	var/silicon_icon_state = null
	///Currently ejecting, and unable to do things
	var/is_currently_ejecting = FALSE

	var/datum/effect_system/smoke_spread/smoke_system = new

	////Action vars
	///Ref to any active thrusters we might have
	var/obj/item/mecha_parts/mecha_equipment/thrusters/active_thrusters

	///Bool for energy shield on/off
	var/defense_mode = FALSE

	///Bool for leg overload on/off
	var/leg_overload_mode = FALSE
	///Bool for leg overload on/off
	var/leg_overload_coeff = 100

	//Bool for zoom on/off
	var/zoom_mode = FALSE

	///Remaining smoke charges
	var/smoke_charges = 5
	///Cooldown between using smoke
	var/smoke_cooldown = 10 SECONDS

	///Bool for if the mech is currently phasing
	var/phasing = FALSE
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


	hud_possible = list (DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_TRACK_HUD)


/datum/armor/sealed_mecha
	melee = 20
	bullet = 10
	bomb = 10
	fire = 100
	acid = 100

/obj/item/radio/mech //this has to go somewhere
	subspace_transmission = TRUE

/obj/vehicle/sealed/mecha/Initialize(mapload)
	. = ..()
	if(enclosed)
		internal_tank = new (src)
		RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE , PROC_REF(disconnect_air))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(play_stepsound))

	spark_system.set_up(2, 0, src)
	spark_system.attach(src)

	smoke_system.set_up(3, src)
	smoke_system.attach(src)

	radio = new(src)
	radio.name = "[src] radio"

	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	SET_MOLES(/datum/gas/oxygen, cabin_air, O2STANDARD*ONE_ATMOSPHERE*cabin_air.return_volume()/(R_IDEAL_GAS_EQUATION*cabin_air.return_temperature()))
	SET_MOLES(/datum/gas/nitrogen, cabin_air, N2STANDARD*ONE_ATMOSPHERE*cabin_air.return_volume()/(R_IDEAL_GAS_EQUATION*cabin_air.return_temperature()))

	add_cell()
	add_scanmod()
	add_capacitor()
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

/obj/mecha/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/atmos_sensitive)

//separate proc so that the ejection mechanism can be easily triggered by other things, such as admins
/obj/vehicle/sealed/mecha/proc/Eject()
	for(var/mob/living/occupant as anything in occupants)
		if(isAI(occupant))
			occupant.gib() //No wreck, no AI to recover
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
	if(LAZYLEN(equipment))
		for(var/obj/item/mecha_parts/mecha_equipment/equip as anything in equipment)
			equip.detach(loc)
			qdel(equip)

	STOP_PROCESSING(SSobj, src)
	LAZYCLEARLIST(equipment)

	QDEL_NULL(cell)
	QDEL_NULL(scanmod)
	QDEL_NULL(capacitor)
	QDEL_NULL(internal_tank)
	QDEL_NULL(cabin_air)
	QDEL_NULL(spark_system)
	QDEL_NULL(smoke_system)

	GLOB.mechas_list -= src //global mech list
	return ..()

/obj/vehicle/sealed/mecha/atom_destruction()
	loc.assume_air(cabin_air)
	Eject()
	return ..()

/obj/vehicle/sealed/mecha/update_icon_state()
	if((mecha_flags & SILICON_PILOT) && silicon_icon_state)
		icon_state = silicon_icon_state
		return ..()
	if(LAZYLEN(occupants))
		icon_state = base_icon_state
		return ..()
	icon_state = "[base_icon_state]-open"
	return ..()

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
		mob_occupant.update_mouse_pointer()

/obj/vehicle/sealed/mecha/CheckParts(list/parts_list)
	. = ..()
	cell = locate(/obj/item/stock_parts/cell) in contents
	scanmod = locate(/obj/item/stock_parts/scanning_module) in contents
	capacitor = locate(/obj/item/stock_parts/capacitor) in contents
	update_part_values()

/obj/vehicle/sealed/mecha/proc/update_part_values() ///Updates the values given by scanning module and capacitor tier, called when a part is removed or inserted.
	if(scanmod)
		normal_step_energy_drain = 20 - (5 * scanmod.rating) //10 is normal, so on lowest part its worse, on second its ok and on higher its real good up to 0 on best
		step_energy_drain = normal_step_energy_drain
	else
		normal_step_energy_drain = 500
		step_energy_drain = normal_step_energy_drain
	if(capacitor)
		var/datum/armor/stock_armor = get_armor_by_type(armor_type)
		var/initial_energy = stock_armor.get_rating(ENERGY)
		set_armor_rating(ENERGY, initial_energy + (capacitor.rating * 5))


////////////////////////
////// Helpers /////////
////////////////////////

///Adds a cell, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_cell(var/obj/item/stock_parts/cell/C=null)
	QDEL_NULL(cell)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new /obj/item/stock_parts/cell/high/plus(src)

///Adds a scanning module, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_scanmod(var/obj/item/stock_parts/scanning_module/sm=null)
	QDEL_NULL(scanmod)
	if(sm)
		sm.forceMove(src)
		scanmod = sm
		return
	scanmod = new /obj/item/stock_parts/scanning_module(src)

///Adds a capacitor, for use in Map-spawned mechs, Nuke Ops mechs, and admin-spawned mechs. Mechs built by hand will replace this.
/obj/vehicle/sealed/mecha/proc/add_capacitor(var/obj/item/stock_parts/capacitor/cap=null)
	QDEL_NULL(capacitor)
	if(cap)
		cap.forceMove(src)
		capacitor = cap
		return
	capacitor = new /obj/item/stock_parts/capacitor(src)

////////////////////////////////////////////////////////////////////////////////

/obj/vehicle/sealed/mecha/examine(mob/user)
	. = ..()
	var/integrity = atom_integrity*100/max_integrity
	switch(integrity)
		if(85 to 100)
			. += "It's fully intact."
		if(65 to 85)
			. += "It's slightly damaged."
		if(45 to 65)
			. += "It's badly damaged."
		if(25 to 45)
			. += "It's heavily damaged."
		else
			. += "It's falling apart."
	var/hide_weapon = locate(/obj/item/mecha_parts/concealed_weapon_bay) in contents
	var/hidden_weapon = hide_weapon ? (locate(/obj/item/mecha_parts/mecha_equipment/weapon) in equipment) : null
	var/list/visible_equipment = equipment - hidden_weapon
	if(visible_equipment.len)
		. += "It's equipped with:"
		for(var/obj/item/mecha_parts/mecha_equipment/ME in visible_equipment)
			. += "[icon2html(ME, user)] \A [ME]."
	if(enclosed)
		return
	if(mecha_flags & SILICON_PILOT)
		. += "[src] appears to be piloting itself..."
	else
		for(var/occupante in occupants)
			. += "You can see [occupante] inside."
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			for(var/held_item in H.held_items)
				if(!isgun(held_item))
					continue
				. += span_warning("It looks like you can hit the pilot directly if you target the center or above.")
				break //in case user is holding two guns

//processing internal damage, temperature, air regulation, alert updates, lights power use.
/obj/vehicle/sealed/mecha/process(delta_time)
	if(internal_damage)
		if(internal_damage & MECHA_INT_FIRE)
			if(!(internal_damage & MECHA_INT_TEMP_CONTROL) && DT_PROB(2.5, delta_time))
				clear_internal_damage(MECHA_INT_FIRE)
			if(internal_tank)
				var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
				if(int_tank_air.return_pressure() > internal_tank.maximum_pressure && !(internal_damage & MECHA_INT_TANK_BREACH))
					set_internal_damage(MECHA_INT_TANK_BREACH)
				if(int_tank_air && int_tank_air.return_volume() > 0) //heat the air_contents
					int_tank_air.temperature = (min(6000+T0C, int_tank_air.return_temperature()+rand(10,15)))
			if(cabin_air && cabin_air.return_volume()>0)
				cabin_air.temperature = (min(6000+T0C, cabin_air.return_temperature()+rand(10,15)))
				if(cabin_air.return_temperature() > max_temperature/2)
					take_damage(delta_time*2/round(max_temperature/cabin_air.return_temperature(),0.1), BURN, 0, 0)

		if(internal_damage & MECHA_INT_TANK_BREACH) //remove some air from internal tank
			if(internal_tank)
				var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
				var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(DT_PROB_RATE(0.05, delta_time))
				if(loc)
					loc.assume_air(leaked_gas)
				else
					qdel(leaked_gas)

		if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
			if(get_charge())
				spark_system.start()
				cell.charge -= min(10 * delta_time, cell.charge)
				cell.maxcharge -= min(10 * delta_time, cell.maxcharge)

	if(!(internal_damage & MECHA_INT_TEMP_CONTROL))
		if(cabin_air && cabin_air.return_volume() > 0)
			var/delta = cabin_air.return_temperature() - T20C
			cabin_air.temperature = (cabin_air.return_temperature() - clamp(round(delta / 8, 0.1), -5, 5) * delta_time)

	if(internal_tank)
		var/datum/gas_mixture/tank_air = internal_tank.return_air()

		var/release_pressure = internal_tank_valve
		var/cabin_pressure = cabin_air.return_pressure()
		var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
		if(pressure_delta > 0) //cabin pressure lower than release pressure
			if(tank_air.return_temperature() > 0)
				tank_air.pump_gas_to(cabin_air, release_pressure)
		else if(pressure_delta < 0) //cabin pressure higher than release pressure
			var/datum/gas_mixture/t_air = return_air()
			if(pressure_delta > 0) //if location pressure is lower than cabin pressure
				cabin_air.pump_gas_to(t_air, cabin_pressure)

	for(var/mob/living/occupant as anything in occupants)
		if(!enclosed && occupant?.incapacitated())  //no sides mean it's easy to just sorta fall out if you're incapacitated.
			visible_message(span_warning("[occupant] tumbles out of the cockpit!"))
			mob_exit(occupant) //bye bye
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

	if(mecha_flags & LIGHTS_ON)
		use_power(2*delta_time)

//Diagnostic HUD updates
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()

/obj/vehicle/sealed/mecha/fire_act() //Check if we should ignite the pilot of an open-canopy mech
	. = ..()
	if(enclosed || mecha_flags & SILICON_PILOT)
		return
	for(var/mob/living/cookedalive as anything in occupants)
		if(cookedalive.fire_stacks < 5)
			cookedalive.fire_stacks += 1
			cookedalive.IgniteMob()

///Displays a special speech bubble when someone inside the mecha speaks
/obj/vehicle/sealed/mecha/proc/display_speech_bubble(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/list/speech_bubble_recipients = list()
	for(var/mob/listener in get_hearers_in_view(7, src))
		if(listener.client)
			speech_bubble_recipients += listener.client

	var/image/mech_speech = image('icons/mob/talk.dmi', src, "machine[say_test(speech_args[SPEECH_MESSAGE])]",MOB_LAYER+1)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay), mech_speech, speech_bubble_recipients, 3 SECONDS)

/obj/vehicle/sealed/mecha/on_emag(mob/user)
	..()
	playsound(src, "sparks", 100, 1)
	to_chat(user, span_warning("You short out the mech suit's internal controls."))
	equipment_disabled = TRUE
	log_message("System emagged detected", LOG_MECHA, color="red")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/vehicle/sealed/mecha, restore_equipment)), 15 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

////////////////////////////
///// Action processing ////
////////////////////////////

///Called when a driver clicks somewhere. Handles everything like equipment, punches, etc.
/obj/vehicle/sealed/mecha/proc/on_mouseclick(mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(modifiers[SHIFT_CLICK]) //Allows things to be examined.
		return
	if(!isturf(target) && !isturf(target.loc)) // Prevents inventory from being drilled
		return
	if(completely_disabled || is_currently_ejecting)
		return
	if(isAI(user) == !LAZYACCESS(modifiers, MIDDLE_CLICK))//BASICALLY if a human uses MMB, or an AI doesn't, then do nothing.
		return
	if(phasing)
		balloon_alert(user, "not while [phasing]!")
		return
	if(user.incapacitated())
		return
	if(construction_state)
		balloon_alert(user, "end maintenance first!")
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
	if(selected)
		if(!Adjacent(target) && (selected.range & MECHA_RANGED))
			if(HAS_TRAIT(livinguser, TRAIT_PACIFISM) && selected.harmful)
				to_chat(livinguser, span_warning("You don't want to harm other living beings!"))
				return
			INVOKE_ASYNC(selected, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment, action), user, target, modifiers)
			return
		if((selected.range & MECHA_MELEE) && Adjacent(target))
			if(isliving(target) && selected.harmful && HAS_TRAIT(livinguser, TRAIT_PACIFISM))
				to_chat(livinguser, span_warning("You don't want to harm other living beings!"))
				return
			INVOKE_ASYNC(selected, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment, action), user, target, modifiers)
			return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MELEE_ATTACK) || !Adjacent(target))
		return
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		target = pick(oview(1,src))
	if(force)
		target.mech_melee_attack(src, user)
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MELEE_ATTACK, melee_cooldown)

/obj/vehicle/sealed/mecha/proc/on_middlemouseclick(mob/user, atom/target, params)
	SIGNAL_HANDLER
	if(isAI(user))
		on_mouseclick(user, target, params)

//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////

/obj/vehicle/sealed/mecha/proc/play_stepsound()
	SIGNAL_HANDLER
	if(mecha_flags & QUIET_STEPS)
		return
	playsound(src, stepsound, 40, TRUE)

///Disconnects air tank- air port connection on mecha move
/obj/vehicle/sealed/mecha/proc/disconnect_air()
	SIGNAL_HANDLER
	if(internal_tank.disconnect()) // Something moved us and broke connection
		to_chat(occupants, "[icon2html(src, occupants)][span_warning("Air port connection has been severed!")]")
		log_message("Lost connection to gas port.", LOG_MECHA)

/obj/vehicle/sealed/mecha/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return

	var/atom/backup = get_spacemove_backup(movement_dir)
	if(backup && movement_dir)
		if(isturf(backup)) //get_spacemove_backup() already checks if a returned turf is solid, so we can just go
			return TRUE
		if(istype(backup, /atom/movable))
			var/atom/movable/movable_backup = backup
			if((!movable_backup.anchored) && (movable_backup.newtonian_move(turn(movement_dir, 180))))
				step_silent = TRUE
				if(return_drivers())
					to_chat(occupants, "[icon2html(src, occupants)][span_info("The [src] push off [movable_backup] to propel yourself.")]")
			return TRUE

	if(active_thrusters?.thrust(movement_dir))
		step_silent = TRUE
		return TRUE
	return FALSE

/obj/vehicle/sealed/mecha/relaymove(mob/living/user, direction)
	if(canmove)
		vehicle_move(direction)
	return TRUE

/obj/vehicle/sealed/mecha/vehicle_move(direction, forcerotate = FALSE)
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, movedelay + step_restricted)
	step_restricted = 0
	if(completely_disabled)
		return FALSE
	if(!direction)
		return FALSE
	if(internal_tank?.connected_port)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to move while connected to the air system port!")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(construction_state)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_danger("Maintenance protocols in effect.")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE

	if(direction == UP || direction == DOWN)
		return FALSE
	if(!Process_Spacemove(direction))
		return FALSE
	if(zoom_mode)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to move while in zoom mode!")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(!cell)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Missing power cell.")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(!scanmod || !capacitor)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Missing [scanmod? "capacitor" : "scanning module"].")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(!use_power(step_energy_drain))
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Insufficient power to move!")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(lavaland_only && is_mining_level(z))
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Invalid Environment.")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE

	var/olddir = dir

	if(internal_damage & MECHA_INT_CONTROL_LOST)
		direction = pick(GLOB.alldirs)

	//only mechs with diagonal movement may move diagonally
	if(!allow_diagonal_movement && ISDIAGONALDIR(direction))
		return TRUE

	var/keyheld = FALSE
	if(strafe)
		for(var/mob/driver as anything in return_drivers())
			if(driver.client?.keys_held["Alt"])
				keyheld = TRUE
				break

	//if we're not facing the way we're going rotate us
	if(dir != direction && !strafe || forcerotate || keyheld)
		if(dir != direction && !(mecha_flags & QUIET_TURNS) && !step_silent)
			playsound(src,turnsound,40,TRUE)
		setDir(direction)
		if(!pivot_step) //If we pivot step, we don't return here so we don't just come to a stop
			return TRUE


	set_glide_size(DELAY_TO_GLIDE_SIZE(movedelay))
	//Otherwise just walk normally
	. = step(src,direction, dir)
	if(phasing)
		use_power(phasing_energy_drain)
	if(strafe)
		setDir(olddir)
	after_move(direction)

/obj/vehicle/sealed/mecha/Bump(atom/obstacle)
	. = ..()
	if(phasing) //Theres only one cause for phasing canpass fails
		to_chat(occupants, "[icon2html(src, occupants)][span_warning("A dull, universal force is preventing you from phasing here!")]")
		spark_system.start()
		return
	if(.) //mech was thrown/door/whatever
		return
	if(bumpsmash) //Need a pilot to push the PUNCH button.
		if(COOLDOWN_FINISHED(src, mecha_bump_smash))
			obstacle.mech_melee_attack(src)
			COOLDOWN_START(src, mecha_bump_smash, smashcooldown)
			if(!obstacle || obstacle.CanPass(src, get_dir(obstacle, src) || dir)) // The else is in case the obstacle is in the same turf.
				step(src,dir)
	if(isobj(obstacle))
		var/obj/obj_obstacle = obstacle
		if(!obj_obstacle.anchored && obj_obstacle.move_resist <= move_force)
			step(obstacle, dir & ~(UP|DOWN))
	else if(ismob(obstacle))
		var/mob/mob_obstacle = obstacle
		if(mob_obstacle.move_resist <= move_force)
			step(obstacle, dir & ~(UP|DOWN))





///////////////////////////////////
////////  Internal damage  ////////
///////////////////////////////////

/obj/vehicle/sealed/mecha/proc/check_for_internal_damage(list/possible_int_damage,ignore_threshold=null)
	if(!islist(possible_int_damage) || !length(possible_int_damage))
		return
	if(prob(20))
		if(ignore_threshold || atom_integrity*100/max_integrity < internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			var/int_dam_flag = safepick(possible_int_damage)
			if(int_dam_flag)
				set_internal_damage(int_dam_flag)
	if(prob(5))
		if(ignore_threshold || atom_integrity*100/max_integrity < internal_damage_threshold)
			if(LAZYLEN(equipment))
				var/obj/item/mecha_parts/mecha_equipment/ME = safepick(equipment)
				qdel(ME)

/obj/vehicle/sealed/mecha/proc/set_internal_damage(int_dam_flag)
	internal_damage |= int_dam_flag
	log_message("Internal damage of type [int_dam_flag].", LOG_MECHA)
	SEND_SOUND(occupants, sound('sound/machines/warning-buzzer.ogg',wait=0))
	diag_hud_set_mechstat()

/obj/vehicle/sealed/mecha/proc/clear_internal_damage(int_dam_flag)
	if(internal_damage & int_dam_flag)
		switch(int_dam_flag)
			if(MECHA_INT_TEMP_CONTROL)
				to_chat(occupants, "[icon2html(src, occupants)][span_boldnotice("Life support system reactivated.")]")
			if(MECHA_INT_FIRE)
				to_chat(occupants, "[icon2html(src, occupants)][span_boldnotice("Internal fire extinguished.")]")
			if(MECHA_INT_TANK_BREACH)
				to_chat(occupants, "[icon2html(src, occupants)][span_boldnotice("Damaged internal tank has been sealed.")]")
	internal_damage &= ~int_dam_flag
	diag_hud_set_mechstat()

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
			if(!construction_state) //Mech must be in maint mode to allow carding.
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
			AI.controlled_mech = null
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
					mob_exit(ejectee, TRUE, TRUE) //IT IS MINE, NOW. SUCK IT, RD!

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
	AI.controlled_mech = src
	AI.remote_control = src
	to_chat(AI, AI.can_dominate_mechs ? span_announce("Takeover of [name] complete! You are now loaded onto the onboard computer. Do not attempt to leave the station sector!") :\
		span_notice("You have been uploaded to a mech's onboard computer."))
	to_chat(AI, span_reallybigboldnotice("Use Middle-Mouse to activate mech functions and equipment. Click normally for AI interactions."))

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


/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/obj/vehicle/sealed/mecha/mob_try_enter(mob/M)
	if(!ishuman(M)) // no silicons or drones in mechas.
		return
	log_message("[M] tries to move into [src].", LOG_MECHA)
	if(!operation_allowed(M))
		to_chat(M, span_warning("Access denied. Insufficient operation keycodes."))
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return
	if(M.buckled)
		to_chat(M, span_warning("You are currently buckled and cannot move."))
		log_message("Permission denied (Buckled).", LOG_MECHA)
		return
	if(M.has_buckled_mobs()) //mob attached to us
		to_chat(M, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		log_message("Permission denied (Attached mobs).", LOG_MECHA)
		return

	visible_message(span_notice("[M] starts to climb into [name]."))

	if(do_after(M, enter_delay, target = src))
		if(atom_integrity <= 0)
			to_chat(M, span_warning("You cannot get in the [name], it has been destroyed!"))
		else if(LAZYLEN(occupants) >= max_occupants)
			to_chat(M, span_danger("[occupants[occupants.len]] was faster! Try better next time, loser."))//get the last one that hopped in
		else if(M.buckled)
			to_chat(M, span_warning("You can't enter the exosuit while buckled."))
		else if(M.has_buckled_mobs())
			to_chat(M, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		else
			moved_inside(M)
			return ..()
	else
		to_chat(M, span_warning("You stop entering the exosuit!"))

/obj/vehicle/sealed/mecha/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_internals)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_cycle_equip)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/strafe)

/obj/vehicle/sealed/mecha/proc/moved_inside(mob/living/newoccupant)
	if(!(newoccupant?.client))
		return FALSE
	if(ishuman(newoccupant) && !Adjacent(newoccupant))
		return FALSE
	add_occupant(newoccupant)
	newoccupant.forceMove(src)
	newoccupant.update_mouse_pointer()
	add_fingerprint(newoccupant)
	log_message("[newoccupant] moved in as pilot.", LOG_MECHA)
	setDir(dir_in)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	if(!internal_damage)
		SEND_SOUND(newoccupant, sound('sound/mecha/nominal.ogg',volume=50))
	return TRUE

/obj/vehicle/sealed/mecha/proc/mmi_move_inside(obj/item/mmi/M, mob/user)
	if(!M.brain_check(user))
		return FALSE
	if(LAZYLEN(occupants) >= max_occupants)
		to_chat(user, span_warning("It's full!"))
		return FALSE
	visible_message(span_notice("[user] starts to insert an MMI into [name]."))

	if(!do_after(user, 4 SECONDS, target = src))
		to_chat(user, span_notice("You stop inserting the MMI."))
		return FALSE
	if(LAZYLEN(occupants) < max_occupants)
		return mmi_moved_inside(M, user)
	to_chat(user, span_warning("Maximum occupants exceeded!"))
	return FALSE

/obj/vehicle/sealed/mecha/proc/mmi_moved_inside(obj/item/mmi/brain_obj, mob/user)
	if(!(Adjacent(brain_obj) && Adjacent(user)))
		return FALSE
	if(!brain_obj.brain_check(user))
		return FALSE

	var/mob/living/brain/brain_mob = brain_obj.brainmob
	if(!user.transferItemToLoc(brain_obj, src))
		to_chat(user, span_warning("\the [brain_obj] is stuck to your hand, you cannot put it in \the [src]!"))
		return FALSE


	brain_obj.set_mecha(src)
	add_occupant(brain_mob)//Note this forcemoves the brain into the mech to allow relaymove
	mecha_flags |= SILICON_PILOT
	brain_mob.reset_perspective(src)
	brain_mob.remote_control = src
	brain_mob.update_mouse_pointer()
	setDir(dir_in)
	log_message("[brain_obj] moved in as pilot.", LOG_MECHA)
	if(!internal_damage)
		SEND_SOUND(brain_obj, sound('sound/mecha/nominal.ogg',volume=50))
	log_game("[key_name(user)] has put the MMI/posibrain of [key_name(brain_mob)] into [src] at [AREACOORD(src)]")
	return TRUE

/obj/vehicle/sealed/mecha/container_resist(mob/living/user)
	to_chat(user, span_notice("You begin the ejection procedure. Equipment is disabled during this process. Hold still to finish ejecting."))
	is_currently_ejecting = TRUE
	if(do_after(user, has_gravity() ? exit_delay : 0 , target = src))
		to_chat(user, span_notice("You exit the mech."))
		mob_exit(user, TRUE)
	else
		to_chat(user, span_notice("You stop exiting the mech. Weapons are enabled again."))
	is_currently_ejecting = FALSE

/obj/vehicle/sealed/mecha/mob_exit(mob/M, silent, forced)
	var/atom/movable/mob_container
	var/turf/newloc = get_turf(src)
	if(ishuman(M))
		mob_container = M
	else if(isbrain(M))
		var/mob/living/brain/brain = M
		mob_container = brain.container
	else if(isAI(M))
		var/mob/living/silicon/ai/AI = M
		if(forced)//This should only happen if there are multiple AIs in a round, and at least one is Malf.
			AI.gib()  //If one Malf decides to steal a mech from another AI (even other Malfs!), they are destroyed, as they have nowhere to go when replaced.
			AI = null
			mecha_flags &= ~SILICON_PILOT
			return
		else
			if(!AI.linked_core)
				if(!silent)
					to_chat(AI, span_userdanger("Inactive core destroyed. Unable to return."))
				AI.linked_core = null
				return
			if(!silent)
				to_chat(AI, span_notice("Returning to core..."))
			AI.controlled_mech = null
			AI.remote_control = null
			mob_container = AI
			newloc = get_turf(AI.linked_core)
			qdel(AI.linked_core)
	else
		return ..()
	var/mob/living/ejector = M
	mecha_flags  &= ~SILICON_PILOT
	mob_container.forceMove(newloc)//ejecting mob container
	log_message("[mob_container] moved out.", LOG_MECHA)
	ejector << browse(null, "window=exosuit")

	if(istype(mob_container, /obj/item/mmi))
		var/obj/item/mmi/mmi = mob_container
		if(mmi.brainmob)
			ejector.forceMove(mmi)
			ejector.reset_perspective()
			remove_occupant(ejector)
		mmi.set_mecha(null)
		mmi.update_appearance()
	setDir(dir_in)
	return ..()


/obj/vehicle/sealed/mecha/add_occupant(mob/M, control_flags)
	RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(mob_exit))
	RegisterSignal(M, COMSIG_MOB_CLICKON, PROC_REF(on_mouseclick))
	RegisterSignal(M, COMSIG_MOB_MIDDLECLICKON, PROC_REF(on_middlemouseclick)) //For AIs
	RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(display_speech_bubble))
	. = ..()
	update_appearance()

/obj/vehicle/sealed/mecha/remove_occupant(mob/M)
	UnregisterSignal(M, COMSIG_MOB_DEATH)
	UnregisterSignal(M, COMSIG_MOB_CLICKON)
	UnregisterSignal(M, COMSIG_MOB_MIDDLECLICKON)
	UnregisterSignal(M, COMSIG_MOB_SAY)
	M.clear_alert("charge")
	M.clear_alert("mech damage")
	if(M.client)
		M.update_mouse_pointer()
		M.client.view_size.resetToDefault()
		zoom_mode = FALSE
	. = ..()
	update_appearance()

/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/vehicle/sealed/mecha/proc/operation_allowed(mob/M)
	req_access = list()
	req_one_access = operation_req_access
	return allowed(M)

/obj/vehicle/sealed/mecha/proc/internals_access_allowed(mob/M)
	req_one_access = internals_req_access
	req_access = list()
	return allowed(M)

///////////////////////
///// Power stuff /////
///////////////////////

/obj/vehicle/sealed/mecha/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/vehicle/sealed/mecha/proc/get_charge()
	for(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/R in equipment)
		var/relay_charge = R.get_charge()
		if(relay_charge)
			return relay_charge
	if(cell)
		return max(0, cell.charge)

/obj/vehicle/sealed/mecha/proc/use_power(amount)
	if(get_charge() && cell.use(amount))
		return TRUE
	return FALSE

/obj/vehicle/sealed/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		return TRUE
	return FALSE

/obj/vehicle/sealed/mecha/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	return ..()

/obj/vehicle/sealed/mecha/return_air()
	if(use_internal_tank)
		return cabin_air
	return ..()

/obj/vehicle/sealed/mecha/return_analyzable_air()
	return cabin_air

/obj/vehicle/sealed/mecha/proc/return_pressure()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		return t_air.return_pressure()
	return

/obj/vehicle/sealed/mecha/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		return t_air.return_temperature()
	return

///////////////////////
////// Ammo stuff /////
///////////////////////

/obj/vehicle/sealed/mecha/proc/ammo_resupply(obj/item/mecha_ammo/A, mob/user,fail_chat_override = FALSE)
	if(!A.rounds)
		if(!fail_chat_override)
			to_chat(user, span_warning("This box of ammo is empty!"))
		return FALSE
	var/ammo_needed
	var/found_gun
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in equipment)
		ammo_needed = 0

		if(gun.ammo_type != A.ammo_type)
			continue
		found_gun = TRUE
		if(A.direct_load)
			ammo_needed = initial(gun.projectiles) - gun.projectiles
		else
			ammo_needed = gun.projectiles_cache_max - gun.projectiles_cache

		if(!ammo_needed)
			continue
		if(ammo_needed < A.rounds)
			if(A.direct_load)
				gun.projectiles = gun.projectiles + ammo_needed
			else
				gun.projectiles_cache = gun.projectiles_cache + ammo_needed
			playsound(get_turf(user),A.load_audio,50,TRUE)
			to_chat(user, span_notice("You add [ammo_needed] [A.round_term][ammo_needed > 1?"s":""] to the [gun.name]"))
			A.rounds = A.rounds - ammo_needed
			if(A.custom_materials)	//Change material content of the ammo box according to the amount of ammo deposited into the weapon
				/// list of materials contained in the ammo box after we put it through the equation so we can stick this list into set_custom_materials()
				var/list/new_material_content = list()
				for(var/datum/material/current_material in A.custom_materials)
					if(istype(current_material, /datum/material/iron))	//we can flatten an empty ammo box into a sheet of iron (2000 units) so we have to make sure the box always has this amount at minimum
						new_material_content[current_material] = (A.custom_materials[current_material] - 2000) * (A.rounds / initial(A.rounds)) + 2000
					else
						new_material_content[current_material] = A.custom_materials[current_material] * (A.rounds / initial(A.rounds))
				A.set_custom_materials(new_material_content)
			A.update_name()
			return TRUE

		if(A.direct_load)
			gun.projectiles = gun.projectiles + A.rounds
		else
			gun.projectiles_cache = gun.projectiles_cache + A.rounds
		playsound(get_turf(user),A.load_audio,50,TRUE)
		to_chat(user, span_notice("You add [A.rounds] [A.round_term][A.rounds > 1?"s":""] to the [gun.name]"))
		A.rounds = 0
		A.set_custom_materials(list(/datum/material/iron=2000))
		A.update_appearance()
		return TRUE
	if(!fail_chat_override)
		if(found_gun)
			to_chat(user, span_notice("You can't fit any more ammo of this type!"))
		else
			to_chat(user, span_notice("None of the equipment on this exosuit can use this ammo!"))
	return FALSE

/obj/vehicle/sealed/mecha/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(mecha_flags & HAS_LIGHTS)
		visible_message(span_danger("[src]'s lights burn out!"))
		mecha_flags &= ~HAS_LIGHTS
		set_light_on(FALSE)
		for(var/occupant in occupants)
			remove_action_type_from_mob(/datum/action/vehicle/sealed/mecha/mech_toggle_lights, occupant)
		playsound(src, 'sound/items/welder.ogg', 50, 1)
