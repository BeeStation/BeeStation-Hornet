//Global lists so they can be editted by admins
GLOBAL_LIST_INIT(battle_royale_basic_loot, list(
		/obj/item/soap,
		/obj/item/kitchen/knife,
		/obj/item/kitchen/knife/combat,
		/obj/item/kitchen/knife/poison,
		/obj/item/throwing_star,
		/obj/item/syndie_glue,
		/obj/item/book_of_babel,
		/obj/item/card/emag,
		/obj/item/storage/box/emps,
		/obj/item/storage/box/lethalshot,
		/obj/item/storage/box/gorillacubes,
		/obj/item/storage/box/teargas,
		/obj/item/storage/box/security/radio,
		/obj/item/storage/box/medsprays,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/box/syndie_kit/bee_grenades,
		/obj/item/storage/box/syndie_kit/centcom_costume,
		/obj/item/storage/box/syndie_kit/chameleon,
		/obj/item/storage/box/syndie_kit/chemical,
		/obj/item/storage/box/syndie_kit/emp,
		/obj/item/storage/box/syndie_kit/imp_adrenal,
		/obj/item/storage/box/syndie_kit/imp_freedom,
		/obj/item/storage/box/syndie_kit/imp_radio,
		/obj/item/storage/box/syndie_kit/imp_stealth,
		/obj/item/storage/box/syndie_kit/imp_storage,
		/obj/item/storage/box/syndie_kit/imp_uplink,
		/obj/item/storage/box/syndie_kit/origami_bundle,
		/obj/item/storage/box/syndie_kit/throwing_weapons,
		/obj/item/storage/box/syndicate/bundle_A,
		/obj/item/storage/box/syndicate/bundle_B,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/energy/disabler,
		/obj/item/construction/rcd,
		/obj/item/clothing/glasses/chameleon/flashproof,
		/obj/item/clothing/glasses/clockwork/wraith_spectacles,
		/obj/item/clothing/glasses/sunglasses/advanced,
		/obj/item/clothing/glasses/thermal/eyepatch,
		/obj/item/clothing/glasses/thermal/syndi,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor,
		/obj/item/clothing/suit/armor/riot,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/vest/russian_coat,
		/obj/item/clothing/suit/armor/hos/trenchcoat,
		/obj/item/clothing/mask/chameleon,
		/obj/item/clothing/head/centhat,
		/obj/item/clothing/head/crown,
		/obj/item/clothing/head/HoS/syndicate,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/helmet/clockcult,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/head/helmet/sec,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/gloves/combat,
		/obj/item/deployablemine/stun,
		/obj/item/switchblade,
		/obj/item/club/tailclub,
		/obj/item/nullrod/tribal_knife,
		/obj/item/nullrod/fedora,
		/obj/item/nullrod/godhand,
		/obj/item/melee/baton/loaded,
		/obj/item/melee/chainofcommand/tailwhip/kitty,
		/obj/item/melee/classic_baton,
		/obj/item/melee/ghost_sword,
		/obj/item/melee/powerfist,
		/obj/item/storage/firstaid/advanced,
		/obj/item/storage/firstaid/brute,
		/obj/item/storage/firstaid/fire,
		/obj/item/storage/firstaid/medical,
		/obj/item/storage/firstaid/tactical,
		/obj/item/gun/energy/ionrifle/carbine
	))

GLOBAL_LIST_INIT(battle_royale_good_loot, list(
		/obj/item/uplink/nuclear,
		/obj/item/hand_tele,
		/obj/item/gun/ballistic/bow/clockbolt,
		/obj/item/gun/ballistic/rifle/boltaction,
		/obj/item/gun/ballistic/shotgun/doublebarrel,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/ballistic/revolver/mateba,
		/obj/item/gun/ballistic/automatic/c20r,
		/obj/item/ammo_box/magazine/smgm45,
		/obj/item/ammo_box/magazine/pistolm9mm,
		/obj/item/katana,
		/obj/item/melee/transforming/energy/sword,
		/obj/item/twohanded/dualsaber,
		/obj/item/twohanded/fireaxe,
		/obj/item/stack/telecrystal/five,
		/obj/item/stack/telecrystal/twenty,
		/obj/item/clothing/suit/space/hardsuit/syndi
	))

GLOBAL_LIST_INIT(battle_royale_insane_loot, list(
		/obj/item/gun/ballistic/automatic/l6_saw/unrestricted,
		/obj/item/energy_katana,
		/obj/item/clothing/suit/space/hardsuit/shielded/syndi,
		/obj/item/his_grace,
		/obj/mecha/combat/marauder/mauler/loaded,
		/obj/item/guardiancreator/tech,
		/obj/item/twohanded/mjollnir,
		/obj/item/pneumatic_cannon/pie/selfcharge,
	))

GLOBAL_DATUM(battle_royale, /datum/battle_royale_controller)

/client/proc/battle_royale()
	set name = "Battle Royale"
	set category = "Fun"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(GLOB.battle_royale)
		to_chat(src, "<span class='warning'>A game is already in progress!</span>")
		return
	log_admin("[key_name(usr)] HAS TRIGGERED BATTLE ROYALE")
	message_admins("[key_name(usr)] HAS TRIGGERED BATTLE ROYALE")
	GLOB.battle_royale = new()
	GLOB.battle_royale.start()

/datum/battle_royale_controller
	var/list/players
	var/datum/proximity_monitor/advanced/battle_royale/field_wall
	var/process_num = 0
	var/field_delay = 15
	var/field_jumps = 5
	var/debug_mode = FALSE

/datum/battle_royale_controller/Destroy(force, ...)
	. = ..()
	GLOB.enter_allowed = TRUE
	world.update_status()

//Trigger random events and shit, update the world border
/datum/battle_royale_controller/process()
	process_num ++
	//Once every 50 seconds
	if(prob(2))
		generate_basic_loot(2)
	//Once every 300 seconds
	if(prob(0.333))
		generate_good_drop()
	var/living_victims = 0
	var/winner
	for(var/mob/living/M in players)
		if(QDELETED(M))
			players -= M
			continue
		if(M.x > 128 + field_wall.current_range + 1 && M.x < 128 - field_wall.current_range - 1 && M.y > 128 + field_wall.current_range + 1 && M.y < 128 - field_wall.current_range - 1)
			M.gib()
		if(!SSmapping.level_trait(M.z, ZTRAIT_STATION) && !SSmapping.level_trait(M.z, ZTRAIT_RESERVED))
			to_chat(M, "<span class='warning'>You have left the z-level!</span>")
			M.gib()
		if(M.stat != DEAD)
			living_victims ++
			winner = M
		CHECK_TICK
	if(living_victims <= 1 && !debug_mode)
		if(winner)
			to_chat(world, "<span class='ratvar'><font size=18>[key_name(winner)] is the winner!</font></span>")
			new /obj/item/melee/supermatter_sword(get_turf(winner))
		qdel(src)
		return
	//Once every 15 seconsd
	// 1,920 seconds (about 32 minutes per game)
	if(process_num % (field_delay * field_jumps) == 0)
		field_wall.current_range -= field_jumps
		field_wall.recalculate_field(TRUE)
	if(process_num > 1000 && prob(0.5))
		generate_endgame_drop()

//==================================
// INITIALIZATION
//==================================

/datum/battle_royale_controller/proc/start()
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
	//Delay pre-game if we are in it
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
	for(var/mob/M as anything in GLOB.player_list)
		if(isliving(M))
			qdel(M)
		CHECK_TICK
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
	titanfall()
	var/turf/center = SSmapping.get_station_center()
	field_wall = make_field(/datum/proximity_monitor/advanced/battle_royale, list("current_range" = 96, "host" = center))

/datum/battle_royale_controller/proc/titanfall()
	var/list/participants = pollGhostCandidates("Would you like to partake in BATTLE ROYALE?")
	var/turf/spawn_turf = get_safe_random_station_turf()
	var/obj/structure/closet/supplypod/centcompod/pod = new()
	pod.setStyle()
	for(var/mob/M in participants)
		var/key = M.key
		//Create a mob and transfer their mind to it.
		CHECK_TICK
		var/mob/living/carbon/human/H = new(pod)
		ADD_TRAIT(H, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
		//Assistant gang
		H.equipOutfit(/datum/outfit/job/assistant)
		//Give them a spell
		H.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock)
		H.key = key
		//Give weapons key
		var/obj/item/implant/weapons_auth/W = new
		W.implant(H)
		players += H
		to_chat(M, "<span class='notice'>You have been given knock and pacafism for 30 seconds.</span>")
	new /obj/effect/DPtarget(spawn_turf, pod)
	SEND_SOUND(world, sound('sound/misc/airraid.ogg'))
	to_chat(world, "<span class='boldannounce'>A 30 second grace period has been established. Good luck.</span>")
	to_chat(world, "<span class='boldannounce'>WARNING: YOU WILL BE GIBBED IF YOU LEAVE THE STATION Z-LEVEL!</span>")
	//Start processing our world events
	START_PROCESSING(SSprocessing, src)
	addtimer(CALLBACK(src, .proc/end_grace), 300)
	generate_basic_loot(100)

/datum/battle_royale_controller/proc/end_grace()
	for(var/mob/M in GLOB.player_list)
		M.RemoveSpell(/obj/effect/proc_holder/spell/aoe_turf/knock)
		REMOVE_TRAIT(M, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
		to_chat(M, "<span class='greenannounce'>You are no longer a pacafist. Be the last [M.gender == MALE ? "man" : "woman"] standing.</span>")

//==================================
// EVENTS / DROPS
//==================================

/datum/battle_royale_controller/proc/generate_basic_loot(amount=1)
	for(var/i in 1 to amount)
		send_item(pick(GLOB.battle_royale_basic_loot))
		stoplag()

/datum/battle_royale_controller/proc/generate_good_drop()
	var/list/good_drops = list()
	for(var/i in 1 to rand(1,3))
		good_drops += pick(GLOB.battle_royale_good_loot)
	send_item(good_drops, announce = "Incomming extended supply materials.", force_time = 600)

/datum/battle_royale_controller/proc/generate_endgame_drop()
	var/obj/item = pick(GLOB.battle_royale_insane_loot)
	send_item(item, announce = "We found a weird looking package in the back of our warehouse. We have no idea what is in it, but it is marked as incredibily dangerous and could be a superweapon.", force_time = 1800)

/datum/battle_royale_controller/proc/send_item(item_path, style = STYLE_BOX, announce=FALSE, force_time = 0)
	if(!item_path)
		return
	var/turf/target = get_safe_random_station_turf()
	var/obj/structure/closet/supplypod/battleroyale/pod = new()
	if(islist(item_path))
		for(var/thing in item_path)
			new thing(pod)
	else
		new item_path(pod)
	if(force_time)
		pod.fallDuration = force_time
	new /obj/effect/DPtarget(target, pod)
	if(announce)
		priority_announce("[announce] \nExpected Drop Location: [get_area(target)]\n ETA: [force_time/10] Seconds.", "High Command Supply Control")

//==================================
// WORLD BORDER
//==================================

/datum/proximity_monitor/advanced/battle_royale
	setup_edge_turfs = TRUE
	use_host_turf = TRUE
	field_shape = 1
	current_range = 5
	var/static/image/edgeturf_south = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_south")
	var/static/image/edgeturf_north = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_north")
	var/static/image/edgeturf_west = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_west")
	var/static/image/edgeturf_east = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_east")
	var/static/image/northwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northwest")
	var/static/image/southwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southwest")
	var/static/image/northeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northeast")
	var/static/image/southeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southeast")
	var/static/image/generic_edge = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_generic")

/datum/proximity_monitor/advanced/battle_royale/field_edge_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/field_edge/F)
	if(isliving(AM))
		var/mob/living/M = AM
		M.gib()
		to_chat(M, "<span class='warning'>You left the zone!</span>")

/datum/proximity_monitor/advanced/battle_royale/setup_edge_turf(turf/T)
	. = ..()
	var/image/I = get_edgeturf_overlay(get_edgeturf_direction(T))
	var/obj/effect/abstract/proximity_checker/advanced/F = edge_turfs[T]
	F.appearance = I.appearance
	F.invisibility = 0
	F.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	F.layer = 5

/datum/proximity_monitor/advanced/battle_royale/proc/get_edgeturf_overlay(direction)
	switch(direction)
		if(NORTH)
			return edgeturf_north
		if(SOUTH)
			return edgeturf_south
		if(EAST)
			return edgeturf_east
		if(WEST)
			return edgeturf_west
		if(NORTHEAST)
			return northeast_corner
		if(NORTHWEST)
			return northwest_corner
		if(SOUTHEAST)
			return southeast_corner
		if(SOUTHWEST)
			return southwest_corner
		else
			return generic_edge

//Checks tick when recalculating becuase field will be large
/datum/proximity_monitor/advanced/battle_royale/update_new_turfs()
	if(!istype(host))
		return FALSE
	var/turf/center = get_turf(host)
	field_turfs_new = list()
	edge_turfs_new = list()
	for(var/turf/T in block(locate(center.x-current_range,center.y-current_range,center.z-square_depth_down),locate(center.x+current_range, center.y+current_range,center.z+square_depth_up)))
		field_turfs_new += T
	edge_turfs_new = field_turfs_new.Copy()
	if(current_range >= 1)
		var/list/turf/center_turfs = list()
		for(var/turf/T in block(locate(center.x-current_range+1,center.y-current_range+1,center.z-square_depth_down),locate(center.x+current_range-1, center.y+current_range-1,center.z+square_depth_up)))
			center_turfs += T
			CHECK_TICK
		for(var/turf/T in center_turfs)
			edge_turfs_new -= T
			CHECK_TICK
