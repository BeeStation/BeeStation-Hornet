/datum/job/detective
	title = JOB_NAME_DETECTIVE
	flag = DETECTIVE
	description = "Investigate crimes, solve murder mysteries, report your findings to the rest of Security."
	department_for_prefs = DEPT_BITFLAG_SEC
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_NAME_HEADOFSECURITY)
	supervisors = "the head of security"
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#ffeeee"
	minimal_player_age = 7
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SECURITY

	outfit = /datum/outfit/job/detective

	access = list(ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_SECURITY, ACCESS_COURT, ACCESS_BRIG, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_SECURITY, ACCESS_COURT, ACCESS_BRIG, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)

	department_flag = ENGSEC
	departments = DEPT_BITFLAG_SEC
	bank_account_department = ACCOUNT_SEC_BITFLAG
	payment_per_department = list(ACCOUNT_SEC_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_DETECTIVE
	rpg_title = "Thiefcatcher"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/detective
	)

	minimal_lightup_areas = list(/area/medical/morgue, /area/security/detectives_office)

/datum/outfit/job/detective
	name = JOB_NAME_DETECTIVE
	jobtype = /datum/job/detective

	id = /obj/item/card/id/job/detective
	belt = /obj/item/storage/belt/fannypack/detective
	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/detective
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/det_suit
	suit_store = /obj/item/melee/classic_baton/police
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/fedora/det_hat
	l_pocket = /obj/item/modular_computer/tablet/pda/detective
	r_pocket = /obj/item/lighter

	mask = /obj/item/clothing/mask/cigarette

	implants = list(/obj/item/implant/mindshield)

	chameleon_extras = list(/obj/item/gun/ballistic/revolver/detective, /obj/item/clothing/glasses/sunglasses/advanced)

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/clothing/mask/cigarette/cig = H.wear_mask
	if(istype(cig)) //Some species specfic changes can mess this up (plasmamen)
		cig.light("")

	if(visualsOnly)
		return

/obj/item/storage/belt/fannypack/detective/PopulateContents()
	new /obj/item/storage/box/evidence(src)
	new /obj/item/detective_scanner(src)
	new /obj/item/toy/crayon/white(src)
