// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

CREATION_TEST_IGNORE_SELF(/obj/item/food/grown)

// Base type. Subtypes are found in /grown dir. Lavaland-based subtypes can be found in mining/ash_flora.dm
/obj/item/food/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "berrypile"
	worn_icon = 'icons/mob/clothing/head/hydroponics.dmi'
	name = "fresh produce" //fix naming bug
	max_volume = 100
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	/// type path, gets converted to item on New(). It's safe to assume it's always a seed item.
	var/obj/item/seeds/seed = null
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

/obj/item/food/grown/Initialize(mapload, obj/item/seeds/new_seed)
	if(!tastes)
		tastes = list("[name]" = 1) //This happens first else the component already inits

	if(new_seed)
		seed = new_seed.Copy()

	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)
	else if(!seed)
		stack_trace("Grown object created without a seed. WTF")
		return INITIALIZE_HINT_QDEL
	if(!pixel_y && !pixel_x)
		pixel_x = base_pixel_x + rand(-5, 5)
		pixel_y = base_pixel_y + rand(-5, 5)

	make_dryable()

	for(var/datum/plant_gene/trait/trait in seed.genes)
		trait.on_new(src, loc)

	// Set our default bitesize: bite size = 1 + (potency * 0.05) * (max_volume * 0.01) * modifier
	// A 100 potency, non-densified plant = 1 + (5 * 1 * modifier) = 6u bite size
	// For reference, your average 100 potency tomato has 14u of reagents - So, with no modifier it is eaten in 3 bites
	bite_consumption = 1 + round(max((seed.potency * BITE_SIZE_POTENCY_MULTIPLIER), 1) * (max_volume * BITE_SIZE_VOLUME_MULTIPLIER) * bite_consumption_mod)

	. = ..() //Only call it here because we want all the genes and shit to be applied before we add edibility. God this code is a mess.

	seed.prepare_result(src)
	transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5 //Makes the resulting produce's sprite larger or smaller based on potency!

	if(discovery_points)
		AddComponent(/datum/component/discoverable, discovery_points)

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

/obj/item/food/grown/examine(user)
	. = ..()
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.examine_line)
				. += T.examine_line

/obj/item/food/grown/attackby(obj/item/O, mob/user, params)
	..()
	if (istype(O, /obj/item/plant_analyzer))
		var/msg = "[span_info("This is \a [span_name(name)]")].\n"
		if(seed)
			msg += seed.get_analyzer_text()
		var/reag_txt = ""
		if(seed)
			for(var/reagent_id in seed.reagents_add)
				var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
				var/amt = reagents.get_reagent_amount(reagent_id)
				reag_txt += "\n[span_info("- [R.name]: [amt]")]"

		if(reag_txt)
			msg += reag_txt
		to_chat(user, examine_block(msg))
	else
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_attackby(src, O, user)


// Various gene procs
/obj/item/food/grown/attack_self(mob/user)
	if(seed && seed.get_gene(/datum/plant_gene/trait/squash))
		squash(user)
	..()

/obj/item/food/grown/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_throw_impact(src, hit_atom)
			if(seed.get_gene(/datum/plant_gene/trait/squash))
				squash(hit_atom)

/obj/item/food/grown/proc/squash(atom/target)
	var/turf/T = get_turf(target)
	forceMove(T)
	if(ispath(splat_type, /obj/effect/decal/cleanable/food/plant_smudge))
		if(filling_color)
			var/obj/O = new splat_type(T)
			O.color = filling_color
			O.name = "[name] smudge"
	else if(splat_type)
		new splat_type(T)

	visible_message(span_warning("[src] has been squashed."),span_italics("You hear a smack."))
	if(seed)
		for(var/datum/plant_gene/trait/trait in seed.genes)
			trait.on_squash(src, target)
	reagents.expose(T)
	for(var/A in T)
		reagents.expose(A)
	qdel(src)

/obj/item/food/grown/proc/squashreact()
	for(var/datum/plant_gene/trait/trait in seed.genes)
		trait.on_squashreact(src)
	qdel(src)

/obj/item/food/grown/proc/OnConsume(mob/living/eater, mob/living/feeder)
	if(iscarbon(usr))
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_consume(src, usr)

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
		var/investigated_plantname = seed.get_product_true_name_for_investigate()
		var/investigate_data = seed.get_gene_datas_for_investigate()
		log_game("[key_name(user)] dropped \"slippery\" [investigated_plantname]/[investigate_data]/Location: [AREACOORD(src)]")
		user.investigate_log("dropped \"slippery\" [investigated_plantname]/[investigate_data]/Location: [AREACOORD(src)]", INVESTIGATE_BOTANY)

#undef BITE_SIZE_POTENCY_MULTIPLIER
#undef BITE_SIZE_VOLUME_MULTIPLIER
