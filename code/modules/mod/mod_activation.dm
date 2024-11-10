#define MOD_ACTIVATION_STEP_FLAGS IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED/*|IGNORE_SLOWDOWNS*/

/// Creates a radial menu from which the user chooses parts of the suit to deploy/retract. Repeats until all parts are extended or retracted.
/obj/item/mod/control/proc/choose_deploy(mob/user)
	if(!length(mod_parts))
		return
	var/list/display_names = list()
	var/list/items = list()
	var/list/parts = get_parts()
	for(var/obj/item/part as anything in parts)
		display_names[part.name] = REF(part)
		var/image/part_image = image(icon = part.icon, icon_state = part.icon_state)
		if(part.loc != src)
			part_image.underlays += image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "module_active")
		items += list(part.name = part_image)
	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/part_reference = display_names[pick]
	var/obj/item/part = locate(part_reference) in parts
	if(!istype(part) || user.incapacitated())
		return
	if(activating)
		balloon_alert(user, "currently [active ? "unsealing" : "sealing"]!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	var/parts_to_check = parts - part
	if(part.loc == src)
		deploy(user, part)
		if(active && !delayed_seal_part(part))
			return
		SEND_SIGNAL(src, COMSIG_MOD_DEPLOYED, user)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc != src)
				continue
			choose_deploy(user)
			break
	else
		if(active && !delayed_seal_part(part))
			return
		retract(user, part)
		SEND_SIGNAL(src, COMSIG_MOD_RETRACTED, user)
		for(var/obj/item/checking_part as anything in parts_to_check)
			if(checking_part.loc == src)
				continue
			choose_deploy(user)
			break

/// Quickly deploys all parts (or retracts if all are on the wearer)
/obj/item/mod/control/proc/quick_deploy(mob/user)
	if(activating)
		balloon_alert(user, "currently sealing/unsealing!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	var/deploy = TRUE
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		deploy = FALSE
		break
	for(var/obj/item/part as anything in get_parts())
		if(deploy && part.loc == src)
			deploy(null, part)
			if(active && !delayed_seal_part(part))
				return
		else if(!deploy && part.loc != src)
			if(active && !delayed_seal_part(part))
				return
	wearer.visible_message("<span class='notice'>[wearer]'s [src] [deploy ? "deploys" : "retracts"] its parts with a mechanical hiss.</span>",
		"<span class='notice'>[src] [deploy ? "deploys" : "retracts"] its parts with a mechanical hiss.</span>",
		"<span class='hear'>You hear a mechanical hiss.</span>")
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(deploy)
		SEND_SIGNAL(src, COMSIG_MOD_DEPLOYED, user)
	else
		SEND_SIGNAL(src, COMSIG_MOD_RETRACTED, user)
	return TRUE

/// Deploys a part of the suit onto the user.
/obj/item/mod/control/proc/deploy(mob/user, obj/item/part)
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(part.loc != src)
		if(!user)
			return FALSE
		balloon_alert(user, "[part.name] already deployed!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	if(part_datum.can_overslot)
		var/obj/item/overslot = wearer.get_item_by_slot(part.slot_flags)
		if(overslot)
			part_datum.overslotting = overslot
			wearer.transferItemToLoc(overslot, part, force = TRUE)
			RegisterSignal(part, COMSIG_ATOM_EXITED, PROC_REF(on_overslot_exit))
	if(wearer.equip_to_slot_if_possible(part, part.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		ADD_TRAIT(part, TRAIT_NODROP, MOD_TRAIT)
		if(!user)
			return TRUE
		wearer.visible_message("<span class='notice'>[wearer]'s [part.name] deploy[part.p_s()] with a mechanical hiss.</span>",
			"<span class='notice'>[part] deploy[part.p_s()] with a mechanical hiss.</span>",
			"<span class='hear'>You hear a mechanical hiss.</span>")
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		SEND_SIGNAL(src, COMSIG_MOD_PART_DEPLOYED, user, part)
		return TRUE
	else
		if(!user)
			return FALSE
		balloon_alert(user, "bodypart clothed!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/// Retract a part of the suit from the user.
/obj/item/mod/control/proc/retract(mob/user, obj/item/part)
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(part.loc == src)
		if(!user)
			return FALSE
		balloon_alert(user, "[part.name] already retracted!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	REMOVE_TRAIT(part, TRAIT_NODROP, MOD_TRAIT)
	wearer.transferItemToLoc(part, src, force = TRUE)
	if(part_datum.overslotting)
		UnregisterSignal(part, COMSIG_ATOM_EXITED)
		var/obj/item/overslot = part_datum.overslotting
		if(!QDELING(wearer) && !wearer.equip_to_slot_if_possible(overslot, overslot.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
			wearer.dropItemToGround(overslot, force = TRUE, silent = TRUE)
		part_datum.overslotting = null
	SEND_SIGNAL(src, COMSIG_MOD_PART_RETRACTED, user, part)
	if(!user)
		return
	wearer.visible_message("<span class='notice'>[wearer.name]'s [part] retract[part.p_s()] back into [src] with a mechanical hiss.",
		"<span class='notice'>[part] retract[part.p_s()] back into [src] with a mechanical hiss.",
		"<span class='hear'>You hear a mechanical hiss.</span>")
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/// Starts the activation sequence, where parts of the suit activate one by one until the whole suit is on
/obj/item/mod/control/proc/toggle_activate(mob/user, force_deactivate = FALSE)
	if(!wearer)
		if(!force_deactivate)
			balloon_alert(user, "equip suit first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!force_deactivate && (SEND_SIGNAL(src, COMSIG_MOD_ACTIVATE, user) & MOD_CANCEL_ACTIVATE))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(locked && !active && !allowed(user) && !force_deactivate)
		balloon_alert(user, "access insufficient!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!get_charge() && !force_deactivate)
		balloon_alert(user, "suit not powered!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(open && !force_deactivate)
		balloon_alert(user, "close the suit panel!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(activating)
		if(!force_deactivate)
			balloon_alert(user, "suit already [active ? "shutting down" : "starting up"]!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	for(var/obj/item/mod/module/module as anything in modules)
		if(!module.active || (module.allow_flags & MODULE_ALLOW_INACTIVE))
			continue
		module.deactivate(display_message = FALSE)
	activating = TRUE
	//mod_link.end_call()
	to_chat(wearer, "<span class='notice'>MODsuit [active ? "shutting down" : "starting up"].</span>")
	//deploy the control unit
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(get_wearer)), hidden = TRUE))
		playsound(src, active ? 'sound/machines/synth_no.ogg' : 'sound/machines/synth_yes.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 8000)
	else
		activating = FALSE
		return

	for(var/obj/item/part as anything in get_parts()) //seals/unseals all deployed parts
		if(part.loc == src)
			continue
		delayed_seal_part(part, no_activation = TRUE)

	//finish activation
	to_chat(wearer, "<span class='notice'>Systems [active ? "shut down. Parts unsealed. Goodbye" : "started up. Parts sealed. Welcome"], [wearer].</span>")
	if(ai)
		to_chat(ai, "<span class='notice'><b>SYSTEMS [active ? "DEACTIVATED. GOODBYE" : "ACTIVATED. WELCOME"]: \"[ai]\"</b></span>")
	finish_activation(is_on = !active)
	if(active)
		playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)
		if(!malfunctioning)
			wearer.playsound_local(get_turf(src), 'sound/mecha/nominal.ogg', 50)
	else
		playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 6000)

	activating = FALSE
	SEND_SIGNAL(src, COMSIG_MOD_TOGGLED, user)
	return TRUE

/obj/item/mod/control/proc/delayed_seal_part(obj/item/clothing/part, no_activation = FALSE)
	. = FALSE
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(do_after(wearer, activation_step_time, wearer, MOD_ACTIVATION_STEP_FLAGS, extra_checks = CALLBACK(src, PROC_REF(get_wearer)), hidden = TRUE))
		to_chat(wearer, "<span class='notice'>[part] [!part_datum.sealed ? part_datum.sealed_message : part_datum.unsealed_message].</span>")
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		seal_part(part, is_sealed = !part_datum.sealed, no_activation = no_activation)
		return TRUE

///Seals or unseals the given part
///Seals or unseals the given part.
/obj/item/mod/control/proc/seal_part(obj/item/clothing/part, is_sealed, no_activation = FALSE)
	var/datum/mod_part/part_datum = get_part_datum(part)
	part_datum.sealed = is_sealed
	if(part_datum.sealed)
		part.icon_state = "[skin]-[part.base_icon_state]-sealed"
		part.clothing_flags |= part.visor_flags
		part.flags_inv |= part.visor_flags_inv
		part.flags_cover |= part.visor_flags_cover
		part.heat_protection = initial(part.heat_protection)
		part.cold_protection = initial(part.cold_protection)
		part.alternate_worn_layer = part_datum.sealed_layer
	else
		part.icon_state = "[skin]-[part.base_icon_state]"
		part.flags_cover &= ~part.visor_flags_cover
		part.flags_inv &= ~part.visor_flags_inv
		part.clothing_flags &= ~part.visor_flags
		part.heat_protection = NONE
		part.cold_protection = NONE
		part.alternate_worn_layer = mod_parts[part]
	wearer.update_clothing(part.slot_flags)
	wearer.update_obscured_slots(part.visor_flags_inv)
	if((part.clothing_flags & (MASKINTERNALS|HEADINTERNALS)) && wearer.invalid_internals())
		wearer.cutoff_internals()
	if(!active || no_activation)
		return
	// these only matter during sealing and unsealing while active via deployment
	if(is_sealed)
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.has_required_parts(list("[part.slot_flags]" = part_datum), need_extended = TRUE))
				continue
			module.on_suit_activation()
	else
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.has_required_parts(list("[part.slot_flags]" = part_datum), need_extended = TRUE))
				continue
			module.on_suit_deactivation()
			if(!module.active || (module.allow_flags & MODULE_ALLOW_INACTIVE))
				continue
			module.deactivate(display_message = FALSE)

/// Finishes the suit's activation
/obj/item/mod/control/proc/finish_activation(is_on)
	var/datum/mod_part/part_datum = get_part_datum(src)
	part_datum.sealed = is_on
	active = is_on
	if(active)
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.has_required_parts(mod_parts, need_extended = TRUE))
				continue
			module.on_suit_activation()
		START_PROCESSING(SSobj, src)
	else
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.has_required_parts(mod_parts, need_extended = TRUE)) //it probably will runtime if we dont do this
				continue
			module.on_suit_deactivation()
		STOP_PROCESSING(SSobj, src)
	update_speed()
	update_icon_state()
	wearer.update_clothing(slot_flags)

/// Quickly deploys all the suit parts and if successful, seals them and turns on the suit. Intended mostly for outfits.
/obj/item/mod/control/proc/quick_activation()
	var/seal = TRUE
	for(var/obj/item/part as anything in get_parts())
		if(!deploy(null, part))
			seal = FALSE
	if(!seal)
		return
	for(var/obj/item/part as anything in get_parts())
		seal_part(part, is_sealed = TRUE)
	finish_activation(is_on = TRUE)

#undef MOD_ACTIVATION_STEP_FLAGS
