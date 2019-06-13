/datum/job/EMT
	title = "EMT"
	flag = Emergency Medical Technician
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	outfit = /datum/outfit/job/EMT

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR

/datum/outfit/job/EMT
	name = "EMT"
	jobtype = /datum/job/EMT

	belt = /obj/item/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/emt
	l_hand = /obj/item/storage/firstaid/regular
	suit_store = /obj/item/flashlight/pen
	head = /obj/item/clothing/head/soft/emt

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = /obj/item/gun/syringe

/datum/outfit/job/EMT/hardsuit
	name = "Emergency Medical Technician (Hardsuit)"

	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/EMT
	suit_store = /obj/item/tank/internals/oxygen
	r_pocket = /obj/item/flashlight/pen
