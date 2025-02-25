/// Sets the direction of the mecha and all of its occcupants
/obj/vehicle/sealed/mecha/setDir(newdir)
	. = ..()
	for(var/mob/living/occupant as anything in occupants)
		occupant.setDir(newdir)

///Called when the mech moves
/obj/vehicle/sealed/mecha/proc/on_move()
	SIGNAL_HANDLER

	collect_ore()
	play_stepsound()

///Collects ore when we move, if there is an orebox and it is functional
/obj/vehicle/sealed/mecha/proc/collect_ore()
	if(isnull(ore_box) || !HAS_TRAIT(src, TRAIT_OREBOX_FUNCTIONAL))
		return
	for(var/obj/item/stack/ore/ore in range(1, src))
		//we can reach it and it's in front of us? grab it!
		if(ore.Adjacent(src) && ((get_dir(src, ore) & dir) || ore.loc == loc))
			ore.forceMove(ore_box)

///Plays the mech step sound effect. Split from movement procs so that other mechs (HONK) can override this one specific part.
/obj/vehicle/sealed/mecha/proc/play_stepsound()
	if(mecha_flags & QUIET_STEPS)
		return
	playsound(src, stepsound, 40, TRUE)

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

///Called when the driver turns with the movement lock key
/obj/vehicle/sealed/mecha/proc/on_turn(mob/living/driver, direction)
	SIGNAL_HANDLER
	return COMSIG_IGNORE_MOVEMENT_LOCK

/obj/vehicle/sealed/mecha/relaymove(mob/living/user, direction)
	. = TRUE
	if(!canmove || !(user in return_drivers()))
		return
	vehicle_move(direction)

/obj/vehicle/sealed/mecha/vehicle_move(direction, forcerotate = FALSE)
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, movedelay + step_restricted)
	step_restricted = 0
	if(completely_disabled)
		return FALSE
	if(!direction)
		return FALSE
	if(ismovable(loc)) //Mech is inside an object, tell it we moved
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, direction)
	var/obj/machinery/portable_atmospherics/canister/internal_tank = get_internal_tank()
	if(internal_tank?.connected_port)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to move while connected to the air system port!")]")
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
	var/list/missing_parts = list()
	if(isnull(cell))
		missing_parts += "power cell"
	if(isnull(capacitor))
		missing_parts += "capacitor"
	if(isnull(servo))
		missing_parts += "micro-servo"
	if(length(missing_parts))
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Missing [english_list(missing_parts)].")]")
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
	if(dir != direction && (!strafe || forcerotate || keyheld))
		if(dir != direction && !(mecha_flags & QUIET_TURNS) && !step_silent)
			playsound(src,turnsound,40,TRUE)
		setDir(direction)
		if(keyheld || !pivot_step) //If we pivot step, we don't return here so we don't just come to a stop
			return TRUE


	set_glide_size(DELAY_TO_GLIDE_SIZE(movedelay))
	//Otherwise just walk normally
	. = step(src,direction, dir)
	if(phasing)
		use_power(phasing_energy_drain)
	if(strafe)
		setDir(olddir)


/obj/vehicle/sealed/mecha/Bump(atom/obstacle)
	. = ..()
	if(phasing) //Theres only one cause for phasing canpass fails
		to_chat(occupants, "[icon2html(src, occupants)]<span class='warning'>A dull, universal force is preventing you from [phasing] here!</span>")
		spark_system.start()
		return
	if(.) //mech was thrown/door/whatever
		return
	if(bumpsmash) //Need a pilot to push the PUNCH button.
		if(COOLDOWN_FINISHED(src, mecha_bump_smash))
			var/list/mob/mobster = return_drivers()
			obstacle.mech_melee_attack(src, mobster[1])
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
