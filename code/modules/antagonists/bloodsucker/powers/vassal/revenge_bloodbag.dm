/datum/action/cooldown/bloodsucker/vassal_blood
	name = "Create Blood"
	desc = "Convert a blood bag into Vampiric Blood."
	button_icon_state = "power_bleed"
	power_explanation = "Use this power with a bloodbag inhand to fill it with Vampiric Blood which is used to reset ex-vassal deconversion timers."
	power_flags = NONE
	check_flags = NONE
	purchase_flags = NONE
	bloodcost = 10
	cooldown_time = 10 SECONDS

/datum/action/cooldown/bloodsucker/vassal_blood/can_use(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/blood_bag = locate(/obj/item/reagent_containers/blood) in owner?.held_items
	if(!blood_bag)
		owner.balloon_alert(owner, "blood bag needed!")
		return FALSE
	if(istype(blood_bag, /obj/item/reagent_containers/blood/OMinus/bloodsucker))
		owner.balloon_alert(owner, "already bloodsucker blood!")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/vassal_blood/ActivatePower(trigger_flags)
	var/blood_bag = locate(/obj/item/reagent_containers/blood) in owner.held_items
	if(blood_bag)
		var/mob/living/living_owner = owner
		living_owner.blood_volume -= 150
		QDEL_NULL(blood_bag)
		var/obj/item/reagent_containers/blood/OMinus/bloodsucker/new_bag = new(owner.loc)
		owner.put_in_active_hand(new_bag)
		DeactivatePower()

/*
 * Bloodsucker Blood
 * Slighty darker than normal blood
 * Artificially made, this must be fed to ex-vassals to keep them on their high.
 */
/datum/reagent/blood/bloodsucker
	color = "#960000"

/datum/reagent/blood/bloodsucker/on_mob_metabolize(mob/living/living)
	var/datum/antagonist/ex_vassal/former_vassal = IS_EX_VASSAL(living)
	if(former_vassal)
		to_chat(living, "<span class='cult'>You feel the blood restore you... You feel safe.</span>")
		COOLDOWN_RESET(former_vassal, blood_timer)
		COOLDOWN_START(former_vassal, blood_timer, 10 MINUTES)
	return ..()


/obj/item/reagent_containers/blood/OMinus/bloodsucker
	unique_blood = /datum/reagent/blood/bloodsucker

/obj/item/reagent_containers/blood/OMinus/bloodsucker/examine(mob/user)
	. = ..()
	if(IS_EX_VASSAL(user) || IS_REVENGE_VASSAL(user))
		. += "<span class='notice'>Seems to be just about the same color as your old Master's...</span>"
