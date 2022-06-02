/*				SCIENCE OBJECTIVES				*/

// Roboticst Botmaker -------------------------------------------------------
/datum/objective/crew/botmaker
	explanation_text = "Ensure there are at least (Yell on GitHub, something broke) functioning bots when the shift ends. The roundstarting ones don't count."
	jobs = "researchdirector,roboticist"
	var/static/roundstartcount

/datum/objective/crew/botmaker/New()
	. = ..()
	target_amount = rand(7,18)
	if(isnull(roundstartcount))
		roundstartcount = 0
		for(var/mob/living/simple_animal/bot/B in GLOB.alive_mob_list)
			roundstartcount++
	target_amount += roundstartcount
	update_explanation_text()

/datum/objective/crew/botmaker/update_explanation_text()
	. = ..()
	explanation_text = "Ensure there are at least [target_amount-roundstartcount] functioning bots when the shift ends. The roundstarting ones don't count."

/datum/objective/crew/botmaker/check_completion()
	var/botcount = target_amount
	for(var/mob/living/simple_animal/bot/B in GLOB.alive_mob_list)
		if(!(B.stat == DEAD))
			botcount--
		if(botcount <= 0)
			return TRUE
	return ..()

// scientist Tech research -------------------------------------------------------
/datum/objective/crew/servertech
	explanation_text = "reach 'val' tech tier from the station R&D server when the shift ends."
	jobs = "researchdirector,scientist"
	target_amount = 5

/datum/objective/crew/servertech/New()
	. = ..()
	update_explanation_text()

/datum/objective/crew/servertech/update_explanation_text()
	. = ..()
	explanation_text = "reach [target_amount] tech tier from the station R&D server when the shift ends."

/datum/objective/crew/servertech/check_completion()
	var/datum/techweb/stored_research = SSresearch.science_tech
	if(stored_research.current_tier >= target_amount)
		return TRUE
	return ..()

// scientist Xeno slime -------------------------------------------------------
/datum/objective/crew/xenoslime
	explanation_text = "have 'val' living slimes in the xenobiology lab when the shift ends."
	jobs = "researchdirector,scientist"

/datum/objective/crew/xenoslime/New()
	. = ..()
	target_amount = rand(33,60)
	update_explanation_text()

/datum/objective/crew/xenoslime/update_explanation_text()
	. = ..()
	explanation_text = "have [target_amount] living slimes in the xenobiology lab when the shift ends."

/datum/objective/crew/xenoslime/check_completion()
	var/list/xenobio_area = typecacheof(list(/area/science/xenobiology))
	var/slimecount = target_amount
	for(var/mob/living/simple_animal/slime/S in GLOB.alive_mob_list)
		var/area/A = get_area(S)
		if(S.stat != DEAD && is_station_level(S.z) && is_type_in_typecache(A, xenobio_area))
			slimecount--
		if(slimecount <= 0)
			return TRUE
	return ..()

// R&D nanites -------------------------------------------------------
/datum/objective/crew/scinanites
	explanation_text = "Let more than one third station crews have nanites."
	jobs = "researchdirector,scientist,roboticist"

/datum/objective/crew/scinanites/check_completion()
	var/realperson = 0
	var/hadnanites = 0
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		if(H.mind && H.mind.assigned_role)
			realperson++
		if(SEND_SIGNAL(H, COMSIG_HAS_NANITES))
			hadnanites++
	if(realperson/3 <= hadnanites) //don't have to `round(realperson/3)`
		return TRUE
	return ..()

// Exploration crew Lost tech -------------------------------------------------------
/datum/objective/crew/losttech
	explanation_text = "have a lost technology disk from explorative ruins when the shift ends."
	jobs = "explorationcrew"

/datum/objective/crew/losttech/check_completion()
	if(owner.current)
		if(owner.current.contents)
			for(var/obj/item/disk/tech_disk/research/D in owner.current.get_contents())
				var/objpath = D.type
				if(objpath in subtypesof(/obj/item/disk/tech_disk/research))
					return TRUE
	return ..()

//TODO: make the research objective work with techwebs
/*
/datum/objective/crew/research //inspired by old hippie's research level objective.
	var/datum/design/targetdesign
	explanation_text = "Make sure the research required to produce a (something broke, yell on GitHub) is available on the R&D server by the end of the shift."
	jobs = "researchdirector,scientist"

/datum/objective/crew/research/New()
	. = ..()
	targetdesign = pick(subtypesof(/datum/design))
	update_explanation_text()

/datum/objective/crew/research/update_explanation_text()
	. = ..()
	explanation_text = "Make sure the research required to produce a [initial(targetdesign.name)] is available on the R&D server by the end of the shift."

/datum/objective/crew/research/check_completion()
	for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
		if(S?.files?.known_designs)
			if(targetdesign in S.files.known_designs)
				return TRUE
	return ..()
*/
