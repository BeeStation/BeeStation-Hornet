// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

CREATION_TEST_IGNORE_SELF(/obj/item/food/grown)

// Base type. Subtypes are found in /grown dir. Lavaland-based subtypes can be found in mining/ash_flora.dm
/obj/item/food/grown
	abstract_type = /obj/item/food/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "berrypile"
	worn_icon = 'icons/mob/clothing/head/hydroponics.dmi'
	name = "fresh produce" //fix naming bug
	max_volume = 100
	max_demand = 150
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	///What basic most typepath does this food associate with - pretty much used exclusively for kudzu stuff
	var/seed_base = /obj/item/plant_seeds
	///Shortcut for roundstart grown items to have 'genes'
	var/obj/item/plant_seeds/seed = null
	///Name of the plant
	var/plantname = ""
	/// The modifier applied to the plant's bite size. If a plant has a large amount of reagents naturally, this should be increased to match.
	var/bite_consumption_mod = 1
	///the splat it makes when it splats lol
	var/splat_type = /obj/effect/decal/cleanable/food/plant_smudge
	/// If TRUE, this object needs to be dry to be ground up
	var/dry_grind = FALSE
	/// If FALSE, this object cannot be distilled into an alcohol.
	var/can_distill = TRUE
	/// The reagent this plant distills to. If NULL, it uses a generic fruit_wine reagent and adjusts its variables.
	var/distill_reagent
	/// Flavor of the plant's wine if NULL distill_reagent. If NULL, this is automatically set to the fruit's flavor.
	var/wine_flavor
	/// Boozepwr of the wine if NULL distill_reagent
	var/wine_power = 10
	///Color of the grown object
	var/filling_color
	//Amount of discovery points given for scanning
	var/discovery_points = 0
	//otherwise this is a huge headache if you are an ashwalker or that survivalist, or just anyone without hydroponic gear access.
	decomp_req_handle = TRUE

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/food/grown)

/obj/item/food/grown/Initialize(mapload, skip_genes)
	. = ..()
	if(!tastes)
		tastes = list("[name]" = 1) //This happens first else the component already inits
	if(!pixel_y && !pixel_x)
		pixel_x = base_pixel_x + rand(-5, 5)
		pixel_y = base_pixel_y + rand(-5, 5)
	make_dryable()
	if(discovery_points)
		AddComponent(/datum/component/discoverable, discovery_points)
//Make sure maploaded produce loads with it's traits & genes
	if(!seed || skip_genes)
		return
	var/obj/item/plant_seeds/new_seed = new seed(src)
//Traits - This doesn't cover modifications added by body & root traits, sue me - This is imperfect, but this should rarely ever happen outside basic mapping or admin stuff
	var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in new_seed.plant_features
	//pre-flight grab reagent stuff from the fruit so SOME traits work properly
	reagents?.maximum_volume = fruit_feature?.total_volume
	//Add the traits from each feature, most will bounce off
	for(var/datum/plant_trait/trait as anything in fruit_feature?.plant_traits)
		trait.copy(src)
	var/trait_scale = max(fruit_feature.trait_power*0.5, 1) //Scale size with trait power
	var/matrix/n_transform = matrix(transform)
	n_transform.Scale(trait_scale, trait_scale)
	transform = n_transform //Weirdly enough, just scaling the transform doesn't work here
//Add genes
	if(!SSbotany.gene_cache["[new_seed.species_id]"])
		var/list/plant_genes = list()
		for(var/datum/plant_feature/gene as anything in new_seed.plant_features)
			if(QDELETED(gene))
				continue
			plant_genes += gene?.copy()
		SSbotany.gene_cache[new_seed.species_id] = plant_genes
	AddElement(/datum/element/plant_genes, SSbotany.gene_cache["[new_seed.species_id]"], new_seed.species_id, new_seed.name_override, new_seed.desc_override)
	qdel(new_seed)

/obj/item/food/grown/Destroy()
	if(isatom(seed))
		QDEL_NULL(seed)
	return ..()

/obj/item/food/grown/make_edible()
	AddComponent(/datum/component/edible,\
				initial_reagents = food_reagents,\
				food_flags = food_flags,\
				foodtypes = foodtypes,\
				volume = max_volume,\
				eat_time = eat_time,\
				tastes = tastes,\
				eatverbs = eatverbs,\
				bite_consumption = bite_consumption,\
				microwaved_type = microwaved_type,\
				junkiness = junkiness)

/obj/item/food/grown/proc/make_dryable()
	AddElement(/datum/element/dryable, type)

/obj/item/food/grown/make_leave_trash()
	if(trash_type)
		AddElement(/datum/element/food_trash, trash_type, FOOD_TRASH_OPENABLE, TYPE_PROC_REF(/obj/item/food/grown/, generate_trash))
	return

///Callback for bonus behavior for generating trash of grown food.
/obj/item/food/grown/proc/generate_trash(atom/location)
	return new trash_type(location, seed)

/obj/item/food/grown/grind_requirements()
	if(dry_grind && !HAS_TRAIT(src, TRAIT_DRIED))
		to_chat(usr, span_warning("[src] needs to be dry before it can be ground up!"))
		return
	return TRUE

/obj/item/food/grown/grind(datum/reagents/target_holder, mob/user)
	if(on_grind() == -1)
		return FALSE

	var/grind_results_num = LAZYLEN(grind_results)
	if(grind_results_num)
		var/total_nutriment_amount = reagents.get_reagent_amount(/datum/reagent/consumable/nutriment, include_subtypes = TRUE)
		var/single_reagent_amount = grind_results_num > 1 ? round(total_nutriment_amount / grind_results_num, CHEMICAL_QUANTISATION_LEVEL) : total_nutriment_amount
		reagents.remove_all_type(/datum/reagent/consumable/nutriment, total_nutriment_amount)
		for(var/reagent in grind_results)
			reagents.add_reagent(reagent, single_reagent_amount)

	if(reagents && target_holder)
		reagents.trans_to(target_holder, reagents.total_volume, transfered_by = user)
	return TRUE

/obj/item/food/grown/dropped(mob/user, silent)
	. = ..()
	if(GetComponent(/datum/component/slippery))
		log_game("[key_name(user)] dropped \"slippery\" [src]/Location: [AREACOORD(src)]")
		user.investigate_log("dropped \"slippery\" [src]/Location: [AREACOORD(src)]", INVESTIGATE_BOTANY)
