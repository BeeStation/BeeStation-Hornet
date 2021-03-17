GLOBAL_VAR(battle_royale_map)
GLOBAL_VAR(battle_royale_z)

/datum/battle_royale_controller
	var/list/players
	var/datum/proximity_monitor/advanced/battle_royale/field_wall
	var/radius = 118
	var/process_num = 0
	var/list/death_wall
	var/debug_mode = FALSE
	var/shuttle_position = 30
	//Field Movement
	var/target_radius = 118								//The current target radius
	var/wall_stage = 1									//The current stage of the wall
	var/next_stage_world_time = 0						//The world time we will go to the next stage
	var/radius_increments = list(70, 50, 40, 30, 20, 10)	//The list of wall radii
	var/radius_delays = 	list(3, 4, 5, 6, 7, 10)		//The list of wall delays per stage
	var/between_delays = 	list(600, 300, 300, 300, 300, 1200)//The list of times between changing stages
	var/field_delay = 10								//The current field delay

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
	//Wall handling logic.
	if(radius > target_radius)
		if(process_num % field_delay == 0)
			decrease_wall_size()
		if(radius == target_radius)
			wall_stage ++
			if(wall_stage > length(between_delays))
				next_stage_world_time = INFINITY
				to_chat(world, "<span class='hierosay big'>The field has stopped closing in.</span>")
			else
				next_stage_world_time = world.time + between_delays[wall_stage]
				to_chat(world, "<span class='hierosay big'>The field will begin moving in [DisplayTimeText(next_stage_world_time - world.time)]</span>")
	else if(next_stage_world_time < world.time)
		target_radius = radius_increments[wall_stage]
		field_delay = radius_delays[wall_stage]
		to_chat(world, "<span class='hierosay big'>The field is closing in, get to safety!</span>")
	if(radius < 70 && prob(1))
		generate_endgame_drop()

/datum/battle_royale_controller/proc/decrease_wall_size()
	for(var/obj/effect/death_wall/wall as() in death_wall)
		wall.decrease_size()
		if(QDELETED(wall))
			death_wall -= wall
		CHECK_TICK
	radius--

//==================================
// INITIALIZATION
//==================================

/*
 * Starts battle royale.
 *
 * Parameters:
 *  - check_map (bool) : If true will check if the current map is setup for battle royale before loading. If the server runs battle royale only, set this to true to prevent double loading maps.
 *  - use_world_mobs (bool) : If true instead of clearing mobs and making new mobs, will just use world mobs.
 *  - speed_start (bool) : If true, will not have any delays
 */
/datum/battle_royale_controller/proc/start(check_map = FALSE, use_world_mobs = FALSE, speed_start = FALSE)
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
	if(!speed_start)
		sleep(50)
	//Clear client mobs
	if(use_world_mobs)
		to_chat(world, "<span class='boldannounce'>Battle Royale: Clearing world mobs.</span>")
		for(var/mob/M as() in GLOB.player_list)
			if(isliving(M))
				qdel(M)
			CHECK_TICK
	//Load the map
	to_chat(world, "<span class='boldannounce'>Battle Royale: Loading Map...</span>")
	if(!GLOB.battle_royale_map)
		var/map_needs_loading = FALSE
		//Check and convert other map
		if(!check_map)
			map_needs_loading = TRUE
		else
			if(!LAZYLEN(GLOB.br_spawns))
				map_needs_loading = TRUE
			else if(!LAZYLEN(GLOB.br_lootdrop))
				map_needs_loading = TRUE
			else
				//Map is fine, convert it
				var/target_level = SSmapping.levels_by_trait(ZTRAIT_STATION)
				if(!target_level)
					map_needs_loading = TRUE
				else
					//The station is setup for battle royale, we can use that.
					var/datum/space_level/S = SSmapping.get_level(target_level)
					S.traits |= ZTRAIT_STATION
					GLOB.battle_royale_map = S.z_value
		//Load the map
		if(map_needs_loading)
			var/datum/map_template/battle_royale/template = new('_maps/battle_royale/KiloRoyale.dmm', "Battle Royale Map")
			GLOB.battle_royale_map = template.load_new_z()
			if(!GLOB.battle_royale_map)
				to_chat(world, "<span class='boldannounce'>Battle Royale: Loading map failed!</span>")
				return
	//Wait to start
	if(speed_start)
		sleep(50)
		to_chat(world, "<span class='greenannounce'>Battle Royale: STARTING IN 30 SECONDS.</span>")
		if(!use_world_mobs)
			to_chat(world, "<span class='greenannounce'><i>If you are on the main menu, observe immediately to sign up. (You will be prompted in 30 seconds.)</i></span>")
		toggle_ooc(TRUE)
		sleep(300)
		toggle_ooc(FALSE)
		to_chat(world, "<span class='boldannounce'>Battle Royale: STARTING IN 5 SECONDS.</span>")
		if(!use_world_mobs)
			to_chat(world, "<span class='greenannounce'>Make sure to hit yes to the sign up message given to all observing players.</span>")
		sleep(50)
	to_chat(world, "<span class='boldannounce'>Battle Royale: Starting game.</span>")
	titanfall(use_world_mobs)
	to_chat(world, "<span class='boldannounce'>The ash storm is forming!</span>")
	//Create the death wall.
	death_wall = list()
	var/z_level = GLOB.battle_royale_z
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
	next_stage_world_time = world.time + 4 MINUTES
	START_PROCESSING(SSprocessing, src)

/datum/battle_royale_controller/proc/titanfall(use_world_mobs = FALSE)
	to_chat(world, "<span class='boldannounce'>JUMP OFF THE SHUTTLE TO DEPLOY TO THAT LOCATION.</span>")
	var/list/participants = list()
	if(use_world_mobs)
		participants = GLOB.player_list
	else
		participants = pollGhostCandidates("Would you like to partake in BATTLE ROYALE?")
	players = list()
	for(var/mob/M in participants)
		var/key = M.key
		//Create a mob and transfer their mind to it.
		CHECK_TICK
		var/spawn_pos = pick(GLOB.br_spawns)
		var/turf/T = get_turf(spawn_pos)
		var/mob/living/carbon/human/H
		if(use_world_mobs && !isliving(M))
			continue
		H = new /mob/living/carbon/human/species/battleroyale(T)
		if(use_world_mobs)
			var/mob/living/carbon/human/old_human = M
			H.dna.copy_dna(old_human.dna)
			qdel(old_human)
		ADD_TRAIT(H, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
		H.status_flags = GODMODE
		H.pass_flags |= PASSMOB
		//Battle Royale gang
		H.equipOutfit(/datum/outfit/battle_royale)
		//Give them a spell
		H.key = key
		//Give weapons key
		var/obj/item/implant/weapons_auth/W = new
		W.implant(H)
		players += H
		to_chat(M, "<span class='notice'>You are in the safe zone, you cannot attack here.</span>")
	SEND_SOUND(world, sound('sound/misc/airraid.ogg'))
	to_chat(world, "<span class='boldannounce'>A 30 second grace period has been established. Good luck.</span>")
	to_chat(world, "<span class='boldannounce'>WARNING: YOU WILL BE GIBBED IF YOU LEAVE THE STATION Z-LEVEL OR STAY ON THE SHUTTLE FOR TOO LONG!</span>")
	to_chat(world, "<span class='boldannounce'>[players.len] people remain...</span>")
	//Hide ghosts
	set_observer_default_invisibility(FALSE, "You are hidden by the battle royale")
	//End the grace period
	INVOKE_ASYNC(src, .proc/end_grace)
	//Send the robusting rocket.
	spawn while(move_shuttle_on())
		sleep(10)

/datum/battle_royale_controller/proc/end_grace()
	generate_basic_loot(150)

/datum/battle_royale_controller/proc/move_shuttle_on()
	shuttle_position ++
	var/shuttle_x = shuttle_position
	var/shuttle_y = world.maxy * 0.5
	var/shuttle_drop_min_x = GLOB.shuttle_drop_min_x
	var/shuttle_drop_min_y = GLOB.shuttle_drop_min_y

	if(shuttle_position > world.maxx - 20)
		return FALSE

	for(var/turf/open/shuttle_drop_turf/T as() in GLOB.shuttle_drop_turfs)
		var/offset_x = T.x - shuttle_drop_min_x
		var/offset_y = T.y - shuttle_drop_min_y
		var/target_x = shuttle_x + offset_x
		var/target_y = shuttle_y + offset_y
		if(target_x > world.maxx)
			continue
		var/turf/target_turf = locate(target_x, target_y, T.z)
		T.set_target_turf(target_turf)
		CHECK_TICK
	return TRUE
