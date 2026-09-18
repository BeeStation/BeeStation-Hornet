/obj/machinery/rnd/production/circuit_imprinter
	name = "circuit imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	circuit = /obj/item/circuitboard/machine/circuit_imprinter
	production_animation = "circuit_imprinter_ani"
	allowed_buildtypes = IMPRINTER

/obj/machinery/rnd/production/circuit_imprinter/calculate_efficiency()
	. = ..()
	// Same curve as the parent, but a circuit imprinter only has one manipulator, where a protolathe has two, so its tier counts double.
	var/total_rating = 1.2
	var/manipulator_upgrades = 0
	for(var/datum/stock_part/manipulator/M in component_parts)
		total_rating -= M.tier * 0.2
		manipulator_upgrades += (M.tier - 1) * 2
	total_rating = clamp(total_rating, 0, 1.2)
	if(total_rating == 0)
		efficiency_coeff = INFINITY
	else
		efficiency_coeff = 1/total_rating
	build_time_coeff = round(clamp(1 - (manipulator_upgrades / 15), 0.6, 1), 0.05)
