/obj/item/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = ISWEAPON
	/// this is to support when you don't want to display "bottle" part with a custom name. i.e.) "Bica-Kelo mix" rather than "Bica-Kelo mix bottle"
	var/label_name
	///How many units are we currently transferring?
	var/amount_per_transfer_from_this = 5
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
	///The tresholds at which we change the icon (used to display fullness of the container)
	var/list/fill_icon_thresholds
	///Optional custom name for reagent fill icon_state prefix
	var/fill_icon_state
	///Icon for the "label", if the holder was renamed
	var/label_icon
	///Does this container prevent grinding?
	var/prevent_grinding = FALSE

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

/obj/item/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/reagent_containers/attack_self(mob/user)
	if(length(possible_transfer_amounts))
		var/i = 0
		for(var/A in possible_transfer_amounts)
			i++
			if(A == amount_per_transfer_from_this)
				if(i < length(possible_transfer_amounts))
					amount_per_transfer_from_this = possible_transfer_amounts[i + 1]
				else
					amount_per_transfer_from_this = possible_transfer_amounts[1]
				balloon_alert(user, "Transferring [amount_per_transfer_from_this]u.")
				return

/obj/item/reagent_containers/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		return ..()

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

/obj/item/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		return ..()

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

/obj/item/reagent_containers/proc/SplashReagents(atom/target, thrown = FALSE)
	if(!reagents || !reagents.total_volume || !spillable)
		return
	var/mob/thrown_by = thrownby?.resolve()

	if(ismob(target) && target.reagents)
		if(thrown)
			reagents.total_volume *= rand(5,10) * 0.1 //Not all of it makes contact with the target
		var/mob/M = target
		var/R
		target.visible_message("<span class='danger'>[M] has been splashed with something!</span>", \
						"<span class='userdanger'>[M] has been splashed with something!</span>")
		for(var/datum/reagent/A in reagents.reagent_list)
			R += "[A.type]  ([num2text(A.volume)]),"

		if(thrownby)
			log_combat(thrown_by, M, "splashed", R)
		reagents.reaction(target, TOUCH)

	else if(bartender_check(target) && thrown)
		visible_message("<span class='notice'>[src] lands onto the [target.name] without spilling a single drop.</span>")
		return

	else
		if(isturf(target) && length(reagents.reagent_list) && thrown_by)
			log_combat(thrown_by, target, "splashed (thrown) [english_list(reagents.reagent_list)]", "in [AREACOORD(target)]")
			log_game("[key_name(thrown_by)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [AREACOORD(target)].")
			message_admins("[ADMIN_LOOKUPFLW(thrown_by)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] in [ADMIN_VERBOSEJMP(target)].")
		visible_message("<span class='notice'>[src] spills its contents all over [target].</span>")
		reagents.reaction(target, TOUCH)
		if(QDELETED(src))
			return

	reagents.clear_reagents()

/obj/item/reagent_containers/microwave_act(obj/machinery/microwave/M)
	reagents.expose_temperature(1000)
	return ..()

/obj/item/reagent_containers/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	reagents.expose_temperature(exposed_temperature)

/obj/item/reagent_containers/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/update_icon(dont_fill = FALSE)
	if(!fill_icon_thresholds || dont_fill)
		return ..()

	cut_overlays()

	if(!reagents.total_volume)
		if(label_icon && (name != initial(name) || desc != initial(desc)))
			var/mutable_appearance/label = mutable_appearance('icons/obj/chemical.dmi', "[label_icon]")
			add_overlay(label)
		return ..()
	var/fill_name = fill_icon_state ? fill_icon_state : icon_state
	var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[fill_name][fill_icon_thresholds[1]]")

	var/percent = round((reagents.total_volume / volume) * 100)
	for(var/i in 1 to length(fill_icon_thresholds))
		var/threshold = fill_icon_thresholds[i]
		var/threshold_end = (i == length(fill_icon_thresholds)) ? INFINITY : fill_icon_thresholds[i+1]
		if(threshold <= percent && percent < threshold_end)
			filling.icon_state = "[fill_name][fill_icon_thresholds[i]]"

	filling.color = mix_color_from_reagents(reagents.reagent_list)
	add_overlay(filling)
	if(label_icon && (name != initial(name) || desc != initial(desc)))
		var/mutable_appearance/label = mutable_appearance('icons/obj/chemical.dmi', "[label_icon]")
		add_overlay(label)
	return ..()

/obj/item/reagent_containers/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run = FALSE)
	// Always attempt to isolate diseases from reagent containers, if possible.
	. = ..()
	EXTRAPOLATOR_ACT_SET(., EXTRAPOLATOR_ACT_PRIORITY_ISOLATE)
	var/datum/reagent/blood/blood = reagents.get_reagent(/datum/reagent/blood)
	EXTRAPOLATOR_ACT_ADD_DISEASES(., blood?.get_diseases())
