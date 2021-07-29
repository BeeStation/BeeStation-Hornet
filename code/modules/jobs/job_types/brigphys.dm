/datum/job/brig_phys
	title = "Brig Physician"
	flag = BRIG_PHYS
	department_head = list("Chief Medical Officer")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "chief medical officer"
	selection_color = "#ffeeee"
	chat_color = "#b16789"
	minimal_player_age = 7
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SECURITY

	outfit = /datum/outfit/job/brig_phys

	access = list(ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_MEDICAL, ACCESS_BRIGPHYS)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_MEDICAL, ACCESS_BRIGPHYS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_BRIG_PHYS
	departments = DEPARTMENT_MEDICAL | DEPARTMENT_SECURITY

/datum/outfit/job/brig_phys
	name = "Brig Physician"
	jobtype = /datum/job/brig_phys

	belt = /obj/item/pda/security
	ears = /obj/item/radio/headset/headset_medsec
	uniform = /obj/item/clothing/under/rank/brig_phys
	shoes = /obj/item/clothing/shoes/sneakers/white
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit = /obj/item/clothing/suit/hazardvest/brig_phys
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	suit_store = /obj/item/flashlight/seclite
	l_hand = /obj/item/storage/firstaid/medical
	head = /obj/item/clothing/head/soft/sec/brig_phys

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/security

	chameleon_extras = /obj/item/gun/syringe
