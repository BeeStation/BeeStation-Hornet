SUBSYSTEM_DEF(botany)
	name = "Botany"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_BOTANY

	///list of plant species - This is used for the discovery component
	var/list/plant_species = list()

	///List of plant needs we randomly pick from to compensate for overdrawing genetic budget
	var/list/overdraw_needs = list()

	///List of discovered plant species
	var/list/discovered_species = list()

	///Blacklist of fruits that can't be slippery - Only used by banana, but will be a micro optimization in the future if we add more
	var/list/slippery_blacklist = list(/obj/item/food/grown/banana)

	///List of cached genes - list('species_id' = list(genes))
	var/list/gene_cache = list()
	///List of cached needs per species, stops need re-rolling
	var/list/previous_needs = list()

	///List of possible weeds, and their weights - These values are interpreted from old botany
	var/list/weeds = list(/obj/item/plant_seeds/preset/amanita = 1, /obj/item/plant_seeds/preset/reishi = 2, /obj/item/plant_seeds/preset/nettle = 1, /obj/item/plant_seeds/preset/chanterelle = 1,
	/obj/item/plant_seeds/preset/tower = 1, /obj/item/plant_seeds/preset/plump = 1, /obj/item/plant_seeds/preset/starthistle = 3, /obj/item/plant_seeds/preset/harebell = 1)

//Refraction reagents
	///List of all botany reagents, pointing to grid location, offset, and obscure size
	var/list/refraction_reagents = list()
	var/list/refraction_coords = list()

//Random seeds
	///List of all random seeds
	var/list/random_seeds = list()
	///List of unused random seeds
	var/list/unused_random_seeds = list()

//Random traits
	///List of all random traits - linked list, arranged by trait compat list(/datum/plant_feature/body = list(traits))
	var/list/random_traits = list()
	var/list/unused_random_traits = list()

//Plant dictionary
	///List of dictionary chapters- features, plants, traits
	var/list/chapters = list()
	///List of links for dictionary references, like finding which features a trait appears in
	var/list/dictionary_links = list()
	///Special index for fast reagents, keeping track of what's logged already
	var/list/fast_reagents = list()

/datum/controller/subsystem/botany/Initialize(timeofday)
	build_dict()
	slippery_blacklist = typecacheof(slippery_blacklist)
//Build overdraw need list
	for(var/datum/plant_need/need as anything in subtypesof(/datum/plant_need))
		if(initial(need.overdraw_need))
			overdraw_needs += need
//Build random seeds lists
	for(var/obj/item/plant_seeds/preset/kirby/seed as anything in subtypesof(/obj/item/plant_seeds/preset/kirby))
		random_seeds += seed
//Build random traits
	for(var/datum/plant_trait/trait as anything in subtypesof(/datum/plant_trait))
		if(!initial(trait.random_trait))
			continue
		//Don't let abstract types through
		var/path = initial(trait.type)
		if(path == /datum/plant_trait || path == /datum/plant_trait/fruit || path == /datum/plant_trait/body || path == /datum/plant_trait/roots || path == /datum/plant_trait/reagent)
			continue
		//Populate the random trait list, keyed by what type of feature the trait is compatible with
		if(!random_traits["[initial(trait.plant_feature_compat)]"])
			random_traits["[initial(trait.plant_feature_compat)]"] = list()
		random_traits["[initial(trait.plant_feature_compat)]"] += trait
//Build refraction reagents
	var/list/all_reagents = subtypesof(/datum/reagent)
	all_reagents = shuffle(all_reagents)
	//Popluate accuracy levels
	for(var/level in 1 to GRID_MAX_ACCURACY)
		refraction_reagents["[level]"] = list()
		refraction_coords["[level]"] = list()
		//Populate reagent data
		for(var/datum/reagent/reagent as anything in all_reagents)
			if(!(initial(reagent.chemical_flags) & CHEMICAL_RNG_BOTANY))
				continue
			//Area in which we can fall inside
			var/matrix_size = rand(2, level+2)
			//Where our hint radius is offset by
			var/max_offset = floor(matrix_size/2)
			var/offset_x = rand(-max_offset+1, max_offset)
			var/offset_y = rand(-max_offset+1, max_offset)
			//Where we actually live
			var/grid_x = rand(1, MAX_REAGENT_GRID*level)
			var/grid_y = rand(1, MAX_REAGENT_GRID*level)
			//Fill the cunt with the info
			refraction_reagents["[level]"]["[initial(reagent.type)]"] = list(GRID_REAGENT_POSITION = list(grid_x, grid_y),
			GRID_REAGENT_NAME = initial(reagent.name),
			GRID_REAGENT_SIZE = matrix_size,
			GRID_REAGENT_OFFSET = list(offset_x, offset_y))
			refraction_coords["[level]"]["[grid_x]:[grid_y]"] = "[initial(reagent.type)]"

/datum/controller/subsystem/botany/proc/build_dict()
//Features
	var/list/keyed_features = list() //List of features keyed by type, so we can link them to plants
	chapters["features"] = list()
	var/list/features = subtypesof(/datum/plant_feature)
	for(var/datum/plant_feature/feature as anything in features)
		var/datum/plant_feature/entry_feature = new feature()
		//Don't let abstract types through
		if(entry_feature.type == /datum/plant_feature || entry_feature.type == /datum/plant_feature/body || entry_feature.type == /datum/plant_feature/fruit || entry_feature.type == /datum/plant_feature/roots || entry_feature.type == /datum/plant_feature/fruit/mushroom)
			qdel(entry_feature)
			continue
		//Don't let kirbies through
		if(istype(entry_feature.type, /datum/plant_feature/body/kirby))
			qdel(entry_feature)
			continue
		//Handle dict override
		if(entry_feature.dictionary_override && keyed_features["[entry_feature.dictionary_override]"])
			continue
		chapters["features"] |= entry_feature
		keyed_features["[entry_feature.type]"] = "[ref(entry_feature)]"
	//Build links
		//Traits
		for(var/datum/plant_trait/trait as anything in entry_feature.plant_traits)
			dictionary_links["[trait.get_id()]"] = dictionary_links["[trait.get_id()]"] || list()
			dictionary_links["[trait.get_id()]"] |= "[ref(entry_feature)]"
		//Mutations
	for(var/datum/plant_feature/feature as anything in chapters["features"])
		for(var/datum/plant_feature/mutation as anything in feature.mutations)
			var/link_feature = keyed_features["[mutation]"]
			dictionary_links[link_feature] = dictionary_links[link_feature] || list()
			dictionary_links[link_feature] |= "[ref(feature)]"
//Traits
	chapters["traits"] = chapters["traits"] || list() //Race condition weirdness
	var/list/traits = subtypesof(/datum/plant_trait)
	for(var/datum/plant_trait/trait as anything in traits)
		var/datum/plant_trait/entry_trait = new trait()
		if(trait.type == /datum/plant_trait || trait.type == /datum/plant_trait/fruit || trait.type == /datum/plant_trait/body || trait.type == /datum/plant_trait/roots || trait.type == /datum/plant_trait/reagent)
			qdel(entry_trait)
			continue
		chapters["traits"] += entry_trait
//Plants - This is a lie, it's actually got pre-made seeds
	chapters["plants"] = list()
	for(var/obj/item/plant_seeds/preset as anything in typesof(/obj/item/plant_seeds/preset))
		if(istype(preset, /obj/item/plant_seeds/preset/kirby))
			continue
		var/obj/item/plant_seeds/seeds = new preset()
		if(seeds.type == /obj/item/plant_seeds/preset)
			qdel(seeds)
			continue
		chapters["plants"] += seeds
		//Build links
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			var/link_feature = keyed_features["[feature.dictionary_override || feature.type]"]
			dictionary_links[link_feature] = dictionary_links[link_feature] || list()
			dictionary_links[link_feature] += "[ref(seeds)]"

/datum/controller/subsystem/botany/proc/get_seed(consider_unused = TRUE)
	if(!consider_unused)
		return pick(random_seeds)
	if(!length(unused_random_seeds))
		var/list/copy_list = random_seeds
		unused_random_seeds = copy_list.Copy()
	var/trait = pick(unused_random_seeds)
	unused_random_seeds -= trait
	return trait

/datum/controller/subsystem/botany/proc/get_random_need()
	return pick(overdraw_needs)

/datum/controller/subsystem/botany/proc/get_random_trait(filter, consider_unused = TRUE)
	if(!filter)
		return
	if(!consider_unused)
		return pick(random_traits[filter])
	if(!length(unused_random_traits[filter]))
		var/list/copy_list = random_traits[filter]
		unused_random_traits[filter] = copy_list.Copy()
	var/trait = pick(unused_random_traits[filter])
	unused_random_traits[filter] -= trait
	return trait

/datum/controller/subsystem/botany/proc/append_reagent_trait(datum/plant_trait/reagent/reagent)
	if(!fast_reagents["[reagent.name][reagent.volume_percentage]"])
		fast_reagents["[reagent.name][reagent.volume_percentage]"] = reagent
		SSbotany.chapters["traits"] = SSbotany.chapters["traits"] || list() //Race condition weirdness
		SSbotany.chapters["traits"] += reagent

//Formatted like "[feature](trait-types)-[feature](trait-types)-[feature](trait-types)"
///Use this to generate a species ID based on our feature's and their traits
/proc/build_plant_species_id(list/feature_list)
	var/new_species_id = ""
	for(var/datum/plant_feature/feature as anything in feature_list)
		var/traits = ""
		for(var/datum/plant_trait/trait as anything in feature.plant_traits)
			traits = "[traits]-[trait?.get_id()]"
		new_species_id = "[new_species_id][feature?.species_name]-([traits])-"
	return new_species_id

/proc/get_species_name(list/feature_list)
	var/species_name = ""
	var/index = 1
	var/max_index = length(feature_list)-1
	for(var/datum/plant_feature/feature as anything in feature_list)
		species_name = "[feature.species_name][index < max_index ? "" : " "][species_name]"
		index += 1
	return species_name

//get a GROWN's fruit trait modifier
/proc/get_fruit_trait_power(obj/item/food/grown/fruit)
	var/list/genes = list()
	SEND_SIGNAL(fruit, COMSIG_PLANT_GET_GENES, genes)
	var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in genes[PLANT_GENE_INDEX_FEATURES]
	return fruit_feature?.trait_power
