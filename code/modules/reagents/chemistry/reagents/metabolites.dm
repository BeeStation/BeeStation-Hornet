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
    desc = "You should never see this. Contact an administrator or coder"
	chem_flags = CHEMICAL_NOT_DEFINED

/datum/reagent/metabolite/medicine
    name = "Medicinal Metabolites"
    metabolization_rate = 0.05

/datum/reagent/metabolite/medicine/bicaridine
    name = "BC1 metabolites"
    desc = "A byproduct of the body processing bicaridine"

/datum/reagent/metabolite/medicine/kelotane
    name = "KL1 metabolites"
    desc = "A byproduct of the body processing kelotane"

/datum/reagent/metabolite/medicine/antitoxin
    name = "AT1 metabolites"
    desc = "A byproduct of the body processing antitoxin"

/datum/reagent/metabolite/medicine/tricordrazine
    name = "TC1 metabolites"
    desc = "A byproduct of the body processing tricordrazine"
