/// Pipe senses end on exit without removing vision granted by a host evolution.
/datum/unit_test/borer_vent_vision

/datum/unit_test/borer_vent_vision/Run()
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	var/obj/machinery/atmospherics/pipe/smart/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/smart/simple)
	var/turf/outside = get_turf(borer)
	TEST_ASSERT(!HAS_TRAIT(borer, TRAIT_THERMAL_VISION), "A loose borer has mob vision without an evolution.")
	TEST_ASSERT(!HAS_TRAIT(borer, TRAIT_NIGHT_VISION), "A loose borer has night vision without an evolution.")

	borer.move_into_vent(pipe)
	TEST_ASSERT(HAS_TRAIT_FROM(borer, TRAIT_THERMAL_VISION, VENTCRAWLING_TRAIT), "Entering a pipe did not grant mob vision.")
	TEST_ASSERT(HAS_TRAIT_FROM(borer, TRAIT_NIGHT_VISION, VENTCRAWLING_TRAIT), "Entering a pipe did not grant night vision.")
	TEST_ASSERT_EQUAL(borer.lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE, "Pipe vision did not reduce lighting opacity.")

	// A forced exit can leave the movement trait set until later cleanup.
	borer.forceMove(outside)
	TEST_ASSERT(!HAS_TRAIT(borer, TRAIT_THERMAL_VISION), "Mob vision persisted after a forced exit.")
	TEST_ASSERT(!HAS_TRAIT(borer, TRAIT_NIGHT_VISION), "Night vision persisted after a forced exit.")
	TEST_ASSERT_EQUAL(borer.lighting_alpha, initial(borer.lighting_alpha), "Lighting opacity did not reset after exit.")
	REMOVE_TRAIT(borer, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)

	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/borer_cyst/cyst = allocate(/obj/item/organ/borer_cyst)
	cyst.configure(borer, BODY_ZONE_HEAD)
	TEST_ASSERT(cyst.Insert(host), "Cyst insertion failed.")
	borer.evolution_points = 4
	TEST_ASSERT(borer.purchase_evolution(/datum/borer_evolution/head/night_vision), "Could not purchase Night Vision.")
	TEST_ASSERT(borer.purchase_evolution(/datum/borer_evolution/head/thermal_vision), "Could not purchase Thermal Vision.")
	borer.update_pipe_vision()
	TEST_ASSERT(HAS_TRAIT(borer, TRAIT_NIGHT_VISION), "Pipe vision cleanup removed the host evolution's night vision.")
	TEST_ASSERT(HAS_TRAIT(borer, TRAIT_THERMAL_VISION), "Pipe vision cleanup removed the host evolution's mob vision.")
	TEST_ASSERT(!HAS_TRAIT_FROM(borer, TRAIT_NIGHT_VISION, VENTCRAWLING_TRAIT), "A hosted borer retained vent night vision.")
	TEST_ASSERT(!HAS_TRAIT_FROM(borer, TRAIT_THERMAL_VISION, VENTCRAWLING_TRAIT), "A hosted borer retained vent mob vision.")

	borer.leave_host()
	borer.move_into_vent(pipe)
	borer.death()
	TEST_ASSERT(!HAS_TRAIT_FROM(borer, TRAIT_NIGHT_VISION, VENTCRAWLING_TRAIT), "A dead borer retained vent night vision.")
	TEST_ASSERT(!HAS_TRAIT_FROM(borer, TRAIT_THERMAL_VISION, VENTCRAWLING_TRAIT), "A dead borer retained vent mob vision.")
