/obj/effect/proc_holder/spell/targeted/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "A spell that extinguishes you and drains nearby heathens engulfed in flames of their life force, \
		healing you for each victim drained. Those in critical condition will have the last of their vitality drained, killing them."
	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = INVOCATION_WHISPER
	requires_heretic_focus = TRUE
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 600
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/targeted/fiery_rebirth/cast(list/targets, mob/living/carbon/human/user)
	if(!istype(user))
		revert_cast()
		return
	var/did_something = user.on_fire // This might be a false negative if the user has items on fire but they themselves are not.
	user.ExtinguishMob()

	for(var/mob/living/carbon/target in view(7, user))
		if(!target.mind || !target.client || target.stat == DEAD || !target.on_fire || IS_HERETIC_OR_MONSTER(target))
			continue
		//This is essentially a death mark, use this to finish your opponent quicker.
		if(target.InCritical() && !HAS_TRAIT(target, TRAIT_NODEATH))
			target.investigate_log("has been killed by fiery rebirth.", INVESTIGATE_DEATHS)
			target.death()

		target.take_overall_damage(burn = 20)
		new /obj/effect/temp_visual/eldritch_smoke(target.drop_location())
		user.heal_overall_damage(brute = 10, burn = 10, stamina = 10, updating_health = FALSE)
		user.adjustToxLoss(-10, updating_health = FALSE, forced = TRUE)
		user.adjustOxyLoss(-10)
		did_something = TRUE

	if(!did_something)
		revert_cast()

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/heretic.dmi'
	icon_state = "smoke"
	duration = 10
