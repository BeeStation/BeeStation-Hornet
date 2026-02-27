#define FRUIT_MINIMUM_BITES 2

/datum/plant_feature/fruit
	species_name = "testus testium"
	name = "fruit"
	icon = 'icons/obj/hydroponics/features/fruit.dmi'
	icon_state = "apple"
	feature_catagories = PLANT_FEATURE_FRUIT
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/pests, /datum/plant_need/reagent/buff/robust)
	trait_type_shortcut = /datum/plant_feature/fruit
	genetic_budget = 2

	///What kind of 'fruit' do we produce
	var/obj/item/fruit_product = /obj/item/food/grown/apple
	///list of fruit we have produced, yet to be harvested
	var/list/fruits = list()
	var/list/visual_fruits = list()

	///
	var/growth_time = PLANT_FRUIT_GROWTH_FAST
	var/growth_time_elapsed = 0
	var/list/growth_timers = list()
	var/list/o_transform = list()
	///Do we skip the grow animation? - For stuff like grass
	var/skip_animation = FALSE

	///Max amount of reagents we can impart onto our stupid fucking children
	var/total_volume = PLANT_FRUIT_VOLUME_MEDIUM

	///Fruit size for body compatibility
	var/fruit_size = PLANT_FRUIT_SIZE_SMALL

	///Colour override for greyscale fruits
	var/colour_override ="#fff"
	///Colourable features, if we don't colour the whole thing
	var/colour_overlay

	///Do we have an icon for bunching?
	var/bunch_icon
	var/mutable_appearance/bunch_appearance
	///How many fruits in a bunch?
	var/bunch_amount = 3

	///List of reagents this fruit has. Saves us making a unique trait for each one. (reagent = percentage)
	var/list/fast_reagents = list()

/datum/plant_feature/fruit/New(datum/component/plant/_parent)
	. = ..()
	if(colour_overlay)
		var/mutable_appearance/coloured_parts =  mutable_appearance(icon, colour_overlay, color = islist(colour_override) ? "#fff" : colour_override)
		feature_appearance.add_overlay(coloured_parts)
	else
		feature_appearance.color = islist(colour_override) ? "#fff" : colour_override
	//bunch icon
	if(bunch_icon)
		bunch_appearance = mutable_appearance(icon, bunch_icon)
	//Build our fast chemicals
	if(!length(fast_reagents))
		return
	for(var/datum/reagent/reagent as anything in fast_reagents)
		plant_traits += new /datum/plant_trait/reagent(src, reagent, fast_reagents[reagent])

/datum/plant_feature/fruit/Destroy(force, ...)
	. = ..()
	if(!catch_attack_hand(src, null) && parent)
		SEND_SIGNAL(parent, COMSIG_PLANT_ACTION_HARVEST, src, null, TRUE)

/datum/plant_feature/fruit/get_scan_dialogue()
	. = ..()
	. += "Fruit Volume: [total_volume]u\n"
	. += "Growth Time: [growth_time/10] seconds\n"
	. += "Fruit Size: [fruit_size]\n"

/datum/plant_feature/fruit/get_ui_data()
	. = ..()
	. += list(PLANT_DATA("Fruit Volume", "[total_volume]u"), PLANT_DATA("Growth Time", "[growth_time/10] SECONDS"), PLANT_DATA("Fruit Size", "[fruit_size]"), PLANT_DATA(null, null))

/datum/plant_feature/fruit/process(delta_time)
	var/obj/item/plant_tray/tray = parent.plant_item.loc
	var/paused = SEND_SIGNAL(tray, COMSIG_PLANTER_PAUSE_PLANT)
	if(!paused && !check_needs(delta_time))
		return
	if(!length(growth_timers))
		return
//Growing
	for(var/timer as anything in growth_timers)
		var/obj/effect/fruit_effect = visual_fruits[timer]
		//Archive the transform to preserve stuff done by body features
		o_transform[timer] = o_transform[timer] || fruit_effect.transform
		//If this is the first time it's being process, shrink it down and reval the alpha
		if(growth_timers[timer] == growth_time)
			fruit_effect.alpha = 255
			fruit_effect.transform = skip_animation ?  fruit_effect.transform.Scale(1, 1) : fruit_effect.transform.Scale(0.1, 0.1)
		growth_timers[timer] -= delta_time SECONDS
		//If our parent is eager to be an adult, used for pre-existing plants
		growth_timers[timer] = parent?.skip_growth ? 0 : growth_timers[timer]
		//Visuals
		if(!fruit_effect) //This can be null when we fuck around with bunching
			continue
		if(!skip_animation) //Need to animate before we can offload, so don't change this to an early return
			var/matrix/new_transform = matrix(o_transform[timer])
			var/progress = min(1, max(0.1, abs(growth_timers[timer]-growth_time) / growth_time))
			new_transform.Scale(progress, progress)
			animate(fruit_effect, transform = new_transform, time = delta_time SECONDS, flags = ANIMATION_PARALLEL)
		//Offload finished fruits
		if(growth_timers[timer] <= 0)
			growth_timers -= timer
			visual_fruits -= timer
			build_fruit()

/datum/plant_feature/fruit/setup_parent(_parent, reset_features)
//Reset
	for(var/timer as anything in growth_timers)
		deltimer(growth_timers[timer])
	for(var/fruit as anything in fruits)
		fruits -= fruit
		qdel(fruit)
	if(parent)
		UnregisterSignal(parent, COMSIG_PLANT_REQUEST_FRUIT)
		UnregisterSignal(parent.plant_item, COMSIG_ATOM_ATTACK_HAND)
	. = ..()
//Pass over
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_PLANT_REQUEST_FRUIT, PROC_REF(setup_fruit))
	RegisterSignal(parent.plant_item, COMSIG_ATOM_ATTACK_HAND, PROC_REF(catch_attack_hand))
	RegisterSignal(parent.plant_item, COMSIG_ATOM_ATTACKBY, PROC_REF(catch_attackby))
	START_PROCESSING(SSobj, src)

/datum/plant_feature/fruit/proc/setup_fruit(datum/source, harvest_amount, list/_visual_fruits, skip_growth = FALSE)
	SIGNAL_HANDLER

	var/bunch_debt = 0
	for(var/fruit_index in 1 to harvest_amount)
	//Build our yummy fruit :)
		growth_timers["[fruit_index]"] = skip_growth ? 0 : growth_time
	//bunch logic
		var/bunch = FALSE
		if(floor((harvest_amount-fruit_index)/bunch_amount) >= 1 && bunch_debt <= 0 && bunch_icon)
			bunch_debt += bunch_amount
			bunch = TRUE
		if(bunch_debt > 0 && !bunch)
			bunch_debt--
			continue
	//Give away an overlay as a gift
		var/obj/effect/fruit_effect = new()
		fruit_effect.appearance = bunch ? bunch_appearance : feature_appearance
		if(islist(colour_override))
			fruit_effect.color = pick(colour_override)
		fruit_effect.alpha = 0 //Fruits shouldn't fuck with alpha, use colour instead - Make the alpha 0 until we start animating
		fruit_effect.vis_flags = VIS_INHERIT_ID
		_visual_fruits += fruit_effect
		visual_fruits["[fruit_index]"] = fruit_effect

/datum/plant_feature/fruit/proc/build_fruit()
//Fruit setup
	var/obj/item/food/grown/new_fruit = new fruit_product(parent.plant_item)
	if(istype(new_fruit))
		new_fruit.seed = null //Otherwise this will overwrite our inherited genes
	new_fruit.create_reagents(total_volume)
	if(istype(new_fruit))
		new_fruit.bite_consumption = new_fruit.reagents.maximum_volume / (new_fruit.bite_consumption_mod + FRUIT_MINIMUM_BITES)
	var/trait_scale = max(trait_power * 0.3, 1)
	new_fruit.transform.Scale(trait_scale, trait_scale)
	SEND_SIGNAL(parent, COMSIG_FRUIT_PREPARE, new_fruit) //Used to prepare fruit characteristics, like making the reagents NO_REACT
//Genes
	new_fruit.AddElement(/datum/element/plant_genes, SSbotany.gene_cache["[parent.species_id]"], parent.species_id)
	fruits += new_fruit
	SEND_SIGNAL(parent, COMSIG_FRUIT_BUILT, new_fruit) //Used when we're done prepping the fruit and we want to add stuff to it, like reagents
	return new_fruit

/datum/plant_feature/fruit/proc/catch_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER

	var/obj/item/plant_tray/tray = parent?.plant_item?.loc
	if(!length(fruits) || SEND_SIGNAL(tray, COMSIG_PLANTER_PAUSE_PLANT))
		return
	var/list/temp_fruits = list()
	var/turf/T = user ? get_turf(user) : get_turf(parent.plant_item)
	for(var/obj/item/fruit as anything in fruits)
		fruits -= fruit
		temp_fruits += fruit
		fruit.forceMove(T)
	SEND_SIGNAL(parent, COMSIG_PLANT_ACTION_HARVEST, user, temp_fruits, FALSE)
	return TRUE

/datum/plant_feature/fruit/proc/catch_attackby(datum/source, obj/item/storage/bag/plants/item, mob/living/user, params)
	SIGNAL_HANDLER

	//Dupe-ish code but what are ya gonna do?
	if(!istype(item, /obj/item/storage/bag/plants))
		return
	var/obj/item/plant_tray/tray = parent.plant_item.loc
	if(!length(fruits) || SEND_SIGNAL(tray, COMSIG_PLANTER_PAUSE_PLANT))
		return
	var/list/temp_fruits = list()
	var/turf/T = user ? get_turf(user) : get_turf(parent.plant_item)
	for(var/obj/item/fruit as anything in fruits)
		fruits -= fruit
		temp_fruits += fruit
		fruit.forceMove(T)
		item.atom_storage?.attempt_insert(fruit, user, TRUE)
	SEND_SIGNAL(parent, COMSIG_PLANT_ACTION_HARVEST, user, temp_fruits, FALSE)
	return TRUE

#undef FRUIT_MINIMUM_BITES
