/datum/unit_test/computer_smoothing

//This could potentially be revised to do an overall check for icon states of a smoothing atom to see if any are missing
/datum/unit_test/computer_smoothing/Run()
	var/atom/spawn_loc = run_loc_floor_bottom_left
	var/obj/machinery/computer/base = /obj/machinery/computer
	for(var/comp_type in subtypesof(/obj/machinery/computer))
		var/obj/machinery/computer/comp = comp_type
		if(isnull(initial(comp.smoothing_flags)))
			Fail("[comp_type] has smoothing_flags set to null instead of NONE!")
			continue
		//This will potentially pickup false positives if someone makes a subtype to a non-smoothing subtype, which smooths and uses its own icon state names
		//This is why we should refactor this to a smoothing test of smoothing states later on.
		if(initial(comp.icon_state) != initial(base.icon_state) && initial(comp.smoothing_flags) != NONE)
			Fail("[comp_type] is trying to smooth with a unique icon") //Can't use ASSERT_NOT_EQUAL, we want to get all the results.
