/datum/job/gimmick //gimmick var must be set to true for all gimmick jobs BUT the parent
	title = "Gimmick"
	flag = GIMMICK
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "no one"
	selection_color = "#dddddd"

	access = list( ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_ASSISTANT
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT

/datum/job/gimmick/barber
	title = "Barber"
	outfit = /datum/outfit/job/gimmick/barber
	access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	gimmick = TRUE

/datum/outfit/job/gimmick/barber
	name = "Barber"
	jobtype = /datum/job/gimmick/barber

	belt = /obj/item/pda/unlicensed
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/sl_suit
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/wallet
	l_pocket = /obj/item/razor/straightrazor

/datum/job/gimmick/magician
	title = "Stage Magician"
	outfit = /datum/outfit/job/gimmick/magician
	access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	gimmick = TRUE

/datum/outfit/job/gimmick/magician
	name = "Stage Magician"
	jobtype = /datum/job/gimmick/magician

	belt = /obj/item/pda/unlicensed
	head = /obj/item/clothing/head/that
	ears = /obj/item/radio/headset
	neck = /obj/item/bedsheet/magician
	uniform = /obj/item/clothing/under/suit_jacket/really_black
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	l_hand = /obj/item/cane
	backpack_contents = list(/obj/item/choice_beacon/magic=1)