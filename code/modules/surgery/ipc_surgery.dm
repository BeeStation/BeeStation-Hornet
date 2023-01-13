/datum/surgery/ipc_clone_damage_surgery
	name = "repair prosthesis anomaly damage"
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYTYPE_ROBOTIC
	lying_required = TRUE
	self_operable = FALSE
	speed_modifier = 0.8
	steps = list(
		/datum/surgery_step/mechanic_open, // 1
		/datum/surgery_step/open_hatch,    // 2
		/datum/surgery_step/mechanic_unwrench, // 3
		/datum/surgery_step/prepare_electronics, // 4
		/datum/surgery_step/prepare_electronics/ipc_clone_damage_surgery, // 5
		/datum/surgery_step/cut_wires, // 6
		/datum/surgery_step/prepare_electronics/ipc_clone_damage_surgery, // 7
		/datum/surgery_step/pulling_out, // 8
		/datum/surgery_step/insert_wires, // 9
		/datum/surgery_step/prepare_electronics/ipc_clone_damage_surgery, // 10
		/datum/surgery_step/mechanic_open/ipc_clone_damage_surgery, // 11
		/datum/surgery_step/prepare_electronics/ipc_clone_damage_surgery, // 12
		/datum/surgery_step/mechanic_wrench/ipc_clone_damage_surgery, // 13
		/datum/surgery_step/mechanic_wrench, // 14
		/datum/surgery_step/mechanic_close // 15
		)

// electronics step
/datum/surgery_step/prepare_electronics/ipc_clone_damage_surgery
	name = "neutralise anomaly electronics"
	time = 30

/datum/surgery_step/prepare_electronics/ipc_clone_damage_surgery/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getCloneLoss() > 60) // this quite does nothing much, but good to know it's going well!
		target.adjustCloneLoss(-(target.getCloneLoss()/2), 0)
	else
		target.adjustCloneLoss(-5, 0)
	return TRUE

// bolt step
/datum/surgery_step/mechanic_open/ipc_clone_damage_surgery
	name = "retighten small bolts"
	time = 40

/datum/surgery_step/mechanic_open/ipc_clone_damage_surgery/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to adjust small bolts in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to adjust small bolts in [target]'s [parse_zone(target_zone)].",
		"[user] begins to adjust small bolts in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_open/ipc_clone_damage_surgery/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getCloneLoss() > 15) // this quite does nothing much, but good to know it's going well!
		target.adjustCloneLoss(-(target.getCloneLoss()/2), 0)
	return TRUE

// wrench step - this will be the final step
/datum/surgery_step/mechanic_wrench/ipc_clone_damage_surgery
	name = "retighten big bolts"
	time = 60

/datum/surgery_step/mechanic_wrench/ipc_clone_damage_surgery/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(isipc(target) || isandroid(target))
		target.setCloneLoss(0, 0)
	else // non-ipc by taking this surgery... their chest seems to be replaced, but they shouldn't be fully healed through this.
		target.adjustCloneLoss(-70, 0)
	return TRUE
