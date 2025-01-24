#define CULT_POLL_WAIT 2400

/// 200 proc calls deep and shit breaks, this is a bit lower to give some safety room
#define MAX_PROC_DEPTH 195 // no idea where to put this

/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

//We used to use linear regression to approximate the answer, but Mloc realized this was actually faster.
//And lo and behold, it is, and it's more accurate to boot.
/proc/cheap_hypotenuse(Ax,Ay,Bx,By)
	return sqrt(abs(Ax - Bx)**2 + abs(Ay - By)**2) //A squared + B squared = C squared

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T as() in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A as() in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms

/proc/circlerangeturfs(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T as() in RANGE_TURFS(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr,radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/** recursive_organ_check
  * inputs: O (object to start with)
  * outputs:
  * description: A pseudo-recursive loop based off of the recursive mob check, this check looks for any organs held
  *				 within 'O', toggling their frozen flag. This check excludes items held within other safe organ
  *				 storage units, so that only the lowest level of container dictates whether we do or don't decompose
  */
/proc/recursive_organ_check(atom/O)

	var/list/processing_list = list(O)
	var/list/processed_list = list()
	var/index = 1
	var/obj/item/organ/found_organ

	while(index <= length(processing_list))

		var/atom/A = processing_list[index]

		if(istype(A, /obj/item/organ))
			found_organ = A
			found_organ.organ_flags ^= ORGAN_FROZEN

		else if(istype(A, /mob/living/carbon))
			var/mob/living/carbon/Q = A
			for(var/organ in Q.internal_organs)
				found_organ = organ
				found_organ.organ_flags ^= ORGAN_FROZEN

		for(var/atom/B in A)	//objects held within other objects are added to the processing list, unless that object is something that can hold organs safely
			if(!processed_list[B] && !istype(B, /obj/structure/closet/crate/freezer) && !istype(B, /obj/structure/closet/secure_closet/freezer))
				processing_list+= B

		index++
		processed_list[A] = A

	return

// Better recursive loop, technically sort of not actually recursive cause that shit is stupid, enjoy.
//No need for a recursive limit either
/proc/recursive_mob_check(atom/O,client_check=1,sight_check=1,include_radio=1)

	var/list/processing_list = list(O)
	var/list/processed_list = list()
	var/list/found_mobs = list()

	while(processing_list.len)

		var/atom/A = processing_list[1]
		var/passed = 0

		if(ismob(A))
			var/mob/A_tmp = A
			passed=1

			if(client_check && !A_tmp.client)
				passed=0

			if(sight_check && !is_in_sight(A_tmp, O))
				passed=0

		else if(include_radio && istype(A, /obj/item/radio))
			passed=1

			if(sight_check && !is_in_sight(A, O))
				passed=0

		if(passed)
			found_mobs |= A

		for(var/atom/B in A)
			if(!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

	return found_mobs

/proc/try_move_adjacent(atom/movable/AM)
	var/turf/T = get_turf(AM)
	for(var/direction in GLOB.cardinals)
		if(AM.Move(get_step(T, direction)))
			break

/proc/get_mob_by_ckey(key)
	var/mob_ckey = ckey(key) //just to be safe
	if(!mob_ckey)
		return
	for(var/mob/M as() in GLOB.player_list)
		if(M?.ckey == mob_ckey)
			return M

/proc/get_ckey_last_living(key, healthy = FALSE)
	var/mob_ckey = ckey(key) //just to be safe
	if(!mob_ckey)
		return
	for(var/mob/living/potential_target as() in GLOB.mob_living_list)
		if(QDELETED(potential_target) || (healthy && potential_target.stat))
			continue
		if(potential_target.ckey == mob_ckey || (!length(potential_target.ckey) && ckey(potential_target.mind?.key) == mob_ckey))
			return potential_target

/proc/considered_alive(datum/mind/M, enforce_human = TRUE)
	if(M?.current)
		if(enforce_human)
			var/mob/living/carbon/human/H
			if(ishuman(M.current))
				H = M.current
			return M.current.stat != DEAD && !issilicon(M.current) && !isbrain(M.current) && (!H || H.dna.species.id != "memezombies" && H.dna.species.id != "memezombiesfast")
		else if(isliving(M.current))
			return M.current.stat != DEAD
	return FALSE

/proc/considered_afk(datum/mind/M)
	return !M || !M.current || !M.current.client || M.current.client.is_afk()

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))
		O = new /atom/movable/screen/text()
	O.maptext = MAPTEXT(maptext)
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/// Removes an image from a client's `.images`. Useful as a callback.
/proc/remove_image_from_client(image/image, client/remove_from)
	remove_from?.images -= image

/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I

/// Shows an image to all clients, then removes that image after the duration.
/// If you want an overlay applied to the object which will show to all clients, use
/// flick_overlay_static
/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_images_from_clients), I, show_to), duration, TIMER_CLIENT_TIME)

/// Displays an image to clients that can see a target object.
/proc/flick_overlay_view(image/I, atom/target, duration)
	var/list/viewing = list()
	for(var/mob/M as() in viewers(target))
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, duration)

/proc/get_active_player_count(var/alive_check = 0, var/afk_check = 0, var/human_check = 0)
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/i = 1; i <= GLOB.player_list.len; i++)
		var/mob/M = GLOB.player_list[i]
		if(M && M.client)
			if(alive_check && M.stat)
				continue
			else if(afk_check && M.client.is_afk())
				continue
			else if(human_check && !ishuman(M))
				continue
			else if(isnewplayer(M)) // exclude people in the lobby
				continue
			else if(isobserver(M)) // Ghosts are fine if they were playing once (didn't start as observers)
				var/mob/dead/observer/O = M
				if(O.started_as_observer) // Exclude people who started as observers
					continue
			active_players++
	return active_players

/proc/show_candidate_poll_window(mob/candidate_mob, poll_time, question, list/candidates, ignore_category, time_passed, flashwindow = TRUE)
	set waitfor = 0

	SEND_SOUND(candidate_mob, 'sound/misc/notice2.ogg') //Alerting them to their consideration
	if(flashwindow)
		window_flash(candidate_mob.client)
	var/list/answers = ignore_category ? list("Yes", "No", "Never for this round") : list("Yes", "No")
	switch(tgui_alert(candidate_mob, question, "A limited-time role has appeared!", answers, poll_time, autofocus = FALSE))
		if("Yes")
			to_chat(candidate_mob, "<span class='notice'>Choice registered: Yes.</span>")
			if(time_passed + poll_time <= world.time)
				to_chat(candidate_mob, "<span class='danger'>Sorry, you answered too late to be considered!</span>")
				SEND_SOUND(candidate_mob, 'sound/machines/buzz-sigh.ogg')
				candidates -= candidate_mob
			else
				candidates += candidate_mob
		if("No")
			to_chat(candidate_mob, "<span class='danger'>Choice registered: No.</span>")
			candidates -= candidate_mob
		if("Never for this round")
			var/list/ignore_list = GLOB.poll_ignore[ignore_category]
			if(!ignore_list)
				GLOB.poll_ignore[ignore_category] = list()
			GLOB.poll_ignore[ignore_category] += candidate_mob.ckey
			to_chat(candidate_mob, "<span class='danger'>Choice registered: Never for this round.</span>")
			candidates -= candidate_mob
		else
			candidates -= candidate_mob

/proc/poll_ghost_candidates(question, jobban_type, role_preference_key, poll_time = 30 SECONDS, ignore_category = null, flashwindow = TRUE, req_hours = 0)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates

	for(var/mob/dead/observer/ghost_player in GLOB.player_list)
		candidates += ghost_player

	return poll_candidates(question, jobban_type, role_preference_key, poll_time, ignore_category, flashwindow, candidates, req_hours)

/proc/poll_candidates(question, banning_key, role_preference_key = null, poll_time = 300, poll_ignore_key = null, flashwindow = TRUE, list/group = null, req_hours = 0)
	var/time_passed = world.time
	if (!question)
		question = "Would you like to be a special role?"
	if(isnull(poll_ignore_key)) // FALSE will not put one, no matter what
		if(role_preference_key)
			poll_ignore_key = "role_[role_preference_key]"
		else if(banning_key)
			poll_ignore_key = "ban_[role_preference_key]"
	var/list/result = list()
	for(var/mob/candidate_mob as anything in group)
		if(QDELETED(candidate_mob) || !candidate_mob.key || !candidate_mob.client)
			continue
		if(!candidate_mob.client.should_include_for_role(
			banning_key = banning_key,
			role_preference_key = role_preference_key,
			poll_ignore_key = poll_ignore_key,
			req_hours = req_hours
		))
			continue

		show_candidate_poll_window(candidate_mob, poll_time, question, result, poll_ignore_key, time_passed, flashwindow)
	sleep(poll_time)

	//Check all our candidates, to make sure they didn't log off or get deleted during the wait period.
	for(var/mob/M in result)
		if(!M.key || !M.client)
			result -= M

	list_clear_nulls(result)

	return result

/**
 * Returns a list of ghosts that are eligible to take over and wish to be considered for a mob.
 *
 * Arguments:
 * * question - Question to show players as part of poll
 * * jobban_type - Type of jobban to use to filter out potential candidates.
 * * poll_time - Length of time in deciseconds that the poll input box exists before closing.
 * * target_mob - The mob that is being polled for.
 * * ignore_category - Unknown/needs further documentation.
 */
/proc/poll_candidates_for_mob(question, jobban_type, role_preference_key, poll_time = 30 SECONDS, mob/target_mob, ignore_category = null)
	var/list/possible_candidates = poll_ghost_candidates(question, jobban_type, role_preference_key, poll_time, ignore_category)

	if(QDELETED(target_mob) || !target_mob.loc)
		return list()

	return possible_candidates

/**
 * Returns a list of ghosts that are eligible to take over and wish to be considered for a mob.
 *
 * Arguments:
 * * question - question to show players as part of poll
 * * jobban_type - Type of jobban to use to filter out potential candidates.
 *
 * * poll_time - Length of time in deciseconds that the poll input box exists before closing.
 * * mobs - The list of mobs being polled for. This list is mutated and invalid mobs are removed from it before the proc returns.
 * * ignore_category - The notification preference that hides the prompt.
 */
/proc/poll_candidates_for_mobs(question, jobban_type, role_preference_key, poll_time = 30 SECONDS, list/mobs, ignore_category = null)
	var/list/candidate_list = poll_ghost_candidates(question, jobban_type, role_preference_key, poll_time, ignore_category)

	var/i=1
	for(var/mob/potential_mob as anything in mobs)
		if(QDELETED(potential_mob) || !potential_mob.loc)
			mobs.Cut(i,i+1)
		else
			++i

	return candidate_list

/proc/makeBody(mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)
		return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new//The mob being spawned.
	SSjob.SendToLateJoin(new_character)

	G_found.client.prefs.apply_prefs_to(new_character)
	new_character.dna.update_dna_identity()
	new_character.key = G_found.key

	return new_character

/proc/send_to_playing_players(thing) //sends a whatever to all playing players; use instead of to_chat(world, where needed)
	for(var/M in GLOB.player_list)
		if(M && !isnewplayer(M))
			to_chat(M, thing)

/proc/window_flash(client/C, ignorepref = FALSE)
	if(ismob(C))
		var/mob/M = C
		if(M.client)
			C = M.client
	if(!C || (!C.prefs.read_player_preference(/datum/preference/toggle/window_flashing) && !ignorepref))
		return
	winset(C, "mainwindow", "flash=5")

//Recursively checks if an item is inside a given type, even through layers of storage. Returns the atom if it finds it.
/proc/recursive_loc_check(atom/movable/target, type)
	var/atom/A = target
	if(istype(A, type))
		return A

	while(!istype(A.loc, type))
		if(!A.loc)
			return
		A = A.loc

	return A.loc

/proc/AnnounceArrival(var/mob/living/carbon/human/character, var/rank)
	if(QDELETED(character) || !SSticker.IsRoundInProgress())
		return
	var/area/A = get_area(character)
	var/message = "<span class='game deadsay'><span class='name'>\
		[character.real_name]</span> ([rank]) has arrived at the station at \
		<span class='name'>[A.name]</span>.</span>"
	deadchat_broadcast(message, follow_target = character, message_type=DEADCHAT_ARRIVALRATTLE)
	if((!GLOB.announcement_systems.len) || (!character.mind))
		return
	if((character.mind.assigned_role == JOB_NAME_CYBORG) || (character.mind.assigned_role == character.mind.special_role))
		return

	var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
	announcer.announce("ARRIVAL", character.real_name, rank, list()) //make the list empty to make it announce it in common

/proc/lavaland_equipment_pressure_check(turf/T)
	. = FALSE
	if(!istype(T))
		return
	var/datum/gas_mixture/environment = T.return_air()
	if(!istype(environment))
		return
	var/pressure = environment.return_pressure()
	if(pressure <= MAXIMUM_LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
		. = TRUE

/proc/ispipewire(item)
	var/static/list/pire_wire = list(
		/obj/machinery/atmospherics,
		/obj/structure/disposalpipe,
		/obj/structure/cable
	)
	return (is_type_in_list(item, pire_wire))

// Find a obstruction free turf that's within the range of the center. Can also condition on if it is of a certain area type.
/proc/find_obstruction_free_location(var/range, var/atom/center, var/area/specific_area)
	var/list/possible_loc = list()

	for(var/turf/found_turf as() in RANGE_TURFS(range, center))
		var/area/turf_area = get_area(found_turf)

		// We check if both the turf is a floor, and that it's actually in the area.
		// We also want a location that's clear of any obstructions.
		if (specific_area)
			if (!istype(turf_area, specific_area))
				continue

		if (!isspaceturf(found_turf))
			if (!found_turf.is_blocked_turf())
				possible_loc.Add(found_turf)

	// Need at least one free location.
	if (possible_loc.len < 1)
		return FALSE

	return pick(possible_loc)

/proc/power_fail(duration_min, duration_max)
	for(var/P in GLOB.apcs_list)
		var/obj/machinery/power/apc/C = P
		if(C.cell && SSmapping.level_trait(C.z, ZTRAIT_STATION))
			var/area/A = C.area
			if(GLOB.typecache_powerfailure_safe_areas[A.type])
				continue

			C.energy_fail(rand(duration_min,duration_max))

/**
  * Poll all mentor ghosts for looking for a candidate
  *
  * Poll all mentor ghosts a question
  * returns people who voted yes in a list
  * Arguments:
  * * Question: String, what do you want to ask them
  * * jobbanType: List, Which roles/jobs to exclude from being asked
  * * role_preference_key:
  * * poll_time: Integer, How long to poll for in deciseconds(0.1s)
  * * ignore_category: Define, ignore_category: People with this category(defined in poll_ignore.dm) turned off dont get the message
  * * flashwindow: Bool, Flash their window to grab their attention
  */
/proc/poll_mentor_ghost_candidates(question, jobban_type, role_preference_key, poll_time = 300, ignore_category = null, flashwindow = TRUE)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates

	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.client?.is_mentor())
			candidates += G

	return poll_candidates(question, jobban_type, role_preference_key, poll_time, ignore_category, flashwindow, candidates)

/**
  * Poll mentor ghosts to take control of a mob
  *
  * Poll mentor ghosts for mob control
  * returns people who voted yes in a list
  * Arguments:
  * * Question: String, what do you want to ask them
  * * jobbanType: List, Which roles/jobs to exclude from being asked
  * * role_preference_key: Bool, Only notify ghosts with special antag on
  * * poll_time: Integer, How long to poll for in deciseconds(0.1s)
  * * M: Mob, /mob to offer
  * * ignore_category: Unknown
  */
/proc/pollMentorCandidatesForMob(Question, jobbanType, role_preference_key, poll_time = 300, mob/M, ignore_category = null)
	var/list/L = poll_mentor_ghost_candidates(Question, jobbanType, role_preference_key, poll_time, ignore_category)
	if(!M || QDELETED(M) || !M.loc)
		return list()
	return L

