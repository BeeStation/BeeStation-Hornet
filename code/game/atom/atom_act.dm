/*
 * +++++++++++++++++++++++++++++++++++++++++ ABOUT THIS FILE +++++++++++++++++++++++++++++++++++++++++++++
 * Not everything here necessarily has the name pattern of [x]_act()
 * This is a file for various atom procs that simply get called when something is happening to that atom.
 * If you're adding something here, you likely want a signal and SHOULD_CALL_PARENT(TRUE)
 * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 */

/**
 * Respond to fire being used on our atom
 *
 * Default behaviour is to send [COMSIG_ATOM_FIRE_ACT] and return
 */
/atom/proc/fire_act(exposed_temperature, exposed_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	return FALSE

/**
 * Sends [COMSIG_ATOM_EXTINGUISH] signal, which properly removes burning component if it is present.
 *
 * Default behaviour is to send [COMSIG_ATOM_ACID_ACT] and return
 */
/atom/proc/extinguish()
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_EXTINGUISH)

/**
 * React to being hit by an explosion
 *
 * Should be called through the [EX_ACT] wrapper macro.
 * The wrapper takes care of the [COMSIG_ATOM_EX_ACT] signal.
 * as well as calling [/atom/proc/contents_explosion].
 */
/atom/proc/ex_act(severity, target)
	set waitfor = FALSE

/// Handle what happens when your contents are exploded by a bomb
/atom/proc/contents_explosion(severity, target)
	return //For handling the effects of explosions on contents that would not normally be effected

/**
 * React to a hit by a blob object
 *
 * default behaviour is to send the [COMSIG_ATOM_BLOB_ACT] signal
 */
/atom/proc/blob_act(obj/structure/blob/B)
	if(SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B) & COMPONENT_CANCEL_BLOB_ACT)
		return FALSE
	return TRUE

/**
  * React to an EMP of the given severity
  *
  * Default behaviour is to send the COMSIG_ATOM_EMP_ACT signal
  *
  * If the signal does not return protection, and there are attached wires then we call
  * emp_pulse() on the wires
  *
  * We then return the protection value
  */
/atom/proc/emp_act(severity)
	var/protection = SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)
	if(!(protection & EMP_PROTECT_WIRES) && istype(wires))
		wires.emp_pulse()

	return protection // Pass the protection value collected here upwards

/**
 * React to a hit by a projectile object
 *
 * Default behaviour is to send the [COMSIG_ATOM_BULLET_ACT] and then call [on_hit][/obj/projectile/proc/on_hit] on the projectile
 *
 * @params
 * * hitting_projectile - projectile
 * * def_zone - zone hit
 * * piercing_hit - is this hit piercing or normal?
 */
/atom/proc/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	var/bullet_signal = SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, hitting_projectile, def_zone)
	if(bullet_signal & COMSIG_ATOM_BULLET_ACT_FORCE_PIERCE)
		return BULLET_ACT_FORCE_PIERCE
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_BLOCK)
		return BULLET_ACT_BLOCK
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_HIT)
		return BULLET_ACT_HIT
	. = hitting_projectile.on_hit(src, 0, def_zone, piercing_hit)

/**
 * React to being hit by a thrown object
 *
 * Default behaviour is to call hitby_react() on ourselves after 2 seconds if we are dense
 * and under normal gravity.
 *
 * Im not sure why this the case, maybe to prevent lots of hitby's if the thrown object is
 * deleted shortly after hitting something (during explosions or other massive events that
 * throw lots of items around - singularity being a notable example)
 */
/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(src, COMSIG_ATOM_HITBY, AM, skipcatch, hitpush, blocked, throwingdatum)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, PROC_REF(hitby_react), AM), 2)
	return FALSE

/**
 * We have have actually hit the passed in atom
 *
 * Default behaviour is to move back from the item that hit us
 */
/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))

/// Handle the atom being slipped over
/atom/proc/handle_slip(mob/living/carbon/slipped_carbon, knockdown_amount, obj/slipping_object, lube, paralyze, force_drop)
	return

/// Used for making a sound when a mob involuntarily falls into the ground.
/atom/proc/handle_fall(mob/faller)
	return

/// Respond to the singularity eating this atom
/atom/proc/singularity_act()
	return

/**
 * Respond to the singularity pulling on us
 *
 * Default behaviour is to send COMSIG_ATOM_SING_PULL and return
 */
/atom/proc/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, singularity, current_size)


/**
 * Respond to acid being used on our atom
 *
 * Default behaviour is to send COMSIG_ATOM_ACID_ACT and return
 */
/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)

/**
 * Respond to an emag being used on our atom
 *
 * Default behaviour is to send COMSIG_ATOM_SHOULD_EMAG,
 * if that is FALSE (due to the default being false, should_emag still occurs on /obj) then COMSIG_ATOM_ON_EMAG and return
 *
 * This typically should not be overriden, in favor of the /obj counterparts:
 * - Override on_emag(mob/user)
 * - Maintain parent calls in on_emag for good practice
 * - If the item is "undo-emaggable" (can be flipped on/off), set emag_toggleable = TRUE
 * For COMSIG_ATOM_SHOULD_EMAG, /obj uses should_emag.
 * - Parent calls do not need to be maintained.
 */
/atom/proc/use_emag(mob/user, obj/item/card/emag/hacker)
	if(!SEND_SIGNAL(src, COMSIG_ATOM_SHOULD_EMAG, user))
		SEND_SIGNAL(src, COMSIG_ATOM_ON_EMAG, user, hacker)

/**
 * Respond to narsie eating our atom
 *
 * Default behaviour is to send COMSIG_ATOM_NARSIE_ACT and return
 */
/atom/proc/narsie_act()
	SEND_SIGNAL(src, COMSIG_ATOM_NARSIE_ACT)

/**
 * Respond to an electric bolt action on our item
 *
 * Default behaviour is to return, we define here to allow for cleaner code later on
 */
/atom/proc/zap_act(power, zap_flags)
	return

/**
 * Respond to ratvar eating our atom
 *
 * Default behaviour is to send COMSIG_ATOM_RATVAR_ACT and return
 */
/atom/proc/ratvar_act()
	SEND_SIGNAL(src, COMSIG_ATOM_RATVAR_ACT)

/**
 * Respond to the eminence clicking on our atom
 *
 * Default behaviour is to send COMSIG_ATOM_EMINENCE_ACT and return
 */
/atom/proc/eminence_act(mob/living/simple_animal/eminence/eminence)
	SEND_SIGNAL(src, COMSIG_ATOM_EMINENCE_ACT, eminence)

/**
 * Called when lighteater attacks our atom
 */
/atom/proc/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src,COMSIG_ATOM_LIGHTEATER_ACT)
	for(var/datum/light_source/light_source in light_sources)
		if(light_source.source_atom != src)
			light_source.source_atom.lighteater_act(light_eater, src)

/**
 * Called when the atom log's in or out
 *
 * Default behaviour is to call on_log on the location this atom is in
 */
/atom/proc/on_log(login)
	if(loc)
		loc.on_log(login)

/**
  * Causes effects when the atom gets hit by a rust effect from heretics
  *
  * Override this if you want custom behaviour in whatever gets hit by the rust
  */
/atom/proc/rust_heretic_act()
	return

/**
 * Respond to an RCD acting on our item
 *
 * Default behaviour is to send COMSIG_ATOM_RCD_ACT and return FALSE
 */
/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	SEND_SIGNAL(src, COMSIG_ATOM_RCD_ACT, user, the_rcd, passed_mode)
	return FALSE

/// Return the values you get when an RCD eats you?
/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/**
 * Respond to our atom being teleported
 *
 * Default behaviour is to send COMSIG_ATOM_TELEPORT_ACT
 */
/atom/proc/teleport_act()
	SEND_SIGNAL(src,COMSIG_ATOM_TELEPORT_ACT)

/**
 * Intercept our atom being teleported if we need to
 *
 * return COMPONENT_BLOCK_TELEPORT to explicity block teleportation
 */
/atom/proc/intercept_teleport(channel, turf/origin, turf/destination)
	. = SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_TELEPORT, channel, origin, destination)

	if(. == COMPONENT_BLOCK_TELEPORT)
		return

	// Recursively check contents by default. This can be overriden if we want different behavior.
	for(var/atom/thing in contents)
		// For the purposes of intercepting teleports, mobs on the turf don't count.
		// We're already doing logic for intercepting teleports on the teleatom-level
		if(isturf(src) && ismob(thing))
			continue
		var/result = thing.intercept_teleport(channel, origin, destination)
		if(result == COMPONENT_BLOCK_TELEPORT)
			return result

/**
 * Respond to our atom being checked by a virus extrapolator.
 *
 * Default behaviour is to send COMSIG_ATOM_EXTRAPOLATOR_ACT and return an empty list (which may be populated by the signal)
 *
 * Returns a list of viruses in the atom.
 * Include EXTRAPOLATOR_SPECIAL_HANDLED in the list if the extrapolation act has been handled by this proc or a signal, and should not be handled by the extrapolator itself.
 */
/atom/proc/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run = FALSE)
	. = list(EXTRAPOLATOR_RESULT_DISEASES = list())
	SEND_SIGNAL(src, COMSIG_ATOM_EXTRAPOLATOR_ACT, user, extrapolator, dry_run, .)

/// This atom has been hit by a hulkified mob in hulk mode (user)
/atom/proc/attack_hulk(mob/living/carbon/human/user)
	SEND_SIGNAL(src, COMSIG_ATOM_HULK_ATTACK, user)

/**
 * attempts to fix something when duct tape is used on it.
 * override if there is something that shouldn't be fixable with tape
 */
/atom/proc/try_ducttape(mob/living/user, obj/item/stack/sticky_tape/duct/tape)
	. = FALSE

	if (!isobj(src) || iseffect(src))
		return

	var/object_is_damaged = get_integrity() < max_integrity
	if (!object_is_damaged)
		balloon_alert(user, "[src] is not damaged!")
		return

	user.visible_message(span_notice("[user] begins repairing [src] with [tape]."), span_notice("You begin repairing [src] with [tape]."))
	playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)

	if (!do_after(user, 3 SECONDS, target = src))
		return

	to_chat(user, span_notice("You finish repairing [src] with [tape]."))
	repair_damage(tape.object_repair_value)
	return TRUE
