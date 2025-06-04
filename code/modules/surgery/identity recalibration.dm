
/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace_limb
	name = "replace limb"
	implements = list(/obj/item/bodypart = 100, /obj/item/organ_storage = 100)
	time = 32
	var/obj/item/bodypart/L = null // L because "limb"


/datum/surgery_step/replace_limb/preop(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage) && istype(tool.contents[1], /obj/item/bodypart))
		tool = tool.contents[1]
	var/obj/item/bodypart/aug = tool
	if(IS_ORGANIC_LIMB(aug))
		to_chat(user, span_warning("That's not an augment, silly!"))
		return -1
	if(aug.body_zone != surgery.location)
		to_chat(user, span_warning("[tool] isn't the right type for [parse_zone(surgery.location)]."))
		return -1
	L = surgery.operated_bodypart

	if(!L)
		user.visible_message("[user] looks for [target]'s [parse_zone(surgery.location)].", span_notice("You look for [target]'s [parse_zone(surgery.location)]..."))
		return

	if(L?.bodypart_disabled)
		to_chat(user, span_warning("You can't augment a limb with paralysis!"))
		return -1
	else
		display_results(user, target, span_notice("You begin to augment [target]'s [parse_zone(surgery.location)]..."),
			"[user] begins to augment [target]'s [parse_zone(surgery.location)] with [aug].",
			"[user] begins to augment [target]'s [parse_zone(surgery.location)].")

//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "Augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace_limb)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE



/datum/surgery/augmentation/can_start(mob/user, mob/living/carbon/target, target_zone)
	return ..() && !isoozeling(target)

//SURGERY STEP SUCCESSES

/datum/surgery_step/replace_limb/success(mob/living/user, mob/living/carbon/target, obj/item/bodypart/tool, datum/surgery/surgery)
	if(L)
		if(istype(tool, /obj/item/organ_storage))
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = tool.contents[1]
		if(istype(tool) && user.temporarilyRemoveItemFromInventory(tool))
			tool.replace_limb(target, TRUE)
		L.drop_limb(1)
		display_results(user, target, span_notice("You successfully augment [target]'s [parse_zone(surgery.location)]."),
			"[user] successfully augments [target]'s [parse_zone(surgery.location)] with [tool]!",
			"[user] successfully augments [target]'s [parse_zone(surgery.location)]!")
		log_combat(user, target, "augmented", addition="by giving him new [parse_zone(surgery.location)] COMBAT MODE: [uppertext(user.combat_mode)]")
	else
		to_chat(user, span_warning("[target] has no organic [parse_zone(surgery.location)] there!"))
	return TRUE


///////RENAME



/datum/surgery_step/rename
	name = "swipe ID"
	implements = list(/obj/item/card/id = 100)
	time = 10
	repeatable = TRUE
	var/obj/item/card/id/id = null

//ACTUAL SURGERIES

/datum/surgery/rename
	name = "Identity Recalibration"
	steps = list(
			/datum/surgery_step/mechanic_open,
			/datum/surgery_step/open_hatch,
			/datum/surgery_step/prepare_electronics,
			/datum/surgery_step/rename,
			/datum/surgery_step/mechanic_close,
			)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_real_bodypart = TRUE
	requires_bodypart_type = BODYTYPE_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE

//SURGERY STEP SUCCESSES

/datum/surgery_step/rename/success(mob/living/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	if(tool)
		id = tool
		if(id.registered_name)
			target.real_name = id.registered_name
			display_results(user, target, span_notice("You successfully recalibrated [target]'s identity!"),
			"[user] successfully recalibrated [target]'s identity with [tool]!",
			"[user] successfully recalibrated [target]'s identity!")
			log_combat(user, target, "renamed", addition="changed [target] to [id.registered_name]")
		else
			target.real_name = "????"
			to_chat(user, span_warning("The lack of registered name on the card has lead to a glitch!"))
		return TRUE
