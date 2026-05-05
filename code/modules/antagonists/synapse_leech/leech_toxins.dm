// Leech Toxin. Their primary method of attack and self-defense.
// Causes intense pain, toxin buildup, dizziness, and eventually unconsciousness and death if untreated.

/datum/reagent/toxin/leech_toxin
    name = "Nocivorant Mycelotoxin"
    description = "A neuro-irritant that spreads through the bloodstream like branching filaments, overwhelming pain pathways and destabilizing motor control."
    color = "#30b300"
    reagent_state = LIQUID
    taste_description = "rotting fungus"
    toxpwr = 1.5
    metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/toxin/leech_toxin/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
    . = ..()
	// TODO
