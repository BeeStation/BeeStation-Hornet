/datum/job/warden
	title = JOB_NAME_WARDEN
	description = "Oversee prisoners in the brig and guard the armory. Hand out equipment when necessary and ensure it is returned after threats have been contained."
	department_for_prefs = DEPT_NAME_SECURITY
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_NAME_HEADOFSECURITY)
	supervisors = "the head of security"
	faction = "Station"
	total_positions = 1
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 600
	exp_type = EXP_TYPE_SECURITY

	outfit = /datum/outfit/job/warden

	base_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_BRIG, ACCESS_BRIGPHYS, ACCESS_ARMORY, ACCESS_MECH_SECURITY,
						ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM) // See /datum/job/warden/get_access()
	extra_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MORGUE,ACCESS_FORENSICS_LOCKERS)

	departments = DEPT_BITFLAG_SEC
	bank_account_department = ACCOUNT_SEC_BITFLAG
	payment_per_department = list(ACCOUNT_SEC_ID = PAYCHECK_HARD)
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM, TRAIT_SECURITY)

	display_order = JOB_DISPLAY_ORDER_WARDEN
	rpg_title = "Jailor"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/warden
	)

	lightup_areas = list(/area/security/detectives_office)
	minimal_lightup_areas = list(/area/security/warden)

	manuscript_jobs = list(
		JOB_NAME_WARDEN,
		JOB_NAME_SECURITYOFFICER // technically, Warden is just promoted seccie, right?
	)

/datum/job/warden/get_access()
	. = ..()
	if(check_config_for_sec_maint())
		. |= ACCESS_MAINT_TUNNELS

/datum/outfit/job/warden
	name = JOB_NAME_WARDEN
	jobtype = /datum/job/warden

	id = /obj/item/card/id/job/warden
	belt = /obj/item/storage/belt/security/full
	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/warden
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/warden/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/hats/warden/red
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	l_pocket = /obj/item/clothing/accessory/badge
	r_pocket = /obj/item/modular_computer/tablet/pda/preset/warden
	accessory = /obj/item/clothing/accessory/security_pager

	backpack = /obj/item/storage/backpack/security
	backpack_contents = list(
		/obj/item/dog_bone = 1,
		/obj/item/mining_voucher/security = 1,
	)
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security

	implants = list(/obj/item/implant/mindshield)

	chameleon_extras = /obj/item/gun/ballistic/shotgun/automatic/combat/compact

