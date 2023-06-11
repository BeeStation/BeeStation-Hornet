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
	var/obj/item/bodypart/affecting = target.get_bodypart(check_zone(user.zone_selected))

	// Check to make sure we can repair
	if((!affecting || (IS_ORGANIC_LIMB(affecting))) || user.a_intent == INTENT_HARM)
		return

	if(target in user.do_afters)
		return COMPONENT_NO_AFTERATTACK

	// Handles welder repairs on human limbs
	if(I.tool_behaviour == TOOL_WELDER)
		if(I.use_tool(source, user, 0, volume=50, amount=1))
			if(user == target)
				user.visible_message("<span class='notice'>[user] starts to fix some of the dents on [target == user ? "[p_their()]" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>",
				"<span class='notice'>You start fixing some of the dents on [target == user ? "your" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>")
				if(!do_after(user, 1.5 SECONDS, target))
					return COMPONENT_NO_AFTERATTACK
			item_heal_robotic(target, user, 15, 0, affecting)
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //antispam
		return COMPONENT_NO_AFTERATTACK

	// Handles cable repairs
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = I
		if(user == target)
			user.visible_message("<span class='notice'>[user] starts to fix some of the burn wires in [target == user ? "[p_their()]" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>",
			"<span class='notice'>You start fixing some of the burnt wires in [target == user ? "your" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>")
			if(!do_after(user, 1.5 SECONDS, target))
				return COMPONENT_NO_AFTERATTACK
		if(coil.amount && item_heal_robotic(target, user, 0, 15, affecting))
			coil.use(1)
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //antispam
		return COMPONENT_NO_AFTERATTACK
