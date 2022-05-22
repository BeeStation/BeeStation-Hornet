
// Reagent genes store reagent ID, reagent size and its maximum
/datum/plant_gene/reagent
	name = "Nutriment"
	var/reagent_id = /datum/reagent/consumable/nutriment
	var/reag_unit = 4
	var/reag_unit_max = 4

/datum/plant_gene/reagent/get_name()
	var/formatted_name
	if(!(mutability_flags & PLANT_GENE_REMOVABLE && mutability_flags & PLANT_GENE_EXTRACTABLE))
		if(mutability_flags & PLANT_GENE_REMOVABLE)
			formatted_name += "Fragile "
		else if(mutability_flags & PLANT_GENE_EXTRACTABLE)
			formatted_name += "Essential "
		else
			formatted_name += "Immutable "
	formatted_name += "[name]"
	return formatted_name

/datum/plant_gene/reagent/proc/set_reagent(reag_id)
	reagent_id = reag_id
	name = "UNKNOWN"

	var/datum/reagent/R = GLOB.chemical_reagents_list[reag_id]
	if(R && R.type == reagent_id)
		name = R.name

/datum/plant_gene/reagent/New(reag_id = null, reag_pair = list(0, 0))
	if(isnull(reag_id))
		return

	..()
	if(reag_id && reag_pair)
		set_reagent(reag_id)
		reag_unit = reag_pair[1]
		reag_unit_max = reag_pair[2]


/datum/plant_gene/reagent/Copy()
	var/datum/plant_gene/reagent/G = ..()
	G.name = name
	G.reagent_id = reagent_id
	G.reag_unit = reag_unit
	G.reag_unit_max = reag_unit_max
	return G

/datum/plant_gene/reagent/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	for(var/datum/plant_gene/reagent/R in S.genes)
		if(R.reagent_id == reagent_id)
			return FALSE
	return TRUE
