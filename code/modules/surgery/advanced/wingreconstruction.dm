/datum/surgery/advanced/wing_reconstruction
	name = "Wing Reconstruction"
	desc = "An experimental surgical procedure that reconstructs the damaged wings of moth people. Requires Instabitaluri."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/wing_reconstruction)
	possible_locs = list(BODY_ZONE_CHEST)
	target_mobtypes = list(/mob/living/carbon/human)

/datum/surgery/advanced/wing_reconstruction/can_start(mob/user, mob/living/carbon/target)
	return ..() && target.dna.features["moth_wings"] == "Burnt Off" && ismoth(target)

/datum/surgery_step/wing_reconstruction
	name = "start wing reconstruction"
	implements = list(TOOL_HEMOSTAT = 85, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	time = 200
	chems_needed = list(/datum/reagent/medicine/synthflesh)
	require_all_chems = FALSE

/datum/surgery_step/wing_reconstruction/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to fix [target]'s charred wing membranes...</span>",
		"<span class='notice'>[user] begins to fix [target]'s charred wing membranes.</span>",
		"<span class='notice'>[user] begins to perform surgery on [target]'s charred wing membranes.</span>")

/datum/surgery_step/wing_reconstruction/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		display_results(user, target, "<span class='notice'>You succeed in reconstructing [target]'s wings.</span>",
			"<span class='notice'>[user] successfully reconstructs [target]'s wings!</span>",
			"<span class='notice'>[user] completes the surgery on [target]'s wings.</span>")
		if(H.dna.features["original_moth_wings"] != null)
			H.dna.features["moth_wings"] = H.dna.features["original_moth_wings"]
		else
			H.dna.features["moth_wings"] = "Plain"
		H.update_mutant_bodyparts()
	return ..()