/obj/effect/proc_holder/spell/targeted/touch/hive_fist
	name = "Mental Fist"
	desc = "We channel the strength of our host's hive into a physical weapon, specially effective on rival hives."
	hand_path = /obj/item/melee/touch_attack/hive_fist
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_icon_state = "hand"
	action_background_icon_state = "bg_hive"

/obj/item/melee/touch_attack/hive_fist
	name = "Mental Fist"
	desc = "The physical embodiment of a hivemind's might."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	catchphrase = null

/obj/item/melee/touch_attack/hive_fist/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || target == user)
		return FALSE
	var/use_charge = FALSE
	if(ishuman(target))
		playsound(user, 'sound/items/welder.ogg', 75, TRUE)
		var/mob/living/carbon/human/tar = target
		var/datum/antagonist/hivemind/foe = IS_HIVEHOST(tar)
		var/datum/antagonist/hivevessel/vessel = IS_WOKEVESSEL(tar)
		var/datum/antagonist/hivevessel/vesselus = IS_WOKEVESSEL(user)
		if(vessel)
			foe = vessel.master
		if(foe)
			tar.adjustFireLoss(round(vesselus.master.hive_size * 0.75))
			tar.adjustStaminaLoss(15)
		else
			tar.adjustFireLoss(15)
			tar.adjustStaminaLoss(40)
			use_charge = TRUE
	if(use_charge)
		return ..()
