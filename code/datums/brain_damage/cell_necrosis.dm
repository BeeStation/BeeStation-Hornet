/datum/brain_trauma/death
	name = "Cell Necrosis"
	desc = "Brain has undergone necrosis due to death. Medication is required to prevent further damage and permanent traumas"
	scan_desc = "cell necrosis"

/datum/brain_trauma/death/on_life()
    . = ..()
    var/chance = 300
    if(owner.reagents.has_reagent(/datum/reagent/medicine/mannitol))
        chance += 50
    for(var/X in owner.internal_organs)
        if(istype(X, /obj/item/organ/cyberimp/brain/brain_cell_stimmulator))
            chance = chance * 2
    if(prob(100/chance) && owner.stat != DEAD)
        if(owner.reagents.has_reagent(/datum/reagent/medicine/brendol) || owner.reagents.has_reagent(/datum/reagent/medicine/cortexone) || owner.reagents.has_reagent(/datum/reagent/medicine/cranizine))
            return
        owner.gain_trauma_type(pick(BRAIN_TRAUMA_MILD,BRAIN_TRAUMA_SEVERE), TRAUMA_RESILIENCE_ABSOLUTE)