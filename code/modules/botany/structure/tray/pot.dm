/obj/item/plant_tray/pot
	name = "plant pot"
	icon_state = "pot_random"
	use_indicators = FALSE
	plumbing = FALSE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	interaction_flags_item = INTERACT_ITEM_ATTACK_HAND_PICKUP
	layer_offset = 1.2
	gain_weeds = FALSE

/obj/item/plant_tray/pot/Initialize(mapload)
	icon_state = "pot"
	. = ..()
	AddComponent(/datum/component/tactical)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_unwielded=10, force_wielded=10)
//Special tray stuff
	tray_component.set_substrate(/datum/plant_subtrate/fairy)
	tray_component.allow_substrate_change = FALSE
	RegisterSignal(src, COMSIG_PLANTER_PAUSE_PLANT, PROC_REF(catch_pause))

/obj/item/plant_tray/pot/Exited(atom/movable/leaving, direction)
	. = ..()
	var/datum/component/plant/plant_comp = leaving.GetComponent(/datum/component/plant)
	if(!plant_comp)
		return
//Fruit - Don't allow people to game pot's pause function
	//Deleted all fruit
	var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in plant_comp.plant_features
	if(!length(fruit_feature?.fruits))
		return
	for(var/obj/item/fruit as anything in fruit_feature?.fruits)
		fruit_feature?.fruits -= fruit
		qdel(fruit)
	SEND_SIGNAL(plant_comp, COMSIG_PLANT_ACTION_HARVEST)
//Body - Refund a yield since we just merc'd one
	var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in plant_comp.plant_features
	body_feature.yields += 1

/obj/item/plant_tray/pot/proc/catch_pause(datum/source)
	SIGNAL_HANDLER

	return TRUE

/*
	Variant that contains a random plant
	Used for hallway plants
*/
/obj/item/plant_tray/pot/random

/obj/item/plant_tray/pot/random/Initialize(mapload)
	. = ..()
//Plant a random seed
	var/obj/item/plant_seeds/preset/random/seed = SSbotany.get_seed()
	seed = new seed(src)
	var/datum/component/plant/plant_component = seed.plant(src, logic = TRUE)
//Add some bonus traits to it
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		//Add a random refraction reagent trait if its a fruit feature
		if(istype(feature, /datum/plant_feature/fruit))
			var/datum/plant_trait/refraction/reagent_trait = new /datum/plant_trait/refraction(feature)
			feature.plant_traits += reagent_trait
		//Remove possible duplicates - kind of a fucked up way of doing it tbh
		for(var/datum/plant_trait/trait as anything in feature.plant_traits)
			if(trait.allow_multiple)
				continue
			//Essentially just remove ourselves from the pool of possible random traits - Don't worry, this gets refilled!
			if(!SSbotany.unused_random_traits["[feature.trait_type_shortcut]"]) //For nectar, and any other weirdo future traits
				continue
			SSbotany.unused_random_traits["[feature.trait_type_shortcut]"] -= trait.type
		var/datum/plant_trait/trait = SSbotany.get_random_trait("[feature.trait_type_shortcut]")
		trait = new trait(feature)
		feature.plant_traits += trait
	//Update species ID to reflect new traits
	plant_component.compile_species_id()
//Needs
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		for(var/datum/plant_need/need as anything in feature.plant_needs)
			need.fufill_need(src)
