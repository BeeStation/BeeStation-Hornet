/datum/unit_test/test_species_organs/Run()
	for (var/datum/species/species as anything in subtypesof(/datum/species))
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
		human.set_species(species)
		for (var/obj/item/organ/organ in human.internal_organs)
			// Find the bodypart that associates them
			var/good = FALSE
			for (var/obj/item/bodypart/part in human.bodyparts)
				if (organ.slot in part.organ_slots)
					if (good)
						TEST_FAIL("The species [species] has bodyparts which redefine the [organ.slot] organ slot multiple times.")
						break
					good = TRUE
			if (!good)
				TEST_FAIL("The species [species] has an organ ([organ]) which has no valid slot in the body.")
