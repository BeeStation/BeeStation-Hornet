/datum/job/prisoner
	title = JOB_NAME_PRISONER
	description = "As a prisoner your job is to stay in prison. Work your ass off in the gulag, beat up the newbie, become top dog. Or just play cards or chess. That'd be nicer."
	department_for_prefs = DEPT_NAME_ASSISTANT
	show_in_prefs = TRUE
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	head_announce = list(null)
	supervisors = "Security / The warden"
	selection_color = "#dddddd"
	minimal_player_age = 10
	exp_requirements = 1200
	exp_type = EXP_TYPE_SECURITY

	departments = DEPT_BITFLAG_UNASSIGNED

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	rpg_title = "Vagrant"
	allow_bureaucratic_error = FALSE

	outfit = /datum/outfit/job/prisoner
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/prisoner
	)

	minimal_lightup_areas = list(
		/area/chapel
	)

/datum/job/prisoner/announce(mob/living/carbon/human/H)

	var/deets = "<font size = 2><b>#Prisoner Transfer Documentation</font></b> \
					<hr> \
					<code> \
					<b>#DETAILS:</b> <br> \
					Transfer to: [station_name()] <br> \
					Case: [H.real_name] <br> \
					Inmate ID: NTP #CC-0[rand(111,999)] <br> \
					Security Class: CAPITAL - LOW SEC <br> \
					AUTH BADGE: <b>Execution allowed</b><br> \
					<hr> \
					<b>#NOTES:</b> <br> \
					-As this prisoner is of capital class or higher, while parole is not forbidden, it is highly advised against.<br> \
					-<b>Keep prisoner in confinement at all times</b>, shall confinement no longer be viable, prefer judicial execution. <br> \
					-While confinement is required, the prisoner may partake in 'activities' outside the brig if supervised and outfitted with an electropack. <hr> </code>\
					<font color='grey'><i>This message has been automatically generated. <br> \
					NT Capital-Class prisoner program includes sign-up for the following activities: <br> \
					- Medical trial subject; <br> \
					- Research trial subject; <br> \
					- Hazardous environment workforce; <br> \
					- Free labor initiative; <br> \
					- And (8) others.<br> \
					</i></font>"
	print_command_report(deets, title = "Prisoner transfer Documentation", announce = FALSE)
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce), "A prisoner has been transferred to your station. Check any communications console for a detailed printout."))
	. = ..()

/datum/outfit/job/prisoner
	name = "Prisoner"
	jobtype = /datum/job/prisoner
	id = /obj/item/card/id/job/prisoner
	belt = /obj/item/modular_computer/tablet/pda/prisoner
	uniform = /obj/item/clothing/under/rank/prisoner/lowsec
	shoes = /obj/item/clothing/shoes/sneakers/white
	can_be_admin_equipped = TRUE


/datum/outfit/job/prisoner/post_equip(mob/living/carbon/human/H)
	var/obj/item/restraints/handcuffs/cuffs = new /obj/item/restraints/handcuffs
	cuffs.apply_cuffs(H)
