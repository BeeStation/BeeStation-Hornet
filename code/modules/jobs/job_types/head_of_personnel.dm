/datum/job/head_of_personnel
	title = JOB_NAME_HEADOFPERSONNEL
	description = "Second in command on the station, oversee the crew assigned to service and cargo positions, handle department transfer requests by consulting relevant heads. Protect Ian at all costs."
	department_for_prefs = DEPT_NAME_CAPTAIN
	department_head_for_prefs = JOB_NAME_CAPTAIN
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list(JOB_NAME_CAPTAIN)
	supervisors = "the captain"
	head_announce = list(RADIO_CHANNEL_SUPPLY, RADIO_CHANNEL_SERVICE)
	faction = "Station"
	total_positions = 1
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 10
	exp_requirements = 600
	exp_type = EXP_TYPE_COMMAND
	min_pop = COMMAND_POPULATION_MINIMUM

	outfit = /datum/outfit/job/head_of_personnel

	base_access = list(
		ACCESS_SEC_DOORS,
		ACCESS_COURT,
		ACCESS_WEAPONS,
		ACCESS_MEDICAL,
		ACCESS_ENGINE,
		ACCESS_CHANGE_IDS,
		ACCESS_AI_UPLOAD,
		ACCESS_EVA,
		ACCESS_HEADS,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_BAR,
		ACCESS_JANITOR,
		ACCESS_CONSTRUCTION,
		ACCESS_MORGUE,
		ACCESS_CREMATORIUM,
		ACCESS_KITCHEN,
		ACCESS_CARGO,
		ACCESS_MAILSORTING,
		ACCESS_QM,
		ACCESS_HYDROPONICS,
		ACCESS_LAWYER,
		ACCESS_THEATRE,
		ACCESS_CHAPEL_OFFICE,
		ACCESS_LIBRARY,
		ACCESS_RESEARCH,
		ACCESS_MINING,
		ACCESS_VAULT,
		ACCESS_MINING_STATION,
		ACCESS_MECH_MINING,
		ACCESS_MECH_ENGINE,
		ACCESS_MECH_SCIENCE,
		ACCESS_MECH_SECURITY,
		ACCESS_MECH_MEDICAL,
		ACCESS_EXPLORATION,
		ACCESS_HOP,
		ACCESS_RC_ANNOUNCE,
		ACCESS_KEYCARD_AUTH,
		ACCESS_GATEWAY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_AUX_BASE,
		ACCESS_SERVICE,
	)
	extra_access = list()

	departments = DEPT_BITFLAG_COM | DEPT_BITFLAG_SRV
	bank_account_department = ACCOUNT_SRV_BITFLAG | ACCOUNT_COM_BITFLAG
	payment_per_department = list(
		ACCOUNT_COM_ID = PAYCHECK_COMMAND_NT,
		ACCOUNT_SRV_ID = PAYCHECK_COMMAND_DEPT)

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL
	rpg_title = "Guild Questgiver"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/head_of_personnel
	)

	minimal_lightup_areas = list(/area/crew_quarters/heads/hop, /area/security/nuke_storage)

	manuscript_jobs = list(
		JOB_NAME_HEADOFPERSONNEL,
		JOB_NAME_BARTENDER,
		JOB_NAME_BOTANIST,
		JOB_NAME_COOK,
		JOB_NAME_JANITOR,
		JOB_NAME_MIME,
		JOB_NAME_CLOWN,

		JOB_NAME_ASSISTANT,
		JOB_NAME_BARBER,
		JOB_NAME_STAGEMAGICIAN,
		// JOB_NAME_CHAPLAIN, // holy knowledge is only allowed to people in religion
		JOB_NAME_CURATOR,
		JOB_NAME_LAWYER,
		JOB_NAME_PRISONER,

		JOB_NAME_QUARTERMASTER,
		JOB_NAME_CARGOTECHNICIAN,
		JOB_NAME_SHAFTMINER
	)

// Special handling to avoid lighting up the entirety of supply whenever there's a HoP.
/datum/job/head_of_personnel/areas_to_light_up(minimal_access = TRUE)
	return minimal_lightup_areas | GLOB.command_lightup_areas

/datum/outfit/job/head_of_personnel
	name = JOB_NAME_HEADOFPERSONNEL
	jobtype = /datum/job/head_of_personnel

	id = /obj/item/card/id/job/head_of_personnel
	belt = /obj/item/modular_computer/tablet/pda/preset/heads/head_of_personnel
	l_pocket = /obj/item/dog_bone
	ears = /obj/item/radio/headset/heads/head_of_personnel
	uniform = /obj/item/clothing/under/rank/civilian/head_of_personnel
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/hats/hopcap
	backpack_contents = list(
		/obj/item/storage/box/ids=1,
		/obj/item/melee/baton/telescopic=1
	)

	chameleon_extras = list(/obj/item/gun/energy/e_gun, /obj/item/stamp/head_of_personnel)
