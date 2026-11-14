/*
	Cyborg ClickOn()

	Cyborgs have no range restriction on attack_robot(), because it is basically an AI click.
	However, they do have a range restriction on item use, so they cannot do without the
	adjacency code.
*/

/mob/living/silicon/robot/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(check_click_intercept(params,A))
		return

	if(IS_UNCONSCIOUS_OR_CRIT(src) || (lockcharge) || IsParalyzed() || IsStun())
		return

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			CtrlShiftClickOn(A)
			return
		if(LAZYACCESS(modifiers, MIDDLE_CLICK))
			ShiftMiddleClickOn(A, params)
			return
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A, params)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK)) // alt and alt-gr (rightalt)
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			AltClickSecondaryOn(A)
		else
			A.borg_click_alt(src)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return

	if(next_move >= world.time)
		return

	face_atom(A) // change direction to face what you clicked on

	if(aicamera.in_camera_mode) //Cyborg picture taking
		aicamera.camera_mode_off()
		aicamera.captureimage(A, usr, null, aicamera.picture_size_x - 1, aicamera.picture_size_y - 1)
		return

	var/obj/item/W = get_active_held_item()

	//wireless interaction with an atom
	if(!W && get_dist(src, A) <= interaction_range)
		if(LAZYACCESS(modifiers, RIGHT_CLICK) && !module_active)
			var/secondary_result = A.attack_robot_secondary(src, modifiers)
			if(secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
				return
			if (secondary_result != SECONDARY_ATTACK_CALL_NORMAL)
				CRASH("attack_robot_secondary did not return a SECONDARY_ATTACK_* define.")

		A.attack_robot(src, modifiers)
		return

	if(W)
		if(incapacitated)
			return

		//while buckled, you can still connect to and control things like doors, but you can't use your modules
		if(buckled)
			to_chat(src, span_warning("You can't use modules while buckled to [buckled]!"))
			return

		//Same trait as humans.
		//While we cant handcuff cyborgs, theres still scenarios where we dont want a mob to be able to use their "hands" or modules in this case
		if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
			return

		if(W == A)
			W.attack_self(src)
			return

		// cyborgs are prohibited from using storage items so we can I think safely remove (A.loc in contents)
		if(A == loc || (A in loc) || (A in contents))
			W.melee_attack_chain(src, A, modifiers)
			return

		if(!isturf(loc))
			return

		// cyborg rightclick code, allowing borgos to use weapons at range
		if(A.IsReachableBy(src, W?.reach))
			W.melee_attack_chain(src, A, modifiers)
			return
		else if(isturf(A) || isturf(A.loc))
			if(LAZYACCESS(modifiers, RIGHT_CLICK))
				var/after_attack_secondary_result = W.afterattack_secondary(A, src, FALSE, modifiers)

				if(after_attack_secondary_result == SECONDARY_ATTACK_CALL_NORMAL)
					W.afterattack(A, src, FALSE, modifiers)
			else
				W.afterattack(A, src, FALSE, modifiers)

//Middle click cycles through selected modules.
/mob/living/silicon/robot/MiddleClickOn(atom/A)
	. = ..()
	cycle_modules()
	return

//Give cyborgs hotkey clicks without breaking existing uses of hotkey clicks
// for non-doors/apcs
/mob/living/silicon/robot/CtrlShiftClickOn(atom/A)
	A.BorgCtrlShiftClick(src)

/mob/living/silicon/robot/ShiftClickOn(atom/A)
	A.BorgShiftClick(src)

/mob/living/silicon/robot/CtrlClickOn(atom/A)
	A.BorgCtrlClick(src)

/atom/proc/BorgCtrlShiftClick(mob/living/silicon/robot/user) //forward to human click if not overridden
	user.base_click_ctrl_shift(src)

/obj/machinery/door/airlock/BorgCtrlShiftClick(mob/living/silicon/robot/user) // Sets/Unsets Emergency Access Override Forwards to AI code.
	if(get_dist(src, user) <= user.interaction_range)
		AICtrlShiftClick(user)
	else
		..()

/atom/proc/BorgShiftClick(mob/living/silicon/robot/user) //forward to human click if not overridden
	ShiftClick(user)

/obj/machinery/door/airlock/BorgShiftClick(mob/living/silicon/robot/user)  // Opens and closes doors! Forwards to AI code.
	if(get_dist(src, user) <= user.interaction_range)
		AIShiftClick(user)
	else
		..()


/atom/proc/BorgCtrlClick(mob/living/silicon/robot/user) //forward to human click if not overridden
	user.base_click_ctrl(src)

/obj/machinery/door/airlock/BorgCtrlClick(mob/living/silicon/robot/user) // Bolts doors. Forwards to AI code.
	if(get_dist(src, user) <= user.interaction_range)
		AICtrlClick(user)
	else
		..()

/obj/machinery/power/apc/BorgCtrlClick(mob/living/silicon/robot/user) // turns off/on APCs. Forwards to AI code.
	if(get_dist(src, user) <= user.interaction_range)
		AICtrlClick(user)
	else
		..()

/obj/machinery/power/apc/BorgCtrlShiftClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range)
		AICtrlShiftClick(user)
	else
		..()

/obj/machinery/power/apc/BorgShiftClick(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range)
		AIShiftClick(user)
	else
		..()

/obj/machinery/power/apc/borg_click_alt(mob/living/silicon/robot/user)
	if(get_dist(src, user) <= user.interaction_range)
		ai_click_alt(user)
	else
		..()


/obj/machinery/power/apc/attack_robot_secondary(mob/living/silicon/user, list/modifiers)
	if(get_dist(src, user) <= user.interaction_range)
		return attack_ai_secondary(user, modifiers)
	else
		..()

/obj/machinery/turretid/BorgCtrlClick(mob/living/silicon/robot/user) //turret control on/off. Forwards to AI code.
	if(get_dist(src, user) <= user.interaction_range)
		AICtrlClick(user)
	else
		..()

/atom/proc/borg_click_alt(mob/living/silicon/robot/user)
	user.base_click_alt(src)
	return

/obj/machinery/door/airlock/borg_click_alt(mob/living/silicon/robot/user) // Electrifies doors. Forwards to AI code.
	if(get_dist(src, user) <= user.interaction_range)
		ai_click_alt(user)
	else
		..()

/obj/machinery/turretid/borg_click_alt(mob/living/silicon/robot/user) //turret lethal on/off. Forwards to AI code.
	if(get_dist(src, user) <= user.interaction_range)
		ai_click_alt(user)
	else
		..()

/*
	As with AI, these are not used in click code,
	because the code for robots is specific, not generic.

	If you would like to add advanced features to robot
	clicks, you can do so here, but you will have to
	change attack_robot() above to the proper function
*/
/mob/living/silicon/robot/UnarmedAttack(atom/A, proximity_flag, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		return A.attack_robot_secondary(src, modifiers)

	return A.attack_robot(src, modifiers)

/**
 * What happens when the cyborg holds left-click on an item.
 *
 * Arguments:
 * * user The mob holding the right click
 * * modifiers The list of the custom click modifiers
 */
/atom/proc/attack_robot(mob/user, modifiers)
	if (SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ROBOT, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	if(attack_silicon(user))
		return TRUE
	return FALSE

/**
 * What happens when the cyborg without active module holds right-click on an item. Returns a SECONDARY_ATTACK_* value.
 *
 * Arguments:
 * * user The mob holding the right click
 * * modifiers The list of the custom click modifiers
 */
/atom/proc/attack_robot_secondary(mob/user, list/modifiers)
	if (SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ROBOT_SECONDARY, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return attack_ai_secondary(user, modifiers)
