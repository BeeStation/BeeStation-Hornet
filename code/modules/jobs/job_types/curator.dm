/datum/job/curator
	title = JOB_NAME_CURATOR
	flag = CURATOR
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/curator

	access = list(ACCESS_LIBRARY, ACCESS_AUX_BASE, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_LIBRARY, ACCESS_AUX_BASE, ACCESS_MINING_STATION)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_CURATOR
	departments = DEPARTMENT_BITFLAG_SERVICE
	rpg_title = "Veteran Adventurer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/curator
	)
	//they doesnt get out that much
	biohazard = 5

/datum/outfit/job/curator
	name = JOB_NAME_CURATOR
	jobtype = /datum/job/curator

	id = /obj/item/card/id/job/curator
	shoes = /obj/item/clothing/shoes/laceup
	belt = /obj/item/pda/curator
	ears = /obj/item/radio/headset/headset_curator
	uniform = /obj/item/clothing/under/rank/civilian/curator
	l_hand = /obj/item/storage/bag/books
	r_pocket = /obj/item/key/displaycase
	l_pocket = /obj/item/laser_pointer
	accessory = /obj/item/clothing/accessory/pocketprotector/full
	backpack_contents = list(
		/obj/item/choice_beacon/hero = 1,
		/obj/item/soapstone = 1,
		/obj/item/barcodescanner = 1
	)

/datum/outfit/job/curator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	H.grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_CURATOR)
