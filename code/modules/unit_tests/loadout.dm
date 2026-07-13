/datum/unit_test/loadout
	abstract_type = /datum/unit_test/loadout

/datum/unit_test/loadout/proc/build_mock_client()
	var/datum/client_interface/mock_client = new
	mock_client.prefs = new /datum/preferences/mock()
	// Force preference so we don't get the 50:50 chance between jumpsuit and jumpskirt
	mock_client.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/jumpsuit_style], PREF_SUIT)
	return mock_client

/// Gear ids aren't static (assigned in New()), so we have to match by type
/datum/unit_test/loadout/proc/find_gear(gear_type)
	for(var/gear_id in GLOB.gear_datums)
		var/datum/gear/gear = GLOB.gear_datums[gear_id]
		if(gear.type == gear_type)
			return gear
	TEST_FAIL("Could not find gear datum of type [gear_type] - was it renamed or removed?")
	return null

/datum/unit_test/loadout/proc/equip_as_job(datum/job/job, list/gear_types, species_type, datum/client_interface/mock_client, mob_type = /mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/human = allocate(mob_type)
	if(species_type)
		human.set_species(species_type)
	human.mind_initialize()
	human.mind.set_assigned_role(job)

	if(!mock_client)
		mock_client = build_mock_client()
	for(var/gear_type in (gear_types || list()))
		var/datum/gear/gear = find_gear(gear_type)
		if(gear)
			mock_client.prefs.equipped_gear += gear.id

	human.on_job_equipping(job, FALSE, mock_client)
	return human

/// A loadout uniform and backpack pick should win over the job outfit's pre_equip()
/datum/unit_test/loadout/loadout_overrides_job_defaults

/datum/unit_test/loadout/loadout_overrides_job_defaults/Run()
	var/mob/living/carbon/human/human = equip_as_job(
		new /datum/job/assistant,
		list(/datum/gear/uniform/color/black, /datum/gear/donator/backpack/ian),
	)

	TEST_ASSERT_NOTNULL(human.w_uniform, "Human has no uniform equipped.")
	TEST_ASSERT_EQUAL(human.w_uniform.type, /obj/item/clothing/under/color/black, "Loadout uniform did not override the job's default uniform.")
	TEST_ASSERT_NOTNULL(human.back, "Human has nothing in their back slot.")
	TEST_ASSERT_EQUAL(human.back.type, /obj/item/storage/backpack/ian, "Loadout backpack did not override the job's backpack-style default.")

/// With no loadout gear selected, the job's pre_equip() defaults should still apply
/datum/unit_test/loadout/loadout_falls_back_to_job_default

/datum/unit_test/loadout/loadout_falls_back_to_job_default/Run()
	var/mob/living/carbon/human/human = equip_as_job(new /datum/job/assistant, list())

	TEST_ASSERT_NOTNULL(human.w_uniform, "Human has no uniform equipped.")
	TEST_ASSERT(istype(human.w_uniform, /obj/item/clothing/under/color), "Human's default uniform was not the expected random-color jumpsuit ([human.w_uniform]).")

/// Loadout items in the glasses slot should displace (not delete) the job's og glasses
/datum/unit_test/loadout/loadout_preserves_displaced_glasses

/datum/unit_test/loadout/loadout_preserves_displaced_glasses/Run()
	var/mob/living/carbon/human/human = equip_as_job(new /datum/job/chemist, list(/datum/gear/accessory/eyepatch))

	TEST_ASSERT_NOTNULL(human.glasses, "Human has nothing in their glasses slot.")
	TEST_ASSERT_EQUAL(human.glasses.type, /obj/item/clothing/glasses/eyepatch, "Loadout glasses did not override the job's default science goggles.")

	var/found_science_goggles = FALSE
	for(var/obj/item/item in human.get_all_gear())
		if(istype(item, /obj/item/clothing/glasses/science))
			found_science_goggles = TRUE
			break
	TEST_ASSERT(found_science_goggles, "Human's displaced science goggles were deleted instead of being preserved in their backpack.")

/// Plasmaman characters have the most restrictions and replacements, so they are the best to test
/datum/unit_test/loadout/plasmaman_species_outfit_and_restrictions

/datum/unit_test/loadout/plasmaman_species_outfit_and_restrictions/Run()
	var/mob/living/carbon/human/human = equip_as_job(
		new /datum/job/captain,
		list(/datum/gear/uniform/color/black, /datum/gear/hat/that),
		species_type = /datum/species/plasmaman,
	)

	TEST_ASSERT_NOTNULL(human.w_uniform, "Plasmaman has no uniform equipped.")
	TEST_ASSERT(istype(human.w_uniform, /obj/item/clothing/under/plasmaman), "Plasmaman did not receive their species_outfits envirosuit uniform ([human.w_uniform]).")
	TEST_ASSERT_NOTNULL(human.head, "Plasmaman has no headwear equipped.")
	TEST_ASSERT(istype(human.head, /obj/item/clothing/head/helmet/space/plasmaman), "Plasmaman did not receive their species_outfits helmet ([human.head]).")

	TEST_ASSERT_NOTEQUAL(human.w_uniform.type, /obj/item/clothing/under/color/black, "Species-blacklisted loadout uniform was equipped on a plasmaman.")

	TEST_ASSERT_NOTEQUAL(human.head.type, /obj/item/clothing/head/hats/tophat, "Loadout tophat overrode the plasmaman's helmet instead of being snowflaked.")
	var/found_tophat = FALSE
	for(var/obj/item/item in human.get_all_gear())
		if(istype(item, /obj/item/clothing/head/hats/tophat))
			found_tophat = TRUE
			break
	TEST_ASSERT(found_tophat, "Plasmaman's unrestricted loadout tophat was lost instead of being snowflaked into their backpack.")

/// Apid characters should be taught the honeycomb recipe when their job equipment is applied
/datum/unit_test/loadout/apid_species_outfit_teaches_recipe

/datum/unit_test/loadout/apid_species_outfit_teaches_recipe/Run()
	var/mob/living/carbon/human/human = equip_as_job(new /datum/job/assistant, list(), species_type = /datum/species/apid)

	TEST_ASSERT_NOTNULL(human.mind, "Human has no mind.")
	TEST_ASSERT(!isnull(human.mind.learned_recipes) && (/datum/crafting_recipe/honeycomb in human.mind.learned_recipes), "Apid was not taught the honeycomb crafting recipe on job equip.")

/// Roundstart job equipping should still roll a chance at a dormant disease (that chance being 100)
/datum/unit_test/loadout/dormant_disease_on_job_equip

/datum/unit_test/loadout/dormant_disease_on_job_equip/Run()
	var/datum/job/assistant/job = new
	job.biohazard = 100 // force the probabilistic roll to always succeed

	var/mob/living/carbon/human/consistent/human = equip_as_job(job, list(), mob_type = /mob/living/carbon/human)

	TEST_ASSERT(length(human.diseases) > 0, "Human was not given a dormant disease despite a guaranteed (biohazard = 100) roll.")

/// Quirk-granted items need to find a valid storage after job and loadout equipping has already happened. Tagger is easy pick
/datum/unit_test/loadout/quirk_item_after_job_equip

/datum/unit_test/loadout/quirk_item_after_job_equip/Run()
	var/mob/living/carbon/human/human = equip_as_job(new /datum/job/assistant, list())
	human.mind.add_quirk(/datum/quirk/tagger, TRUE)

	var/found_spraycan = FALSE
	for(var/obj/item/item in human.get_all_gear())
		if(istype(item, /obj/item/toy/crayon/spraycan))
			found_spraycan = TRUE
			break
	TEST_ASSERT(found_spraycan, "Tagger quirk's spraycan did not end up anywhere on the human after job equipping.")

/// The loadout-equip UI action should reject equipping a second item into an occupied slot
/datum/unit_test/loadout/equip_gear_rejects_slot_conflict

/datum/unit_test/loadout/equip_gear_rejects_slot_conflict/Run()
	var/datum/gear/gear_a = find_gear(/datum/gear/uniform/color/black)
	var/datum/gear/gear_b = find_gear(/datum/gear/donator/uniform/wine_gown) // same slot
	if(isnull(gear_a) || isnull(gear_b))
		return

	var/datum/client_interface/mock_client = build_mock_client()
	mock_client.prefs.purchased_gear += list(gear_a.id, gear_b.id)

	var/mob/living/carbon/human/stub_user = allocate(/mob/living/carbon/human/consistent)

	var/datum/preference_middleware/loadout/middleware = new(mock_client.prefs)
	middleware.equip_gear(list("id" = gear_a.id), stub_user)
	middleware.equip_gear(list("id" = gear_b.id), stub_user)

	TEST_ASSERT_EQUAL(length(mock_client.prefs.equipped_gear), 1, "Second gear item sharing an occupied slot was not rejected.")
