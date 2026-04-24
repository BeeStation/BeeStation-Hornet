/**
 * Plasmaman liver
 * Makes plasma and hot ice heal wounds, also makes gunpowder a hallucinogen.
 **/
/obj/item/organ/liver/bone/plasmaman
	name = "reagent processing crystal"
	desc = "A large crystal that is somehow capable of metabolizing chemicals, these are found in plasmamen."
	icon_state = "liver-p"
	organ_flags = ORGAN_MINERAL

/obj/item/organ/liver/bone/plasmaman/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()
	// parent returned COMSIG_MOB_STOP_REAGENT_CHECK or we are failing
	if((. & COMSIG_MOB_STOP_REAGENT_CHECK) || (organ_flags & ORGAN_FAILING))
		return
	// plasmamen get high on gunpowder lol
	if(istype(chem, /datum/reagent/blackpowder))
		organ_owner.set_timed_status_effect(15 SECONDS * seconds_per_tick, /datum/status_effect/drugginess)
		if(organ_owner.get_timed_status_effect_duration(/datum/status_effect/hallucination) / 10 < chem.volume)
			organ_owner.adjust_hallucinations(2.5 SECONDS * seconds_per_tick)
		return // Do normal metabolism
