/datum/job/medical_doctor
	title = JOB_NAME_MEDICALDOCTOR
	description = "Treat people of both minor wounds, serious injuries and resurrect them from the dead. Make use of surgeries and surgical tools, Chemistry's pills and patches, Virology's viruses and in dire cases, Genetics' cloning."
	department_for_prefs = DEPT_NAME_MEDICAL
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	dynamic_spawn_group = JOB_SPAWN_GROUP_DEPARTMENT
	selection_color = "#d4ebf2"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/medical_doctor

	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS, ACCESS_VIROLOGY)

	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR
	rpg_title = "Cleric"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/medical
	)
	biohazard = 40

	lightup_areas = list(
		/area/medical/genetics,
		/area/medical/virology,
		/area/medical/chemistry,
		/area/medical/apothecary
	)
	minimal_lightup_areas = list(
		/area/medical/morgue,
		/area/medical/surgery,
		/area/medical/genetics/cloning
	)

	manuscript_jobs = list(
		JOB_NAME_MEDICALDOCTOR,
		JOB_NAME_CHEMIST // why not
	)

/datum/job/medical_doctor/get_access()
	. = ..()
	LOWPOP_GRANT_ACCESS(JOB_NAME_CHEMIST, ACCESS_CHEMISTRY)
	LOWPOP_GRANT_ACCESS(JOB_NAME_GENETICIST, ACCESS_GENETICS)
	if (SSjob.initial_players_to_assign < COMMAND_POPULATION_MINIMUM)
		. |= ACCESS_CMO

/datum/outfit/job/medical_doctor
	name = JOB_NAME_MEDICALDOCTOR
	jobtype = /datum/job/medical_doctor

	id = /obj/item/card/id/job/medical_doctor
	belt = /obj/item/modular_computer/tablet/pda/preset/medical
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/doctor
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	suit_store = /obj/item/storage/firstaid/medical
	l_pocket = /obj/item/flashlight/pen

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe

/datum/outfit/job/doctor/mod
	name = "Medical Doctor (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/medical
	suit = null
	head = null
	uniform = /obj/item/clothing/under/rank/medical/doctor
	mask = /obj/item/clothing/mask/breath/medical
	r_pocket = /obj/item/flashlight/pen
	internals_slot = ITEM_SLOT_SUITSTORE
