/datum/job/geneticist
	title = JOB_NAME_GENETICIST
	flag = GENETICIST
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_RESEARCHDIRECTOR)
	supervisors = "the chief medical officer and research director"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	selection_color = "#d4ebf2"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/geneticist

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_ROBOTICS, ACCESS_MINERAL_STOREROOM, ACCESS_TECH_STORAGE)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)

	department_flag = MEDSCI
	departments = DEPT_BITFLAG_MED | DEPT_BITFLAG_SCI
	bank_account_department = ACCOUNT_MED_BITFLAG | ACCOUNT_SCI_BITFLAG
	payment_per_department = list(
		ACCOUNT_MED_ID = PAYCHECK_MEDIUM_BY_HALF,  // Paid by med for half
		ACCOUNT_SCI_ID = PAYCHECK_MEDIUM_BY_HALF   // And paid by sci for half
	)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_GENETICIST
	rpg_title = "Genemancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/genetics
	)
	biohazard = 25

/datum/outfit/job/geneticist
	name = JOB_NAME_GENETICIST
	jobtype = /datum/job/geneticist

	id = /obj/item/card/id/job/geneticist
	belt = /obj/item/modular_computer/tablet/pda/geneticist
	ears = /obj/item/radio/headset/headset_medsci
	uniform = /obj/item/clothing/under/rank/medical/geneticist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/genetics
	suit_store =  /obj/item/flashlight/pen
	l_pocket = /obj/item/sequence_scanner

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel/gen
	duffelbag = /obj/item/storage/backpack/duffelbag/med

