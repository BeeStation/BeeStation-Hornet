/datum/plant_trait/fruit/temperature
	name = "Heated Contents"
	desc = "The fruit rapidly heats its contents when triggered."
	///How hot or cold are we trying to make our reagents?
	var/target_temperature = 666
	///How many ticks to reach target
	var/target_coefficient = 0.25
	///Verb + friends for visible message
	var/temperature_verb = "heating up"

/datum/plant_trait/fruit/temperature/setup_fruit_parent()
	. = ..()
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))

/datum/plant_trait/fruit/temperature/catch_activate(datum/source)
	. = ..()
	if(QDELING(src) || QDELING(fruit_parent))
		return
	fruit_parent?.visible_message("<span class='warning'>[fruit_parent] starts [temperature_verb]!</span>")
	START_PROCESSING(SSobj, src)

/datum/plant_trait/fruit/temperature/process(delta_time)
	if(!fruit_parent.reagents)
		return ..()
	if(QDELING(src) || QDELING(fruit_parent))
		return ..()
	//This is just stolen from the chem heater
	fruit_parent.reagents.adjust_thermal_energy((target_temperature - fruit_parent.reagents.chem_temp) * target_coefficient * delta_time * SPECIFIC_HEAT_DEFAULT * fruit_parent.reagents.total_volume)
	fruit_parent.reagents.handle_reactions()

/*
	Cooling variant
*/
/datum/plant_trait/fruit/temperature/cold
	name = "Cooled Contents"
	desc = "The fruit rapidly cools its contents when triggered."
	target_temperature = -666
	target_coefficient = 0.25
	temperature_verb = "cooling down"
