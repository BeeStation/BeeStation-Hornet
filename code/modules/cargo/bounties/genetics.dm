/datum/bounty/genetics
	reward = 1000
	var/shipped = FALSE
	var/datum/mutation/bounty_mutation
	var/static/list/excluded_mutations = list(/datum/mutation/elvis,
		/datum/mutation/bad_dna,
		/datum/mutation/thermal/x_ray,
		/datum/mutation/laser_eyes,
		/datum/mutation/thermal,
		/datum/mutation/stoner, //Stoner is locked behind beach bums and will probably never be seen
		/datum/mutation/human,
		/datum/mutation/human/thermal)

/datum/bounty/genetics/New()
	. = ..()
	var/static/list/mutation_pools
	if(!length(mutation_pools))
		mutation_pools = GLOB.all_mutations - excluded_mutations
	bounty_mutation = pick_n_take(mutation_pools)
	name = "Data Disk ([bounty_mutation.name])"
	description = "Central Command is requesting a data disk containing the nucleotide sequence of a [bounty_mutation.name] mutation for experimental research"
	reward += bounty_mutation.difficulty * 500

/datum/bounty/genetics/completion_string()
	return shipped ? "Shipped" : "Not Shipped"

/datum/bounty/genetics/can_claim()
	return ..() && shipped

/datum/bounty/genetics/applies_to(obj/item/disk/data/disk)
	if(shipped)
		return FALSE
	if(disk.flags_1 & HOLOGRAM_1)
		return FALSE
	if(!istype(disk, /obj/item/disk/data))
		return FALSE
	for(var/datum/mutation/each_mutation in disk.mutations)
		if(bounty_mutation == each_mutation.type)
			return TRUE
	return FALSE

/datum/bounty/genetics/ship(obj/item/disk/data/disk)
	if(!applies_to(disk))
		return
	shipped = TRUE

/datum/bounty/genetics/compatible_with(datum/other_bounty)
	if(!istype(other_bounty, /datum/bounty/genetics))
		return TRUE
	var/datum/bounty/genetics/o_bounty = other_bounty
	return o_bounty.bounty_mutation != bounty_mutation

