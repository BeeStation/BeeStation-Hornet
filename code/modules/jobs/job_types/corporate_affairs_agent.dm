/datum/job/caa
	title = "Corporate Affairs Agent"
	flag = CAA
	department_head = list("Captain")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "Central Command"
	selection_color = "#ddddff"
	chat_color = "#50C878"
	exp_requirements = 840
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/caa

	access = list(ACCESS_CAA, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS,
				ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_RESEARCH, ACCESS_CARGO,
				ACCESS_HEADS)
	minimal_access = list(ACCESS_CAA, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_SEC_RECORDS,
				ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_RESEARCH, ACCESS_CARGO,
				ACCESS_HEADS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CIV
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CAA
	departments = DEPARTMENT_COMMAND | DEPARTMENT_SERVICE
	rpg_title = "Diplomat"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/caa
	)

/datum/outfit/job/caa
	name = "Corporate Affairs Agent"
	jobtype = /datum/job/caa

	id = /obj/item/card/id/job/caa
	belt = /obj/item/pda/caa
	ears = /obj/item/radio/headset/headset_caa
	uniform = /obj/item/clothing/under/suit/black
	suit = /obj/item/clothing/suit/toggle/caa/black
	shoes = /obj/item/clothing/shoes/laceup
	l_hand = /obj/item/storage/briefcase/caa
	l_pocket = /obj/item/laser_pointer
	neck = /obj/item/clothing/neck/tie/black
	glasses = /obj/item/clothing/glasses/sunglasses/advanced

	chameleon_extras = /obj/item/stamp/law

	implants = list(/obj/item/implant/mindshield)


/datum/outfit/job/caa/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

/datum/outfit/job/caa/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	H.dna.mutation_index[GLOWY] = create_sequence(GLOWY, FALSE, 8)
	H.dna.default_mutation_genes[GLOWY] = H.dna.mutation_index[GLOWY]
