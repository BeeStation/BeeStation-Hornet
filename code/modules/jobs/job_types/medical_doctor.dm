/datum/job/medical_doctor
	title = JOB_NAME_MEDICALDOCTOR
	flag = DOCTOR
	description = "Treat people of both minor wounds, serious injuries and resurrect them from the dead. Make use of surgeries and surgical tools, Chemistry's pills and patches, Virology's viruses and in dire cases, Genetics' cloning."
	department_for_prefs = DEPT_BITFLAG_MED
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	selection_color = "#d4ebf2"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/medical_doctor

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_VIROLOGY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)

	department_flag = MEDSCI
	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR
	rpg_title = "Cleric"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/medical
	)
	biohazard = 40

	lightup_areas = list(
		/area/medical/genetics,
		/area/medical/virology,
		/area/medical/chemistry,
		/area/medical/apothecary
	)
	minimal_lightup_areas = list(
		/area/medical/morgue,
		/area/medical/surgery,
		/area/medical/genetics/cloning
	)

/datum/outfit/job/medical_doctor
	name = JOB_NAME_MEDICALDOCTOR
	jobtype = /datum/job/medical_doctor

	id = /obj/item/card/id/job/medical_doctor
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/doctor
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	suit_store = /obj/item/storage/firstaid/medical
	l_pocket = /obj/item/flashlight/pen

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = /obj/item/gun/syringe
