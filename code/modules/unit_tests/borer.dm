/// Possession must preserve mind ownership and keep the borer's antagonist information private.
/datum/unit_test/borer_host_control

/datum/unit_test/borer_host_control/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	host.mind_initialize()
	borer.mind_initialize()
	var/datum/mind/host_mind = host.mind
	var/datum/mind/borer_mind = borer.mind
	var/datum/antagonist/borer/antag = borer_mind.has_antag_datum(/datum/antagonist/borer)
	TEST_ASSERT_NOTNULL(antag, "The borer has no antagonist datum.")
	TEST_ASSERT(borer.infest_human(host, BODY_ZONE_HEAD), "Infestation failed.")

	TEST_ASSERT(borer.transfer_host_control(), "Takeover failed.")
	TEST_ASSERT_EQUAL(host.mind, borer_mind, "The borer's mind did not enter the host.")
	TEST_ASSERT_EQUAL(host_mind.current, borer.host_backseat, "The human's mind did not enter the backseat.")
	borer.host_backseat.mind_initialize()
	TEST_ASSERT(!host_mind.has_antag_datum(/datum/antagonist/borer), "Possession made the human a borer antagonist.")
	TEST_ASSERT_EQUAL(antag.ui_status(borer.host_backseat, GLOB.always_state), UI_CLOSE, "The human can access borer information.")
	TEST_ASSERT_EQUAL(antag.ui_status(host, GLOB.always_state), UI_INTERACTIVE, "The possessing borer cannot access its information.")

	TEST_ASSERT(borer.release_host_control(), "Release failed.")
	TEST_ASSERT_EQUAL(host.mind, host_mind, "Release did not restore the human's mind.")
	TEST_ASSERT_EQUAL(borer.mind, borer_mind, "Release did not restore the borer's mind.")
	TEST_ASSERT_NULL(borer.host_backseat, "Release left a backseat behind.")
	TEST_ASSERT_EQUAL(antag.owner, borer_mind, "Possession reassigned the borer antagonist.")
	TEST_ASSERT_EQUAL(antag.ui_status(host, GLOB.always_state), UI_CLOSE, "The released human can access borer information.")
