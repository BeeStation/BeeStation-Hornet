/// Test that emissive overlays on worn objects work correctly.
/datum/unit_test/emissive_worn_overlays
	var/mob/living/carbon/human/test_subject

/datum/unit_test/emissive_worn_overlays/Run()
	test_subject = allocate(/mob/living/carbon/human/consistent)

	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test)
	test_screenshot("sunglasses", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE, override_plane = EMISSIVE_PLANE))
	qdel(test_subject)

	test_subject = allocate(/mob/living/carbon/human/consistent)
	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_partial)
	test_screenshot("partial", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE, override_plane = EMISSIVE_PLANE))
	qdel(test_subject)

	test_subject = allocate(/mob/living/carbon/human/consistent)
	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_fully)
	test_screenshot("blocked", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE, override_plane = EMISSIVE_PLANE))
	qdel(test_subject)

	test_subject = allocate(/mob/living/carbon/human/consistent)
	test_subject.set_species(/datum/species/ipc)
	test_screenshot("ipc", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE, override_plane = EMISSIVE_PLANE))
	qdel(test_subject)

	test_subject = allocate(/mob/living/carbon/human/consistent)
	test_subject.set_species(/datum/species/ipc)
	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_fully)
	test_screenshot("ipc_blocked", get_flat_icon_for_all_directions(test_subject, no_anim = FALSE, override_plane = EMISSIVE_PLANE))
	qdel(test_subject)

/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_partial
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/helmet/sec

/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_fully
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/bio_hood
