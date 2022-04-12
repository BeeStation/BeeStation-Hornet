/datum/job/iaa
	title = "Internal Affairs Agent"
	flag = IAA
	department_head = list("Captain")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Central Command"
	selection_color = "#dddddd"
	chat_color = "#C07D7D"

	outfit = /datum/outfit/job/iaa

	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS,
				ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_RESEARCH, ACCESS_CARGO)
	minimal_access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS,
				ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_RESEARCH, ACCESS_CARGO)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CIV
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_IAA
	departments = DEPARTMENT_SERVICE
	rpg_title = "Magistrate"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/lawyer
	)

/datum/outfit/job/iaa
	name = "Internal Affairs Agent"
	jobtype = /datum/job/iaa

	id = /obj/item/card/id/job/lawyer
	belt = /obj/item/pda/iaa
	ears = /obj/item/radio/headset/headset_iaa
	uniform = /obj/item/clothing/under/suit/black
	suit = /obj/item/clothing/suit/toggle/lawyer/black
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase/lawyer
	l_pocket = /obj/item/laser_pointer
	r_pocket = /obj/item/assembly/flash/handheld
	neck = /obj/item/clothing/neck/tie/black
	glasses = /obj/item/clothing/glasses/sunglasses/advanced

	chameleon_extras = /obj/item/stamp/law

	implants = list(/obj/item/implant/mindshield)


/datum/outfit/job/iaa/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

/datum/outfit/job/iaa/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	H.dna.mutation_index[GLOWY] = create_sequence(GLOWY, FALSE, 8)
	H.dna.default_mutation_genes[GLOWY] = H.dna.mutation_index[GLOWY]
