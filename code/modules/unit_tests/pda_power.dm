/datum/unit_test/pda_power_consumption/Run()
	for (var/pda_path in subtypesof(/obj/item/modular_computer/tablet/pda))
		var/obj/item/modular_computer/tablet/pda/pda = allocate(pda_path)
		var/power_held = pda.get_power()
		TEST_ASSERT_EQUAL(pda.handle_power(1), TRUE, "The PDA tyoe [pda_path] failed its handle_power call when spawned.")
		var/power_consumption = pda.last_power_usage
		var/time_left = (power_held / power_consumption) SECONDS
		TEST_ASSERT_TRUE(time_left > 90 MINUTES, "PDA with path [pda_path] only had [time_left / (1 MINUTES)] of power when running no programs. It needs at least 90 minutes of runtime as to not frustrate players and to be a reasonably usable item.")
