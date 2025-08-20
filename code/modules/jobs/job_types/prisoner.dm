/datum/job/prisoner
	title = JOB_NAME_PRISONER
	description = "As a prisoner your job is to be imprisoned. Play cards or chess, cook some food or grow some plants. Run away when security ain't looking."
	department_for_prefs = DEPT_NAME_ASSISTANT
	show_in_prefs = TRUE
	faction = "Station"
	total_positions = 3
	min_pop = LOWPOP_JOB_LIMIT
	supervisors = "Security / The warden"
	selection_color = "#dddddd"

	departments = DEPT_BITFLAG_UNASSIGNED

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	rpg_title = "Vagrant"
	allow_bureaucratic_error = FALSE

	outfit = /datum/outfit/job/prisoner
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/prisoner
	)

	minimal_lightup_areas = list(
		/area/security/prison
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

	for(var/obj/machinery/fax/sec/availableSecFaxes in GLOB.fax_machines)
		var/obj/item/paper/message = new /obj/item/paper
		message.name = "Prisoner transfer Documentation"
		message.add_raw_text(deets)
		availableSecFaxes.receive(message, "NT Penal Division", important = TRUE)
		message.update_icon()

	// Announcement after
	print_command_report(deets, title = "Prisoner transfer Documentation", announce = FALSE)
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "A prisoner has been transferred to your station. Check any communications console or security fax machine for a detailed printout.", "NT Penal Transfer", 'sound/misc/notice2.ogg'))
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
	can_be_admin_equipped = TRUE
