/obj/machinery/sleep_console
	name = "sleeper console"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "console"
	density = FALSE

/obj/machinery/sleeper
	name = "sleeper"
	desc = "An enclosed machine used to stabilize and heal patients."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = FALSE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/sleeper

	var/efficiency = 1
	var/min_health = -25
	var/list/available_chems
	var/controls_inside = FALSE
	var/list/possible_chems = list(
		list(/datum/reagent/medicine/epinephrine, /datum/reagent/medicine/morphine, /datum/reagent/medicine/perfluorodecalin, /datum/reagent/medicine/bicaridine, /datum/reagent/medicine/kelotane),
		list(/datum/reagent/medicine/oculine,/datum/reagent/medicine/inacusiate),
		list(/datum/reagent/medicine/antitoxin, /datum/reagent/medicine/mutadone, /datum/reagent/medicine/mannitol, /datum/reagent/medicine/salbutamol, /datum/reagent/medicine/pen_acid),
		list(/datum/reagent/medicine/omnizine)
	)
	var/list/chem_buttons	//Used when emagged to scramble which chem is used, eg: antitoxin -> morphine
	var/scrambled_chems = FALSE //Are chem buttons scrambled? used as a warning
	var/enter_message = "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"
	payment_department = ACCOUNT_MED
	fair_market_price = 5
/obj/machinery/sleeper/Initialize()
	. = ..()
	occupant_typecache = GLOB.typecache_living
	update_icon()
	reset_chem_buttons()

/obj/machinery/sleeper/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	var/I
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		I += M.rating

	efficiency = initial(efficiency)* E
	min_health = initial(min_health) * E
	available_chems = list()
	for(var/i in 1 to I)
		available_chems |= possible_chems[i]
	reset_chem_buttons()

/obj/machinery/sleeper/update_icon()
	if(state_open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/machinery/sleeper/container_resist(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/sleeper/Exited(atom/movable/user)
	if (!state_open && user == occupant)
		container_resist(user)

/obj/machinery/sleeper/relaymove(mob/user)
	if (!state_open)
		container_resist(user)

/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
		..()

/obj/machinery/sleeper/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, "[enter_message]")

/obj/machinery/sleeper/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(is_operational() && occupant)
		open_machine()

/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.stat || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	close_machine(target)

/obj/machinery/sleeper/screwdriver_act(mob/living/user, obj/item/I)
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

/obj/machinery/sleeper/wrench_act(mob/living/user, obj/item/I)
	if(default_change_direction_wrench(user, I))
		return TRUE

/obj/machinery/sleeper/crowbar_act(mob/living/user, obj/item/I)
	if(default_pry_open(I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/sleeper/default_pry_open(obj/item/I) //wew
	. = !(state_open || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open [src].</span>", "<span class='notice'>You pry open [src].</span>")
		open_machine()


/obj/machinery/sleeper/ui_state(mob/user)
	if(controls_inside)
		return GLOB.default_state
	return GLOB.notcontained_state

/obj/machinery/sleeper/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Sleeper")
		ui.open()

/obj/machinery/sleeper/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/sleeper/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click [src] to [state_open ? "close" : "open"] it.</span>"

/obj/machinery/sleeper/process()
	..()
	check_nap_violations()

/obj/machinery/sleeper/nap_violation(mob/violator)
	open_machine()

/obj/machinery/sleeper/ui_data()
	var/list/data = list()
	data["occupied"] = occupant ? 1 : 0
	data["open"] = state_open

	data["chems"] = list()
	for(var/chem in available_chems)
		var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
		data["chems"] += list(list("name" = R.name, "id" = R.type, "allowed" = chem_allowed(chem)))

	data["occupant"] = list()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
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
		data["occupant"]["cloneLoss"] = mob_occupant.getCloneLoss()
		data["occupant"]["brainLoss"] = mob_occupant.getOrganLoss(ORGAN_SLOT_BRAIN)
		data["occupant"]["reagents"] = list()
		if(mob_occupant.reagents && mob_occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
				data["occupant"]["reagents"] += list(list("name" = R.name, "volume" = R.volume))
	return data

/obj/machinery/sleeper/ui_act(action, params)
	if(..())
		return
	var/mob/living/mob_occupant = occupant
	check_nap_violations()
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("inject")
			var/chem = text2path(params["chem"])
			if(!is_operational() || !mob_occupant || isnull(chem))
				return
			if(mob_occupant.health < min_health && chem != /datum/reagent/medicine/epinephrine)
				return
			if(inject_chem(chem, usr))
				. = TRUE
				if(scrambled_chems && prob(5))
					to_chat(usr, "<span class='warning'>Chemical system re-route detected, results may not be as expected!</span>")

/obj/machinery/sleeper/emag_act(mob/user)
	scramble_chem_buttons()
	to_chat(user, "<span class='warning'>You scramble the sleeper's user interface!</span>")

/obj/machinery/sleeper/proc/inject_chem(chem, mob/user)
	if((chem in available_chems) && chem_allowed(chem))
		occupant.reagents.add_reagent(chem_buttons[chem], 10) //emag effect kicks in here so that the "intended" chem is used for all checks, for extra FUUU
		if(user)
			log_combat(user, occupant, "injected [chem] into", addition = "via [src]")
		use_power(100)
		return TRUE

/obj/machinery/sleeper/proc/chem_allowed(chem)
	var/mob/living/mob_occupant = occupant
	if(!mob_occupant || !mob_occupant.reagents)
		return
	var/amount = mob_occupant.reagents.get_reagent_amount(chem) + 10 <= 20 * efficiency
	var/occ_health = mob_occupant.health > min_health || chem == /datum/reagent/medicine/epinephrine
	return amount && occ_health

/obj/machinery/sleeper/proc/reset_chem_buttons()
	scrambled_chems = FALSE
	LAZYINITLIST(chem_buttons)
	for(var/chem in available_chems)
		chem_buttons[chem] = chem

/obj/machinery/sleeper/proc/scramble_chem_buttons()
	scrambled_chems = TRUE
	var/list/av_chem = available_chems.Copy()
	for(var/chem in av_chem)
		chem_buttons[chem] = pick_n_take(av_chem) //no dupes, allow for random buttons to still be correct


/obj/machinery/sleeper/syndie
	icon_state = "sleeper_s"
	controls_inside = TRUE

/obj/machinery/sleeper/syndie/fullupgrade
	circuit = /obj/item/circuitboard/machine/sleeper/fullupgrade

/obj/machinery/sleeper/clockwork
	name = "soothing sleeper"
	desc = "A large cryogenics unit built from brass. Its surface is pleasantly cool the touch."
	icon_state = "sleeper_clockwork"
	enter_message = "<span class='bold inathneq_small'>You hear the gentle hum and click of machinery, and are lulled into a sense of peace.</span>"
	possible_chems = list(list(/datum/reagent/medicine/epinephrine, /datum/reagent/medicine/salbutamol, /datum/reagent/medicine/bicaridine, /datum/reagent/medicine/kelotane, /datum/reagent/medicine/oculine, /datum/reagent/medicine/inacusiate, /datum/reagent/medicine/mannitol))

/obj/machinery/sleeper/old
	icon_state = "oldpod"
