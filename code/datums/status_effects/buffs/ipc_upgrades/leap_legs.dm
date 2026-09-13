/datum/status_effect/ipc_upgrade/leap_legs
	id = "ipc leap legs"
	name = "Leap Legs"
	power_requirement = 250
	cooldown_length = 5 SECONDS
	singleton = TRUE
	action_type = /datum/action/innate/ipc_upgrade_action/targeted
	action_icon = "leap_legs"
	item_type = /obj/item/ipc_upgrade/leap_legs

/datum/status_effect/ipc_upgrade/leap_legs/on_activate(atom/target)
	if(!target)
		return
	playsound(owner, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	if(!do_after(owner, 1 SECONDS, owner))
		return
	playsound(owner, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	var/angle = get_angle(owner, target)
	owner.transform = owner.transform.Turn(angle)
	owner.throw_at(target, 5, 1, spin = FALSE, callback = CALLBACK(src, PROC_REF(on_throw_end), owner, -angle))

/datum/status_effect/ipc_upgrade/leap_legs/proc/on_throw_end(mob/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(angle)
