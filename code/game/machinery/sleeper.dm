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
	obj_flags = BLOCKS_CONSTRUCTION
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/sleeper
	clicksound = 'sound/machines/pda_button1.ogg'

	var/efficiency = 1.25
	var/list/available_chems
	var/controls_inside = FALSE
	/// the maximum amount of chem containers the sleeper can hold. Value can be changed by parts tier and RefreshParts()
	var/max_vials = 6
	/// the list of vials that are in the sleeper. Do not define anything here.
	var/list/inserted_vials = list()
	/// the list of roundstart vials - especially predefined chem bags. (Warning: be careful of heritance when you make subtypes)
	var/list/roundstart_vials = list(
		/obj/item/reagent_containers/chem_bag/oxy_mix
	)
	/// the list of roundstart chems. It will be automatically filled into a chem bag. (Warning: be careful of heritance when you make subtypes)
	var/list/roundstart_chems = list(
		/datum/reagent/medicine/epinephrine = 80,
		/datum/reagent/medicine/morphine = 80,
		/datum/reagent/medicine/bicaridine = 80,
		/datum/reagent/medicine/kelotane = 80,
		/datum/reagent/medicine/antitoxin = 80
	)
	/// If true doesn't consume chems
	var/synthesizing = FALSE
	var/scrambled_chems = FALSE //Are chem buttons scrambled? used as a warning
	var/enter_message = span_notice("<b>You feel cool air surround you. You go numb as your senses turn inward.</b>")
	dept_req_for_free = ACCOUNT_MED_BITFLAG
	fair_market_price = 5

/obj/machinery/sleeper/Initialize(mapload)
	. = ..()
	occupant_typecache = GLOB.typecache_living
	update_appearance()
	RefreshParts()

	//Create roundstart chems
	var/created_vials = 0
	if (mapload)
		// create pre-defined vials first and insert it into sleeper
		for (var/each_vial in roundstart_vials)
			if(created_vials >= max_vials)
				stack_trace("Sleeper attempts to create roundstart chems more than [max_vials]")
				break
			if(!ispath(each_vial, /obj/item/reagent_containers))
				stack_trace("Sleeper attempts to create weird item inside of it: [each_vial]")
				continue
			inserted_vials += new each_vial
			created_vials++
		// and then chemical bag with a single chem will go into sleeper
		for (var/each_chem in roundstart_chems)
			if(created_vials >= max_vials)
				stack_trace("Sleeper attempts to create roundstart chems more than [max_vials]")
				break
			if(!ispath(each_chem, /datum/reagent))
				stack_trace("Sleeper attempts to create not-chemical inside of it: [each_chem]")
				continue
			var/obj/item/reagent_containers/chem_bag/beaker = new(null)
			beaker.reagents.add_reagent(each_chem, roundstart_chems[each_chem])
			var/datum/reagent/main_reagent = beaker.reagents.reagent_list[1]
			beaker.name = "[main_reagent.name] [beaker.name]"
			beaker.label_name = main_reagent.name
			inserted_vials += beaker
			created_vials++

/obj/machinery/sleeper/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	var/I
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		I += M.rating

	max_vials = 5 + E
	efficiency = initial(efficiency) * sqrt(I)
	available_chems = list()

	//Eject chems
	for(var/i in max_vials + 1 to length(inserted_vials))
		var/atom/movable/removed_vial = inserted_vials[i]
		removed_vial.forceMove(loc)
		inserted_vials -= removed_vial

	ui_update()

/obj/machinery/sleeper/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][state_open ? "-open" : ""]"

/obj/machinery/sleeper/attackby(obj/item/I, mob/living/user, params)
	if ((istype(I, /obj/item/reagent_containers/cup) \
		|| istype(I, /obj/item/reagent_containers/chem_bag)) \
		&& !user.combat_mode)
		if (length(inserted_vials) >= max_vials)
			to_chat(user, span_warning("[src] cannot hold any more!"))
			return
		if(!user.transferItemToLoc(I, null))
			return
		user.visible_message(span_notice("[user] inserts \the [I] into \the [src]"), span_notice("You insert \the [I] into \the [src]"))
		inserted_vials += I
		ui_update()
		return
	. = ..()

/obj/machinery/sleeper/on_deconstruction()
	for(var/atom/movable/A as anything in inserted_vials)
		A.forceMove(drop_location())
	return ..()

/obj/machinery/sleeper/container_resist(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/sleeper/Exited(atom/movable/gone, direction)
	. = ..()
	if (!state_open && gone == occupant)
		container_resist(gone)

/obj/machinery/sleeper/relaymove(mob/living/user, direction)
	if (!state_open)
		container_resist(user)

//Note: open_machine and close_machine already ui_update()
/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
		..()

/obj/machinery/sleeper/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(controls_inside)
			ui_interact(mob_occupant)
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(mob_occupant, "[enter_message]")

/obj/machinery/sleeper/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(is_operational && occupant)
		open_machine()


/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !ISADVANCEDTOOLUSER(user))
		return

	close_machine(target)


/obj/machinery/sleeper/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, span_warning("[src] is currently occupied!"))
		return
	if(state_open)
		to_chat(user, span_warning("[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!"))
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
		visible_message(span_notice("[usr] pries open [src]."), span_notice("You pry open [src]."))
		open_machine()


/obj/machinery/sleeper/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()

	if(isliving(occupant))
		. = TRUE // Only autoupdate when occupied

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
	. += span_notice("Alt-click [src] to [state_open ? "close" : "open"] it.")

/obj/machinery/sleeper/process()
	..()
	check_nap_violations()

/obj/machinery/sleeper/nap_violation(mob/violator)
	open_machine()

/obj/machinery/sleeper/ui_data()
	var/list/data = list()
	data["open"] = state_open

	data["max_vials"] = max_vials
	//Display the names of the inserted vials
	data["chems"] = list()
	var/i = 1
	for(var/obj/item/reagent_containers/chem_vial as() in inserted_vials)
		var/chem_name = chem_vial.renamedByPlayer ? chem_vial.name : chem_vial.label_name || chem_vial.name
		data["chems"] += list(list("name" = chem_name, "id" = i, "allowed" = chem_allowed(i), "amount" = chem_vial.reagents?.total_volume || 0))
		i++

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
	data["occupant"]["cloneLoss"] = mob_occupant.getCloneLoss()
	data["occupant"]["brainLoss"] = mob_occupant.getOrganLoss(ORGAN_SLOT_BRAIN)
	data["occupant"]["reagents"] = list()
	if(length(mob_occupant.reagents?.reagent_list))
		for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
			data["occupant"]["reagents"] += list(list("name" = R.name, "volume" = R.volume))
	return data

/obj/machinery/sleeper/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("door")
			check_nap_violations()
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("eject")
			var/chem = params["chem"]
			if(!is_operational || chem < 1 || chem > length(inserted_vials))
				return
			//Eject the canister
			var/atom/movable/removed_vial = inserted_vials[chem]
			removed_vial.forceMove(loc)
			inserted_vials -= removed_vial
			to_chat(usr, span_notice("You eject the [removed_vial] from [src]."))
			. = TRUE
		if("inject")
			check_nap_violations()
			var/chem = params["chem"]
			if(!is_operational || !isliving(occupant) || chem < 1 || chem > length(inserted_vials))
				return
			if(obj_flags & EMAGGED)
				chem = rand(1, length(inserted_vials))
			if(inject_chem(chem, usr))
				. = TRUE
				if(scrambled_chems && prob(5))
					to_chat(usr, span_warning("Chemical system re-route detected, results may not be as expected!"))

/obj/machinery/sleeper/should_emag(mob/user)
	return TRUE

/obj/machinery/sleeper/on_emag(mob/user)
	..()
	scrambled_chems = TRUE
	to_chat(user, span_warning("You scramble the sleeper's internal dispensing systems!"))

/obj/machinery/sleeper/proc/inject_chem(chem, mob/user)
	if(chem_allowed(chem))
		var/obj/item/reagent_containers/stored_vial = inserted_vials[chem]
		if (!synthesizing)
			stored_vial.reagents.trans_to(occupant, 10 / efficiency, efficiency, transfered_by = user)
		else
			stored_vial.reagents.copy_to(occupant, 10)
		if(user)
			playsound(src, pick('sound/items/hypospray.ogg','sound/items/hypospray2.ogg'), 50, TRUE, 2)
			log_combat(user, occupant, "injected [stored_vial.reagents.get_reagent_names()] into", addition = "via [src]", important = FALSE)
		use_power(100)
		return TRUE

/obj/machinery/sleeper/proc/chem_allowed(chem)
	var/mob/living/mob_occupant = occupant
	if(!mob_occupant || !mob_occupant.reagents || chem < 1 || chem > length(inserted_vials))
		return
	var/obj/item/reagent_containers/stored_vial = inserted_vials[chem]
	for (var/datum/reagent/reagent in stored_vial.reagents.reagent_list)
		var/amount = mob_occupant.reagents.get_reagent_amount(reagent.type) + 10 <= 16 * efficiency
		if(!amount)
			return FALSE
	return TRUE

/obj/machinery/sleeper/syndie
	icon_state = "sleeper_s"
	controls_inside = TRUE
	roundstart_vials = list()
	roundstart_chems = list(
		/datum/reagent/medicine/syndicate_nanites = 100,
		/datum/reagent/medicine/omnizine = 100,
		/datum/reagent/medicine/oculine = 100,
		/datum/reagent/medicine/inacusiate = 100,
		/datum/reagent/medicine/mannitol = 100,
		/datum/reagent/medicine/mutadone = 100,
	)
	efficiency = 2.5

/obj/machinery/sleeper/syndie/fullupgrade
	circuit = /obj/item/circuitboard/machine/sleeper/fullupgrade

/obj/machinery/sleeper/clockwork
	name = "soothing sleeper"
	desc = "A large cryogenics unit built from brass. Its surface is pleasantly cool the touch."
	icon_state = "sleeper_clockwork"
	enter_message = span_boldinathneqsmall("You hear the gentle hum and click of machinery, and are lulled into a sense of peace.")
	roundstart_vials = list()
	roundstart_chems = list(
		/datum/reagent/medicine/epinephrine = 200,
		/datum/reagent/medicine/bicaridine = 200,
		/datum/reagent/medicine/kelotane = 200,
		/datum/reagent/medicine/salbutamol = 200,
		/datum/reagent/medicine/oculine = 100,
		/datum/reagent/medicine/inacusiate = 100,
		/datum/reagent/medicine/mannitol = 100)
	synthesizing = TRUE

/obj/machinery/sleeper/old
	icon_state = "oldpod"
