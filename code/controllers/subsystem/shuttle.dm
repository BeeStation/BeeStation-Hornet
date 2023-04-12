#define MAX_TRANSIT_REQUEST_RETRIES 10

SUBSYSTEM_DEF(shuttle)
	name = "Shuttle"
	wait = 10
	init_order = INIT_ORDER_SHUTTLE
	flags = SS_KEEP_TIMING|SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/list/mobile = list()
	var/list/stationary = list()
	var/list/beacons = list()
	var/list/transit = list()

	var/list/transit_requesters = list()
	var/list/transit_request_failures = list()

		//emergency shuttle stuff
	var/obj/docking_port/mobile/emergency/emergency
	var/obj/docking_port/mobile/arrivals/arrivals
	var/obj/docking_port/mobile/emergency/backup/backup_shuttle
	var/emergencyCallTime = 6000	//time taken for emergency shuttle to reach the station when called (in deciseconds)
	var/emergencyDockTime = 1800	//time taken for emergency shuttle to leave again once it has docked (in deciseconds)
	var/emergencyEscapeTime = 1200	//time taken for emergency shuttle to reach a safe distance after leaving station (in deciseconds)
	var/area/emergencyLastCallLoc
	var/emergencyCallAmount = 0		//how many times the escape shuttle was called
	var/emergencyNoEscape			//Hostile environment that prevents the shuttle from leaving after it has arrived
	var/emergencyDelayArrival 		//Infestation that delays the shuttle arrival while contingency plans are put into place
	var/emergencyNoRecall = FALSE
	var/adminEmergencyNoRecall = FALSE
	var/list/hostileEnvironments = list() //Things blocking escape shuttle from leaving
	var/list/infestedEnvironments = list() //Things that can trigger a delay on escape shuttle arrival
	var/infestationActive = FALSE //So unusual circumstances can't trigger a second infestation warning and delay
	var/hostileEnvTrackPlayed = FALSE
	var/list/tradeBlockade = list() //Things blocking cargo from leaving.
	var/supplyBlocked = FALSE

		//supply shuttle stuff
	var/obj/docking_port/mobile/supply/supply
	var/centcom_message = ""			//Remarks from CentCom on how well you checked the last order.
	var/list/discoveredPlants = list()	//Typepaths for unusual plants we've already sent CentCom, associated with their potencies

	var/list/hidden_shuttle_turfs = list() //all turfs hidden from navigation computers associated with a list containing the image hiding them and the type of the turf they are pretending to be
	var/list/hidden_shuttle_turf_images = list() //only the images from the above list

	var/datum/round_event/shuttle_loan/shuttle_loan

	var/shuttle_purchased = FALSE //If the station has purchased a replacement escape shuttle this round
	var/list/shuttle_purchase_requirements_met = list() //For keeping track of ingame events that would unlock new shuttles, such as defeating a boss or discovering a secret item

	var/lockdown = FALSE	//disallow transit after nuke goes off

	var/datum/map_template/shuttle/selected

	var/obj/docking_port/mobile/existing_shuttle

	var/datum/map_template/shuttle/preview_template

	var/obj/docking_port/mobile/preview_shuttle

	var/datum/turf_reservation/preview_reservation

	var/shuttles_loaded = FALSE

/datum/controller/subsystem/shuttle/Initialize(timeofday)
	initial_load()

	if(!arrivals)
		WARNING("No /obj/docking_port/mobile/arrivals placed on the map!")
	if(!emergency)
		WARNING("No /obj/docking_port/mobile/emergency placed on the map!")
	if(!backup_shuttle)
		WARNING("No /obj/docking_port/mobile/emergency/backup placed on the map!")
	if(!supply)
		WARNING("No /obj/docking_port/mobile/supply placed on the map!")
	return ..()

/datum/controller/subsystem/shuttle/proc/initial_load()
	shuttles_loaded = TRUE
	for(var/s in stationary)
		var/obj/docking_port/stationary/S = s
		S.load_roundstart()
		CHECK_TICK

/datum/controller/subsystem/shuttle/fire()
	for(var/thing in mobile)
		if(!thing)
			mobile.Remove(thing)
			continue
		var/obj/docking_port/mobile/P = thing
		P.check()
	for(var/thing in transit)
		var/obj/docking_port/stationary/transit/T = thing
		if(!T.owner)
			qdel(T, force=TRUE)
		// This next one removes transit docks/zones that aren't
		// immediately being used. This will mean that the zone creation
		// code will be running a lot.
		var/obj/docking_port/mobile/owner = T.owner
		if(owner)
			var/idle = owner.mode == SHUTTLE_IDLE
			var/not_centcom_evac = owner.launch_status == NOLAUNCH
			var/not_in_use = (!T.docked)
			if(idle && not_centcom_evac && not_in_use)
				qdel(T, force=TRUE)
	CheckAutoEvac()

	if(!SSmapping.clearing_reserved_turfs)
		while(transit_requesters.len)
			var/requester = popleft(transit_requesters)
			var/success = generate_transit_dock(requester)
			if(!success) // BACK OF THE QUEUE
				transit_request_failures[requester]++
				if(transit_request_failures[requester] < MAX_TRANSIT_REQUEST_RETRIES)
					transit_requesters += requester
				else
					var/obj/docking_port/mobile/M = requester
					M.transit_failure()
			if(MC_TICK_CHECK)
				break

/datum/controller/subsystem/shuttle/proc/CheckAutoEvac()
	if(emergencyNoEscape || emergencyNoRecall || !emergency || !SSticker.HasRoundStarted())
		return

	var/threshold = CONFIG_GET(number/emergency_shuttle_autocall_threshold)
	if(!threshold)
		return

	var/alive = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			++alive

	var/total = GLOB.joined_player_list.len
	if(total <= 0)
		return //no players no autoevac

	if(alive / total <= threshold)
		var/msg = "Automatically dispatching emergency shuttle due to crew death."
		message_admins(msg)
		log_game("[msg] Alive: [alive], Roundstart: [total], Threshold: [threshold]")
		emergencyNoRecall = TRUE
		priority_announce("Catastrophic casualties detected: crisis shuttle protocols activated - jamming recall signals across all frequencies.", sound = SSstation.announcer.get_rand_alert_sound())
		if(emergency.timeLeft(1) > emergencyCallTime * 0.4)
			emergency.request(null, set_coefficient = 0.4)

/datum/controller/subsystem/shuttle/proc/block_recall(lockout_timer)
	emergencyNoRecall = TRUE
	addtimer(CALLBACK(src, PROC_REF(unblock_recall)), lockout_timer)

/datum/controller/subsystem/shuttle/proc/unblock_recall()
	emergencyNoRecall = FALSE

/datum/controller/subsystem/shuttle/proc/getShuttle(id)
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.id == id)
			return M
	WARNING("couldn't find shuttle with id: [id]")

/datum/controller/subsystem/shuttle/proc/getDock(id)
	for(var/obj/docking_port/stationary/S in stationary)
		if(S.id == id)
			return S
	WARNING("couldn't find dock with id: [id]")

/// Check if we can call the evac shuttle.
/// Returns TRUE if we can. Otherwise, returns a string detailing the problem.
/datum/controller/subsystem/shuttle/proc/canEvac(mob/user)
	var/srd = CONFIG_GET(number/shuttle_refuel_delay)
	if(world.time - SSticker.round_start_time < srd)
		return "The emergency shuttle is refueling. Please wait [DisplayTimeText(srd - (world.time - SSticker.round_start_time))] before attempting to call."

	switch(emergency.mode)
		if(SHUTTLE_RECALL)
			return "The emergency shuttle may not be called while returning to CentCom."
		if(SHUTTLE_CALL)
			return "The emergency shuttle is already on its way."
		if(SHUTTLE_DOCKED)
			return "The emergency shuttle is already here."
		if(SHUTTLE_IGNITING)
			return "The emergency shuttle is firing its engines to leave."
		if(SHUTTLE_ESCAPE)
			return "The emergency shuttle is moving away to a safe distance."
		if(SHUTTLE_STRANDED)
			return "The emergency shuttle has been disabled by CentCom."

	return TRUE

/datum/controller/subsystem/shuttle/proc/requestEvac(mob/user, call_reason)
	if(!emergency)
		WARNING("requestEvac(): There is no emergency shuttle, but the \
			shuttle was called. Using the backup shuttle instead.")
		if(!backup_shuttle)
			CRASH("requestEvac(): There is no emergency shuttle, \
			or backup shuttle! The game will be unresolvable. This is \
			possibly a mapping error, more likely a bug with the shuttle \
			manipulation system, or badminry. It is possible to manually \
			resolve this problem by loading an emergency shuttle template \
			manually, and then calling register() on the mobile docking port. \
			Good luck.")
		emergency = backup_shuttle

	var/can_evac_or_fail_reason = SSshuttle.canEvac(user)
	if(can_evac_or_fail_reason != TRUE)
		to_chat(user, "<span class='alert'>[can_evac_or_fail_reason]</span>")
		return

	call_reason = trim(html_encode(call_reason))

	if(length(call_reason) < CALL_SHUTTLE_REASON_LENGTH && seclevel2num(get_security_level()) > SEC_LEVEL_GREEN)
		to_chat(user, "<span class='alert'>You must provide a reason.</span>")
		return

	var/area/signal_origin = get_area(user)
	var/emergency_reason = "\nNature of emergency:\n\n[call_reason]"
	var/security_num = seclevel2num(get_security_level())
	switch(security_num)
		if(SEC_LEVEL_RED,SEC_LEVEL_DELTA)
			emergency.request(null, signal_origin, html_decode(emergency_reason), 1) //There is a serious threat we gotta move no time to give them five minutes.
		else
			emergency.request(null, signal_origin, html_decode(emergency_reason), 0)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

	if(!frequency)
		return

	var/datum/signal/status_signal = new(list("command" = "update")) // Start processing shuttle-mode displays to display the timer
	frequency.post_signal(src, status_signal)

	log_game("[user ? key_name(user) : "An automated system"] has called the shuttle.")
	if(user)
		var/area/A = get_area(user)
		deadchat_broadcast("<span class='deadsay'><span class='name'>[user.real_name]</span> has called the shuttle at <span class='name'>[A.name]</span>.</span>", user)
	if(call_reason)
		SSblackbox.record_feedback("text", "shuttle_reason", 1, "[call_reason]")
		log_game("Shuttle call reason: [call_reason]")
	message_admins("[user ? ADMIN_LOOKUPFLW(user) : "An automated system"] has called the shuttle. (<A HREF='?_src_=holder;[HrefToken()];trigger_centcom_recall=1'>TRIGGER CENTCOM RECALL</A>)")

/datum/controller/subsystem/shuttle/proc/centcom_recall(old_timer, admiral_message)
	if(emergency.mode != SHUTTLE_CALL || emergency.timer != old_timer)
		return
	emergency.cancel()

	if(!admiral_message)
		admiral_message = pick(GLOB.admiral_messages)
	var/intercepttext = "<font size = 3><b>Nanotrasen Update</b>: Request For Shuttle.</font><hr>\
						To whom it may concern:<br><br>\
						We have taken note of the situation upon [station_name()] and have come to the \
						conclusion that it does not warrant the abandonment of the station.<br>\
						If you do not agree with our opinion we suggest that you open a direct \
						line with us and explain the nature of your crisis.<br><br>\
						<i>This message has been automatically generated based upon readings from long \
						range diagnostic tools. To assure the quality of your request every finalized report \
						is reviewed by an on-call rear admiral.<br>\
						<b>Rear Admiral's Notes:</b> \
						[admiral_message]"
	print_command_report(intercepttext, announce = TRUE)

// Called when an emergency shuttle mobile docking port is
// destroyed, which will only happen with admin intervention
/datum/controller/subsystem/shuttle/proc/emergencyDeregister()
	// When a new emergency shuttle is created, it will override the
	// backup shuttle.
	src.emergency = src.backup_shuttle

/datum/controller/subsystem/shuttle/proc/cancelEvac(mob/user)
	if(canRecall())
		emergency.cancel(get_area(user))
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[ADMIN_LOOKUPFLW(user)] has recalled the shuttle.")
		deadchat_broadcast("<span class='deadsay'><span class='name'>[user.real_name]</span> has recalled the shuttle from <span class='name'>[get_area_name(user, TRUE)]</span>.</span>", user)
		return 1

/datum/controller/subsystem/shuttle/proc/canRecall()
	if(!emergency || emergency.mode != SHUTTLE_CALL || emergencyNoRecall || SSticker.mode.name == "meteor")
		return
	var/security_num = seclevel2num(get_security_level())
	switch(security_num)
		if(SEC_LEVEL_GREEN)
			if(emergency.timeLeft(1) < emergencyCallTime)
				return
		if(SEC_LEVEL_BLUE)
			if(emergency.timeLeft(1) < emergencyCallTime * 0.5)
				return
		else
			if(emergency.timeLeft(1) < emergencyCallTime * 0.25)
				return
	return 1

/datum/controller/subsystem/shuttle/proc/autoEvac()
	if (!SSticker.IsRoundInProgress())
		return

	var/callShuttle = 1

	for(var/thing in GLOB.shuttle_caller_list)
		if(isAI(thing))
			var/mob/living/silicon/ai/AI = thing
			if(AI.deployed_shell && !AI.deployed_shell.client)
				continue
			if(AI.stat || !AI.client)
				continue
		else if(istype(thing, /obj/machinery/computer/communications))
			var/obj/machinery/computer/communications/C = thing
			if(C.machine_stat & BROKEN)
				continue

		var/turf/T = get_turf(thing)
		if(T && is_station_level(T.z))
			callShuttle = 0
			break

	if(callShuttle)
		if(EMERGENCY_IDLE_OR_RECALLED)
			emergency.request(null, set_coefficient = 2.5)
			log_game("There is no means of calling the shuttle anymore. Shuttle automatically called.")
			message_admins("All the communications consoles were destroyed and all AIs are inactive. Shuttle called.")

/datum/controller/subsystem/shuttle/proc/registerHostileEnvironment(datum/bad)
	hostileEnvironments[bad] = TRUE
	checkHostileEnvironment()

/datum/controller/subsystem/shuttle/proc/clearHostileEnvironment(datum/bad)
	hostileEnvironments -= bad
	checkHostileEnvironment()

/datum/controller/subsystem/shuttle/proc/registerInfestation(datum/bad)
	infestedEnvironments[bad] = TRUE //This only matters when shuttle is at a specific stage in evacuation, there is no need to update or check the validity of the list every time it is updated

/datum/controller/subsystem/shuttle/proc/clearInfestation(datum/bad)
	infestedEnvironments -= bad

/datum/controller/subsystem/shuttle/proc/registerTradeBlockade(datum/bad)
	tradeBlockade[bad] = TRUE
	checkTradeBlockade()

/datum/controller/subsystem/shuttle/proc/clearTradeBlockade(datum/bad)
	tradeBlockade -= bad
	checkTradeBlockade()


/datum/controller/subsystem/shuttle/proc/checkTradeBlockade()
	for(var/datum/d in tradeBlockade)
		if(!istype(d) || QDELETED(d))
			tradeBlockade -= d
	supplyBlocked = tradeBlockade.len

	if(supplyBlocked && (supply.mode == SHUTTLE_IGNITING))
		supply.mode = SHUTTLE_STRANDED
		supply.timer = null
		//Make all cargo consoles speak up
	if(!supplyBlocked && (supply.mode == SHUTTLE_STRANDED))
		supply.mode = SHUTTLE_DOCKED
		//Make all cargo consoles speak up

/datum/controller/subsystem/shuttle/proc/checkHostileEnvironment()
	for(var/datum/d in hostileEnvironments)
		if(!istype(d) || QDELETED(d))
			hostileEnvironments -= d
	emergencyNoEscape = hostileEnvironments.len

	if(emergencyNoEscape && (emergency.mode == SHUTTLE_IGNITING))
		emergency.mode = SHUTTLE_STRANDED
		emergency.timer = null
		emergency.sound_played = FALSE
		priority_announce("Hostile environment detected. \
			Departure has been postponed indefinitely pending \
			conflict resolution.", null, 'sound/misc/notice1.ogg', "Priority")
	if(!emergencyNoEscape && (emergency.mode == SHUTTLE_STRANDED))
		emergency.mode = SHUTTLE_DOCKED
		emergency.setTimer(emergencyDockTime)
		priority_announce("Hostile environment resolved. \
			You have 3 minutes to board the Emergency Shuttle.",
			null, ANNOUNCER_SHUTTLEDOCK, "Priority")

/datum/controller/subsystem/shuttle/proc/checkInfestedEnvironment()
	for(var/mob/d in infestedEnvironments)
		var/turf/T = get_turf(d)
		if(QDELETED(d) || !is_station_level(T.z)) //If they have been destroyed or left the station Z level, the queen will not trigger this check
			infestedEnvironments -= d
	emergencyDelayArrival = length(infestedEnvironments)
	return emergencyDelayArrival

/datum/controller/subsystem/shuttle/proc/delayForInfestedStation()
	if(infestationActive)
		return
	infestationActive = TRUE
	emergencyNoRecall = TRUE
	priority_announce("Xenomorph infestation detected: crisis shuttle protocols activated - jamming recall signals across all frequencies.")
	play_soundtrack_music(/datum/soundtrack_song/bee/mind_crawler)
	if(EMERGENCY_IDLE_OR_RECALLED)
		emergency.request(null, set_coefficient=1) //If a shuttle wasn't already called, call one now, with 10 minute delay
	else if(emergency.mode == SHUTTLE_CALL)
		emergency.setTimer(10 MINUTES) //If shuttle was already in transit, delay the arrival time to 10 minutes
		//If the emergency shuttle has already passed the point of no return before a queen existed, do not delay round for Xenomorphs - they spawned too late on a round that was already coming to an end.

//try to move/request to dockHome if possible, otherwise dockAway. Mainly used for admin buttons
/datum/controller/subsystem/shuttle/proc/toggleShuttle(shuttleId, dockHome, dockAway, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	if(!M)
		return 1
	var/obj/docking_port/stationary/dockedAt = M.docked
	var/destination = dockHome
	if(dockedAt && dockedAt.id == dockHome)
		destination = dockAway
	if(timed)
		if(M.request(getDock(destination)))
			return 2
	else
		if(M.initiate_docking(getDock(destination)) != DOCKING_SUCCESS)
			return 2
	return 0	//dock successful


/datum/controller/subsystem/shuttle/proc/moveShuttle(shuttleId, dockId, timed)
	var/obj/docking_port/mobile/M = getShuttle(shuttleId)
	var/obj/docking_port/stationary/D = getDock(dockId)

	if(!M)
		return 1
	if(timed)
		if(M.request(D))
			return 2
	else
		if(M.initiate_docking(D) != DOCKING_SUCCESS)
			return 2
	return 0	//dock successful

/datum/controller/subsystem/shuttle/proc/request_transit_dock(obj/docking_port/mobile/M)
	if(!istype(M))
		CRASH("[M] is not a mobile docking port")

	if(M.assigned_transit)
		return
	else
		if(!(M in transit_requesters))
			transit_requesters += M

/datum/controller/subsystem/shuttle/proc/generate_transit_dock(obj/docking_port/mobile/M)
	// First, determine the size of the needed zone
	// Because of shuttle rotation, the "width" of the shuttle is not
	// always x.
	var/travel_dir = M.preferred_direction
	// Remember, the direction is the direction we appear to be
	// coming from
	var/dock_angle = dir2angle(M.preferred_direction) + dir2angle(M.port_direction) + 180
	var/dock_dir = angle2dir(dock_angle)

	var/transit_width = SHUTTLE_TRANSIT_BORDER * 2
	var/transit_height = SHUTTLE_TRANSIT_BORDER * 2

	// Shuttles travelling on their side have their dimensions swapped
	// from our perspective
	var/list/union_coords = M.return_union_coords(M.get_all_towed_shuttles(), 0, 0, dock_dir)
	transit_width += union_coords[3] - union_coords[1] + 1
	transit_height += union_coords[4] - union_coords[2] + 1

/*
	to_chat(world, "The attempted transit dock will be [transit_width] width, and \)
		[transit_height] in height. The travel dir is [travel_dir]."
*/

	var/transit_path = /turf/open/space/transit
	switch(travel_dir)
		if(NORTH)
			transit_path = /turf/open/space/transit/north
		if(SOUTH)
			transit_path = /turf/open/space/transit/south
		if(EAST)
			transit_path = /turf/open/space/transit/east
		if(WEST)
			transit_path = /turf/open/space/transit/west

	var/datum/turf_reservation/proposal = SSmapping.RequestBlockReservation(transit_width, transit_height, null, /datum/turf_reservation/transit, transit_path)

	if(!istype(proposal))
		return FALSE

	var/turf/bottomleft = locate(proposal.bottom_left_coords[1], proposal.bottom_left_coords[2], proposal.bottom_left_coords[3])
	// Then create a transit docking port in the middle
	// union coords (1,2) points from the docking port to the bottom left corner of the bounding box
	// So if we negate those coordinates, we get the vector pointing from the bottom left of the bounding box to the docking port
	var/transit_x = bottomleft.x + SHUTTLE_TRANSIT_BORDER + abs(union_coords[1])
	var/transit_y = bottomleft.y + SHUTTLE_TRANSIT_BORDER + abs(union_coords[2])

	var/turf/midpoint = locate(transit_x, transit_y, bottomleft.z)
	if(!midpoint)
		return FALSE
	var/area/shuttle/transit/A = new()
	A.parallax_movedir = travel_dir
	A.contents = proposal.reserved_turfs
	var/obj/docking_port/stationary/transit/new_transit_dock = new(midpoint)
	new_transit_dock.reserved_area = proposal
	new_transit_dock.name = "Transit for [M.id]/[M.name]"
	new_transit_dock.owner = M
	new_transit_dock.assigned_area = A

	// Add 180, because ports point inwards, rather than outwards
	new_transit_dock.setDir(angle2dir(dock_angle))

	M.assigned_transit = new_transit_dock
	return new_transit_dock

/datum/controller/subsystem/shuttle/Recover()
	initialized = SSshuttle.initialized
	if (istype(SSshuttle.mobile))
		mobile = SSshuttle.mobile
	if (istype(SSshuttle.stationary))
		stationary = SSshuttle.stationary
	if (istype(SSshuttle.transit))
		transit = SSshuttle.transit
	if (istype(SSshuttle.transit_requesters))
		transit_requesters = SSshuttle.transit_requesters
	if (istype(SSshuttle.transit_request_failures))
		transit_request_failures = SSshuttle.transit_request_failures

	if (istype(SSshuttle.emergency))
		emergency = SSshuttle.emergency
	if (istype(SSshuttle.arrivals))
		arrivals = SSshuttle.arrivals
	if (istype(SSshuttle.backup_shuttle))
		backup_shuttle = SSshuttle.backup_shuttle

	if (istype(SSshuttle.emergencyLastCallLoc))
		emergencyLastCallLoc = SSshuttle.emergencyLastCallLoc

	if (istype(SSshuttle.hostileEnvironments))
		hostileEnvironments = SSshuttle.hostileEnvironments

	if (istype(SSshuttle.supply))
		supply = SSshuttle.supply

	if (istype(SSshuttle.discoveredPlants))
		discoveredPlants = SSshuttle.discoveredPlants

	if (istype(SSshuttle.shuttle_loan))
		shuttle_loan = SSshuttle.shuttle_loan

	if (istype(SSshuttle.shuttle_purchase_requirements_met))
		shuttle_purchase_requirements_met = SSshuttle.shuttle_purchase_requirements_met

	centcom_message = SSshuttle.centcom_message
	emergencyNoEscape = SSshuttle.emergencyNoEscape
	emergencyCallAmount = SSshuttle.emergencyCallAmount
	shuttle_purchased = SSshuttle.shuttle_purchased
	lockdown = SSshuttle.lockdown

	selected = SSshuttle.selected

	existing_shuttle = SSshuttle.existing_shuttle

	preview_template = SSshuttle.preview_template

	preview_reservation = SSshuttle.preview_reservation

/datum/controller/subsystem/shuttle/proc/is_in_shuttle_bounds(atom/A)
	var/area/current = get_area(A)
	if(istype(current, /area/shuttle) && !istype(current, /area/shuttle/transit))
		return TRUE
	for(var/obj/docking_port/mobile/M in mobile)
		if(M.is_in_shuttle_bounds(A))
			return TRUE

/datum/controller/subsystem/shuttle/proc/get_containing_shuttle(atom/A)
	var/list/mobile_cache = mobile
	for(var/i in 1 to mobile_cache.len)
		var/obj/docking_port/port = mobile_cache[i]
		if(port.is_in_shuttle_bounds(A))
			return port

/datum/controller/subsystem/shuttle/proc/get_containing_dock(atom/A)
	. = list()
	var/list/stationary_cache = stationary
	for(var/i in 1 to stationary_cache.len)
		var/obj/docking_port/port = stationary_cache[i]
		if(port.is_in_shuttle_bounds(A))
			. += port

/datum/controller/subsystem/shuttle/proc/get_dock_overlap(x0, y0, x1, y1, z)
	. = list()
	var/list/stationary_cache = stationary
	for(var/i in 1 to stationary_cache.len)
		var/obj/docking_port/port = stationary_cache[i]
		if(!port || port.z != z)
			continue
		var/list/bounds = port.return_coords()
		var/list/overlap = get_overlap(x0, y0, x1, y1, bounds[1], bounds[2], bounds[3], bounds[4])
		var/list/xs = overlap[1]
		var/list/ys = overlap[2]
		if(xs.len && ys.len)
			.[port] = overlap

/datum/controller/subsystem/shuttle/proc/update_hidden_docking_ports(list/remove_turfs, list/add_turfs)
	var/list/remove_images = list()
	var/list/add_images = list()

	if(remove_turfs)
		for(var/T in remove_turfs)
			var/list/L = hidden_shuttle_turfs[T]
			if(L)
				remove_images += L[1]
		hidden_shuttle_turfs -= remove_turfs

	if(add_turfs)
		for(var/V in add_turfs)
			var/turf/T = V
			var/image/I
			if(remove_images.len)
				//we can just reuse any images we are about to delete instead of making new ones
				I = remove_images[1]
				remove_images.Cut(1, 2)
				I.loc = T
			else
				I = image(loc = T)
				add_images += I
			I.appearance = T.appearance
			I.override = TRUE
			hidden_shuttle_turfs[T] = list(I, T.type)

	hidden_shuttle_turf_images -= remove_images
	hidden_shuttle_turf_images += add_images

	for(var/V in GLOB.navigation_computers)
		var/obj/machinery/computer/shuttle_flight/C = V
		C.update_hidden_docking_ports(remove_images, add_images)

	QDEL_LIST(remove_images)


/datum/controller/subsystem/shuttle/proc/action_load(datum/map_template/shuttle/loading_template, obj/docking_port/stationary/destination_port, datum/variable_ref/loaded_shuttle_reference)
	if (!loaded_shuttle_reference)
		loaded_shuttle_reference = new()
	var/datum/map_generator/shuttle_loader = load_template(loading_template, loaded_shuttle_reference)
	shuttle_loader.on_completion(CALLBACK(src, PROC_REF(linkup_shuttle_after_load), loading_template, destination_port, loaded_shuttle_reference))
	shuttle_loader.on_completion(CALLBACK(src, PROC_REF(action_load_completed), destination_port, loaded_shuttle_reference))
	preview_template = loading_template
	return shuttle_loader

/datum/controller/subsystem/shuttle/proc/linkup_shuttle_after_load(datum/map_template/shuttle/loading_template, obj/docking_port/stationary/destination_port, datum/variable_ref/shuttle_reference)
	var/obj/docking_port/mobile/loaded_shuttle = shuttle_reference.value
	loaded_shuttle.linkup(loading_template, destination_port)

/datum/controller/subsystem/shuttle/proc/action_load_completed(obj/docking_port/stationary/destination_port, datum/variable_ref/shuttle_reference)
	var/obj/docking_port/mobile/loaded_shuttle = shuttle_reference.value
	// get the existing shuttle information, if any
	var/timer = 0
	var/mode = SHUTTLE_IDLE
	var/obj/docking_port/stationary/D

	if(istype(destination_port))
		D = destination_port
	else if(existing_shuttle)
		timer = existing_shuttle.timer
		mode = existing_shuttle.mode
		D = existing_shuttle.docked

	if(!D)
		D = generate_transit_dock(loaded_shuttle)

	if(!D)
		CRASH("No dock found for preview shuttle ([preview_template.name]), aborting.")

	var/result = loaded_shuttle.canDock(D)
	// truthy value means that it cannot dock for some reason
	// but we can ignore the someone else docked error because we'll
	// be moving into their place shortly
	if((result != SHUTTLE_CAN_DOCK) && (result != SHUTTLE_SOMEONE_ELSE_DOCKED))
		WARNING("Template shuttle [loaded_shuttle] cannot dock at [D] ([result]).")
		return

	if(existing_shuttle)
		existing_shuttle.jumpToNullSpace()

	var/list/force_memory = loaded_shuttle.movement_force
	loaded_shuttle.movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	loaded_shuttle.initiate_docking(D)
	loaded_shuttle.movement_force = force_memory

	. = loaded_shuttle

	// Shuttle state involves a mode and a timer based on world.time, so
	// plugging the existing shuttles old values in works fine.
	loaded_shuttle.timer = timer
	loaded_shuttle.mode = mode

	loaded_shuttle.register()

	loaded_shuttle.reset_air()

	// TODO indicate to the user that success happened, rather than just
	// blanking the modification tab
	preview_template = null
	existing_shuttle = null
	selected = null
	QDEL_NULL(preview_reservation)

/datum/controller/subsystem/shuttle/proc/load_template(datum/map_template/shuttle/S, datum/variable_ref/shuttle_reference)
	. = FALSE
	// load shuttle template, centred at shuttle import landmark,
	preview_reservation = SSmapping.RequestBlockReservation(S.width, S.height, SSmapping.transit.z_value, /datum/turf_reservation/transit)
	if(!preview_reservation)
		CRASH("failed to reserve an area for shuttle template loading")
	var/turf/BL = TURF_FROM_COORDS_LIST(preview_reservation.bottom_left_coords)
	var/datum/map_generator/shuttle_loader = S.load(BL, FALSE, TRUE, TRUE, FALSE)
	shuttle_loader.on_completion(CALLBACK(src, PROC_REF(template_loaded), S, BL, shuttle_reference))
	return shuttle_loader

/// Template loaded completed.
/// Parameters preceeded by _ are discarded and not used.
/datum/controller/subsystem/shuttle/proc/template_loaded(datum/map_template/shuttle/S, turf/BL, datum/variable_ref/shuttle_reference)
	var/affected = S.get_affected_turfs(BL, centered=FALSE)

	var/found = 0
	// Search the turfs for docking ports
	// - We need to find the mobile docking port because that is the heart of
	//   the shuttle.
	// - We need to check that no additional ports have slipped in from the
	//   template, because that causes unintended behaviour.
	for(var/T in affected)
		for(var/obj/docking_port/mobile/P in T)
			if(!P.docked)
				found++
				if(found > 1)
					qdel(P, force=TRUE)
					log_world("Map warning: Shuttle Template [S.mappath] has multiple mobile docking ports.")
				else
					shuttle_reference.value = P
	if(!found)
		var/msg = "load_template(): Shuttle Template [S.mappath] has no mobile docking port. Aborting import."
		for(var/T in affected)
			var/turf/T0 = T
			T0.empty()

		message_admins(msg)
		WARNING(msg)
		return
	//Everything fine
	S.post_load(shuttle_reference.value)
	return TRUE

/datum/controller/subsystem/shuttle/proc/unload_preview()
	if(preview_shuttle)
		preview_shuttle.jumpToNullSpace()
	preview_shuttle = null


/datum/controller/subsystem/shuttle/ui_state(mob/user)
	return GLOB.admin_state

/datum/controller/subsystem/shuttle/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleManipulator")
		ui.set_autoupdate(TRUE)
		ui.open()


/datum/controller/subsystem/shuttle/ui_data(mob/user)
	var/list/data = list()
	data["tabs"] = list("Status", "Templates", "Modification")

	// Templates panel
	data["templates"] = list()
	var/list/templates = data["templates"]
	data["templates_tabs"] = list()
	data["selected"] = list()

	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

		if(!templates[S.port_id])
			data["templates_tabs"] += S.port_id
			templates[S.port_id] = list(
				"port_id" = S.port_id,
				"templates" = list())

		var/list/L = list()
		L["name"] = S.name
		L["shuttle_id"] = S.shuttle_id
		L["port_id"] = S.port_id
		L["description"] = S.description
		L["admin_notes"] = S.admin_notes

		if(selected == S)
			data["selected"] = L

		templates[S.port_id]["templates"] += list(L)

	data["templates_tabs"] = sort_list(data["templates_tabs"])

	data["existing_shuttle"] = null

	// Status panel
	data["shuttles"] = list()
	for(var/i in mobile)
		var/obj/docking_port/mobile/M = i
		var/timeleft = M.timeLeft(1)
		var/list/L = list()
		L["name"] = M.name
		L["id"] = M.id
		L["timer"] = M.timer
		L["timeleft"] = M.getTimerStr()
		if (timeleft > 1 HOURS)
			L["timeleft"] = "Infinity"
		L["can_fast_travel"] = M.timer && timeleft >= 50
		L["can_fly"] = TRUE
		if(istype(M, /obj/docking_port/mobile/emergency))
			L["can_fly"] = FALSE
		else if(!M.destination)
			L["can_fast_travel"] = FALSE
		if (M.mode != SHUTTLE_IDLE)
			L["mode"] = capitalize(M.mode)
		L["status"] = M.getDbgStatusText()
		if(M == existing_shuttle)
			data["existing_shuttle"] = L

		data["shuttles"] += list(L)

	return data

/datum/controller/subsystem/shuttle/ui_act(action, params)
	if(..())
		return

	var/mob/user = usr

	// Preload some common parameters
	var/shuttle_id = params["shuttle_id"]
	var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]

	switch(action)
		if("select_template")
			if(S)
				existing_shuttle = getShuttle(S.port_id)
				selected = S
				. = TRUE
		if("jump_to")
			if(params["type"] == "mobile")
				for(var/i in mobile)
					var/obj/docking_port/mobile/M = i
					if(M.id == params["id"])
						user.forceMove(get_turf(M))
						. = TRUE
						break

		if("fly")
			for(var/i in mobile)
				var/obj/docking_port/mobile/M = i
				if(M.id == params["id"])
					. = TRUE
					M.admin_fly_shuttle(user)
					break

		if("fast_travel")
			for(var/i in mobile)
				var/obj/docking_port/mobile/M = i
				if(M.id == params["id"] && M.timer && M.timeLeft(1) >= 50)
					M.setTimer(50)
					. = TRUE
					message_admins("[key_name_admin(usr)] fast travelled [M]")
					log_admin("[key_name(usr)] fast travelled [M]")
					SSblackbox.record_feedback("text", "shuttle_manipulator", 1, "[M.name]")
					break

		if("preview")
			if(S)
				. = TRUE
				unload_preview()
				var/datum/variable_ref/loaded_shuttle_reference = new()
				var/datum/map_generator/shuttle_loader = load_template(S, loaded_shuttle_reference)
				shuttle_loader.on_completion(CALLBACK(src, PROC_REF(jump_to_preview), user, loaded_shuttle_reference))
				preview_template = S
		if("load")
			if(existing_shuttle == backup_shuttle)
				// TODO make the load button disabled
				WARNING("The shuttle that the selected shuttle will replace \
					is the backup shuttle. Backup shuttle is required to be \
					intact for round sanity.")
			else if(S)
				. = TRUE
				// If successful, returns the mobile docking port
				var/datum/variable_ref/loaded_shuttle_reference = new()
				var/datum/map_generator/shuttle_loader = action_load(S, null, loaded_shuttle_reference)
				shuttle_loader.on_completion(CALLBACK(src, PROC_REF(shuttle_manipulator_on_load), user, loaded_shuttle_reference))

/datum/controller/subsystem/shuttle/proc/shuttle_manipulator_on_load(mob/user, datum/variable_ref/loaded_shuttle_reference)
	var/obj/docking_port/mobile/mdp = loaded_shuttle_reference.value
	if(mdp)
		user.forceMove(get_turf(mdp))
		message_admins("[key_name_admin(usr)] loaded [mdp] with the shuttle manipulator.")
		log_admin("[key_name(usr)] loaded [mdp] with the shuttle manipulator.</span>")
		SSblackbox.record_feedback("text", "shuttle_manipulator", 1, "[mdp.name]")

/datum/controller/subsystem/shuttle/proc/jump_to_preview(mob/user, datum/variable_ref/loaded_shuttle_reference)
	var/obj/docking_port/mobile/loaded_shuttle = loaded_shuttle_reference.value
	preview_shuttle = loaded_shuttle_reference.value
	if(loaded_shuttle)
		user.forceMove(get_turf(loaded_shuttle))
