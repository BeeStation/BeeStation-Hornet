/obj/effect/proc_holder/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cleave"
	action_background_icon_state = "bg_ecult"
	invocation = "CL'VE"
	invocation_type = INVOCATION_WHISPER
	requires_heretic_focus = TRUE
	charge_max = 350
	clothes_req = FALSE
	range = 9

/obj/effect/proc_holder/spell/pointed/cleave/cast(list/targets, mob/user)
	if(!targets.len)
		user.balloon_alert(user, "No targets")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	for(var/mob/living/carbon/human/nearby_human in range(1, targets[1]))
		targets |= nearby_human

	for(var/mob/living/carbon/human/victim as anything in targets)
		if(victim == user)
			continue
		if(victim.anti_magic_check())
			victim.visible_message(
				"<span class='danger'>[victim]'s body flashes in a fiery glow, but repels the blaze!</span>",
				"<span class='danger'>Your body begins to flash in a fiery glow, but you are protected!</span>"
			)
			continue

		if(!victim.blood_volume)
			continue

		victim.visible_message(
			"<span class='danger'>[victim]'s veins are shredded from within as an unholy blaze erupts from [victim.p_their()] blood!</span>",
			"<span class='danger'>Your veins burst from within and unholy flame erupts from your blood!</span>"
		)

		victim.bleed_rate += 5
		victim.adjustFireLoss(20)
		new /obj/effect/temp_visual/cleave(victim.drop_location())

/obj/effect/proc_holder/spell/pointed/cleave/can_target(atom/target, mob/user, silent)
	if(!ishuman(target))
		if(!silent)
			target.balloon_alert(user, "Invalid target")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/cleave/long
	charge_max = 650

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/heretic.dmi'
	icon_state = "cleave"
	duration = 6
