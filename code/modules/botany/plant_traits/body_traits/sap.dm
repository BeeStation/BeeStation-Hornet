/*
	Makes this plant benehfit from polination, like nectar, but doesn't share the reward like nectar, offset by cost
*/
/datum/plant_trait/body/sap
	name = "Sap"
	desc = "Makes this plant benehfit from bee polination, this buff is not shared.\n	Polinated plants will regain over half their missing health, and all their buffs\
	will be active for a short duration."
	genetic_cost = 3
	///Quick reference to our parent's component parent
	var/datum/component/plant/plant_comp

/datum/plant_trait/body/sap/setup_component_parent(datum/source)
	. = ..()
	plant_comp = source
	if(!istype(plant_comp))
		plant_comp = null
		return
	RegisterSignal(plant_comp, COMSIG_PLANT_BEE_BUFF, PROC_REF(catch_bee))

/datum/plant_trait/body/sap/proc/catch_bee(datum/source)
	SIGNAL_HANDLER

//Basically copy pasted from nectar.dm with some tweaks to make it unique
//Visuals
	playsound(plant_comp.plant_item, 'sound/items/party_horn.ogg', 35, TRUE)
	plant_comp.plant_item.add_emitter(/obj/emitter/confetti, "confetti", 10, lifespan = 15)
//Help ourselves
	SEND_SIGNAL(plant_comp, COMSIG_PLANT_NECTAR_BUFF)
	var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in plant_comp.plant_features
	//Restores half of missing health every polination
	body_feature?.adjust_health((initial(body_feature.health) - body_feature.health)*0.75)
