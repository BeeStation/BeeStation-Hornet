/*
Assistant
*/
/datum/job/assistant
	title = JOB_NAME_ASSISTANT
	job_bitflags = JOB_BITFLAG_SELECTABLE | JOB_BITFLAG_MANAGE_LOCKED
	total_positions = 5
	spawn_positions = 5
	selection_color = "#dddddd"
	antag_rep = 7

	outfit = /datum/outfit/job/assistant

	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()

	departments = DEPT_BITFLAG_CIV
	bank_account_department = NONE // nothing is free for them
	payment_per_department = list(ACCOUNT_CIV_ID = PAYCHECK_ASSISTANT) // Get a job. Job reassignment changes your paycheck now. Get over it.

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	rpg_title = "Lout"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/job/assistant/notify_your_supervisor()
	return "absolutely everyone"

/datum/job/assistant/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has assistant maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

/datum/outfit/job/assistant
	name = JOB_NAME_ASSISTANT
	jobtype = /datum/job/assistant
	belt = /obj/item/modular_computer/tablet/pda/assistant
	id = /obj/item/card/id/job/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/H)
	..()
	if (CONFIG_GET(flag/grey_assistants))
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/grey
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/grey
	else
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/random
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/random

