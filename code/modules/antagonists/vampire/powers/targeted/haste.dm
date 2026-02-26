/* Level 1: Speed to location
 * Level 2: Dodge Bullets
 * Level 3: Stun People Passed
 */

/datum/action/vampire/targeted/haste
	name = "Immortal Haste"
	desc = "Dash somewhere with supernatural speed. Those nearby may be knocked away or stunned."
	button_icon_state = "power_speed"
	power_explanation = "Click anywhere to immediately dash towards that location.\n\
		The Power will not work if you are lying down, zero-gravity, or are being aggressively grabbed.\n\
		Anyone in your way during your Haste will be knocked down.\n\
		Higher levels will increase the knockdown dealt to enemies."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = VAMPIRE_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 6
	sol_multiplier = 10
	cooldown_time = 12 SECONDS
	target_range = 15
	power_activates_immediately = TRUE
	///List of all people hit by our power, so we don't hit them again.
	var/list/hit = list()

/datum/action/vampire/targeted/haste/can_use()
	. = ..()
	if(!.)
		return FALSE

	// Being Grabbed
	if(owner.pulledby && owner.pulledby.grab_state >= GRAB_AGGRESSIVE)
		owner.balloon_alert(owner, "you're being grabbed!")
		return FALSE
	if(!owner.has_gravity(owner.loc)) //We dont want people to be able to use this to fly around in space
		owner.balloon_alert(owner, "you cannot dash while floating!")
		return FALSE
	var/mob/living/carbon/user = owner
	if(user?.body_position == LYING_DOWN)
		owner.balloon_alert(owner, "you must be standing to tackle!")
		return FALSE
	return TRUE

/// Anything will do, if it's not me or my square
/datum/action/vampire/targeted/haste/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Can't dash to the same tile we're already on
	if(target_atom.loc == owner.loc)
		return FALSE

/// This is a non-async proc to make sure the power is "locked" until this finishes.
/datum/action/vampire/targeted/haste/FireTargetedPower(atom/target_atom)
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	var/mob/living/user = owner
	var/turf/targeted_turf = isturf(target_atom) ? target_atom : get_turf(target_atom)
	// Pulled? Not anymore.
	user.pulledby?.stop_pulling()
	// Go to target turf
	// DO NOT USE WALK TO.
	owner.balloon_alert(owner, "you dash into the air!")
	playsound(get_turf(owner), 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	var/safety = get_dist(user, targeted_turf) * 3 + 1
	var/consequetive_failures = 0
	while(--safety && (get_turf(user) != targeted_turf))
		var/success = step_towards(user, targeted_turf) //This does not try to go around obstacles.
		if(!success)
			success = step_to(user, targeted_turf) //this does
		if(!success)
			consequetive_failures++
			if(consequetive_failures >= 3) //if 3 steps don't work
				break //just stop
		else
			consequetive_failures = 0 //reset so we can keep moving
		if(user.resting || INCAPACITATED_IGNORING(user, INCAPABLE_RESTRAINTS|INCAPABLE_GRAB)) //actually down? stop.
			break
		if(success) //don't sleep if we failed to move.
			sleep(world.tick_lag)

/datum/action/vampire/targeted/haste/power_activated_sucessfully()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	hit.Cut()

/datum/action/vampire/targeted/haste/proc/on_move()
	for(var/mob/living/hit_living in dview(1, get_turf(owner)) - owner)
		if(hit.Find(hit_living))
			continue
		hit += hit_living
		playsound(hit_living, "sound/weapons/punch[rand(1,4)].ogg", 15, 1, -1)
		hit_living.Knockdown(10 + level_current * 4)
		hit_living.spin(10, 1)
