/datum/unit_test/stat_mc_validation/Run()
	main_loop:
		for (var/datum/controller/subsystem/ss in Master.subsystems)
			var/list/result = ss.stat_entry()
			// Rejected
			if (isnull(result))
				TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it returns null.")
				continue
			// Rejected for not returning a list
			if (!islist(result))
				TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it did not return a list.")
				continue
			// The list should be associative and contain stat types
			for (var/key in result)
				var/list/value = result[key]
				if (!islist(value))
					TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it does not properly use the new system of stat panel component types.")
					continue main_loop
				var/comp_type = value["type"]
				if (!comp_type)
					TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it does not properly use the new system of stat panel component types.")
					continue main_loop
				switch (comp_type)
					if (STAT_TEXT)
						var/text = value["text"]
						if (isnull(text))
							TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it contains a text component with no text parameter.")
							continue main_loop
						continue
					if (STAT_BUTTON)
						var/text = value["text"]
						var/action = value["action"]
						if (isnull(text) || isnull(action))
							TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it has a button which has either no text, or no action.")
							continue main_loop
						continue
					if (STAT_ATOM)
						var/text = value["text"]
						if (isnull(text))
							TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it contains an atom component with no text parameter.")
							continue main_loop
						continue
					if (STAT_DIVIDER)
						continue
					if (STAT_VERB)
						var/action = value["action"]
						if (isnull(action))
							TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it has a verb which has no action.")
							continue main_loop
						continue
					if (STAT_BLANK)
						continue
					else
						TEST_FAIL("The subsystem [ss.name] has an invalid stat_entry proc, it attempted to display a component with a type that was not recognised.")
						continue main_loop
