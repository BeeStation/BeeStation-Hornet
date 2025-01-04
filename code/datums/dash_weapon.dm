/datum/action/innate/dash
	name = "Dash"
	desc = "Teleport to the targeted location."
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	var/current_charges = 1
	var/max_charges = 1
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

/datum/action/innate/dash/IsAvailable()
	if(current_charges > 0)
		return TRUE
	else
		return FALSE

/datum/action/innate/dash/Activate()
	dashing_item.attack_self(owner) //Used to toggle dash behavior in the dashing item

/datum/action/innate/dash/proc/Teleport(mob/user, atom/target)
	if(!IsAvailable())
		return
	var/turf/T = get_turf(target)
	if(user in viewers(user.client.view, T))
		var/obj/spot1 = new phaseout(get_turf(user), user.dir)
		var/turf/new_location = do_dash(user, get_turf(user), T, obj_damage=200, phase=FALSE, on_turf_cross=CALLBACK(src, PROC_REF(dashslash), user))
		if(new_location)
			playsound(T, dash_sound, 25, 1)
			var/obj/spot2 = new phasein(new_location, user.dir)
			spot1.Beam(spot2,beam_effect,time=2 SECONDS)
			if (owner)
				owner.update_action_buttons_icon()
			if (current_charges == max_charges)
				addtimer(CALLBACK(src, PROC_REF(charge)), charge_rate)
			current_charges--
		else
			to_chat(user, "<span class='warning'>You cannot dash here!</span>")

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
		to_chat(target, "<span class='userdanger'>[user] goes through you faster than you can see!</span>")
	return TRUE

/datum/action/innate/dash/proc/charge()
	current_charges = clamp(current_charges + 1, 0, max_charges)
	if (owner)
		owner.update_action_buttons_icon()
		to_chat(owner, "<span class='notice'>[src] now has [current_charges]/[max_charges] charges.</span>")
	if(recharge_sound)
		playsound(dashing_item, recharge_sound, 50, 1)
	if (current_charges != max_charges)
		addtimer(CALLBACK(src, PROC_REF(charge)), charge_rate)
