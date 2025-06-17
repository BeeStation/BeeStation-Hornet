/obj/item/reagent_containers
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
	///Holder for the reagent flags
	var/reagent_flags
	///The reagents the container has
	var/list/list_reagents
	///The disease this container holds
	var/spawned_disease
	///The amount of the disease
	var/disease_amount = 20
	///Is this container spillable (by throwing, etc)
	var/spillable = FALSE
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
	if(isnum_safe(vol) && vol > 0)
		volume = vol
	create_reagents(volume, reagent_flags)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease()
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent(/datum/reagent/blood, disease_amount, data)
	if(!label_name)
		label_name = name
	add_initial_reagents()

/obj/item/reagent_containers/examine()
	. = ..()
	if(has_variable_transfer_amount)
		if(possible_transfer_amounts.len > 1)
			. += "<span class='notice'>Left-click or right-click in-hand to increase or decrease its transfer amount.</span>"
		else if(possible_transfer_amounts.len)
			. += "<span class='notice'>Left-click or right-click in-hand to view its transfer amount.</span>"

/obj/item/reagent_containers/attack(mob/living/target_mob, mob/living/user, params)
	if (!user.combat_mode)
		return
	return ..()

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/attack_self(mob/user)
	if(has_variable_transfer_amount)
		change_transfer_amount(user, FORWARD)

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

/obj/item/reagent_containers/pre_attack_secondary(atom/target, mob/living/user, params)
	if (try_splash(user, target))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/// Tries to splash the target. Used on both right-click and normal click when in combat mode.
/obj/item/reagent_containers/proc/try_splash(mob/user, atom/target)
	if (!spillable)
		return FALSE

	if (!reagents?.total_volume)
		return FALSE

	var/punctuation = ismob(target) ? "!" : "."

	var/reagent_text
	user.visible_message(
		span_danger("[user] splashes the contents of [src] onto [target][punctuation]"),
		span_danger("You splash the contents of [src] onto [target][punctuation]"),
		ignored_mobs = target,
	)

	if (ismob(target))
		var/mob/target_mob = target
		target_mob.show_message(
			span_userdanger("[user] splash the contents of [src] onto you!"),
			MSG_VISUAL,
			span_userdanger("You feel drenched!"),
		)

	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		reagent_text += "[reagent] ([num2text(reagent.volume)]),"

	var/mob/thrown_by = thrownby?.resolve()
	if(isturf(target) && reagents.reagent_list.len && thrown_by)
		log_combat(thrown_by, target, "splashed (thrown) [english_list(reagents.reagent_list)]")
		message_admins("[ADMIN_LOOKUPFLW(thrown_by)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] at [ADMIN_VERBOSEJMP(target)].")

	reagents.expose(target, TOUCH)
	log_combat(user, target, "splashed", reagent_text)
	reagents.clear_reagents()

	return TRUE

/obj/item/reagent_containers/proc/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	var/mob/living/carbon/C = eater
	var/covered = ""
	if(C.is_mouth_covered(head_only = 1))
		covered = "headgear"
	else if(C.is_mouth_covered(mask_only = 1))
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

/obj/item/reagent_containers/fire_act(exposed_temperature, exposed_volume)
	reagents.expose_temperature(exposed_temperature)
	return ..()

/obj/item/reagent_containers/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	SplashReagents(hit_atom, TRUE)

/obj/item/reagent_containers/proc/bartender_check(atom/target)
	. = FALSE
	var/mob/thrown_by = thrownby?.resolve()
	if(target.CanPass(src, get_dir(target, src)) && thrown_by && HAS_TRAIT(thrown_by, TRAIT_BOOZE_SLIDER))
		. = TRUE

/obj/item/reagent_containers/proc/SplashReagents(atom/target, thrown = FALSE, override_spillable = FALSE)
	if(!reagents || !reagents.total_volume || (!spillable && !override_spillable))
		return
	var/mob/thrown_by = thrownby?.resolve()

	if(ismob(target) && target.reagents)
		if(thrown)
			reagents.total_volume *= rand(5,10) * 0.1 //Not all of it makes contact with the target
		var/mob/M = target
		var/R
		target.visible_message(span_danger("[M] has been splashed with something!"), \
						span_userdanger("[M] has been splashed with something!"))
		for(var/datum/reagent/A in reagents.reagent_list)
			R += "[A.type]  ([num2text(A.volume)]),"

		if(thrownby)
			log_combat(thrown_by, M, "splashed", R)
		reagents.expose(target, TOUCH)

	else if(bartender_check(target) && thrown)
		visible_message(span_notice("[src] lands onto the [target.name] without spilling a single drop."))
		return

	else
		if(isturf(target) && length(reagents.reagent_list) && thrown_by)
			log_combat(thrown_by, target, "splashed (thrown) [english_list(reagents.reagent_list)]", "in [AREACOORD(target)]")
			log_game("[key_name(thrown_by)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [AREACOORD(target)].")
			message_admins("[ADMIN_LOOKUPFLW(thrown_by)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [ADMIN_VERBOSEJMP(target)].")
		visible_message(span_notice("[src] spills its contents all over [target]."))
		reagents.expose(target, TOUCH)
		if(QDELETED(src))
			return

	reagents.clear_reagents()

/obj/item/reagent_containers/microwave_act(obj/machinery/microwave/M)
	reagents.expose_temperature(1000)
	return ..()

/obj/item/reagent_containers/fire_act(temperature, volume)
	reagents.expose_temperature(temperature)

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

/obj/item/reagent_containers/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run = FALSE)
	// Always attempt to isolate diseases from reagent containers, if possible.
	. = ..()
	EXTRAPOLATOR_ACT_SET(., EXTRAPOLATOR_ACT_PRIORITY_ISOLATE)
	var/datum/reagent/blood/blood = reagents.get_reagent(/datum/reagent/blood)
	EXTRAPOLATOR_ACT_ADD_DISEASES(., blood?.get_diseases())
