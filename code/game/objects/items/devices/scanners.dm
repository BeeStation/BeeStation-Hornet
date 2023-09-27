
/*

CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
SLIME SCANNER
NANITE SCANNER
GENE SCANNER

*/
#define MODE_TRAY 1 //Normal mode, shows objects under floors
#define MODE_BLUEPRINT 2 //Blueprint mode, shows how wires and pipes are by default

/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	custom_price = 10
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = FALSE
	var/mode = MODE_TRAY
	var/list/image/showing = list()
	var/client/viewing
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
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/t_scanner/proc/toggle_mode(mob/user)
	if(mode == MODE_TRAY)
		mode = MODE_BLUEPRINT
		to_chat(user, "<span class='notice'>You switch the [src] to work in the 'blueprint' mode.</span>")
		if(on)
			set_viewer(user)
	else
		to_chat(user, "<span class='notice'>You switch the [src] to work in the 'scanner' mode.</span>")
		mode = MODE_TRAY
		clear_viewer(user)
	update_appearance()

/obj/item/t_scanner/update_icon_state()
	if(on)
		icon_state = copytext_char(icon_state, 1, -1) + "[mode]"
	else
		icon_state = copytext_char(icon_state, 1, -1) + "[on]"
	return ..()

/obj/item/t_scanner/AltClick(mob/user)
	toggle_mode(user)

/obj/item/t_scanner/attack_self(mob/user)
	toggle_on()

/obj/item/t_scanner/cyborg_unequip(mob/user)
	if(!on)
		return
	toggle_on()

/obj/item/t_scanner/dropped(mob/user)
	..()
	clear_viewer(user)

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	if(mode == MODE_TRAY)
		scan()
	else
		clear_viewer(loc)
		set_viewer(loc)


/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/proc/t_ray_scan(mob/viewer, flick_time = 16, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(distance, viewer) )

		if(O.invisibility == INVISIBILITY_MAXIMUM || HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I
	if(t_ray_images.len)
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

/obj/item/t_scanner/proc/get_images(turf/T, viewsize)
	. = list()
	for(var/turf/TT in range(viewsize, T))
		if(TT.blueprint_data)
			. += TT.blueprint_data

/obj/item/t_scanner/proc/set_viewer(mob/user)
	if(!ismob(user) || !user.client)
		return
	if(user?.client)
		if(viewing)
			clear_viewer()
		viewing = user.client
		showing = get_images(get_turf(user), viewing.view)
		viewing.images |= showing

/obj/item/t_scanner/proc/clear_viewer(mob/user)
	if(!ismob(user) || !user.client)
		return
	if(viewing)
		viewing.images -= showing
		viewing = null
	showing.Cut()

#undef MODE_TRAY //Normal mode, shows objects under floors
#undef MODE_BLUEPRINT //Blueprint mode, shows how wires and pipes are by default

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
	playsound(src, 'sound/effects/fastbeep.ogg', 10)

	// Clumsiness/brain damage check
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
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
		healthscan(user, M, advanced=advanced)
	else if(scanmode == 1)
		chemscan(user, M)

	add_fingerprint(user)


// Used by the PDA medical scanner too
/proc/healthscan(mob/user, mob/living/M, mode = 1, advanced = FALSE, to_chat = TRUE)
	if(isliving(user) && (user.incapacitated() || user.is_blind()))
		return

	// the final list of strings to render
	var/message = list()

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
			message += "<span class='alert'>Subject suffering from heart attack: Apply defibrillation or other electric shock immediately!</span>"

	message += "<span class='info'>Analyzing results for [M]:\n\tOverall status: [mob_status]</span>"

	// Damage descriptions
	if(brute_loss > 10)
		message += "\t<span class='alert'>[brute_loss > 50 ? "Severe" : "Minor"] tissue damage detected.</span>"
	if(fire_loss > 10)
		message += "\t<span class='alert'>[fire_loss > 50 ? "Severe" : "Minor"] burn damage detected.</span>"
	if(oxy_loss > 10)
		message += "\t<span class='info'><span class='alert'>[oxy_loss > 50 ? "Severe" : "Minor"] oxygen deprivation detected.</span>"
	if(tox_loss > 10)
		message += "\t<span class='alert'>[tox_loss > 50 ? "Severe" : "Minor"] amount of toxin damage detected.</span>"
	if(M.getStaminaLoss())
		message += "\t<span class='alert'>Subject appears to be suffering from fatigue.</span>"
		if(advanced)
			message += "\t<span class='info'>Fatigue Level: [M.getStaminaLoss()]%.</span>"
	if(M.getCloneLoss())
		message += "\t<span class='alert'>Subject appears to have [M.getCloneLoss() > 30 ? "Severe" : "Minor"] cellular damage.</span>"
		if(advanced)
			message += "\t<span class='info'>Cellular Damage Level: [M.getCloneLoss()].</span>"
	if(!M.getorgan(/obj/item/organ/brain))
		message += "\t<span class='alert'>Subject lacks a brain.</span>"
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
			message += "\t<span class='alert'>Cerebral traumas detected: subject appears to be suffering from [english_list(trauma_text)].</span>"
		if(length(C.last_mind?.quirks))
			message += "\t<span class='info'>Subject has the following physiological traits: [C.last_mind.get_quirk_string()].</span>"
	if(advanced)
		message += "\t<span class='info'>Brain Activity Level: [(200 - M.getOrganLoss(ORGAN_SLOT_BRAIN))/2]%.</span>"

	if(M.radiation)
		message += "\t<span class='alert'>Subject is irradiated.</span>"
		if(advanced)
			message += "\t<span class='info'>Radiation Level: [M.radiation]%.</span>"

	if(advanced && M.hallucinating())
		message += "\t<span class='info'>Subject is hallucinating.</span>"

	//Eyes and ears
	if(advanced)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
			message += "\t<span class='info'><b>==EAR STATUS==</b></span>"
			if(istype(ears))
				var/healthy = TRUE
				if(HAS_TRAIT_FROM(C, TRAIT_DEAF, GENETIC_MUTATION))
					healthy = FALSE
					message += "\t<span class='alert'>Subject is genetically deaf.</span>"
				else if(HAS_TRAIT(C, TRAIT_DEAF))
					healthy = FALSE
					message += "\t<span class='alert'>Subject is deaf.</span>"
				else
					if(ears.damage)
						message += "\t<span class='alert'>Subject has [ears.damage > ears.maxHealth ? "permanent ": "temporary "]hearing damage.</span>"
						healthy = FALSE
					if(ears.deaf)
						message += "\t<span class='alert'>Subject is [ears.damage > ears.maxHealth ? "permanently ": "temporarily "] deaf.</span>"
						healthy = FALSE
				if(healthy)
					message += "\t<span class='info'>Healthy.</span>"
			else
				message += "\t<span class='alert'>Subject does not have ears.</span>"
			var/obj/item/organ/eyes/eyes = C.getorganslot(ORGAN_SLOT_EYES)
			message += "\t<span class='info'><b>==EYE STATUS==</b></span>"
			if(istype(eyes))
				var/healthy = TRUE
				if(C.is_blind())
					message += "\t<span class='alert'>Subject is blind.</span>"
					healthy = FALSE
				if(HAS_TRAIT(C, TRAIT_NEARSIGHT))
					message += "\t<span class='alert'>Subject is nearsighted.</span>"
					healthy = FALSE
				if(eyes.damage > 30)
					message += "\t<span class='alert'>Subject has severe eye damage.</span>"
					healthy = FALSE
				else if(eyes.damage > 20)
					message += "\t<span class='alert'>Subject has significant eye damage.</span>"
					healthy = FALSE
				else if(eyes.damage)
					message += "\t<span class='alert'>Subject has minor eye damage.</span>"
					healthy = FALSE
				if(healthy)
					message += "\t<span class='info'>Healthy.</span>"
			else
				message += "\t<span class='alert'>Subject does not have eyes.</span>"


	// Body part damage report
	if(iscarbon(M))
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
			message += minor_damage
			message += major_damage
			message += max_damage
		//Genetic damage
		if(advanced && H.has_dna())
			message += "\t<span class='info'>Genetic Stability: [H.dna.stability]%.</span>"
			if(H.has_status_effect(STATUS_EFFECT_LING_TRANSFORMATION))
				message += "\t<span class='info'>Subject's DNA appears to be in an unstable state.</span>"

	// Species and body temperature
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/species/S = H.dna.species
		var/mutant = FALSE
		if(H.dna.check_mutation(HULK))
			mutant = TRUE
		else if(S.mutantlungs != initial(S.mutantlungs))
			mutant = TRUE
		else if(S.mutant_brain != initial(S.mutant_brain))
			mutant = TRUE
		else if(S.mutant_heart != initial(S.mutant_heart))
			mutant = TRUE
		else if(S.mutanteyes != initial(S.mutanteyes))
			mutant = TRUE
		else if(S.mutantears != initial(S.mutantears))
			mutant = TRUE
		else if(S.mutanthands != initial(S.mutanthands))
			mutant = TRUE
		else if(S.mutanttongue != initial(S.mutanttongue))
			mutant = TRUE
		else if(S.mutanttail != initial(S.mutanttail))
			mutant = TRUE
		else if(S.mutantliver != initial(S.mutantliver))
			mutant = TRUE
		else if(S.mutantstomach != initial(S.mutantstomach))
			mutant = TRUE

		message += "<span class='info'>Species: [S.name][mutant ? "-derived mutant" : ""]</span>"
	message += "<span class='info'>Body temperature: [round(M.bodytemperature-T0C,0.1)] &deg;C ([round(M.bodytemperature*1.8-459.67,0.1)] &deg;F)</span>"

	// Time of death
	if(M.tod && (M.stat == DEAD || ((HAS_TRAIT(M, TRAIT_FAKEDEATH)) && !advanced)))
		message += "<span class='info'>Time of Death: [M.tod]</span>"
		var/tdelta = round(world.time - M.timeofdeath)
		if(tdelta < (DEFIB_TIME_LIMIT * 10))
			message += "<span class='alert'><b>Subject died [DisplayTimeText(tdelta)] ago, defibrillation may be possible!</b></span>"

	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			message += "<span class='alert'><b>Warning: [D.form] detected</b>\nName: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</span>"

	// Blood Level
	if(M.has_dna())
		var/mob/living/carbon/C = M
		var/blood_id = C.get_blood_id()
		if(blood_id)
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.bleed_rate)
					message += "<span class='alert'><b>Subject is bleeding!</b></span>"
			var/blood_percent =  round((C.blood_volume / BLOOD_VOLUME_NORMAL)*100)
			var/blood_type = C.dna.blood_type
			if(blood_id != /datum/reagent/blood)//special blood substance
				var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
				if(R)
					blood_type = R.name
				else
					blood_type = blood_id
			if(C.blood_volume <= BLOOD_VOLUME_SAFE && C.blood_volume > BLOOD_VOLUME_OKAY)
				message += "<span class='alert'>Blood level: LOW [blood_percent] %, [C.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>"
			else if(C.blood_volume <= BLOOD_VOLUME_OKAY)
				message += "<span class='alert'>Blood level: <b>CRITICAL [blood_percent] %</b>, [C.blood_volume] cl,</span> <span class='info'>type: [blood_type]</span>"
			else
				message += "<span class='info'>Blood level: [blood_percent] %, [C.blood_volume] cl, type: [blood_type]</span>"

		var/list/cyberimp_detect = list()
		for(var/obj/item/organ/cyberimp/CI in C.internal_organs)
			if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
				cyberimp_detect += CI.name
		if(length(cyberimp_detect))
			message += "<span class='notice'>Detected cybernetic modifications:</span>"
			for(var/name in cyberimp_detect)
				message += "<span class='notice'>[name]</span>"

	SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, FALSE)
	if(to_chat)
		to_chat(user, EXAMINE_BLOCK(jointext(message, "\n")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
	else
		return(jointext(message, "\n"))

/proc/chemscan(mob/living/user, mob/living/M, to_chat = TRUE)
	if(!istype(M))
		return
	var/message = list()
	if(M.reagents)
		if(M.reagents.reagent_list.len)
			message += "<span class='notice'>Subject contains the following reagents:</span>"
			for(var/datum/reagent/R in M.reagents.reagent_list)
				message += "<span class='notice'>[round(R.volume, 0.001)] units of [R.name][R.overdosed == 1 ? "</span> - <span class='boldannounce'>OVERDOSING</span>" : ".</span>"]"
		else
			message += "<span class='notice'>Subject contains no reagents.</span>"
		if(M.reagents.addiction_list.len)
			message += "<span class='boldannounce'>Subject is addicted to the following reagents:</span>"
			for(var/datum/reagent/R in M.reagents.addiction_list)
				message += "<span class='alert'>[R.name]</span>"
		else
			message += "<span class='notice'>Subject is not addicted to any reagents.</span>"
	if(to_chat)
		to_chat(user, EXAMINE_BLOCK(jointext(message, "\n")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
	else
		return(jointext(message, "\n"))

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	advanced = TRUE

/obj/item/analyzer
	desc = "A hand-held environmental scanner which can be used to scan gases in the atmosphere or within containers. Can also be used to scan unusual station phenomena. Alt-Click to use the built in barometer function."
	name = "analyzer"
	custom_price = 10
	icon = 'icons/obj/device.dmi'
	icon_state = "analyzer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	drop_sound = 'sound/items/handling/weldingtool_drop.ogg'
	pickup_sound =  'sound/items/handling/weldingtool_pickup.ogg'
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

	if(user.stat || user.is_blind())
		return

	//Functionality moved down to proc/scan_turf()
	var/turf/location = get_turf(user)

	if(!istype(location))
		return

	scan_turf(user, location)

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
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/analyzer, ping)), cooldown_time)

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

/proc/atmosanalyzer_scan(mob/user, atom/target, silent=FALSE, to_chat = TRUE)
	var/mixture = target.return_analyzable_air()
	if(!mixture)
		return FALSE

	var/list/message = list()
	var/icon = target
	if(!silent && isliving(user))
		user.visible_message("[user] has used the analyzer on [icon2html(icon, viewers(user))] [target].", "<span class='notice'>You use the analyzer on [icon2html(icon, user)] [target].</span>")
	message += "<span class='boldnotice'>Results of analysis of [icon2html(icon, user)] [target].</span>"

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/g in airs)
		if(airs.len > 1) //not a unary gas mixture
			message += "<span class='boldnotice'>Node [airs.Find(g)]</span>"
		var/datum/gas_mixture/air_contents = g

		var/total_moles = air_contents.total_moles()
		var/pressure = air_contents.return_pressure()
		var/volume = air_contents.return_volume() //could just do mixture.volume... but safety, I guess?
		var/temperature = air_contents.return_temperature()
		var/cached_scan_results = air_contents.analyzer_results

		if(total_moles > 0)
			message += "<span class='notice'>Moles: [round(total_moles, 0.01)] mol</span>"
			message += "<span class='notice'>Volume: [volume] L</span>"
			message += "<span class='notice'>Pressure: [round(pressure,0.01)] kPa</span>"

			for(var/id in air_contents.get_gases())
				var/gas_concentration = air_contents.get_moles(id)/total_moles
				message += "<span class='notice'>[GLOB.gas_data.names[id]]: [round(gas_concentration*100, 0.01)] % ([round(air_contents.get_moles(id), 0.01)] mol)</span>"
			message += "<span class='notice'>Temperature: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)</span>"

		else
			if(airs.len > 1)
				message += "<span class='notice'>This node is empty!</span>"
			else
				message += "<span class='notice'>[target] is empty!</span>"
			message += "<span class='notice'>Volume: [volume] L</span>"

		if(cached_scan_results && cached_scan_results["fusion"]) //notify the user if a fusion reaction was detected
			var/instability = round(cached_scan_results["fusion"], 0.01)
			message += "<span class='boldnotice'>Large amounts of free neutrons detected in the air indicate that a fusion reaction took place.</span>"
			message += "<span class='notice'>Instability of the last fusion reaction: [instability].</span>"

	if(to_chat)
		to_chat(user, EXAMINE_BLOCK(jointext(message, "\n")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
		return TRUE
	else
		return(jointext(message, "\n"))

/obj/item/analyzer/proc/scan_turf(mob/user, turf/location)
	var/list/message = list()
	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	message += "<span class='info'><B>Results:</B></span>"
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		message += "<span class='info'>Pressure: [round(pressure, 0.01)] kPa</span>"
	else
		message += "<span class='alert'>Pressure: [round(pressure, 0.01)] kPa</span>"
	if(total_moles)
		var/o2_concentration = environment.get_moles(GAS_O2)/total_moles
		var/n2_concentration = environment.get_moles(GAS_N2)/total_moles
		var/co2_concentration = environment.get_moles(GAS_CO2)/total_moles
		var/plasma_concentration = environment.get_moles(GAS_PLASMA)/total_moles

		if(abs(n2_concentration - N2STANDARD) < 20)
			message += "<span class='info'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_N2), 0.01)] mol)</span>"
		else
			message += "<span class='alert'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_N2), 0.01)] mol)</span>"

		if(abs(o2_concentration - O2STANDARD) < 2)
			message += "<span class='info'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_O2), 0.01)] mol)</span>"
		else
			message += "<span class='alert'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_O2), 0.01)] mol)</span>"

		if(co2_concentration > 0.01)
			message += "<span class='alert'>CO2: [round(co2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_CO2), 0.01)] mol)</span>"
		else
			message += "<span class='info'>CO2: [round(co2_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_CO2), 0.01)] mol)</span>"

		if(plasma_concentration > 0.005)
			message += "<span class='alert'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_PLASMA), 0.01)] mol)</span>"
		else
			message += "<span class='info'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(environment.get_moles(GAS_PLASMA), 0.01)] mol)</span>"

		for(var/id in environment.get_gases())
			if(id in GLOB.hardcoded_gases)
				continue
			var/gas_concentration = environment.get_moles(id)/total_moles
			message += "<span class='alert'>[GLOB.gas_data.names[id]]: [round(gas_concentration*100, 0.01)] % ([round(environment.get_moles(id), 0.01)] mol)</span>"
		message += "<span class='info'>Temperature: [round(environment.return_temperature()-T0C, 0.01)] &deg;C ([round(environment.return_temperature(), 0.01)] K)</span>"
	to_chat(user, EXAMINE_BLOCK(jointext(message, "\n")))

/obj/item/analyzer/ranged
	desc = "A hand-held scanner which uses advanced spectroscopy and infrared readings to analyze gases as a distance. Alt-Click to use the built in barometer function."
	name = "long-range analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "ranged_analyzer"

/obj/item/analyzer/ranged/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(target.tool_act(user, src, tool_behaviour))
		return
	// Tool act didn't scan it, so let's get it's turf.
	var/turf/location = get_turf(target)
	scan_turf(user, location)

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
	if(user.stat || user.is_blind())
		return
	if(!isslime(M))
		to_chat(user, "<span class='warning'>This device can only scan slimes!</span>")
		return
	var/mob/living/simple_animal/slime/T = M
	slime_scan(T, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	var/list/message = list()

	message += "<b>Slime scan results:</b>"
	message += "<span class='notice'>[T.colour] [T.is_adult ? "adult" : "baby"] slime</span>"
	message += "Nutrition: [T.nutrition]/[T.get_max_nutrition()]"
	if(T.nutrition < T.get_starve_nutrition())
		message += "<span class='warning'>Warning: slime is starving!</span>"
	else if(T.nutrition < T.get_hunger_nutrition())
		message += "<span class='warning'>Warning: slime is hungry</span>"
	message += "Electric change strength: [T.powerlevel]"
	message += "Health: [round(T.health/T.maxHealth,0.01)*100]%"
	if(T.slime_mutation[4] == T.colour)
		message += "This slime does not evolve any further."
	else
		if(T.slime_mutation[3] == T.slime_mutation[4])
			if(T.slime_mutation[2] == T.slime_mutation[1])
				message += "Possible mutation: [T.slime_mutation[3]]"
				message += "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting"
			else
				message += "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)"
				message += "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
		else
			message += "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]"
			message += "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
	if(T.cores > 1)
		message += "Multiple cores detected"
	message += "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]"
	if(T.has_status_effect(STATUS_EFFECT_SLIMEGRUB))
		message += "<b>Redgrub infestation detected. Quarantine immediately.</b>"
		message += "Redgrubs can be purged from a slime using capsaicin oil or extreme heat"
	if(T.effectmod)
		message += "<span class='notice'>Core mutation in progress: [T.effectmod]</span>"
		message += "<span class = 'notice'>Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]</span>"
	if(T.transformeffects != SLIME_EFFECT_DEFAULT)
		var/slimeeffect = "\nTransformative extract effect detected: "
		if(T.transformeffects & SLIME_EFFECT_GREY)
			slimeeffect += "grey"
		if(T.transformeffects & SLIME_EFFECT_ORANGE)
			slimeeffect += "orange"
		if(T.transformeffects & SLIME_EFFECT_PURPLE)
			slimeeffect += "purple"
		if(T.transformeffects & SLIME_EFFECT_BLUE)
			slimeeffect += "blue"
		if(T.transformeffects & SLIME_EFFECT_METAL)
			slimeeffect += "metal"
		if(T.transformeffects & SLIME_EFFECT_YELLOW)
			slimeeffect += "yellow"
		if(T.transformeffects & SLIME_EFFECT_DARK_PURPLE)
			slimeeffect += "dark purple"
		if(T.transformeffects & SLIME_EFFECT_DARK_BLUE)
			slimeeffect += "dark blue"
		if(T.transformeffects & SLIME_EFFECT_SILVER)
			slimeeffect += "silver"
		if(T.transformeffects & SLIME_EFFECT_BLUESPACE)
			slimeeffect += "bluespace"
		if(T.transformeffects & SLIME_EFFECT_SEPIA)
			slimeeffect += "sepia"
		if(T.transformeffects & SLIME_EFFECT_CERULEAN)
			slimeeffect += "cerulean"
		if(T.transformeffects & SLIME_EFFECT_PYRITE)
			slimeeffect += "pyrite"
		if(T.transformeffects & SLIME_EFFECT_RED)
			slimeeffect += "red"
		if(T.transformeffects & SLIME_EFFECT_GREEN)
			slimeeffect += "green"
		if(T.transformeffects & SLIME_EFFECT_PINK)
			slimeeffect += "pink"
		if(T.transformeffects & SLIME_EFFECT_GOLD)
			slimeeffect += "gold"
		if(T.transformeffects & SLIME_EFFECT_OIL)
			slimeeffect += "oil"
		if(T.transformeffects & SLIME_EFFECT_BLACK)
			slimeeffect += "black"
		if(T.transformeffects & SLIME_EFFECT_LIGHT_PINK)
			slimeeffect += "light pink"
		if(T.transformeffects & SLIME_EFFECT_ADAMANTINE)
			slimeeffect += "adamantine"
		if(T.transformeffects & SLIME_EFFECT_RAINBOW)
			slimeeffect += "rainbow"
		message += "<span class='notice'>[slimeeffect].</span>"
	to_chat(user, EXAMINE_BLOCK(jointext(message, "\n")))


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

/obj/item/sequence_scanner/attack(mob/living/M, mob/living/user)
	add_fingerprint(user)
	if(!HAS_TRAIT(M, TRAIT_RADIMMUNE) && !HAS_TRAIT(M, TRAIT_BADDNA)) //no scanning if its a husk or DNA-less Species
		user.visible_message("<span class='notice'>[user] analyzes [M]'s genetic sequence.</span>", \
							"<span class='notice'>You analyze [M]'s genetic sequence.</span>")
		gene_scan(M, user)
		playsound(src, 'sound/effects/fastbeep.ogg', 20)

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

	var/list/full_list_mutations = list()
	for(var/each in buffer) // get inherent mutations first
		full_list_mutations[each] = FALSE
	for(var/datum/mutation/each_mutation in C.dna.mutations)
		if(each_mutation.type in buffer) // active inherent mutation
			full_list_mutations[each_mutation.type] = "Activated"
		else // active artificial mutation
			full_list_mutations[each_mutation.type] = "Injected"
	for(var/datum/mutation/each_mutation in C.dna.temporary_mutations)
		full_list_mutations[each_mutation.type] = "Temporary"

	for(var/A in full_list_mutations)
		to_chat(user, "\t<span class='notice'>[get_display_name(A)]</span>") // if you want to make the scanner tell which mutation is active, put "full_list_mutations[A]" to the second parameter of get_display_name() proc.
	to_chat(user, "\t<span class='info'>Genetic Stability: [C.dna.stability]%.</span>")
	if(C.has_status_effect(STATUS_EFFECT_LING_TRANSFORMATION))
		to_chat(user, "\t<span class='info'>Subject's DNA appears to be in an unstable state.</span>")


/obj/item/sequence_scanner/proc/display_sequence(mob/living/user)
	if(!LAZYLEN(buffer) || !ready)
		return
	var/list/options = list()
	for(var/A in buffer)
		options += get_display_name(A)

	var/answer = input(user, "Analyze Potential", "Sequence Analyzer")  as null|anything in sort_list(options)
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
		addtimer(CALLBACK(src, PROC_REF(recharge)), cooldown, TIMER_UNIQUE)

/obj/item/sequence_scanner/proc/recharge()
	icon_state = initial(icon_state)
	ready = TRUE

/obj/item/sequence_scanner/proc/get_display_name(mutation, active_detail=FALSE)
	var/datum/mutation/HM = GET_INITIALIZED_MUTATION(mutation)
	if(!HM)
		return "ERROR"
	if(discovered[mutation])
		return !active_detail ? "[HM.name] ([HM.alias])" : "<span class='green'>[HM.name] ([HM.alias]) - [active_detail]</span>"
	else
		return !active_detail ? HM.alias : "<span class='green'>[HM.alias] - [active_detail]</span>"

/obj/item/extrapolator
	name = "virus extrapolator"
	icon = 'icons/obj/device.dmi'
	icon_state = "extrapolator_scan"
	desc = "A bulky scanning device, used to extract genetic material of potential pathogens"
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	/// Whether the extrapolator is currently in use.
	var/using = FALSE
	/// Whether the extrapolator is currently in SCAN or EXTRACT mode.
	var/scan = TRUE
	/// The scanning module installed in the extrapolator. Used to determine extraction speed, and the stealthiest virus that's possible to extract.
	var/obj/item/stock_parts/scanning_module/scanner
	/// A list of advance disease IDs that this extrapolator has already extracted.
	var/list/extracted_ids = list()
	/// How long it takes, in deciseconds, for the extrapolator to extract a virus.
	var/extract_time = 10 SECONDS
	/// How long it takes, in deciseconds, for the extrapolator to isolate a symptom.
	var/isolate_time = 15 SECONDS
	/// The extrapolator can extract any virus with a stealth below this value.
	var/maximum_stealth = 3
	/// The extrapolator can extract any symptom with a stealth below this value.
	var/maximum_level = 7
	/// The typepath of the default scanning module that will generate in the extrapolator, if it starts with none.
	var/default_scanning_module = /obj/item/stock_parts/scanning_module
	/// Cooldown for when the extrapolator can be used next.
	COOLDOWN_DECLARE(usage_cooldown)

/obj/item/extrapolator/Initialize(mapload, obj/item/stock_parts/scanning_module/starting_scanner)
	. = ..()
	starting_scanner = starting_scanner || default_scanning_module
	if(ispath(starting_scanner, /obj/item/stock_parts/scanning_module))
		scanner = new starting_scanner(src)
	else if(istype(starting_scanner))
		starting_scanner.forceMove(src)
		scanner = starting_scanner
	refresh_parts()

/obj/item/extrapolator/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stock_parts/scanning_module))
		if(!scanner)
			if(!user.transferItemToLoc(item, src))
				return
			scanner = item
			to_chat(user, "<span class='notice'>You install \the [scanner] in [src].</span>")
			refresh_parts()
		else
			to_chat(user, "<span class='notice'>[src] already has \the [scanner] installed.</span>")
		return
	return ..()

/obj/item/extrapolator/screwdriver_act(mob/living/user, obj/item/item)
	. = TRUE
	if(..())
		return
	if(!scanner)
		to_chat(user, "<span class='warning'>\The [src] has no scanner to remove!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You remove \the [scanner] from \the [src].</span>")
	scanner.forceMove(drop_location())
	scanner = null
	item.play_tool_sound(src)

/obj/item/extrapolator/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/machines/click.ogg', vol = 50, vary = TRUE)
	if(scan)
		icon_state = "extrapolator_sample"
		scan = FALSE
		to_chat(user, "<span class='notice'>You remove the probe from the device and set it to EXTRACT.</span>")
	else
		icon_state = "extrapolator_scan"
		scan = TRUE
		to_chat(user, "<span class='notice'>You put the probe back in the device and set it to SCAN.</span>")

/obj/item/extrapolator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!scanner)
			. += "<span class='notice'>The scanner is missing.</span>"
		else
			. += "<span class='notice'>A class <b>[scanner.rating]</b> scanning module is installed. It is <i>screwed</i> in place.</span>"
			. += "<span class='notice'>Can detect diseases <b>below stealth [maximum_stealth]</b>.</span>"
			. += "<span class='notice'>Can extract diseases in <b>[DisplayTimeText(extract_time)]</b>.</span>"
			. += "<span class='notice'>Can isolate symptoms <b>[maximum_level >= 9 ? "of any level" : "below level [maximum_level]"]</b>, in <b>[DisplayTimeText(isolate_time)]</b>.</span>"

/**
 * Updates the extraction and isolation times based on the scanner's rating.
 */
/obj/item/extrapolator/proc/refresh_parts()
	if(!scanner)
		return
	var/effective_scanner_rating = scanner.rating + 1
	extract_time = (10 SECONDS) / effective_scanner_rating
	isolate_time = (15 SECONDS) / effective_scanner_rating
	maximum_stealth = scanner.rating + 2
	maximum_level = scanner.rating + 7

/obj/item/extrapolator/attack(atom/AM, mob/living/user)
	return

/obj/item/extrapolator/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag && !scan)
		return
	if(using)
		to_chat(user, "<span class='warning'>[icon2html(src, user)] The extrapolator is already in use.</span>")
		return
	if(!COOLDOWN_FINISHED(src, usage_cooldown))
		to_chat(user, "<span class='warning'>[icon2html(src, user)] The extrapolator is still recharging!</span>")
		return
	if(scanner)
		var/list/result = target?.extrapolator_act(user, src, dry_run = TRUE)
		var/list/diseases = result && result[EXTRAPOLATOR_RESULT_DISEASES]
		if(!length(diseases))
			var/list/atom/targets = find_valid_targets(user, target)
			var/target_amt = length(targets)
			if(target_amt)
				target = target_amt > 1 ? tgui_input_list(user, "Select object to analyze", "Viral Extrapolation", targets, default = targets[1]) : targets[1]
			if(target)
				result = target.extrapolator_act(user, src, dry_run = TRUE)
				diseases = result && result[EXTRAPOLATOR_RESULT_DISEASES]
		if(!target)
			return
		if(!length(diseases))
			if(scan)
				to_chat(user, "<span class='notice'>[icon2html(src, user)] \The [src] fails to return any data.</span>")
			else
				to_chat(user, "<span class='notice'>[icon2html(src, user)] \The [src]'s probe detects no diseases.</span>")
			return
		if(EXTRAPOLATOR_ACT_CHECK(result, EXTRAPOLATOR_ACT_PRIORITY_SPECIAL))
			// extrapolator_act did some sort of special behavior, we don't need to do anything further
			return
		if(scan)
			scan(user, target)
		else
			extrapolate(user, target)
	else
		to_chat(user, "<span class='warning'>The extrapolator has no scanner installed!</span>")

/obj/item/extrapolator/proc/find_valid_targets(mob/living/user, atom/target)
	. = list()
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return
	for(var/atom/target_to_try in target_turf.contents - target)
		var/list/result = target_to_try.extrapolator_act(user, src, dry_run = TRUE)
		if(length(result[EXTRAPOLATOR_RESULT_DISEASES]))
			. += target_to_try

/**
 * Scans an atom, showing any (detectable) diseases they may have.
 */
/obj/item/extrapolator/proc/scan(mob/living/user, atom/target)
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
		message += "<span class='boldnotice'>[costly_icon2html(target, user)] [target] scan results</span>"
		message += "<span class='boldnotice'>[icon2html(src, user)] \The [src] detects the following diseases:</span>"
		for(var/datum/disease/disease in diseases)
			if(istype(disease, /datum/disease/advance))
				var/datum/disease/advance/advance_disease = disease
				if(advance_disease.stealth >= maximum_stealth) //the extrapolator can detect diseases of higher stealth than a normal scanner
					continue
				message += "<span class='info'><b>[advance_disease.name]</b>, [advance_disease.dormant ? "<i>dormant virus</i>" : "stage [advance_disease.stage]/5"]</span>"
				if(extracted_ids[advance_disease.GetDiseaseID()])
					message += "<span class='info italics'>This virus has been extracted by \the [src] previously.</span>"
				message += "<span class='info bold'>[advance_disease.name] has the following symptoms:</span>"
				for(var/datum/symptom/symptom in advance_disease.symptoms)
					message += "[symptom.name]"
			else
				message += "<span class='info'><b>[disease.name]</b>, stage [disease.stage]/[disease.max_stages].</span>"
	to_chat(user, EXAMINE_BLOCK(jointext(message, "\n")), avoid_highlighting = TRUE, trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/**
 * Attempts to either extract a disease from an atom, or isolate a symptom from an advance disease.
 */
/obj/item/extrapolator/proc/extrapolate(mob/living/user, atom/target, isolate = FALSE)
	. = FALSE
	var/list/result = target?.extrapolator_act(user, target)
	var/list/diseases = result[EXTRAPOLATOR_RESULT_DISEASES]
	if(!length(diseases))
		return
	if(EXTRAPOLATOR_ACT_CHECK(result, EXTRAPOLATOR_ACT_PRIORITY_SPECIAL)) // hardcoded "we handled this ourselves" response
		return TRUE
	if(EXTRAPOLATOR_ACT_CHECK(result, EXTRAPOLATOR_ACT_PRIORITY_ISOLATE))
		isolate = TRUE
	var/list/advance_diseases = list()
	for(var/datum/disease/advance/candidate in diseases)
		advance_diseases += candidate
	if(!length(advance_diseases))
		to_chat(user, "<span class='warning'>[icon2html(src, user)] There are no valid diseases to make a culture from.</span>")
		return
	var/datum/disease/advance/target_disease = length(advance_diseases) > 1 ? tgui_input_list(user, "Select disease to extract", "Viral Extraction", advance_diseases, default = advance_diseases[1]) : advance_diseases[1]
	if(!target_disease)
		return
	using = TRUE
	if(isolate)
		. = isolate_symptom(user, target, target_disease)
	else
		. = isolate_disease(user, target, target_disease)
	using = FALSE

/**
 * Attempts to isolate a single symptom from an advance disease.
 */
/obj/item/extrapolator/proc/isolate_symptom(mob/living/user, atom/target, datum/disease/advance/target_disease)
	. = FALSE
	var/list/symptoms = list()
	for(var/datum/symptom/symptom in target_disease.symptoms)
		if(symptom.level <= maximum_level)
			symptoms += symptom
			continue
	if(!length(symptoms))
		to_chat(user, "<span class='warning'>[icon2html(src, user)] There are no symptoms that could be isolated..</span>")
		return
	var/datum/symptom/chosen = length(symptoms) > 1 ? tgui_input_list(user, "Select symptom to isolate", "Symptom Extraction", symptoms, default = symptoms[1]) : symptoms[1]
	if(!chosen)
		return
	user.visible_message("<span class='notice'>[user] slots [target] into [src], which begins to whir and beep!</span>", \
		"<span class='notice'>[icon2html(src, user)] You begin isolating <b>[chosen.name]</b> from [target]...</span>", \
		vision_distance = COMBAT_MESSAGE_RANGE)
	var/datum/disease/advance/symptom_holder = new
	symptom_holder.name = chosen.name
	symptom_holder.symptoms += chosen
	symptom_holder.Finalize()
	symptom_holder.Refresh()
	if(do_after(user, extract_time, target = target))
		create_culture(user, symptom_holder, target)
		return TRUE

/**
 * Attempts to isolate an advance disease from a target.
 */
/obj/item/extrapolator/proc/isolate_disease(mob/living/user, atom/target, datum/disease/advance/target_disease, timer = 10 SECONDS)
	. = FALSE
	user.visible_message("<span class='notice'>[user] begins to thoroughly scan [target] with [src]...</span>", \
		"<span class='notice'>[icon2html(src, user)] You begin isolating <b>[target_disease.name]</b> from [target]...</span>")
	if(do_after(user, isolate_time, target = target))
		create_culture(user, target_disease, target)
		return TRUE

/**
 * Creates a culture of an advance disease.
 */
/obj/item/extrapolator/proc/create_culture(mob/living/user, datum/disease/advance/disease)
	. = FALSE
	var/list/data = list("viruses" = list(disease))
	if(user.get_active_held_item() != src)
		to_chat(user, "<span class='warning'>The extrapolator must be held in your active hand to work!</span>")
		return
	var/obj/item/reagent_containers/glass/bottle/culture_bottle = new(user.drop_location())
	culture_bottle.name = "[disease.name] culture bottle"
	culture_bottle.desc = "A small bottle. Contains [disease.agent] culture in synthblood medium."
	culture_bottle.reagents.add_reagent(/datum/reagent/blood, 20, data)
	user.put_in_hands(culture_bottle)
	playsound(src, 'sound/machines/ping.ogg', vol = 30, vary = TRUE)
	COOLDOWN_START(src, usage_cooldown, 1 SECONDS)
	extracted_ids[disease.GetDiseaseID()] = TRUE
	return TRUE

/obj/item/extrapolator/tier4
	default_scanning_module = /obj/item/stock_parts/scanning_module/triphasic
