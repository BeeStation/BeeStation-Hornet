GLOBAL_LIST_INIT(clockwork_portals, list())

/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "ark of the Clockwork Justicar"
	max_integrity = 250
	obj_integrity = 250
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_components"
	pixel_x = -32
	pixel_y = -32
	density = TRUE

	var/activated = FALSE
	var/grace_period = 300
	var/assault_time = 0

/obj/structure/destructible/clockwork/massive/celestial_gateway/Initialize()
	. = ..()
	GLOB.celestial_gateway = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	if(GLOB.ratvar_risen)
		return
	hierophant_message("The Ark has been destroyed, Reebe is becomming unstable!", null, "<span class='big_brass'>")
	if(GLOB.ratvar_risen || !istype(SSticker.mode, /datum/game_mode/clockcult))
		return
	flee_reebe(FALSE)
	. = ..()
	for(var/i in 1 to 30)
		explosion(pick(get_area_turfs(/area/reebe/city_of_cogs)), 0, 2, 4, 4, FALSE)
		sleep(5)
	explosion(pick(GLOB.servant_spawns), 50, 40, 30, 30, FALSE, TRUE)
	SSticker.force_ending = TRUE

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			resistance_flags |= INDESTRUCTIBLE
			visible_message("<span class='userdanger'>[src] begins to pulse uncontrollably... you might want to run!</span>")
			sound_to_playing_players(volume = 50, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_disrupted.ogg'))
			for(var/mob/M in GLOB.player_list)
				var/turf/T = get_turf(M)
				if((T && T.z == z) || is_servant_of_ratvar(M))
					M.playsound_local(M, 'sound/machines/clockcult/ark_deathrattle.ogg', 100, FALSE, pressure_affected = FALSE)
			sleep(27)
			explosion(src, 1, 3, 8, 8)
			sound_to_playing_players('sound/effects/explosion_distant.ogg', volume = 50)
	qdel(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(!.)
		return
	hierophant_message("The ark is taking damage!", null, "<span class='large_brass'>")
	flick("clockwork_gateway_damaged", src)
	playsound(src, 'sound/machines/clockcult/ark_damage.ogg', 75, FALSE)

//==========Battle Phase===========
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/open_gateway()
	if(GLOB.gateway_opening)
		return
	GLOB.gateway_opening = TRUE
	var/s = sound('sound/magic/clockwork/ark_activation_sequence.ogg')
	icon_state = "clockwork_gateway_charging"
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		SEND_SOUND(M.current, s)
		to_chat(M, "<span class='big_brass'>The Ark has been activated, you will be transported soon!</span>")
	addtimer(CALLBACK(src, .proc/announce_gateway), 300)
	addtimer(CALLBACK(src, .proc/recall_sound), 270)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/recall_sound()
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		var/mob/living/servant = M.current
		if(!servant)
			continue
		SEND_SOUND(servant, 'sound/machines/clockcult/ark_recall.ogg')

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/announce_gateway()
	activated = TRUE
	set_security_level(SEC_LEVEL_DELTA)
	SSshuttle.registerHostileEnvironment(src)
	SSshuttle.lockdown = TRUE
	mass_recall()
	addtimer(CALLBACK(src, .proc/begin_assault), 3000)
	priority_announce("Massive [Gibberish("bluespace", 100)] anomaly detected on all frequencies. All crew are directed to \
	@!$, [text2ratvar("PURGE ALL UNTRUTHS")] <&. the anomalies and destroy their source to prevent further damage to corporate property. This is \
	not a drill.[grace_period ? " Estimated time of appearance: [grace_period] seconds. Use this time to prepare for an attack on [station_name()]." : ""]"\
	,"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg')
	sound_to_playing_players(volume = 10, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_charging.ogg', TRUE))
	GLOB.ratvar_arrival_tick = world.time + 9000

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/mass_recall()
	var/list/spawns = GLOB.servant_spawns.Copy()
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		var/mob/living/servant = M.current
		if(!servant)
			continue
		servant.forceMove(pick_n_take(spawns))
		if(ishuman(servant))
			var/mutable_appearance/forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
			servant.add_overlay(forbearance)
	for(var/mob/M in GLOB.player_list)
		SEND_SOUND(M, 'sound/magic/clockwork/invoke_general.ogg')

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_assault()
	priority_announce("Space-time anomalies detected near the station. Source determined to be a temporal\
		energy pulse eminating from J1523-215. All crew are to enter [text2ratvar("prep#re %o di%")]\
		and destroy the [text2ratvar("I'd *ik£ to s#e yo! try")], which has been determined to be the source of the\
		pulse.\n Glory to Nanotrasen.", "Anomaly Alert", 'sound/ai/spanomalies.ogg')
	var/list/pick_turfs = list()
	for(var/turf/open/floor/T in world)
		if(is_station_level(T.z))
			pick_turfs += T
	for(var/i in 1 to 100)
		var/turf/T = pick(pick_turfs)
		GLOB.clockwork_portals += new /obj/effect/portal/wormhole/clockcult(T, null, 0, null, FALSE)
	addtimer(CALLBACK(src, .proc/begin_activation), 2400)
	return

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_activation()
	icon_state = "clockwork_gateway_active"
	sound_to_playing_players(volume = 25, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_active.ogg', TRUE))
	addtimer(CALLBACK(src, .proc/begin_ratvar_arrival), 2400)
	return

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_ratvar_arrival()
	sound_to_playing_players(volume = 30, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_closing.ogg', TRUE))
	icon_state = "clockwork_gateway_closing"
	addtimer(CALLBACK(src, .proc/ratvar_approaches), 1200)
	return

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/ratvar_approaches()
	hierophant_message("Ratvar approaches, you shall be eternally rewarded for your servitude!", null, "<span class='large_brass'>")
	resistance_flags |= INDESTRUCTIBLE
	sound_to_playing_players(volume = 100, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/ratvar_rises.ogg')) //End the sounds
	GLOB.ratvar_risen = TRUE
	var/original_matrix = matrix()
	animate(src, transform = original_matrix * 1.5, alpha = 255, time = 125)
	sleep(125)
	transform = original_matrix
	animate(src, transform = original_matrix * 3, alpha = 0, time = 5)
	QDEL_IN(src, 3)
	sleep(3)
	var/turf/center_station = SSmapping.get_station_center()
	new /obj/singularity/ratvar(center_station)
	flee_reebe(TRUE)
	return

//=========Ratvar==========
/obj/singularity/ratvar
	name = "ratvar, the Clockwork Justicar"
	desc = "Oh, that's ratvar!"
	icon = 'icons/effects/512x512.dmi'
	icon_state = "ratvar"
	density = FALSE
	current_size = STAGE_SIX
	allowed_size = STAGE_SIX
	pixel_x = -236
	pixel_y = -256
	var/range = 1

/obj/singularity/ratvar/Initialize(mapload, starting_energy = 50)
	log_game("!!! RATVAR HAS RISEN. !!!")
	. = ..()
	desc = "[text2ratvar("That's Ratvar, the Clockwork Justicar. The great one has risen.")]"
	SEND_SOUND(world, 'sound/effects/ratvar_reveal.ogg')
	to_chat(world, "<span class='big_brass'>The bluespace veil gives way to Ratvar, this realm shall be shone in his light!</span>")
	SSticker.force_ending = 1
	UnregisterSignal(src, COMSIG_ATOM_BSA_BEAM)

//tasty
/obj/singularity/ratvar/process()
	move()
	eat()

/obj/singularity/ratvar/eat()
	for(var/tile in spiral_range_turfs(range, src))
		var/turf/T = tile
		if(!T || !isturf(loc))
			continue
		T.ratvar_act()
		for(var/thing in T)
			if(isturf(loc) && thing != src)
				var/atom/movable/X = thing
				consume(X)
			CHECK_TICK
	if(range < 50)
		range ++
	return

/obj/singularity/ratvar/consume(atom/A)
	A.ratvar_act()

/obj/singularity/ratvar/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(T == loc)
		T = get_step(A, A.dir) //please don't slam into a window like a bird, Ratvar
	forceMove(T)
