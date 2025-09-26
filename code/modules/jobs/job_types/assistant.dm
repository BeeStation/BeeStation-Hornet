/*
Assistant
*/
/datum/job/assistant
	title = JOB_NAME_ASSISTANT
	description = "Help out around the station or ask the Head of Personnel for an assignment. As the lowest-level position, expect to be treated like an intern most of the time."
	department_for_prefs = DEPT_NAME_ASSISTANT
	supervisors = "absolutely everyone"
	faction = "Station"
	total_positions = -1
	selection_color = "#dddddd"
	antag_rep = 7

	outfit = /datum/outfit/job/assistant

	base_access = list()	//See /datum/job/assistant/get_access()

	departments = DEPT_BITFLAG_CIV
	bank_account_department = NONE // nothing is free for them
	payment_per_department = list(ACCOUNT_CIV_ID = PAYCHECK_ASSISTANT) // Get a job. Job reassignment changes your paycheck now. Get over it.

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	rpg_title = "Lout"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/job/assistant/get_spawn_position_count()
	// Outside of minpop, there are infinite assistants
	if (SSjob.initial_players_to_assign >= MINPOP_JOB_LIMIT)
		return -1
	return ..()

/datum/job/assistant/get_access()
	. = ..()
	if(CONFIG_GET(flag/assistants_have_maint_access)) //Config has assistant maint access set
		. |= ACCESS_MAINT_TUNNELS
	if (SSjob.initial_players_to_assign < LOWPOP_JOB_LIMIT)
		. |= list(ACCESS_EVA, ACCESS_MAINT_TUNNELS, ACCESS_AUX_BASE)
	LOWPOP_GRANT_ACCESS(JOB_NAME_BARTENDER, ACCESS_BAR)
	LOWPOP_GRANT_ACCESS(JOB_NAME_BARTENDER, ACCESS_JANITOR)
	LOWPOP_GRANT_ACCESS(JOB_NAME_COOK, ACCESS_KITCHEN)
	LOWPOP_GRANT_ACCESS(JOB_NAME_BOTANIST, ACCESS_HYDROPONICS)
	LOWPOP_GRANT_ACCESS(JOB_NAME_CLOWN, ACCESS_THEATRE)
	LOWPOP_GRANT_ACCESS(JOB_NAME_CURATOR, ACCESS_LIBRARY)

/datum/outfit/job/assistant
	name = JOB_NAME_ASSISTANT
	jobtype = /datum/job/assistant
	belt = /obj/item/modular_computer/tablet/pda/preset/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/target)
	..()
	give_holiday_hat(target)
	give_jumpsuit(target)

/datum/outfit/job/assistant/proc/give_holiday_hat(mob/living/carbon/human/target)
	for(var/holidayname in GLOB.holidays)
		var/datum/holiday/holiday_today = GLOB.holidays[holidayname]
		var/obj/item/special_hat = holiday_today.holiday_hat
		if(prob(20) && !isnull(special_hat) && isnull(head))
			head = special_hat

/datum/outfit/job/assistant/proc/give_jumpsuit(mob/living/carbon/human/target)
	if (CONFIG_GET(flag/grey_assistants))
		if (target.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/grey
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/grey
	else
		if(target.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/random
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/random

/datum/outfit/job/assistant/consistent
	name = "Assistant - Always Grey"

/datum/outfit/job/assistant/consistent/pre_equip(mob/living/carbon/human/target)
	..()
	give_jumpsuit(target)

/datum/outfit/job/assistant/consistent/post_equip(mob/living/carbon/human/H, visualsOnly)
	..()

	// This outfit is used by the assets SS, which is ran before the atoms SS
	if (SSatoms.initialized == INITIALIZATION_INSSATOMS)
		H.w_uniform?.update_greyscale()
		H.update_inv_w_uniform()
