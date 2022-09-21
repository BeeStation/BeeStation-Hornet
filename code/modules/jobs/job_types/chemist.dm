/datum/job/chemist
	title = JOB_NAME_CHEMIST
	flag = CHEMIST
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#d4ebf2"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/chemist

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CHEMIST
	departments = DEPARTMENT_BITFLAG_MEDICAL
	rpg_title = "Alchemist"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/chemist
	)
	biohazard = 15

/datum/outfit/job/chemist
	name = JOB_NAME_CHEMIST
	jobtype = /datum/job/chemist

	id = /obj/item/card/id/job/chemist
	glasses = /obj/item/clothing/glasses/science
	belt = /obj/item/pda/chemist
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/chemist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/chemist
	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel/chem
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = /obj/item/gun/syringe

