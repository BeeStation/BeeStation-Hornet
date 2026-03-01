/datum/job/prisoner
	title = JOB_NAME_PRISONER
	description = "As a prisoner your job is to be imprisoned. Play cards or chess, cook some food or grow some plants. Run away when security ain't looking."
	department_for_prefs = DEPT_NAME_ASSISTANT
	show_in_prefs = TRUE
	faction = "Station"
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	total_positions = 3
	min_pop = MINPOP_JOB_LIMIT
	supervisors = "your own conscience"
	selection_color = "#dddddd"

	base_access = list()
	departments = DEPT_BITFLAG_UNASSIGNED
	bank_account_department = NONE

	display_order = JOB_DISPLAY_ORDER_PRISONER
	rpg_title = "Vagrant"
	allow_bureaucratic_error = FALSE

	outfit = /datum/outfit/job/prisoner
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/prisoner
	)

	minimal_lightup_areas = list(
		/area/security/prison
	)

	manuscript_jobs = list(
		JOB_NAME_PRISONER,
		JOB_NAME_ASSISTANT
	)

/datum/job/prisoner/announce(mob/living/carbon/human/H)
	var/deets = "<font size = 2><b>#Prisoner Transfer Documentation</font></b> \
					<hr> \
					<code> \
					<b>#DETAILS:</b> <br> \
					Transfer to: [station_name()] <br> \
					Case: [H.real_name] <br> \
					Inmate ID: NTP #CC-0[rand(111,999)] <br> \
					Charge Class: CAPITAL <br> \
					Security level: LOW <br> \
					<hr> \
					<b>#NOTES:</b> <br> \
					-While confinement is required, the prisoner may partake in 'activities' outside the brig if supervised and outfitted with an electropack or tracking implant. <hr> </code>\
					<font color='grey'><i>This message has been automatically generated. <br> \
					NT Capital-Class prisoner program includes sign-up for the following activities: <br> \
					- Free labor initiative; <br> \
					- Hazardous environment workforce; <br> \
					- Research trial subject; <br> \
					- Medical trial subject; <br> \
					- And (8) others.<br> \
					</i></font>"

	//Fax first
	for(var/obj/machinery/fax/sec/available_sec_faxes in GLOB.fax_machines)
		var/obj/item/paper/message = new /obj/item/paper
		message.name = "Prisoner transfer Documentation"
		message.add_raw_text(deets)
		available_sec_faxes.receive(message, "NT Penal Division", important = TRUE)
		message.update_icon()

	// Announcement after
	print_command_report(deets, title = "Prisoner transfer Documentation", announce = FALSE)
	. = ..()

/datum/job/prisoner/get_access()
	return list()

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner

	id = /obj/item/card/id/job/prisoner
	belt = /obj/item/modular_computer/tablet/pda/prisoner
	uniform = /obj/item/clothing/under/rank/prisoner/lowsec
	shoes = /obj/item/clothing/shoes/sneakers/white

/datum/job/prisoner/radio_help_message(mob/M)
	.=..()
	to_chat(M,span_prisonermessage("<b>You have signed up as Low-Security Inmate, <i>This is primarily a roleplaying role.</i><hr>\
									You are expected to create conflict using good role-play; in a way that is fun for others.<br>\
									Good conflict escalation doesn't require spoiling the plan to a victim, but it is more interesting when you drop hints and attempt to get more players involved.<br>\
									You are neutral to the station and are not expected to be on their side, but all conflicts must align with your character's motivations.<br></b>"))
