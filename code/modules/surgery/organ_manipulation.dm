/datum/surgery/organ_manipulation
	name = "organ manipulation"
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_real_bodypart = 1
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs,
		//there should be bone fixing
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	self_operable = TRUE
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/alien
	name = "alien organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	target_mobtypes = list(/mob/living/carbon/alien/humanoid)
	steps = list(
		/datum/surgery_step/saw,
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/mechanic
	name = "prosthesis organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_bodypart_type = BODYPART_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE
	success_multiplier = 0.8 //on a surgery bed you can do prosthetic manipulation relatively risk-free
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery/organ_manipulation/mechanic/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery_step/manipulate_organs
	time = 64
	name = "manipulate organs"
	repeatable = 1
	implements = list(/obj/item/organ = 100, /obj/item/reagent_containers/food/snacks/organ = 0, /obj/item/organ_storage = 100)
	var/implements_extract = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 55)
	var/current_type
	var/obj/item/organ/I = null

/datum/surgery_step/manipulate_organs/New()
	..()
	implements = implements + implements_extract

/datum/surgery_step/manipulate_organs/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	I = null
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='notice'>There is nothing inside [tool]!</span>")
			return -1
		I = tool.contents[1]
		if(!isorgan(I))
			to_chat(user, "<span class='notice'>You cannot put [I] into [target]'s [parse_zone(target_zone)]!</span>")
			return -1
		tool = I
	if(isorgan(tool))
		current_type = "insert"
		I = tool
		if(target_zone != I.zone || target.getorganslot(I.slot))
			to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
			return -1
	if(istype(tool, /obj/item/organ/brain/positron))
		var/obj/item/bodypart/affected = target.get_bodypart(check_zone(target_zone))
		if(!affected)
			return -1
		if(affected.status != ORGAN_ROBOTIC)
			to_chat(user, "<span class='notice'>You can't put [tool] into a meat enclosure!</span>")
			return -1
		if(!isipc(target))
			to_chat(user, "<span class='notice'>[target] does not have the proper connectors to interface with [tool].</span>")
			return -1
		if(target_zone != "chest")
			to_chat(user, "<span class='notice'>You have to install [tool] in [target]'s chest!</span>")
		if(target.internal_organs_slot["brain"])
			to_chat(user, "<span class='notice'>[target] already has a brain! You'd rather not find out what would happen with two in there.</span>")
			return -1
		user.visible_message("<span class='notice'>[user] begins to insert [tool] into [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>You begin to insert [tool] into [target]'s [parse_zone(target_zone)]...</span>")

		display_results(user, target, "<span class='notice'>You begin to insert [tool] into [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to insert [tool] into [target]'s [parse_zone(target_zone)].",
			"[user] begins to insert something into [target]'s [parse_zone(target_zone)].")

	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/organs = target.getorganszone(target_zone)
		if(!organs.len)
			to_chat(user, "<span class='notice'>There are no removable organs in [target]'s [parse_zone(target_zone)]!</span>")
			return -1
		else
			for(var/obj/item/organ/O in organs)
				O.on_find(user)
				organs -= O
				organs[O.name] = O

			I = input("Remove which organ?", "Surgery", null, null) as null|anything in sortList(organs)
			if(I && user && target && user.Adjacent(target) && user.get_active_held_item() == tool)
				I = organs[I]
				if(!I)
					return -1
				display_results(user, target, "<span class='notice'>You begin to extract [I] from [target]'s [parse_zone(target_zone)]...</span>",
					"[user] begins to extract [I] from [target]'s [parse_zone(target_zone)].",
					"[user] begins to extract something from [target]'s [parse_zone(target_zone)].")
			else
				return -1

	else if(istype(tool, /obj/item/reagent_containers/food/snacks/organ))
		to_chat(user, "<span class='warning'>[tool] was bitten by someone! It's too damaged to use!</span>")
		return -1

/datum/surgery_step/manipulate_organs/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(current_type == "insert")
		if(istype(tool, /obj/item/organ_storage))
			I = tool.contents[1]
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = I
		else
			I = tool
		user.temporarilyRemoveItemFromInventory(I, TRUE)
		I.Insert(target)
		display_results(user, target, "<span class='notice'>You insert [tool] into [target]'s [parse_zone(target_zone)].</span>",
			"[user] inserts [tool] into [target]'s [parse_zone(target_zone)]!",
			"[user] inserts something into [target]'s [parse_zone(target_zone)]!")

	else if(current_type == "extract")
		if(I && I.owner == target)
			display_results(user, target, "<span class='notice'>You successfully extract [I] from [target]'s [parse_zone(target_zone)].</span>",
				"[user] successfully extracts [I] from [target]'s [parse_zone(target_zone)]!",
				"[user] successfully extracts something from [target]'s [parse_zone(target_zone)]!")
			log_combat(user, target, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
			I.Remove(target)
			I.forceMove(get_turf(target))
		else
			display_results(user, target, "<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>",
				"[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
				"[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!")
	return 0
