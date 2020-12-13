
/*

CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
SLIME SCANNER
NANITE SCANNER
GENE SCANNER

*/
/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	custom_price = 10
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = FALSE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	materials = list(/datum/material/iron=150)

/obj/item/t_scanner/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to emit terahertz-rays into [user.p_their()] brain with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS

/obj/item/t_scanner/proc/toggle_on()
	on = !on
	icon_state = copytext_char(icon_state, 1, -1) + "[on]"
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/t_scanner/attack_self(mob/user)
	toggle_on()

/obj/item/t_scanner/cyborg_unequip(mob/user)
	if(!on)
		return
	toggle_on()

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/proc/t_ray_scan(mob/viewer, flick_time = 8, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(distance, viewer) )
		if(O.level != 1)
			continue

		if(O.invisibility == INVISIBILITY_MAXIMUM || HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I
	if(t_ray_images.len)
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=200)
	var/mode = 1
	var/scanmode = 0
	var/advanced = FALSE

/obj/item/healthanalyzer/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!</span>")
	return BRUTELOSS

/obj/item/healthanalyzer/attack_self(mob/user)
	if(!scanmode)
		to_chat(user, "<span class='notice'>You switch the health analyzer to scan chemical contents.</span>")
		scanmode = 1
	else
		to_chat(user, "<span class='notice'>You switch the health analyzer to check physical health.</span>")
		scanmode = 0

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
	flick("[icon_state]-scan", src)	//makes it so that it plays the scan animation upon scanning, including clumsy scanning

	// Clumsiness/brain damage check

	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		user.visible_message("<span class='warning'>[user] analyzes the floor's vitals!</span>", \
							"<span class='notice'>You stupidly try to analyze the floor's vitals!</span>")
		to_chat(user, "<span class='info'>Analyzing results for The floor:\n\tOverall status: <b>Healthy</b></span>")
		to_chat(user, "<span class='info'>Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FF8000'>Burn</font>/<font color='red'>Brute</font></span>")
		to_chat(user, "<span class='info'>\tDamage specifics: <font color='blue'>0</font>-<font color='green'>0</font>-<font color='#FF8000'>0</font>-<font color='red'>0</font></span>")
		to_chat(user, "<span class='info'>Body temperature: ???</span>")
		return

	user.visible_message("<span class='notice'>[user] analyzes [M]'s vitals.</span>", \
						"<span class='notice'>You analyze [M]'s vitals.</span>")

	if(scanmode == 0)
		healthscan(user, M, mode, advanced)
	else if(scanmode == 1)
		chemscan(user, M)

	add_fingerprint(user)


// Used by the PDA medical scanner too
/proc/healthscan(mob/user, mob/living/M, mode = 1, advanced = FALSE)
	if(isliving(user) && (user.incapacitated() || user.eye_blind))
		return
	//Damage specifics
	var/oxy_loss = M.getOxyLoss()
	var/tox_loss = M.getToxLoss()
	var/fire_loss = M.getFireLoss()
	var/brute_loss = M.getBruteLoss()
	var/mob_status = (M.stat == DEAD ? "<span class='alert'><b>Deceased</b></span>" : "<b>[round(M.health/M.maxHealth,0.01)*100] % healthy</b>")

	if(HAS_TRAIT(M, TRAIT_FAKEDEATH) && !advanced)
		mob_status = "<span class='alert'><b>Deceased</b></span>"
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.undergoing_cardiac_arrest() && H.stat != DEAD)
			to_chat(user, "<span class='alert'>Subject suffering from heart attack: Apply defibrillation or other electric shock immediately!</span>")

	to_chat(user, "<span class='info'>Analyzing results for [M]:\n\tOverall status: [mob_status]</span>")

	// Damage descriptions
	if(brute_loss > 10)
		to_chat(user, "\t<span class='alert'>[brute_loss > 50 ? "Severe" : "Minor"] tissue damage detected.</span>")
	if(fire_loss > 10)
		to_chat(user, "\t<span class='alert'>[fire_loss > 50 ? "Severe" : "Minor"] burn damage detected.</span>")
	if(oxy_loss > 10)
		to_chat(user, "\t<span class='info'><span class='alert'>[oxy_loss > 50 ? "Severe" : "Minor"] oxygen deprivation detected.</span>")
	if(tox_loss > 10)
		to_chat(user, "\t<span class='alert'>[tox_loss > 50 ? "Severe" : "Minor"] amount of toxin damage detected.</span>")
	if(M.getStaminaLoss())
		to_chat(user, "\t<span class='alert'>Subject appears to be suffering from fatigue.</span>")
		if(advanced)
			to_chat(user, "\t<span class='info'>Fatigue Level: [M.getStaminaLoss()]%.</span>")
	if (M.getCloneLoss())
		to_chat(user, "\t<span class='alert'>Subject appears to have [M.getCloneLoss() > 30 ? "Severe" : "Minor"] cellular damage.</span>")
		if(advanced)
			to_chat(user, "\t<span class='info'>Cellular Damage Level: [M.getCloneLoss()].</span>")
	if (!M.getorgan(/obj/item/organ/brain))
		to_chat(user, "\t<span class='alert'>Subject lacks a brain.</span>")
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
			to_chat(user, "\t<span class='alert'>Cerebral traumas detected: subject appears to be suffering from [english_list(trauma_text)].</span>")
		if(C.roundstart_quirks.len)
			to_chat(user, "\t<span class='info'>Subject has the following physiological traits: [C.get_trait_string()].</span>")
	if(advanced)
		to_chat(user, "\t<span class='info'>Brain Activity Level: [(200 - M.getOrganLoss(ORGAN_SLOT_BRAIN))/2]%.</span>")

	if (M.radiation)
		to_chat(user, "\t<span class='alert'>Subject is irradiated.</span>")
		if(advanced)
			to_chat(user, "\t<span class='info'>Radiation Level: [M.radiation]%.</span>")

	if(advanced && M.hallucinating())
		to_chat(user, "\t<span class='info'>Subject is hallucinating.</span>")

	//Eyes and ears
	if(advanced)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
			to_chat(user, "\t<span class='info'><b>==EAR STATUS==</b></span>")
			if(istype(ears))
				var/healthy = TRUE
				if(HAS_TRAIT_FROM(C, TRAIT_DEAF, GENETIC_MUTATION))
					healthy = FALSE
					to_chat(user, "\t<span class='alert'>Subject is genetically deaf.</span>")
				else if(HAS_TRAIT(C, TRAIT_DEAF))
					healthy = FALSE
					to_chat(user, "\t<span class='alert'>Subject is deaf.</span>")
				else
					if(ears.damage)
						to_chat(user, "\t<span class='alert'>Subject has [ears.damage > ears.maxHealth ? "permanent ": "temporary "]hearing damage.</span>")
						healthy = FALSE
					if(ears.deaf)
						to_chat(user, "\t<span class='alert'>Subject is [ears.damage > ears.maxHealth ? "permanently ": "temporarily "] deaf.</span>")
						healthy = FALSE
				if(healthy)
					to_chat(user, "\t<span class='info'>Healthy.</span>")
			else
				to_chat(user, "\t<span class='alert'>Subject does not have ears.</span>")
			var/obj/item/organ/eyes/eyes = C.getorganslot(ORGAN_SLOT_EYES)
			to_chat(user, "\t<span class='info'><b>==EYE STATUS==</b></span>")
			if(istype(eyes))
				var/healthy = TRUE
				if(HAS_TRAIT(C, TRAIT_BLIND))
					to_chat(user, "\t<span class='alert'>Subject is blind.</span>")
					healthy = FALSE
				if(HAS_TRAIT(C, TRAIT_NEARSIGHT))
					to_chat(user, "\t<span class='alert'>Subject is nearsighted.</span>")
					healthy = FALSE
				if(eyes.damage > 30)
					to_chat(user, "\t<span class='alert'>Subject has severe eye damage.</span>")
					healthy = FALSE
				else if(eyes.damage > 20)
					to_chat(user, "\t<span class='alert'>Subject has significant eye damage.</span>")
					healthy = FALSE
				else if(eyes.damage)
					to_chat(user, "\t<span class='alert'>Subject has minor eye damage.</span>")
					healthy = FALSE
				if(healthy)
					to_chat(user, "\t<span class='info'>Healthy.</span>")
			else
				to_chat(user, "\t<span class='alert'>Subject does not have eyes.</span>")


	// Body part damage report
	if(iscarbon(M) && mode == 1)
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
				dmgreport += "<tr><td><font color='#0000CC'>[capitalize(org.name)]:</font></td>\
								<td><font color='red'>[(org.brute_dam > 0) ? "[round(org.brute_dam,1)]" : "0"]</font></td>\
								<td><font color='orange'>[(org.burn_dam > 0) ? "[round(org.burn_dam,1)]" : "0"]</font></td></tr>"
			dmgreport += "</font></table>"
			to_chat(user, dmgreport.Join())


	//Organ damages report
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/minor_damage
		var/major_damage
		var/max_damage
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

		if(report_organs)	//we either finish the list, or set it to be empty if no organs were reported in that category
			if(!max_damage)
				max_damage = "\t<span class='alert'>Non-Functional Organs: </span>"
			else
				max_damage += "</span>"
			if(!major_damage)
				major_damage = "\t<span class='info'>Severely Damaged Organs: </span>"
			else
				major_damage += "</span>"
			if(!minor_damage)
				minor_damage = "\t<span class='info'>Mildly Damaged Organs: </span>"
			else
				minor_damage += "</span>"
			to_chat(user, minor_damage)
			to_chat(user, major_damage)
			to_chat(user, max_damage)
		//Genetic damage
		if(advanced && H.has_dna())
			to_chat(user, "\t<span class='info'>Genetic Stability: [H.dna.stability]%.</span>")

	// Species and body temperature
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/species/S = H.dna.species
		var/mutant = FALSE
		if (H.dna.check_mutation(HULK))
			mutant = TRUE
		else if (S.mutantlungs != initial(S.mutantlungs))
			mutant = TRUE
		else if (S.mutant_brain != initial(S.mutant_brain))
			mutant = TRUE
		else if (S.mutant_heart != initial(S.mutant_heart))
			mutant = TRUE
		else if (S.mutanteyes != initial(S.mutanteyes))
			mutant = TRUE
		else if (S.mutantears != initial(S.mutantears))
			mutant = TRUE
		else if (S.mutanthands != initial(S.mutanthands))
			mutant = TRUE
		else if (S.mutanttongue != initial(S.mutanttongue))
			mutant = TRUE
		else if (S.mutanttail != initial(S.mutanttail))
			mutant = TRUE
		else if (S.mutantliver != initial(S.mutantliver))
			mutant = TRUE
		else if (S.mutantstomach != initial(S.mutantstomach))
			mutant = TRUE

		to_chat(user, "<span class='info'>Species: [S.name][mutant ? "-derived mutant" : ""]</span>")
	to_chat(user, "<span class='info'>Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)</span>")

	// Time of death
	if(M.tod && (M.stat == DEAD || ((HAS_TRAIT(M, TRAIT_FAKEDEATH)) && !advanced)))
		to_chat(user, "<span class='info'>Time of Death: [M.tod]</span>")
		var/tdelta = round(world.time - M.timeofdeath)
		if(tdelta < (DEFIB_TIME_LIMIT * 10))
			to_chat(user, "<span class='alert'><b>Subject died [DisplayTimeText(tdelta)] ago, defibrillation may be possible!</b></span>")

	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			to_chat(user, "<span class='alert'><b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</span>")

	// Blood Level
	if(M.has_dna())
		var/mob/living/carbon/C = M
		var/blood_id = C.get_blood_id()
		if(blood_id)
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.bleed_rate)
					to_chat(user, "<span class='alert'><b>Subject is bleeding!</b></span>")
			var/blood_percent =  round((C.blood_volume / BLOOD_VOLUME_NORMAL)*100)
			var/blood_type = C.dna.blood_type
			if(blood_id != /datum/reagent/blood)//special blood substance
				var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
				if(R)
					blood_type = R.name
				else
					blood_type = blood_id
			if(C.blood_volume <= BLOOD_VOLUME_SAFE && C.blood_volume > BLOOD_VOLUME_OKAY)
				to_chat(user, "<span class='alert'>Blood level: LOW [blood_percent] %, [C.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>")
			else if(C.blood_volume <= BLOOD_VOLUME_OKAY)
				to_chat(user, "<span class='alert'>Blood level: <b>CRITICAL [blood_percent] %</b>, [C.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>")
			else
				to_chat(user, "<span class='info'>Blood level: [blood_percent] %, [C.blood_volume] cl, type: [blood_type]</span>")

		var/cyberimp_detect
		for(var/obj/item/organ/cyberimp/CI in C.internal_organs)
			if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
				cyberimp_detect += "[C.name] is modified with a [CI.name].<br>"
		if(cyberimp_detect)
			to_chat(user, "<span class='notice'>Detected cybernetic modifications:</span>")
			to_chat(user, "<span class='notice'>[cyberimp_detect]</span>")
	SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, FALSE)

/proc/chemscan(mob/living/user, mob/living/M)
	if(istype(M))
		if(M.reagents)
			if(M.reagents.reagent_list.len)
				to_chat(user, "<span class='notice'>Subject contains the following reagents:</span>")
				for(var/datum/reagent/R in M.reagents.reagent_list)
					to_chat(user, "<span class='notice'>[round(R.volume, 0.001)] units of [R.name][R.overdosed == 1 ? "</span> - <span class='boldannounce'>OVERDOSING</span>" : ".</span>"]")
			else
				to_chat(user, "<span class='notice'>Subject contains no reagents.</span>")
			if(M.reagents.addiction_list.len)
				to_chat(user, "<span class='boldannounce'>Subject is addicted to the following reagents:</span>")
				for(var/datum/reagent/R in M.reagents.addiction_list)
					to_chat(user, "<span class='alert'>[R.name]</span>")
			else
				to_chat(user, "<span class='notice'>Subject is not addicted to any reagents.</span>")

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	if(usr.incapacitated())
		return

	mode = !mode
	switch (mode)
		if(1)
			to_chat(usr, "The scanner now shows specific limb damage.")
		if(0)
			to_chat(usr, "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	advanced = TRUE

/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels. Alt-Click to use the built in barometer function."
	name = "analyzer"
	custom_price = 10
	icon = 'icons/obj/device.dmi'
	icon_state = "analyzer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	tool_behaviour = TOOL_ANALYZER
	materials = list(/datum/material/iron=30, /datum/material/glass=20)
	grind_results = list(/datum/reagent/mercury = 5, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click [src] to activate the barometer function.</span>"

/obj/item/analyzer/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!</span>")
	return BRUTELOSS

/obj/item/analyzer/attackby(obj/O, mob/living/user)
	if(istype(O, /obj/item/bodypart/l_arm/robot) || istype(O, /obj/item/bodypart/r_arm/robot))
		to_chat(user, "<span class='notice'>You add [O] to [src].</span>")
		qdel(O)
		qdel(src)
		user.put_in_hands(new /obj/item/bot_assembly/atmosbot)
	else
		..()

/obj/item/analyzer/attack_self(mob/user)
	add_fingerprint(user)

	if (user.stat || user.eye_blind)
		return

	var/turf/location = user.loc
	if(!istype(location))
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	to_chat(user, "<span class='info'><B>Results:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(user, "<span class='info'>Pressure: [round(pressure, 0.01)] kPa</span>")
	else
		to_chat(user, "<span class='alert'>Pressure: [round(pressure, 0.01)] kPa</span>")
	if(total_moles)
		var/o2_concentration = environment.get_moles(/datum/gas/oxygen)/total_moles
		var/n2_concentration = environment.get_moles(/datum/gas/nitrogen)/total_moles
		var/co2_concentration = environment.get_moles(/datum/gas/carbon_dioxide)/total_moles
		var/plasma_concentration = environment.get_moles(/datum/gas/plasma)/total_moles

		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(user, "<span class='info'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/nitrogen), 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='alert'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/nitrogen), 0.01)] mol)</span>")

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(user, "<span class='info'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/oxygen), 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='alert'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/oxygen), 0.01)] mol)</span>")

		if(co2_concentration > 0.01)
			to_chat(user, "<span class='alert'>CO2: [round(co2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/carbon_dioxide), 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='info'>CO2: [round(co2_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/carbon_dioxide), 0.01)] mol)</span>")

		if(plasma_concentration > 0.005)
			to_chat(user, "<span class='alert'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/plasma), 0.01)] mol)</span>")
		else
			to_chat(user, "<span class='info'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(environment.get_moles(/datum/gas/plasma), 0.01)] mol)</span>")

		for(var/id in environment.get_gases())
			if(id in GLOB.hardcoded_gases)
				continue
			var/gas_concentration = environment.get_moles(id)/total_moles
			to_chat(user, "<span class='alert'>[GLOB.meta_gas_info[id][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] % ([round(environment.get_moles(id), 0.01)] mol)</span>")
		to_chat(user, "<span class='info'>Temperature: [round(environment.return_temperature()-T0C, 0.01)] &deg;C ([round(environment.return_temperature(), 0.01)] K)</span>")

/obj/item/analyzer/AltClick(mob/user) //Barometer output for measuring when the next storm happens

	if(user.canUseTopic(src, BE_CLOSE))

		if(cooldown)
			to_chat(user, "<span class='warning'>[src]'s barometer function is preparing itself.</span>")
			return

		var/turf/T = get_turf(user)
		if(!T)
			return

		playsound(src, 'sound/effects/pop.ogg', 100)
		var/area/user_area = T.loc
		var/datum/weather/ongoing_weather = null

		if(!user_area.outdoors)
			to_chat(user, "<span class='warning'>[src]'s barometer function won't work indoors!</span>")
			return

		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
				ongoing_weather = W
				break

		if(ongoing_weather)
			if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
				to_chat(user, "<span class='warning'>[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]</span>")
				return

			to_chat(user, "<span class='notice'>The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)].</span>")
			if(ongoing_weather.aesthetic)
				to_chat(user, "<span class='warning'>[src]'s barometer function says that the next storm will breeze on by.</span>")
		else
			var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
			var/fixed = next_hit ? next_hit - world.time : -1
			if(fixed < 0)
				to_chat(user, "<span class='warning'>[src]'s barometer function was unable to trace any weather patterns.</span>")
			else
				to_chat(user, "<span class='warning'>[src]'s barometer function says a storm will land in approximately [butchertime(fixed)].</span>")
		cooldown = TRUE
		addtimer(CALLBACK(src,/obj/item/analyzer/proc/ping), cooldown_time)

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='notice'>[src]'s barometer function is ready!</span>")
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/inaccurate = round(accuracy*(1/3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1,amount))

/proc/atmosanalyzer_scan(mob/user, atom/target, silent=FALSE)
	var/mixture = target.return_analyzable_air()
	if(!mixture)
		return FALSE

	var/icon = target
	if(!silent && isliving(user))
		user.visible_message("[user] has used the analyzer on [icon2html(icon, viewers(user))] [target].", "<span class='notice'>You use the analyzer on [icon2html(icon, user)] [target].</span>")
	to_chat(user, "<span class='boldnotice'>Results of analysis of [icon2html(icon, user)] [target].</span>")

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/g in airs)
		if(airs.len > 1) //not a unary gas mixture
			to_chat(user, "<span class='boldnotice'>Node [airs.Find(g)]</span>")
		var/datum/gas_mixture/air_contents = g

		var/total_moles = air_contents.total_moles()
		var/pressure = air_contents.return_pressure()
		var/volume = air_contents.return_volume() //could just do mixture.volume... but safety, I guess?
		var/temperature = air_contents.return_temperature()
		var/cached_scan_results = air_contents.analyzer_results

		if(total_moles > 0)
			to_chat(user, "<span class='notice'>Moles: [round(total_moles, 0.01)] mol</span>")
			to_chat(user, "<span class='notice'>Volume: [volume] L</span>")
			to_chat(user, "<span class='notice'>Pressure: [round(pressure,0.01)] kPa</span>")

			for(var/id in air_contents.get_gases())
				var/gas_concentration = air_contents.get_moles(id)/total_moles
				to_chat(user, "<span class='notice'>[GLOB.meta_gas_info[id][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] % ([round(air_contents.get_moles(id), 0.01)] mol)</span>")
			to_chat(user, "<span class='notice'>Temperature: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)</span>")

		else
			if(airs.len > 1)
				to_chat(user, "<span class='notice'>This node is empty!</span>")
			else
				to_chat(user, "<span class='notice'>[target] is empty!</span>")

		if(cached_scan_results && cached_scan_results["fusion"]) //notify the user if a fusion reaction was detected
			var/instability = round(cached_scan_results["fusion"], 0.01)
			to_chat(user, "<span class='boldnotice'>Large amounts of free neutrons detected in the air indicate that a fusion reaction took place.</span>")
			to_chat(user, "<span class='notice'>Instability of the last fusion reaction: [instability].</span>")
	return TRUE

//slime scanner

/obj/item/slime_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=30, /datum/material/glass=20)

/obj/item/slime_scanner/attack(mob/living/M, mob/living/user)
	if(user.stat || user.eye_blind)
		return
	if (!isslime(M))
		to_chat(user, "<span class='warning'>This device can only scan slimes!</span>")
		return
	var/mob/living/simple_animal/slime/T = M
	slime_scan(T, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	to_chat(user, "========================")
	to_chat(user, "<b>Slime scan results:</b>")
	to_chat(user, "<span class='notice'>[T.colour] [T.is_adult ? "adult" : "baby"] slime</span>")
	to_chat(user, "Nutrition: [T.nutrition]/[T.get_max_nutrition()]")
	if (T.nutrition < T.get_starve_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is starving!</span>")
	else if (T.nutrition < T.get_hunger_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is hungry</span>")
	to_chat(user, "Electric change strength: [T.powerlevel]")
	to_chat(user, "Health: [round(T.health/T.maxHealth,0.01)*100]%")
	if (T.slime_mutation[4] == T.colour)
		to_chat(user, "This slime does not evolve any further.")
	else
		if (T.slime_mutation[3] == T.slime_mutation[4])
			if (T.slime_mutation[2] == T.slime_mutation[1])
				to_chat(user, "Possible mutation: [T.slime_mutation[3]]")
				to_chat(user, "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting")
			else
				to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)")
				to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
		else
			to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]")
			to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
	if (T.cores > 1)
		to_chat(user, "Multiple cores detected")
	to_chat(user, "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")
	if(T.effectmod)
		to_chat(user, "<span class='notice'>Core mutation in progress: [T.effectmod]</span>")
		to_chat(user, "<span class = 'notice'>Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]</span>")
	to_chat(user, "========================")


/obj/item/nanite_scanner
	name = "nanite scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_scanner"
	item_state = "nanite_remote"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner able to detect nanites and their programming."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=200)

/obj/item/nanite_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	user.visible_message("<span class='notice'>[user] analyzes [M]'s nanites.</span>", \
						"<span class='notice'>You analyze [M]'s nanites.</span>")

	add_fingerprint(user)

	var/response = SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, TRUE)
	if(!response)
		to_chat(user, "<span class='info'>No nanites detected in the subject.</span>")

/obj/item/sequence_scanner
	name = "genetic sequence scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "gene"
	item_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held scanner for analyzing someones gene sequence on the fly. Hold near a DNA console to update the internal database."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=200)
	var/list/discovered = list() //hit a dna console to update the scanners database
	var/list/buffer
	var/ready = TRUE
	var/cooldown = 200

/obj/item/sequence_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	if (!HAS_TRAIT(M, TRAIT_RADIMMUNE) && !HAS_TRAIT(M, TRAIT_BADDNA)) //no scanning if its a husk or DNA-less Species
		user.visible_message("<span class='notice'>[user] analyzes [M]'s genetic sequence.</span>", \
							"<span class='notice'>You analyze [M]'s genetic sequence.</span>")
		gene_scan(M, user)

	else
		user.visible_message("<span class='notice'>[user] failed to analyse [M]'s genetic sequence.</span>", "<span class='warning'>[M] has no readable genetic sequence!</span>")

/obj/item/sequence_scanner/attack_self(mob/user)
	display_sequence(user)

/obj/item/sequence_scanner/attack_self_tk(mob/user)
	return

/obj/item/sequence_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/machinery/computer/scan_consolenew))
		var/obj/machinery/computer/scan_consolenew/C = O
		if(C.stored_research)
			to_chat(user, "<span class='notice'>[name] database updated.</span>")
			discovered = C.stored_research.discovered_mutations
		else
			to_chat(user,"<span class='warning'>No database to update from.</span>")

/obj/item/sequence_scanner/proc/gene_scan(mob/living/carbon/C, mob/living/user)
	if(!iscarbon(C) || !C.has_dna())
		return
	buffer = C.dna.mutation_index
	to_chat(user, "<span class='notice'>Subject [C.name]'s DNA sequence has been saved to buffer.</span>")
	if(LAZYLEN(buffer))
		for(var/A in buffer)
			to_chat(user, "<span class='notice'>[get_display_name(A)]</span>")


/obj/item/sequence_scanner/proc/display_sequence(mob/living/user)
	if(!LAZYLEN(buffer) || !ready)
		return
	var/list/options = list()
	for(var/A in buffer)
		options += get_display_name(A)

	var/answer = input(user, "Analyze Potential", "Sequence Analyzer")  as null|anything in sortList(options)
	if(answer && ready && user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		var/sequence
		for(var/A in buffer) //this physically hurts but i dont know what anything else short of an assoc list
			if(get_display_name(A) == answer)
				sequence = buffer[A]
				break

		if(sequence)
			var/display
			for(var/i in 0 to length_char(sequence) / DNA_MUTATION_BLOCKS-1)
				if(i)
					display += "-"
				display += copytext_char(sequence, 1 + i*DNA_MUTATION_BLOCKS, DNA_MUTATION_BLOCKS*(1+i) + 1)

			to_chat(user, "<span class='boldnotice'>[display]</span><br>")

		ready = FALSE
		icon_state = "[icon_state]_recharging"
		addtimer(CALLBACK(src, .proc/recharge), cooldown, TIMER_UNIQUE)

/obj/item/sequence_scanner/proc/recharge()
	icon_state = initial(icon_state)
	ready = TRUE

/obj/item/sequence_scanner/proc/get_display_name(mutation)
	var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation)
	if(!HM)
		return "ERROR"
	if(mutation in discovered)
		return  "[HM.name] ([HM.alias])"
	else
		return HM.alias

/obj/item/extrapolator
	name = "virus extrapolator"
	icon = 'icons/obj/device.dmi'
	icon_state = "extrapolator_scan"
	desc = "A bulky scanning device, used to extract genetic material of potential pathogens"
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	var/scan = TRUE
	var/cooldown = -1200 //so it's charged roundstart
	var/obj/item/stock_parts/scanning_module/scanner //used for upgrading!

/obj/item/extrapolator/Initialize()
	. = ..()
	scanner = new(src)

/obj/item/extrapolator/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/scanning_module))
		if(!scanner)
			if(!user.transferItemToLoc(W, src))
				return
			scanner = W
			to_chat(user, "<span class='notice'>You install a [scanner.name] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] already has a scanner installed.</span>")

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(scanner)
			to_chat(user, "<span class='notice'>You remove the [scanner.name] from \the [src].</span>")
			scanner.forceMove(drop_location())
			scanner = null
	else
		return ..()

/obj/item/extrapolator/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	if(scan)
		icon_state = "extrapolator_sample"
		scan = FALSE
		to_chat(user, "<span class='notice'>You remove the probe from the device and set it to EXTRACT</span>")
	else
		icon_state = "extrapolator_scan"
		scan = TRUE
		to_chat(user, "<span class='notice'>You put the probe back in the device and set it to SCAN</span>")

/obj/item/extrapolator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!scanner)
			. += "<span class='notice'>The scanner is missing.<span>"
		else
			. += "<span class='notice'>A class <b>[scanner.rating]</b> scanning module is installed. It is <i>screwed</i> in place.<span>"
		if(cooldown > world.time - (1200 / scanner.rating))
			. += "<span class='warning'>The extrapolator is still recharging!</span>"
		else
			. += "<span class='info'>The extrapolator is ready to use!</span>"


/obj/item/extrapolator/attack(atom/AM, mob/living/user)
	return

/obj/item/extrapolator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(scanner)
		if(!target.extrapolator_act(user, src, scan))
			if(locate(/datum/component/infective) in target.datum_components)
				return //so the failure message does not show when we can actually extrapolate from a component
			if(scan)
				to_chat(user, "<span class='notice'>the extrapolator fails to return any data</span>")
			else
				to_chat(user, "<span class='notice'>the extrapolator's probe detects no diseases</span>")
	else
		to_chat(user, "<span class='warning'>the extrapolator has no scanner installed</span>")

/obj/item/extrapolator/proc/scan(atom/AM, var/list/diseases = list(), mob/user)
	to_chat(user, "<span class='notice'><b>[src] detects the following diseases:</b></span>")
	for(var/datum/disease/D in diseases)
		if(istype(D, /datum/disease/advance))
			var/datum/disease/advance/A = D
			if(A.properties["stealth"] >= (2 + scanner.rating)) //the extrapolator can detect diseases of higher stealth than a normal scanner
				continue
			to_chat(user, "<span class='info'><font color='green'><b>[A.name]</b>, stage [A.stage]/5</font></span>")
			to_chat(user, "<span class='info'><b>[A] has the following symptoms:</b></span>")
			for(var/datum/symptom/S in A.symptoms)
				to_chat(user, "<span class='info'>[S.name]</span>")
		else
			to_chat(user, "<span class='info'><font color='green'><b>[D.name]</b>, stage [D.stage]/[D.max_stages].</font></span>")

/obj/item/extrapolator/proc/extrapolate(atom/AM, var/list/diseases = list(), mob/user, isolate = FALSE, timer = 200)
	var/list/advancediseases = list()
	var/list/symptoms = list()
	if(cooldown > world.time - (1200 / scanner.rating))
		to_chat(user, "<span class='warning'>The extrapolator is still recharging!</span>")
		return
	for(var/datum/disease/advance/cantidate in diseases)
		advancediseases += cantidate
	if(!LAZYLEN(advancediseases))
		to_chat(user, "<span class='warning'>There are no valid diseases to make a culture from.</span>")
		return
	var/datum/disease/advance/A = input(user,"What disease do you wish to extract") in null|advancediseases
	if(isolate)
		for(var/datum/symptom/S in A.symptoms)
			if(S.level <= 6 + scanner.rating)
				symptoms += S
			continue
		var/datum/symptom/chosen = input(user,"What symptom do you wish to isolate") in null|symptoms
		var/datum/disease/advance/symptomholder = new
		if(!symptoms.len || !chosen)
			to_chat(user, "<span class='warning'>There are no valid diseases to isolate a symptom from.</span>")
			return
		symptomholder.name = chosen.name
		symptomholder.symptoms += chosen
		symptomholder.Finalize()
		symptomholder.Refresh()
		to_chat(user, "<span class='warning'>you begin isolating [chosen].</span>")
		if(do_mob(user, AM, (600 / scanner.rating)))
			create_culture(symptomholder, user)
	else if(do_mob(user, AM, (timer / scanner.rating)))
		create_culture(A, user)

/obj/item/extrapolator/proc/create_culture(var/datum/disease/advance/A, mob/user)
	if(cooldown > world.time - (1200 / scanner.rating))
		to_chat(user, "<span class='warning'>The extrapolator is still recharging!</span>")
		return FALSE
	var/list/data = list("viruses" = list(A))
	var/obj/item/reagent_containers/glass/bottle/B = new(user.loc)
	cooldown = world.time
	B.name = "[A.name] culture bottle"
	B.desc = "A small bottle. Contains [A.agent] culture in synthblood medium."
	B.reagents.add_reagent(/datum/reagent/blood, 20, data)
	user.put_in_hands(B)
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	return TRUE

