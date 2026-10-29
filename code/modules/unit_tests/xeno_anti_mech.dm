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

/// A space cleaner spray reaches the mech's tile and washes the acid off, instead of stopping at the hull.
/datum/unit_test/xeno_anti_mech_acid_spray_wash

/datum/unit_test/xeno_anti_mech_acid_spray_wash/Run()
	var/mob/living/carbon/human/janitor = allocate(/mob/living/carbon/human/consistent)
	var/turf/next_to_janitor = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand, next_to_janitor)
	var/datum/component/mecha_acid/acid = mech.LoadComponent(/datum/component/mecha_acid)
	acid.add_dose()
	var/obj/item/reagent_containers/spray/cleaner/bottle = allocate(/obj/item/reagent_containers/spray/cleaner)
	janitor.put_in_active_hand(bottle)

	bottle.spray(mech, janitor)
	var/obj/effect/decal/chempuff/puff = locate() in get_turf(janitor)
	TEST_ASSERT_NOTNULL(puff, "Test setup: spraying did not create a chem puff.")
	// The movement subsystem would take this step on its next tick; take it now.
	puff.move_packet.running_loop.process()
	TEST_ASSERT(QDELETED(acid), "Space cleaner sprayed at the mech never washed its acid off.")
	qdel(puff)

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

/// Pilots of an acid-coated mech get the alert (which comes and goes with the blur), lose it on leaving or washing, and examine explains the acid.
/datum/unit_test/xeno_anti_mech_acid_ux

/datum/unit_test/xeno_anti_mech_acid_ux/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human/consistent)
	mech.add_occupant(pilot)
	pilot.forceMove(mech)
	var/datum/component/mecha_acid/acid = mech.LoadComponent(/datum/component/mecha_acid)
	acid.add_dose()
	TEST_ASSERT_NOTNULL(pilot.alerts[ALERT_MECH_ACID], "The pilot did not get the Acid on Hull alert.")

	var/crew_view = jointext(mech.examine(pilot), "\n")
	TEST_ASSERT(findtext(crew_view, "bubbling alien acid"), "Examining an acid-coated mech did not mention the acid.")
	var/mob/living/carbon/alien/humanoid/drone/drone = allocate(/mob/living/carbon/alien/humanoid/drone)
	var/xeno_view = jointext(mech.examine(drone), "\n")
	TEST_ASSERT(findtext(xeno_view, "Four doses will melt it"), "Xenos examining an acid-coated mech were not told how many doses are burning.")

	pilot.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT_NULL(pilot.alerts[ALERT_MECH_ACID], "The acid alert followed the pilot out of the mech.")

	var/mob/living/carbon/human/second_pilot = allocate(/mob/living/carbon/human/consistent)
	mech.add_occupant(second_pilot)
	second_pilot.forceMove(mech)
	TEST_ASSERT_NOTNULL(second_pilot.alerts[ALERT_MECH_ACID], "A pilot climbing into an acid-coated mech did not get the acid alert.")

	mech.wash(CLEAN_WASH)
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

/// A snared mech stays rooted until the resin dries: XENO_SNARE_HOLD_SECONDS if the pilot never struggles.
/datum/unit_test/xeno_anti_mech_snare_decay

/datum/unit_test/xeno_anti_mech_snare_decay/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/datum/component/xeno_snare/snare = mech.AddComponent(/datum/component/xeno_snare)
	TEST_ASSERT(HAS_TRAIT_FROM(mech, TRAIT_MECHA_ROOTED, XENO_SNARE_TRAIT), "Snaring a mech did not root it.")
	for(var/second in 1 to XENO_SNARE_HOLD_SECONDS - 1)
		snare.process(1)
	TEST_ASSERT(!QDELETED(snare), "The snare dried before [XENO_SNARE_HOLD_SECONDS] seconds.")
	snare.process(1)
	TEST_ASSERT(QDELETED(snare), "The snare was still holding after [XENO_SNARE_HOLD_SECONDS] seconds.")
	TEST_ASSERT(!HAS_TRAIT(mech, TRAIT_MECHA_ROOTED), "The mech stayed rooted after the snare dried.")

/// Trying to move tears the resin, at most once per XENO_SNARE_STRUGGLE_COOLDOWN, until the mech breaks free.
/datum/unit_test/xeno_anti_mech_snare_struggle

/datum/unit_test/xeno_anti_mech_snare_struggle/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/datum/component/xeno_snare/snare = mech.AddComponent(/datum/component/xeno_snare)
	mech.vehicle_move(NORTH)
	TEST_ASSERT_EQUAL(snare.strength, XENO_SNARE_HOLD_SECONDS - XENO_SNARE_STRUGGLE_STRENGTH, "Trying to move did not weaken the snare.")
	COOLDOWN_RESET(mech, cooldown_vehicle_move)
	mech.vehicle_move(NORTH)
	TEST_ASSERT_EQUAL(snare.strength, XENO_SNARE_HOLD_SECONDS - XENO_SNARE_STRUGGLE_STRENGTH, "Struggles were not rate limited.")
	for(var/attempt in 1 to 20)
		if(QDELETED(snare))
			break
		COOLDOWN_RESET(mech, cooldown_vehicle_move)
		COOLDOWN_RESET(snare, struggle_cooldown)
		mech.vehicle_move(NORTH)
	TEST_ASSERT(QDELETED(snare), "Struggling never broke the snare.")
	TEST_ASSERT(!HAS_TRAIT(mech, TRAIT_MECHA_ROOTED), "The mech stayed rooted after struggling free.")

/// Snaring a snared mech refreshes the hold without freeing it, and washing doesn't dissolve resin.
/datum/unit_test/xeno_anti_mech_snare_refresh

/datum/unit_test/xeno_anti_mech_snare_refresh/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/datum/component/xeno_snare/snare = mech.AddComponent(/datum/component/xeno_snare)
	snare.process(5)
	var/datum/component/xeno_snare/again = mech.AddComponent(/datum/component/xeno_snare)
	TEST_ASSERT_EQUAL(again, snare, "Snaring a snared mech created a second snare.")
	TEST_ASSERT_EQUAL(snare.strength, XENO_SNARE_HOLD_SECONDS, "Snaring a snared mech did not refresh the hold.")
	TEST_ASSERT(HAS_TRAIT_FROM(mech, TRAIT_MECHA_ROOTED, XENO_SNARE_TRAIT), "Re-snaring a mech freed it.")
	mech.wash(CLEAN_WASH)
	TEST_ASSERT(!QDELETED(snare), "Washing dissolved the snare. Only struggling or drying should free the mech.")
	TEST_ASSERT(HAS_TRAIT(mech, TRAIT_MECHA_ROOTED), "Washing freed a snared mech.")

/// The pilot of a snared mech gets the Snared alert until it breaks, and examine tells everyone what's going on.
/datum/unit_test/xeno_anti_mech_snare_ux

/datum/unit_test/xeno_anti_mech_snare_ux/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human/consistent)
	mech.add_occupant(pilot)
	pilot.forceMove(mech)
	var/datum/component/xeno_snare/snare = mech.AddComponent(/datum/component/xeno_snare)
	TEST_ASSERT_NOTNULL(pilot.alerts[ALERT_MECH_SNARED], "The pilot of a snared mech did not get the Snared alert.")
	TEST_ASSERT(findtext(jointext(mech.examine(pilot), "\n"), "hardened resin"), "Examining a snared mech did not mention the resin.")
	var/mob/living/carbon/alien/humanoid/drone/drone = allocate(/mob/living/carbon/alien/humanoid/drone)
	TEST_ASSERT(findtext(jointext(mech.examine(drone), "\n"), "Our resin holds it"), "Xenos examining a snared mech did not get the hive line.")
	for(var/second in 1 to XENO_SNARE_HOLD_SECONDS)
		if(QDELETED(snare))
			break
		snare.process(1)
	TEST_ASSERT_NULL(pilot.alerts[ALERT_MECH_SNARED], "The Snared alert stayed after the resin dried.")

/// A mech destroyed while snared and acid-coated throws its pilot clear without leaving alerts or the smear on them.
/datum/unit_test/xeno_anti_mech_destroyed_while_afflicted

/datum/unit_test/xeno_anti_mech_destroyed_while_afflicted/Run()
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human/consistent)
	mech.add_occupant(pilot)
	pilot.forceMove(mech)
	mech.AddComponent(/datum/component/xeno_snare)
	var/datum/component/mecha_acid/acid = mech.LoadComponent(/datum/component/mecha_acid)
	for(var/dose in 1 to 4)
		acid.add_dose()
	for(var/second in 1 to MECHA_ACID_BURN_SECONDS)
		if(QDELETED(mech))
			break
		acid.process(1)
	TEST_ASSERT(QDELETED(mech), "Four doses did not destroy the snared mech.")
	TEST_ASSERT(isturf(pilot.loc), "The pilot was not thrown clear of the destroyed mech.")
	TEST_ASSERT_NULL(pilot.alerts[ALERT_MECH_SNARED], "The Snared alert survived the mech's destruction.")
	TEST_ASSERT_NULL(pilot.alerts[ALERT_MECH_ACID], "The acid alert survived the mech's destruction.")
	for(var/obj/structure/mecha_wreckage/wreck in run_loc_floor_bottom_left)
		qdel(wreck)

/// The snare mine is a passable, air-permeable floor patch that only mechs set off, built from the resin menu.
/datum/unit_test/xeno_anti_mech_snare_mine

/datum/unit_test/xeno_anti_mech_snare_mine/Run()
	var/turf/mine_turf = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/obj/structure/alien/resin_snare/mine = allocate(/obj/structure/alien/resin_snare, mine_turf)
	TEST_ASSERT(!mine.density, "The snare mine blocks movement.")
	TEST_ASSERT(!mine.opacity, "The snare mine blocks vision.")
	TEST_ASSERT_EQUAL(mine.can_atmos_pass, ATMOS_PASS_YES, "The snare mine blocks air.")
	// Weeds spreading onto the tile after the snare was laid must draw beneath it.
	var/obj/structure/alien/weeds/weeds = allocate(/obj/structure/alien/weeds, mine_turf)
	TEST_ASSERT(mine.plane == weeds.plane && mine.layer > weeds.layer, "Weeds growing onto a snare's tile draw over it.")

	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human/consistent)
	walker.forceMove(mine_turf)
	TEST_ASSERT(!QDELETED(mine), "A human set off a snare mine.")
	var/mob/living/carbon/alien/humanoid/drone/drone = allocate(/mob/living/carbon/alien/humanoid/drone)
	drone.forceMove(mine_turf)
	TEST_ASSERT(!QDELETED(mine), "A xeno set off a snare mine.")

	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand)
	mech.forceMove(mine_turf)
	TEST_ASSERT(QDELETED(mine), "A mech walked over a snare mine without setting it off.")
	TEST_ASSERT(HAS_TRAIT_FROM(mech, TRAIT_MECHA_ROOTED, XENO_SNARE_TRAIT), "The snare mine did not root the mech.")

	var/datum/action/alien/make_structure/resin/resin_action = locate() in drone.actions
	TEST_ASSERT_NOTNULL(resin_action, "Drones should have Secrete Resin.")
	TEST_ASSERT_EQUAL(resin_action.structures["resin snare"], /obj/structure/alien/resin_snare, "Secrete Resin can't build a resin snare.")
	TEST_ASSERT(findtext(resin_action.desc, "snare"), "Secrete Resin's description doesn't mention the snare.")

/// Crack Open refuses bad targets for free, pins the mech while held, and drags the human pilot out when it completes.
/// The action is granted to a drone: spawning a Queen registers a shuttle infestation and a game-end timer.
/datum/unit_test/xeno_anti_mech_crack_open

/datum/unit_test/xeno_anti_mech_crack_open/Run()
	var/mob/living/carbon/alien/humanoid/drone/drone = allocate(/mob/living/carbon/alien/humanoid/drone)
	var/datum/action/alien/crack_open/crack_open = new(drone)
	crack_open.Grant(drone)
	var/turf/next_to_drone = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand, next_to_drone)
	TEST_ASSERT(drone.getPlasma() >= crack_open.plasma_cost, "Test setup: the drone needs enough plasma for Crack Open.")

	// An empty mech is refused, and nothing is spent.
	var/plasma_before = drone.getPlasma()
	TEST_ASSERT(!crack_open.on_activate(drone, mech), "Crack Open accepted an empty mech.")
	TEST_ASSERT_EQUAL(drone.getPlasma(), plasma_before, "Crack Open spent plasma on an empty mech.")
	TEST_ASSERT(crack_open.is_available(), "Crack Open went on cooldown after an invalid target.")

	// The grab pins the mech. Letting go, even twice, frees it.
	crack_open.seize(mech)
	TEST_ASSERT(HAS_TRAIT_FROM(mech, TRAIT_MECHA_SEIZED, CRACK_OPEN_TRAIT), "Seizing a mech did not pin it.")
	TEST_ASSERT(findtext(jointext(mech.examine(drone), "\n"), "is tearing it open"), "Examining a seized mech did not say it's being torn open.")
	crack_open.release(mech)
	crack_open.release(mech)
	TEST_ASSERT(!HAS_TRAIT(mech, TRAIT_MECHA_SEIZED), "Releasing the grab left the mech pinned.")

	// Completing the channel drags the human pilot out onto the grabber's tile and leaves the mech intact.
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human/consistent)
	mech.add_occupant(pilot)
	pilot.forceMove(mech)
	crack_open.finish_crack_open(mech)
	TEST_ASSERT(!LAZYLEN(mech.occupants), "Crack Open left the pilot inside the mech.")
	TEST_ASSERT_EQUAL(pilot.loc, get_turf(drone), "The pilot was not dragged onto the Queen's tile.")
	TEST_ASSERT(pilot.IsKnockdown(), "The dragged-out pilot was not knocked down.")
	TEST_ASSERT(!QDELETED(mech), "Cracking open a human-piloted mech destroyed it.")

/// While the Queen holds a mech nothing moves her off her tile: not her own steps, not a pull, not a shove.
/datum/unit_test/xeno_anti_mech_crack_open_grip

/datum/unit_test/xeno_anti_mech_crack_open_grip/Run()
	var/turf/start = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 1, run_loc_floor_bottom_left.z)
	var/turf/north = get_step(start, NORTH)
	var/mob/living/carbon/alien/humanoid/drone/drone = allocate(/mob/living/carbon/alien/humanoid/drone, start)
	var/datum/action/alien/crack_open/crack_open = new(drone)
	crack_open.Grant(drone)
	var/obj/vehicle/sealed/mecha/durand/mech = allocate(/obj/vehicle/sealed/mecha/durand, get_step(start, EAST))
	var/mob/living/carbon/human/escort = allocate(/mob/living/carbon/human/consistent, get_step(start, SOUTH))

	crack_open.seize(mech)
	drone.Move(north, NORTH)
	TEST_ASSERT_EQUAL(drone.loc, start, "The Queen moved off her tile while holding a mech.")
	drone.disarm_effect(escort)
	TEST_ASSERT_EQUAL(drone.loc, start, "A shove pushed the Queen off her tile while she held a mech.")
	escort.start_pulling(drone)
	escort.Move(get_step(escort, WEST), WEST)
	TEST_ASSERT_EQUAL(drone.loc, start, "An escort dragged the Queen off her tile while she held a mech.")
	escort.stop_pulling()

	crack_open.release(mech)
	drone.Move(north, NORTH)
	TEST_ASSERT_EQUAL(drone.loc, north, "The Queen was still stuck in place after letting go.")

#undef XENO_ANTI_MECH_TEST_TRAIT
