/datum/action/innate/dash
	name = "Dash"
	desc = "Teleport to the targeted location."
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	var/current_charges = 1
	/// If set to 0, doesn't require charges
	var/max_charges = 0
	/// How much damage is dealt to objects in the path
	var/obj_damage = 200
	var/charge_rate = 250
	var/obj/item/dashing_item
	var/dash_sound = 'sound/magic/blink.ogg'
	var/recharge_sound = 'sound/magic/charge.ogg'
	var/beam_effect = "blur"
	var/phasein = /obj/effect/temp_visual/dir_setting/ninja/phase
	var/phaseout = /obj/effect/temp_visual/dir_setting/ninja/phase/out

/datum/action/innate/dash/Grant(mob/user, obj/dasher)
	. = ..()
	dashing_item = dasher

/datum/action/innate/dash/Destroy()
	dashing_item = null
	return ..()

/datum/action/innate/dash/is_available()
	if(current_charges > 0 || max_charges == 0)
		return TRUE
	else
		return FALSE

/datum/action/innate/dash/on_activate()
	dashing_item.attack_self(owner) //Used to toggle dash behavior in the dashing item

/datum/action/innate/dash/proc/Teleport(mob/user, atom/target)
	if(!is_available())
		return
	var/turf/T = get_turf(target)
	var/obj/spot1 = new phaseout(get_turf(user), user.dir)
	var/turf/new_location = do_dash(user, get_turf(user), T, obj_damage=obj_damage, phase=FALSE, on_turf_cross=CALLBACK(src, PROC_REF(dashslash), user))
	if(new_location)
		playsound(T, dash_sound, 25, 1)
		var/obj/spot2 = new phasein(new_location, user.dir)
		spot1.Beam(spot2,beam_effect,time=2 SECONDS)
		if (owner)
			owner.update_action_buttons_icon()
		if (max_charges > 0)
			if (current_charges == max_charges)
				addtimer(CALLBACK(src, PROC_REF(charge)), charge_rate)
			current_charges--
	else
		to_chat(user, span_warning("You cannot dash here!"))

/datum/action/innate/dash/proc/dashslash(mob/user, turf/slash_location)
	for(var/mob/living/target in slash_location)//Hit everything in the turf
		// skip mobs that we shouldn't be able to hit
		if (target.incorporeal_move)
			continue
		// Skip any mobs that aren't standing, or aren't dense
		if ((target.body_position == LYING_DOWN) || !target.density || user == target)
			continue
		// Slash through target
		target.attackby(dashing_item, user)
		user.do_item_attack_animation(target, used_item=dashing_item)
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

/datum/action/innate/dash/proc/charge()
	current_charges = clamp(current_charges + 1, 0, max_charges)
	if (owner)
		owner.update_action_buttons_icon()
		to_chat(owner, span_notice("[src] now has [current_charges]/[max_charges] charges."))
	if(recharge_sound)
		playsound(dashing_item, recharge_sound, 50, 1)
	if (current_charges != max_charges)
		addtimer(CALLBACK(src, PROC_REF(charge)), charge_rate)
