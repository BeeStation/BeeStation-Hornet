GLOBAL_VAR_INIT(pirates_spawned, FALSE)

#define PIRATE_RESPONSE_NO_PAY "pirate_answer_no_pay"
#define PIRATE_RESPONSE_PAY "pirate_answer_pay"

/proc/send_pirate_threat()
	GLOB.pirates_spawned = TRUE
	var/ship_name = "Space Privateers Association"
	var/payoff_min = 20000
	var/payoff = 0
	var/initial_send_time = world.time
	var/response_max_time = rand(4,7) MINUTES
	priority_announce("Incoming subspace communication. Secure channel opened at all communication consoles.", "Incoming Message", SSstation.announcer.get_rand_report_sound())
	var/datum/comm_message/threat = new
	var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	if(D)
		payoff = max(payoff_min, FLOOR(D.account_balance * 0.80, 1000))
	ship_name = pick(strings(PIRATE_NAMES_FILE, "ship_names"))
	threat.title = "Business proposition"
	threat.content = "Avast, ye scurvy dogs! Our fine ship <i>[ship_name]</i> has come for yer booty. Immediately transfer [payoff] space doubloons from yer Cargo budget or ye'll be walkin' the plank. Don't try and cheat us, make sure it's all tharr!"
	threat.possible_answers = list(
		PIRATE_RESPONSE_PAY = "We'll pay.",
		PIRATE_RESPONSE_NO_PAY = "No way.",
	)
	threat.answer_callback = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pirates_answered), threat, payoff, ship_name, initial_send_time, response_max_time)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_pirates), threat, FALSE), response_max_time)
	SScommunications.send_message(threat,unique = TRUE)

/proc/pirates_answered(datum/comm_message/threat, payoff, ship_name, initial_send_time, response_max_time)
	if(world.time > initial_send_time + response_max_time)
		priority_announce("Too late to beg for mercy!",sender_override = ship_name)
		return
	// Attempted to pay off
	if(threat?.answered == PIRATE_RESPONSE_PAY)
		var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
		if(!D)
			return
		// Check if they can afford it
		if(D.adjust_money(-payoff))
			priority_announce("Thanks for the credits, landlubbers.", sound = SSstation.announcer.get_rand_alert_sound(), sender_override = ship_name)
		else
			priority_announce("Trying to cheat us? You'll regret this!", sound = SSstation.announcer.get_rand_alert_sound(), sender_override = ship_name)
			spawn_pirates(threat, TRUE) // insta-spawn!

/proc/spawn_pirates(datum/comm_message/threat, skip_answer_check)
	// If they paid it off in the meantime, don't spawn pirates
	// If they couldn't afford to pay, don't spawn another - it already spawned (see above)
	// If they selected "No way.", this spawns on the timeout, so we don't want to return for the answer check
	if(!skip_answer_check && threat?.answered == PIRATE_RESPONSE_PAY)
		return

	var/list/candidates = SSpolling.poll_ghost_candidates(
		check_jobban = ROLE_SPACE_PIRATE,
		poll_time = 15 SECONDS,
		role_name_text = "pirate crew",
		alert_pic = /obj/item/stack/sheet/mineral/gold,
	)
	shuffle_inplace(candidates)

	var/datum/map_template/shuttle/pirate/default/ship = new
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Pirate event found no turf to load in")

	var/datum/async_map_generator/template_placer = ship.load(T)
	template_placer.on_completion(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(after_pirate_spawn), ship, candidates))

	priority_announce("Unidentified armed ship detected near the station.", sound = SSstation.announcer.get_rand_alert_sound())

/proc/after_pirate_spawn(datum/map_template/shuttle/pirate/default/ship, list/candidates, datum/async_map_generator/async_map_generator, turf/T)
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/pirate/spawner in A)
			if(candidates.len > 0)
				var/mob/M = candidates[1]
				spawner.create(M.ckey)
				candidates -= M
				notify_ghosts("The pirate ship has an object of interest: [M]!", source=M, action=NOTIFY_ORBIT, header="Something's Interesting!")
			else
				notify_ghosts("The pirate ship has an object of interest: [spawner]!", source=spawner, action=NOTIFY_ORBIT, header="Something's Interesting!")

//Shuttle equipment

/obj/machinery/shuttle_scrambler
	name = "Data Siphon"
	desc = "This heap of machinery steals credits and data from unprotected systems and locks down cargo shuttles."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = TRUE
	var/active = FALSE
	var/credits_stored = 0
	var/siphon_per_tick = 5

/obj/machinery/shuttle_scrambler/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/shuttle_scrambler/process()
	if(active)
		if(is_station_level(z))
			var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
			if(D)
				var/siphoned = min(D.account_balance,siphon_per_tick)
				D.adjust_money(-siphoned)
				credits_stored += siphoned
			interrupt_research()
		else
			return
	else
		STOP_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/proc/toggle_on(mob/user)
	SSshuttle.registerTradeBlockade(src)
	AddComponent(/datum/component/gps, "Nautical Signal")
	active = TRUE
	to_chat(user,span_notice("You toggle [src] [active ? "on":"off"]."))
	to_chat(user,span_warning("The scrambling signal can be now tracked by GPS."))
	START_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/interact(mob/user)
	if(!active)
		if(alert(user, "Turning the scrambler on will make the shuttle trackable by GPS. Are you sure you want to do it?", "Scrambler", "Yes", "Cancel") != "Yes")
			return
		if(active || !user.canUseTopic(src, BE_CLOSE))
			return
		toggle_on(user)
		update_icon()
		send_notification()
	else
		dump_loot(user)

//interrupt_research
/obj/machinery/shuttle_scrambler/proc/interrupt_research()
	for(var/obj/machinery/rnd/server/S in GLOB.machines)
		if(S.machine_stat & (NOPOWER|BROKEN))
			continue
		S.emp_act(1)
		new /obj/effect/temp_visual/emp(get_turf(S))

/obj/machinery/shuttle_scrambler/proc/dump_loot(mob/user)
	if(credits_stored)	// Prevents spamming empty holochips
		new /obj/item/holochip(drop_location(), credits_stored)
		to_chat(user,span_notice("You retrieve the siphoned credits!"))
		credits_stored = 0
	else
		to_chat(user,span_notice("There's nothing to withdraw."))

/obj/machinery/shuttle_scrambler/proc/send_notification()
	priority_announce("Data theft signal detected, source registered on local gps units.", sound = SSstation.announcer.get_rand_alert_sound())

/obj/machinery/shuttle_scrambler/proc/toggle_off(mob/user)
	SSshuttle.clearTradeBlockade(src)
	active = FALSE
	STOP_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/update_icon()
	if(active)
		icon_state = "dominator-blue"
	else
		icon_state = "dominator"

/obj/machinery/shuttle_scrambler/Destroy()
	toggle_off()
	return ..()

/obj/machinery/computer/shuttle_flight/pirate
	name = "pirate shuttle console"
	shuttleId = "pirateship"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	possible_destinations = "pirateship_away;pirateship_home;pirateship_custom"

/obj/docking_port/mobile/pirate
	name = "pirate shuttle"
	id = "pirateship"
	rechargeTime = 3 MINUTES

/obj/machinery/suit_storage_unit/pirate
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/oxygen

/obj/machinery/loot_locator
	name = "Booty Locator"
	desc = "This sophisticated machine scans the nearby space for items of value."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	var/cooldown = 300
	var/next_use = 0

/obj/machinery/loot_locator/interact(mob/user)
	if(world.time <= next_use)
		to_chat(user,span_warning("[src] is recharging."))
		return
	next_use = world.time + cooldown
	var/atom/movable/AM = find_random_loot()
	if(!AM)
		say("No valuables located. Try again later.")
	else
		say("Located: [AM.name] at [get_area_name(AM)]")

/obj/machinery/loot_locator/proc/find_random_loot()
	if(!GLOB.exports_list.len)
		setupExports()
	var/list/possible_loot = list()
	for(var/datum/export/pirate/E in GLOB.exports_list)
		possible_loot += E
	var/datum/export/pirate/P
	var/atom/movable/AM
	while(!AM && possible_loot.len)
		P = pick_n_take(possible_loot)
		AM = P.find_loot()
	return AM

//Pad & Pad Terminal
/obj/machinery/piratepad
	name = "cargo hold pad"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle-off"
	///This is the icon_state that this telepad uses when it's not in use.
	var/idle_state = "lpad-idle-off"
	///This is the icon_state that this telepad uses when it's warming up for goods teleportation.
	var/warmup_state = "lpad-idle"
	///This is the icon_state to flick when the goods are being sent off by the telepad.
	var/sending_state = "lpad-beam"
	///This is the cargo hold ID used by the piratepad_control. Match these two to link them together.
	var/cargo_hold_id

REGISTER_BUFFER_HANDLER(/obj/machinery/piratepad)

DEFINE_BUFFER_HANDLER(/obj/machinery/piratepad)
	if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, span_notice("You register [src] in [buffer_parent]'s buffer."))
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/piratepad/screwdriver_act_secondary(mob/living/user, obj/item/screwdriver/screw)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "lpad-idle-open", "lpad-idle-off", screw)

/obj/machinery/piratepad/crowbar_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	default_deconstruction_crowbar(tool)
	return TRUE

/obj/machinery/computer/piratepad_control
	name = "cargo hold control terminal"
	///Message to display on the TGUI window.
	var/status_report = "Ready for delivery."
	///Reference to the specific pad that the control computer is linked up to.
	var/datum/weakref/pad_ref
	///How long does it take to warmup the pad to teleport?
	var/warmup_time = 100
	///Is the teleport pad/computer sending something right now? TRUE/FALSE
	var/sending = FALSE
	///For the purposes of space pirates, how many points does the control pad have collected.
	var/points = 0
	///Reference to the export report totaling all sent objects and mobs.
	var/datum/export_report/total_report
	///Callback holding the sending timer for sending the goods after a delay.
	var/sending_timer
	///This is the cargo hold ID used by the piratepad machine. Match these two to link them together.
	var/cargo_hold_id
	///Interface name for the ui_interact call for different subtypes.
	var/interface_type = "CargoHoldTerminal"
	///Typecache of things that shouldn't be sold and shouldn't have their contents sold.
	var/static/list/nosell_typecache

/obj/machinery/computer/piratepad_control/Initialize(mapload)
	..()
	if(isnull(nosell_typecache))
		nosell_typecache = typecacheof(/mob/living/silicon/robot)
	return INITIALIZE_HINT_LATELOAD

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/piratepad_control)

DEFINE_BUFFER_HANDLER(/obj/machinery/computer/piratepad_control)
	if (istype(buffer,/obj/machinery/piratepad))
		to_chat(user, span_notice("You link [src] with [buffer] in [buffer_parent] buffer."))
		pad_ref = WEAKREF(buffer)
		ui_update()
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/computer/piratepad_control/LateInitialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/P in GLOB.machines)
			if(P.cargo_hold_id == cargo_hold_id)
				pad_ref = WEAKREF(P)
				return
	else
		var/obj/machinery/piratepad/pad = locate() in range(4, src)
		pad_ref = WEAKREF(pad)


/obj/machinery/computer/piratepad_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, interface_type, name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/piratepad_control/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["pad"] = pad_ref?.resolve() ? TRUE : FALSE
	data["sending"] = sending
	data["status_report"] = status_report
	return data

/obj/machinery/computer/piratepad_control/ui_act(action, params)
	if(..())
		return
	if(!pad_ref?.resolve())
		return

	switch(action)
		if("recalc")
			recalc()
			. = TRUE
		if("send")
			start_sending()
			. = TRUE
		if("stop")
			stop_sending()
			. = TRUE

/// Calculates the predicted value of the items on the pirate pad
/obj/machinery/computer/piratepad_control/proc/recalc()
	if(sending)
		return

	status_report = "Predicted value: "
	var/value = 0
	var/datum/export_report/report = new
	var/obj/machinery/piratepad/pad = pad_ref?.resolve()
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, apply_elastic = FALSE, dry_run = TRUE, external_report = report)

	for(var/datum/export/exported_datum in report.total_amount)
		status_report += exported_datum.total_printout(report,notes = FALSE)
		status_report += " "
		value += report.total_value[exported_datum]

	if(!value)
		status_report += "0"

/// Deletes and sells the item
/obj/machinery/computer/piratepad_control/proc/send()
	if(!sending)
		return

	var/datum/export_report/report = new
	var/obj/machinery/piratepad/pad = pad_ref?.resolve()

	for(var/atom/movable/item_on_pad in get_turf(pad))
		if(item_on_pad == pad)
			continue
		export_item_and_contents(item_on_pad, apply_elastic = FALSE, delete_unsold = FALSE, external_report = report)

	status_report = "Sold: "
	var/value = 0
	for(var/datum/export/exported_datum in report.total_amount)
		var/export_text = exported_datum.total_printout(report,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		status_report += export_text
		status_report += " "
		value += report.total_value[exported_datum]

	if(!total_report)
		total_report = report
	else
		total_report.exported_atoms += report.exported_atoms
		for(var/datum/export/exported_datum in report.total_amount)
			total_report.total_amount[exported_datum] += report.total_amount[exported_datum]
			total_report.total_value[exported_datum] += report.total_value[exported_datum]
		playsound(loc, 'sound/machines/wewewew.ogg', 70, TRUE)

	points += value

	if(!value)
		status_report += "Nothing"

	pad.visible_message(span_notice("[pad] activates!"))
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	sending = FALSE
	ui_update()

/// Prepares to sell the items on the pad
/obj/machinery/computer/piratepad_control/proc/start_sending()
	var/obj/machinery/piratepad/pad = pad_ref?.resolve()
	if(!pad)
		status_report = "No pad detected. Build or link a pad."
		pad.audible_message(span_notice("[pad] beeps."))
		return
	if(pad?.panel_open)
		status_report = "Please screwdrive pad closed to send. "
		pad.audible_message(span_notice("[pad] beeps."))
		return
	if(sending)
		return
	sending = TRUE
	status_report = "Sending... "
	pad.visible_message(span_notice("[pad] starts charging up."))
	pad.icon_state = pad.warmup_state
	sending_timer = addtimer(CALLBACK(src, PROC_REF(send)),warmup_time, TIMER_STOPPABLE)

/// Finishes the sending state of the pad
/obj/machinery/computer/piratepad_control/proc/stop_sending(custom_report)
	if(!sending)
		return
	sending = FALSE
	status_report = "Ready for delivery."
	if(custom_report)
		status_report = custom_report
	var/obj/machinery/piratepad/pad = pad_ref?.resolve()
	pad.icon_state = pad.idle_state
	deltimer(sending_timer)

//Attempts to find the thing on station
/datum/export/pirate/proc/find_loot()
	return

/datum/export/pirate/ransom
	cost = 3000
	unit_name = "hostage"
	export_types = list(/mob/living/carbon/human)

/datum/export/pirate/ransom/find_loot()
	var/list/head_minds = SSjob.get_living_heads()
	var/list/head_mobs = list()
	for(var/datum/mind/M as anything in head_minds)
		head_mobs += M.current
	if(head_mobs.len)
		return pick(head_mobs)

/datum/export/pirate/ransom/get_cost(atom/movable/AM)
	var/mob/living/carbon/human/ransomee = AM
	if(ransomee.stat != CONSCIOUS || !ransomee.mind) //mint condition only
		return 0
	else if(FACTION_PIRATE in ransomee.faction) //can't ransom your fellow pirates to CentCom!
		return 0
	else if(ransomee.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND))
		return 3000
	else
		return 1000

/datum/export/pirate/parrot
	cost = 2000
	unit_name = "alive parrot"
	export_types = list(/mob/living/simple_animal/parrot)

/datum/export/pirate/parrot/find_loot()
	for(var/mob/living/simple_animal/parrot/current_parrot in GLOB.alive_mob_list)
		var/turf/parrot_turf = get_turf(current_parrot)
		if(parrot_turf && is_station_level(parrot_turf.z))
			return current_parrot

/datum/export/pirate/cash
	cost = 1
	unit_name = "bills"
	export_types = list(/obj/item/stack/spacecash)

/datum/export/pirate/cash/get_amount(obj/exported_item)
	var/obj/item/stack/spacecash/cash = exported_item
	return ..() * cash.amount * cash.value

/datum/export/pirate/holochip
	cost = 1
	unit_name = "holochip"
	export_types = list(/obj/item/holochip)

/datum/export/pirate/holochip/get_cost(atom/movable/exported_item)
	var/obj/item/holochip/chip = exported_item
	return chip.credits

#undef PIRATE_RESPONSE_NO_PAY
#undef PIRATE_RESPONSE_PAY
