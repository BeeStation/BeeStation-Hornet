// Bioscanners! Stealing code from sleepers since 2545!

/obj/machinery/bioscanner
	name = "Bio-Scanner"
	desc = "An enclosed machine used to scan and diagnose patients."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "bscanner"
	density = FALSE
	circuit = /obj/item/circuitboard/machine/bioscanner

	state_open = TRUE
	clicksound = 'sound/machines/pda_button1.ogg'

	var/scanning
	var/enter_message = "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"

	var/speed_coeff
	var/scan_level
	var/radiation_dose

/obj/machinery/bioscanner/Initialize(mapload)
	. = ..()
	occupant_typecache = GLOB.typecache_living //TODO someone explain to me what this means or does.
	update_appearance()
	RefreshParts()

/obj/machinery/bioscanner/RefreshParts()
	scan_level = 0
	speed_coeff = 1

	// E is scanning level, meaning how good it scans.
	var/E
	for(var/obj/item/stock_parts/scanning_module/B in component_parts)
		E += B.rating
	radiation_dose = 400 / E

	// I is scanning power, meaning how fast it scans
	var/I
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		I += M.rating

	speed_coeff = 1 / I
	ui_update()

/obj/machinery/bioscanner/update_icon_state()
	. = ..()

/obj/machinery/bioscanner/container_resist(mob/living/user)
//	visible_message("<span class='notice'> You hear faint prying noises from inside [src]!</span>",
//		"<span class='notice'> You attempt to pry the door open from the inside! (This will take roughly a minute.)</span>")
//	if(do_after(user, 4 SECONDS, user))
//		visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
//			"<span class='notice'>You climb out of [src]!</span>")
//		open_machine()
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/bioscanner/open_machine()
	if(!state_open && !panel_open && !scanning)
		icon_state = "bscanner"
		..()

/obj/machinery/bioscanner/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(mob_occupant, "[enter_message]")
	ActivityStatus()

/obj/machinery/bioscanner/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(is_operational && occupant)
		open_machine()

/obj/machinery/bioscanner/MouseDrop_T(mob/target, mob/user)
	if(user.stat || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
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
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		return
	return FALSE

/obj/machinery/bioscanner/crowbar_act(mob/living/user, obj/item/I)
	if(default_pry_open(I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/bioscanner/default_pry_open(obj/item/I)
	. = !(state_open || scanning || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open [src].</span>", "<span class='notice'>You pry open [src].</span>")
		open_machine()

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
	ActivityStatus()

/obj/machinery/bioscanner/proc/ActivityStatus() //doing it like this feels so fucking bad. There has to be a more elegant solution than this.
	if(!state_open)
		icon_state= "bscanner_off"

		if(occupant && !state_open)
			icon_state = "bscanner_green"

			if(occupant && !state_open && scanning)
				var/mob/living/mob_occupant = occupant
				switch(mob_occupant.stat)
					if(CONSCIOUS, SOFT_CRIT)
						icon_state = "bscanner_yellow"
					if(UNCONSCIOUS)
						icon_state = "bscanner_red"
					if(DEAD)
						icon_state = "bscanner_death"
	else
		icon_state= "bscanner"

/obj/machinery/bioscanner/proc/startscan(mob/user)
	if(state_open)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 15, FALSE, 0)
		return
	else
		if(!occupant)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 15, FALSE, 0)
			return
		scanning = TRUE
		ActivityStatus()
		visible_message("<span class='notice'> The Bio-Scanner hums to life.</span>")
		playsound(src, 'sound/machines/boop.ogg', 75, FALSE, 0)
		playsound(src, 'sound/machines/capacitor_charge.ogg', 100, TRUE, 2)
		addtimer(CALLBACK(src, PROC_REF(bioscanComplete), user),300*speed_coeff)

/obj/machinery/bioscanner/proc/bioscanComplete()
	scanning = FALSE
	ActivityStatus()
	var/mob/living/mob_occupant = occupant
	mob_occupant.rad_act(rand(radiation_dose/10,radiation_dose))
	visible_message("<span class='notice'> The Bio-Scanner shuts down.</span>")
	playsound(src, 'sound/machines/ping.ogg', 75, FALSE, 0)
	playsound(src, 'sound/machines/capacitor_discharge.ogg', 100, TRUE, 2)

	//when just using mob_occupant.stat on the paper, it always just returns numbers. so we do this instead. sounds more professional too
	var/occupantStatus
	var/occupantColor

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

	//Here we go, the paper, the RESULTS.
	var/obj/item/paper/paperwork = new /obj/item/paper(get_turf(src))
	paperwork.name = "BIOTIC SCAN RESULT: [mob_occupant]."
	paperwork.add_raw_text("
	<i>Station time: [station_time_timestamp()]</i><br>
	<h1>#Biotic Scan Report</h1><br>
	<h2>#Nanotrasen Medical Devision</h2><br>
	<hr />
	<h1>GENERAL</h1><br>
	Name: [mob_occupant]<br>
	Species: [(S.name)][mutant ? "-derived mutant" : ""]<br>
	<b>Status: <font color=[occupantColor]>[occupantStatus]</font></b><br>
	DNA: [H.dna.unique_enzymes]<br>
	Body temperature: [round(mob_occupant.bodytemperature-T0C,0.1)] &deg;C ([round(mob_occupant.bodytemperature*1.8-459.67,0.1)] &deg;F<br>
	<hr />
	")
	paperwork.update_appearance()
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)

/obj/machinery/bioscanner/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/bioscanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Bioscanner", "Biotic Scanning Interface")
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
