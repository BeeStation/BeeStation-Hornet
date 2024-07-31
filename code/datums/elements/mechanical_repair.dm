// Handles repairing mechanical limbs on humans
// Originally moved from cable coil/welder code

/datum/element/mechanical_repair
	element_flags = ELEMENT_DETACH

/datum/element/mechanical_repair/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(try_repair))

/datum/element/mechanical_repair/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_PARENT_ATTACKBY)

/datum/element/mechanical_repair/proc/try_repair(datum/source, obj/item/I, mob/user)
	var/mob/living/carbon/human/target = source

	if(!istype(I, /obj/item/stack/cable_coil) && I.tool_behaviour != TOOL_WELDER)
		return

	// Check to make sure we can repair
	if(user.a_intent == INTENT_HARM)
		return

	if(target in user.do_afters)
		return COMPONENT_NO_AFTERATTACK

	var/datum/task/fetch_selected_limb = user.select_bodyzone(target, style = BODYZONE_STYLE_MEDICAL)
	fetch_selected_limb.continue_with(CALLBACK(src, PROC_REF(complete_repairs), target, I, user))
	return COMPONENT_NO_AFTERATTACK

/datum/element/mechanical_repair/proc/complete_repairs(mob/living/carbon/human/target, obj/item/I, mob/user, selected_zone)
	if(target in user.do_afters || !user.can_interact_with(target, TRUE) || !user.can_interact_with(I, TRUE))
		return COMPONENT_NO_AFTERATTACK

	var/obj/item/bodypart/affecting = target.get_bodypart(check_zone(selected_zone))

	if (!affecting || (IS_ORGANIC_LIMB(affecting)))
		to_chat(user, "<span class='warning'>That limb is not robotic!.</span>")
		return

	// Handles welder repairs on human limbs
	if(I.tool_behaviour == TOOL_WELDER)
		do
			if(I.use_tool(target, user, 0, volume=50, amount=1))
				if(user == target)
					user.visible_message("<span class='notice'>[user] starts to fix some of the dents on [target == user ? "[p_their()]" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>",
					"<span class='notice'>You start fixing some of the dents on [target == user ? "your" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>")
					if(!do_after(user, 1.5 SECONDS, target))
						return COMPONENT_NO_AFTERATTACK
		while (item_heal_robotic(target, user, 15, 0, affecting) && user.is_zone_selected(selected_zone) && !QDELETED(I))
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //antispam
		return COMPONENT_NO_AFTERATTACK

	// Handles cable repairs
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = I
		do
			if(user == target)
				user.visible_message("<span class='notice'>[user] starts to fix some of the burn wires in [target == user ? "[p_their()]" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>",
				"<span class='notice'>You start fixing some of the burnt wires in [target == user ? "your" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>")
				if(!do_after(user, 1.5 SECONDS, target))
					return COMPONENT_NO_AFTERATTACK
		// Run checks to ensure that we can continue healing. We check coil twice, as we want to break out of the loop if we ran out of coil
		while (coil.amount && item_heal_robotic(target, user, 0, 15, affecting) && coil.use(1) && coil.amount && user.is_zone_selected(selected_zone) && !QDELETED(coil))
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //antispam
		return COMPONENT_NO_AFTERATTACK
