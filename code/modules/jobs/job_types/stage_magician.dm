/datum/job/stage_magician

	title = JOB_NAME_STAGEMAGICIAN
	description = "Use your special tools to provide entertainment for the crew, show them than you can do more than simple parlor magic tricks."
	department_for_prefs = DEPT_NAME_SERVICE
	department_head = list(JOB_NAME_HEADOFPERSONNEL)
	supervisors = "the head of personnel"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/stage_magician

	base_access = list(ACCESS_THEATRE)
	extra_access = list(ACCESS_MAINT_TUNNELS)

	departments = DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG
	payment_per_department = list(ACCOUNT_SRV_ID = PAYCHECK_MINIMAL)

	display_order = JOB_DISPLAY_ORDER_STAGE_MAGICIAN
	rpg_title = "Master Illusionist"
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/magic
	)

	minimal_lightup_areas = list(/area/crew_quarters/theatre)

/datum/outfit/job/stage_magician
	name = JOB_NAME_STAGEMAGICIAN
	jobtype = /datum/job/stage_magician
	id = /obj/item/card/id/job/stage_magician
	belt = /obj/item/modular_computer/tablet/pda/unlicensed
	head = /obj/item/clothing/head/hats/tophat
	ears = /obj/item/radio/headset/headset_srv
	neck = /obj/item/bedsheet/magician
	uniform = /obj/item/clothing/under/suit/black_really
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	l_hand = /obj/item/cane
	backpack_contents = list(/obj/item/choice_beacon/radial/magic=1)
	can_be_admin_equipped = TRUE
