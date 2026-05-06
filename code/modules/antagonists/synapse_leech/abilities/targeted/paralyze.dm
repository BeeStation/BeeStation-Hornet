/**
 * # Paralyzing Sting
 *
 * Targeted ability. A high-cost burst of concentrated neurotoxin that briefly paralyzes a single
 * adjacent victim, giving the leech an opening to escape or set up a nest.
 */
/datum/action/leech/targeted/paralyze
	name = "Paralyzing Sting"
	desc = "Inject a paralytic dose of toxin."
	power_explanation = "Sting an adjacent victim with a heavy dose of paralytic neurotoxin, briefly locking up their muscles."
	button_icon_state = "paralyze"

	target_range = 1
	cooldown_time = 60 SECONDS
	substrate_cost = 80
	prefire_message = "Select a victim to sting..."

	/// How much paralytide we inject per sting.
	var/paralytide_dose = 20

/datum/action/leech/targeted/paralyze/is_valid_target(atom/target)
	if(!isliving(target))
		return FALSE
	var/mob/living/victim = target
	if(HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
		return FALSE
	return TRUE

/datum/action/leech/targeted/paralyze/on_target(mob/living/basic/synapse_leech/leech, atom/target)
	var/mob/living/victim = target
	if(!victim.reagents)
		return FALSE
	to_chat(target, span_warning("You feel a tiny prick!"))
	victim.reagents.add_reagent(/datum/reagent/toxin/leech_paralytide, paralytide_dose)
	return TRUE
