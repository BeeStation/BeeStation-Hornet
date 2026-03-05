/datum/job/captain
	title = JOB_NAME_CAPTAIN
	description = "Supreme leader of the station, oversee and appoint missing heads of staff, manage alert levels and contact CentCom if needed. Don't forget to secure the nuclear authentication disk."
	department_for_prefs = DEPT_NAME_CAPTAIN
	department_head_for_prefs = JOB_NAME_CAPTAIN
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	department_head = list("CentCom")
	supervisors = "Nanotrasen officials and Space law"
	faction = "Station"
	total_positions = 1
	selection_color = "#ccccff"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 900
	exp_type = EXP_TYPE_COMMAND

	outfit = /datum/outfit/job/captain

	base_access = list()  //See get_access()
	extra_access = list() //See get_access()

	departments = DEPT_BITFLAG_COM
	bank_account_department = ACCOUNT_SEC_BITFLAG | ACCOUNT_COM_BITFLAG
	payment_per_department = list(
		ACCOUNT_COM_ID = PAYCHECK_COMMAND_NT,
		ACCOUNT_SEC_ID = PAYCHECK_COMMAND_DEPT)
	mind_traits = list(TRAIT_DISK_VERIFIER)

	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	rpg_title = "Star Duke"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/command
	)

	minimal_lightup_areas = list(
		/area/crew_quarters/heads/captain,
		/area/crew_quarters/heads/hop,
		/area/security
	)

	// captain can write manuscript of command roles
	manuscript_jobs = list(
		JOB_NAME_CAPTAIN,
		JOB_NAME_CHIEFENGINEER,
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_HEADOFPERSONNEL,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_RESEARCHDIRECTOR,
	)

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/H)
	..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce), "Captain [H.real_name] on deck!"))

/datum/outfit/job/captain
	name = JOB_NAME_CAPTAIN
	jobtype = /datum/job/captain

	id = /obj/item/card/id/job/captain
	belt = /obj/item/modular_computer/tablet/pda/preset/heads/captain
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	ears = /obj/item/radio/headset/heads/captain/alt
	gloves = /obj/item/clothing/gloves/color/captain
	uniform =  /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/hats/caphat
	backpack_contents = list(/obj/item/melee/baton/telescopic=1, /obj/item/station_charter=1)

	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel/cap
	duffelbag = /obj/item/storage/backpack/duffelbag/captain

	implants = list(/obj/item/implant/mindshield)
	accessory = /obj/item/clothing/accessory/medal/gold/captain

	chameleon_extras = list(/obj/item/gun/energy/e_gun, /obj/item/stamp/captain)

/datum/outfit/job/captain/mod
	name = "Captain (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/magnate
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/atmos
