/datum/surgery/stitch_muscle
	name = "stitch muscle"
	possible_locs = list(
		BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM,
		BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders/stitch_muscle
	)
	requires_injury = TRUE

/datum/surgery_step/clamp_bleeders/stitch_muscle
	name = "stitch muscle"

/datum/surgery_step/clamp_bleeders/stitch_muscle/preop(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to stitch the muscle in [target]'s [parse_zone(surgery.location)]..."),
		"[user] starts stitching the muscle in [target]'s [parse_zone(surgery.location)].",
		"[user] starts stitching the muscle in [target]'s [parse_zone(surgery.location)].")

/datum/surgery_step/clamp_bleeders/stitch_muscle/success(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/skin_graft/surgery)
	var/datum/injury/injury = surgery.operated_bodypart.get_injury_by_base(/datum/injury/cut_healthy)
	injury.heal()
	return TRUE
