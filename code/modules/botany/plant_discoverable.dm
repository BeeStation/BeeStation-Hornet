/*
	Equivilent for plants
	essentially looks at the plant's traits
*/

/datum/component/discoverable/plant

/datum/component/discoverable/plant/discovery_scan(datum/techweb/linked_techweb, mob/user)
//Pre-checks
	//Has it been scanned
	var/atom/atom_parent = parent
	if(scanned)
		to_chat(user, "<span class='warning'>[atom_parent] has already been analysed.</span>")
		return
	//Does it have a plant component
	var/datum/component/plant/plant_component = atom_parent.GetComponent(/datum/component/plant)
	if(!plant_component)
		return
//Check if this plant species is discovered or not
	var/discover_id = get_discover_id?.Invoke() || plant_component.species_id
	if(!unique && linked_techweb.scanned_atoms[discover_id])
		return
	if(atom_parent.flags_1 & HOLOGRAM_1)
		return
	scanned = TRUE
	linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, point_reward)
	linked_techweb.scanned_atoms[discover_id] = TRUE
	SSbotany.discovered_species |= discover_id
	playsound(user, 'sound/machines/terminal_success.ogg', 60)
	to_chat(user, span_notice("New datapoint scanned, [point_reward] discovery points gained."))
	pulse_effect(get_turf(atom_parent), 4)
