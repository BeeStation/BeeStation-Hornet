/datum/plant_trait/nectar
	name = "Nectar"
	desc = "Makes this plant benehfit from bee polination, and spreads those buffs to all plants in the same tray.\n	Polinated plants will regain half their missing health, and all their buffs \
	will be active for a short duration."
	//plant_feature_compat = /datum/plant_feature/fruit/flower
	random_trait = FALSE
	///Quick reference to our parent's component parent
	var/datum/component/plant/plant_comp

/datum/plant_trait/nectar/setup_component_parent(datum/source)
	. = ..()
	plant_comp = source
	if(!istype(plant_comp))
		plant_comp = null
		return
	RegisterSignal(plant_comp, COMSIG_PLANT_BEE_BUFF, PROC_REF(catch_bee))

/datum/plant_trait/nectar/proc/catch_bee(datum/source)
	SIGNAL_HANDLER

//Visuals
	playsound(plant_comp.plant_item, 'sound/items/party_horn.ogg', 35, TRUE)
	plant_comp.plant_item.add_emitter(/obj/emitter/confetti, "confetti", 10, lifespan = 15)
//Help ourselves
	SEND_SIGNAL(plant_comp, COMSIG_PLANT_NECTAR_BUFF)
	var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in plant_comp.plant_features
	//Restores half of missing health every polination
	body_feature?.adjust_health((initial(body_feature.health) - body_feature.health)*0.5)
//Spread the love
	var/datum/component/planter/plant_tray = plant_comp.plant_item.loc.GetComponent(/datum/component/planter)
	if(!plant_tray)
		return
	for(var/datum/component/plant/_plant_comp as anything in plant_tray.plants)
		SEND_SIGNAL(_plant_comp, COMSIG_PLANT_NECTAR_BUFF)
		body_feature = locate(/datum/plant_feature/body) in _plant_comp.plant_features
		body_feature?.adjust_health((initial(body_feature.health) - body_feature.health)*0.5)
