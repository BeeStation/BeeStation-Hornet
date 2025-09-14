/datum/surgery/skin_graft
	name = "skin graft"
	possible_locs = list(
		BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM,
		BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders/skin_graft
	)
	requires_injury = TRUE
	var/target_injury = /datum/injury/healthy_skin_burn

/datum/surgery_step/clamp_bleeders/skin_graft
	name = "graft skin"

/datum/surgery_step/clamp_bleeders/skin_graft/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to transfer the healthy skin at [target]'s [parse_zone(surgery.location)]..."),
		"[user] starts transfering some healthy skin from [target]'s [parse_zone(surgery.location)].",
		"[user] starts transfering some healthy skin from [target]'s [parse_zone(surgery.location)].")

/datum/surgery_step/clamp_bleeders/skin_graft/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/skin_graft/surgery)
	var/datum/injury/injury = surgery.operated_bodypart.get_injury(surgery.target_injury)
	injury.heal()
	return TRUE
