// Describes the three modes of scanning available for health analyzers
#define SCANMODE_HEALTH 0
//#define SCANMODE_WOUND 1
#define SCANMODE_COUNT 1 // Update this to be the number of scan modes if you add more
#define SCANNER_CONDENSED 0
#define SCANNER_VERBOSE 1

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	inhand_icon_state = "healthanalyzer"
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
	custom_price = 100
	var/mode = SCANNER_VERBOSE
	var/scanmode = SCANMODE_HEALTH
	var/advanced = FALSE

/obj/item/healthanalyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/*
/obj/item/healthanalyzer/attack_self(mob/user)
	scanmode = (scanmode + 1) % SCANMODE_COUNT
	switch(scanmode)
		if(SCANMODE_HEALTH)
			to_chat(user, "<span class='notice'>You switch the health analyzer to check physical health.</span>")
		//if(SCANMODE_WOUND)
		//	to_chat(user, "<span class='notice'>You switch the health analyzer to report extra info on wounds.</span>")
*/

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)

	flick("[icon_state]-scan", src)	//makes it so that it plays the scan animation upon scanning, including clumsy scanning

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		user.visible_message(span_warning("[user] analyzes the floor's vitals!"), \
							span_notice("You stupidly try to analyze the floor's vitals!"))
		to_chat(user, "[span_info("Analyzing results for The floor:\n\tOverall status: <b>Healthy</b>")]\
				\n[span_info("Key: <font color='#00cccc'>Suffocation</font>/<font color='#00cc66'>Toxin</font>/<font color='#ffcc33'>Burn</font>/<font color='#ff3333'>Brute</font>")]\
				\n[span_info("\tDamage specifics: <font color='#66cccc'>0</font>-<font color='#00cc66'>0</font>-<font color='#ff9933'>0</font>-<font color='#ff3333'>0</font>")]\
				\n[span_info("Body temperature: ???")]")
		return

	user.visible_message(span_notice("[user] analyzes [M]'s vitals."))
	balloon_alert(user, "analyzing vitals")
	playsound(user.loc, 'sound/effects/fastbeep.ogg', 10)

	switch (scanmode)
		if (SCANMODE_HEALTH)
			healthscan(user, M, mode, advanced)
		//if (SCANMODE_WOUND)
		//	woundscan(user, M, src)

	add_fingerprint(user)

/obj/item/healthanalyzer/attack_secondary(mob/living/victim, mob/living/user, params)
	chemscan(user, victim)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/healthanalyzer/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	if (isliving(target))
		context.add_left_click_action("Scan Health")
		context.add_right_click_action("Scan Chemicals")

/**
 * healthscan
 * returns a list of everything a health scan should give to a player.
 * Examples of where this is used is Health Analyzer and the Physical Scanner tablet app.
 * Args:
 * user - The person with the scanner
 * target - The person being scanned
 * mode - Uses SCANNER_CONDENSED or SCANNER_VERBOSE to decide whether to give a list of all individual limb damage
 * advanced - Whether it will give more advanced details, such as husk source.
 * tochat - Whether to immediately post the result into the chat of the user, otherwise it will return the results.
 */
/proc/healthscan(mob/user, mob/living/target, mode = SCANNER_VERBOSE, advanced = FALSE, tochat = TRUE)
	if(user.incapacitated())
		return

	// the final list of strings to render
	var/render_list = list()

	// Damage specifics
	var/oxy_loss = target.getOxyLoss()
	var/tox_loss = target.getToxLoss()
	var/fire_loss = target.getFireLoss()
	var/brute_loss = target.getBruteLoss()
	var/mob_status = (target.stat == DEAD ? span_alert("<b>Deceased</b>") : "<b>[round(target.health/target.maxHealth,0.01)*100]% healthy</b>")

	if(HAS_TRAIT(target, TRAIT_FAKEDEATH) && !advanced)
		mob_status = span_alert("<b>Deceased</b>")
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	render_list += "[span_info("Analyzing results for [target]:")]\n<span class='info ml-1'>Overall status: [mob_status]</span>\n"

	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target
		if(humantarget.undergoing_cardiac_arrest() && humantarget.stat != DEAD)
			render_list += "<span class='alert ml-1'><b>Subject suffering from heart attack: Apply defibrillation or other electric shock immediately!</b></span>\n"

	SEND_SIGNAL(target, COMSIG_LIVING_HEALTHSCAN, render_list, advanced, user, mode, tochat)

	// Husk detection
	if(HAS_TRAIT(target, TRAIT_HUSK))
		if(advanced)
			if(HAS_TRAIT_FROM(target, TRAIT_HUSK, BURN))
				render_list += "<span class='alert ml-1'>Subject has been husked by severe burns.</span>\n"
			else if (HAS_TRAIT_FROM(target, TRAIT_HUSK, CHANGELING_DRAIN))
				render_list += "<span class='alert ml-1'>Subject has been husked by dessication.</span>\n"
			else
				render_list += "<span class='alert ml-1'>Subject has been husked by mysterious causes.</span>\n"

		else
			render_list += "<span class='alert ml-1'>Subject has been husked.</span>\n"

	if(target.getStaminaLoss())
		if(advanced)
			render_list += "<span class='alert ml-1'>Fatigue level: [target.getStaminaLoss()]%.</span>\n"
		else
			render_list += "<span class='alert ml-1'>Subject appears to be suffering from fatigue.</span>\n"
	if (target.getCloneLoss())
		if(advanced)
			render_list += "<span class='alert ml-1'>Cellular damage level: [target.getCloneLoss()].</span>\n"
		else
			render_list += "<span class='alert ml-1'>Subject appears to have [target.getCloneLoss() > 30 ? "severe" : "minor"] cellular damage.</span>\n"
	if (!target.get_organ_slot(ORGAN_SLOT_BRAIN)) // kept exclusively for soul purposes
		render_list += "<span class='alert ml-1'>Subject lacks a brain.</span>\n"

	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		if(LAZYLEN(carbontarget.get_traumas()))
			var/list/trauma_text = list()
			for(var/datum/brain_trauma/trauma in carbontarget.get_traumas())
				var/trauma_desc = ""
				switch(trauma.resilience)
					if(TRAUMA_RESILIENCE_SURGERY)
						trauma_desc += "severe "
					if(TRAUMA_RESILIENCE_LOBOTOMY)
						trauma_desc += "deep-rooted "
					if(TRAUMA_RESILIENCE_MAGIC, TRAUMA_RESILIENCE_ABSOLUTE)
						trauma_desc += "permanent "
				trauma_desc += trauma.scan_desc
				trauma_text += trauma_desc
			render_list += "<span class='alert ml-1'>Cerebral traumas detected: subject appears to be suffering from [english_list(trauma_text)].</span>\n"
		if(carbontarget.last_mind?.quirks.len)
			render_list += "<span class='info ml-1'>Subject Major Disabilities: [carbontarget.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY, from_scan = TRUE)].</span>\n"
			if(advanced)
				render_list += "<span class='info ml-1'>Subject Minor Disabilities: [carbontarget.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY, TRUE)].</span>\n"
	//Eyes and ears
	if(advanced && iscarbon(target))
		var/mob/living/carbon/carbontarget = target

		// Ear status
		var/obj/item/organ/ears/ears = carbontarget.get_organ_slot(ORGAN_SLOT_EARS)
		if(istype(ears))
			if(HAS_TRAIT_FROM(carbontarget, TRAIT_DEAF, GENETIC_MUTATION))
				render_list += "<span class='alert ml-2'>Subject is genetically deaf.\n</span>"
			//else if(HAS_TRAIT_FROM(carbontarget, TRAIT_DEAF, EAR_DAMAGE))
			//	render_list += "<span class='alert ml-2'>Subject is deaf from ear damage.\n</span>"
			else if(HAS_TRAIT(carbontarget, TRAIT_DEAF))
				render_list += "<span class='alert ml-2'>Subject is deaf.\n</span>"
			else
				if(ears.damage)
					render_list += "<span class='alert ml-2'>Subject has [ears.damage > ears.maxHealth ? "permanent ": "temporary "]hearing damage.\n</span>"
				if(ears.deaf)
					render_list += "<span class='alert ml-2'>Subject is [ears.damage > ears.maxHealth ? "permanently ": "temporarily "] deaf.\n</span>"

		// Eye status
		var/obj/item/organ/eyes/eyes = carbontarget.get_organ_slot(ORGAN_SLOT_EYES)
		if(istype(eyes))
			if(carbontarget.is_blind())
				render_list += "<span class='alert ml-2'>Subject is blind.\n</span>"
			else if(HAS_TRAIT(carbontarget, TRAIT_NEARSIGHT))
				render_list += "<span class='alert ml-2'>Subject is nearsighted.\n</span>"

	// Body part damage report
	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		var/list/damaged = carbontarget.get_damaged_bodyparts(1,1)
		if(length(damaged)>0 || oxy_loss>0 || tox_loss>0 || fire_loss>0)
			var/dmgreport = "<span class='info ml-1'>General status:</span>\
							<table class='ml-2'><tr><font face='Verdana'>\
							<td style='width:7em;'><font color='#ff0000'><b>Damage:</b></font></td>\
							<td style='width:5em;'><font color='#ff3333'><b>Brute</b></font></td>\
							<td style='width:4em;'><font color='#ff9933'><b>Burn</b></font></td>\
							<td style='width:4em;'><font color='#00cc66'><b>Toxin</b></font></td>\
							<td style='width:8em;'><font color='#00cccc'><b>Suffocation</b></font></td></tr>\
							<tr><td><font color='#ff3333'><b>Overall:</b></font></td>\
							<td><font color='#ff3333'><b>[CEILING(brute_loss,1)]</b></font></td>\
							<td><font color='#ff9933'><b>[CEILING(fire_loss,1)]</b></font></td>\
							<td><font color='#00cc66'><b>[CEILING(tox_loss,1)]</b></font></td>\
							<td><font color='#33ccff'><b>[CEILING(oxy_loss,1)]</b></font></td></tr>"

			if(mode == SCANNER_VERBOSE)
				for(var/obj/item/bodypart/limb as anything in damaged)
					if(limb.bodytype & BODYTYPE_ROBOTIC)
						dmgreport += "<tr><td><font color='#cc3333'>[capitalize(limb.name)]:</font></td>"
					else
						dmgreport += "<tr><td><font color='#cc3333'>[capitalize(limb.plaintext_zone)]:</font></td>"
					dmgreport += "<td><font color='#cc3333'>[(limb.brute_dam > 0) ? "[CEILING(limb.brute_dam,1)]" : "0"]</font></td>"
					dmgreport += "<td><font color='#ff9933'>[(limb.burn_dam > 0) ? "[CEILING(limb.burn_dam,1)]" : "0"]</font></td></tr>"
			dmgreport += "</font></table>"
			render_list += dmgreport // tables do not need extra linebreak
		for(var/obj/item/bodypart/limb as anything in carbontarget.bodyparts)
			for(var/obj/item/embed as anything in limb.embedded_objects)
				render_list += "<span class='alert ml-1'>Embedded object: [embed] located in \the [limb.plaintext_zone]</span>\n"

	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target

		// Organ damage, missing organs
		if(humantarget.internal_organs && humantarget.internal_organs.len)
			var/render = FALSE
			var/toReport = "<span class='info ml-1'>Organs:</span>\
				<table class='ml-2'><tr>\
				<td style='width:6em;'><font color='#ff0000'><b>Organ:</b></font></td>\
				[advanced ? "<td style='width:3em;'><font color='#ff0000'><b>Dmg</b></font></td>" : ""]\
				<td style='width:12em;'><font color='#ff0000'><b>Status</b></font></td>"

			for(var/obj/item/organ/organ as anything in humantarget.internal_organs)
				var/status = organ.get_status_text()
				if (status != "")
					render = TRUE
					toReport += "<tr><td><font color='#cc3333'>[organ.name]:</font></td>\
						[advanced ? "<td><font color='#ff3333'>[CEILING(organ.damage,1)]</font></td>" : ""]\
						<td>[status]</td></tr>"

			var/missing_organs = list()
			if(!humantarget.get_organ_slot(ORGAN_SLOT_BRAIN))
				missing_organs += "brain"
			if(!HAS_TRAIT_FROM(humantarget, TRAIT_NOBLOOD, SPECIES_TRAIT) && !humantarget.get_organ_slot(ORGAN_SLOT_HEART))
				missing_organs += "heart"
			if(!HAS_TRAIT_FROM(humantarget, TRAIT_NOBREATH, SPECIES_TRAIT) && !humantarget.get_organ_slot(ORGAN_SLOT_LUNGS))
				missing_organs += "lungs"
			if(/*!HAS_TRAIT_FROM(humantarget, TRAIT_LIVERLESS_METABOLISM, SPECIES_TRAIT) &&*/ !humantarget.get_organ_slot(ORGAN_SLOT_LIVER))
				missing_organs += "liver"
			if(!HAS_TRAIT_FROM(humantarget, TRAIT_NOHUNGER, SPECIES_TRAIT) && !humantarget.get_organ_slot(ORGAN_SLOT_STOMACH))
				missing_organs += "stomach"
			if(!humantarget.get_organ_slot(ORGAN_SLOT_TONGUE))
				missing_organs += "tongue"
			if(!humantarget.get_organ_slot(ORGAN_SLOT_EARS))
				missing_organs += "ears"
			if(!humantarget.get_organ_slot(ORGAN_SLOT_EYES))
				missing_organs += "eyes"

			if(length(missing_organs))
				render = TRUE
				for(var/organ in missing_organs)
					toReport += "<tr><td><font color='#cc3333'>[organ]:</font></td>\
						[advanced ? "<td><font color='#ff3333'>["-"]</font></td>" : ""]\
						<td><font color='#cc3333'>["Missing"]</font></td></tr>"

			if(render)
				render_list += toReport + "</table>" // tables do not need extra linebreak

		//Genetic stability
		if(advanced && humantarget.has_dna())
			render_list += "<span class='info ml-1'>Genetic Stability: [humantarget.dna.stability]%.</span>\n"
			if(humantarget.has_status_effect(/datum/status_effect/ling_transformation))
				render_list += "<span class='info ml-1'>Subject's DNA appears to be in an unstable state.</span>\n"

		// Species and body temperature
		var/datum/species/targetspecies = humantarget.dna.species
		var/mutant = humantarget.dna.check_mutation(/datum/mutation/hulk) \
			|| targetspecies.mutantlungs != initial(targetspecies.mutantlungs) \
			|| targetspecies.mutantbrain != initial(targetspecies.mutantbrain) \
			|| targetspecies.mutantheart != initial(targetspecies.mutantheart) \
			|| targetspecies.mutanteyes != initial(targetspecies.mutanteyes) \
			|| targetspecies.mutantears != initial(targetspecies.mutantears) \
			|| targetspecies.mutanthands != initial(targetspecies.mutanthands) \
			|| targetspecies.mutanttongue != initial(targetspecies.mutanttongue) \
			|| targetspecies.mutantliver != initial(targetspecies.mutantliver) \
			|| targetspecies.mutantstomach != initial(targetspecies.mutantstomach) \
			|| targetspecies.mutantappendix != initial(targetspecies.mutantappendix) \
			|| targetspecies.mutantwings != initial(targetspecies.mutantwings)

		render_list += "<span class='info ml-1'>Species: [targetspecies.name][mutant ? "-derived mutant" : ""]</span>\n"
		var/core_temperature_message = "Core temperature: [round(humantarget.coretemperature-T0C, 0.1)] &deg;C ([round(humantarget.coretemperature*1.8-459.67,0.1)] &deg;F)"
		if(humantarget.coretemperature >= humantarget.get_body_temp_heat_damage_limit())
			render_list += "<span class='alert ml-1'>☼ [core_temperature_message] ☼</span>\n"
		else if(humantarget.coretemperature <= humantarget.get_body_temp_cold_damage_limit())
			render_list += "<span class='alert ml-1'>❄ [core_temperature_message] ❄</span>\n"
		else
			render_list += "<span class='info ml-1'>[core_temperature_message]</span>\n"

	var/body_temperature_message = "Body temperature: [round(target.bodytemperature-T0C, 0.1)] &deg;C ([round(target.bodytemperature*1.8-459.67,0.1)] &deg;F)"
	if(target.bodytemperature >= target.get_body_temp_heat_damage_limit())
		render_list += "<span class='alert ml-1'>☼ [body_temperature_message] ☼</span>\n"
	else if(target.bodytemperature <= target.get_body_temp_cold_damage_limit())
		render_list += "<span class='alert ml-1'>❄ [body_temperature_message] ❄</span>\n"
	else
		render_list += "<span class='info ml-1'>[body_temperature_message]</span>\n"

	// Time of death
	if(target.tod && (target.stat == DEAD || ((HAS_TRAIT(target, TRAIT_FAKEDEATH)) && !advanced)))
		render_list += "<span class='info ml-1'>Time of Death: [target.tod]</span>\n"
		var/tdelta = round(world.time - target.timeofdeath)
		render_list += "<span class='alert ml-1'><b>Subject died [DisplayTimeText(tdelta)] ago.</b></span>\n"

	/*
	// Wounds
	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		var/list/wounded_parts = carbontarget.get_wounded_bodyparts()
		for(var/i in wounded_parts)
			var/obj/item/bodypart/wounded_part = i
			render_list += "<span class='alert ml-1'><b>Physical trauma[LAZYLEN(wounded_part.wounds) > 1 ? "s" : ""] detected in [wounded_part.name]</b>"
			for(var/k in wounded_part.wounds)
				var/datum/wound/W = k
				render_list += "<div class='ml-2'>[W.name] ([W.severity_text()])\nRecommended treatment: [W.treat_text]</div>" // less lines than in woundscan() so we don't overload people trying to get basic med info
			render_list += "</span>"
	*/

	//Diseases
	for(var/datum/disease/disease as anything in target.diseases)
		if(!(disease.visibility_flags & HIDDEN_SCANNER))
			render_list += "<span class='alert ml-1'><b>Warning: [disease.form] detected</b>\n\
			<div class='ml-2'>Name: [disease.name].\nType: [disease.spread_text].\nStage: [disease.stage]/[disease.max_stages].\nPossible Cure: [disease.cure_text]</div>\
			</span>" // divs do not need extra linebreak

	// Blood Level
	if(target.has_dna())
		var/mob/living/carbon/carbontarget = target
		var/blood_id = carbontarget.get_blood_id()
		if(blood_id)
			if(carbontarget.is_bleeding())
				render_list += "<span class='alert ml-1'><b>Subject is bleeding at a rate of [round(carbontarget.get_bleed_rate(), 0.1)]/s!</b></span>\n"
			else if (carbontarget.is_bandaged())
				render_list += "<span class='alert ml-1'><b>Subject is bleeding (Bandaged)!</b></span>\n"
			var/blood_percent = round((carbontarget.blood_volume / BLOOD_VOLUME_NORMAL) * 100)
			var/blood_type = carbontarget.dna.blood_type.name
			if(blood_id != /datum/reagent/blood) // special blood substance
				var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
				blood_type = R ? R.name : blood_id

			// Get compatible blood type names
			var/list/compatible_names = list()
			for(var/compatible_type in carbontarget.dna.blood_type.compatible_types)
				var/datum/blood_type/compatible_datum = new compatible_type()
				compatible_names += compatible_datum.name
				qdel(compatible_datum)
			var/blood_info = "[blood_type] (Compatible: [jointext(compatible_names, ", ")])"

			if(HAS_TRAIT(carbontarget, TRAIT_MASQUERADE))
				render_list += "<span class='alert ml-1'>Blood level: 100 %, 560 cl,</span> [span_info("type: [blood_info]")]\n"
			else if(carbontarget.blood_volume <= BLOOD_VOLUME_SAFE && carbontarget.blood_volume > BLOOD_VOLUME_OKAY)
				render_list += "<span class='alert ml-1'>Blood level: LOW [blood_percent] %, [carbontarget.blood_volume] cl,</span> [span_info("type: [blood_info]")]\n"
			else if(carbontarget.blood_volume <= BLOOD_VOLUME_OKAY)
				render_list += "<span class='alert ml-1'>Blood level: <b>CRITICAL [blood_percent] %</b>, [carbontarget.blood_volume] cl,</span> [span_info("type: [blood_info]")]\n"
			else
				render_list += "<span class='info ml-1'>Blood level: [blood_percent] %, [carbontarget.blood_volume] cl, type: [blood_type]</span>\n"

	// Cybernetics
	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		var/cyberimp_detect
		for(var/obj/item/organ/cyberimp/cyberimp in carbontarget.internal_organs)
			if(cyberimp.status == ORGAN_ROBOTIC && !cyberimp.syndicate_implant)
				cyberimp_detect += "[!cyberimp_detect ? "[cyberimp.examine_title(user)]" : ", [cyberimp.examine_title(user)]"]"
		if(cyberimp_detect)
			render_list += "<span class='notice ml-1'>Detected cybernetic modifications:</span>\n"
			render_list += "<span class='notice ml-2'>[cyberimp_detect]</span>\n"
	// we handled the last <br> so we don't need handholding

	SEND_SIGNAL(target, COMSIG_NANITE_SCAN, user, FALSE)
	if(tochat)
		to_chat(user, examine_block(jointext(render_list, "")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
	else
		return(jointext(render_list, ""))

/proc/chemscan(mob/living/user, mob/living/target)
	if(user.incapacitated())
		return

	if(istype(target) && target.reagents)
		var/list/render_list = list() //The master list of readouts, including reagents in the blood/stomach, addictions, quirks, etc.
		var/list/render_block = list() //A second block of readout strings. If this ends up empty after checking stomach/blood contents, we give the "empty" header.

		// Blood reagents
		if(target.reagents.reagent_list.len)
			for(var/r in target.reagents.reagent_list)
				var/datum/reagent/reagent = r
				//if(reagent.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems on scanners
				//	continue
				render_block += "<span class='notice ml-2'>[round(reagent.volume, 0.001)] units of [reagent.name][reagent.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"

		if(!length(render_block)) //If no VISIBLY DISPLAYED reagents are present, we report as if there is nothing.
			render_list += "<span class='notice ml-1'>Subject contains no reagents in their blood.</span>\n"
		else
			render_list += "<span class='notice ml-1'>Subject contains the following reagents in their blood:</span>\n"
			render_list += render_block //Otherwise, we add the header, reagent readouts, and clear the readout block for use on the stomach.
			render_block.Cut()

		// Stomach reagents
		/*
		var/obj/item/organ/stomach/belly = target.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(belly)
			if(belly.reagents.reagent_list.len)
				for(var/bile in belly.reagents.reagent_list)
					var/datum/reagent/bit = bile
					if(bit.chemical_flags & REAGENT_INVISIBLE)
						continue
					if(!belly.food_reagents[bit.type])
						render_block += "<span class='notice ml-2'>[round(bit.volume, 0.001)] units of [bit.name][bit.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"
					else
						var/bit_vol = bit.volume - belly.food_reagents[bit.type]
						if(bit_vol > 0)
							render_block += "<span class='notice ml-2'>[round(bit_vol, 0.001)] units of [bit.name][bit.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"

			if(!length(render_block))
				render_list += "<span class='notice ml-1'>Subject contains no reagents in their stomach.</span>\n"
			else
				render_list += "<span class='notice ml-1'>Subject contains the following reagents in their stomach:</span>\n"
				render_list += render_block
		*/

		// Addictions
		if(LAZYLEN(target.mind?.active_addictions))
			render_list += "<span class='boldannounce ml-1'>Subject is addicted to the following types of drug:</span><br>"
			for(var/datum/addiction/addiction_type as anything in target.mind.active_addictions)
				render_list += "<span class='alert ml-2'>[initial(addiction_type.name)]</span><br>"

		// we handled the last <br> so we don't need handholding
		to_chat(user, examine_block(jointext(render_list, "")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/**
 * Scans an atom, showing any (detectable) diseases they may have.
 */
/proc/virusscan(mob/user, atom/target, maximum_stealth, maximum, list/extracted_ids)
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

/proc/genescan(mob/living/carbon/C, mob/user, list/discovered)
	. = TRUE
	if(!iscarbon(C) || !C.has_dna())
		return FALSE
	if(HAS_TRAIT(C, TRAIT_RADIMMUNE) || HAS_TRAIT(C, TRAIT_BADDNA))
		return FALSE
	var/list/message = list()
	var/list/active_inherent_muts = list()
	var/list/active_injected_muts = list()
	var/list/inherent_muts = list()
	var/list/mut_index = C.dna.mutation_index.Copy()

	for(var/datum/mutation/each in C.dna.mutations)
		//get name and alias if discovered (or no discovered list was provided) or just alias if not
		var/datum/mutation/each_mutation = GET_INITIALIZED_MUTATION(each.type) //have to do this as instances of mutation do not have alias but global ones do....
		var/each_mut_details = "ERROR"
		if(!discovered || (each_mutation.type in discovered))
			each_mut_details = span_info("[each_mutation.name] ([each_mutation.alias])")
		else
			each_mut_details = span_info("[each_mutation.alias]")

		if(each_mutation.type in mut_index)
			//add mutation readout for all active inherent mutations
			active_inherent_muts += "[each_mut_details][span_infobold(" : Active ")]"
			mut_index -= each_mutation.type
		else
			//add mutation readout for all injected (not inherent) mutations
			active_injected_muts += each_mut_details

	for(var/each in mut_index)
		var/datum/mutation/each_mutation = GET_INITIALIZED_MUTATION(each)
		var/each_mut_details = "ERROR"
		if(each_mutation)
			//repeating this code twice is nasty, but nested procs (if even possible??) or more global procs then needed is... less so
			if(!discovered || (each_mutation.type in discovered))
				each_mut_details = span_info("[each_mutation.name] ([each_mutation.alias])")
			else
				each_mut_details = span_info("[each_mutation.alias]")
		inherent_muts += each_mut_details

	message += span_noticebold("[C] scan results")
	active_inherent_muts.len > 0 ? (message += "[jointext(active_inherent_muts, "\n")]") : ""
	inherent_muts.len > 0 ? (message += "[jointext(inherent_muts, "\n")]") : ""
	active_injected_muts.len > 0 ? (message += "[span_infobold("Injected mutations:\n")][jointext(active_injected_muts, "\n")]") : ""

	to_chat(user, examine_block(jointext(message, "\n")), avoid_highlighting = TRUE, trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/obj/item/healthanalyzer/AltClick(mob/user)
	..()

	if(!user.canUseTopic(src, be_close = TRUE) || !user.can_read(src))
		return

	mode = !mode
	to_chat(user, mode == SCANNER_VERBOSE ? "The scanner now shows specific limb damage." : "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	advanced = TRUE

#undef SCANMODE_HEALTH
//#undef SCANMODE_WOUND
#undef SCANMODE_COUNT
#undef SCANNER_CONDENSED
#undef SCANNER_VERBOSE
