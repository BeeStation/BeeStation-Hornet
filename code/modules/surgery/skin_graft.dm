/datum/surgery/skin_graft
	name = "skin graft"
	// Dynamically determined
	location = null
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/incise/skin_graft
	)

/datum/surgery_step/incise/skin_graft
	name = "cut skin"

/datum/surgery_step/incise/skin_graft/preop(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to cut away the healthy skin at [target]'s [parse_zone(surgery.location)]..."),
		"[user] starts extracting some healthy skin from [target]'s [parse_zone(surgery.location)].",
		"[user] starts extracting some healthy skin from [target]'s [parse_zone(surgery.location)].")

/datum/surgery/skin_graft/third_degree
	name = "skin graft"
