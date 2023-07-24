/datum/job/gimmick //gimmick var must be set to true for all gimmick jobs BUT the parent
	title = JOB_NAME_GIMMICK
	flag = GIMMICK
	description = "Use your unique position to provide a service or entertain the crew."
	department_for_prefs = DEPT_BITFLAG_ASSISTANT
	show_in_prefs = TRUE
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "no one"
	selection_color = "#dddddd"
	exp_type_department = EXP_TYPE_GIMMICK

	access = list(ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_CIV
	bank_account_department = ACCOUNT_CIV_BITFLAG
	payment_per_department = list(ACCOUNT_CIV_ID = PAYCHECK_ASSISTANT)

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	rpg_title = "Peasant"
	allow_bureaucratic_error = FALSE
	outfit = /datum/outfit/job/gimmick
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)
/datum/outfit/job/gimmick
	can_be_admin_equipped = FALSE // we want just the parent outfit to be unequippable since this leads to problems

/datum/job/gimmick/barber
	title = JOB_NAME_BARBER
	flag = BARBER
	description = "Give the crew haircuts using the variety of tools at your disposal, and provide less professional and cosmetic surgeries."
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	gimmick = TRUE
	show_in_prefs = FALSE

	outfit = /datum/outfit/job/gimmick/barber

	access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_ASSISTANT)

	rpg_title = "Scissorhands"
/datum/outfit/job/gimmick/barber
	name = JOB_NAME_BARBER
	jobtype = /datum/job/gimmick/barber
	id = /obj/item/card/id/job/barber
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/suit/sl
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/wallet
	l_pocket = /obj/item/razor/straightrazor
	can_be_admin_equipped = TRUE

/datum/job/gimmick/stage_magician
	title = JOB_NAME_STAGEMAGICIAN
	flag = MAGICIAN
	description = "Use your special tools to provide entertainment for the crew, show them than you can do more than simple parlor magic tricks."
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	gimmick = TRUE
	show_in_prefs = FALSE

	outfit = /datum/outfit/job/gimmick/stage_magician

	access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_MINIMAL)

	rpg_title = "Master Illusionist"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/magic
	)
/datum/outfit/job/gimmick/stage_magician
	name = JOB_NAME_STAGEMAGICIAN
	jobtype = /datum/job/gimmick/stage_magician
	id = /obj/item/card/id/job/stage_magician
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	head = /obj/item/clothing/head/that
	ears = /obj/item/radio/headset
	neck = /obj/item/bedsheet/magician
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	l_hand = /obj/item/cane
	backpack_contents = list(/obj/item/choice_beacon/radial/magic=1)
	can_be_admin_equipped = TRUE

/datum/job/gimmick/psychiatrist
	title = JOB_NAME_PSYCHIATRIST
	flag = PSYCHIATRIST
	description = "Provide therapy to the crew through talk sessions, psychoactive drugs, and careful consideration of their thoughts and feelings. Provide mental evaluations for Security."
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	gimmick = TRUE
	show_in_prefs = FALSE

	outfit = /datum/outfit/job/gimmick/psychiatrist

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MEDICAL)

	department_flag = MEDSCI
	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_EASY)
	mind_traits = list(TRAIT_MADNESS_IMMUNE, TRAIT_MEDICAL_METABOLISM)

	rpg_title = "Enchanter"
/datum/outfit/job/gimmick/psychiatrist //psychiatrist doesnt get much shit, but he has more access and a cushier paycheck
	name = JOB_NAME_PSYCHIATRIST
	jobtype = /datum/job/gimmick/psychiatrist
	id = /obj/item/card/id/job/psychiatrist
	belt = /obj/item/modular_computer/tablet/pda/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup
	backpack_contents = list(/obj/item/choice_beacon/pet/ems=1)
	can_be_admin_equipped = TRUE

/datum/job/gimmick/vip
	title = JOB_NAME_VIP
	flag = CELEBRITY
	description = "Flaunt around your wealth, organize posh parties and other high life activities with your near-bottomless budget."
	gimmick = TRUE
	show_in_prefs = FALSE

	outfit = /datum/outfit/job/gimmick/vip

	access = list(ACCESS_MAINT_TUNNELS) //Assistants with shitloads of money, what could go wrong?
	minimal_access = list(ACCESS_MAINT_TUNNELS)

	department_flag = CIVILIAN
	departments = DEPT_BITFLAG_VIP
	bank_account_department = ACCOUNT_VIP_BITFLAG
	payment_per_department = list(ACCOUNT_VIP_ID = PAYCHECK_VIP)  //our power is being fucking rich

	rpg_title = "Master of Patronage"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/vip
	)
/datum/outfit/job/gimmick/vip
	name = JOB_NAME_VIP
	jobtype = /datum/job/gimmick/vip
	id = /obj/item/card/id/gold/vip
	belt = /obj/item/modular_computer/tablet/pda/vip
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	ears = /obj/item/radio/headset/heads //VIP can talk loud for no reason
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	can_be_admin_equipped = TRUE
