/**
  *
  * Allows parent (obj) to initiate surgeries.
  *
  */
/datum/component/surgery_initiator
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///allows for post-selection manipulation of parent
	var/datum/callback/after_select_cb

/datum/component/surgery_initiator/Initialize(_after_select_cb)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	after_select_cb = _after_select_cb

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/initiate_surgery_moment)

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)

/datum/component/surgery_initiator/Destroy()
	if(after_select_cb)
		QDEL_NULL(after_select_cb)
	return ..()

	/**
	  *
	  * Does the surgery initiation.
	  *
	  */
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	if(!isliving(target))
		return
	var/mob/living/livingtarget = target
	. = COMPONENT_ITEM_NO_ATTACK

	var/datum/surgery/current_surgery

	for(var/i_one in livingtarget.surgeries)
		var/datum/surgery/surgeryloop = i_one
		current_surgery = surgeryloop

	if(!current_surgery)
		var/datum/task/zone_selector = user.select_bodyzone(livingtarget, TRUE)
		zone_selector.continue_with(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(initiate_surgery_at_zone), I, livingtarget, user))

	else if(!current_surgery.step_in_progress)
		attempt_cancel_surgery(current_surgery, I, livingtarget, user)

	return 1

/datum/component/surgery_initiator/proc/initiate_surgery_at_zone(obj/item/I, mob/living/livingtarget, mob/user, target_zone)
	var/list/all_surgeries = GLOB.surgeries_list.Copy()
	var/list/available_surgeries = list()

	var/mob/living/carbon/carbontarget
	if (iscarbon(livingtarget))
		carbontarget = livingtarget

	var/obj/item/bodypart/affecting = livingtarget.get_bodypart(check_zone(target_zone))

	for(var/i_two in all_surgeries)
		var/datum/surgery/surgeryloop_two = i_two
		if(!surgeryloop_two.possible_locs.Find(target_zone))
			continue
		if(affecting)
			if(!surgeryloop_two.requires_bodypart)
				continue
			if(surgeryloop_two.requires_bodypart_type && !(affecting.bodytype & surgeryloop_two.requires_bodypart_type))
				continue
			if(surgeryloop_two.requires_real_bodypart && affecting.is_pseudopart)
				continue
		else if(carbontarget && surgeryloop_two.requires_bodypart) //mob with no limb in surgery zone when we need a limb
			continue
		if(surgeryloop_two.lying_required && (livingtarget.mobility_flags & MOBILITY_STAND))
			continue
		if(!surgeryloop_two.can_start(user, livingtarget))
			continue
		for(var/path in surgeryloop_two.target_mobtypes)
			if(istype(livingtarget, path))
				available_surgeries[surgeryloop_two.name] = surgeryloop_two
				break

	if(!available_surgeries.len)
		return

	var/pick_your_surgery = input("Begin which procedure?", "Surgery", null, null) as null|anything in sort_list(available_surgeries)
	if(pick_your_surgery && user?.Adjacent(livingtarget) && (I in user))
		var/datum/surgery/surgeryinstance_notonmob = available_surgeries[pick_your_surgery]

		for(var/i_three in livingtarget.surgeries)
			var/datum/surgery/surgeryloop_three = i_three
			if(surgeryloop_three.location == target_zone)
				return //during the input() another surgery was started at the same location.

		//we check that the surgery is still doable after the input() wait.
		if(carbontarget)
			affecting = carbontarget.get_bodypart(check_zone(target_zone))
		if(surgeryinstance_notonmob.requires_bodypart_type && !(affecting.bodytype & surgeryinstance_notonmob.requires_bodypart_type))
			return
		else if(carbontarget && surgeryinstance_notonmob.requires_bodypart)
			return
		if(surgeryinstance_notonmob.lying_required && (livingtarget.mobility_flags & MOBILITY_STAND))
			return
		if(!surgeryinstance_notonmob.can_start(user, livingtarget, target_zone))
			return

		if(surgeryinstance_notonmob.ignore_clothes || get_location_accessible(livingtarget, target_zone))
			var/datum/surgery/procedure = new surgeryinstance_notonmob.type(livingtarget, target_zone, affecting)
			user.visible_message("<span class='notice'>[user] drapes [parent] over [livingtarget]'s [parse_zone(target_zone)] to prepare for surgery.</span>", \
				"<span class='notice'>You drape [parent] over [livingtarget]'s [parse_zone(target_zone)] to prepare for \an [procedure.name].</span>")
			I.balloon_alert(user, "You drape over [parse_zone(target_zone)].")

			log_combat(user, livingtarget, "operated on", null, "(OPERATION TYPE: [procedure.name]) (TARGET AREA: [target_zone])")
			after_select_cb?.Invoke()
		else
			I.balloon_alert(user, "[parse_zone(target_zone)] is covered up!")

		/**
		  *
		  * Does the surgery de-initiation.
		  *
		  */
/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/the_surgery, obj/item/the_item, mob/living/the_patient, mob/user)
	if(the_surgery.status == 1)
		the_patient.surgeries -= the_surgery
		user.visible_message("<span class='notice'>[user] removes [the_item] from [the_patient]'s [parse_zone(the_surgery.location)].</span>", \
			"<span class='notice'>You remove [the_item] from [the_patient]'s [parse_zone(the_surgery.location)].</span>")
		the_item.balloon_alert(user, "You remove [the_item] from [parse_zone(the_surgery.location)].")
		qdel(the_surgery)
		return

	if(!the_surgery.can_cancel)
		return

	var/required_tool_type = TOOL_CAUTERY
	var/obj/item/close_tool = user.get_inactive_held_item()
	var/is_robotic = the_surgery.requires_bodypart_type == BODYTYPE_ROBOTIC

	if(is_robotic)
		required_tool_type = TOOL_SCREWDRIVER

	if(iscyborg(user))
		close_tool = locate(/obj/item/cautery) in user.held_items
		if(!close_tool)
			to_chat(user, "<span class='warning'>You need to equip a cautery in an inactive slot to stop [the_patient]'s surgery!</span>")
			return
	else if(!close_tool || close_tool.tool_behaviour != required_tool_type)
		to_chat(user, "<span class='warning'>You need to hold a [is_robotic ? "screwdriver" : "cautery"] in your inactive hand to stop [the_patient]'s surgery!</span>")
		return

	/*
	if(the_surgery.operated_bodypart)
		the_surgery.operated_bodypart.generic_bleedstacks -= 5
	*/

	the_patient.surgeries -= the_surgery
	user.visible_message("<span class='notice'>[user] closes [the_patient]'s [parse_zone(the_surgery.location)] with [close_tool] and removes [the_item].</span>", \
		"<span class='notice'>You close [the_patient]'s [parse_zone(the_surgery.location)] with [close_tool] and remove [the_item].</span>")
	qdel(the_surgery)
