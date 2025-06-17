GLOBAL_VAR_INIT(pirates_spawned, FALSE)

// Pirates threat
/// No way
#define PIRATE_RESPONSE_NO_PAY "pirate_answer_no_pay"
/// We'll pay
#define PIRATE_RESPONSE_PAY "pirate_answer_pay"

/datum/round_event_control/pirates
	name = "Space Pirates"
	typepath = /datum/round_event/pirates
	weight = 10
	max_occurrences = 1
	min_players = 20
	dynamic_should_hijack = TRUE
	gamemode_blacklist = list("nuclear")
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event_control/pirates/preRunEvent()
	if (!SSmapping.empty_space)
		return EVENT_CANT_RUN
	return ..()

/datum/round_event/pirates/start()
	if(!GLOB.pirates_spawned)
		send_pirate_threat()

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

	var/list/candidates = poll_ghost_candidates("Do you wish to be considered for pirate crew?", ROLE_SPACE_PIRATE, /datum/role_preference/midround_ghost/space_pirate, 15 SECONDS)
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
	SSsecurity_level.set_level(SEC_LEVEL_BLACK)

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
	icon_state = "lpad-idle-o"
	var/idle_state = "lpad-idle-o"
	var/warmup_state = "lpad-idle"
	var/sending_state = "lpad-beam"
	var/cargo_hold_id

REGISTER_BUFFER_HANDLER(/obj/machinery/piratepad)

DEFINE_BUFFER_HANDLER(/obj/machinery/piratepad)
	if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, span_notice("You register [src] in [buffer_parent]'s buffer."))
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/computer/piratepad_control
	name = "cargo hold control terminal"


	var/status_report = "Ready for delivery."
	var/obj/machinery/piratepad/pad
	var/warmup_time = 100
	var/sending = FALSE
	var/points = 0
	var/datum/export_report/total_report
	var/sending_timer
	var/cargo_hold_id

/obj/machinery/computer/piratepad_control/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/piratepad_control)

DEFINE_BUFFER_HANDLER(/obj/machinery/computer/piratepad_control)
	if (istype(buffer,/obj/machinery/piratepad))
		to_chat(user, span_notice("You link [src] with [buffer] in [buffer_parent] buffer."))
		set_pad(buffer)
		ui_update()
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/computer/piratepad_control/LateInitialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/P in GLOB.machines)
			if(P.cargo_hold_id == cargo_hold_id)
				set_pad(P)
				return
	else
		set_pad(locate(/obj/machinery/piratepad) in range(4,src))

/obj/machinery/computer/piratepad_control/proc/set_pad(obj/machinery/piratepad/newpad)
	if(pad)
		UnregisterSignal(pad, COMSIG_PARENT_QDELETING)

	pad = newpad

	if(pad)
		RegisterSignal(pad, COMSIG_PARENT_QDELETING, PROC_REF(handle_pad_deletion))

/obj/machinery/computer/piratepad_control/proc/handle_pad_deletion()
	pad = null
	ui_update()


/obj/machinery/computer/piratepad_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/piratepad_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoHoldTerminal")
		ui.open()

/obj/machinery/computer/piratepad_control/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["pad"] = pad ? TRUE : FALSE
	data["sending"] = sending
	data["status_report"] = status_report
	return data

/obj/machinery/computer/piratepad_control/ui_act(action, params)
	if(..())
		return
	if(!pad)
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

/obj/machinery/computer/piratepad_control/proc/recalc()
	if(sending)
		return

	status_report = "Predicted value: "
	var/value = 0
	var/datum/export_report/ex = new
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, EXPORT_PIRATE | EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, dry_run = TRUE, external_report = ex)

	for(var/datum/export/E in ex.total_amount)
		status_report += E.total_printout(ex,notes = FALSE)
		status_report += " "
		value += ex.total_value[E]

	if(!value)
		status_report += "0"

/obj/machinery/computer/piratepad_control/proc/send()
	if(!sending)
		return

	var/datum/export_report/ex = new

	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, EXPORT_PIRATE | EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, delete_unsold = FALSE, external_report = ex)

	status_report = "Sold: "
	var/value = 0
	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		status_report += export_text
		status_report += " "
		value += ex.total_value[E]

	if(!total_report)
		total_report = ex
	else
		total_report.exported_atoms += ex.exported_atoms
		for(var/datum/export/E in ex.total_amount)
			total_report.total_amount[E] += ex.total_amount[E]
			total_report.total_value[E] += ex.total_value[E]

	points += value

	if(!value)
		status_report += "Nothing"

	pad.visible_message(span_notice("[pad] activates!"))
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	sending = FALSE
	ui_update()

/obj/machinery/computer/piratepad_control/proc/start_sending()
	if(sending)
		return
	sending = TRUE
	status_report = "Sending..."
	pad.visible_message(span_notice("[pad] starts charging up."))
	pad.icon_state = pad.warmup_state
	sending_timer = addtimer(CALLBACK(src,PROC_REF(send)),warmup_time, TIMER_STOPPABLE)

/obj/machinery/computer/piratepad_control/proc/stop_sending()
	if(!sending)
		return
	sending = FALSE
	status_report = "Ready for delivery."
	pad.icon_state = pad.idle_state
	deltimer(sending_timer)

/datum/export/pirate
	export_category = EXPORT_PIRATE

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
	for(var/datum/mind/M in head_minds)
		head_mobs += M.current
	if(head_mobs.len)
		return pick(head_mobs)

/datum/export/pirate/ransom/get_cost(atom/movable/AM)
	var/mob/living/carbon/human/H = AM
	if(H.stat != CONSCIOUS || !H.mind || !H.mind.assigned_role) //mint condition only
		return 0
	else if(FACTION_PIRATE in H.faction) //can't ransom your fellow pirates to CentCom!
		return 0
	else
		if(H.mind.assigned_role in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND))
			return 3000
		else
			return 1000

/datum/export/pirate/parrot
	cost = 2000
	unit_name = "alive parrot"
	export_types = list(/mob/living/simple_animal/parrot)

/datum/export/pirate/parrot/find_loot()
	for(var/mob/living/simple_animal/parrot/P in GLOB.alive_mob_list)
		var/turf/T = get_turf(P)
		if(T && is_station_level(T.z))
			return P

/datum/export/pirate/cash
	cost = 1
	unit_name = "bills"
	export_types = list(/obj/item/stack/spacecash)

/datum/export/pirate/cash/get_amount(obj/O)
	var/obj/item/stack/spacecash/C = O
	return ..() * C.amount * C.value

/datum/export/pirate/holochip
	cost = 1
	unit_name = "holochip"
	export_types = list(/obj/item/holochip)

/datum/export/pirate/holochip/get_cost(atom/movable/AM)
	var/obj/item/holochip/H = AM
	return H.credits

#undef PIRATE_RESPONSE_NO_PAY
#undef PIRATE_RESPONSE_PAY
