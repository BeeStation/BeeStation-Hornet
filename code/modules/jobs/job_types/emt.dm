/datum/job/emt
	title = "Paramedic"
	flag = EMT
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#d4ebf2"
	chat_color = "#8FBEB4"

	outfit = /datum/outfit/job/emt

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR

/datum/outfit/job/emt
	name = "Paramedic"
	jobtype = /datum/job/emt

	id = /obj/item/card/id/job/med
	belt = /obj/item/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/emt
	shoes = /obj/item/clothing/shoes/sneakers/white
	head = /obj/item/clothing/head/soft/emt
	suit =  /obj/item/clothing/suit/toggle/labcoat/emt
	l_hand = /obj/item/storage/firstaid/medical
	l_pocket = /obj/item/pinpointer/crew
	suit_store = /obj/item/sensor_device

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = /obj/item/gun/syringe
