/datum/surgery/coronary_bypass
	name = "Coronary Bypass"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise_heart, /datum/surgery_step/coronary_bypass, /datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/coronary_bypass/can_start(mob/user, mob/living/carbon/target, target_zone)
	var/obj/item/organ/heart/H = target.get_organ_slot(ORGAN_SLOT_HEART)
	if(H)
		if(H.damage > 60 && !H.operated)
			return TRUE
	return FALSE


//an incision but with greater bleed, and a 90% base success chance
/datum/surgery_step/incise_heart
	name = "incise heart"
	implements = list(TOOL_SCALPEL = 90, /obj/item/melee/energy/sword = 45, /obj/item/knife = 45,
		/obj/item/shard = 25)
	time = 16
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/incise_heart/preop(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to make an incision in [target]'s heart..."),
		"[user] begins to make an incision in [target]'s heart.",
		"[user] begins to make an incision in [target]'s heart.")

/datum/surgery_step/incise_heart/success(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if (!HAS_TRAIT(H, TRAIT_NOBLOOD))
			display_results(user, target, span_notice("Blood pools around the incision in [H]'s heart."),
				"Blood pools around the incision in [H]'s heart.",
				"")
			H.add_bleeding(BLEED_DEEP_WOUND)
			H.adjustBruteLoss(10)
	return TRUE

/datum/surgery_step/incise_heart/failure(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		display_results(user, target, span_warning("You screw up, cutting too deeply into the heart!"),
			span_warning("[user] screws up, causing blood to spurt out of [H]'s chest!"),
			span_warning("[user] screws up, causing blood to spurt out of [H]'s chest!"))
		H.add_bleeding(BLEED_CRITICAL)
		H.adjustOrganLoss(ORGAN_SLOT_HEART, 10)
		H.adjustBruteLoss(10)

//grafts a coronary bypass onto the individual's heart, success chance is 90% base again
/datum/surgery_step/coronary_bypass
	name = "graft coronary bypass"
	implements = list(TOOL_HEMOSTAT = 90, TOOL_WIRECUTTER = 35, /obj/item/stack/package_wrap = 15, /obj/item/stack/cable_coil = 5)
	time = 90

/datum/surgery_step/coronary_bypass/preop(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin to graft a bypass onto [target]'s heart..."),
			"[user] begins to graft something onto [target]'s heart!",
			"[user] begins to graft something onto [target]'s heart!")

/datum/surgery_step/coronary_bypass/success(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	target.setOrganLoss(ORGAN_SLOT_HEART, 60)
	var/obj/item/organ/heart/heart = target.get_organ_slot(ORGAN_SLOT_HEART)
	if(heart)	//slightly worrying if we lost our heart mid-operation, but that's life
		heart.operated = TRUE
	display_results(user, target, span_notice("You successfully graft a bypass onto [target]'s heart."),
			"[user] finishes grafting something onto [target]'s heart.",
			"[user] finishes grafting something onto [target]'s heart.")
	return TRUE

/datum/surgery_step/coronary_bypass/failure(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		display_results(user, target, span_warning("You screw up in attaching the graft, and it tears off, tearing part of the heart!"),
			span_warning("[user] screws up, causing blood to spurt out of [H]'s chest profusely!"),
			span_warning("[user] screws up, causing blood to spurt out of [H]'s chest profusely!"))
		H.adjustOrganLoss(ORGAN_SLOT_HEART, 20)
		H.add_bleeding(BLEED_CRITICAL)
	return FALSE
