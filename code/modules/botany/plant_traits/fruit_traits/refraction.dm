/datum/plant_trait/refraction
	name = "Experimental Refraction Gene"
	desc = "This trait will attempt to sequence plant DNA to produce a reagent, based on the refraction coordinates associated with it. Failing a sequence will destroy the plant's DNA on maturation."
	plant_feature_compat = /datum/plant_feature/fruit
	random_trait = FALSE //We already appear in every random plant
	///Our refraction reagent
	var/datum/reagent/refraction_reagent
	//For inheritence
	var/grid_x
	var/grid_y
	var/level

/datum/plant_trait/refraction/New(datum/plant_feature/_parent, _grid_x, _grid_y, _level)
	. = ..()
	if(!length(SSbotany.refraction_reagents))
		return
	grid_x = _grid_x
	grid_y = _grid_y
	level = _level || GRID_MAX_ACCURACY
	if(!grid_x && !grid_y) //If no supplied coordinates, aka we're a random trait, pick a random reagent to rep
		var/reagent = pick(SSbotany.refraction_reagents["[level]"])
		grid_x = SSbotany.refraction_reagents["[level]"][reagent][GRID_REAGENT_POSITION][1]
		grid_y = SSbotany.refraction_reagents["[level]"][reagent][GRID_REAGENT_POSITION][2]
	refraction_reagent = text2path(SSbotany.refraction_coords["[level]"]["[grid_x]:[grid_y]"])
	name = "[name] ([level])([grid_x], [grid_y])"

/datum/plant_trait/refraction/copy(datum/plant_feature/_parent, datum/plant_trait/_trait)
	var/datum/plant_trait/new_trait = _trait || new type(_parent, grid_x, grid_y, level)
	return new_trait

/datum/plant_trait/refraction/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_BUILT, PROC_REF(prepare_fruit))

/datum/plant_trait/refraction/proc/prepare_fruit(datum/source, obj/item/fruit)
	SIGNAL_HANDLER

//Kill the plant if the trait failed
	if(!refraction_reagent)
		var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in parent.parent?.plant_features
		body_feature?.yields = 0
		body_feature?.adjust_health(body_feature.health*-1)
		body_feature?.catch_harvest()
		return
//Add reagent
	var/datum/plant_feature/fruit/fruit_feature = parent
	var/obj/item/_fruit_parent = parent
	var/target_volume = 1
	if(istype(fruit_feature))
		target_volume = fruit_feature.total_volume
	else if(istype(_fruit_parent))
		target_volume = _fruit_parent.reagents?.maximum_volume
	fruit.reagents?.add_reagent(refraction_reagent, (0.05 * parent.trait_power) * target_volume)

