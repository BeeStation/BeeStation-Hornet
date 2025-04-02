/datum/job/surgeon
	title = JOB_NAME_SURGEON
	description = "Perform advanced surgeries that regular crew are not capable of, including experimental surgeries which can upgrade the body."
	department_for_prefs = DEPT_NAME_MEDICAL
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#d4ebf2"
	exp_requirements = 120
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/surgeon

	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_VIROLOGY)
	extra_access = list(ACCESS_CHEMISTRY, ACCESS_GENETICS)

	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_HARD)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM, TRAIT_SURGEON, TRAIT_ROBOTICIST_SURGEON)

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR
	rpg_title = "Necromancer"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/medical
	)
	biohazard = 30

	lightup_areas = list(
		/area/medical/genetics,
		/area/medical/virology,
		/area/medical/chemistry,
		/area/medical/apothecary,
		/area/medical/surgery
	)
	minimal_lightup_areas = list(
		/area/medical/surgery,
		/area/medical/genetics/cloning
	)

/datum/outfit/job/surgeon
	name = JOB_NAME_SURGEON
	jobtype = /datum/job/surgeon

	id = /obj/item/card/id/job/surgeon
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/doctor/blue
	belt = /obj/item/storage/belt/medical/surgeon
	r_pocket = /obj/item/modular_computer/tablet/pda/surgeon
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/apron/surgical
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/beret/med

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
