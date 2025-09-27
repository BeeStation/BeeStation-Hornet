/datum/action/innate/dash
	name = "Dash"
	desc = "Teleport to the targeted location."
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	/// How many dash charges do we have?
	var/current_charges = 1
	/// If set to 0, doesn't require charges. If set to a value greater than 0
	/// then this is the maximum number of charges that the ability can hold, with
	/// charges being consumed upon the use of the ability. Once all charges are
	/// consumed, the user must wait until they recharge before the ability can
	/// be used again.
	var/max_charges = 1
	/// How much damage is dealt to objects in the path
	var/obj_damage = 200
	/// How long does it take to get a dash charge back?
	var/charge_rate = 25 SECONDS
	/// What sound do we play on dash?
	var/dash_sound = 'sound/magic/blink.ogg'
	/// What sound do we play on recharge?
	var/recharge_sound = 'sound/magic/charge.ogg'
	/// What effect does our beam use?
	var/beam_effect = "blur"
	/// How long does our beam last?
	var/beam_length = 2 SECONDS
	/// What effect should we play when we phase in (at the teleport target turf)
	var/phasein = /obj/effect/temp_visual/dir_setting/ninja/phase
	/// What effect should we play when we phase out (at the source turf)
	var/phaseout = /obj/effect/temp_visual/dir_setting/ninja/phase/out

/datum/action/innate/dash/is_available(feedback = FALSE)
	return ..() && (max_charges <= 0 || current_charges > 0)

/datum/action/innate/dash/on_activate()
	var/obj/item/dashing_item = master
	if(!istype(dashing_item))
		return

	dashing_item.attack_self(owner) //Used to toggle dash behavior in the dashing item

/// Teleport user to target using do_dash. Returns TRUE if teleport successful, FALSE otherwise.
/datum/action/innate/dash/proc/teleport(mob/user, atom/target)
	if(!is_available(feedback = TRUE))
		return FALSE

	var/turf/current_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)

	// Use obj_damage to break through obstacles, but don't phase
	var/turf/final_turf = do_dash(user, current_turf, target_turf, obj_damage = obj_damage, phase = FALSE, on_turf_cross = CALLBACK(src, PROC_REF(dashslash), user))
	if(!final_turf)
		user.balloon_alert(user, "dash blocked!")
		return FALSE

	var/obj/spot_one = new phaseout(current_turf, user.dir)
	var/obj/spot_two = new phasein(final_turf, user.dir) // Use where ninja actually ended up
	spot_one.Beam(spot_two, beam_effect, time = beam_length)
	playsound(final_turf, dash_sound, 25, TRUE) // Play sound where ninja ended up
	owner?.update_action_buttons_icon()

	if (max_charges > 0 && current_charges == max_charges)
		addtimer(CALLBACK(src, PROC_REF(charge)), charge_rate)

	//User dashed but still ended up in the same place, take no charge. Yes this can occur from shenanigans.
	// The ninja dash does nothing to walls, and windows/tables are all instantly taken out by the 200 damage anyway, so this is just sanity check
	if(max_charges > 0 && current_turf != final_turf)
		current_charges--

	return TRUE

/datum/action/innate/dash/proc/dashslash(mob/user, turf/slash_location)
	for(var/mob/living/target in slash_location)//Hit everything in the turf
		// skip mobs that we shouldn't be able to hit
		if (target.incorporeal_move)
			continue
		// Skip any mobs that aren't standing, or aren't dense
		if ((target.body_position == LYING_DOWN) || !target.density || user == target)
			continue
		// Slash through target
		target.attackby(master, user)
		user.do_item_attack_animation(target, used_item = master)
		to_chat(target, span_userdanger("[user] dashes towards you faster than you can react!"))
		// Push the attacked person back
		target.Move(get_step(target, get_dir(user, target)))
		// Give the user a click cooldown
		user.changeNext_move(1.4 SECONDS)
		user.client?.give_cooldown_cursor(1.4 SECONDS)
		return FALSE
	// Give the user a click cooldown every time they dash
	user.changeNext_move(1.4 SECONDS)
	user.client?.give_cooldown_cursor(1.4 SECONDS)
	return TRUE

/// Callback for [/proc/teleport] to increment our charges after  use.
/datum/action/innate/dash/proc/charge()
	current_charges = clamp(current_charges + 1, 0, max_charges)

	var/obj/item/dashing_item = master
	if(!istype(dashing_item))
		return

	if(recharge_sound)
		playsound(dashing_item, recharge_sound, 50, TRUE)

	if(!owner)
		return
	owner.update_action_buttons_icon()
	dashing_item.balloon_alert(owner, "[current_charges]/[max_charges] dash charges")
	if (current_charges != max_charges)
		addtimer(CALLBACK(src, PROC_REF(charge)), charge_rate)
