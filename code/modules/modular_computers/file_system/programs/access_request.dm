#define CARDCON_DEPARTMENT_CIVILIAN "Civilian"
#define CARDCON_DEPARTMENT_SECURITY "Security"
#define CARDCON_DEPARTMENT_MEDICAL "Medical"
#define CARDCON_DEPARTMENT_SUPPLY "Supply"
#define CARDCON_DEPARTMENT_SCIENCE "Science"
#define CARDCON_DEPARTMENT_ENGINEERING "Engineering"
#define CARDCON_DEPARTMENT_COMMAND "Command"

/datum/computer_file/program/card_req
	filename = "request_access"
	filedesc = "Card Request Access"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program for requesting access from command."
	transfer_access = ACCESS_HEADS
	requires_ntnet = 0
	size = 8
	tgui_id = "NtosCardReq"
	program_icon = "id-card"

	var/list/sub_managers

/datum/computer_file/program/card_req/New(obj/item/modular_computer/comp)
	. = ..()
	sub_managers = list(
		"[ACCESS_HOP]" = list(
			"department" = list(CARDCON_DEPARTMENT_SUPPLY, CARDCON_DEPARTMENT_COMMAND),
			"region" = 1,
			"head" = JOB_NAME_HEADOFPERSONNEL
		),
		"[ACCESS_HOS]" = list(
			"department" = CARDCON_DEPARTMENT_SECURITY,
			"region" = 2,
			"head" = JOB_NAME_HEADOFSECURITY
		),
		"[ACCESS_CMO]" = list(
			"department" = CARDCON_DEPARTMENT_MEDICAL,
			"region" = 3,
			"head" = JOB_NAME_CHIEFMEDICALOFFICER
		),
		"[ACCESS_RD]" = list(
			"department" = CARDCON_DEPARTMENT_SCIENCE,
			"region" = 4,
			"head" = JOB_NAME_RESEARCHDIRECTOR
		),
		"[ACCESS_CE]" = list(
			"department" = CARDCON_DEPARTMENT_ENGINEERING,
			"region" = 5,
			"head" = JOB_NAME_CHIEFENGINEER
		)
	)

/datum/computer_file/program/card_req/ui_static_data(mob/user)
	var/list/regions = list()
	for(var/i in 1 to 7)
		var/list/accesses = list()
		for(var/access in get_region_accesses(i))
			if (get_access_desc(access))
				accesses += list(list(
					"desc" = replacetext(get_access_desc(access), "&nbsp", " "),
					"ref" = access,
				))
