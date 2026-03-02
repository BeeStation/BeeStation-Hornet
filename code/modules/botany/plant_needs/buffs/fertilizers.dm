/*
	Robust Harvest, increases harvest
*/
/datum/plant_need/reagent/buff/robust
	need_description = "Improves plant's next harvest by half its max harvest, apply before a harvest starts growing."
	reagent_needs = list(/datum/reagent/plantnutriment/robustharvestnutriment = 5, /datum/reagent/saltpetre = 2, /datum/reagent/plantnutriment/slimenutriment = 1, /datum/reagent/ammonia = 5)
	auto_threshold = TRUE

/datum/plant_need/reagent/buff/robust/apply_buff(__delta_time)
	. = ..()
	var/datum/plant_feature/body/body_feature = parent
	if(!istype(body_feature))
		return
	body_feature.max_harvest += max(1, initial(body_feature.max_harvest) / 2)

/datum/plant_need/reagent/buff/robust/remove_buff(__delta_time)
	. = ..()
	//TODO: make this turn off after the harvest signal - Racc
	var/datum/plant_feature/body/body_feature = parent
	if(!istype(body_feature))
		return
	body_feature.max_harvest -= max(1, initial(body_feature.max_harvest) / 2)

/*
	Generic healing template
*/
/datum/plant_need/reagent/buff/heal
	auto_threshold = TRUE
	///What percentage of missing health do we restore?
	var/restore = 0.2

/datum/plant_need/reagent/buff/heal/New(datum/plant_feature/_parent)
	need_description = "Heals a plant for [restore*100]% of its missing health."
	return ..()

/datum/plant_need/reagent/buff/heal/apply_buff(__delta_time)
	. = ..()
	var/datum/plant_feature/body/body_feature = parent
	if(!istype(body_feature))
		return
	body_feature.adjust_health(((initial(body_feature.health) - body_feature.health)*restore)*__delta_time)

//Tier 1, 10%
/datum/plant_need/reagent/buff/heal/tier_1
	reagent_needs = list(/datum/reagent/plantnutriment/eznutriment = 5, /datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/sugar = 5)
	restore = 0.1

//Tier 2, 30%
/datum/plant_need/reagent/buff/heal/tier_2
	reagent_needs = list(/datum/reagent/medicine/charcoal = 5, /datum/reagent/consumable/milk = 3, /datum/reagent/ammonia = 2, /datum/reagent/ash = 1, /datum/reagent/blood = 1,
	/datum/reagent/diethylamine = 1)
	restore = 0.3

//Tier 3, 50%
/datum/plant_need/reagent/buff/heal/tier_3
	reagent_needs = list(/datum/reagent/plantnutriment/slimenutriment = 1, /datum/reagent/water/holywater = 2, /datum/reagent/medicine/cryoxadone = 1.5, /datum/reagent/plantnutriment/left4zednutriment = 1)
	restore = 0.5
