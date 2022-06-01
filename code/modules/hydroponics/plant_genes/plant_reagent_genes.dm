
// Reagent genes store reagent ID, reagent size and its maximum
/datum/plant_gene/reagent
	name = "Nutriment"
	var/reagent_id = /datum/reagent/consumable/nutriment
	var/reag_unit = 4
	var/reag_unit_max = 4
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_REAGENT_ADJUSTABLE | PLANT_GENE_QDEL_TARGET

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

// basic reagent genes we play
/datum/plant_gene/reagent/sandbox
	plant_gene_flags = PLANT_GENE_COMMON_REMOVABLE | PLANT_GENE_REAGENT_ADJUSTABLE | PLANT_GENE_QDEL_TARGET

/datum/plant_gene/reagent/sandbox/can_add(obj/item/seeds/S)
	if(!..())
		return FALSE
	for(var/datum/plant_gene/reagent/sandbox/R in S.genes)
		if(!istype(R, /datum/plant_gene/reagent/sandbox))
			continue
		if(R.reagent_id == reagent_id)
			return FALSE
	return TRUE

// special reagent genes which is restricted to play
// This is needed to stack with the same reagent togather
// i.e.) Nutriment 2u from innate, Nutriment 4u from sandbox = 6u nutriment
// 		 innate nutriment 2u is not changable, but sandbox nutriment 4u can be removed.
/datum/plant_gene/reagent/innate
	plant_gene_flags = PLANT_GENE_QDEL_TARGET

/datum/plant_gene/reagent/innate/New(reag_id = null, reag_pair = list(0, 0, NONE))
	if(isnull(reag_id))
		return

	..()
	if(reag_id && reag_pair)
		set_reagent(reag_id)
		reag_unit = reag_pair[1]
		reag_unit_max = reag_pair[2]

	if(reag_pair[3])
		plant_gene_flags |= reag_pair[3]

