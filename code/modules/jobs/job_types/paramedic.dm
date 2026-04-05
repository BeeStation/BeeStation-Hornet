/datum/job/paramedic
	title = JOB_NAME_PARAMEDIC
	description = "Retrieve the gravely injured and dead people from around the station, deliver medicine for minor wounds, and keep a close eye on the Crew Monitor in your free time."
	department_for_prefs = DEPT_NAME_MEDICAL
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	total_positions = 2
	selection_color = "#d4ebf2"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/paramedic

	base_access = list(
		ACCESS_MEDICAL,
		ACCESS_MORGUE,
		ACCESS_CLONING,
		ACCESS_MECH_MEDICAL,
		ACCESS_MAINT_TUNNELS,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_AUX_BASE
	)
	extra_access = list(ACCESS_SURGERY, ACCESS_MINERAL_STOREROOM, ACCESS_VIROLOGY)

	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR
	rpg_title = "Corpse Runner"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/paramedic
	)
	biohazard = 50//deal with sick like MDS, but also muck around in maint and get into the thick of it

	lightup_areas = list(/area/medical/surgery)
	minimal_lightup_areas = list(
		/area/storage/eva,
		/area/medical/morgue,
		/area/medical/genetics/cloning
	)

	manuscript_jobs = list(
		JOB_NAME_PARAMEDIC,
		JOB_NAME_BRIGPHYSICIAN  // They're somewhat identical
	)

/datum/outfit/job/paramedic
	name = JOB_NAME_PARAMEDIC
	jobtype = /datum/job/paramedic

	id = /obj/item/card/id/job/paramedic
	belt = /obj/item/modular_computer/tablet/pda/preset/paramedic
	ears = /obj/item/radio/headset/headset_med
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses/degraded
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	uniform = /obj/item/clothing/under/rank/medical/paramedic
	shoes = /obj/item/clothing/shoes/sneakers/white
	head = /obj/item/clothing/head/soft/paramedic
	suit =  /obj/item/clothing/suit/toggle/labcoat/paramedic
	l_pocket = /obj/item/pinpointer/crew
	r_pocket = /obj/item/sensor_device
	suit_store = /obj/item/storage/firstaid/medical/paramedic

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	box = /obj/item/storage/box/survival/medical
	chameleon_extras = /obj/item/gun/syringe
