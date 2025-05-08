/obj/item/modular_computer/deal_damage(amount, penetration, type, flag, dir, sound, zone)
	. = ..()
	var/component_probability = min(50, max(amount*0.1, 1 - atom_integrity/max_integrity))
	switch(flag)
		if(DAMAGE_STANDARD)
			component_probability = amount * 0.5
		if(DAMAGE_LASER)
			component_probability = amount * 0.66
	if(component_probability)
		for(var/I in all_components)
			var/obj/item/computer_hardware/H = all_components[I]
			if(prob(component_probability))
				H.deal_damage(round(amount*0.5), penetration, type, flag, dir, FALSE, zone)


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
				H.take_direct_damage(rand(10,30), BRUTE)
	relay_qdel()
	qdel(src)
