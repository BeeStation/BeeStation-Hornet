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
		/obj/item/storage/box/syndie_kit/bundle_A,
		/obj/item/storage/box/syndie_kit/bundle_B,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/energy/disabler,
		/obj/item/construction/rcd,
		/obj/item/clothing/glasses/chameleon/flashproof,
		/obj/item/book/granter/spell/knock,
		/obj/item/clothing/glasses/sunglasses/advanced,
		/obj/item/clothing/glasses/thermal/eyepatch,
		/obj/item/clothing/glasses/thermal/syndi,
		/obj/item/clothing/suit/space,
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
		/obj/item/gun/energy/ionrifle,
		/obj/item/organ/regenerative_core/battle_royale
	))

GLOBAL_LIST_INIT(battle_royale_good_loot, list(
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
		/obj/item/dualsaber,
		/obj/item/fireaxe,
		/obj/item/stack/sheet/telecrystal/five,
		/obj/item/stack/sheet/telecrystal/twenty,
		/obj/item/clothing/suit/space/hardsuit/syndi
	))

GLOBAL_LIST_INIT(battle_royale_insane_loot, list(
		/obj/item/gun/ballistic/automatic/l6_saw/unrestricted,
		/obj/item/energy_katana,
		/obj/item/clothing/suit/space/hardsuit/shielded/syndi,
		/obj/item/his_grace,
		/obj/mecha/combat/marauder/mauler/loaded,
		/obj/item/guardiancreator/tech,
		/obj/item/mjolnir,
		/obj/item/pneumatic_cannon/pie/selfcharge,
		/obj/item/uplink/nuclear
	))

GLOBAL_DATUM(battle_royale, /datum/battle_royale_controller)

#define BATTLE_ROYALE_AVERBS list(\
	/client/proc/battle_royale_speed,\
	/client/proc/battle_royale_varedit,\
	/client/proc/battle_royale_spawn_loot,\
	/client/proc/battle_royale_spawn_loot_good\
)

/client/proc/battle_royale()
	set name = "Battle Royale"
	set category = "Adminbus"
	if(!(check_rights(R_FUN) || (check_rights(R_ADMIN) && SSticker.current_state == GAME_STATE_FINISHED)))
		to_chat(src, "<span class='warning'>You do not have permission to do that! (If you don't have +FUN, wait until the round is over then you can trigger it.)</span>")
		return
	if(GLOB.battle_royale)
		to_chat(src, "<span class='warning'>A game is already in progress!</span>")
		return
	if(alert(src, "ARE YOU SURE YOU ARE SURE YOU WANT TO START BATTLE ROYALE?",,"Yes","No") != "Yes")
		to_chat(src, "<span class='notice'>oh.. ok then.. I see how it is.. :(</span>")
		return
	log_admin("[key_name(usr)] HAS TRIGGERED BATTLE ROYALE")
	message_admins("[key_name(usr)] HAS TRIGGERED BATTLE ROYALE")

	for(var/client/admin in GLOB.admins)
		if(check_rights(R_ADMIN) && !GLOB.battle_royale && admin.tgui_panel)
			admin.tgui_panel.clear_br_popup()

	GLOB.battle_royale = new()
	GLOB.battle_royale.start()

/client/proc/battle_royale_speed()
	set name = "Battle Royale - Change wall speed"
	set category = "Event"
	if(!check_rights(R_ADMIN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(!GLOB.battle_royale)
		to_chat(src, "<span class='warning'>No game is in progress.</span>")
		return
	var/new_speed = input(src, "New wall delay (seconds)") as num
	if(new_speed > 0)
		GLOB.battle_royale.field_delay = new_speed
		log_admin("[key_name(usr)] has changed the field delay to [new_speed] seconds")
		message_admins("[key_name(usr)] has changed the field delay to [new_speed] seconds")

/client/proc/battle_royale_varedit()
	set name = "Battle Royale - Variable Edit"
	set category = "Event"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(!GLOB.battle_royale)
		to_chat(src, "<span class='warning'>No game is in progress.</span>")
		return
	debug_variables(GLOB.battle_royale)

/client/proc/battle_royale_spawn_loot()
	set name = "Battle Royale - Spawn Loot Drop (Minor)"
	set category = "Event"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(!GLOB.battle_royale)
		to_chat(src, "<span class='warning'>No game is in progress.</span>")
		return
	GLOB.battle_royale.generate_good_drop()
	log_admin("[key_name(usr)] generated a battle royale drop.")
	message_admins("[key_name(usr)] generated a battle royale drop.")

/client/proc/battle_royale_spawn_loot_good()
	set name = "Battle Royale - Spawn Loot Drop (Major)"
	set category = "Event"
	if(!check_rights(R_FUN))
		to_chat(src, "<span class='warning'>You do not have permission to do that!</span>")
		return
	if(!GLOB.battle_royale)
		to_chat(src, "<span class='warning'>No game is in progress.</span>")
		return
	GLOB.battle_royale.generate_endgame_drop()
	log_admin("[key_name(usr)] generated a good battle royale drop.")
	message_admins("[key_name(usr)] generated a good battle royale drop.")

/datum/battle_royale_controller
	var/list/players
	var/datum/proximity_monitor/advanced/battle_royale/field_wall
	var/radius = 118
	var/process_num = 0
	var/list/death_wall
	var/field_delay = 15
	var/debug_mode = FALSE

/datum/battle_royale_controller/Destroy(force, ...)
	QDEL_LIST(death_wall)
	for(var/client/C in GLOB.admins)
		C.remove_verb(BATTLE_ROYALE_AVERBS)
	. = ..()
	GLOB.enter_allowed = TRUE

	//BR finished? Let people play as borgs/golems again
	ENABLE_BITFIELD(GLOB.ghost_role_flags, (GHOSTROLE_SPAWNER | GHOSTROLE_SILICONS))

	world.update_status()
	GLOB.battle_royale = null

//Trigger random events and shit, update the world border
/datum/battle_royale_controller/process()
	process_num++
	//Once every 50ish seconds
	if(prob(2))
		generate_basic_loot(2)
	//Once every 100ish seconds.
	if(prob(1))
		generate_good_drop()

/*	if(living_victims <= 1 && !debug_mode)
		to_chat(world, "<span class='ratvar'><font size=18>VICTORY ROYALE!!</font></span>")
		if(winner)
			winner.client?.process_greentext()
			to_chat(world, "<span class='ratvar'><font size=18>[key_name(winner)] is the winner!</font></span>")
			new /obj/item/melee/supermatter_sword(get_turf(winner))
		qdel(src)
		return
*/
	//Once every 15 seconsd
	// 1,920 seconds (about 32 minutes per game)
	if(process_num % 15)
		if(SSticker.mode)
			SSticker.mode.check_win()
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
		if(check_rights_for(C, R_ADMIN))
			C.add_verb(BATTLE_ROYALE_AVERBS)

//	toggle_ooc(FALSE)
//	to_chat(world, "<span class='ratvar'><font size=24>Battle Royale will begin soon...</span></span>")
	//Stop new player joining
	GLOB.enter_allowed = FALSE

	//Don't let anyone join as posibrains/golems etc
//	DISABLE_BITFIELD(GLOB.ghost_role_flags, (GHOSTROLE_SPAWNER | GHOSTROLE_SILICONS))

	world.update_status()

/*
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
	//Clear all living mobs
	to_chat(world, "<span class='boldannounce'>Battle Royale: Clearing world mobs.</span>")
	for(var/mob/living/M as() in GLOB.mob_living_list)
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
*/
	//spawn one basic loot drop per player after 30 second. Everyone already has a starting loadout of their choice, so no need for super spam
	addtimer(CALLBACK(src, .proc/generate_basic_loot, GLOB.player_list.len), 300) 

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

//unused
/datum/battle_royale_controller/proc/titanfall()
	var/list/participants = pollGhostCandidates("Would you like to partake in BATTLE ROYALE?")
	var/turf/spawn_turf = get_safe_random_station_turfs()
	var/obj/structure/closet/supplypod/centcompod/pod = new()
	pod.setStyle()
	players = list()
	for(var/mob/M in participants)
		var/key = M.key
		//Create a mob and transfer their mind to it.
		CHECK_TICK
		var/mob/living/carbon/human/H = new(pod)
		ADD_TRAIT(H, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
		ADD_TRAIT(H, TRAIT_DROPS_ITEMS_ON_DEATH, BATTLE_ROYALE_TRAIT)
		H.status_flags |= GODMODE
		//Assistant gang
		H.equipOutfit(/datum/outfit/job/assistant)
		//Give them a spell
		H.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock)
		H.key = key
		//Give weapons key
		var/obj/item/implant/weapons_auth/W = new
		W.implant(H)
		players += H
		to_chat(M, "<span class='notice'>You have been given knock and pacifism for 30 seconds.</span>")
	new /obj/effect/pod_landingzone(spawn_turf, pod)
	SEND_SOUND(world, sound('sound/misc/airraid.ogg'))
	to_chat(world, "<span class='boldannounce'>A 30 second grace period has been established. Good luck.</span>")
	to_chat(world, "<span class='boldannounce'>WARNING: YOU WILL BE GIBBED IF YOU LEAVE THE STATION Z-LEVEL!</span>")
	to_chat(world, "<span class='boldannounce'>[players.len] people remain...</span>")

	//Start processing our world events
	addtimer(CALLBACK(src, .proc/end_grace), 300)
	generate_basic_loot(150)

/datum/battle_royale_controller/proc/end_grace()
	for(var/mob/M in GLOB.player_list)
		M.RemoveSpell(/obj/effect/proc_holder/spell/aoe_turf/knock)
		M.status_flags -= GODMODE
		REMOVE_TRAIT(M, TRAIT_PACIFISM, BATTLE_ROYALE_TRAIT)
		to_chat(M, "<span class='greenannounce'>You are no longer a pacifist. Be the last [M.gender == MALE ? "man" : "woman"] standing.</span>")

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
	send_item(good_drops, announce = "Incoming extended supply materials.", force_time = 300)

/datum/battle_royale_controller/proc/generate_endgame_drop()
	var/obj/item = pick(GLOB.battle_royale_insane_loot)
	send_item(item, announce = "We found a weird looking package in the back of our warehouse. We have no idea what is in it, but it is marked as incredibily dangerous and could be a superweapon.", force_time = 600)

/datum/battle_royale_controller/proc/send_item(item_path, style = STYLE_BOX, announce=FALSE, force_time = 0)
	if(!item_path)
		return
	var/turf/target = get_safe_random_station_turfs()
	var/obj/structure/closet/supplypod/battleroyale/pod = new()
	if(islist(item_path))
		for(var/thing in item_path)
			new thing(pod)
	else
		new item_path(pod)
	if(force_time)
		pod.delays[POD_FALLING]= force_time
	new /obj/effect/pod_landingzone(target, pod)
	if(announce)
		priority_announce("[announce] \nExpected Drop Location: [get_area(target)]\n ETA: [force_time/10] Seconds.", "High Command Supply Control", SSstation.announcer.get_rand_alert_sound())

//==================================
// WORLD BORDER
//==================================

/obj/effect/death_wall
	var/current_radius = 118
	var/turf/center_turf
	icon = 'icons/effects/fields.dmi'
	icon_state = "projectile_dampen_generic"

/obj/effect/death_wall/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/death_wall/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	//lol u died
	if(isliving(AM))
		var/mob/living/M = AM
		INVOKE_ASYNC(M, /mob/living/carbon.proc/gib)
		to_chat(M, "<span class='warning'>You left the zone!</span>")

/obj/effect/death_wall/Moved(atom/OldLoc, Dir)
	. = ..()
	for(var/mob/living/M in get_turf(src))
		M.gib()
		to_chat(M, "<span class='warning'>You left the zone!</span>")

/obj/effect/death_wall/proc/set_center(turf/center)
	center_turf = center

/obj/effect/death_wall/proc/decrease_size()
	var/minx = CLAMP(center_turf.x - current_radius, 1, 255)
	var/maxx = CLAMP(center_turf.x + current_radius, 1, 255)
	var/miny = CLAMP(center_turf.y - current_radius, 1, 255)
	var/maxy = CLAMP(center_turf.y + current_radius, 1, 255)
	if(y == maxy || y == miny)
		//We have nowhere to move to so are deleted
		if(x == minx || x == minx + 1 || x == maxx || x == maxx - 1)
			qdel(src)
			return
	//Where do we go to?
	var/top = y == maxy
	var/bottom = y == miny
	var/left = x == minx
	var/right = x == maxx
	if(left)
		forceMove(get_step(get_turf(src), EAST))
	else if(right)
		forceMove(get_step(get_turf(src), WEST))
	else if(bottom)
		forceMove(get_step(get_turf(src), NORTH))
	else if(top)
		forceMove(get_step(get_turf(src), SOUTH))
	current_radius--

//=====
// Heal
// =====
/obj/item/organ/regenerative_core/battle_royale
	preserved = TRUE
