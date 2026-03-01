/////////////////////////////////////////////////////////////////////////////////////
					/* METABOLITE REAGENTS */
//////////////////////////////////////////////////////////////////////////////////////

/*
* Metabolites are the byproducts left behind after metabolizing a given reagent.
* Metabolites by themselves should almost always do nothing, only serving as an indicator that something was processed by the body semi-recently
*
* Naming metabolites is as follows:
* First charcter of first syllable
* First character of second syllable
* Number ascending from 1 (to differentiate metabolites with the same first characters)
*/

/datum/reagent/metabolite
	name = "Metabolites"
	color = "#FAFF00"
	description = "You should never see this. Contact an administrator or coder"
	chemical_flags = CHEMICAL_NOT_DEFINED

/datum/reagent/metabolite/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = ..()
	if(volume > MAX_METABOLITES)
		volume = MAX_METABOLITES

/datum/reagent/metabolite/medicine
	name = "Medicinal Metabolites"
	metabolization_rate = REAGENTS_METABOLISM * 0.025

/datum/reagent/metabolite/medicine/bicaridine
	name = "BC1 metabolites"
	description = "A byproduct of the body processing bicaridine"

/datum/reagent/metabolite/medicine/kelotane
	name = "KL1 metabolites"
	description = "A byproduct of the body processing kelotane"

/datum/reagent/metabolite/medicine/antitoxin
	name = "AT1 metabolites"
	description = "A byproduct of the body processing antitoxin"

/datum/reagent/metabolite/medicine/tricordrazine
	name = "TC1 metabolites"
	description = "A byproduct of the body processing tricordrazine"

/datum/reagent/metabolite/medicine/styptic_powder
	name = "SP1 metabolites"
	description = "A byproduct of the body processing styptic_powder"
	metabolization_rate = REAGENTS_METABOLISM * 0.5 //higher rate just like the base reagent.

/datum/reagent/metabolite/medicine/silver_sulfadiazine
	name = "SV1 metabolites"
	description = "A byproduct of the body processing silver sulfadiazine"
	metabolization_rate = REAGENTS_METABOLISM * 0.5

/datum/reagent/metabolite/bz
	name = "BZ1 metabolites"
	description = "A byproduct of the body processing BZ gas."
	metabolization_rate = REAGENTS_METABOLISM * 0.2

/datum/reagent/metabolite/bz/on_mob_life(mob/living/carbon/affected_mob)
	. = ..()
	// This one's effect is grandfathered in from before other metabolites existed. One of the only direct counters to changelings
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(affected_mob)
	changeling?.adjust_chemicals(-2)
