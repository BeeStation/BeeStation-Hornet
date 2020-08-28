/datum/surgery/prosthetic_replacement
	name = "prosthetic replacement"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/add_prosthetic)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD)
	requires_bodypart = FALSE //need a missing limb
	requires_bodypart_type = 0
	self_operable = TRUE

/datum/surgery/prosthetic_replacement/can_start(mob/user, mob/living/carbon/target, target_zone)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/C = target
	if(!isoozeling(target))
		if(!C.get_bodypart(target_zone)) //can only start if limb is missing
			return TRUE


/datum/surgery_step/add_prosthetic
	name = "add prosthetic"
	implements = list(/obj/item/bodypart = 100, /obj/item/organ_storage = 100, /obj/item/chainsaw = 100, /obj/item/melee/synthetic_arm_blade = 100)
	time = 32
	var/organ_rejection_dam = 0

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, span_notice("There is nothing inside [tool]!"))
			return -1
		var/obj/item/I = tool.contents[1]
		if(!isbodypart(I))
			to_chat(user, span_notice("[I] cannot be attached!"))
			return -1
		tool = I
	if(istype(tool, /obj/item/bodypart))
		var/obj/item/bodypart/BP = tool
		if(ismonkey(target))// monkey patient only accept organic monkey limbs
			if(!IS_ORGANIC_LIMB(BP) || BP.animal_origin != MONKEY_BODYPART)
				to_chat(user, span_warning("[BP] doesn't match the patient's morphology."))
				return -1
		if(IS_ORGANIC_LIMB(BP))
			organ_rejection_dam = 10
			if(ishuman(target))
				if(BP.animal_origin)
					to_chat(user, span_warning("[BP] doesn't match the patient's morphology."))
					return -1
				var/mob/living/carbon/human/H = target
				if(H.dna.species.id != BP.limb_id)
					organ_rejection_dam = 30

		if(surgery.location == BP.body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
			display_results(user, target, span_notice("You begin to replace [target]'s [parse_zone(surgery.location)] with [tool]..."),
				"[user] begins to replace [target]'s [parse_zone(surgery.location)] with [tool].",
				"[user] begins to replace [target]'s [parse_zone(surgery.location)].")
		else
			to_chat(user, span_warning("[tool] isn't the right type for [parse_zone(surgery.location)]."))
			return -1
	else if(surgery.location == BODY_ZONE_L_ARM || surgery.location == BODY_ZONE_R_ARM)
		display_results(user, target, span_notice("You begin to attach [tool] onto [target]..."),
			"[user] begins to attach [tool] onto [target]'s [parse_zone(surgery.location)].",
			"[user] begins to attach something onto [target]'s [parse_zone(surgery.location)].")
	else
		to_chat(user, span_warning("[tool] must be installed onto an arm."))
		return -1

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
		tool = tool.contents[1]
	if(istype(tool, /obj/item/bodypart) && user.temporarilyRemoveItemFromInventory(tool))
		var/obj/item/bodypart/L = tool
		L.attach_limb(target)
		if(organ_rejection_dam)
			target.adjustToxLoss(organ_rejection_dam)
		display_results(user, target, span_notice("You succeed in replacing [target]'s [parse_zone(surgery.location)]."),
			"[user] successfully replaces [target]'s [parse_zone(surgery.location)] with [tool]!",
			"[user] successfully replaces [target]'s [parse_zone(surgery.location)]!")
		target.cauterise_wounds()
		return 1
	else
		var/obj/item/bodypart/L = target.newBodyPart(surgery.location, FALSE, FALSE)
		L.is_pseudopart = TRUE
		L.attach_limb(target)
		user.visible_message("[user] finishes attaching [tool]!", span_notice("You attach [tool]."))
		display_results(user, target, span_notice("You attach [tool]."),
			"[user] finishes attaching [tool]!",
			"[user] finishes the attachment procedure!")
		qdel(tool)
		if(istype(tool, /obj/item/chainsaw/energy/doom))
			var/obj/item/mounted_chainsaw/super/new_arm = new(target)
			surgery.location == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return 1
		else if(istype(tool, /obj/item/chainsaw/energy))
			var/obj/item/mounted_chainsaw/energy/new_arm = new(target)
			surgery.location == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return 1
		else if(istype(tool, /obj/item/chainsaw))
			var/obj/item/mounted_chainsaw/normal/new_arm = new(target)
			surgery.location == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return 1
		else if(istype(tool, /obj/item/melee/synthetic_arm_blade))
			var/obj/item/melee/arm_blade/new_arm = new(target,TRUE,TRUE)
			surgery.location == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return 1
