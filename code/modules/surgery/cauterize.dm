/datum/surgery/cauterize
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_IGNORE_CLOTHES
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/close
	)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_bodypart_type = NONE
	replaced_by = /datum/surgery

/datum/surgery/cauterize/can_start(mob/user, mob/living/carbon/target)
	if (..())
		return TRUE
	return target.is_bleeding()
