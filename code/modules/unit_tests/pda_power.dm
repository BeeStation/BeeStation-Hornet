/datum/unit_test/pda_power_consumption/Run()
	var/list/errors = list()
	for (var/pda_path in subtypesof(/obj/item/modular_computer/tablet/pda))
		var/obj/item/modular_computer/tablet/pda/pda = allocate(pda_path)
		pda.enabled = TRUE
		var/power_held = pda.get_power()
		var/power_consumption = pda.calculate_power()
		if (!power_consumption)
			errors += "PDA of path [pda_path] has 0 power consumption when turned on."
			continue
		var/time_left = (power_held / power_consumption) SECONDS
		if (time_left < 90 MINUTES)
			errors += "PDA with path [pda_path] only had [time_left / (1 MINUTES)] minutes of power when running no programs. It needs at least 90 minutes of runtime as to not frustrate players and to be a reasonably usable item."
	if (length(errors))
		TEST_FAIL(jointext(errors, "\n"))
