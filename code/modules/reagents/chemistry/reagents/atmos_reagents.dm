/datum/reagent/nitrium
	name = "Nitrium"
	description = "A highly reactive gas that makes you feel faster."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "#90560B"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "burning"
	overdose_threshold = 10
	metabolized_traits = list(TRAIT_NOSTAMCRIT, TRAIT_NOLIMBDISABLE)

	var/warned = FALSE
	var/feeling_high = FALSE

/datum/reagent/nitrium/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
	to_chat(affected_mob, span_warning("You feel like nothing can stop you!"))
	feeling_high = TRUE

/datum/reagent/nitrium/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium) //Just in case it doesn't get removed in mob_life

/datum/reagent/nitrium/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	// Stopped huffing and wearing off, but not all gone. No more stamina modifiers. Takes ~20 more seconds to fully metabolize
	if(feeling_high && holder.get_reagent_amount(/datum/reagent/nitrium) <= 2)
		feeling_high = FALSE
		to_chat(affected_mob, span_warning("You can feel your high starting to wear off"))
		affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
	// Whether they go back to huffing too soon, or they have just started huffing, this calculation will handle stamina restoration and exhaustion both.
	else
		affected_mob.adjustStaminaLoss((clamp((-30 + current_cycle), -2, 5)) * REM * delta_time, updating_health = FALSE)
		if(!warned && current_cycle >= 31)
			to_chat(affected_mob, span_danger("Your body aches!"))
			warned = TRUE
		return UPDATE_MOB_HEALTH

/datum/reagent/nitrium/overdose_start(mob/living/carbon/affected_mob)
	//Because otherwise it lasts for a punishingly long time if an overdose is reached
	metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/nitrosyl_plasmide
	name = "Nitrosyl plasmide"
	description = "A highly reactive byproduct that stops you from sleeping"
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "#E1A116"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "sourness"
	addiction_types = list(/datum/addiction/stimulants = 14)
	metabolized_traits = list(TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE)

	var/warned = FALSE

/datum/reagent/nitrosyl_plasmide/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrosyl_plasmide)

/datum/reagent/nitrosyl_plasmide/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrosyl_plasmide)

/datum/reagent/nitrosyl_plasmide/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustStaminaLoss((clamp((-10 + current_cycle), -8, 3)) * REM * delta_time, updating_health = FALSE)
	if(!warned && current_cycle >= 13)
		to_chat(affected_mob, span_danger("Your body feels like it's on fire!")) // Nitrosyl is now draining more than Nitrium is giving
		warned = TRUE

	return UPDATE_MOB_HEALTH
