#define GENERIC_TOXIN_DAMAGE 5

/*
	Toxin
	Generic toxin that damages the plant
*/
/datum/plant_need/reagent/buff/toxin
	reagent_needs = list(/datum/reagent/toxin = 1, /datum/reagent/consumable/ethanol = 5, /datum/reagent/fluorine = 1, /datum/reagent/chlorine = 1, /datum/reagent/phosphorus = 1,
	/datum/reagent/toxin/acid = 1, /datum/reagent/toxin/acid/fluacid = 0.5, /datum/reagent/toxin/plantbgone = 0.5, /datum/reagent/napalm = 1, /datum/reagent/toxin/plantbgone/weedkiller = 5,
	/datum/reagent/toxin/pestkiller = 1.5)
	auto_threshold = TRUE
	nectar_buff_duration = 0 SECONDS

/datum/plant_need/reagent/buff/toxin/New(datum/plant_feature/_parent)
	need_description = "This plant is susceptible to toxic reagents, which will damage the plant for [GENERIC_TOXIN_DAMAGE] health."
	return ..()

/datum/plant_need/reagent/buff/toxin/apply_buff(__delta_time)
	. = ..()
	var/datum/plant_feature/body/body_feature = parent
	if(!istype(body_feature))
		return
	body_feature.adjust_health(GENERIC_TOXIN_DAMAGE*__delta_time)

#undef GENERIC_TOXIN_DAMAGE
