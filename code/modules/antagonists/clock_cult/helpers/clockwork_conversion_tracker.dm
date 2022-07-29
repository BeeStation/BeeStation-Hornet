//Helps track the living % of the crew that are servants for when opening the ark automatically

GLOBAL_VAR(ark_transport_triggered)

GLOBAL_VAR(critical_servant_count)

GLOBAL_VAR_INIT(conversion_timer_start, 0)

GLOBAL_VAR_INIT(conversion_timer_end, 0)

//If there is a clockcult team (clockcult gamemode), add them to the team
/proc/add_servant_of_ratvar(mob/M, add_team = TRUE, silent=FALSE, servant_type = /datum/antagonist/servant_of_ratvar, datum/team/clock_cult/team = null)
	if(!istype(M))
		return
	if(!silent)
		hierophant_message("<b>[M]</b> has been successfully converted!", span = "<span class='sevtug'>", use_sanitisation=FALSE)
	var/datum/antagonist/servant_of_ratvar/antagdatum = servant_type

	var/servant_count = GLOB.human_servants_of_ratvar.len

	//No ark
	if(!GLOB.celestial_gateway)
		return M.mind.add_antag_datum(antagdatum, team)

	//Servant count is less than 6
	if(servant_count < 6)
		return M.mind.add_antag_datum(antagdatum, team)

	//Begin the conversion timer
	if(!GLOB.conversion_timer_start)
		GLOB.conversion_timer_start = world.time
		send_sound_to_servants(sound('sound/magic/clockwork/scripture_tier_up.ogg'))
		hierophant_message("The boundary space is being torn apart, the celestial gateway's activation sequence can no longer be stopped...'", span="<span class='large_brass'>")

	//Should be 1 when its 6, should be 0 when its critical_servant_count
	var/timer_proportion = 1 - ((servant_count - 6) / GLOB.critical_servant_count)

	GLOB.conversion_timer_end = GLOB.conversion_timer_start + (80 MINUTES) * timer_proportion

	addtimer(CALLBACK(GLOBAL_PROC, /proc/trigger_gateway_activation), max(GLOB.conversion_timer_end - GLOB.conversion_timer_start, 30 SECONDS), TIMER_UNIQUE | TIMER_OVERRIDE)

	if(ishuman(M) && (servant_type == /datum/antagonist/servant_of_ratvar) && GLOB.critical_servant_count)
		hierophant_message("The celestial gateway will open in [DisplayTimeText(max(GLOB.conversion_timer_end - world.time, 0))].", span="<span class='heavy_brass'>")

	return M.mind.add_antag_datum(antagdatum, team)

/proc/remove_servant_of_ratvar(datum/mind/cult_mind, silent, stun)
	if(cult_mind.current)
		var/datum/antagonist/servant_of_ratvar/cult_datum = cult_mind.has_antag_datum(/datum/antagonist/servant_of_ratvar)
		if(!cult_datum)
			return FALSE
		to_chat(cult_mind, "<span class='large_brass'>Never forget th...[text2ratvar("e will of Eng'ine!")]...</span>")
		to_chat(cult_mind, "<span class='warning'>The quiet ticking in the back of your mind slowly fades away...</span>")
		cult_datum.silent = silent
		cult_datum.on_removal()
		cult_mind.special_role = null
		if(stun)
			cult_mind.current.Unconscious(100)
		return TRUE

/proc/calculate_clockcult_values()
	var/playercount = get_active_player_count()
	GLOB.critical_servant_count = round(max((playercount/5)+6,10))

/proc/trigger_gateway_activation()
	if(GLOB.ark_transport_triggered)
		return
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		SEND_SOUND(M.current, 'sound/magic/clockwork/scripture_tier_up.ogg')
	hierophant_message("The Ark's many cogs suddenly whir to life, steam gushing out of its many crevices; it will open in 5 minutes!", null, "<span class='large_brass'>")
	addtimer(CALLBACK(GLOBAL_PROC, .proc/force_open_ark), 3000)
	GLOB.ark_transport_triggered = TRUE
	return TRUE

/proc/force_open_ark()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		log_runtime("Celestial gateway not located.")
		return
	gateway.open_gateway()

/proc/send_sound_to_servants(sound/S)
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		if(M.current.mind)
			SEND_SOUND(M.current, S)
	for(var/mob/dead/observer/O in GLOB.player_list)
		SEND_SOUND(O, S)
