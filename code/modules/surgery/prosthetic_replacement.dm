/datum/surgery/prosthetic_replacement
	name = "Prosthetic replacement"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/add_prosthetic
	)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_HEAD
	)
	requires_bodypart = FALSE //need a missing limb
	requires_bodypart_type = 0
	self_operable = TRUE

/datum/surgery/prosthetic_replacement/can_start(mob/user, mob/living/carbon/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/C = target
	if(!C.get_bodypart(user.get_combat_bodyzone(src))) //can only start if limb is missing
		return TRUE
	return FALSE


/datum/surgery_step/add_prosthetic
	name = "add prosthetic"
	implements = list(
		/obj/item/bodypart = 100,
		/obj/item/organ_storage = 100,
		/obj/item/chainsaw = 100,
		/obj/item/melee/synthetic_arm_blade = 100
	)
	time = 32
	var/organ_rejection_dam = 0

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, span_notice("There is nothing inside [tool]!"))
			return -1
		var/obj/item/organ_storage_contents = tool.contents[1]
		if(!isbodypart(organ_storage_contents))
			to_chat(user, span_warning("[organ_storage_contents] cannot be attached!"))
			return -1
		tool = organ_storage_contents
	if(isbodypart(tool))
		var/obj/item/bodypart/bodypart_to_attach = tool
		if(IS_ORGANIC_LIMB(bodypart_to_attach))
			organ_rejection_dam = 10
			if(ishuman(target))
				var/mob/living/carbon/human/human_target = target
				var/obj/item/bodypart/chest/target_chest = human_target.get_bodypart(BODY_ZONE_CHEST)
				if(!(bodypart_to_attach.bodytype & target_chest.acceptable_bodytype))
					to_chat(user, span_warning("[bodypart_to_attach] doesn't match the patient's morphology."))
					return -1
				if(human_target.dna.species.id != bodypart_to_attach.limb_id)
					organ_rejection_dam = 30

			if(!bodypart_to_attach.can_attach_limb(target))
				target.balloon_alert(user, "that doesn't go on the [parse_zone(target_zone)]!")
				return -1

		if(target_zone == bodypart_to_attach.body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
			display_results(
				user,
				target,
				span_notice("You begin to replace [target]'s [parse_zone(target_zone)] with [tool]..."),
				span_notice("[user] begins to replace [target]'s [parse_zone(target_zone)] with [tool]."),
				span_notice("[user] begins to replace [target]'s [parse_zone(target_zone)]."),
			)
		else
			to_chat(user, span_warning("[tool] isn't the right type for [parse_zone(target_zone)]."))
			return -1
	else if(target_zone == BODY_ZONE_L_ARM || target_zone == BODY_ZONE_R_ARM)
		display_results(
			user,
			target,
			span_notice("You begin to attach [tool] onto [target]..."),
			span_notice("[user] begins to attach [tool] onto [target]'s [parse_zone(target_zone)]."),
			span_notice("[user] begins to attach something onto [target]'s [parse_zone(target_zone)]."),
		)
	else
		to_chat(user, span_warning("[tool] must be installed onto an arm."))
		return -1

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(istype(tool, /obj/item/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
		tool = tool.contents[1]
	if(istype(tool, /obj/item/bodypart) && user.temporarilyRemoveItemFromInventory(tool))
		var/obj/item/bodypart/L = tool
		L.try_attach_limb(target)
		if(organ_rejection_dam)
			target.adjustToxLoss(organ_rejection_dam)
		display_results(
			user,
			target,
			span_notice("You succeed in replacing [target]'s [parse_zone(target_zone)]."),
			span_notice("[user] successfully replaces [target]'s [parse_zone(target_zone)] with [tool]!"),
			span_notice("[user] successfully replaces [target]'s [parse_zone(target_zone)]!"),
		)
		target.cauterise_wounds()
		return
	else
		var/obj/item/bodypart/L = target.newBodyPart(target_zone, FALSE, FALSE)
		L.is_pseudopart = TRUE
		L.try_attach_limb(target)
		user.visible_message(span_notice("[user] finishes attaching [tool]!"), span_notice("You attach [tool]."))
		display_results(
			user,
			target,
			span_notice("You attach [tool]."),
			span_notice("[user] finishes attaching [tool]!"),
			span_notice("[user] finishes the attachment procedure!"),
		)
		qdel(tool)
		if(istype(tool, /obj/item/chainsaw/energy/doom))
			var/obj/item/mounted_chainsaw/super/new_arm = new(target)
			target_zone == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return
		else if(istype(tool, /obj/item/chainsaw/energy))
			var/obj/item/mounted_chainsaw/energy/new_arm = new(target)
			target_zone == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return
		else if(istype(tool, /obj/item/chainsaw))
			var/obj/item/mounted_chainsaw/normal/new_arm = new(target)
			target_zone == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return
		else if(istype(tool, /obj/item/melee/synthetic_arm_blade))
			var/obj/item/melee/arm_blade/new_arm = new(target,TRUE,TRUE)
			target_zone == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return
	return ..()
