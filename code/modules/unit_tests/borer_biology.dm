/// IPCs remain valid hosts, but neither base regeneration nor gland upgrades provide chemicals.
/datum/unit_test/borer_ipc_chemicals

/datum/unit_test/borer_ipc_chemicals/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	host.set_species(/datum/species/ipc)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	TEST_ASSERT(borer.infest_human(host, BODY_ZONE_HEAD), "The borer could not infest an unprotected IPC.")
	TEST_ASSERT_EQUAL(borer.host, host, "IPC infestation did not bind the host.")
	borer.chemicals = 80
	borer.Life(delta_time = 2)
	TEST_ASSERT_EQUAL(borer.chemicals, 80, "An IPC supplied base chemical regeneration.")
	borer.evolution_points = 1
	TEST_ASSERT(borer.purchase_evolution(/datum/borer_evolution/efficient_glands), "Could not purchase Efficient Glands.")
	borer.Life(delta_time = 2)
	TEST_ASSERT_EQUAL(borer.chemicals, 80, "Efficient Glands bypassed the IPC regeneration restriction.")
	var/datum/borer_evolution/toggle_ability/arm_manifestation/manifest = locate(/datum/borer_evolution/toggle_ability/arm_manifestation) in borer.available_evolutions
	TEST_ASSERT_NOTNULL(manifest, "The borer has no arm manifestation to check.")
	TEST_ASSERT_EQUAL(manifest.get_chemical_drain(borer), 1, "Manifestation upkeep offset regeneration which the IPC does not provide.")
	host.mind_initialize()
	borer.mind_initialize()
	TEST_ASSERT(borer.transfer_host_control(), "Could not transfer control of the IPC.")
	borer.Life(delta_time = 2)
	TEST_ASSERT_EQUAL(borer.chemicals, 75, "IPC possession did not pay full upkeep without regeneration.")
	TEST_ASSERT(borer.release_host_control(), "Could not release control of the IPC.")

/// Health recovery uses the same ground-atmosphere check as eggs and never revives dead borers.
/datum/unit_test/borer_health_regeneration
	var/datum/gas_mixture/test_air
	var/list/original_moles

/datum/unit_test/borer_health_regeneration/Destroy()
	if(!QDELETED(test_air) && original_moles)
		test_air.moles = original_moles
	test_air = null
	original_moles = null
	return ..()

/datum/unit_test/borer_health_regeneration/Run()
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	var/obj/item/food/borer_egg/egg = allocate(/obj/item/food/borer_egg)
	var/turf/floor = get_turf(borer)
	test_air = floor.return_air()
	TEST_ASSERT_NOTNULL(test_air, "The test floor has no atmosphere.")
	original_moles = test_air.moles.Copy()
	egg.grown = TRUE
	borer.adjustHealth(10)
	test_air.moles = list(/datum/gas/oxygen = 1)
	borer.regenerate_health(10)
	TEST_ASSERT_EQUAL(borer.health, 10, "Oxygen alone healed the borer.")
	TEST_ASSERT(!egg.can_hatch(), "Oxygen alone allowed the egg to hatch.")
	test_air.moles = list(/datum/gas/plasma = 1)
	borer.regenerate_health(10)
	TEST_ASSERT_EQUAL(borer.health, 10, "Plasma alone healed the borer.")
	TEST_ASSERT(!egg.can_hatch(), "Plasma alone allowed the egg to hatch.")
	test_air.moles[/datum/gas/oxygen] = 1
	borer.regenerate_health(10)
	TEST_ASSERT_EQUAL(borer.health, 11, "Egg-hatching air did not restore one HP in ten seconds.")
	TEST_ASSERT(egg.can_hatch(), "The shared healing atmosphere did not allow egg hatching.")
	var/obj/item/storage/box/box = allocate(/obj/item/storage/box)
	borer.forceMove(box)
	borer.regenerate_health(10)
	TEST_ASSERT_EQUAL(borer.health, 11, "A contained borer used the floor's atmosphere to heal.")
	borer.forceMove(floor)
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/borer_cyst/cyst = allocate(/obj/item/organ/borer_cyst)
	cyst.configure(borer, BODY_ZONE_HEAD)
	TEST_ASSERT(cyst.Insert(host), "Could not enter the living host.")
	borer.regenerate_health(10)
	TEST_ASSERT_EQUAL(borer.health, 12, "Host healing did not apply exactly once in suitable surrounding air.")
	test_air.moles = list(/datum/gas/oxygen = 1)
	borer.regenerate_health(10)
	TEST_ASSERT_EQUAL(borer.health, 13, "A living host did not heal its borer in ordinary air.")
	borer.regenerate_health(1000)
	TEST_ASSERT_EQUAL(borer.health, borer.maxHealth, "Healing did not stop at maximum health.")
	borer.adjustHealth(10)
	host.death()
	borer.regenerate_health(10)
	TEST_ASSERT_EQUAL(borer.health, 10, "A dead host healed its borer.")
	borer.adjustHealth(100)
	TEST_ASSERT_EQUAL(borer.stat, DEAD, "The test borer did not die.")
	borer.regenerate_health(1000)
	TEST_ASSERT_EQUAL(borer.health, 0, "Passive healing restored a dead borer's health.")
	TEST_ASSERT_EQUAL(borer.stat, DEAD, "Passive healing revived a dead borer.")

/// Real shields slow takeover, fake shields do not; resistance can finish before possession starts.
/datum/unit_test/borer_mindshield_takeover

/datum/unit_test/borer_mindshield_takeover/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	host.mind_initialize()
	borer.mind_initialize()
	var/datum/mind/host_mind = host.mind
	TEST_ASSERT(borer.infest_human(host, BODY_ZONE_HEAD), "Infestation failed.")
	TEST_ASSERT_EQUAL(borer.get_host_control_windup(), 5 SECONDS, "Unshielded takeover is not five seconds.")
	ADD_TRAIT(host, TRAIT_FAKE_MINDSHIELD, REF(src))
	TEST_ASSERT_EQUAL(borer.get_host_control_windup(), 5 SECONDS, "A fake mindshield slowed takeover.")
	REMOVE_TRAIT(host, TRAIT_FAKE_MINDSHIELD, REF(src))
	var/started_at = world.time
	borer.control_attempt_duration = 5 SECONDS
	borer.control_attempt_ends_at = started_at + 5 SECONDS
	var/obj/item/implant/mindshield/implant = allocate(/obj/item/implant/mindshield)
	TEST_ASSERT(implant.implant(host, silent = TRUE), "Could not implant the test mindshield.")
	TEST_ASSERT_EQUAL(borer.get_host_control_windup(), 25 SECONDS, "A real mindshield did not slow takeover fivefold.")
	borer.update_control_windup()
	TEST_ASSERT_EQUAL(borer.control_attempt_ends_at, started_at + 25 SECONDS, "Mid-attempt implantation did not preserve elapsed time.")
	TEST_ASSERT_EQUAL(borer.control_attempt_progress.goal, 25 SECONDS, "The progress bar did not use the shielded duration.")
	implant.removed(host, silent = TRUE)
	borer.update_control_windup()
	TEST_ASSERT_EQUAL(borer.control_attempt_ends_at, started_at + 5 SECONDS, "Removing the shield did not restore the ordinary duration.")
	TEST_ASSERT(implant.implant(host, silent = TRUE), "Could not reimplant the mindshield.")
	borer.update_control_windup()
	borer.chemicals = 80
	TEST_ASSERT(borer.begin_control_resistance(host), "A shielded host could not resist the windup.")
	// Simulate a delayed processing tick on which both deadlines have elapsed.
	borer.control_attempt_ends_at = world.time
	borer.control_resist_ends_at = world.time
	borer.process_host_control()
	TEST_ASSERT(!borer.controlling_host, "Takeover beat an already completed struggle.")
	TEST_ASSERT_EQUAL(host.mind, host_mind, "The host's mind moved despite winning the struggle.")
	TEST_ASSERT_EQUAL(borer.chemicals, 80, "An unsuccessful takeover charged the activation cost.")
	TEST_ASSERT_EQUAL(borer.control_attempt_ends_at, 0, "Resistance did not cancel the pending takeover.")
	TEST_ASSERT_EQUAL(borer.control_attempt_duration, 0, "Resistance left a windup duration behind.")
	TEST_ASSERT_EQUAL(borer.next_host_control, world.time + 45 SECONDS, "Repelling takeover did not impose the cooldown.")
