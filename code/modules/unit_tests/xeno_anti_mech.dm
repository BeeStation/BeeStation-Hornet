/// Trait source for traits these tests add by hand.
#define XENO_ANTI_MECH_TEST_TRAIT "xeno_anti_mech_test"

/// The rooted and seized traits stop a mech from stepping or turning, and the vehicle occupant signals fire.
/datum/unit_test/xeno_anti_mech_hooks
	/// How many COMSIG_MECHA_ROOTED_MOVE_ATTEMPT signals we saw
	var/rooted_attempts = 0
	/// How many COMSIG_VEHICLE_OCCUPANT_ADDED signals we saw
	var/occupants_added = 0
	/// How many COMSIG_VEHICLE_OCCUPANT_REMOVED signals we saw
	var/occupants_removed = 0

/datum/unit_test/xeno_anti_mech_hooks/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	RegisterSignal(mech, COMSIG_MECHA_ROOTED_MOVE_ATTEMPT, PROC_REF(on_rooted_attempt))
	RegisterSignal(mech, COMSIG_VEHICLE_OCCUPANT_ADDED, PROC_REF(on_occupant_added))
	RegisterSignal(mech, COMSIG_VEHICLE_OCCUPANT_REMOVED, PROC_REF(on_occupant_removed))

	// Control: with no traits, a move key turns the mech toward it.
	mech.setDir(SOUTH)
	mech.vehicle_move(NORTH)
	TEST_ASSERT_EQUAL(mech.dir, NORTH, "An unrestricted mech did not turn when told to move. The test setup is broken, not the traits.")

	mech.setDir(SOUTH)
	ADD_TRAIT(mech, TRAIT_MECHA_ROOTED, XENO_ANTI_MECH_TEST_TRAIT)
	COOLDOWN_RESET(mech, cooldown_vehicle_move)
	TEST_ASSERT(!mech.vehicle_move(NORTH), "A rooted mech was allowed to move.")
	TEST_ASSERT_EQUAL(mech.dir, SOUTH, "A rooted mech was allowed to turn.")
	TEST_ASSERT_EQUAL(rooted_attempts, 1, "A blocked move on a rooted mech did not send COMSIG_MECHA_ROOTED_MOVE_ATTEMPT.")
	REMOVE_TRAIT(mech, TRAIT_MECHA_ROOTED, XENO_ANTI_MECH_TEST_TRAIT)

	ADD_TRAIT(mech, TRAIT_MECHA_SEIZED, XENO_ANTI_MECH_TEST_TRAIT)
	COOLDOWN_RESET(mech, cooldown_vehicle_move)
	TEST_ASSERT(!mech.vehicle_move(NORTH), "A seized mech was allowed to move.")
	TEST_ASSERT_EQUAL(mech.dir, SOUTH, "A seized mech was allowed to turn.")
	TEST_ASSERT_EQUAL(rooted_attempts, 1, "A seized mech's blocked move was counted as a snare struggle.")
	REMOVE_TRAIT(mech, TRAIT_MECHA_SEIZED, XENO_ANTI_MECH_TEST_TRAIT)

	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human/consistent)
	mech.add_occupant(pilot)
	pilot.forceMove(mech)
	TEST_ASSERT_EQUAL(occupants_added, 1, "add_occupant() did not send COMSIG_VEHICLE_OCCUPANT_ADDED.")
	pilot.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(occupants_removed, 1, "Leaving the mech did not send COMSIG_VEHICLE_OCCUPANT_REMOVED.")

/datum/unit_test/xeno_anti_mech_hooks/proc/on_rooted_attempt(datum/source, direction)
	SIGNAL_HANDLER
	rooted_attempts++

/datum/unit_test/xeno_anti_mech_hooks/proc/on_occupant_added(datum/source, mob/occupant)
	SIGNAL_HANDLER
	occupants_added++

/datum/unit_test/xeno_anti_mech_hooks/proc/on_occupant_removed(datum/source, mob/occupant)
	SIGNAL_HANDLER
	occupants_removed++

#undef XENO_ANTI_MECH_TEST_TRAIT
