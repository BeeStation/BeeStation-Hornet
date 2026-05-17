/datum/surgery/advanced/experimental_dissection
	name = "Experimental Dissection"
	desc = "A surgical procedure which deeply analyzes the biology of a corpse, and automatically adds new findings to the research database."
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/experimental_dissection,
		/datum/surgery_step/close,
	)
	surgery_flags = SURGERY_REQUIRE_RESTING
	possible_locs = list(BODY_ZONE_CHEST)
	target_mobtypes = list(/mob/living)

/datum/surgery/advanced/experimental_dissection/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return .
	if(HAS_TRAIT_FROM(target, TRAIT_DISSECTED, EXPERIMENTAL_SURGERY_TRAIT))
		return FALSE
	if(target.stat != DEAD)
		return FALSE
	return .

/datum/surgery_step/experimental_dissection
	name = "dissection"
	implements = list(
		TOOL_SCALPEL = 60,
		TOOL_KNIFE = 20,
		/obj/item/shard = 10,
	)
	time = 12 SECONDS
	silicons_obey_prob = TRUE

/datum/surgery_step/experimental_dissection/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(span_notice("[user] starts dissecting [target]."), span_notice("You start dissecting [target]."))

/datum/surgery_step/experimental_dissection/proc/check_value(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.dna?.species)
			if(isabductor(H))
				return 8000
			if(isgolem(H) || iszombie(H) || isashwalker(H))
				return 4000
			if(isslimeperson(H) || isluminescent(H) || isstargazer(H) || isdiona(H))
				return 3000
			return 2000
	else if(isalienroyal(target))
		return 10000
	else if(isalienadult(target))
		return 5000
	else if(ismonkey(target))
		return 1000

/datum/surgery_step/experimental_dissection/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	user.visible_message("[user] dissects [target]!", span_notice("You dissect [target], and add your discoveries to the research database!"))
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_DISCOVERY = check_value(target)))
	var/obj/item/bodypart/L = target.get_bodypart(BODY_ZONE_CHEST)
	target.apply_damage(80, BRUTE, L)
	ADD_TRAIT(target, TRAIT_DISSECTED, "surgery")
	return TRUE

/datum/surgery_step/experimental_dissection/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] dissects [target]!", span_notice("You dissect [target], but do not find anything particularly interesting."))
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_DISCOVERY = (check_value(target) * 0.2)))
	var/obj/item/bodypart/L = target.get_bodypart(BODY_ZONE_CHEST)
	target.apply_damage(80, BRUTE, L)
	ADD_TRAIT(target, TRAIT_DISSECTED, "surgery")
	return TRUE
