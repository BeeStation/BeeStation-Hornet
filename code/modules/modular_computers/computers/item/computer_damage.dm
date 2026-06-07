/obj/item/modular_computer/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	var/component_probability = min(50, max(damage_amount*0.1, 1 - atom_integrity/max_integrity))
	switch(damage_flag)
		if(BULLET)
			component_probability = damage_amount * 0.5
		if(LASER)
			component_probability = damage_amount * 0.66
	if(component_probability)
		for(var/I in all_components)
			var/obj/item/computer_hardware/H = all_components[I]
			if(prob(component_probability))
				H.take_damage(round(damage_amount*0.5), damage_type, damage_flag, 0)


/obj/item/modular_computer/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		return ..()
	physical.visible_message("\The [src] breaks apart!")

	var/iron_to_drop = steel_sheet_cost / 2
	if(iron_to_drop >= 1)
		new /obj/item/stack/sheet/iron(drop_location(), iron_to_drop)

	for(var/port, component in all_components)
		if(prob(MC_PART_DROP_CHANCE))
			uninstall_component(component)	// Lets not just delete all components like that
		else
			qdel(component)
	return ..()
