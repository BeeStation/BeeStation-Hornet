//Water
/datum/plant_need/reagent/water
	need_description = "The basic recipe required to sustain plant life."
	reagent_needs = list(/datum/reagent/water = 1, /datum/reagent/medicine/earthsblood = 0.01, /datum/reagent/consumable/sodawater = 0.5, /datum/reagent/consumable/milk = 0.09)
	auto_threshold = TRUE

/datum/plant_need/reagent/water/fufill_need(atom/location)
	location.reagents.add_reagent(/datum/reagent/water, location?.reagents.maximum_volume)

//Blood
/datum/plant_need/reagent/blood
	reagent_needs = list(/datum/reagent/blood = 0.3)
	success_threshold = 1
	overdraw_need = TRUE

//Milk
/datum/plant_need/reagent/milk
	reagent_needs = list(/datum/reagent/consumable/milk = 0.3)
	success_threshold = 1
	overdraw_need = TRUE
