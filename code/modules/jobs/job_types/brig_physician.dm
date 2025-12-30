/datum/job/brig_physician
	title = JOB_NAME_BRIGPHYSICIAN
	description = "Tend to the health of Security Officers and Prisoners, help out at Medbay if you have free time."
	department_for_prefs = DEPT_NAME_SECURITY
	department_head_for_prefs = JOB_NAME_HEADOFSECURITY
	department_head = list(JOB_NAME_HEADOFSECURITY)
	supervisors = "the head of security"
	faction = "Station"
	total_positions = 1
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 60
	exp_type = EXP_TYPE_MEDICAL
	outfit = /datum/outfit/job/brig_physician

	base_access = list(ACCESS_BRIGPHYS, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MECH_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE)
	extra_access = list(ACCESS_MEDICAL, ACCESS_SURGERY)

	departments = DEPT_BITFLAG_SEC
	bank_account_department = ACCOUNT_MED_BITFLAG | ACCOUNT_SEC_BITFLAG
	payment_per_department = list(ACCOUNT_SEC_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BRIG_PHYS
	rpg_title = "Battle Cleric"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/brig_physician
	)
	biohazard = 25 //still deals with the sick and injured, just less than a medical doctor

	minimal_lightup_areas = list(/area/medical/morgue)

	manuscript_jobs = list(
		JOB_NAME_BRIGPHYSICIAN,
		JOB_NAME_PARAMEDIC // They're somewhat identical
	)

/datum/outfit/job/brig_physician
	name = JOB_NAME_BRIGPHYSICIAN
	jobtype = /datum/job/brig_physician

	id = /obj/item/card/id/job/brig_physician
	belt = /obj/item/modular_computer/tablet/pda/preset/brig_physician
	ears = /obj/item/radio/headset/headset_medsec
	uniform = /obj/item/clothing/under/rank/brig_physician
	shoes = /obj/item/clothing/shoes/sneakers/white
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit = /obj/item/clothing/suit/hazardvest/brig_physician
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	suit_store = /obj/item/storage/firstaid/medical/physician
	l_pocket = /obj/item/flashlight/seclite
	r_pocket = /obj/item/assembly/flash
	head = /obj/item/clothing/head/soft/sec/brig_physician

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/security
	chameleon_extras = /obj/item/gun/syringe
