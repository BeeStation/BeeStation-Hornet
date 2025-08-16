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
	break_apart()

/obj/item/modular_computer/proc/break_apart()
	if(!(flags_1 & NODECONSTRUCT_1))
		physical.visible_message("\The [src] breaks apart!")
		var/turf/newloc = get_turf(src)
		new /obj/item/stack/sheet/iron(newloc, round(steel_sheet_cost/2))
		for(var/port in all_components)
			var/obj/item/computer_hardware/component = all_components[port]
			if(prob(MC_PART_DROP_CHANCE))
				uninstall_component(component)	// Lets not just delete all components like that
			else
				qdel(component)
	relay_qdel()
	qdel(src)
