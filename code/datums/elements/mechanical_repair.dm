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

	//can only do one progress bar at a time
	if(target in user.do_afters)
		to_chat(user, "<span class ='warning'>You're already trying to repair [target == user ? "you" : "[target]'s"] structural damage!</span>")
		return COMPONENT_NO_AFTERATTACK

	// Handles welder repairs on human limbs
	if(I.tool_behaviour == TOOL_WELDER)
		var/speed_mod = 1
		while(affecting.brute_dam > 0)
			if(I.use_tool(source, user, 0, volume=50, amount=1))
				if(user == target)
					user.visible_message("<span class='notice'>[user] starts to fix some of the dents on [target == user ? "[p_their()]" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>",
					"<span class='notice'>You start fixing some of the dents on [target == user ? "your" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>")
					if(!do_after(user, 1.5 SECONDS * speed_mod, target, show_to_target = TRUE, add_item = I))
						break
				item_heal_robotic(target, user, 15, 0, affecting)
				if(speed_mod > 0.2)
					speed_mod -= 0.1
			else
				break
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //antispam
		return COMPONENT_NO_AFTERATTACK

	// Handles cable repairs
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = I
		var/looping = TRUE
		var/speed_mod = 1
		while(looping)
			if(affecting.burn_dam <= 0)
				looping = FALSE
				user.changeNext_move(CLICK_CD_MELEE * 0.5) //antispam
				return COMPONENT_NO_AFTERATTACK
			if(user == target)
				user.visible_message("<span class='notice'>[user] starts to fix some of the burn wires in [target == user ? "[p_their()]" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>",
				"<span class='notice'>You start fixing some of the burnt wires in [target == user ? "your" : "[target]'s"] [parse_zone(affecting.body_zone)].</span>")
				if(!do_after(user, 1.5 SECONDS * speed_mod, target, show_to_target = TRUE, add_item = coil))
					looping = FALSE
					return COMPONENT_NO_AFTERATTACK
			if(coil.amount && item_heal_robotic(target, user, 0, 15, affecting))
				coil.use(1)
			if(speed_mod > 0.2)
				speed_mod -= 0.1
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //antispam
		return COMPONENT_NO_AFTERATTACK
