/datum/plant_trait/roots/carnivore
	name = "Pesticide Secretions"
	desc = "This gene causes roots to develop pesticide secretions. Plants with this trait will destroy nearby pests."
	genetic_cost = 2

/datum/plant_trait/roots/carnivore/setup_parent(_parent)
	. = ..()
	if(istype(parent, /datum/plant_feature/roots/hyphae))
		parent = null
		qdel(src)
		return

/datum/plant_trait/roots/carnivore/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_trait/roots/carnivore/process(delta_time)
	var/datum/component/planter/plant_tray = parent.parent.plant_item.loc.GetComponent(/datum/component/planter)
	if(!plant_tray)
		return
	for(var/datum/component/plant/_plant_comp as anything in plant_tray.plants)
		SEND_SIGNAL(_plant_comp, COMSIG_PLANT_CARNI_BUFF, delta_time)
