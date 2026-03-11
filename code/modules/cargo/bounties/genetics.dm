/datum/bounty/genetics
	reward = 1000
	var/shipped = FALSE
	var/datum/mutation/mutation
	var/admin_only = list(/datum/mutation/elvis,
		/datum/mutation/bad_dna,
		/datum/mutation/thermal/x_ray,
		/datum/mutation/laser_eyes,
		/datum/mutation/thermal,
		/datum/mutation/stoner) //Stoner is locked behind beach bums and will probably never be seen

/datum/bounty/genetics/New()
	..()
	mutation = pick(GLOB.all_mutations - admin_only)
	name = "Data Disk ([mutation.name])"
	description = "Central Command is requesting a data disk containing the nucleotide sequence of a [mutation.name] mutation for experimental research"
	reward +=  mutation.difficulty * 500

/datum/bounty/genetics/completion_string()
	return shipped ? "Shipped" : "Not Shipped"

/datum/bounty/genetics/can_claim()
	return ..() && shipped

/datum/bounty/genetics/applies_to(obj/item/disk/data/O)
	if(shipped)
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	if(!istype(O, /obj/item/disk/data))
		return FALSE
	for(var/datum/mutation/stored in O.mutations)
		if(mutation == stored.type)
			return TRUE
	return FALSE

/datum/bounty/genetics/ship(obj/item/disk/data/O)
	if(!applies_to(O))
		return
	shipped = TRUE

/datum/bounty/genetics/compatible_with(datum/other_bounty)
	if(!istype(other_bounty, /datum/bounty/genetics))
		return TRUE
	var/datum/bounty/genetics/M = other_bounty
	return M.mutation != mutation

