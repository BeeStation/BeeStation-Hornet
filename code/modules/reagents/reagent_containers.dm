/obj/item/reagent_containers
	abstract_type = /obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = ISWEAPON
	/// this is to support when you don't want to display "bottle" part with a custom name. i.e.) "Bica-Kelo mix" rather than "Bica-Kelo mix bottle"
	var/label_name
	/// The maximum amount of reagents per transfer that will be moved out of this reagent container.
	var/amount_per_transfer_from_this = 5
	/// Does this container allow changing transfer amounts at all, the container can still have only one possible transfer value in possible_transfer_amounts at some point even if this is true
	var/has_variable_transfer_amount = TRUE
	///Possible amounts of units transfered a click
	var/list/possible_transfer_amounts = list(5,10,15,20,25,30)
	///The amount of reagents this can hold
	var/volume = 30
	/// The base reagent flags that our reagent datum takes on when created
	var/initial_reagent_flags = NONE
	///The reagents the container has
	var/list/list_reagents
	///The disease this container holds
	var/spawned_disease
	///The amount of the disease
	var/disease_amount = 20
	/**
	 * The different thresholds at which the reagent fill overlay will change. See reagentfillings.dmi.
	 *
	 * Should be a list of integers which correspond to a reagent unit threshold.
	 * If null, no automatic fill overlays are generated.
	 *
	 * For example, list(0) will mean it will gain a the overlay with any reagents present. This overlay is "overlayname0".
	 * list(0, 10) whill have two overlay options, for 0-10 units ("overlayname0") and 10+ units ("overlayname10").
	 */
	var/list/fill_icon_thresholds
	///Optional custom name for reagent fill icon_state prefix
	var/fill_icon_state
	///Icon for the "label", if the holder was renamed
	var/label_icon
	///Does this container prevent grinding?
	var/prevent_grinding = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/reagent_containers)

/obj/item/reagent_containers/Initialize(mapload, vol)
	. = ..()
	if(isnum(vol) && vol > 0)
		volume = vol
	if(!force)
		item_flags |= NOBLUDGEON
	create_reagents(volume, initial_reagent_flags)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease()
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent(/datum/reagent/blood, disease_amount, data)
	if(!label_name)
		label_name = name
	add_initial_reagents()
	AddElement(/datum/element/reagents_exposed_on_fire)

/obj/item/reagent_containers/examine()
	. = ..()
	if(has_variable_transfer_amount)
		if(possible_transfer_amounts.len > 1)
			. += span_notice("Left-click or right-click in-hand to increase or decrease its transfer amount.")
		else if(possible_transfer_amounts.len)
			. += span_notice("Left-click or right-click in-hand to view its transfer amount.")

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/attack_self(mob/user, list/modifiers)
	if(reagents.flags & SEALED_CONTAINER)
		return TRUE
	if(has_variable_transfer_amount)
		change_transfer_amount(user, FORWARD)
		return TRUE

/obj/item/reagent_containers/attack_self_secondary(mob/user)
	if(has_variable_transfer_amount)
		change_transfer_amount(user, BACKWARD)

/obj/item/reagent_containers/proc/mode_change_message(mob/user)
	return

/obj/item/reagent_containers/proc/change_transfer_amount(mob/user, direction = FORWARD)
	var/list_len = length(possible_transfer_amounts)
	if(!list_len)
		return
	var/index = possible_transfer_amounts.Find(amount_per_transfer_from_this) || 1
	switch(direction)
		if(FORWARD)
			index = (index % list_len) + 1
		if(BACKWARD)
			index = (index - 1) || list_len
		else
			CRASH("change_transfer_amount() called with invalid direction value")
	amount_per_transfer_from_this = possible_transfer_amounts[index]
	balloon_alert(user, "transferring [amount_per_transfer_from_this]u")
	mode_change_message(user)

/obj/item/reagent_containers/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!user.combat_mode)
		return NONE // non-combat-mode-rmb allows for stuff like opening containers or attacking (bottle breaking)
	if(try_splash(user, interacting_with))
		return ITEM_INTERACT_SUCCESS
	return NONE

/// Tries to splash the target, called when right-clicking with a reagent container.
/obj/item/reagent_containers/proc/try_splash(mob/user, atom/target)
	if (!is_open_container() || (reagents.flags & NO_SPLASH))
		return FALSE

	if (!reagents?.total_volume)
		return FALSE

	var/punctuation = ismob(target) ? "!" : "."

	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(
		span_danger("[user] splashes the contents of [src] onto [target][punctuation]"),
		span_danger("You splash the contents of [src] onto [target][punctuation]"),
		ignored_mobs = target,
	)

	if (ismob(target))
		var/mob/target_mob = target
		target_mob.show_message(
			span_userdanger("[user] splashes the contents of [src] onto you!"),
			MSG_VISUAL,
			span_userdanger("You feel drenched!"),
		)

	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)

	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash")
	if(isturf(target))
		splash_animation.icon_state = "splash_floor"
	splash_animation.color = mix_color_from_reagents(reagents.reagent_list)
	target.flick_overlay_view(splash_animation, 1 SECONDS)

	reagents.expose(target, TOUCH)
	log_combat(user, target, "splashed", reagents.get_reagent_log_string())
	reagents.clear_reagents()

	return TRUE

/obj/item/reagent_containers/proc/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	if(!reagents?.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return FALSE
	var/mob/living/carbon/C = eater
	var/covered = ""
	if(C.is_mouth_covered(ITEM_SLOT_HEAD))
		covered = "headgear"
	else if(C.is_mouth_covered(ITEM_SLOT_MASK))
		covered = "mask"
	if(covered)
		var/who = (isnull(user) || eater == user) ? "your" : "[eater.p_their()]"
		balloon_alert(user, "Remove [who] [covered] first!")
		return FALSE
	if(!eater.has_mouth())
		if(eater == user)
			balloon_alert(eater, "You have no mouth!")
		else
			balloon_alert(user, "[eater] has no mouth!")
		return FALSE
	return TRUE

/// Sets reagent flags to the passed flags outright
/obj/item/reagent_containers/proc/update_container_flags(new_flags)
	reagents.flags = new_flags

/// Adds the passed flags to the current reagent flags
/obj/item/reagent_containers/proc/add_container_flags(new_flags)
	reagents.flags |= new_flags

/// Resets to base flags
/obj/item/reagent_containers/proc/reset_container_flags()
	reagents.flags = initial_reagent_flags

/obj/item/reagent_containers/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	splash_reagents(hit_atom, throwingdatum?.get_thrower(), was_thrown = TRUE, allow_closed_splash = FALSE)

/obj/item/reagent_containers/proc/bartender_check(atom/target)
	. = FALSE
	var/mob/thrown_by = thrownby?.resolve()
	if(target.CanPass(src, get_dir(target, src)) && thrown_by && HAS_TRAIT(thrown_by, TRAIT_BOOZE_SLIDER))
		. = TRUE

/**
 * Attempts to splash the reagents in the container onto the target.
 *
 * * target - The target to splash the reagents onto.
 * * throwingdatum - The throwingdatum behind the throw if the
 */
/obj/item/reagent_containers/proc/splash_reagents(atom/target, mob/splasher, was_thrown = FALSE, allow_closed_splash = FALSE)
	if(!reagents || !reagents.total_volume || (!is_open_container() && !allow_closed_splash) || (reagents.flags & NO_SPLASH))
		return

	if(ismob(target) && target.reagents)
		var/splash_multiplier = 1
		if(was_thrown)
			splash_multiplier *= (rand(5,10) * 0.1) //Not all of it makes contact with the target
		var/turf_splash_multiplier = 1 - splash_multiplier
		var/mob/M = target
		var/turf/target_turf = get_turf(target)
		target.visible_message(
			span_danger("[M] is splashed with something!"),
			span_userdanger("[M] is splashed with something!"),
		)
		if(splasher)
			log_combat(splasher, M, "splashed", src, "containing [reagents.get_reagent_log_string()] [was_thrown ? "(thrown)" : ""]")
		reagents.expose(target, TOUCH, splash_multiplier)
		if(turf_splash_multiplier > 0)
			reagents.expose(target_turf, TOUCH, turf_splash_multiplier) // 1 - splash_multiplier because it's what didn't hit the target

	else if(bartender_check(target, splasher) && was_thrown)
		visible_message(span_notice("[src] lands onto \the [target] without spilling a single drop."))
		return

	else
		if(isturf(target) && length(reagents.reagent_list) && splasher)
			log_combat(splasher, target, "splashed [english_list(reagents.reagent_list)]", src, "in [AREACOORD(target)] [was_thrown ? "(thrown)" : ""]")
			message_admins("[ADMIN_LOOKUPFLW(splasher)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [ADMIN_VERBOSEJMP(target)].")
		visible_message(span_notice("[src] spills its contents all over [target]."))
		reagents.expose(target, TOUCH)
		if(QDELETED(src))
			return

	playsound(target, 'sound/effects/slosh.ogg', 25, TRUE)

	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash")
	if(isturf(target))
		splash_animation.icon_state = "splash_floor"
	splash_animation.color = mix_color_from_reagents(reagents.reagent_list)
	target.flick_overlay_view(splash_animation, 1 SECONDS)

	reagents.clear_reagents()

/obj/item/reagent_containers/on_reagent_change(changetype)
	update_appearance()

/obj/item/reagent_containers/update_overlays()
	. = ..()
	if(!fill_icon_thresholds)
		return

	if(!reagents.total_volume)
		if(label_icon && (name != initial(name) || desc != initial(desc)))
			var/mutable_appearance/label = mutable_appearance('icons/obj/chemical.dmi', "[label_icon]")
			. += label
		return
	var/fill_name = fill_icon_state ? fill_icon_state : icon_state
	var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[fill_name][fill_icon_thresholds[1]]")

	var/percent = round((reagents.total_volume / volume) * 100)
	for(var/i in 1 to length(fill_icon_thresholds))
		var/threshold = fill_icon_thresholds[i]
		var/threshold_end = (i == length(fill_icon_thresholds)) ? INFINITY : fill_icon_thresholds[i+1]
		if(threshold <= percent && percent < threshold_end)
			filling.icon_state = "[fill_name][fill_icon_thresholds[i]]"

	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling
	if(label_icon && (name != initial(name) || desc != initial(desc)))
		var/mutable_appearance/label = mutable_appearance('icons/obj/chemical.dmi', "[label_icon]")
		. += label

/obj/item/reagent_containers/proc/try_refill(atom/target, mob/living/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return ITEM_INTERACT_BLOCKING

	if(target.reagents.holder_full())
		to_chat(user, span_warning("[target] is full."))
		return ITEM_INTERACT_BLOCKING

	var/trans = round(reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user), CHEMICAL_VOLUME_ROUNDING)
	playsound(target.loc, "liquid_pour", 50, TRUE)
	if(trans)
		to_chat(user, span_notice("You transfer [trans] unit\s of the solution to [target]."))
	target.update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/proc/try_drain(atom/target, mob/living/user)
	if(!target.reagents.total_volume)
		to_chat(user, span_warning("[target] is empty and can't be refilled!"))
		return ITEM_INTERACT_BLOCKING

	if(reagents.holder_full())
		to_chat(user, span_warning("[src] is full."))
		return ITEM_INTERACT_BLOCKING

	var/trans = round(target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user), CHEMICAL_VOLUME_ROUNDING)
	playsound(target.loc, "liquid_pour", 50, TRUE)
	to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [target]."))
	target.update_appearance()
	return ITEM_INTERACT_SUCCESS
