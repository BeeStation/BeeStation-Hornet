GLOBAL_LIST_EMPTY(servants_of_ratvar)	//List of minds in the cult
GLOBAL_LIST_EMPTY(human_servants_of_ratvar)	//Humans in the cult

GLOBAL_VAR(clockcult_team)

GLOBAL_VAR(ratvar_arrival_tick)	//The world.time that Ratvar will arrive if the gateway is not disrupted

GLOBAL_VAR_INIT(installed_integration_cogs, 0)

GLOBAL_VAR(celestial_gateway)	//The celestial gateway
GLOBAL_VAR_INIT(ratvar_risen, FALSE)	//Has ratvar risen?
GLOBAL_VAR_INIT(gateway_opening, FALSE)	//Is the gateway currently active?

//A useful list containing all scriptures with the index of the name.
//This should only be used for looking up scriptures
GLOBAL_LIST_EMPTY(clockcult_all_scriptures)

//==========================
//===Clock cult Gamemode ===
//==========================

/datum/game_mode/clockcult
	name = "clockcult"
	config_tag = "clockcult"
	report_type = "clockcult"
	false_report_weight = 5
	required_players = 24
	required_enemies = 4
	recommended_enemies = 4
	antag_flag = ROLE_SERVANT_OF_RATVAR
	enemy_minimum_age = 14

	title_icon = "clockcult"

	var/datum/team/clockcult/clockcult_team
	var/clock_cultists = CLOCKCULT_MIN_SERVANTS
	var/list/selected_servants = list()

/datum/game_mode/clockcult/pre_setup()
	//Load Reebe
	var/list/errorList = list()
	var/list/reebe = SSmapping.LoadGroup(errorList, "Reebe", "map_files/generic", "CityOfCogs.dmm", default_traits=ZTRAITS_REEBE, silent=TRUE)
	if(errorList.len)
		message_admins("Reebe failed to load")
		log_game("Reebe failed to load")
		return FALSE
	for(var/datum/parsed_map/map in reebe)
		map.initTemplateBounds()
	//How many cultists?
	var/players = get_active_player_count()
	players = round(players / CLOCKCULT_CREW_PER_CULT)
	players = clamp(players, CLOCKCULT_MIN_SERVANTS, CLOCKCULT_MAX_SERVANTS)
	//Generate cultists
	for(var/i in 1 to players)
		if(!antag_candidates.len)
			break
		var/datum/mind/clockie = antag_pick(antag_candidates, ROLE_SERVANT_OF_RATVAR)
		antag_candidates -= clockie
		selected_servants += clockie
		clockie.assigned_role = ROLE_SERVANT_OF_RATVAR
		clockie.special_role = ROLE_SERVANT_OF_RATVAR
	//Generate clock classes
	var/id = 1
	for(var/class_typepath in subtypesof(/datum/clockcult/servant_class))
		var/datum/clockcult/servant_class/class = new class_typepath()
		class.class_ID = id++
		GLOB.servant_classes[class.class_name] = class
	//Generate scriptures
	for(var/scripture_typepath in typesof(/datum/clockcult/scripture))
		var/datum/clockcult/scripture/S = new scripture_typepath
		GLOB.clockcult_all_scriptures[S.name] = S
	return TRUE

/datum/game_mode/clockcult/post_setup(report)
	var/list/spawns = GLOB.servant_spawns.Copy()
	//Create team
	for(var/datum/mind/servant_mind in selected_servants)
		servant_mind.current.forceMove(pick_n_take(spawns))
		var/datum/antagonist/servant_of_ratvar/S = add_servant_of_ratvar(servant_mind.current)
		S.equip_carbon(servant_mind.current)
		S.equip_servant()
		S.create_team()
	//Setup the conversion limits for auto opening the ark
	calculate_clockcult_values()
	return ..()

/datum/game_mode/clockcult/check_finished(force_ending)
	return FALSE

/datum/game_mode/clockcult/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	if(GLOB.ratvar_risen)
		round_credits += "<center><h1>Ratvar has been released from his prison!</h1>"
	else
		round_credits += "<center><h1>The clock cultists failed to summon Ratvar, he will remain trapped forever to rust!</h1>"
	round_credits += "<center><h1>The Servants of Ratvar:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/operative in GLOB.servants_of_ratvar)
		round_credits += "<center><h2>[operative.name] as a servant of Ratvar!</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The servants were annihilated!</h2>", "<center><h2>Their remains could not be identified!</h2>")
		round_credits += "<br>"

	round_credits += ..()
	return round_credits

/datum/game_mode/proc/update_clockcult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CLOCKWORK]
	culthud.join_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, "clockwork")

/datum/game_mode/proc/update_clockcult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CLOCKWORK]
	culthud.leave_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, null)

//==========================
//==== Clock cult procs ====
//==========================

/proc/is_servant_of_ratvar(mob/living/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/servant_of_ratvar)

//Similar to cultist one, except silicons are allowed
/proc/is_convertable_to_clockcult(mob/living/M)
	if(!istype(M))
		return FALSE
	if(!M.mind)
		return FALSE
	if(ishuman(M) && (M.mind.assigned_role in list("Captain", "Chaplain")))
		return FALSE
	if(is_servant_of_ratvar(M))
		return FALSE
	if(M.mind.enslaved_to && !is_servant_of_ratvar(M.mind.enslaved_to))
		return FALSE
	if(M.mind.unconvertable)
		return FALSE
	if(iscultist(M) || isconstruct(M) || ispAI(M))
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return FALSE
	return TRUE

/proc/flee_reebe(allow_servant_exit = FALSE)
	for(var/mob/living/M in GLOB.mob_list)
		if(!is_reebe(M.z))
			continue
		var/safe_place = find_safe_turf()
		if(is_servant_of_ratvar(M))
			if(!allow_servant_exit)
				continue
		else
			M.SetSleeping(50)
		M.forceMove(safe_place)

//Transmits a message to everyone in the cult
//Doesn't work if the cultists contain holy water, or are not on the station or Reebe
//TODO: SANITIZE MESSAGES WITH THE NORMAL SAY STUFF (punctuation)
/proc/hierophant_message(msg, mob/living/sender, span = "<span class='brass'>", use_sanitisation=TRUE)
	var/hierophant_message = "[span]"
	if(!msg)
		if(sender)
			to_chat(sender, "<span class='brass'>You cannot transmit nothing!</span>")
		return FALSE
	if(use_sanitisation)
		msg = sanitize(msg)
	if(sender)
		sender.say("#[text2ratvar(msg)]")
		hierophant_message += "<b>[sender.name]</b> transmits, \"[msg]\""
	else
		hierophant_message += msg
	if(span)
		hierophant_message += "</span>"
	for(var/mob/M in GLOB.player_list)
		if(isliving(M) && !is_servant_of_ratvar(M))
			continue
		to_chat(M, hierophant_message)

//====================================
//==== Reebe Pressure Calculation (Depreciated :( )) ====
//====================================
//If there was a pressure calculation too recently, the server will wait a few seconds instead
//This makes it so if a bunch of walls are created they will all be processed under the same calc
//This effect is minimal in game, since the cracking of walls has a random delay on it when triggered.
//Assume the servant blockers are the edge of Reebe
//Most of this proc is the queuing system that prevents it from running too often,
//instead it queues itself up with a timer if it needs to update.
//I know, it's a little weird but it prevents spamming this and breaking stuff.
#define REEBE_PRESSURE_CALC_DELAY 50

/proc/calculate_reebe_pressure(called_through_timer = FALSE)
	set waitfor = FALSE
	var/gateway = GLOB.celestial_gateway
	if(!gateway)
		log_runtime("Error, no celestial gateway found. Reebe pressure calculation failed!")
		return
	var/static/next_calculation_time = 0
	var/static/wait_timer
	var/static/was_blocked = TRUE
	if(next_calculation_time > world.time)
		//If we was called through timer, the previous timer expired, so requeue it
		//If not and there is a timer already, we are already queued to update
		if(wait_timer && !called_through_timer)
			return
		wait_timer = addtimer(CALLBACK(GLOBAL_PROC, /proc/calculate_reebe_pressure, TRUE), REEBE_PRESSURE_CALC_DELAY, TIMER_STOPPABLE | TIMER_UNIQUE)
		return
	//Run the actual calculation
	wait_timer = null
	//Send all requests to queue until we are done here.
	next_calculation_time = world.time + INFINITY
	//Find the gateway
	var/gateway_loc = get_turf(gateway)
	if(!gateway_loc)
		log_runtime("Error, celestial gateway has no turf!")
		next_calculation_time = world.time
		return
	//Calculate the Reebe area
	var/list/room = detect_room(gateway_loc, list(/turf/open/indestructible/reebe_void))
	var/pressure_good = FALSE
	//Room must be good if we manage to find reebe_void, otherwise we must check to make sure it is good
	if(!room)
		pressure_good = TRUE
	else
		for(var/turf/T in room)
			for(var/obj/effect/clockwork/servant_blocker/C in T)
				pressure_good = TRUE
				break
			if(pressure_good)
				break
	//Regenerate Reebe
	if(pressure_good)
		//If the walls become good, make every wall on reebe good
		for(var/turf/closed/wall/clockwork/CW in get_area_turfs(/area/reebe/city_of_cogs))
			//Make the walls stronger
			if(CW.reinforced)
				continue
			CW.reinforced = TRUE
			addtimer(CALLBACK(CW, /turf/closed/wall/clockwork.proc/make_reinforced), rand(0, 50))
			CHECK_TICK
		was_blocked = FALSE
		next_calculation_time = world.time + REEBE_PRESSURE_CALC_DELAY
		return
	if(!was_blocked)
		hierophant_message("<b>The Ark has been enclosed causing pressure to build up!</b><br>Walls surrounding the Ark have become much weaker!", null, "<span class='brass'>")
	was_blocked = TRUE
	//Pressure is bad, to prevent exploiting make all walls weak
	for(var/turf/closed/wall/clockwork/CW in get_area_turfs(/area/reebe/city_of_cogs))
		//Make the walls stronger
		if(!CW.reinforced)
			continue
		CW.reinforced = FALSE
		addtimer(CALLBACK(CW, /turf/closed/wall/clockwork.proc/make_weak), rand(0, 80))
		CHECK_TICK
	next_calculation_time = world.time + REEBE_PRESSURE_CALC_DELAY
#undef REEBE_PRESSURE_CALC_DELAY
