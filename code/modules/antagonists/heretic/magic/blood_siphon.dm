/obj/effect/proc_holder/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A spell that heals your wounds while damaging the enemy."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	action_background_icon_state = "bg_ecult"
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = INVOCATION_WHISPER
	charge_max = 150
	clothes_req = FALSE
	range = 9

/obj/effect/proc_holder/spell/pointed/blood_siphon/cast(list/targets, mob/living/user)
	if(!istype(user))
		revert_cast()
		return
	var/mob/living/target = targets[1]
	if(!istype(target))
		user.balloon_alert(user, "Invalid target")
		return
	playsound(user, 'sound/magic/demon_attack1.ogg', vol = 75, vary = TRUE)
	if(target.anti_magic_check())
		user.balloon_alert(user, "Spell blocked")
		target.visible_message(
			"<span class='danger'>The spell bounces off of [target]!</span>",
			"<span class='danger'>The spell bounces off of you!</span>",
		)
		return

	target.visible_message(
		"<span class='danger'>[target] turns pale as a red glow envelops [target.p_them()]!</span>",
		"<span class='danger'>You turn pale as a red glow enevelops you!</span>",
	)

	target.take_overall_damage(brute = 20)
	user.heal_overall_damage(brute = 20)

	if(!user.blood_volume)
		return

	target.blood_volume -= 20
	if(user.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		user.blood_volume += 20

/obj/effect/proc_holder/spell/pointed/blood_siphon/can_target(atom/target, mob/user, silent)
	if(!isliving(target))
		if(!silent)
			target.balloon_alert(user, "Invalid target")
		return FALSE
	return TRUE
