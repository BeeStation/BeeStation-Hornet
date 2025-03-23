/obj/item/modular_computer/apply_damage(amount, penetration, type = BRUTE, flag = null, dir = NONE, sound = TRUE)
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
				H.apply_damage(round(damage_amount*0.5), 0, damage_type, damage_flag, sound = 0)


/obj/item/modular_computer/deconstruct(disassembled = TRUE)
	break_apart()

/obj/item/modular_computer/proc/break_apart()
	if(!(flags_1 & NODECONSTRUCT_1))
		physical.visible_message("\The [src] breaks apart!")
		var/turf/newloc = get_turf(src)
		new /obj/item/stack/sheet/iron(newloc, round(steel_sheet_cost/2))
		for(var/C in all_components)
			var/obj/item/computer_hardware/H = all_components[C]
			if(QDELETED(H))
				continue
			uninstall_component(H)
			H.forceMove(newloc)
			if(prob(25))
				H.apply_damage(rand(10,30), 0, BRUTE, sound = 0)
	relay_qdel()
	qdel(src)
