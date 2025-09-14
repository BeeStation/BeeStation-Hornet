/datum/surgery/bone_setting
	name = "bone setting"
	possible_locs = list(
		BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM,
		BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders/bone_setting
	)
	requires_injury = TRUE
	var/target_injury = /datum/injury/trauma_healthy

/datum/surgery_step/clamp_bleeders/bone_setting
	name = "set bone"

/datum/surgery_step/clamp_bleeders/bone_setting/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to set the bone in [target]'s [parse_zone(surgery.location)]..."),
		"[user] starts setting the bone in [target]'s [parse_zone(surgery.location)].",
		"[user] starts setting the bone in [target]'s [parse_zone(surgery.location)].")

/datum/surgery_step/clamp_bleeders/bone_setting/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/bone_setting/surgery)
	var/datum/injury/injury = surgery.operated_bodypart.get_injury(surgery.target_injury)
	injury.heal()
	return TRUE
