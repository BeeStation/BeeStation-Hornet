/// Tests the fully heal flag [HEAL_ORGANS].
/datum/unit_test/full_heal_heals_organs

/datum/unit_test/full_heal_heals_organs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	for(var/obj/item/organ/organ in dummy.internal_organs)
		organ.applyOrganDamage(50)

	dummy.fully_heal(HEAL_ORGANS)

	for(var/obj/item/organ/organ in dummy.internal_organs)
		if(organ.damage <= 0)
			continue
		TEST_FAIL("Organ [organ] did not get healed by fullyheal flag HEAL_ORGANS.")

/// Tests the fully heal flag [HEAL_REFRESH_ORGANS].
/datum/unit_test/full_heal_regenerates_organs

/datum/unit_test/full_heal_regenerates_organs/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	var/list/we_started_with = list()

	for(var/obj/item/organ/organ in dummy.internal_organs)
		if(organ.organ_flags & ORGAN_VITAL) // leave this for now
			continue
		we_started_with += organ.type
		qdel(organ)

	TEST_ASSERT(length(we_started_with), "Dummy didn't spawn with any organs to regenerate.")

	dummy.fully_heal(HEAL_REFRESH_ORGANS)

	for(var/obj/item/organ/organ_type as anything in we_started_with)
		if(dummy.get_organ_by_type(organ_type))
			continue
		TEST_FAIL("Organ [initial(organ_type.name)] didn't regenerate in the dummy after fullyheal flag HEAL_REFRESH_ORGANS.")

/// Tests the fully heal combination flag [HEAL_DAMAGE].
/datum/unit_test/full_heal_damage_types

/datum/unit_test/full_heal_damage_types/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	dummy.take_direct_damage(10, BRUTE)
	dummy.take_direct_damage(10, BURN)
	dummy.take_direct_damage(10, TOX)
	dummy.take_direct_damage(10, OXY)
	dummy.take_direct_damage(10, CLONE)
	dummy.take_direct_damage(10, STAMINA)
	dummy.fully_heal(HEAL_DAMAGE)

	if(dummy.getBruteLoss())
		TEST_FAIL("The dummy still had brute damage after a fully heal!")
	if(dummy.getFireLoss())
		TEST_FAIL("The dummy still had burn damage after a fully heal!")
	if(dummy.getToxLoss())
		TEST_FAIL("The dummy still had toxins damage after a fully heal!")
	if(dummy.getOxyLoss())
		TEST_FAIL("The dummy still had oxy damage after a fully heal!")
	if(dummy.getCloneLoss())
		TEST_FAIL("The dummy still had clone damage after a fully heal!")
	if(dummy.getExhaustion())
		TEST_FAIL("The dummy still had stamina damage after a fully heal!")
