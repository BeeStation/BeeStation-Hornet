/*
	Plant gene element. Allows most things grown from plants to be turned into seeds
	Technically anything can have this
*/
/datum/element/plant_genes
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///List of our plant genes
	var/list/plant_genes = list()

/datum/element/plant_genes/Attach(obj/target, list/_plant_features, _species_id)
	. = ..()
	plant_genes = list(PLANT_GENE_INDEX_FEATURES = _plant_features, PLANT_GENE_INDEX_ID = _species_id)
	RegisterSignal(target, COMSIG_PLANT_GET_GENES, PROC_REF(append_genes))

/datum/element/plant_genes/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_PLANT_GET_GENES)

/datum/element/plant_genes/proc/append_genes(datum/source, list/gene_list)
	SIGNAL_HANDLER

	gene_list += plant_genes
