/datum/action/cooldown/vampire/vassal_blood
	name = "Create Blood"
	desc = "Convert a blood bag into Vampiric Blood."
	button_icon_state = "power_bleed"
	power_explanation = "Use this power with a bloodbag in hand to fill it with Vampiric Blood which is used to reset ex-vassal deconversion timers."
	power_flags = NONE
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 150
	cooldown_time = 10 SECONDS

/datum/action/cooldown/vampire/vassal_blood/can_use(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE

	var/blood_bag = locate(/obj/item/reagent_containers/blood) in owner?.held_items
	if(!blood_bag)
		owner.balloon_alert(owner, "blood bag needed!")
		return FALSE
	if(istype(blood_bag, /obj/item/reagent_containers/blood/OMinus/vampire))
		owner.balloon_alert(owner, "already vampire blood!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/vassal_blood/ActivatePower()
	var/blood_bag = locate(/obj/item/reagent_containers/blood) in owner.held_items
	if(blood_bag)
		QDEL_NULL(blood_bag)
		var/obj/item/reagent_containers/blood/OMinus/vampire/new_bag = new(owner.loc)
		owner.put_in_active_hand(new_bag)
		DeactivatePower()

/*
 * Vampire Blood
 * Slighty darker than normal blood
 * Artificially made, this must be fed to ex-vassals to keep them on their high.
 */
/datum/reagent/blood/vampire
	color = "#960000"

/datum/reagent/blood/vampire/on_mob_metabolize(mob/living/living)
	var/datum/antagonist/ex_vassal/former_vassal = IS_EX_VASSAL(living)
	if(former_vassal)
		to_chat(living, span_cult("You feel the blood restore you... You feel safe."))
		COOLDOWN_RESET(former_vassal, blood_timer)
		COOLDOWN_START(former_vassal, blood_timer, 10 MINUTES)
	return ..()


/obj/item/reagent_containers/blood/OMinus/vampire
	unique_blood = /datum/reagent/blood/vampire

/obj/item/reagent_containers/blood/OMinus/vampire/examine(mob/user)
	. = ..()
	if(IS_EX_VASSAL(user) || IS_REVENGE_VASSAL(user))
		. += span_notice("Seems to be just about the same color as your old Master's...")
