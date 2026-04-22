//Water
/datum/plant_need/reagent/water
	need_description = "The basic recipe required to sustain plant life."
	reagent_needs = list(/datum/reagent/water = 1, /datum/reagent/medicine/earthsblood = 0.1, /datum/reagent/consumable/sodawater = 0.5, /datum/reagent/consumable/milk = 0.09)
	auto_threshold = TRUE

/datum/plant_need/reagent/water/fufill_need(atom/location)
	location.reagents.add_reagent(/datum/reagent/water, location?.reagents.maximum_volume)

//Blood
/datum/plant_need/reagent/blood
	need_description = "This plant has acquired a taste for blood..."
	reagent_needs = list(/datum/reagent/blood = 0.3, /datum/reagent/medicine/earthsblood = 1)
	auto_threshold = TRUE
	overdraw_need = TRUE

//Milk
/datum/plant_need/reagent/milk
	need_description = "This plant wants milk."
	reagent_needs = list(/datum/reagent/consumable/milk = 0.3, /datum/reagent/medicine/earthsblood = 1)
	auto_threshold = TRUE
	overdraw_need = TRUE

//Kelotane
/datum/plant_need/reagent/kelotane
	need_description = "This plant needs kelotane to stabilize its biology."
	reagent_needs = list(/datum/reagent/medicine/kelotane = 0.1, /datum/reagent/medicine/earthsblood = 1)
	auto_threshold = TRUE
	overdraw_need = TRUE

//Bicaridine
/datum/plant_need/reagent/bicaridine
	need_description = "This plant needs bicaridine to stabilize its biology."
	reagent_needs = list(/datum/reagent/medicine/bicaridine = 0.1, /datum/reagent/medicine/earthsblood = 1)
	auto_threshold = TRUE
	overdraw_need = TRUE
