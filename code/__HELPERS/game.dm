//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
#define RANGE_TURFS(RADIUS, CENTER) \
  block( \
    locate(max(CENTER.x-(RADIUS),1),          max(CENTER.y-(RADIUS),1),          CENTER.z), \
    locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy), CENTER.z) \
  )

#define RANGE_TURFS_XY(XRADIUS, YRADIUS, CENTER) \
  block( \
    locate(max(CENTER.x-(XRADIUS),1),          max(CENTER.y-(YRADIUS),1),          CENTER.z), \
    locate(min(CENTER.x+(XRADIUS),world.maxx), min(CENTER.y+(YRADIUS),world.maxy), CENTER.z) \
  )

#define Z_TURFS(ZLEVEL) block(locate(1,1,ZLEVEL), locate(world.maxx, world.maxy, ZLEVEL))
#define CULT_POLL_WAIT 2400

/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

//We used to use linear regression to approximate the answer, but Mloc realized this was actually faster.
//And lo and behold, it is, and it's more accurate to boot.
/proc/cheap_hypotenuse(Ax,Ay,Bx,By)
	return sqrt(abs(Ax - Bx)**2 + abs(Ay - By)**2) //A squared + B squared = C squared

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

			if(sight_check && !isInSight(A_tmp, O))
				passed=0

		else if(include_radio && istype(A, /obj/item/radio))
			passed=1

			if(sight_check && !isInSight(A, O))
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
	var/ckey = ckey(key) //just to be safe
	for(var/mob/M as() in GLOB.player_list)
		if(M?.ckey == ckey)
			return M
	return null

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

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_images_from_clients, I, show_to), duration, TIMER_CLIENT_TIME)

/proc/flick_overlay_view(image/I, atom/target, duration) //wrapper for the above, flicks to everyone who can see the target atom
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

/proc/showCandidatePollWindow(mob/M, poll_time, Question, list/candidates, ignore_category, time_passed, flashwindow = TRUE)
	set waitfor = 0

	SEND_SOUND(M, 'sound/misc/notice2.ogg') //Alerting them to their consideration
	if(flashwindow)
		window_flash(M.client)
	switch(ignore_category ? askuser(M,Question,"Please answer in [DisplayTimeText(poll_time)]!","Yes","No","Never for this round", StealFocus=0, Timeout=poll_time) : askuser(M,Question,"Please answer in [DisplayTimeText(poll_time)]!","Yes","No", StealFocus=0, Timeout=poll_time))
		if(1)
			to_chat(M, "<span class='notice'>Choice registered: Yes.</span>")
			if(time_passed + poll_time <= world.time)
				to_chat(M, "<span class='danger'>Sorry, you answered too late to be considered!</span>")
				SEND_SOUND(M, 'sound/machines/buzz-sigh.ogg')
				candidates -= M
			else
				candidates += M
		if(2)
			to_chat(M, "<span class='danger'>Choice registered: No.</span>")
			candidates -= M
		if(3)
			var/list/L = GLOB.poll_ignore[ignore_category]
			if(!L)
				GLOB.poll_ignore[ignore_category] = list()
			GLOB.poll_ignore[ignore_category] += M.ckey
			to_chat(M, "<span class='danger'>Choice registered: Never for this round.</span>")
			candidates -= M
		else
			candidates -= M

/proc/pollGhostCandidates(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, ignore_category = null, flashwindow = TRUE, req_hours = 0)
	var/list/candidates = list()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates

	for(var/mob/dead/observer/G in GLOB.player_list)
		candidates += G

	return pollCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category, flashwindow, candidates, req_hours)

/proc/pollCandidates(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, ignore_category = null, flashwindow = TRUE, list/group = null, req_hours = 0)
	var/time_passed = world.time
	if (!Question)
		Question = "Would you like to be a special role?"
	var/list/result = list()
	for(var/m in group)
		var/mob/M = m
		if(!M.key || !M.client || (ignore_category && GLOB.poll_ignore[ignore_category] && (M.ckey in GLOB.poll_ignore[ignore_category])))
			continue
		if(be_special_flag)
			if(!(M.client.prefs) || !(be_special_flag in M.client.prefs.be_special))
				continue
		if(gametypeCheck)
			if(!gametypeCheck.age_check(M.client))
				continue
		if(jobbanType)
			if(QDELETED(M) || is_banned_from(M.ckey, list(jobbanType, ROLE_SYNDICATE)))
				continue
		if(req_hours) //minimum living hour count
			if((M.client.get_exp_living(TRUE)/60) < req_hours)
				continue

		showCandidatePollWindow(M, poll_time, Question, result, ignore_category, time_passed, flashwindow)
	sleep(poll_time)

	//Check all our candidates, to make sure they didn't log off or get deleted during the wait period.
	for(var/mob/M in result)
		if(!M.key || !M.client)
			result -= M

	listclearnulls(result)

	return result

/proc/pollCandidatesForMob(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, mob/M, ignore_category = null)
	var/list/L = pollGhostCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category)
	if(QDELETED(M) || !M.loc)
		return list()
	return L

/proc/pollCandidatesForMobs(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, list/mobs, ignore_category = null)
	var/list/L = pollGhostCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category)
	var/i=1
	for(var/v in mobs)
		var/atom/A = v
		if(QDELETED(A) || !A.loc)
			mobs.Cut(i,i+1)
		else
			++i
	return L

/proc/poll_helper(var/mob/living/M)

/proc/makeBody(mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)
		return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new//The mob being spawned.
	SSjob.SendToLateJoin(new_character)

	G_found.client.prefs.copy_to(new_character)
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
	if(!C || (!C.prefs.windowflashing && !ignorepref))
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
	if((character.mind.assigned_role == "Cyborg") || (character.mind.assigned_role == character.mind.special_role))
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
	if(pressure <= LAVALAND_EQUIPMENT_EFFECT_PRESSURE)
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
			if (!is_blocked_turf(found_turf))
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
