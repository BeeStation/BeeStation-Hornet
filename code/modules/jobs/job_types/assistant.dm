/*
Assistant
*/
/datum/job/assistant
	title = "Assistant"
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	chat_color = "#bdbdbd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/assistant
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	departments = DEPARTMENT_SERVICE
	rpg_title = "Lout"

	mail_goodies = list(
		/obj/effect/spawner/lootdrop/donkpocket_solo = 10,
		/obj/item/clothing/mask/gas/old = 10,
		/obj/item/clothing/gloves/color/fyellow = 7,
		/obj/item/choice_beacon/music = 5,
		/obj/item/toy/crayon/spraycan = 3,
		/obj/item/crowbar/large = 2
	)

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)
/datum/job/assistant/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has assistant maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

/datum/outfit/job/assistant
	name = "Assistant"
	jobtype = /datum/job/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/H)
	..()
	if (CONFIG_GET(flag/grey_assistants))
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/grey
		else
			uniform = /obj/item/clothing/under/skirt/color/grey
	else
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/random
		else
			uniform = /obj/item/clothing/under/skirt/color/random
