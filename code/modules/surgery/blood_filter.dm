/datum/surgery/blood_filter
	name = "Filter blood"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/filter_blood,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = TRUE
	ignore_clothes = FALSE
	var/antispam = FALSE

/datum/surgery_step/filter_blood
	name = "Filter blood"
	implements = list(/obj/item/blood_filter = 95)
	repeatable = TRUE
	time = 2.5 SECONDS

/datum/surgery/blood_filter/can_start(mob/user, mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_HUSK) || target.reagents.total_volume==0) //Can't filter husk or 0 regent body
		return FALSE
	return ..()

/datum/surgery_step/filter_blood/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery,/datum/surgery/blood_filter))
		var/datum/surgery/blood_filter/the_surgery = surgery
		if(!the_surgery.antispam)
			display_results(user, target, "<span class='notice'>You begin filtering [target]'s blood...</span>",
		"<span class='notice'>[user] uses [tool] to filtering your blood.</span>",
		"<span class='notice'>[user] uses [tool] on [target]'s chest.</span>")

/datum/surgery_step/filter_blood/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(..())
		while(target.reagents.total_volume)
			if(!..())
				break

/datum/surgery_step/filter_blood/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(target.reagents.total_volume)
		for(var/blood_chem in target.reagents.reagent_list)
			var/datum/reagent/chem = blood_chem
			target.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10)) //Removes more reagent for higher amounts
		display_results(user, target, "<span class='notice'>[tool] pings as it finishes filtering [target]'s blood.</span>",
			"<span class='notice'>[tool] pings as it stops pumping your blood.</span>",
			"[tool] pings as it stops pumping.")
	else
		display_results(user, target, "<span class='notice'>[tool] flashes, [target]'s blood is clean.</span>",
			"<span class='notice'>[tool] flashes, your blood is clean.</span>",
			"[tool] has no chemcials to filter.")
	if(istype(surgery, /datum/surgery/blood_filter))
		var/datum/surgery/blood_filter/the_surgery = surgery
		the_surgery.antispam = TRUE
	return TRUE

/datum/surgery_step/filter_blood/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You screw up, brusing [target]'s chest!</span>",
		"<span class='warning'>[user] screws up, brusing [target]'s chest!</span>",
		"<span class='warning'>[user] screws up!</span>")
	target.adjustBruteLoss(5)
