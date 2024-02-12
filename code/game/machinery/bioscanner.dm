// Bioscanners! Stealing code from sleepers since 2545!

/obj/machinery/bioscanner
	name = "bio-Scanner"
	desc = "An enclosed machine used to scan and diagnose patients."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "bscanner"
	density = FALSE
	circuit = /obj/item/circuitboard/machine/bioscanner

	idle_power_usage = 1000
	active_power_usage = 10000
	use_power = IDLE_POWER_USE

	state_open = TRUE
	clicksound = 'sound/machines/pda_button1.ogg'
	var/datum/looping_sound/bioscanner/soundloop

	var/scanning
	var/scan_timer
	var/enter_message = "<span class='notice'><b>You feel a prickling as the scanning beams pass over you.</b></span>"

	var/speed_coeff
	var/scan_level
	var/radiation_dose
	var/result

/obj/machinery/bioscanner/Initialize(mapload)
	. = ..()
	occupant_typecache = GLOB.typecache_living
	update_appearance()
	RefreshParts()
	soundloop = new(src, FALSE)

/obj/machinery/microwave/Destroy()
	open_machine()
	QDEL_NULL(soundloop)
	. = ..()

/obj/machinery/bioscanner/RefreshParts()
	scan_level = 0
	speed_coeff = 1

	// E is scanning level, meaning how good it scans.
	var/E
	for(var/obj/item/stock_parts/micro_laser/B in component_parts)
		E += B.rating
	radiation_dose = 400 / E

	// I is scanning power, meaning how fast it scans
	var/I
	for(var/obj/item/stock_parts/scanning_module/M in component_parts)
		I += M.rating

	speed_coeff = 1 / I
	ui_update()

/obj/machinery/bioscanner/update_icon()

	//Default if nothing else changes it.
	icon_state= "bscanner"

	if(machine_stat == NOPOWER)
		icon_state= "bscanner"
		return

	if(panel_open)
		icon_state= "bscanner-o"
		return

	//If closed, be closed. Unless there's someone in it,
	if(!state_open)
		icon_state= "bscanner_off"

		//because then you need the fancy colors.
		if(occupant)
			icon_state = "bscanner_green"
			if(occupant && scanning)
				var/mob/living/mob_occupant = occupant
				switch(mob_occupant.stat)
					if(CONSCIOUS, SOFT_CRIT)
						icon_state = "bscanner_yellow"
					if(UNCONSCIOUS)
						icon_state = "bscanner_red"
					if(DEAD)
						icon_state = "bscanner_death"
		return
	. = ..()

/obj/machinery/bioscanner/container_resist(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/bioscanner/open_machine()
	if(!state_open && !panel_open && !scanning)
		..()

/obj/machinery/bioscanner/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(mob_occupant, "[enter_message]")

/obj/machinery/bioscanner/MouseDrop_T(mob/target, mob/user)
	if(user.stat || !iscarbon(target) || !user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can't do that!</span>")
		return
	if(!Adjacent(user) || !user.Adjacent(target))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			to_chat(user, "<span class='warning'>You have to stand to do this!</span>")
			return
	close_machine(target)

/obj/machinery/bioscanner/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, "<span class='warning'>[src] is currently occupied!</span>")
		return
	if(state_open)
		to_chat(user, "<span class='warning'>[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!</span>")
		return
	if(default_deconstruction_screwdriver(user, "bscanner-o", "bscanner_off", I))
		return
	return FALSE

/obj/machinery/bioscanner/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/bioscanner/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/bioscanner/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click [src] to [state_open ? "close" : "open"] it.</span>"

/obj/machinery/bioscanner/process()
	..()
	if(machine_stat == NOPOWER && !state_open)
		use_power = IDLE_POWER_USE
		scanning = FALSE
		soundloop.stop()
		deltimer(scan_timer)
		update_icon()
		open_machine()
		balloon_alert_to_viewers("Powerloss detected, unlatching door.")
		playsound(src, 'sound/machines/creak.ogg', 100, FALSE, 0)
	else
		update_icon()

/obj/machinery/bioscanner/proc/startscan(mob/user)
	var/mob/living/mob_occupant = occupant
	if(!scanning && !state_open && occupant && iscarbon(mob_occupant))
		use_power = ACTIVE_POWER_USE
		scanning = TRUE
		update_icon()
		visible_message("<span class='notice'> The Bio-Scanner hums to life.</span>")
		balloon_alert_to_viewers("Beginning scan cycle.")
		soundloop.start()
		playsound(src, 'sound/machines/boop.ogg', 75, FALSE, 0)
		scan_timer = addtimer(CALLBACK(src, PROC_REF(bioscanComplete), user), 300*speed_coeff, TIMER_STOPPABLE)
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 15, FALSE, 0)
		return

/obj/machinery/bioscanner/proc/bioscanComplete()
	use_power = IDLE_POWER_USE
	scanning = FALSE
	update_icon()
	var/mob/living/mob_occupant = occupant
	mob_occupant.rad_act(rand(radiation_dose/2,radiation_dose))
	visible_message("<span class='notice'> The Bio-Scanner shuts down.</span>")
	balloon_alert_to_viewers("Scan complete.")
	playsound(src, 'sound/machines/ping.ogg', 75, FALSE, 0)
	soundloop.stop()

	//Here we go, the paper, the RESULTS.
	//starting with the general section

	//when just using mob_occupant.stat on the paper, it always just returns numbers. so we do this instead. sounds more professional too
	var/occupantStatus
	var/occupantColor

	//Damage specifics
	var/oxy_loss = mob_occupant.getOxyLoss()
	var/tox_loss = mob_occupant.getToxLoss()
	var/fire_loss = mob_occupant.getFireLoss()
	var/brute_loss = mob_occupant.getBruteLoss()

	switch(mob_occupant.stat)
		if(CONSCIOUS)
			occupantStatus = "Stable"
			occupantColor = "Green"
		if (SOFT_CRIT)
			occupantStatus = "Progressive Shock"
			occupantColor = "Orange"
		if(UNCONSCIOUS)
			occupantStatus = "Fibrillating"
			occupantColor = "Red"
		if(DEAD)
			occupantStatus = "Asystole"
			occupantColor = "Red"

	//Species check, like many things, stolen from the health analyzer
	var/mob/living/carbon/human/H = mob_occupant
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

	//General

	result = "<i>Station time: [station_time_timestamp()]</i><br>\
				<h1>#Biotic Scan Report</h1><br>\
				<h2>#Nanotrasen Medical Devision</h2><br>\
				<hr />\
				<h1>GENERAL</h1><br>\
				Name: [mob_occupant]<br>\
				Species: [(S.name)][mutant ? "-derived mutant" : ""]<br>\
				<b>Status: <font color=[occupantColor]>[occupantStatus]</font></b><br>\
				DNA: [H.dna.unique_enzymes]<br>\
				Body temperature: [round(mob_occupant.bodytemperature-T0C,0.1)] &deg;C ([round(mob_occupant.bodytemperature*1.8-459.67,0.1)] &deg;F<br>"

	//Cardiac Arrest!
	if(ishuman(H))
		if(H.undergoing_cardiac_arrest() && H.stat != DEAD)
			result += "<hr /><b><font color=["red"]>Subject suffering from heart attack: Apply defibrillation or other electric shock immediately!</font></b>"

	if(mob_occupant.tod && (mob_occupant.stat == DEAD || ((HAS_TRAIT(mob_occupant, TRAIT_FAKEDEATH)))))
		result += "Time of Death: [mob_occupant.tod]<br>"
		var/tdelta = round(world.time - mob_occupant.timeofdeath)
		if(tdelta < (DEFIB_TIME_LIMIT * 10))
			result += "<b>Subject died [DisplayTimeText(tdelta)] ago, defibrillation may be possible!</b><br>"

	result += "<hr />"

	//Injury
	result += "<h2>INJURY</h2><br>"

	if(iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		var/list/damaged = C.get_damaged_bodyparts(1,1)
		var/list/dmgreport = list()
		dmgreport += "<table style='margin-left:3em'><tr><font face='Verdana'>\
						<td style='width:7em;'><font color='#0000CC'>Damage:</font></td>\
						<td style='width:5em;'><font color='red'><b>Blunt-Force Tissue</b></font></td>\
						<td style='width:4em;'><font color='orange'><b>Thermal-Burn Tissue</b></font></td>\

						<tr><td><font color='#0000CC'>Overall:</font></td>\
						<td><font color='red'>[round(brute_loss,1)]</font></td>\
						<td><font color='orange'>[round(fire_loss,1)]</font></td></tr>"

		for(var/o in damaged)
			var/obj/item/bodypart/org = o //head, left arm, right arm, etc.
			dmgreport += "<tr><td><font color='#0000CC'>[capitalize(parse_zone(org.body_zone))]:</font></td>\
							<td><font color='red'>[(org.brute_dam > 0) ? "[round(org.brute_dam,1)]" : "0"]</font></td>\
							<td><font color='orange'>[(org.burn_dam > 0) ? "[round(org.burn_dam,1)]" : "0"]</font></td></tr>"
		dmgreport += "</font></table>"
		result += dmgreport.Join()

	result +="<hr />\
				<b>Radioactive Tissue Damage: [mob_occupant.radiation]</b><br>\
				<b>Hypoxemic Damage: [oxy_loss]</b><br>\
				<b>Blood Toxicity: [tox_loss]</b><br>\
				<b>Lactic Acid Buildup: [mob_occupant.getStaminaLoss()]</b><br>"

	result += "<hr />"

	//Organs!
	result += "<h2>ORGANS</h2><br>"

	if(ishuman(occupant))
		result += "<b>Detected Internal Organs:</b><br>"
		for(var/O in H.internal_organs)
			var/obj/item/organ/organ = O
			if(organ.damage >= 60)
				result += " - <b><font color=["red"]>WARNING:[organ.name] at [organ.damage] damage.</b></font><br>"
			else if(organ.damage >= 30)
				result += " - <b>[organ.name] at [organ.damage] damage.</b><br>"
			else
				result += " - [organ.name] at [organ.damage] damage.<br>"

	for(var/obj/item/bodypart/limb as anything in H.bodyparts)
		for(var/obj/item/embed as anything in limb.embedded_objects)
			result += "Foreign object detected in subject's:[limb.name]<br>"

	result += "<hr />"

	//Genetics
	result += "<h2>GENETICAL</h2><br>"

	result += "Chromosomal Damage: [mob_occupant.getCloneLoss()]<br>"

	if(H.has_dna())
		result += "Genetic Stability: [H.dna.stability]%.<br>"
		if(H.has_status_effect(STATUS_EFFECT_LING_TRANSFORMATION))
			result += "Subject's DNA appears to be in an unstable state."

	result += "<hr />"

	//Neural
	result += "<h2>NEURAL</h2><br>"

	if(!mob_occupant.getorgan(/obj/item/organ/brain))
		result += "ERROR: Subject lacks a brain.<br>"

	result += "Brain Activity Level: [(200 - mob_occupant.getOrganLoss(ORGAN_SLOT_BRAIN))/2]%.<br>"

	var/mob/living/carbon/C = mob_occupant
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
		result += "Cerebral traumas detected: subject appears to be suffering from [english_list(trauma_text)].<br>"
	else
		result += "No Cerebral traumas detected.<br>"

	if(length(C.last_mind?.quirks))
		result += "Subject has the following physiological traits: [C.last_mind.get_quirk_string()]."
	else
		result += "Subject has no particular physiological traits.<br>"

	if(mob_occupant.hallucinating())
		result += "Subject is hallucinating."
	else
		result += "Subject is not hallucinating."

	result += "<hr />"

	//Blood
	result += "<h2>BLOOD</h2><br>"

	if(mob_occupant.has_dna())
		var/blood_id = C.get_blood_id()
		if(blood_id)
			if(ishuman(C))
				if(H.bleed_rate)
					result += "<b>Subject currently losing blood.</b><br>"
			var/blood_percent =  round((C.blood_volume / BLOOD_VOLUME_NORMAL)*100)
			var/blood_type = C.dna.blood_type
			if(blood_id != /datum/reagent/blood)//special blood substance
				var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
				if(R)
					blood_type = R.name
				else
					blood_type = blood_id
			if(C.blood_volume <= BLOOD_VOLUME_SAFE && C.blood_volume > BLOOD_VOLUME_OKAY)
				result += "Blood level: LOW [blood_percent] %, [C.blood_volume] cl.<br> Blood Type: [blood_type].<br>"
			else if(C.blood_volume <= BLOOD_VOLUME_OKAY)
				result += "Blood level: <b>CRITICAL [blood_percent] %</b>, [C.blood_volume] cl.<br> Blood Type: [blood_type].<br>"
			else
				result += "Blood level: [blood_percent] %, [C.blood_volume] cl.<br> Blood Type: [blood_type]<br>"

	for(var/thing in mob_occupant.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			result += "<b>Warning: [D.form] detected</b><br>\
			Name: [D.name].<br>\
			Type: [D.spread_text].<br>\
			Stage: [D.stage]/[D.max_stages].<br>\
			Possible Cure: [D.cure_text]<br>"

	result += "<br><b>Reagents:</b><br>"

	//reagents
	if(istype(mob_occupant))
		if(mob_occupant.reagents)
			if(mob_occupant.reagents.reagent_list.len)
				result += "Subject contains the following reagents:<br>"
				for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
					result += "[round(R.volume, 0.001)] units of [R.name][R.overdosed == 1 ? "<b>OVERDOSING</B>" : "."]"
			else
				result += "Subject contains no reagents.<br>"
			if(mob_occupant.reagents.addiction_list.len)
				result += "Subject is addicted to the following reagents:<br>"
				for(var/datum/reagent/R in mob_occupant.reagents.addiction_list)
					result += "[R.name]<br>"
			else
				result += "Subject is not addicted to any reagents.<br>"

	result += "<hr />"
	//Then printing it
	var/obj/item/paper/paperwork = new /obj/item/paper(get_turf(src))
	paperwork.name = "BIOTIC SCAN RESULT: [mob_occupant]."
	paperwork.add_raw_text(result)
	paperwork.update_appearance()
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)

/obj/machinery/bioscanner/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/bioscanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Bioscanner", "Biotic Scanner")
		ui.open()

/obj/machinery/bioscanner/ui_data(mob/user)
	var/list/data = list()
	data["open"] = state_open

	data["scanning"] = scanning

	data["occupant"] = list()
	if(!isliving(occupant))
		data["occupied"] = FALSE
		return data
	data["occupied"] = TRUE
	var/mob/living/mob_occupant = occupant
	data["occupant"]["name"] = mob_occupant.name
	switch(mob_occupant.stat)
		if(CONSCIOUS)
			data["occupant"]["stat"] = "Conscious"
			data["occupant"]["statstate"] = "good"
		if(SOFT_CRIT)
			data["occupant"]["stat"] = "Conscious"
			data["occupant"]["statstate"] = "average"
		if(UNCONSCIOUS)
			data["occupant"]["stat"] = "Unconscious"
			data["occupant"]["statstate"] = "average"
		if(DEAD)
			data["occupant"]["stat"] = "Dead"
			data["occupant"]["statstate"] = "bad"
	data["occupant"]["health"] = mob_occupant.health
	data["occupant"]["maxHealth"] = mob_occupant.maxHealth
	data["occupant"]["minHealth"] = HEALTH_THRESHOLD_DEAD
	data["occupant"]["bruteLoss"] = mob_occupant.getBruteLoss()
	data["occupant"]["oxyLoss"] = mob_occupant.getOxyLoss()
	data["occupant"]["toxLoss"] = mob_occupant.getToxLoss()
	data["occupant"]["fireLoss"] = mob_occupant.getFireLoss()
	return data

/obj/machinery/bioscanner/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("startscan")
			if(!is_operational)
				return
			else
				startscan()
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
/obj/machinery/bioscanner/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()

	if(isliving(occupant))
		. = TRUE // Only autoupdate when occupied
