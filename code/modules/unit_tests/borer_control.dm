/// Early resistance survives movement and possession, and cannot be accelerated by repeated presses.
/datum/unit_test/borer_control_resistance

/datum/unit_test/borer_control_resistance/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	var/obj/item/organ/borer_cyst/cyst = allocate(/obj/item/organ/borer_cyst)
	host.mind_initialize()
	borer.mind_initialize()
	var/datum/mind/host_mind = host.mind
	cyst.configure(borer, BODY_ZONE_HEAD)
	TEST_ASSERT(cyst.Insert(host), "Cyst insertion failed.")
	borer.control_attempt_ends_at = world.time + 5 SECONDS
	SEND_SIGNAL(host, COMSIG_LIVING_RESIST, host)
	var/resist_deadline = borer.control_resist_ends_at
	TEST_ASSERT_EQUAL(resist_deadline, world.time + 12 SECONDS, "Resist did not start the twelve-second struggle.")
	SEND_SIGNAL(host, COMSIG_LIVING_RESIST, host)
	TEST_ASSERT_EQUAL(borer.control_resist_ends_at, resist_deadline, "Repeated Resist presses changed the struggle deadline.")

	var/turf/original_turf = get_turf(host)
	host.forceMove(get_step(host, EAST))
	TEST_ASSERT(borer.control_attempt_ends_at, "Host movement cancelled the takeover attempt.")
	TEST_ASSERT_EQUAL(borer.control_resist_ends_at, resist_deadline, "Host movement reset the struggle.")
	TEST_ASSERT(borer.transfer_host_control(), "Could not transfer host control.")
	TEST_ASSERT_EQUAL(borer.control_resist_ends_at, resist_deadline, "Takeover reset the early resistance deadline.")
	TEST_ASSERT_EQUAL(borer.control_resist_progress.user, borer.host_backseat, "The resistance progress bar did not follow the host's mind.")
	SEND_SIGNAL(host, COMSIG_LIVING_RESIST, host)
	TEST_ASSERT_EQUAL(borer.control_resist_ends_at, resist_deadline, "The controlling borer changed the host's struggle.")
	host.Paralyze(20 SECONDS)
	host.forceMove(original_turf)
	TEST_ASSERT_EQUAL(borer.control_resist_ends_at, resist_deadline, "A physical stun or movement cancelled mental resistance.")

	borer.control_resist_ends_at = world.time
	borer.process_host_control()
	TEST_ASSERT(!borer.controlling_host, "A completed struggle did not end possession.")
	TEST_ASSERT_EQUAL(host.mind, host_mind, "Resistance did not restore the host's mind.")
	TEST_ASSERT_NULL(borer.control_resist_progress, "Resistance left its progress bar behind.")
	TEST_ASSERT_EQUAL(borer.next_host_control, world.time + 45 SECONDS, "Successful resistance did not impose a takeover cooldown.")

/// The later window opens below 35% reserve OR after two minutes, not automatically on possession.
/datum/unit_test/borer_control_weakness

/datum/unit_test/borer_control_weakness/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	var/obj/item/organ/borer_cyst/cyst = allocate(/obj/item/organ/borer_cyst)
	host.mind_initialize()
	borer.mind_initialize()
	cyst.configure(borer, BODY_ZONE_HEAD)
	TEST_ASSERT(cyst.Insert(host), "Cyst insertion failed.")
	TEST_ASSERT(borer.transfer_host_control(), "Could not transfer host control.")
	borer.chemicals = 90
	TEST_ASSERT(!borer.is_host_control_weak(), "Fresh control with a large reserve was weak.")
	TEST_ASSERT(!borer.begin_control_resistance(borer.host_backseat), "The host could begin resisting strong control.")
	TEST_ASSERT_EQUAL(borer.control_resist_ends_at, 0, "Failed resistance started a struggle timer.")

	borer.chemicals = 35
	TEST_ASSERT(!borer.is_host_control_weak(), "Control weakened at exactly 35%, rather than below it.")
	borer.chemicals = 34.9
	TEST_ASSERT(borer.is_host_control_weak(), "Control did not weaken below 35%.")
	borer.max_chemicals = 150
	borer.chemicals = 52.5
	TEST_ASSERT(!borer.is_host_control_weak(), "Expanded Glands used the wrong 35% boundary.")
	borer.chemicals = 52.4
	TEST_ASSERT(borer.is_host_control_weak(), "Expanded Glands did not use a proportional threshold.")

	borer.chemicals = 140
	borer.control_started_at = world.time - 2 MINUTES
	TEST_ASSERT(!borer.is_host_control_weak(), "Control weakened before exceeding two minutes.")
	borer.control_started_at--
	TEST_ASSERT(borer.is_host_control_weak(), "Time alone did not open the resistance window.")
	borer.process_host_control()
	TEST_ASSERT(borer.control_weak_notice_sent, "Weak control did not notify the host.")
	TEST_ASSERT(borer.controlling_host, "The two-minute threshold automatically ended possession.")
	TEST_ASSERT_EQUAL(borer.control_resist_ends_at, 0, "Weakness automatically started resistance.")
	SEND_SIGNAL(borer.host_backseat, COMSIG_LIVING_RESIST, borer.host_backseat)
	TEST_ASSERT(borer.control_resist_ends_at > world.time, "The backseat's Resist did not start a struggle during weak control.")
	TEST_ASSERT(borer.release_host_control(), "The borer could not voluntarily release its host.")
	TEST_ASSERT_EQUAL(borer.next_host_control, world.time + 45 SECONDS, "Voluntary release bypassed an active struggle's cooldown.")

/// Gland upgrades keep their normal regeneration during possession, which still ends at zero reserve.
/datum/unit_test/borer_control_chemical_upkeep

/datum/unit_test/borer_control_chemical_upkeep/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	var/obj/item/organ/borer_cyst/cyst = allocate(/obj/item/organ/borer_cyst)
	host.mind_initialize()
	borer.mind_initialize()
	var/datum/mind/host_mind = host.mind
	cyst.configure(borer, BODY_ZONE_HEAD)
	TEST_ASSERT(cyst.Insert(host), "Cyst insertion failed.")
	TEST_ASSERT(borer.transfer_host_control(), "Could not transfer host control.")
	borer.chemicals = 90
	borer.Life(delta_time = 2)
	TEST_ASSERT_EQUAL(borer.chemicals, 87, "Base regeneration was not offset against control upkeep.")
	borer.max_chemicals = 150
	borer.chemical_regen_bonus = 1
	borer.chemicals = 140
	borer.Life(delta_time = 2)
	TEST_ASSERT_EQUAL(borer.chemicals, 139, "Efficient Glands did not retain normal regeneration.")
	borer.chemicals = 0.25
	borer.Life(delta_time = 1)
	TEST_ASSERT(!borer.controlling_host, "Zero chemicals did not automatically end possession.")
	TEST_ASSERT_EQUAL(host.mind, host_mind, "Chemical exhaustion did not return control to the host.")
