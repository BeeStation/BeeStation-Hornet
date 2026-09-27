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

/// Four doses of xeno acid destroy a mech, whatever its armor.
/datum/unit_test/xeno_anti_mech_acid_kills

/datum/unit_test/xeno_anti_mech_acid_kills/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/datum/component/mecha_acid/acid = mech.LoadComponent(/datum/component/mecha_acid)
	for(var/dose in 1 to 4)
		acid.add_dose()
	TEST_ASSERT_EQUAL(acid.dose_count(), 4, "Four doses should give four burning doses.")
	for(var/second in 1 to MECHA_ACID_BURN_SECONDS)
		if(QDELETED(mech))
			break
		acid.process(1)
	TEST_ASSERT(QDELETED(mech), "Four doses of acid did not destroy the mech within [MECHA_ACID_BURN_SECONDS] seconds.")
	for(var/obj/structure/mecha_wreckage/wreck in run_loc_floor_bottom_left)
		qdel(wreck)

/// Washing a mech neutralizes the acid: the component is removed and the mech takes no more damage.
/datum/unit_test/xeno_anti_mech_acid_wash

/datum/unit_test/xeno_anti_mech_acid_wash/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/datum/component/mecha_acid/acid = mech.LoadComponent(/datum/component/mecha_acid)
	acid.add_dose()
	acid.process(1)
	acid.process(1)
	var/integrity_before_wash = mech.get_integrity()
	TEST_ASSERT(integrity_before_wash < mech.max_integrity, "A dose of acid did not burn the mech.")
	mech.wash(CLEAN_WASH)
	TEST_ASSERT(QDELETED(acid), "Washing the mech did not remove the acid.")
	TEST_ASSERT_NULL(mech.GetComponent(/datum/component/mecha_acid), "Washing left a mecha_acid component behind.")
	TEST_ASSERT_EQUAL(mech.get_integrity(), integrity_before_wash, "Washing should neither repair nor damage the mech.")

/// A dose on a mech whose systems are all already broken still burns, and reports no new failure.
/datum/unit_test/xeno_anti_mech_acid_no_systems_left

/datum/unit_test/xeno_anti_mech_acid_no_systems_left/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	mech.internal_damage = mech.possible_int_damage
	var/datum/component/mecha_acid/acid = mech.LoadComponent(/datum/component/mecha_acid)
	for(var/attempt in 1 to 10)
		TEST_ASSERT(!acid.break_system(), "break_system() reported a failure although every system was already broken.")
	acid.add_dose()
	TEST_ASSERT_EQUAL(acid.dose_count(), 1, "A dose on a fully broken mech was not added.")
	acid.process(1)
	TEST_ASSERT(mech.get_integrity() < mech.max_integrity, "A dose on a fully broken mech did not burn it.")

/// Pilots of an acid-coated mech get the smear and the alert, lose both on leaving or washing, and examine explains the acid.
/datum/unit_test/xeno_anti_mech_acid_ux

/datum/unit_test/xeno_anti_mech_acid_ux/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human/consistent)
	mech.add_occupant(pilot)
	pilot.forceMove(mech)
	var/datum/component/mecha_acid/acid = mech.LoadComponent(/datum/component/mecha_acid)
	acid.add_dose()
	TEST_ASSERT_NOTNULL(pilot.screens[FULLSCREEN_MECHA_ACID], "The pilot's optics were not smeared.")
	TEST_ASSERT_NOTNULL(pilot.alerts[ALERT_MECH_ACID], "The pilot did not get the Acid on Hull alert.")

	var/crew_view = jointext(mech.examine(pilot), "\n")
	TEST_ASSERT(findtext(crew_view, "bubbling alien acid"), "Examining an acid-coated mech did not mention the acid.")
	var/mob/living/carbon/alien/humanoid/drone/drone = allocate(/mob/living/carbon/alien/humanoid/drone)
	var/xeno_view = jointext(mech.examine(drone), "\n")
	TEST_ASSERT(findtext(xeno_view, "Four doses will melt it"), "Xenos examining an acid-coated mech were not told how many doses are burning.")

	pilot.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT_NULL(pilot.screens[FULLSCREEN_MECHA_ACID], "The smear followed the pilot out of the mech.")
	TEST_ASSERT_NULL(pilot.alerts[ALERT_MECH_ACID], "The acid alert followed the pilot out of the mech.")

	var/mob/living/carbon/human/second_pilot = allocate(/mob/living/carbon/human/consistent)
	mech.add_occupant(second_pilot)
	second_pilot.forceMove(mech)
	TEST_ASSERT_NOTNULL(second_pilot.screens[FULLSCREEN_MECHA_ACID], "A pilot climbing into an acid-coated mech was not smeared.")

	mech.wash(CLEAN_WASH)
	TEST_ASSERT_NULL(second_pilot.screens[FULLSCREEN_MECHA_ACID], "Washing did not clear the pilot's smear.")
	TEST_ASSERT_NULL(second_pilot.alerts[ALERT_MECH_ACID], "Washing did not clear the acid alert.")

/// Corrosive Acid on a mech applies a dose instead of silently failing against the mech's acid-proofing.
/datum/unit_test/xeno_anti_mech_corrosive_acid

/datum/unit_test/xeno_anti_mech_corrosive_acid/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/mob/living/carbon/alien/humanoid/drone/drone = allocate(/mob/living/carbon/alien/humanoid/drone)
	var/datum/action/alien/acid/corrosion/corrosion = locate() in drone.actions
	TEST_ASSERT_NOTNULL(corrosion, "Drones should have Corrosive Acid.")
	TEST_ASSERT(findtext(corrosion.desc, "main weapon against mechs"), "Corrosive Acid's description doesn't tell xenos it's their anti-mech weapon.")
	TEST_ASSERT(corrosion.on_activate(drone, mech), "Corrosive Acid failed on a mech.")
	var/datum/component/mecha_acid/acid = mech.GetComponent(/datum/component/mecha_acid)
	TEST_ASSERT_NOTNULL(acid, "Corrosive Acid on a mech did not apply mecha acid.")
	TEST_ASSERT_EQUAL(acid.dose_count(), 1, "One use of Corrosive Acid should be one dose.")

#undef XENO_ANTI_MECH_TEST_TRAIT
