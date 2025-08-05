/datum/reagent/nitrium_high_metabolization
	name = "Nitrosyl plasmide"
	description = "A highly reactive byproduct that stops you from sleeping, while dealing increasing toxin damage over time."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "#E1A116"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "sourness"
	metabolized_traits = list(TRAIT_SLEEPIMMUNE)

/datum/reagent/nitrium_high_metabolization/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	affected_mob.adjustStaminaLoss(-4 * REM * delta_time, updating_health = FALSE)
	affected_mob.adjustToxLoss(0.1 * (current_cycle-1) * REM * delta_time, updating_health = FALSE) // 1 toxin damage per cycle at cycle 10
	return UPDATE_MOB_HEALTH

/datum/reagent/nitrium_low_metabolization
	name = "Nitrium"
	description = "A highly reactive gas that makes you feel faster."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "#90560B"
	chemical_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "burning"

/datum/reagent/nitrium_low_metabolization/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

/datum/reagent/nitrium_low_metabolization/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
