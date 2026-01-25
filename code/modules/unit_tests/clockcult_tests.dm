/datum/unit_test/clockcult_slab_kindle/Run()
	var/mob/living/carbon/human/consistent/clockie = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/target = allocate(/mob/living/carbon/human/consistent)
	clockie.mind_initialize()
	clockie.mind.add_antag_datum(/datum/antagonist/servant_of_ratvar)
	clockie.drop_all_held_items()
	var/obj/item/clockwork/clockwork_slab/slab = allocate(/mob/living/carbon/human/consistent)
	clockie.put_in_active_hand(slab)
	usr = clockie
	slab.cogs = 1
	// Buy the scripture
	slab.ui_act("invoke", list(
		"scriptureName" = /datum/clockcult/scripture/slab/kindle::name
	))
	TEST_ASSERT(/datum/clockcult/scripture/slab/kindle in slab.purchased_scriptures, "Expected kindle to be unlocked")
	// Invoke the scripture
	slab.ui_act("invoke", list(
		"scriptureName" = /datum/clockcult/scripture/slab/kindle::name
	))
	TEST_ASSERT(istype(slab.active_scripture, /datum/clockcult/scripture/slab/kindle), "Expected kindle to be bound to the slab.")
	// Attack the target
	clockie.ClickOn(target)
	TEST_ASSERT(target.incapacitated(), "Expected target to be stunned when clicked on with kindle.")

/datum/unit_test/clockcult_slab_bind/Run()
	var/mob/living/carbon/human/consistent/clockie = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/target = allocate(/mob/living/carbon/human/consistent)
	clockie.mind_initialize()
	clockie.mind.add_antag_datum(/datum/antagonist/servant_of_ratvar)
	clockie.drop_all_held_items()
	var/obj/item/clockwork/clockwork_slab/slab = allocate(/mob/living/carbon/human/consistent)
	clockie.put_in_active_hand(slab)
	usr = clockie
	slab.cogs = 1
	// Buy the scripture
	slab.ui_act("invoke", list(
		"scriptureName" = /datum/clockcult/scripture/slab/hateful_manacles::name
	))
	TEST_ASSERT(/datum/clockcult/scripture/slab/hateful_manacles in slab.purchased_scriptures, "Expected hateful_manacles to be unlocked")
	// Invoke the scripture
	slab.ui_act("invoke", list(
		"scriptureName" = /datum/clockcult/scripture/slab/hateful_manacles::name
	))
	TEST_ASSERT(istype(slab.active_scripture, /datum/clockcult/scripture/slab/hateful_manacles), "Expected hateful_manacles to be bound to the slab.")
	// Attack the target
	clockie.ClickOn(target)
	TEST_ASSERT(target.handcuffed, "Expected target to be cuffed when hateful_manacles was used.")

