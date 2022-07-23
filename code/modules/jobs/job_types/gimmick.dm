/datum/job/gimmick //gimmick var must be set to true for all gimmick jobs BUT the parent
	title = "Gimmick"
	flag = GIMMICK
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "no one"
	selection_color = "#dddddd"

	exp_type_department = EXP_TYPE_GIMMICK

	access = list(ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_ASSISTANT
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	departments = DEPARTMENT_SERVICE
	rpg_title = "Peasant"

	allow_bureaucratic_error = FALSE
	outfit = /datum/outfit/job/gimmick

/datum/outfit/job/gimmick
	can_be_admin_equipped = FALSE // we want just the parent outfit to be unequippable since this leads to problems

/datum/job/gimmick/barber
	title = "Barber"
	flag = BARBER
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/barber

	access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_ASSISTANT
	paycheck_department = ACCOUNT_SRV

	departments = DEPARTMENT_SERVICE
	rpg_title = "Scissorhands"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/outfit/job/gimmick/barber
	name = "Barber"
	jobtype = /datum/job/gimmick/barber

	id = /obj/item/card/id/job/barber
	belt = /obj/item/pda/unlicensed
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/suit/sl
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/wallet
	l_pocket = /obj/item/razor/straightrazor
	can_be_admin_equipped = TRUE

/datum/job/gimmick/magician
	title = "Stage Magician"
	flag = MAGICIAN
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/magician

	access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_MINIMAL
	paycheck_department = ACCOUNT_SRV

	departments = DEPARTMENT_SERVICE
	rpg_title = "Master Illusionist"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/magic
	)

/datum/outfit/job/gimmick/magician
	name = "Stage Magician"
	jobtype = /datum/job/gimmick/magician

	id = /obj/item/card/id/job/magician
	belt = /obj/item/pda/unlicensed
	head = /obj/item/clothing/head/that
	ears = /obj/item/radio/headset
	neck = /obj/item/bedsheet/magician
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	l_hand = /obj/item/cane
	backpack_contents = list(/obj/item/choice_beacon/magic=1)
	can_be_admin_equipped = TRUE

/datum/job/gimmick/shrink
	title = "Psychiatrist"
	flag = SHRINK
	supervisors = "the chief medical officer"
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/shrink

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)
	paycheck = PAYCHECK_EASY
	departments = DEPARTMENT_MEDICAL

	paycheck_department = ACCOUNT_MED
	rpg_title = "Enchanter"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/outfit/job/gimmick/shrink //psychiatrist doesnt get much shit, but he has more access and a cushier paycheck
	name = "Psychiatrist"
	jobtype = /datum/job/gimmick/shrink

	id = /obj/item/card/id/job/psychi
	belt = /obj/item/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup
	backpack_contents = list(/obj/item/choice_beacon/pet/ems=1)
	can_be_admin_equipped = TRUE

/datum/job/gimmick/celebrity
	title = "VIP"
	flag = CELEBRITY
	department_flag = CIVILIAN
	gimmick = TRUE

	outfit = /datum/outfit/job/gimmick/celebrity

	access = list(ACCESS_MAINT_TUNNELS) //Assistants with shitloads of money, what could go wrong?
	minimal_access = list(ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_VIP  //our power is being fucking rich
	paycheck_department = ACCOUNT_CIV

	departments = DEPARTMENT_SERVICE
	rpg_title = "Master of Patronage"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/vip
	)

/datum/outfit/job/gimmick/celebrity
	name = "VIP"
	jobtype = /datum/job/gimmick/celebrity

	id = /obj/item/card/id/gold/vip
	belt = /obj/item/pda/celebrity
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	ears = /obj/item/radio/headset/heads //VIP can talk loud for no reason
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	can_be_admin_equipped = TRUE
