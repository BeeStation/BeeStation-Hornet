/*

	Advance Disease is a system for Virologist to Engineer their own disease with symptoms that have effects and properties
	which add onto the overall disease.

	If you need help with creating new symptoms or expanding the advance disease, ask for Giacom on #coderbus.

*/




/*

	PROPERTIES

 */

/datum/disease/advance
	name = "Unknown" // We will always let our Virologist name our disease.
	desc = "An engineered disease which can contain a multitude of symptoms."
	form = "Advance Disease" // Will let med-scanners know that this disease was engineered.
	agent = "advance microbes"
	max_stages = 5
	spread_text = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey, /mob/living/carbon/monkey/tumor)

	/// last player to modify the disease.
	var/last_modified_by = "no CKEY"
	var/resistance
	var/stealth
	var/stage_rate
	var/transmission
	var/severity
	var/speed
	var/list/symptoms = list() // The symptoms of the disease.
	var/id = ""
	var/processing = FALSE
	var/mutable = TRUE //set to FALSE to prevent most in-game methods of altering the disease via virology
	var/oldres
	var/faltered = FALSE //used if a disease has been made non-contagious
	// The order goes from easy to cure to hard to cure.
	var/mutability = 1
	var/dormant = FALSE //this prevents a disease from having any effects or spreading
	var/keepid = FALSE
	var/archivecure
	var/event = FALSE // check if this virus spawned as a part of an event.
	var/static/list/advance_cures = list(
		list(/datum/reagent/water, /datum/reagent/consumable/nutriment, /datum/reagent/ash, /datum/reagent/iron),
		list(/datum/reagent/consumable/ethanol, /datum/reagent/uranium/radium, /datum/reagent/oil, /datum/reagent/potassium, /datum/reagent/lithium),
		list(/datum/reagent/consumable/sodiumchloride, /datum/reagent/drug/nicotine, /datum/reagent/drug/space_drugs),
		list(/datum/reagent/medicine/salglu_solution, /datum/reagent/medicine/antihol, /datum/reagent/fuel, /datum/reagent/space_cleaner),
		list(/datum/reagent/medicine/spaceacillin, /datum/reagent/toxin/mindbreaker, /datum/reagent/toxin/itching_powder, /datum/reagent/medicine/cryoxadone, /datum/reagent/medicine/epinephrine),
		list(/datum/reagent/medicine/mine_salve, /datum/reagent/medicine/oxandrolone, /datum/reagent/medicine/atropine),
		list(/datum/reagent/medicine/leporazine, /datum/reagent/water/holywater, /datum/reagent/medicine/neurine),
		list(/datum/reagent/concentrated_barbers_aid, /datum/reagent/drug/happiness, /datum/reagent/medicine/pen_acid),
		list(/datum/reagent/medicine/haloperidol, /datum/reagent/pax, /datum/reagent/gunpowder, /datum/reagent/medicine/diphenhydramine),
		list(/datum/reagent/toxin/lipolicide, /datum/reagent/drug/ketamine, /datum/reagent/drug/methamphetamine),
		list(/datum/reagent/drug/krokodil, /datum/reagent/hair_dye, /datum/reagent/medicine/modafinil)
		)
/*

	OLD PROCS

 */

/datum/disease/advance/New()
	Refresh()

/datum/disease/advance/Destroy()
	if(affected_mob)
		SEND_SIGNAL(affected_mob, COMSIG_DISEASE_END, GetDiseaseID())
		UnregisterSignal(affected_mob, COMSIG_MOB_DEATH)
	if(processing)
		for(var/datum/symptom/S in symptoms)
			S.End(src)
	return ..()

/**
* add the disease with no checks
* Don't use this proc. use ForceContractDisease on mob/living/carbon instead
*/
/datum/disease/advance/try_infect(mob/living/infectee, make_copy = TRUE)
	//see if we are more transmittable than enough diseases to replace them
	//diseases replaced in this way do not confer immunity
	var/list/advance_diseases = list()
	var/channel = CheckChannel() //we do this because this can break otherwise, for some obscure reason i cannot fathom
	for(var/datum/disease/advance/P in infectee.diseases)
		var/otherchannel = P.CheckChannel()
		if(dormant || P.dormant)//dormant diseases dont interfere with channels, not even with other dormant diseases if you manage to get two
			continue
		if(IsSame(P))
			continue
		if(channel == otherchannel)
			advance_diseases += P
	var/replace_num = advance_diseases.len + 1 - DISEASE_LIMIT //amount of diseases that need to be removed to fit this one
	if(replace_num > 0)
		sort_list(advance_diseases, GLOBAL_PROC_REF(cmp_advdisease_resistance_asc))
		for(var/i in 1 to replace_num)
			var/datum/disease/advance/competition = advance_diseases[i]
			if(transmission > (competition.resistance * 2))
				competition.cure(FALSE)
			else
				return FALSE //we are not strong enough to bully our way in
	infect(infectee, make_copy)
	return TRUE

/datum/disease/advance/after_add()
	if(affected_mob)
		RegisterSignal(affected_mob, COMSIG_MOB_DEATH, PROC_REF(on_mob_death))

/datum/disease/advance/proc/on_mob_death()
	SIGNAL_HANDLER

	for(var/datum/symptom/S as() in symptoms)
		S.OnDeath(src)

// Randomly pick a symptom to activate.
/datum/disease/advance/stage_act(delta_time, times_fired)
	if(dormant)
		return
	. = ..()
	if(!.)
		return

	if(!length(symptoms))
		return

	if(!processing)
		processing = TRUE
		for(var/s in symptoms)
			var/datum/symptom/symptom_datum = s
			if(symptom_datum.Start(src)) //this will return FALSE if the symptom is neutered
				symptom_datum.next_activation = world.time + rand(symptom_datum.symptom_delay_min SECONDS, symptom_datum.symptom_delay_max SECONDS)
			symptom_datum.on_stage_change(src)

	for(var/s in symptoms)
		var/datum/symptom/symptom_datum = s
		symptom_datum.Activate(src)

// Tell symptoms stage changed
/datum/disease/advance/update_stage(new_stage)
	..()
	for(var/datum/symptom/S as() in symptoms)
		S.on_stage_change(src)

// Compares type then ID.
/datum/disease/advance/IsSame(datum/disease/advance/D)
	if(!istype(D, /datum/disease/advance))
		return FALSE

	if(GetDiseaseID() != D.GetDiseaseID())
		return FALSE
	return TRUE

// Returns the advance disease with a different reference memory.
/datum/disease/advance/Copy()
	var/datum/disease/advance/A = ..()
	QDEL_LIST(A.symptoms)
	for(var/datum/symptom/S as() in symptoms)
		A.symptoms += S.Copy()
	if(!CONFIG_GET(flag/biohazards_allowed))
		A.dormant = dormant
	A.mutable = mutable
	A.initial = initial
	A.faltered = faltered
	A.resistance = resistance
	A.stealth = stealth
	A.stage_rate = stage_rate
	A.transmission = transmission
	A.severity = severity
	A.speed = speed
	A.keepid = keepid
	A.id = id
	A.event = event
	A.Refresh()
	//this is a new disease starting over at stage 1, so processing is not copied
	return A

//Describe this disease to an admin in detail (for logging)
/datum/disease/advance/admin_details()
	var/list/name_symptoms = list()
	for(var/datum/symptom/S in symptoms)
		name_symptoms += S.name

	return "[name], last modified by: [last_modified_by] symptoms:[english_list(name_symptoms)] resistance:[resistance] stealth:[stealth] speed:[stage_rate] transmission:[transmission] faltered:[faltered ? "Yes" : "No"]"

/*

	NEW PROCS

 */

// Mix the symptoms of two diseases (the src and the argument)
/datum/disease/advance/proc/Mix(datum/disease/advance/D)
	if(!(IsSame(D)))
		var/list/possible_symptoms = list()
		if(CONFIG_GET(flag/seeded_symptoms)) //two diseases mixing always returns the same result if this option is on
			for(var/datum/symptom/S in symptoms)
				possible_symptoms += S
				RemoveSymptom(S)
			for(var/datum/symptom/S in D.symptoms)
				possible_symptoms += S
			possible_symptoms = sort_list(possible_symptoms, GLOBAL_PROC_REF(cmp_advdisease_symptomid_asc))
		else
			possible_symptoms = shuffle(D.symptoms)
		for(var/datum/symptom/S in possible_symptoms)
			AddSymptom(S.Copy())

/datum/disease/advance/proc/HasSymptom(datum/symptom/S)
	for(var/datum/symptom/symp in symptoms)
		if(symp.type == S.type)
			return TRUE
	return FALSE

// Will generate new unique symptoms, use this if there are none. Returns a list of symptoms that were generated.
/datum/disease/advance/proc/GenerateSymptoms(level_min, level_max, amount_get = 0)

	var/list/generated = list() // Symptoms we generated.

	// Generate symptoms. By default, we only choose non-deadly symptoms.
	var/list/possible_symptoms = list()
	for(var/symp in SSdisease.list_symptoms)
		var/datum/symptom/S = new symp
		if(S.naturally_occuring && S.level >= level_min && S.level <= level_max)
			if(!HasSymptom(S))
				possible_symptoms += S

	if(!possible_symptoms.len)
		return generated

	// Random chance to get more than one symptom
	var/number_of = amount_get
	if(!amount_get)
		number_of = 1
		while(prob(20))
			number_of += 1

	for(var/i = 1; number_of >= i && possible_symptoms.len; i++)
		generated += pick_n_take(possible_symptoms)

	return generated

/datum/disease/advance/proc/Refresh(new_name = FALSE)
	GenerateProperties()
	AssignProperties()
	if(processing && symptoms && symptoms.len)
		for(var/datum/symptom/S in symptoms)
			S.Start(src)
			S.on_stage_change(src)
	if(!keepid)
		id = null
	var/the_id = GetDiseaseID()
	if(!SSdisease.archive_diseases[the_id])
		SSdisease.archive_diseases[the_id] = src // So we don't infinite loop
		SSdisease.archive_diseases[the_id] = Copy()
		if(new_name)
			AssignName()
	else
		var/actual_name = SSdisease.get_disease_name(GetDiseaseID())
		if(actual_name != "Unknown")
			name = actual_name


//Generate disease properties based on the effects. Returns an associated list.
/datum/disease/advance/proc/GenerateProperties()
	resistance = 0
	stealth = 0
	stage_rate = 0
	transmission = 0
	severity = 0
	var/c1sev
	var/c2sev
	var/c3sev
	for(var/datum/symptom/S as() in symptoms)
		resistance += S.resistance
		stealth += S.stealth
		stage_rate += S.stage_speed
		transmission += S.transmission
	for(var/datum/symptom/S as() in symptoms)
		S.severityset(src)
		if(S.neutered)
			continue
		switch(S.severity)
			if(-INFINITY to 0)
				c1sev += S.severity
			if(1 to 2)
				c2sev= max(c2sev, min(3, (S.severity + c2sev)))
			if(3 to 4)
				c2sev = max(c2sev, min(4, (S.severity + c2sev)))
			if(5 to INFINITY)
				if(c3sev >= 5)
					c3sev += (S.severity -3)//diminishing returns
				else
					c3sev += S.severity
	severity += (max(c2sev, c3sev) + c1sev)


// Assign the properties that are in the list.
/datum/disease/advance/proc/AssignProperties()
	if(dormant || stealth >= 2)//dormant diseases dont need to show up for normal docs
		visibility_flags |= HIDDEN_SCANNER
	else
		visibility_flags &= ~HIDDEN_SCANNER

	SetSpread()
	spreading_modifier = max(CEILING(0.4 * transmission, 1), 1)
	cure_chance = clamp(7.5 - (0.5 * resistance), 5, 10) // can be between 5 and 10
	stage_prob = max(stage_rate, 1)
	SetDanger(severity)
	GenerateCure()
	symptoms = sort_list(symptoms, GLOBAL_PROC_REF(cmp_advdisease_symptomid_asc))



// Assign the spread type and give it the correct description.
/datum/disease/advance/proc/SetSpread()
	if(faltered)
		spread_flags = DISEASE_SPREAD_FALTERED
		spread_text = "Intentional Injection"
	else if(dormant)
		if(CONFIG_GET(flag/biohazards_allowed))
			spread_flags = DISEASE_SPREAD_BLOOD
			spread_text = "Blood"
		else
			spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
			spread_text = "None"
	else
		switch(transmission)
			if(-INFINITY to 5)
				spread_flags = DISEASE_SPREAD_BLOOD
				spread_text = "Blood"
			if(6 to 10)
				spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS
				spread_text = "Fluids"
			if(11 to INFINITY)
				spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_CONTACT_SKIN
				spread_text = "On contact"

/datum/disease/advance/proc/SetDanger(level_sev)
	switch(level_sev)
		if(-INFINITY to -2)
			danger = DISEASE_BENEFICIAL
		if(-1)
			danger = DISEASE_POSITIVE
		if(0)
			danger = DISEASE_NONTHREAT
		if(1)
			danger = DISEASE_MINOR
		if(2)
			danger = DISEASE_MEDIUM
		if(3)
			danger = DISEASE_HARMFUL
		if(4)
			danger = DISEASE_DANGEROUS
		if(5)
			danger = DISEASE_BIOHAZARD
		if(6 to INFINITY)
			danger = DISEASE_PANDEMIC
		else
			danger = "Unknown"

/datum/disease/advance/proc/CheckChannel() //i hate that i have to  use this to make this work
	switch(severity)
		if(-INFINITY to -2)
			return 1
		if(-1)
			return 1
		if(0)
			return 1
		if(1)
			return 2
		if(2)
			return 2
		if(3)
			return 2
		if(4)
			return 2
		if(5)
			return 3
		if(6 to INFINITY)
			return 3
		else
			return 2

// Will generate a random cure, the less resistance the symptoms have, the harder the cure.
/datum/disease/advance/proc/GenerateCure()
	var/res = clamp(resistance - (symptoms.len / 2), 1, advance_cures.len)
	if(archivecure != res)
		cures = list(pick(advance_cures[res]))
		// Get the cure name from the cure_id
		var/datum/reagent/D = GLOB.chemical_reagents_list[cures[1]]
		cure_text = D.name
	archivecure = res


// Randomly generate a symptom, has a chance to lose or gain a symptom.
/datum/disease/advance/proc/Evolve(min_level, max_level, ignore_mutable = FALSE)
	if(!mutable && !ignore_mutable)
		return
	var/s = safepick(GenerateSymptoms(min_level, max_level, 1))
	if(s)
		AddSymptom(s)
	return

// Randomly remove a symptom.
/datum/disease/advance/proc/Devolve(ignore_mutable = FALSE)
	if(!mutable && !ignore_mutable)
		return
	if(symptoms.len > 1)
		RemoveRandomSymptom()
		Refresh(TRUE)

// Randomly neuter a symptom.
/datum/disease/advance/proc/Neuter(ignore_mutable = FALSE)
	if(!mutable && !ignore_mutable)
		return
	if(symptoms.len)
		var/s = safepick(symptoms)
		if(s)
			NeuterSymptom(s)
			Refresh(TRUE)

// Name the disease.
/datum/disease/advance/proc/AssignName(name = "Unknown")
	Refresh()
	var/datum/disease/advance/A = SSdisease.archive_diseases[GetDiseaseID()]
	A.name = name
	for(var/datum/disease/advance/AD in SSdisease.active_diseases)
		AD.Refresh()

// Return a unique ID of the disease.
/datum/disease/advance/GetDiseaseID()
	if(!id)
		var/list/L = list()
		for(var/datum/symptom/S in symptoms)
			if(S.neutered)
				L += "[S.id]N"
			else
				L += S.id
		L = sort_list(L) // Sort the list so it doesn't matter which order the symptoms are in.
		var/result = jointext(L, ":")
		id = result
	return id

//This proc is used when creating diseases, to call OnAdd for each symptom to make sure the symptoms work as they should
/datum/disease/advance/proc/Finalize()
	for(var/datum/symptom/S in symptoms)
		S.OnAdd(src)


// Add a symptom, if it is over the limit we take a random symptom away and add the new one.
/datum/disease/advance/proc/AddSymptom(datum/symptom/S)
	if(HasSymptom(S))
		return
	if(symptoms.len >= VIRUS_SYMPTOM_LIMIT)
		RemoveRandomSymptom()
	symptoms += S
	S.OnAdd(src)
	Refresh()

//removes a random symptom. If SEEDED_SYMPTOMS is on in config, removes a symptom predetermined at roundstart instead
/datum/disease/advance/proc/RemoveRandomSymptom()
	if(CONFIG_GET(flag/seeded_symptoms))
		var/list/orderlysymptoms = list()
		for(var/datum/symptom/S in symptoms)
			orderlysymptoms += S //sort symptoms by their ID. Symptom ID is chosen based on order in the symptom list, which is randomized on disease subsystem init
		var/list/queuedsymptoms = sort_list(orderlysymptoms, GLOBAL_PROC_REF(cmp_advdisease_symptomid_asc))
		RemoveSymptom(queuedsymptoms[1])
	else
		RemoveSymptom(pick(symptoms))

// Simply removes the symptom.
/datum/disease/advance/proc/RemoveSymptom(datum/symptom/S)
	symptoms -= S
	S.OnRemove(src)

// Neuter a symptom, so it will only affect stats
/datum/disease/advance/proc/NeuterSymptom(datum/symptom/S)
	if(!S.neutered)
		S.neutered = TRUE
		S.name += " (neutered)"
		S.OnRemove(src)

/*

	Static Procs

*/

// Mix a list of advance diseases and return the mixed result.
/proc/Advance_Mix(list/D_list)
	var/list/diseases = list()

	for(var/datum/disease/advance/A in D_list)
		if(!A.mutable)
			continue
		diseases += A.Copy()

	if(!diseases.len)
		return null
	if(diseases.len <= 1)
		return pick(diseases) // Just return the only entry.

	var/i = 0
	// Mix our diseases until we are left with only one result.
	while(i < 20 && diseases.len > 1)

		i++

		var/datum/disease/advance/D1 = pick(diseases)
		diseases -= D1

		var/datum/disease/advance/D2 = pick(diseases)
		D2.Mix(D1)

	// Should be only 1 entry left, but if not let's only return a single entry
	var/datum/disease/advance/to_return = pick(diseases)
	to_return.dormant = FALSE
	to_return.Refresh(new_name = TRUE)
	return to_return

/proc/SetViruses(datum/reagent/R, list/data)
	if(data)
		var/list/preserve = list()
		if(istype(data) && data["viruses"])
			for(var/datum/disease/A in data["viruses"])
				preserve += A.Copy()
			R.data = data.Copy()
		if(preserve.len)
			R.data["viruses"] = preserve

/proc/AdminCreateVirus(client/user)

	if(!user)
		return

	var/i = VIRUS_SYMPTOM_LIMIT

	var/datum/disease/advance/D = new(0, null)
	D.symptoms = list()

	var/list/symptoms = list()
	symptoms += "Done"
	symptoms += SSdisease.list_symptoms.Copy()
	do
		if(user)
			var/symptom = input(user, "Choose a symptom to add ([i] remaining)", "Choose a Symptom") in sort_list(symptoms, GLOBAL_PROC_REF(cmp_typepaths_asc))
			if(isnull(symptom))
				return
			else if(istext(symptom))
				i = 0
			else if(ispath(symptom))
				var/datum/symptom/S = new symptom
				if(!D.HasSymptom(S))
					D.symptoms += S
					i -= 1
	while(i > 0)

	if(D.symptoms.len > 0)

		var/new_name = stripped_input(user, "Name your new disease.", "New Name")
		if(!new_name)
			return
		D.AssignName(new_name)
		D.Refresh()
		D.Finalize()

		for(var/datum/disease/advance/AD in SSdisease.active_diseases)
			AD.Refresh()

		for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
			if(!is_station_level(H.z))
				continue
			if(!H.HasDisease(D))
				H.ForceContractDisease(D)
				break

		var/list/name_symptoms = list()
		for(var/datum/symptom/S in D.symptoms)
			name_symptoms += S.name
		message_admins("[key_name_admin(user)] has triggered a custom virus outbreak of [D.admin_details()]")
		log_virus("[key_name(user)] has triggered a custom virus outbreak of [D.admin_details()]!")

/datum/disease/advance/infect(var/mob/living/infectee, make_copy = TRUE)
	var/datum/disease/advance/A = make_copy ? Copy() : src
	if(!initial && A.mutable && (spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
		var/minimum = 1
		if(prob(clamp(35-(A.resistance + A.stealth - A.speed), 0, 50) * (A.mutability)))//stealthy/resistant diseases are less likely to mutate. this means diseases used to farm mutations should be easier to cure. hypothetically.
			if(infectee.job == "clown" || infectee.job == "mime" || prob(1))//infecting a clown or mime can evolve l0 symptoms/. they can also appear very rarely
				minimum = 0
			else
				minimum = clamp(A.severity - 1, 1, 7)
			A.Evolve(minimum, clamp(A.severity + 4, minimum, 9))
			A.id = GetDiseaseID()
			A.keepid = TRUE//this is really janky, but basically mutated diseases count as the original disease
				//if you want to evolve a higher level symptom you need to test and spread a deadly virus among test subjects.
				//this is to give monkey testing a use, and add a bit more of a roleplay element to virology- testing deadly diseases on and curing/vaccinating monkeys
				//this also adds the risk of disease escape if strict biohazard protocol is not followed, however
				//the immutability of resistant diseases discourages this with hard-to-cure diseases.
				//if players intentionally grief/cant seem to get biohazard protocol down, this can be changed to not use severity.
	else
		A.initial = FALSE //diseases *only* mutate when spreading. they wont mutate from any other kind of injection
	infectee.diseases += A
	A.affected_mob = infectee
	SSdisease.active_diseases += A //Add it to the active diseases list, now that it's actually in a mob and being processed.

	A.after_add()
	infectee.med_hud_set_status()

	var/turf/source_turf = get_turf(infectee)
	log_virus("[key_name(infectee)] was infected by virus: [src.admin_details()] at [loc_name(source_turf)]")


/datum/disease/advance/proc/random_disease_name(var/atom/diseasesource)//generates a name for a disease depending on its symptoms and where it comes from
	// If this just has 1 symptom, use that symptom's name.
	if(length(symptoms) == 1)
		var/datum/symptom/main_symptom = symptoms[1]
		if(istype(main_symptom) && length(main_symptom.name))
			return main_symptom.name
	var/list/prefixes = list("Spacer's ", "Space ", "Infectious ","Viral ", "The ", "[pick(GLOB.first_names)]'s ", "[pick(GLOB.last_names)]'s ", "Acute ")//prefixes that arent tacked to the body need spaces after the word
	var/list/bodies = list(pick("[pick(GLOB.first_names)]", "[pick(GLOB.last_names)]"), "Space", "Disease", "Noun", "Cold", "Germ", "Virus")
	var/list/suffixes = list("ism", "itis", "osis", "itosis", " #[rand(1,10000)]", "-[rand(1,100)]", "s", "y", "ovirus", " Bug", " Infection", " Disease", " Complex", " Syndrome", " Sickness") //suffixes that arent tacked directly on need spaces before the word
	if(stealth >=2)
		prefixes += "Crypto "
	switch(max(resistance - (symptoms.len / 2), 1))
		if(1)
			suffixes += "-alpha"
		if(2)
			suffixes += "-beta"
		if(3)
			suffixes += "-gamma"
		if(4)
			suffixes += "-delta"
		if(5)
			suffixes += "-epsilon"
		if(6)
			suffixes += pick("-zeta", "-eta", "-theta", "-iota")
		if(7)
			suffixes += pick("-kappa", "-lambda")
		if(8)
			suffixes += pick("-mu", "-nu", "-xi", "-omicron")
		if(9)
			suffixes += pick("-pi", "-rho", "-sigma", "-tau")
		if(10)
			suffixes += pick("-upsilon", "-phi", "-chi", "-psi")
		if(11 to INFINITY)
			suffixes += "-omega"
			prefixes += "Robust "
	switch(transmission - symptoms.len)
		if(-INFINITY to 2)
			prefixes += "Bloodborne "
		if(3)
			prefixes += list("Mucous ", "Kissing ")
		if(4)
			prefixes += "Contact "
			suffixes += " Flu"
		if(5 to INFINITY)
			prefixes += "Airborne "
			suffixes += " Plague"
	switch(severity)
		if(-INFINITY to 0)
			prefixes += "Altruistic "
		if(1 to 2)
			prefixes += "Benign "
		if(3 to 4)
			prefixes += "Malignant "
		if(5)
			prefixes += "Terminal "
			bodies += "Death"
		if(6 to INFINITY)
			prefixes += "Deadly "
			bodies += "Death"
	if(diseasesource)
		if(ishuman(diseasesource))
			var/mob/living/carbon/human/H = diseasesource
			prefixes += pick("[H.first_name()]'s", "[H.name]'s", "[H.job]'s", "[H.dna.species]'s")
			bodies += pick("[H.first_name()]", "[H.job]", "[H.dna.species]")
			if(islizard(H) || iscatperson(H))//add rat-origin prefixes to races that eat rats
				prefixes += list("Vermin ", "Zoo", "Maintenance ")
				bodies += list("Rat", "Maint")
		else switch(diseasesource.type)
			if(/mob/living/simple_animal/pet/hamster/vector)
				prefixes += list("Vector's ", "Hamster ")
				bodies += list("Freebie")
			if(/obj/effect/decal/cleanable)
				prefixes += list("Bloody ", "Maintenance ")
				bodies += list("Maint")
			if(/mob/living/simple_animal/mouse)
				prefixes += list("Vermin ", "Zoo", "Maintenance ")
				bodies += list("Rat", "Maint")
			if(/obj/item/reagent_containers/syringe)
				prefixes += list("Junkie ", "Maintenance ")
				bodies += list("Needle", "Maint")
			if(/obj/item/fugu_gland)
				prefixes += "Wumbo"
			if(/obj/item/organ/lungs)
				prefixes += "Miasmic "
				bodies += list("Stench", "Lung")
	for(var/datum/symptom/Symptom as() in symptoms)
		if(!Symptom.neutered)
			prefixes += Symptom.prefixes
			bodies += Symptom.bodies
			suffixes += Symptom.suffixes
	switch(rand(1, 3))
		if(1)
			return "[pick(prefixes)][pick(bodies)]"
		if(2)
			return "[pick(prefixes)][pick(bodies)][pick(suffixes)]"
		if(3)
			return "[pick(bodies)][pick(suffixes)]"

/datum/disease/advance/proc/logchanges(datum/reagents/holder, var/modification_type)
	if(holder?.my_atom?.fingerprintslast)
		last_modified_by = holder.my_atom.fingerprintslast
	else
		message_admins("[name], a disease, has been modified ([modification_type]) without logging a CKEY. Please report this to coders")
		log_virus("[name], a disease, has been modified ([modification_type]) without logging a CKEY. Please report this to coders")
		// if someone finds a way to avoid being logged while modifiying a virus, admins should be notified so coders can be notified.
		return FALSE
	log_virus("[modification_type]: [admin_details()]")
