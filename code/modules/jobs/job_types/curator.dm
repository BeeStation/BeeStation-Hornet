/datum/job/curator
	title = JOB_NAME_CURATOR
	flag = CURATOR
	description = "Be in charge of maintaining the library, engage in peace talks with alien races using your knowledge of all languages, cosplay to your heart's content."
	department_for_prefs = DEPT_BITFLAG_CIV
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/curator

	access = list(ACCESS_LIBRARY, ACCESS_AUX_BASE, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_LIBRARY, ACCESS_AUX_BASE, ACCESS_MINING_STATION)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_CIV
	bank_account_department = ACCOUNT_CIV_BITFLAG
	payment_per_department = list(ACCOUNT_CIV_ID = PAYCHECK_EASY)

	display_order = JOB_DISPLAY_ORDER_CURATOR
	rpg_title = "Veteran Adventurer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/curator
	)
	//they doesnt get out that much
	biohazard = 10

	minimal_lightup_areas = list(
		/area/library,
		/area/construction/mining/aux_base
	)

/datum/outfit/job/curator
	name = JOB_NAME_CURATOR
	jobtype = /datum/job/curator

	id = /obj/item/card/id/job/curator
	shoes = /obj/item/clothing/shoes/laceup
	belt = /obj/item/modular_computer/tablet/pda/curator
	ears = /obj/item/radio/headset/headset_curator
	uniform = /obj/item/clothing/under/rank/civilian/curator
	l_hand = /obj/item/storage/bag/books
	r_pocket = /obj/item/key/displaycase
	l_pocket = /obj/item/laser_pointer
	accessory = /obj/item/clothing/accessory/pocketprotector/full
	backpack_contents = list(
		/obj/item/choice_beacon/radial/hero = 1,
		/obj/item/soapstone = 1,
		/obj/item/barcodescanner = 1
	)

/datum/outfit/job/curator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	H.grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_CURATOR)
