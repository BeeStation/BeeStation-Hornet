/datum/job/head_of_security
	title = JOB_NAME_HEADOFSECURITY
	description = "Oversee the members of security and ensure they follow Space Law. Deputize other crew members when the station is in need of additional protection."
	department_for_prefs = DEPT_NAME_SECURITY
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	department_head = list(JOB_NAME_CAPTAIN)
	supervisors = "the captain"
	head_announce = list(RADIO_CHANNEL_SECURITY)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#ffdddd"
	req_admin_notify = 1
	minimal_player_age = 14
	exp_requirements = 1200
	exp_type = EXP_TYPE_SECURITY
	exp_type_department = EXP_TYPE_SECURITY

	outfit = /datum/outfit/job/head_of_security
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	base_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MECH_SECURITY,
						ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
						ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MAINT_TUNNELS)
	extra_access = list()

	departments = DEPT_BITFLAG_SEC | DEPT_BITFLAG_COM
	bank_account_department = ACCOUNT_SEC_BITFLAG | ACCOUNT_COM_BITFLAG
	payment_per_department = list(
		ACCOUNT_COM_ID = PAYCHECK_COMMAND_NT,
		ACCOUNT_SEC_ID = PAYCHECK_COMMAND_DEPT)

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_SECURITY
	rpg_title = "Guard Leader"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/head_of_security
	)

	minimal_lightup_areas = list(
		/area/crew_quarters/heads/hos,
		/area/security/detectives_office,
		/area/security/warden
	)

/datum/outfit/job/head_of_security
	name = JOB_NAME_HEADOFSECURITY
	jobtype = /datum/job/head_of_security

	id = /obj/item/card/id/job/head_of_security
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/heads/hos/alt
	uniform = /obj/item/clothing/under/rank/security/head_of_security
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/hos/trenchcoat
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/hats/hos/beret
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/modular_computer/tablet/pda/heads/head_of_security
	l_pocket = /obj/item/clothing/accessory/badge/officer/hos

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security

	implants = list(/obj/item/implant/mindshield)

	chameleon_extras = list(/obj/item/gun/energy/e_gun/hos, /obj/item/stamp/hos)

/datum/outfit/job/head_of_security/hardsuit
	name = "Head of Security (Hardsuit)"

	mask = /obj/item/clothing/mask/gas/sechailer
	suit = /obj/item/clothing/suit/space/hardsuit/security/head_of_security
	suit_store = /obj/item/tank/internals/oxygen
