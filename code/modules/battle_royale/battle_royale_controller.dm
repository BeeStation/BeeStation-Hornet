GLOBAL_VAR(battle_royale_map)

/datum/battle_royale_controller
	var/list/players
	var/datum/proximity_monitor/advanced/battle_royale/field_wall
	var/radius = 118
	var/process_num = 0
	var/list/death_wall
	var/field_delay = 15
	var/debug_mode = FALSE
	var/shuttle_position = 30

/datum/battle_royale_controller/Destroy(force, ...)
	QDEL_LIST(death_wall)
	for(var/client/C in GLOB.admins)
		C.remove_verb(BATTLE_ROYALE_AVERBS)
	. = ..()
	GLOB.enter_allowed = TRUE
	world.update_status()
	GLOB.battle_royale = null

//Trigger random events and shit, update the world border
/datum/battle_royale_controller/process()
	process_num++
	//Once every 50 seconds
	if(prob(2))
		generate_basic_loot(5)
	//Once every 100 seconds.
	if(prob(1))
		generate_good_drop()
	var/living_victims = 0
	var/mob/winner
	for(var/mob/living/M as() in players)
		if(QDELETED(M))
			players -= M
			continue
		if(M.stat == DEAD)	//We aren't going to remove them from the list in case they somehow revive.
			continue
		var/turf/T = get_turf(M)
		if(T.x > 128 + radius || T.x < 128 - radius || T.y > 128 + radius || T.y < 128 - radius)
			to_chat(M, "<span class='warning'>You have left the zone!</span>")
			M.gib()
		if(!SSmapping.level_trait(T.z, ZTRAIT_BATTLEROYALE))
			to_chat(M, "<span class='warning'>You have left the z-level!</span>")
			M.gib()
		living_victims++
		winner = M
		CHECK_TICK
	if(living_victims <= 1 && !debug_mode)
		to_chat(world, "<span class='ratvar'><font size=18>VICTORY ROYALE!!</font></span>")
		if(winner)
			winner.client?.process_greentext()
			to_chat(world, "<span class='ratvar'><font size=18>[key_name(winner)] is the winner!</font></span>")
			new /obj/item/melee/supermatter_sword(get_turf(winner))
		qdel(src)
		return
	//Once every 15 seconsd
	// 1,920 seconds (about 32 minutes per game)
	if(process_num % (field_delay) == 0)
		for(var/obj/effect/death_wall/wall as() in death_wall)
			wall.decrease_size()
			if(QDELETED(wall))
				death_wall -= wall
			CHECK_TICK
		radius--
	if(radius < 70 && prob(1))
		generate_endgame_drop()

//==================================
// INITIALIZATION
//==================================

/datum/battle_royale_controller/proc/start()
	//Give Verbs to admins
	for(var/client/C in GLOB.admins)
		if(check_rights_for(C, R_FUN))
			C.add_verb(BATTLE_ROYALE_AVERBS)
	toggle_ooc(FALSE)
	to_chat(world, "<span class='ratvar'><font size=24>Battle Royale will begin soon...</span></span>")
	//Stop new player joining
	GLOB.enter_allowed = FALSE
	world.update_status()
	if(SSticker.current_state < GAME_STATE_PREGAME)
		to_chat(world, "<span class=boldannounce>Battle Royale: Waiting for server to be ready...</span>")
		SSticker.start_immediately = FALSE
		UNTIL(SSticker.current_state >= GAME_STATE_PREGAME)
		to_chat(world, "<span class=boldannounce>Battle Royale: Done!</span>")
	//Delay pre-game if we are in it.
	if(SSticker.current_state == GAME_STATE_PREGAME)
		//Force people to be not ready and start the game
		for(var/mob/dead/new_player/player in GLOB.player_list)
			to_chat(player, "<span class=greenannounce>You have been forced as an observer. When the prompt to join battle royale comes up, press yes. This is normal and you are still in queue to play.</span>")
			player.ready = FALSE
			player.make_me_an_observer(TRUE)
		to_chat(world, "<span class='boldannounce'>Battle Royale: Force-starting game.</span>")
		SSticker.start_immediately = TRUE
	SEND_SOUND(world, sound('sound/misc/server-ready.ogg'))
	sleep(50)
	//Clear client mobs
	to_chat(world, "<span class='boldannounce'>Battle Royale: Clearing world mobs.</span>")
	for(var/mob/M as() in GLOB.player_list)
		if(isliving(M))
			qdel(M)
		CHECK_TICK
	//Load the map
	to_chat(world, "<span class='boldannounce'>Battle Royale: Loading Map...</span>")
	if(!GLOB.battle_royale_map)
		var/list/errorList = list()
		var/list/br_map = SSmapping.LoadGroup(errorList, "Battle Royale World", "battle_royale", "KiloRoyale.dmm", default_traits=ZTRAITS_BATTLE_ROYALE)
		if(errorList.len)
			message_admins("br_map failed to load")
			log_game("br_map failed to load")
			return FALSE
		for(var/datum/parsed_map/map in br_map)
			map.initTemplateBounds()
			GLOB.battle_royale_map = map
	//Wait to start
	sleep(50)
	to_chat(world, "<span class='greenannounce'>Battle Royale: STARTING IN 30 SECONDS.</span>")
	to_chat(world, "<span class='greenannounce'><i>If you are on the main menu, observe immediately to sign up. (You will be prompted in 30 seconds.)</i></span>")
	toggle_ooc(TRUE)
	sleep(300)
	toggle_ooc(FALSE)
	to_chat(world, "<span class='boldannounce'>Battle Royale: STARTING IN 5 SECONDS.</span>")
	to_chat(world, "<span class='greenannounce'>Make sure to hit yes to the sign up message given to all observing players.</span>")
	sleep(50)
	to_chat(world, "<span class='boldannounce'>Battle Royale: Starting game.</span>")
	INVOKE_ASYNC(src, .proc/titanfall)
	sleep(350)	//So people spawn in
	death_wall = list()
	var/z_level = SSmapping.station_start
	var/turf/center = SSmapping.get_station_center()
	var/list/edge_turfs = list()
	edge_turfs += block(locate(12, 12, z_level), locate(244, 12, z_level))			//BOTTOM
	edge_turfs += block(locate(12, 244, z_level), locate(244, 244, z_level))		//TOP
	edge_turfs |= block(locate(12, 12, z_level), locate(12, 244, z_level))			//LEFT
	edge_turfs |= block(locate(244, 12, z_level), locate(244, 244, z_level)) 	//RIGHT
	for(var/turf/T in edge_turfs)
		var/obj/effect/death_wall/DW = new(T)
		DW.set_center(center)
		death_wall += DW
		CHECK_TICK
	START_PROCESSING(SSprocessing, src)

/datum/battle_royale_controller/proc/titanfall()
	var/list/participants = pollGhostCandidates("Would you like to partake in BATTLE ROYALE?")
	players = list()
	for(var/mob/M in participants)
		var/key = M.key
		//Create a mob and transfer their mind to it.
		CHECK_TICK
		var/spawn_pos = pick(GLOB.br_spawns)
		var/mob/living/carbon/human/H = new(get_turf(spawn_pos))
		ADD_TRAIT(H, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
		H.status_flags = GODMODE
		H.pass_flags |= PASSMOB
		//Assistant gang
		H.equipOutfit(/datum/outfit/job/assistant)
		//Give them a spell
		H.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock/slow)
		H.key = key
		//Give weapons key
		var/obj/item/implant/weapons_auth/W = new
		W.implant(H)
		players += H
		to_chat(M, "<span class='notice'>You have been given knock and pacafism for 30 seconds.</span>")
	SEND_SOUND(world, sound('sound/misc/airraid.ogg'))
	to_chat(world, "<span class='boldannounce'>A 30 second grace period has been established. Good luck.</span>")
	to_chat(world, "<span class='boldannounce'>WARNING: YOU WILL BE GIBBED IF YOU LEAVE THE STATION Z-LEVEL!</span>")
	to_chat(world, "<span class='boldannounce'>[players.len] people remain...</span>")
	//Hide ghosts
	set_observer_default_invisibility(TRUE, "You are hidden by the battle royale")
	//End the grace period
	INVOKE_ASYNC(src, .proc/end_grace)
	//Send the robusting rocket.
	while(move_shuttle_on())
		sleep(10)

/datum/battle_royale_controller/proc/end_grace()
	generate_basic_loot(150)

/datum/battle_royale_controller/proc/move_shuttle_on()
	shuttle_position ++
	var/shuttle_x = shuttle_position
	var/shuttle_y = world.maxy * 0.5
	var/shuttle_drop_min_x = GLOB.shuttle_drop_min_x
	var/shuttle_drop_min_y = GLOB.shuttle_drop_min_y

	for(var/turf/open/shuttle_drop_turf/T as() in GLOB.shuttle_drop_turfs)
		var/offset_x = T.x - shuttle_drop_min_x
		var/offset_y = T.y - shuttle_drop_min_y
		var/target_x = shuttle_x + offset_x
		var/target_y = shuttle_y + offset_y
		if(target_x > world.maxx - 20)
			return FALSE
		var/turf/target_turf = locate(target_x, target_y, T.z)
		T.set_target_turf(target_turf)
		CHECK_TICK
	return TRUE
