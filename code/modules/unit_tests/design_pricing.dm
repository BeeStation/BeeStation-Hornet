/// Tests that autolathe designs have reasonable item values compared to their material costs
/datum/unit_test/autolathe_design_value_check

/datum/unit_test/autolathe_design_value_check/Run()
	// Material datum values
	var/static/list/material_values = list()
	if(!material_values.len)
		for(var/material_type in list(
			/datum/material/iron,
			/datum/material/glass,
			/datum/material/silver,
			/datum/material/gold,
			/datum/material/copper,
			/datum/material/plasma,
			/datum/material/uranium,
			/datum/material/diamond,
			/datum/material/titanium
		))
			var/datum/material/mat = new material_type()
			material_values[material_type] = mat.value_per_unit || 0.001 // Default fallback
			qdel(mat)

	// List of designs that are exempt from the test (wacky material conversions)
	var/static/list/exempted_designs = list(
		/datum/design/rcd_ammo,
	)

	var/designs_tested = 0
	var/designs_failed = 0

	for(var/design_type in subtypesof(/datum/design) - exempted_designs)
		var/datum/design/design = new design_type()

		// limit it to autolathe designs
		if(!(design.build_type & AUTOLATHE))
			qdel(design)
			continue

		// Skip designs without materials or build_path
		if(!design.materials?.len || !design.build_path)
			qdel(design)
			continue

		designs_tested++

		// Calculate total material cost
		var/total_material_cost = 0
		for(var/material_type in design.materials)
			var/material_amount = design.materials[material_type]
			var/material_value = material_values[material_type] || 0.001 // Default fallback
			total_material_cost += material_amount * material_value

		// Create the item
		var/obj/item/created_item = allocate(design.build_path)
		var/item_value = 0

		if(created_item.custom_price)
			item_value = created_item.custom_price
		else
			// Skip items without custom_price
			qdel(design)
			continue

		// Define acceptable value ranges
		// Item should be worth at least 50% of material cost (not worthless)
		var/min_acceptable_value = total_material_cost * 0.5
		// Item should not be worth more than 3x material cost (not overpowered)
		var/max_acceptable_value = total_material_cost * 3

		// Special cases for very cheap items (avoid division by zero issues)
		if(total_material_cost < 50)
			min_acceptable_value = 1
			max_acceptable_value = total_material_cost * 20

		// Check if within acceptable range
		if(item_value < min_acceptable_value)
			TEST_FAIL("Design '[design.name]' ([design.type]) produces item worth [item_value] credits, but materials cost [total_material_cost] units. Item may be undervalued (ratio: [round(item_value/total_material_cost*100, 0.1)]%).")
			designs_failed++
		else if(item_value > max_acceptable_value)
			TEST_FAIL("Design '[design.name]' ([design.type]) produces item worth [item_value] credits, but materials cost [total_material_cost] units. Item may be overvalued (ratio: [round(item_value/total_material_cost*100, 0.1)]%).")
			designs_failed++

		qdel(design)

	if(designs_tested == 0)
		TEST_FAIL("No autolathe designs with custom_price found to test")
	else if(designs_failed > 0)
		TEST_FAIL("[designs_failed] out of [designs_tested] autolathe designs have questionable item values")
