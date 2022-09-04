/datum/job/brig_physician
	title = JOB_NAME_BRIGPHYSICIAN
	flag = BRIG_PHYS
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "chief medical officer"
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/brig_physician

	access = list(ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_MEDICAL, ACCESS_BRIGPHYS)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_MEDICAL, ACCESS_BRIGPHYS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BRIG_PHYS
	departments = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SECURITY
	rpg_title = "Battle Cleric"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/brig_physician
	)
	biohazard = 15 //still deals with the sick and injured, just less than a medical doctor

/datum/outfit/job/brig_physician
	name = JOB_NAME_BRIGPHYSICIAN
	jobtype = /datum/job/brig_physician

	id = /obj/item/card/id/job/brig_physician
	belt = /obj/item/pda/brig_physician
	ears = /obj/item/radio/headset/headset_medsec
	uniform = /obj/item/clothing/under/rank/brig_physician
	shoes = /obj/item/clothing/shoes/sneakers/white
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit = /obj/item/clothing/suit/hazardvest/brig_physician
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	suit_store = /obj/item/flashlight/seclite
	l_hand = /obj/item/storage/firstaid/medical
	head = /obj/item/clothing/head/soft/sec/brig_physician

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/security

	chameleon_extras = /obj/item/gun/syringe
