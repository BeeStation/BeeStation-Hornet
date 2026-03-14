/**
  * force move the control_object of your client mob
  *
  * Used in admin possession and called from the client Move proc
  * ensures the possessed object moves and not the admin mob
  *
  * Has no sanity other than checking density
  */
/client/proc/Move_object(direct)
	if(mob?.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)
				return
			mob.control_object.setDir(direct)
		else
			mob.control_object.forceMove(get_step(mob.control_object,direct))

/**
  * Move a client in a direction
  *
  * Huge proc, has a lot of functionality
  *
  * Mostly it will despatch to the mob that you are the owner of to actually move
  * in the physical realm
  *
  * Things that stop you moving as a mob:
  * * world time being less than your next move_delay
  * * not being in a mob, or that mob not having a loc
  * * missing the n and direction parameters
  * * being in remote control of an object (calls Moveobject instead)
  * * being dead (it ghosts you instead)
  *
  * Things that stop you moving as a mob living (why even have OO if you're just shoving it all
  * in the parent proc with istype checks right?):
  * * having incorporeal_move set (calls Process_Incorpmove() instead)
  * * being grabbed
  * * being buckled  (relaymove() is called to the buckled atom instead)
  * * having your loc be some other mob (relaymove() is called on that mob instead)
  * * Not having MOBILITY_MOVE
  * * Failing Process_Spacemove() call
  *
  * At this point, if the mob is is confused, then a random direction and target turf will be calculated for you to travel to instead
  *
  * Now the parent call is made (to the byond builtin move), which moves you
  *
  * Some final move delay calculations (doubling if you moved diagonally successfully)
  *
  * if mob throwing is set I believe it's unset at this point via a call to finalize
  *
  * Finally if you're pulling an object and it's dense, you are turned 180 after the move
  * (if you ask me, this should be at the top of the move so you don't dance around)
  *
  */
/client/Move(new_loc, direct)
	// If the movement delay is slightly less than the period from now until the next tick,
	// let us move and take the additional delay and add it onto the next move. This means that
	// it will slowly stack until we can lose a tick, where the ticks we lose are proportional
	// to the slowdowns difference to the next tick step.
	var/floored_move_delay = FLOOR(move_delay, 1 / world.fps)
	if(world.time < floored_move_delay) //do not move anything ahead of this check please
		return FALSE
	next_move_dir_add = 0
	next_move_dir_sub = 0

	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag //this is here because Move() can now be called mutiple times per tick
	if(!mob || !mob.loc)
		return FALSE
	if(!new_loc || !direct)
		return FALSE
	if(mob.notransform)
		return FALSE	//This is sota the goto stop mobs from moving var
	if(mob.control_object)
		return Move_object(direct)
	if(!isliving(mob))
		return mob.Move(new_loc, direct)
	if(mob.stat == DEAD)
		mob.ghostize()
		return FALSE
	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, new_loc, direct) & COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE)
		return FALSE

	var/mob/living/L = mob  //Already checked for isliving earlier
	if(L.incorporeal_move)	//Move though walls
		Process_Incorpmove(direct)
		return FALSE

	if(mob.remote_control)					//we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		return AIMove(new_loc,direct,mob)

	if(Process_Grab()) //are we restrained by someone's grip?
		return

	if(mob.buckled)							//if we're buckled to something, tell it we moved.
		return mob.buckled.relaymove(mob, direct)

	if(!(L.mobility_flags & MOBILITY_MOVE))
		return FALSE

	if(isobj(mob.loc) || ismob(mob.loc))	//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return FALSE

	if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_MOVE, args) & COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE)
		return FALSE

	//We are now going to move
	var/add_delay = mob.cached_multiplicative_slowdown
	mob.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay * ( (NSCOMPONENT(direct) && EWCOMPONENT(direct)) ? sqrt(2) : 1 ) )) // set it now in case of pulled objects
	//If the move was recent, count using old_move_delay
	//We want fractional behavior and all
	if(old_move_delay + world.tick_lag > world.time)
		//Yes this makes smooth movement stutter if add_delay is too fractional
		//Yes this is better then the alternative
		move_delay = old_move_delay
	else
		move_delay = world.time

	//Basically an optional override for our glide size
	//Sometimes you want to look like you're moving with a delay you don't actually have yet
	visual_delay = 0

	. = ..()

	if((direct & (direct - 1)) && mob.loc == new_loc) //moved diagonally successfully
		add_delay *= sqrt(2)
	// Record any time that we gained due to sub-tick slowdown
	var/move_delta = move_delay - floored_move_delay
	if(visual_delay)
		mob.set_glide_size(visual_delay)
	else
		mob.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay))
	add_delay += move_delta
	// Apply the movement delay
	move_delay += add_delay
	if(.) // If mob is null here, we deserve the runtime
		if(mob.throwing)
			mob.throwing.finalize(FALSE)

		// At this point we've moved the client's attached mob. This is one of the only ways to guess that a move was done
		// as a result of player input and not because they were pulled or any other magic.
		SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_MOVED)

	var/atom/movable/P = mob.pulling
	if(P && !ismob(P) && P.density)
		mob.setDir(turn(mob.dir, 180))

/**
  * Checks to see if you're being grabbed and if so attempts to break it
  *
  * Called by client/Move()
  */
/client/proc/Process_Grab()
	if(!mob.pulledby)
		return FALSE

	if(mob.pulledby == mob.pulling && mob.pulledby.grab_state == GRAB_PASSIVE) //Don't autoresist passive grabs if we're grabbing them too.
		return FALSE
	if(HAS_TRAIT(mob, TRAIT_INCAPACITATED))
		COOLDOWN_START(src, move_delay, 1 SECONDS)
		return TRUE
	else if(HAS_TRAIT(mob, TRAIT_RESTRAINED))
		COOLDOWN_START(src, move_delay, 1 SECONDS)
		to_chat(src, span_warning("You're restrained! You can't move!"))
		return TRUE
	else if(mob.pulledby.grab_state == GRAB_AGGRESSIVE)
		COOLDOWN_START(src, move_delay, 1 SECONDS)
		return TRUE
	else
		return mob.resist_grab(1)

/**
  * Allows mobs to ignore density and phase through objects
  *
  * Called by client/Move()
  *
  * The behaviour depends on the incorporeal_move value of the mob
  *
  * * INCORPOREAL_MOVE_BASIC - forceMoved to the next tile with no stop
  * * INCORPOREAL_MOVE_SHADOW  - the same but leaves a cool effect path
  * * INCORPOREAL_MOVE_JAUNT - the same but blocked by holy tiles
  * * INCORPOREAL_MOVE_EMINCENCE - was invented so that only Eminence can pass through clockwalls
  *
  * You'll note this is another mob living level proc living at the client level
  */

/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	L.setDir(direct)
	switch(L.incorporeal_move)
		if(INCORPOREAL_MOVE_BASIC)
			var/T = get_step_multiz(mobloc, direct)
			if(T && !istype(T, /turf/closed/indestructible/cordon))
				L.forceMove(T)
			else
				to_chat(L, span_warning("There's nowhere to go in that direction!"))
		if(INCORPOREAL_MOVE_SHADOW)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				var/target = locate(locx,locy,mobloc.z)
				if(target && !istype(target, /turf/closed/indestructible/cordon))
					var/lineofturf = get_line(mobloc, target)
					if(locate(/turf/closed/indestructible/cordon) in lineofturf)
						return //No phasing over cordons
					L.forceMove(target)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in lineofturf)
						new /obj/effect/temp_visual/dir_setting/ninja/shadow(T, L.dir)
						limit--
						if(limit<=0)
							break
			else
				new /obj/effect/temp_visual/dir_setting/ninja/shadow(mobloc, L.dir)
				var/T = get_step(L,direct)
				if(T && !istype(T, /turf/closed/indestructible/cordon))
					L.forceMove(T)
		if(INCORPOREAL_MOVE_JAUNT) //Incorporeal move, but blocked by holy-watered tiles and salt piles.
			var/turf/open/floor/stepTurf = get_step_multiz(mobloc, direct)
			if(stepTurf)
				var/obj/effect/decal/cleanable/food/salt/salt = locate() in stepTurf
				if(salt)
					to_chat(L, span_warning("[salt] bars your passage!"))
					if(isrevenant(L))
						var/mob/living/simple_animal/revenant/R = L
						R.reveal(20)
						R.stun(20)
					return
				if(stepTurf.flags_1 & NOJAUNT_1)
					to_chat(L, span_warning("Some strange aura is blocking the way."))
					return
				if(stepTurf.is_holy())
					to_chat(L, span_warning("Holy energies block your path!"))
					return
				L.forceMove(stepTurf)
			else
				to_chat(L, span_warning("There's nowhere to go in that direction!"))
		if(INCORPOREAL_MOVE_EMINENCE) //Incorporeal move for emincence. Blocks move like Jaunt but lets it pass through clockwalls
			var/turf/open/floor/stepTurf = get_step_multiz(mobloc, direct)
			var/turf/loccheck = get_turf(stepTurf)
			if(stepTurf)
				var/obj/effect/decal/cleanable/food/salt/salt = locate() in stepTurf
				if(salt)
					to_chat(L, span_warning("[salt] bars your passage!"))
					return
				if((stepTurf.flags_1 & NOJAUNT_1) && !is_on_reebe(loccheck))
					to_chat(L, span_warning("Some strange aura is blocking the way."))
					return
				if(stepTurf.is_holy())
					to_chat(L, span_warning("Holy energies block your path!"))
					return
				L.forceMove(stepTurf)
			else
				to_chat(L, span_warning("There's nowhere to go in that direction!"))
	return TRUE

/**
  * Handles mob/living movement in space (or no gravity)
  *
  * Called by /client/Move()
  *
  * return TRUE for movement or FALSE for none
  *
  * You can move in space if you have a spacewalk ability
  */
/mob/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(. || HAS_TRAIT(src, TRAIT_SPACEWALK))
		return TRUE

	if(buckled)
		return TRUE

	if(movement_type & FLYING)
		return TRUE

	var/atom/movable/backup = get_spacemove_backup(movement_dir)
	if(!backup)
		return FALSE

	if(!istype(backup) || !movement_dir || backup.anchored)
		return TRUE

	if(backup.newtonian_move(dir2angle(REVERSE_DIR(movement_dir)), instant = TRUE)) //You're pushing off something movable, so it moves
		to_chat(src, span_info("You push off of [backup] to propel yourself."))
	return TRUE

/**
 * Finds a target near a mob that is viable for pushing off when moving.
 * Takes the intended movement direction as input.
*/
/mob/get_spacemove_backup(moving_direction)
	for(var/atom/pushover as anything in range(1, get_turf(src)))
		if(pushover == src)
			continue
		if(isarea(pushover))
			continue
		if(isturf(pushover))
			var/turf/turf = pushover
			if(!turf.density)
				continue
			return pushover
		var/atom/movable/rebound = pushover
		if(rebound == buckled)
			continue
		if(ismob(rebound))
			var/mob/M = rebound
			if(M.buckled)
				continue
		var/pass_allowed = rebound.CanPass(src, get_dir(rebound, src))
		if(!rebound.density && pass_allowed)
			continue
		if(moving_direction == get_dir(src, pushover) && !pass_allowed) // Can't push "off" of something that you're walking into
			continue
		if(rebound.anchored)
			return rebound
		if(pulling == rebound)
			continue
		return rebound

/mob/has_gravity(turf/gravity_turf)
	return mob_negates_gravity() || ..()

/**
 * Does this mob ignore gravity
 */
/mob/proc/mob_negates_gravity()
	var/turf/turf = get_turf(src)
	return !isgroundlessturf(turf) && HAS_TRAIT(src, TRAIT_NEGATES_GRAVITY)

/mob/newtonian_move(direction, instant = FALSE)
	. = ..()
	if(!.) //Only do this if we're actually going somewhere
		return
	if(!client)
		return
	client.visual_delay = MOVEMENT_ADJUSTED_GLIDE_SIZE(inertia_move_delay, SSspacedrift.visual_delay) //Make sure moving into a space move looks like a space move

/// Called when this mob slips over, override as needed
/mob/proc/slip(knockdown, paralyze, forcedrop, w_amount, obj/O, lube)
	return

//bodypart selection verbs - Cyberboss
//8:repeated presses toggles through head - eyes - mouth
//4: r-arm 5: chest 6: l-arm
//1: r-leg 2: groin 3: l-leg

///Validate the client's mob has a valid zone selected
/client/proc/check_has_body_select()
	return mob && mob.hud_used && mob.hud_used.zone_select && istype(mob.hud_used.zone_select, /atom/movable/screen/zone_sel)

/**
  * Hidden verb to set the target zone of a mob to the head
  *
  * (bound to 8) - repeated presses toggles through head - eyes - mouth
  */
AUTH_CLIENT_VERB(body_toggle_head)
	set name = "body-toggle-head"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select

	var/next_in_line
	switch(selector.selecting)
		if(BODY_ZONE_HEAD)
			next_in_line = BODY_ZONE_PRECISE_EYES
		if(BODY_ZONE_PRECISE_EYES)
			next_in_line = BODY_ZONE_PRECISE_MOUTH
		else
			next_in_line = BODY_ZONE_HEAD

	selector.set_selected_zone(next_in_line, mob)

///Hidden verb to target the right arm, bound to 4
AUTH_CLIENT_VERB(body_r_arm)
	set name = "body-r-arm"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_R_ARM, mob)

///Hidden verb to target the chest, bound to 5
AUTH_CLIENT_VERB(body_chest)
	set name = "body-chest"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_CHEST, mob)

///Hidden verb to target the left arm, bound to 6
AUTH_CLIENT_VERB(body_l_arm)
	set name = "body-l-arm"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_L_ARM, mob)

///Hidden verb to target the right leg, bound to 1
AUTH_CLIENT_VERB(body_r_leg)
	set name = "body-r-leg"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_R_LEG, mob)

///Hidden verb to target the groin, bound to 2
AUTH_CLIENT_VERB(body_groin)
	set name = "body-groin"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_PRECISE_GROIN, mob)

///Hidden verb to target the left leg, bound to 3
AUTH_CLIENT_VERB(body_l_leg)
	set name = "body-l-leg"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	selector.set_selected_zone(BODY_ZONE_L_LEG, mob)

AUTH_CLIENT_VERB(body_up)
	set name = "body-up"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	switch (selector.selecting)
		if (BODY_GROUP_LEGS, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			selector.set_selected_zone(BODY_GROUP_ARMS, mob)
		if (BODY_GROUP_ARMS, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			selector.set_selected_zone(BODY_GROUP_CHEST_HEAD, mob)

AUTH_CLIENT_VERB(body_down)
	set name = "body-down"
	set hidden = 1

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_select
	switch (selector.selecting)
		if (BODY_GROUP_CHEST_HEAD, BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_GROIN)
			selector.set_selected_zone(BODY_GROUP_ARMS, mob)
		if (BODY_GROUP_ARMS, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			selector.set_selected_zone(BODY_GROUP_LEGS, mob)

///Verb to toggle the walk or run status
AUTH_CLIENT_VERB(toggle_walk_run)
	set name = "toggle-walk-run"
	set hidden = TRUE
	set instant = TRUE
	if(mob)
		mob.toggle_move_intent(usr)

/**
  * Toggle the move intent of the mob
  *
  * triggers an update the move intent hud as well
  */
/mob/proc/toggle_move_intent(mob/user)
	if(m_intent == MOVE_INTENT_RUN)
		m_intent = MOVE_INTENT_WALK
	else
		m_intent = MOVE_INTENT_RUN
	if(hud_used && hud_used.static_inventory)
		for(var/atom/movable/screen/mov_intent/selector in hud_used.static_inventory)
			selector.update_icon()

///Moves a mob upwards in z level
/mob/verb/up()
	set name = "Move Upwards"
	set category = "IC"
	if(isnewplayer(src))
		return
	if(zMove(UP, TRUE))
		to_chat(src, span_notice("You move upwards."))

///Moves a mob down a z level
/mob/verb/down()
	set name = "Move Down"
	set category = "IC"
	if(isnewplayer(src))
		return
	if(zMove(DOWN, TRUE))
		to_chat(src, span_notice("You move down."))

///Move a mob between z levels, if it's valid to move z's on this turf
/mob/proc/zMove(dir, feedback = FALSE, feedback_to = src)
	if(dir != UP && dir != DOWN)
		return FALSE
	var/turf/source = get_turf(src)
	var/turf/target = get_step_multiz(src, dir)
	if(!target)
		if(feedback)
			to_chat(feedback_to, span_warning("There's nowhere to go in that direction!"))
		return FALSE
	var/ventcrawling = movement_type & VENTCRAWLING
	if(!canZMove(dir, source, target) && !ventcrawling)
		if(feedback)
			to_chat(feedback_to, span_warning("You couldn't move there!"))
		return FALSE
	if(!ventcrawling) //let this be handled in atmosmachinery.dm
		forceMove(target)
	else
		var/obj/machinery/atmospherics/pipe = loc
		pipe.relaymove(src, dir)
	return TRUE


