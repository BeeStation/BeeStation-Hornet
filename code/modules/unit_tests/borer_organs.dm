/// Cyst extraction frees the borer without leaving its effects on the host.
/datum/unit_test/borer_extraction

/datum/unit_test/borer_extraction/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	var/obj/item/organ/borer_cyst/cyst = allocate(/obj/item/organ/borer_cyst)
	cyst.configure(borer, BODY_ZONE_L_ARM)
	TEST_ASSERT(cyst.Insert(host), "Cyst insertion failed.")
	TEST_ASSERT_EQUAL(borer.host, host, "Insertion did not bind the borer to the host.")
	TEST_ASSERT_EQUAL(borer.cyst, cyst, "Insertion did not assign the borer's cyst.")
	borer.evolution_points = 1
	TEST_ASSERT(borer.purchase_evolution(/datum/borer_evolution/arm/shock_dampening), "Could not purchase Shock Dampening.")
	TEST_ASSERT(HAS_TRAIT(host, TRAIT_SHOCKIMMUNE), "Shock Dampening did not affect the host.")

	cyst.Remove(host)
	TEST_ASSERT_NULL(borer.host, "Extraction left the borer bound to the host.")
	TEST_ASSERT_NULL(borer.cyst, "Extraction left the borer bound to the cyst.")
	TEST_ASSERT_NULL(cyst.borer, "The extracted cyst retained its borer.")
	TEST_ASSERT_EQUAL(borer.loc, get_turf(host), "Extraction did not release the borer onto the turf.")
	TEST_ASSERT(!HAS_TRAIT(host, TRAIT_SHOCKIMMUNE), "Extraction left Shock Dampening on the host.")

/// Severed limbs retain their borers, including when attached to a different host.
/datum/unit_test/borer_limb_transfer

/datum/unit_test/borer_limb_transfer/Run()
	var/mob/living/carbon/human/old_host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/new_host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	var/obj/item/organ/borer_cyst/cyst = allocate(/obj/item/organ/borer_cyst)
	cyst.configure(borer, BODY_ZONE_L_ARM)
	TEST_ASSERT(cyst.Insert(old_host), "Cyst insertion failed.")
	borer.evolution_points = 1
	TEST_ASSERT(borer.purchase_evolution(/datum/borer_evolution/arm/shock_dampening), "Could not purchase Shock Dampening.")
	var/obj/item/bodypart/limb = old_host.get_bodypart(BODY_ZONE_L_ARM)
	limb.drop_limb()
	TEST_ASSERT_NULL(borer.host, "Limb removal left the borer bound to its old host.")
	TEST_ASSERT_EQUAL(borer.cyst, cyst, "Limb removal detached the borer from its cyst.")
	TEST_ASSERT_EQUAL(borer.severed_limb, limb, "Limb removal did not assign the severed limb.")
	TEST_ASSERT_EQUAL(borer.loc, limb, "The borer did not move into the severed limb.")
	TEST_ASSERT(!HAS_TRAIT(old_host, TRAIT_SHOCKIMMUNE), "Limb removal left Shock Dampening on the old host.")

	var/obj/item/bodypart/replaced_limb = new_host.get_bodypart(BODY_ZONE_L_ARM)
	replaced_limb.drop_limb()
	TEST_ASSERT(limb.try_attach_limb(new_host), "Could not attach the infested limb to the new host.")
	TEST_ASSERT_EQUAL(borer.host, new_host, "Reattachment did not bind the borer to its new host.")
	TEST_ASSERT_NULL(borer.severed_limb, "Reattachment retained the severed limb reference.")
	TEST_ASSERT(HAS_TRAIT(new_host, TRAIT_SHOCKIMMUNE), "Reattachment did not apply Shock Dampening to the new host.")

	limb.drop_limb()
	limb.drop_organs()
	TEST_ASSERT_NULL(borer.cyst, "Opening the severed limb left the borer bound to its cyst.")
	TEST_ASSERT_NULL(borer.severed_limb, "Opening the severed limb retained the limb reference.")
	TEST_ASSERT_EQUAL(borer.loc, get_turf(limb), "Opening the severed limb did not release the borer.")
	qdel(limb)
	qdel(replaced_limb)

/// Migration's special removal must preserve the borer and cyst for reinsertion.
/datum/unit_test/borer_cyst_migration

/datum/unit_test/borer_cyst_migration/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/simple_animal/borer/borer = allocate(/mob/living/simple_animal/borer)
	var/obj/item/organ/borer_cyst/cyst = allocate(/obj/item/organ/borer_cyst)
	cyst.configure(borer, BODY_ZONE_L_ARM)
	TEST_ASSERT(cyst.Insert(host), "Cyst insertion failed.")

	borer.deactivate_evolutions(host)
	cyst.Remove(host, special = TRUE)
	TEST_ASSERT_EQUAL(borer.cyst, cyst, "Special removal detached the borer from its cyst.")
	TEST_ASSERT_EQUAL(cyst.borer, borer, "Special removal cleared the cyst's borer.")
	cyst.configure(borer, BODY_ZONE_CHEST)
	TEST_ASSERT(cyst.Insert(host, special = TRUE), "Cyst reinsertion failed.")
	TEST_ASSERT_EQUAL(borer.host, host, "Migration did not retain the host.")
	TEST_ASSERT_EQUAL(cyst.bodypart_owner, host.get_bodypart(BODY_ZONE_CHEST), "Migration did not move the cyst into the chest.")
	TEST_ASSERT_NULL(host.get_cortical_borer(BODY_ZONE_L_ARM), "Migration left a borer in the old zone.")
	TEST_ASSERT_EQUAL(host.get_cortical_borer(BODY_ZONE_CHEST), borer, "Migration did not register the borer in the new zone.")
