/*				CARGO OBJECTIVES				*/

/datum/objective/crew/petsplosion
	explanation_text = "Ensure there are at least (If you see this, yell on GitHub) pets on the station by the end of the shift. Interpret this as you wish."
	jobs = list(
		JOB_NAME_QUARTERMASTER,
		JOB_NAME_CARGOTECHNICIAN,
	)

/datum/objective/crew/petsplosion/New()
	. = ..()
	target_amount = rand(10,30)
	update_explanation_text()

/datum/objective/crew/petsplosion/update_explanation_text()
	. = ..()
	explanation_text = "Ensure there are at least [target_amount] pets on the station by the end of the shift. Interpret this as you wish."

/datum/objective/crew/petsplosion/check_completion()
	if(..())
		return TRUE
	var/petcount = target_amount
	for(var/mob/living/simple_animal/pet/P in GLOB.mob_list)
		if(!(P.stat == DEAD))
			if((P.z in SSmapping.levels_by_trait(ZTRAIT_STATION)) || SSshuttle.emergency.shuttle_areas[get_area(P)])
				petcount--
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(!(H.stat == DEAD))
			if((H.z in SSmapping.levels_by_trait(ZTRAIT_STATION)) || SSshuttle.emergency.shuttle_areas[get_area(H)])
				if(istype(H.wear_neck, /obj/item/clothing/neck/petcollar))
					petcount--
	return petcount <= 0

/datum/objective/crew/points //ported from old hippie
	explanation_text = "Make sure the station has at least (Something broke, yell on GitHub) station credits at the end of the shift."
	jobs = list(
		JOB_NAME_QUARTERMASTER,
		JOB_NAME_CARGOTECHNICIAN,
	)

/datum/objective/crew/points/New()
	. = ..()
	target_amount = rand(25000,100000)
	update_explanation_text()

/datum/objective/crew/points/update_explanation_text()
	. = ..()
	explanation_text = "Make sure the station has at least [target_amount] station credits at the end of the shift."

/datum/objective/crew/points/check_completion()
	if(..())
		return TRUE
	var/datum/bank_account/C = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	return C.account_balance >= target_amount

/datum/objective/crew/bubblegum
	explanation_text = "Ensure Bubblegum is dead at the end of the shift."
	jobs = JOB_NAME_SHAFTMINER

/datum/objective/crew/bubblegum/check_completion()
	if(..())
		return TRUE
	for(var/mob/living/simple_animal/hostile/megafauna/bubblegum/B in GLOB.mob_list)
		if(B.stat != DEAD)
			return FALSE
	return TRUE

/datum/objective/crew/fatstacks //ported from old hippie
	explanation_text = "Have at least (something broke, report this on GitHub) mining points on your ID at the end of the shift."
	jobs = JOB_NAME_SHAFTMINER

/datum/objective/crew/fatstacks/New()
	. = ..()
	target_amount = rand(15000,50000)
	update_explanation_text()

/datum/objective/crew/fatstacks/update_explanation_text()
	. = ..()
	explanation_text = "Have at least [target_amount] mining points on your bank account at the end of the shift."

/datum/objective/crew/fatstacks/check_completion()
	if(..())
		return TRUE
	var/mob/living/carbon/human/H = owner?.current
	if(!istype(H))
		return FALSE
	var/datum/bank_account/your_account = SSeconomy.get_bank_account_by_id(owner.account_id)
	if(your_account.report_currency(ACCOUNT_CURRENCY_MINING) >= target_amount)
		return TRUE
	return FALSE
