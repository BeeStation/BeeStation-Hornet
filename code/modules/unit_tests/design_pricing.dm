/// Tests that autolathe designs have reasonable item values compared to their material costs
/datum/unit_test/autolathe_design_value_check

/datum/unit_test/autolathe_design_value_check/Run()
	// Material value constants (based on typical SS13 economy)
	var/static/list/material_values = list(
		/datum/material/iron = 1,
		/datum/material/glass = 1,
		/datum/material/silver = 5,
		/datum/material/gold = 10,
		/datum/material/copper = 2,
		/datum/material/plasma = 15,
		/datum/material/uranium = 20,
		/datum/material/diamond = 50,
		/datum/material/titanium = 30
	)

	var/designs_tested = 0
	var/designs_failed = 0

	for(var/design_type in subtypesof(/datum/design))
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
			var/material_value = material_values[material_type] || 1 // Default to 1 if unknown
			total_material_cost += material_amount * material_value

		// Create the item
		var/obj/item/created_item = allocate(design.build_path)
		var/item_value = 0

		// Check if item has custom_price
		if(created_item.custom_price)
			item_value = created_item.custom_price
		else
			// Fallback to a basic calculation if no custom_price
			// This is a rough estimate based on material cost
			item_value = total_material_cost

		// Define acceptable value ranges
		// Item should be worth at least 50% of material cost (not worthless)
		var/min_acceptable_value = total_material_cost * 0.5
		// Item should not be worth more than 3x material cost (not overpowered)
		var/max_acceptable_value = total_material_cost * 3

		// Special cases for very cheap items (avoid division by zero issues)
		if(total_material_cost < 50)
			min_acceptable_value = 1
			max_acceptable_value = total_material_cost * 20

		// Check if item value is within acceptable range
		if(item_value < min_acceptable_value)
			TEST_FAIL("Design '[design.name]' ([design.type]) produces item worth [item_value] credits, but materials cost [total_material_cost] units. Item may be undervalued.")
			designs_failed++
		else if(item_value > max_acceptable_value)
			TEST_FAIL("Design '[design.name]' ([design.type]) produces item worth [item_value] credits, but materials cost [total_material_cost] units. Item may be overvalued.")
			designs_failed++

		qdel(design)

	if(designs_tested == 0)
		TEST_FAIL("No autolathe designs found to test")
	else if(designs_failed == 0)
		// Don't report success message to avoid spam
		return
	else
		TEST_FAIL("[designs_failed] out of [designs_tested] autolathe designs have questionable item values")
