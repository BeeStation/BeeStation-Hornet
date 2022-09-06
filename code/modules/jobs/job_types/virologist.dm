/datum/job/virologist
	title = JOB_NAME_VIROLOGIST
	flag = VIROLOGIST
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#d4ebf2"
	exp_requirements = 180
	exp_type = EXP_TYPE_MEDICAL
	exp_type_department = EXP_TYPE_MEDICAL

	outfit = /datum/outfit/job/virologist

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_MECH_MEDICAL, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_VIROLOGY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_VIROLOGIST
	departments = DEPARTMENT_BITFLAG_MEDICAL
	rpg_title = "Plague Doctor"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/virologist
	)
	biohazard = 50 //duh

/datum/outfit/job/virologist
	name = JOB_NAME_VIROLOGIST
	jobtype = /datum/job/virologist

	id = /obj/item/card/id/job/virologist
	belt = /obj/item/extrapolator
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical/virologist
	mask = /obj/item/clothing/mask/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat/virologist
	suit_store =  /obj/item/flashlight/pen
	r_pocket = /obj/item/pda/virologist

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel/vir
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	pda_slot = ITEM_SLOT_RPOCKET
