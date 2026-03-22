/*				MEDICAL OBJECTIVES				*/

/datum/objective/crew/morgue //Ported from old Hippie
	explanation_text = "Ensure the Medbay has been cleaned of any corpses when the shift ends."
	jobs = list(
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_GENETICIST,
		JOB_NAME_MEDICALDOCTOR,
	)
	var/static/list/medical_areas = typecacheof(list(
		/area/medical/cryo,
		/area/medical/genetics/cloning,
		/area/medical/exam_room,
		/area/medical/medbay/aft,
		/area/medical/medbay/central,
		/area/medical/medbay/lobby,
		/area/medical/patients_rooms,
		/area/medical/sleeper,
		/area/medical/storage,
	))

/datum/objective/crew/morgue/check_completion()
	if(..())
		return TRUE
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		var/area/A = get_area(H)
		if(H.stat == DEAD && is_station_level(H.z) && is_type_in_typecache(A, medical_areas)) // If person is dead and corpse is in one of these areas
			return FALSE
	return TRUE

/datum/objective/crew/paramedicmorgue
	explanation_text = "Ensure that no corpses remain outside of Medbay when the shift ends."
	jobs = JOB_NAME_PARAMEDIC
	var/static/list/medical_areas_morgue = typecacheof(list(
		/area/medical/cryo,
		/area/medical/genetics/cloning,
		/area/medical/exam_room,
		/area/medical/medbay/aft,
		/area/medical/medbay/central,
		/area/medical/medbay/lobby,
		/area/medical/patients_rooms,
		/area/medical/sleeper,
		/area/medical/storage,
		/area/medical/morgue,
	))

/datum/objective/crew/paramedicmorgue/check_completion()
	if(..())
		return TRUE
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		var/area/A = get_area(H)
		if(H.stat == DEAD && is_station_level(H.z) && !is_type_in_typecache(A, medical_areas_morgue)) // If person is dead and corpse is NOT in one of these areas
			return FALSE
	return TRUE

/datum/objective/crew/chems
	var/target_chemical
	var/datum/reagent/target_chemical_name_obj
	explanation_text = "Have at least (yell on GitHub if this breaks) units of X chemical in the smartfridge when the shift ends."
	jobs = list(
		JOB_NAME_CHIEFMEDICALOFFICER,
		JOB_NAME_CHEMIST,
	)

/datum/objective/crew/chems/New()
	. = ..()
	target_chemical = get_random_reagent_id(CHEMICAL_GOAL_CHEMIST_USEFUL_MEDICINE)
	// because initial() is picky
	target_chemical_name_obj = target_chemical
	target_amount = rand(10,40)
	update_explanation_text()

/datum/objective/crew/chems/update_explanation_text()
	. = ..()
	explanation_text = "Have at least [target_amount] units total of [initial(target_chemical_name_obj.name)] in the chemistry smartfridge(s) or with you when the shift ends."

/datum/objective/crew/chems/check_completion()
	if(..())
		return TRUE
	var/units_total = 0
	if(owner?.current?.contents)
		for(var/obj/item/reagent_containers/container in owner.current.get_contents())
			units_total += container.reagents?.get_reagent_amount(target_chemical)
	for(var/obj/machinery/smartfridge/chemistry/fridge in GLOB.machines)
		for(var/obj/item/reagent_containers/container in fridge.contents)
			units_total += container.reagents?.get_reagent_amount(target_chemical)
	return units_total >= target_amount

/datum/objective/crew/noinfections
	explanation_text = "Make sure there are no living crew members with harmful diseases at the end of the shift."
	jobs = JOB_NAME_VIROLOGIST

/datum/objective/crew/noinfections/check_completion()
	if(..())
		return TRUE
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.stat == DEAD || (!is_station_level(H.z) && !SSshuttle.emergency.shuttle_areas[get_area(H)]))
			continue
		for(var/datum/disease/D as anything in H.diseases)
			if(get_disease_danger_value(D.danger) >= 6) // >= DISEASE_HARMFUL
				return FALSE
	return TRUE
