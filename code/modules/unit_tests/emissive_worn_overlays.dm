/// Test that emissive overlays on worn objects work correctly.
/datum/unit_test/emissive_worn_overlays
	var/mob/living/carbon/human/test_subject

/datum/unit_test/emissive_worn_overlays/Run()
	test_subject = allocate(/mob/living/carbon/human/consistent)
	// Belong to the emissive plane so that we render only our emissives.
	test_subject.plane = EMISSIVE_PLANE

	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test)
	var/icon/flat_icon = create_icon()
	test_screenshot("sunglasses", flat_icon)

	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_partial)
	flat_icon = create_icon()
	test_screenshot("partial", flat_icon)

	test_subject.equipOutfit(/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_fully)
	flat_icon = create_icon()
	test_screenshot("blocked", flat_icon)

/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_partial
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/helmet/sec

/datum/outfit/job/assistant/consistent/emissive_worn_overlay_test_blocked_fully
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/bio_hood

/// Create the mob icon with light cone underlay
/datum/unit_test/emissive_worn_overlays/proc/create_icon()
	var/icon/final_icon = get_flat_icon_for_all_directions(test_subject, no_anim = FALSE)
	return final_icon
