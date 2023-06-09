/datum/surgery/blood_filter
	name = "Filter Blood"
	desc = "A surgical procedure that filters toxins from the patient's blood. Does not undo any toxin damage, however."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/filter_blood,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = TRUE
	ignore_clothes = FALSE
	replaced_by = /datum/surgery/blood_filter/upgraded
	var/antispam = FALSE
	var/filtering_step_type

/datum/surgery/blood_filter/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(filtering_step_type)
		steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				filtering_step_type,
				/datum/surgery_step/close)

/datum/surgery/blood_filter/can_start(mob/user, mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_HUSK)) //Can't filter husk
		return FALSE
	var/datum/surgery_step/filter_blood/filtering_step = filtering_step_type
	var/heals_tox = filtering_step ? initial(filtering_step.tox_heal_factor) > 0 : FALSE
	if((!heals_tox || target.getToxLoss() <= 0) && target.reagents?.total_volume == 0)
		return FALSE
	return ..()

/datum/surgery_step/filter_blood
	name = "Filter blood"
	implements = list(/obj/item/blood_filter = 95)
	repeatable = TRUE
	time = 2.5 SECONDS
	success_sound = 'sound/machines/ping.ogg'
	var/chem_purge_factor = 0.2
	var/tox_heal_factor = 0

/datum/surgery_step/filter_blood/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(surgery,/datum/surgery/blood_filter))
		var/datum/surgery/blood_filter/the_surgery = surgery
		if(!the_surgery.antispam)
			display_results(user, target, "<span class='notice'>You begin filtering [target]'s blood...</span>",
		"<span class='notice'>[user] uses [tool] to filtering your blood.</span>",
		"<span class='notice'>[user] uses [tool] on [target]'s chest.</span>")

/datum/surgery_step/filter_blood/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(..())
		while(target.reagents.total_volume || (tox_heal_factor > 0 && target.getToxLoss() > 0))
			if(!..())
				break

/datum/surgery_step/filter_blood/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/tox_loss = target.getToxLoss()
	if(target.reagents.total_volume || (tox_heal_factor > 0 && tox_loss > 0))
		for(var/blood_chem in target.reagents.reagent_list)
			var/datum/reagent/chem = blood_chem
			target.reagents.remove_reagent(chem.type, min(chem.volume * chem_purge_factor, 10)) //Removes more reagent for higher amounts
		if(tox_heal_factor > 0)
			if(tox_loss <= 2)
				target.setToxLoss(0)
			else
				target.adjustToxLoss(-(tox_loss * tox_heal_factor), forced=TRUE) //forced so this will actually heal oozelings too
		var/list/remaining = list()
		if(locate(/obj/item/healthanalyzer) in user.held_items)
			if(tox_heal_factor > 0 && tox_loss > 0)
				remaining += "<font color='[COLOR_GREEN]'>[round(tox_loss, 0.1)]</font> toxin"
			if(target.reagents.total_volume)
				remaining += "<font color='[COLOR_MAGENTA]'>[round(target.reagents.total_volume, 0.1)]u</font> of reagents"
		var/umsg = length(remaining) ? " [english_list(remaining)] remaining." : ""
		display_results(user, target, "<span class='notice'>[tool] pings as it filters [target]'s blood.[umsg]</span>",
				"<span class='notice'>[user] pumps [target]'s blood with [tool].</span>",
				"[tool] pings as it pumps.")
	else
		display_results(user, target, "<span class='notice'>[tool] flashes, [target]'s blood is clean.</span>",
			"<span class='notice'>[user] finishes pumping [target]'s blood with [tool]</span>",
			"[tool] has no chemicals or toxins to filter.")
	if(istype(surgery, /datum/surgery/blood_filter))
		var/datum/surgery/blood_filter/the_surgery = surgery
		the_surgery.antispam = TRUE
	return TRUE

/datum/surgery_step/filter_blood/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You screw up, brusing [target]'s chest!</span>",
		"<span class='warning'>[user] screws up, brusing [target]'s chest!</span>",
		"<span class='warning'>[user] screws up!</span>")
	target.adjustBruteLoss(5)

/datum/surgery/blood_filter/upgraded
	name = "Filter Blood (Adv.)"
	desc = "A surgical procedure that provides advanced toxin filtering to remove reagents from the patient's blood, in addition to undoing any damage the toxins done to the patient's system. Heals considerably more when the patient is severely injured."
	requires_tech = TRUE
	filtering_step_type = /datum/surgery_step/filter_blood/upgraded
	replaced_by = /datum/surgery/blood_filter/femto

/datum/surgery_step/filter_blood/upgraded
	time = 1.85 SECONDS
	tox_heal_factor = 0.075

/datum/surgery/blood_filter/femto
	name = "Filter Blood (Exp.)"
	desc = "A surgical procedure that provides experimental toxin filtering to remove reagents from the patient's blood, in addition to undoing any damage the toxins done to the patient's system. Heals considerably more when the patient is severely injured."
	requires_tech = TRUE
	filtering_step_type = /datum/surgery_step/filter_blood/upgraded/femto
	replaced_by = null

/datum/surgery_step/filter_blood/upgraded/femto
	time = 1 SECONDS
