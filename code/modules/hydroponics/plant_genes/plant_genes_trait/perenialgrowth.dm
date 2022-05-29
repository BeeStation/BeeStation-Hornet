/datum/plant_gene/trait/repeated_harvest
	research_needed = 6
	name = "Perennial Growth"
	desc = "Your plants will grow again even if it's harvested.<br />WARNING: Not valid to Replica Pod."
	trait_id = "perenial"
	randomness_flags = BOTANY_RANDOM_COMMON

/datum/plant_gene/trait/repeated_harvest/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	if(istype(S, /obj/item/seeds/replicapod))
		return FALSE
	return TRUE


/datum/plant_gene/trait/no_perenial
	research_needed = -1
	name = "Incompatible Perennial Growth"
	desc = "Your plant can't take Perennial Growth trait"
	trait_id = "perenial"
	randomness_flags = BOTANY_RANDOM_COMMON
	mutability_flags = NONE
