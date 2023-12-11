/datum/job/brig_physician
	title = JOB_NAME_BRIGPHYSICIAN
	flag = BRIG_PHYS
	description = "Tend to the health of Security Officers and Prisoners, help out at Medbay if you have free time."
	department_for_prefs = DEPT_BITFLAG_SEC
	department_head_for_prefs = JOB_NAME_HEADOFSECURITY
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "chief medical officer"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/brig_physician

	access = list(ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_MEDICAL, ACCESS_BRIGPHYS)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_MEDICAL, ACCESS_BRIGPHYS)

	department_flag = ENGSEC
	departments = DEPT_BITFLAG_MED | DEPT_BITFLAG_SEC
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BRIG_PHYS
	rpg_title = "Battle Cleric"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/brig_physician
	)
	biohazard = 25 //still deals with the sick and injured, just less than a medical doctor

	minimal_lightup_areas = list(/area/medical/morgue)

/datum/outfit/job/brig_physician
	name = JOB_NAME_BRIGPHYSICIAN
	jobtype = /datum/job/brig_physician

	id = /obj/item/card/id/job/brig_physician
	belt = /obj/item/modular_computer/tablet/pda/brig_physician
	ears = /obj/item/radio/headset/headset_medsec
	uniform = /obj/item/clothing/under/rank/brig_physician
	shoes = /obj/item/clothing/shoes/sneakers/white
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit = /obj/item/clothing/suit/hazardvest/brig_physician
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	suit_store = /obj/item/storage/firstaid/medical
	l_pocket = /obj/item/flashlight/seclite
	head = /obj/item/clothing/head/soft/sec/brig_physician

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival/security

	chameleon_extras = /obj/item/gun/syringe
