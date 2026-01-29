/obj/item/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	inhand_icon_state = "mousetrap"
	custom_materials = list(/datum/material/iron=100)
	attachable = TRUE
	var/armed = FALSE
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	var/obj/item/host = null
	var/turf/host_turf = null

/obj/item/assembly/mousetrap/Initialize(mapload)
	. = ..()
	update_host(force = TRUE)

/obj/item/assembly/mousetrap/examine(mob/user)
	. = ..()
	. += span_notice("The pressure plate is [armed?"primed":"safe"].")

/obj/item/assembly/mousetrap/proc/update_host(force = FALSE)
	var/obj/item/newhost
	// Pick the first valid object in this list:
	// Wiring datum's owner
	// assembly holder's attached object
	// assembly holder itself
	// us
	newhost = connected?.holder || holder?.master || holder || src
	//only trigger step-on mode if the host is an item
	if(!istype(newhost,/obj/item))
		if(host)
			UnregisterSignal(host,COMSIG_MOVABLE_MOVED)
			host = src
		if(isturf(host_turf))
			UnregisterSignal(host_turf,COMSIG_ATOM_ENTERED)
			host_turf = null
		return

	// If host changed
	if((newhost != host) || force)
		if(host)
			UnregisterSignal(host,COMSIG_MOVABLE_MOVED)
		host = newhost
		RegisterSignal(host,COMSIG_MOVABLE_MOVED, PROC_REF(holder_movement))

	// If host moved
	if((host_turf != host.loc) || force)
		if(isturf(host_turf))
			UnregisterSignal(host_turf,COMSIG_ATOM_ENTERED)
			host_turf = null
		if(isturf(host.loc))
			host_turf = host.loc
			RegisterSignal(host_turf,COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
		else
			host_turf = null

/obj/item/assembly/mousetrap/holder_movement()
	. = ..()
	update_host()

/obj/item/assembly/mousetrap/activate()
	if(..())
		armed = !armed
		if(!armed)
			if(ishuman(usr))
				var/mob/living/carbon/human/user = usr
				if((HAS_TRAIT(user, TRAIT_DUMB) || HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
					to_chat(user, span_warning("Your hand slips, setting off the trigger!"))
					pulse(FALSE)
		update_icon()
		playsound(src, 'sound/weapons/handcuffs.ogg', 30, TRUE, -3)

/obj/item/assembly/mousetrap/update_icon()
	icon_state = "mousetrap[armed ? "armed" : ""]"
	if(holder)
		holder.update_icon()

/obj/item/assembly/mousetrap/on_attach()
	. = ..()
	update_host()

/obj/item/assembly/mousetrap/on_detach()
	. = ..()
	update_host()

/obj/item/assembly/mousetrap/proc/triggered(mob/target, type = "feet")
	if(!armed)
		return
	armed = FALSE  // moved to the top because you could trigger it more than once under some circumstances
	update_icon()
	var/obj/item/bodypart/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
			pulse(FALSE)
			return FALSE
		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.get_bodypart(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
					H.Paralyze(60)
				else
					to_chat(H, "<span notice='warning'>Your [H.shoes] protects you from [src].")
			if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
				if(!H.gloves)
					affecting = H.get_bodypart(type)
					H.Stun(60)
				else
					to_chat(H, "<span notice='warning'>Your [H.gloves] protects you from [src].")
		if(affecting)
			if(affecting.receive_damage(1, 0))
				H.update_damage_overlays()
	else if(ismouse(target))
		var/mob/living/basic/mouse/M = target
		visible_message(span_boldannounce("SPLAT!"))
		M.splat()
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	pulse(FALSE)

/**
 * clumsy_check: Sets off the mousetrap if handled by a clown (with some probability)
 *
 * Arguments:
 * * user: The mob handling the trap
 */
/obj/item/assembly/mousetrap/proc/clumsy_check(mob/living/carbon/human/user)
	if(!armed)
		return FALSE
	if((HAS_TRAIT(user, TRAIT_DUMB) || HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		var/which_hand = BODY_ZONE_PRECISE_L_HAND
		if(!(user.active_hand_index % 2))
			which_hand = BODY_ZONE_PRECISE_R_HAND
		triggered(user, which_hand)
		user.visible_message(("<span notice='warning'>[user] accidentally sets off [src], breaking their fingers."), \
			("<span notice='warning'>You accidentally trigger [src]!"))
		return TRUE
	return FALSE

/obj/item/assembly/mousetrap/attack_self(mob/living/carbon/human/user)
	if(!armed)
		to_chat(user, span_notice("You arm [src]."))
	else
		if((HAS_TRAIT(user, TRAIT_DUMB) || HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
			var/which_hand = BODY_ZONE_PRECISE_L_HAND
			if(!(user.active_hand_index % 2))
				which_hand = BODY_ZONE_PRECISE_R_HAND
			triggered(user, which_hand)
			user.visible_message(span_warning("[user] accidentally sets off [src], breaking their fingers."), \
								span_warning("You accidentally trigger [src]!"))
			return
		to_chat(user, span_notice("You disarm [src]."))
	armed = !armed
	update_icon()
	playsound(src, 'sound/weapons/handcuffs.ogg', 30, TRUE, -3)


//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/assembly/mousetrap/attack_hand(mob/living/carbon/human/user)
	if(armed)
		if((HAS_TRAIT(user, TRAIT_DUMB) || HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
			var/which_hand = BODY_ZONE_PRECISE_L_HAND
			if(!(user.active_hand_index % 2))
				which_hand = BODY_ZONE_PRECISE_R_HAND
			triggered(user, which_hand)
			user.visible_message(span_warning("[user] accidentally sets off [src], breaking their fingers."), \
								span_warning("You accidentally trigger [src]!"))
			return
	return ..()


/obj/item/assembly/mousetrap/proc/on_entered(datum/source, atom/movable/AM as mob|obj)
	SIGNAL_HANDLER
	if(armed)
		if(ismob(AM))
			var/mob/MM = AM
			if(!(MM.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
				if(ishuman(AM))
					var/mob/living/carbon/H = AM
					if(H.m_intent == MOVE_INTENT_RUN)
						INVOKE_ASYNC(src, PROC_REF(triggered), H)
						H.visible_message(span_warning("[H] accidentally steps on [src]."), \
											span_warning("You accidentally step on [src]"))
				else if(ismouse(MM))
					INVOKE_ASYNC(src, PROC_REF(triggered), MM)
		else if(AM.density) // For mousetrap grenades, set off by anything heavy
			INVOKE_ASYNC(src, PROC_REF(triggered), AM)

/obj/item/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		if(finder)
			finder.visible_message(span_warning("[finder] accidentally sets off [src], breaking their fingers."), \
							   span_warning("You accidentally trigger [src]!"))
			triggered(finder, (finder.active_hand_index % 2 == 0) ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND)
			return TRUE	//end the search!
		else
			visible_message(span_warning("[src] snaps shut!"))
			triggered(loc)
			return FALSE
	return FALSE


/obj/item/assembly/mousetrap/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(!armed)
		return ..()
	visible_message(span_warning("[src] is triggered by [AM]."))
	triggered(null)

/obj/item/assembly/mousetrap/Destroy()
	if(host)
		UnregisterSignal(host,COMSIG_MOVABLE_MOVED)
		host = null
	if(isturf(host_turf))
		UnregisterSignal(host_turf,COMSIG_ATOM_ENTERED)
		host_turf = null
	return ..()

/obj/item/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = TRUE
