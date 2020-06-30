//Helps track the living % of the crew that are servants for when opening the ark automatically

GLOBAL_VAR(minimum_servant_count)
GLOBAL_VAR(critical_servant_count)

//If there is a clockcult team (clockcult gamemode), add them to the team
/proc/add_servant_of_ratvar(mob/M, add_team = TRUE)
	if(!istype(M))
		return
	var/datum/antagonist/servant_of_ratvar/antagdatum = /datum/antagonist/servant_of_ratvar
	return M.mind.add_antag_datum(antagdatum)

/proc/calculate_clockcult_values()
	var/playercount = get_active_player_count()
	GLOB.minimum_servant_count = round(CLAMP((playercount/12)+4, 6, 12))
	GLOB.critical_servant_count = round(max((playercount/6)+6,10))

/proc/check_ark_status()
	if(!GLOB.critical_servant_count)
		return
	//Cogscarabs will not trigger the gateway to open
	if(GLOB.human_servants_of_ratvar.len < GLOB.critical_servant_count)
		return FALSE
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		SEND_SOUND(M.current, 'sound/magic/clockwork/scripture_tier_up.ogg')
	hierophant_message("The Ark is preparing to open, you will be transported in 5 minutes!", null, "<span class='large_brass'>")
	addtimer(CALLBACK(GLOBAL_PROC, .proc/force_open_ark), 3000)
	return TRUE

/proc/force_open_ark()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		log_runtime("Celestial gateway not located.")
		return
	gateway.open_gateway()
