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
	radiation_dose = 200 / E

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
		icon_state = "bscanner_off"
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(mob_occupant, "[enter_message]")

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

/obj/machinery/bioscanner/default_pry_open(obj/item/I) //wew
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
	statusupdate()

/obj/machinery/bioscanner/proc/statusupdate()
	if(scanning && occupant)
		var/mob/living/mob_occupant = occupant
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				icon_state = "bscanner_green"
			if(SOFT_CRIT)
				icon_state = "bscanner_yellow"
			if(UNCONSCIOUS)
				icon_state = "bscanner_red"
			if(DEAD)
				icon_state = "bscanner_death"

/obj/machinery/bioscanner/proc/startbioscan()
	if(!occupant)
		return

	statusupdate()
	visible_message("<span class='notice'> The Bio-Scanner thrums to life.</span>")
	playsound(src, 'sound/machines/boop.ogg', 75, FALSE, 0)
	playsound(src, 'sound/machines/capacitor_charge.ogg', 100, TRUE, 2)
	addtimer(CALLBACK(src, PROC_REF(statusupdate)),30*speed_coeff)
	bioscanComplete()

/obj/machinery/bioscanner/proc/bioscanComplete()

	var/mob/living/mob_occupant = occupant
	mob_occupant.rad_act(rand(radiation_dose/2,radiation_dose))
	icon_state = "bscanner_off"
	scanning = FALSE
	visible_message("<span class='notice'> The Bio-Scanner shuts down.</span>")
	playsound(src, 'sound/machines/ping.ogg', 75, FALSE, 0)
	playsound(src, 'sound/machines/capacitor_discharge.ogg', 100, TRUE, 2)

/obj/machinery/bioscanner/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/bioscanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Bioscanner")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/bioscanner/ui_data()

/obj/machinery/bioscanner/ui_act(action, params)

/obj/machinery/bioscanner/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()

	if(isliving(occupant))
		. = TRUE // Only autoupdate when occupied
