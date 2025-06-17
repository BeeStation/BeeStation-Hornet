#define SCANMODE_HEALTH 0
//#define SCANMODE_WOUND 1
#define SCANNER_CONDENSED 0
#define SCANNER_VERBOSE 1

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner capable of distinguishing vital signs of the subject. Has a side button to scan for chemicals"
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)
	var/mode = SCANNER_VERBOSE
	var/scanmode = SCANMODE_HEALTH
	var/advanced = FALSE

/obj/item/healthanalyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)

	flick("[icon_state]-scan", src)	//makes it so that it plays the scan animation upon scanning, including clumsy scanning

	// Clumsiness/brain damage check
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		user.visible_message(
			span_warning("[user] analyzes the floor's vitals!"),
			span_notice("You stupidly try to analyze the floor's vitals!")
		)
		to_chat(user, span_info("Analyzing results for The floor:\n\tOverall status: <b>Healthy</b>"))
		to_chat(user, span_info("Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font>"))
		to_chat(user, span_info("\tDamage specifics: <font color='blue'>0</font>-<font color='green'>0</font>-<font color='#FF8000'>0</font>-<font color='red'>0</font>"))
		to_chat(user, span_info("Body temperature: ???"))
		return

	user.visible_message(
		span_notice("[user] analyzes [M]'s vitals."),
		span_notice("You analyze [M]'s vitals."),
	)

	balloon_alert(user, "analyzing vitals")
	playsound(src, 'sound/effects/fastbeep.ogg', 10)

	switch (scanmode)
		if (SCANMODE_HEALTH)
			healthscan(user, M, mode, advanced)
		//if (SCANMODE_WOUND)
		//	woundscan(user, M, src)

	add_fingerprint(user)

/obj/item/healthanalyzer/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	if (isliving(target))
		context.add_left_click_action("Scan Health")
		context.add_right_click_action("Scan Chemicals")

/obj/item/healthanalyzer/attack_secondary(mob/living/victim, mob/living/user, params)
	chemscan(user, victim)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN


// Used by the PDA medical scanner too
/proc/healthscan(mob/user, mob/living/M, mode = SCANNER_VERBOSE, advanced = FALSE, to_chat = TRUE)
	if(isliving(user) && user.incapacitated())
		return

	// the final list of strings to render
	var/message = list()

	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()
	var/mob_status = (M.stat == DEAD ? span_alert("<b>Deceased</b>") : "<b>[round(M.health/M.maxHealth,0.01)*100] % healthy</b>")

	if(HAS_TRAIT(M, TRAIT_FAKEDEATH) && !advanced)
		mob_status = span_alert("<b>Deceased</b>")
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.undergoing_cardiac_arrest() && H.stat != DEAD)
			message += span_alert("Subject suffering from heart attack: Apply defibrillation or other electric shock immediately!")

	message += span_info("Analyzing results for [M]:\n\tOverall status: [mob_status]")

	if(advanced && HAS_TRAIT_FROM(M, TRAIT_HUSK, BURN))
		message += "<span class='alert ml-1'>Subject has been husked by severe burns.</span>\n"
	else if(HAS_TRAIT(M, TRAIT_HUSK))
		message += "<span class='alert ml-1'>Subject has been husked.</span>\n"

	// Damage descriptions
	if(brute_loss > 10)
		message += "\t[span_alert("[brute_loss > 50 ? "Severe" : "Minor"] tissue damage detected.")]"
	if(fire_loss > 10)
		message += "\t[span_alert("[fire_loss > 50 ? "Severe" : "Minor"] burn damage detected.")]"
	if(oxy_loss > 10)
		message += "\t[span_info("<span class='alert'>[oxy_loss > 50 ? "Severe" : "Minor"] oxygen deprivation detected.")]"
	if(tox_loss > 10)
		message += "\t[span_alert("[tox_loss > 50 ? "Severe" : "Minor"] amount of toxin damage detected.")]"
	if(M.getStaminaLoss())
		message += "\t[span_alert("Subject appears to be suffering from fatigue.")]"
		if(advanced)
			message += "\t[span_info("Fatigue Level: [M.getStaminaLoss()]%.")]"
	if(M.getCloneLoss())
		message += "\t[span_alert("Subject appears to have [M.getCloneLoss() > 30 ? "Severe" : "Minor"] cellular damage.")]"
		if(advanced)
			message += "\t[span_info("Cellular Damage Level: [M.getCloneLoss()].")]"
	if(!M.get_organ_slot(ORGAN_SLOT_BRAIN))
		message += "\t[span_alert("Subject lacks a brain.")]"
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(LAZYLEN(C.get_traumas()))
			var/list/trauma_text = list()
			for(var/datum/brain_trauma/B in C.get_traumas())
				var/trauma_desc = ""
				switch(B.resilience)
					if(TRAUMA_RESILIENCE_SURGERY)
						trauma_desc += "severe "
					if(TRAUMA_RESILIENCE_LOBOTOMY)
						trauma_desc += "deep-rooted "
					if(TRAUMA_RESILIENCE_MAGIC, TRAUMA_RESILIENCE_ABSOLUTE)
						trauma_desc += "permanent "
				trauma_desc += B.scan_desc
				trauma_text += trauma_desc
			message += "\t[span_alert("Cerebral traumas detected: subject appears to be suffering from [english_list(trauma_text)].")]"
		if(length(C.last_mind?.quirks))
			message += "\t[span_info("Subject has the following physiological traits: [C.get_quirk_string()].")]"
	if(advanced)
		message += "\t[span_info("Brain Activity Level: [(200 - M.getOrganLoss(ORGAN_SLOT_BRAIN))/2]%.")]"

	if(advanced && M.hallucinating())
		message += "\t[span_info("Subject is hallucinating.")]"

	//Eyes and ears
	if(advanced)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/obj/item/organ/ears/ears = C.get_organ_slot(ORGAN_SLOT_EARS)
			message += "\t[span_info("<b>==EAR STATUS==</b>")]"
			if(istype(ears))
				var/healthy = TRUE
				if(HAS_TRAIT_FROM(C, TRAIT_DEAF, GENETIC_MUTATION))
					healthy = FALSE
					message += "\t[span_alert("Subject is genetically deaf.")]"
				else if(HAS_TRAIT(C, TRAIT_DEAF))
					healthy = FALSE
					message += "\t[span_alert("Subject is deaf.")]"
				else
					if(ears.damage)
						message += "\t[span_alert("Subject has [ears.damage > ears.maxHealth ? "permanent ": "temporary "]hearing damage.")]"
						healthy = FALSE
					if(ears.deaf)
						message += "\t[span_alert("Subject is [ears.damage > ears.maxHealth ? "permanently ": "temporarily "] deaf.")]"
						healthy = FALSE
				if(healthy)
					message += "\t[span_info("Healthy.")]"
			var/obj/item/organ/eyes/eyes = C.get_organ_slot(ORGAN_SLOT_EYES)
			message += "\t[span_info("<b>==EYE STATUS==</b>")]"
			if(istype(eyes))
				var/healthy = TRUE
				if(C.is_blind())
					message += "\t[span_alert("Subject is blind.")]"
					healthy = FALSE
				if(HAS_TRAIT(C, TRAIT_NEARSIGHT))
					message += "\t[span_alert("Subject is nearsighted.")]"
					healthy = FALSE
				if(eyes.damage > 30)
					message += "\t[span_alert("Subject has severe eye damage.")]"
					healthy = FALSE
				else if(eyes.damage > 20)
					message += "\t[span_alert("Subject has significant eye damage.")]"
					healthy = FALSE
				else if(eyes.damage)
					message += "\t[span_alert("Subject has minor eye damage.")]"
					healthy = FALSE
				if(healthy)
					message += "\t[span_info("Healthy.")]"

	// Body part damage report
	if(iscarbon(M) && mode == SCANNER_VERBOSE)
		var/mob/living/carbon/C = M
		var/list/damaged = C.get_damaged_bodyparts(1,1)
		if(length(damaged)>0 || oxy_loss>0 || tox_loss>0 || fire_loss>0)
			var/list/dmgreport = list()
			dmgreport += "<table style='margin-left:3em'><tr><font face='Verdana'>\
							<td style='width:7em;'><font color='#0000CC'>Damage:</font></td>\
							<td style='width:5em;'><font color='red'><b>Brute</b></font></td>\
							<td style='width:4em;'><font color='orange'><b>Burn</b></font></td>\
							<td style='width:4em;'><font color='green'><b>Toxin</b></font></td>\
							<td style='width:8em;'><font color='purple'><b>Suffocation</b></font></td></tr>\

							<tr><td><font color='#0000CC'>Overall:</font></td>\
							<td><font color='red'>[round(brute_loss,1)]</font></td>\
							<td><font color='orange'>[round(fire_loss,1)]</font></td>\
							<td><font color='green'>[round(tox_loss,1)]</font></td>\
							<td><font color='purple'>[round(oxy_loss,1)]</font></td></tr>"

			for(var/o in damaged)
				var/obj/item/bodypart/org = o //head, left arm, right arm, etc.
				dmgreport += "<tr><td><font color='#0000CC'>[capitalize(parse_zone(org.body_zone))]:</font></td>\
								<td><font color='red'>[(org.brute_dam > 0) ? "[round(org.brute_dam,1)]" : "0"]</font></td>\
								<td><font color='orange'>[(org.burn_dam > 0) ? "[round(org.burn_dam,1)]" : "0"]</font></td></tr>"
			dmgreport += "</font></table>"
			message += dmgreport.Join()


	//Organ damages report
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/minor_damage
		var/major_damage
		var/max_damage
		var/list/missing_organ_list = list()
		var/report_organs = FALSE

		//Piece together the lists to be reported
		for(var/O in H.internal_organs)
			var/obj/item/organ/organ = O
			if(organ.organ_flags & ORGAN_FAILING)
				report_organs = TRUE	//if we report one organ, we report all organs, even if the lists are empty, just for consistency
				if(max_damage)
					max_damage += ", "	//prelude the organ if we've already reported an organ
					max_damage += organ.name	//this just slaps the organ name into the string of text
				else
					max_damage = "\t<span class='alert'>Non-Functional Organs: "	//our initial statement
					max_damage += organ.name
			else if(organ.damage > organ.high_threshold)
				report_organs = TRUE
				if(major_damage)
					major_damage += ", "
					major_damage += organ.name
				else
					major_damage = "\t<span class='info'>Severely Damaged Organs: "
					major_damage += organ.name
			else if(organ.damage > organ.low_threshold)
				report_organs = TRUE
				if(minor_damage)
					minor_damage += ", "
					minor_damage += organ.name
				else
					minor_damage = "\t<span class='info'>Mildly Damaged Organs: "
					minor_damage += organ.name
		for(var/obj/item/organ/each_organ as anything in H.dna.species.required_organs) //Start checking against the carbon mob, seeing if there is any organs missing.
			if(isnull(H.get_organ_by_type(each_organ))) //Can we find the given organ in the mob?
				missing_organ_list += initial(each_organ.name) //If not, add it to the list.
				report_organs = TRUE
		if(report_organs)	//we either finish the list, or set it to be empty if no organs were reported in that category
			if(!max_damage)
				max_damage = "\t[span_alert("Non-Functional Organs: ")]"
			else
				max_damage += "</span>"
			if(!major_damage)
				major_damage = "\t[span_info("Severely Damaged Organs: ")]"
			else
				major_damage += "</span>"
			if(!minor_damage)
				minor_damage = "\t[span_info("Mildly Damaged Organs: ")]"
			else
				minor_damage += "</span>"
			message += minor_damage
			message += major_damage
			message += max_damage
			if(length(missing_organ_list)) //If we have missing organs, display them in a fancy list.
				message += "\t[span_alert("Missing Organs: [english_list(missing_organ_list)]")]"
		//Genetic damage
		if(advanced && H.has_dna())
			message += "\t[span_info("Genetic Stability: [H.dna.stability]%.")]"
			if(H.has_status_effect(/datum/status_effect/ling_transformation))
				message += "\t[span_info("Subject's DNA appears to be in an unstable state.")]"

		// Embedded Items
		for(var/obj/item/bodypart/limb as anything in H.bodyparts)
			for(var/obj/item/embed as anything in limb.embedded_objects)
				message += "\t[span_alert("Foreign object embedded in subject's [limb.name].")]"

	// Species and body temperature
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/species/S = H.dna.species
		var/mutant = H.dna.check_mutation(/datum/mutation/hulk) \
			|| S.mutantlungs != initial(S.mutantlungs) \
			|| S.mutantbrain != initial(S.mutantbrain) \
			|| S.mutantheart != initial(S.mutantheart) \
			|| S.mutanteyes != initial(S.mutanteyes) \
			|| S.mutantears != initial(S.mutantears) \
			|| S.mutanthands != initial(S.mutanthands) \
			|| S.mutanttongue != initial(S.mutanttongue) \
			|| S.mutantliver != initial(S.mutantliver) \
			|| S.mutantstomach != initial(S.mutantstomach) \
			|| S.mutantappendix != initial(S.mutantappendix) \
			|| S.mutantwings != initial(S.mutantwings)

		message += span_info("Species: [S.name][mutant ? "-derived mutant" : ""]")
		message += span_info("Core temperature: [round(H.coretemperature-T0C,0.1)] &deg;C ([round(H.coretemperature*1.8-459.67,0.1)] &deg;F)")
	message += span_info("Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)")

	// Time of death
	if(M.tod && (M.stat == DEAD || ((HAS_TRAIT(M, TRAIT_FAKEDEATH)) && !advanced)))
		message += span_info("Time of Death: [M.tod]")
		var/tdelta = round(world.time - M.timeofdeath)
		if(tdelta < (DEFIB_TIME_LIMIT * 10))
			message += span_alert("<b>Subject died [DisplayTimeText(tdelta)] ago, defibrillation may be possible!</b>")

	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			message += span_alert("<b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]")

	// Blood Level
	if(M.has_dna())
		var/mob/living/carbon/C = M
		var/blood_id = C.get_blood_id()
		if(blood_id)
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.is_bleeding())
					message += span_alert("<b>Subject is bleeding at a rate of [round(H.get_bleed_rate(), 0.1)]/s!</b>")
				else if (H.is_bandaged())
					message += span_alert("<b>Subject is bleeding (Bandaged)!</b>")
			var/blood_percent =  round((C.blood_volume / BLOOD_VOLUME_NORMAL)*100)
			var/blood_type = C.dna.blood_type
			if(blood_id != /datum/reagent/blood)//special blood substance
				var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
				if(R)
					blood_type = R.name
				else
					blood_type = blood_id
			var/blood_info = "[blood_type] (Compatible: [jointext(get_safe_blood(blood_type), ", ")])"
			if(C.blood_volume <= BLOOD_VOLUME_SAFE && C.blood_volume > BLOOD_VOLUME_OKAY)
				message += span_alert("Blood level: LOW [blood_percent] %, [C.blood_volume] cl,</span> <span class='info'>type: [blood_info]")
			else if(C.blood_volume <= BLOOD_VOLUME_OKAY)
				message += span_alert("Blood level: <b>CRITICAL [blood_percent] %</b>, [C.blood_volume] cl,</span> <span class='info'>type: [blood_info]")
			else
				message += span_info("Blood level: [blood_percent] %, [C.blood_volume] cl, type: [blood_info]")

		var/list/cyberimp_detect = list()
		for(var/obj/item/organ/cyberimp/CI in C.internal_organs)
			if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
				cyberimp_detect += CI.name
		if(length(cyberimp_detect))
			message += span_notice("Detected cybernetic modifications:")
			for(var/name in cyberimp_detect)
				message += span_notice("[name]")

	SEND_SIGNAL(M, COMSIG_LIVING_HEALTHSCAN, message, advanced, user, to_chat)

	if(to_chat)
		to_chat(user, examine_block(jointext(message, "\n")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
	else
		return(jointext(message, "\n"))

/proc/chemscan(mob/living/user, mob/living/M, to_chat = TRUE)
	if(user.incapacitated())
		return

	var/message = list()
	if(istype(M) && M.reagents)
		if(M.reagents.reagent_list.len)
			message += span_notice("Subject contains the following reagents:")
			for(var/datum/reagent/R in M.reagents.reagent_list)
				message += "[span_notice("[round(R.volume, 0.001)] units of [R.name]")] [R.overdosed == 1 ? " - [span_boldannounce("OVERDOSING")]" : ""]"
		else
			message += span_notice("Subject contains no reagents.")
		if(M.reagents.addiction_list.len)
			message += span_boldannounce("Subject is addicted to the following reagents:")
			for(var/datum/reagent/R in M.reagents.addiction_list)
				message += span_alert("[R.name]")
		else
			message += "<span class='notice'>Subject is not addicted to any types of drug.</span>"
	if(to_chat)
		to_chat(user, examine_block(jointext(message, "\n")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
	else
		return(jointext(message, "\n"))

/**
 * Scans an atom, showing any (detectable) diseases they may have.
 */
/proc/virusscan(mob/user, atom/target, var/maximum_stealth, var/maximum, var/list/extracted_ids)
	. = TRUE
	var/list/result = target?.extrapolator_act(user, target)
	var/list/diseases = result[EXTRAPOLATOR_RESULT_DISEASES]
	if(!length(diseases))
		return FALSE
	if(EXTRAPOLATOR_ACT_CHECK(result, EXTRAPOLATOR_ACT_PRIORITY_SPECIAL))
		return
	var/list/message = list()
	if(length(diseases))
		// costly_icon2html should be okay, as the extrapolator has a cooldown and is NOT spammable
		message += span_noticebold("[costly_icon2html(target, user)] [target] scan results]")
		for(var/datum/disease/disease in diseases)
			if(istype(disease, /datum/disease/advance))
				var/datum/disease/advance/advance_disease = disease
				if(advance_disease.stealth >= maximum_stealth) //the extrapolator can detect diseases of higher stealth than a normal scanner
					continue
				var/list/properties
				if(!advance_disease.mutable)
					LAZYADD(properties, "immutable")
				if(advance_disease.faltered)
					LAZYADD(properties, "faltered")
				if(advance_disease.carrier)
					LAZYADD(properties, "carrier")
				message += span_info("<b>[advance_disease.name]</b>[LAZYLEN(properties) ? " ([properties.Join(", ")])" : ""], [advance_disease.dormant ? "<i>dormant virus</i>" : "stage [advance_disease.stage]/5"]")
				if(extracted_ids[advance_disease.GetDiseaseID()])
					message += span_infoitalics("This virus has been extracted previously.")
				message += span_infobold("[advance_disease.name] has the following symptoms:")
				for(var/datum/symptom/symptom in advance_disease.symptoms)
					message += "[symptom.name]"
			else
				message += span_info("<b>[disease.name]</b>, stage [disease.stage]/[disease.max_stages].")
	to_chat(user, examine_block(jointext(message, "\n")), avoid_highlighting = TRUE, trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	if(usr.incapacitated())
		return

	mode = !mode
	to_chat(usr, mode == SCANNER_VERBOSE ? "The scanner now shows specific limb damage." : "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	advanced = TRUE

#undef SCANMODE_HEALTH
//#undef SCANMODE_WOUND
#undef SCANNER_CONDENSED
#undef SCANNER_VERBOSE
