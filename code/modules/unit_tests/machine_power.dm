/// use_power holds a mode, avoid wattage
/datum/unit_test/machine_power_modes/Run()
	var/list/valid_modes = list(NO_POWER_USE, IDLE_POWER_USE, ACTIVE_POWER_USE)
	var/list/errors = list()

	for(var/obj/machinery/machine_path as anything in subtypesof(/obj/machinery))
		var/mode = initial(machine_path.use_power)
		if(!(mode in valid_modes))
			errors += "[machine_path] declares use_power = [mode], which is not a power mode. \
				Use NO_POWER_USE, IDLE_POWER_USE or ACTIVE_POWER_USE, and set wattages with \
				idle_power_usage / active_power_usage."

	if(length(errors))
		TEST_FAIL(jointext(errors, "\n"))

/// Sanity so Inducers cannot dole out more power than they have
/datum/unit_test/inducer_conservation/Run()
	var/obj/item/inducer/inducer = allocate(/obj/item/inducer)
	var/obj/item/stock_parts/cell/target = allocate(/obj/item/stock_parts/cell/high)

	TEST_ASSERT_NOTNULL(inducer.cell, "Inducer spawned without a cell to test with")
	target.charge = 0

	// Sit below the charge rate
	inducer.cell.charge = round(inducer.cell.chargerate * 0.5)

	var/source_before = inducer.cell.charge
	var/total_before = source_before + target.charge

	inducer.induce(target)

	var/total_after = inducer.cell.charge + target.charge

	TEST_ASSERT(inducer.cell.charge < source_before, "Inducer transferred power without spending any of its own charge")
	TEST_ASSERT(total_after <= total_before, "Inducing below the charge rate created [total_after - total_before] units of power from nothing")

/// Machines that recompute their own draw must read a stable baseline
/datum/unit_test/holopad_power_stability/Run()
	var/obj/machinery/holopad/pad = allocate(/obj/machinery/holopad)

	pad.SetLightsAndPower()
	var/first_reading = pad.active_power_usage

	for(var/i in 1 to 10)
		pad.SetLightsAndPower()

	TEST_ASSERT_EQUAL(pad.active_power_usage, first_reading, "Holopad active power usage drifted across repeated updates with no change in users.")
