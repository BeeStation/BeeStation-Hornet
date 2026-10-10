/datum/plant_trait/roots/no_weeds
	name = "Allelopathy"
	desc = "This gene causes roots to releasing root-inhibiting chemicals that prevent weeds from growing."
	genetic_cost = 1
	scales = "Weed removal rate scales with trait power."
	/// Amount of weeds we remove per cycle
	var/weed_remove = 0.3

/datum/plant_trait/roots/no_weeds/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_trait/roots/no_weeds/process(delta_time)
	var/datum/component/planter/plant_tray = parent.parent.plant_item.loc.GetComponent(/datum/component/planter)
	if(!plant_tray)
		return
	plant_tray.weed_level -= (weed_remove * parent.trait_power) * delta_time;
	plant_tray.weed_level = max(0, plant_tray.weed_level)
