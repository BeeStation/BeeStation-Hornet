/datum/job/chemist
	title = JOB_NAME_CHEMIST
	description = "Create healing medicines and fullfill other requests when medicine isn't needed. Label everything you produce correctly to prevent confusion."
	department_for_prefs = DEPT_NAME_MEDICAL
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	total_positions = 2
	selection_color = "#d4ebf2"
	// Requires some understanding of medical, but is a relatively
	// easy role to learn.
	exp_requirements = 60
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/chemist

	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)
	extra_access = list(ACCESS_SURGERY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_CLONING)

	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CHEMIST
	rpg_title = "Alchemist"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/chemist
	)
	biohazard = 25

	lightup_areas = list(
		/area/medical/surgery,
		/area/medical/virology,
		/area/medical/genetics
	)
	minimal_lightup_areas = list(
		/area/medical/morgue,
		/area/medical/chemistry,
		/area/medical/apothecary
	)

/datum/outfit/job/chemist
	name = JOB_NAME_CHEMIST
	jobtype = /datum/job/chemist

	id = /obj/item/card/id/job/chemist
	glasses = /obj/item/clothing/glasses/science
	belt = /obj/item/modular_computer/tablet/pda/preset/chemist
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/chemist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/chemist
	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel/chem
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe

