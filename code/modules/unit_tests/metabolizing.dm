/datum/unit_test/on_mob_end_metabolize/Run()
	SSmobs.pause()

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/datum/reagent/drug/badminordrazine/badminordrazine = /datum/reagent/drug/badminordrazine

	// Give them enough badminordrazine to be consumed in 2 metabolizations
	pill.reagents.add_reagent(badminordrazine, initial(badminordrazine.metabolization_rate) * 1.9)
	pill.attack(user, user)
	user.Life()

	TEST_ASSERT(user.reagents.has_reagent(badminordrazine), "User does not have badminordrazine in their system after consuming it")
	TEST_ASSERT(user.has_movespeed_modifier(/datum/reagent/drug/badminordrazine), "User consumed badminordrazine, but did not gain movespeed modifier")

	user.Life()
	TEST_ASSERT(!user.reagents.has_reagent(badminordrazine), "User still has badminordrazine in their system when it should've finished metabolizing")
	TEST_ASSERT(!user.has_movespeed_modifier(/datum/reagent/drug/badminordrazine), "User still has movespeed modifier despite not containing any more badminordrazine")

/datum/unit_test/on_mob_end_metabolize/Destroy()
	SSmobs.ignite()
	return ..()
