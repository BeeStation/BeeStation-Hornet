/datum/bounty/genetics
	reward = 1000
	var/shipped = FALSE
	var/datum/mutation/mutation
	var/static/list/mutations = GLOB.all_mutations[]

/datum/bounty/genetics/New()
	..()
	mutation = pick_n_take(mutations)
	name = "Data disk containing ([mutation.name])"
	description = "meow"
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
	for(var/i in O.mutations)
		if(i == mutation)
			return TRUE
	return FALSE

/datum/bounty/genetics/ship(obj/item/disk/data/O)
	if(!applies_to(O))
		return
	shipped = TRUE


