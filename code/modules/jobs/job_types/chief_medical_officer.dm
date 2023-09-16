/datum/job/chief_medical_officer
	title = JOB_NAME_CHIEFMEDICALOFFICER
	flag = CMO_JF
	description = "Oversee paramedics, doctors, chemists, geneticists and the virologist. \
	Ensure doctors and paramedicts are treating people in a timely manner, request medicine and other concoctions from chemists, \
	and ensure geneticists and the virologist are following appropriate safety precautions while performing their research."
	department_for_prefs = DEPT_BITFLAG_MED
	department_head = list(JOB_NAME_CAPTAIN)
	supervisors = "the captain"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	head_announce = list(RADIO_CHANNEL_MEDICAL)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#c1e1ec"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 1200
	exp_type = EXP_TYPE_MEDICAL
	exp_type_department = EXP_TYPE_MEDICAL

	outfit = /datum/outfit/job/chief_medical_officer

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_HEADS, ACCESS_MINERAL_STOREROOM,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE, ACCESS_MECH_MEDICAL,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_BRIGPHYS, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_WEAPONS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_HEADS, ACCESS_MINERAL_STOREROOM,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE, ACCESS_MECH_MEDICAL,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_BRIGPHYS, ACCESS_EVA, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_WEAPONS)

	department_flag = MEDSCI
	departments = DEPT_BITFLAG_MED | DEPT_BITFLAG_COM
	bank_account_department = ACCOUNT_MED_BITFLAG | ACCOUNT_COM_BITFLAG
	payment_per_department = list(
		ACCOUNT_COM_ID = PAYCHECK_COMMAND_NT,
		ACCOUNT_MED_ID = PAYCHECK_COMMAND_DEPT)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	rpg_title = "High Cleric"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/cmo
	)
	biohazard = 45

	minimal_lightup_areas = list(
		/area/crew_quarters/heads/cmo,
		/area/medical/apothecary,
		/area/medical/chemistry,
		/area/medical/genetics,
		/area/medical/morgue,
		/area/medical/surgery,
		/area/storage/eva
	)

/datum/outfit/job/chief_medical_officer
	name = JOB_NAME_CHIEFMEDICALOFFICER
	jobtype = /datum/job/chief_medical_officer

	id = /obj/item/card/id/job/chief_medical_officer
	belt = /obj/item/modular_computer/tablet/pda/heads/chief_medical_officer
	l_pocket = /obj/item/pinpointer/crew
	r_pocket = /obj/item/flashlight/pen
	ears = /obj/item/radio/headset/heads/cmo
	uniform = /obj/item/clothing/under/rank/medical/chief_medical_officer
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/toggle/labcoat/cmo
	suit_store = /obj/item/storage/firstaid/medical
	backpack_contents = list(/obj/item/melee/classic_baton/police/telescopic=1)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = list(/obj/item/gun/syringe, /obj/item/stamp/cmo)

/datum/outfit/job/chief_medical_officer/hardsuit
	name = "Chief Medical Officer (Hardsuit)"

	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/medical/cmo
	suit_store = /obj/item/tank/internals/oxygen
	r_pocket = /obj/item/flashlight/pen
