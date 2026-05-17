//Only super duper common stuff lives here
/datum/plant_trait/reagent/fruit
	plant_feature_compat = /datum/plant_feature/fruit

//Nutriment
/datum/plant_trait/reagent/fruit/nutriment
	reagent = /datum/reagent/consumable/nutriment
	volume_percentage = PLANT_REAGENT_MEDIUM

/datum/plant_trait/reagent/fruit/nutriment/large
	volume_percentage = PLANT_REAGENT_LARGE

//Vitamin
/datum/plant_trait/reagent/fruit/vitamin
	reagent = /datum/reagent/consumable/nutriment/vitamin
	volume_percentage = PLANT_REAGENT_SMALL

/datum/plant_trait/reagent/fruit/vitamin/large
	volume_percentage = PLANT_REAGENT_MEDIUM
