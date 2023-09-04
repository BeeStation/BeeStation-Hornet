/datum/unit_test/on_mob_end_metabolize/Run()
	SSmobs.pause()

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	var/datum/reagent/drug/methamphetamine/meth = /datum/reagent/drug/methamphetamine

	// Give them enough meth to be consumed in 2 metabolizations
	pill.reagents.add_reagent(meth, initial(meth.metabolization_rate) * 1.9)
	pill.attack_mob_target(user, user)
	user.Life()

	TEST_ASSERT(user.reagents.has_reagent(meth), "User does not have meth in their system after consuming it")
	TEST_ASSERT(user.has_movespeed_modifier(/datum/reagent/drug/methamphetamine), "User consumed meth, but did not gain movespeed modifier")

	user.Life()
	TEST_ASSERT(!user.reagents.has_reagent(meth), "User still has meth in their system when it should've finished metabolizing")
	TEST_ASSERT(!user.has_movespeed_modifier(/datum/reagent/drug/methamphetamine), "User still has movespeed modifier despite not containing any more meth")

/datum/unit_test/on_mob_end_metabolize/Destroy()
	SSmobs.ignite()
	return ..()
