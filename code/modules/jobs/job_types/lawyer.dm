/datum/job/lawyer
	title = JOB_NAME_LAWYER
	description = "Ensure Security follows Space Law and Standard Operating Procedure perfectly, represent your clients in trials and other legal troubles, make sure the crew is treated fairly by the men in red."
	department_for_prefs = DEPT_NAME_CIVILIAN
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 2
	selection_color = "#dddddd"
	var/lawyers = 0 //Counts lawyer amount

	outfit = /datum/outfit/job/lawyer

	base_access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS)
	extra_access = list()

	departments = DEPT_BITFLAG_CIV
	bank_account_department = ACCOUNT_CIV_BITFLAG
	payment_per_department = list(ACCOUNT_CIV_ID = PAYCHECK_EASY)
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_LAWYER
	rpg_title = "Magistrate"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/lawyer
	)

	minimal_lightup_areas = list(/area/lawoffice)

	manuscript_jobs = list(
		JOB_NAME_LAWYER,
		JOB_NAME_DETECTIVE, // a lawyer should also know how to collect evidences
		JOB_NAME_CURATOR
	)

/datum/outfit/job/lawyer
	name = JOB_NAME_LAWYER
	jobtype = /datum/job/lawyer

	id = /obj/item/card/id/job/lawyer
	belt = /obj/item/modular_computer/tablet/pda/preset/lawyer
	ears = /obj/item/radio/headset/headset_srvsec
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	suit = /obj/item/clothing/suit/toggle/lawyer
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase/lawyer
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/clothing/accessory/lawyers_badge

	chameleon_extras = /obj/item/stamp/law


/datum/outfit/job/lawyer/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return ..()

	var/static/use_purple_suit = FALSE //If there is one lawyer, they get the default blue suit. If another lawyer joins the round, they start with a purple suit.
	if(use_purple_suit)
		uniform = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit
		suit = /obj/item/clothing/suit/toggle/lawyer/purple
	else
		use_purple_suit = TRUE
	..()

/datum/outfit/job/lawyer/get_types_to_preload()
	. = ..()
	. += /obj/item/clothing/under/rank/civilian/lawyer/purpsuit
	. += /obj/item/clothing/suit/toggle/lawyer/purple
