GLOBAL_LIST_INIT(clockwork_portals, list())

/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "\improper Ark of the Clockwork Justiciar"
	desc = "A massive, hulking amalgamation of parts. It seems to be maintaining a very unstable bluespace anomaly."
	clockwork_desc = "Nezbere's magnum opus: a hulking clockwork machine capable of combining bluespace and steam power to summon Ratvar. Once activated, \
	its instability will cause one-way bluespace rifts to open across the station to the City of Cogs, so be prepared to defend it at all costs."
	max_integrity = 1000
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_components"
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	can_be_repaired = FALSE
	immune_to_servant_attacks = TRUE
	layer = BELOW_MOB_LAYER

	var/activated = FALSE
	var/grace_period = 1800
	var/assault_time = 0

	var/list/phase_messages = list()
	var/recalled = FALSE

	var/destroyed = FALSE

/obj/structure/destructible/clockwork/massive/celestial_gateway/Initialize(mapload)
	. = ..()
	GLOB.celestial_gateway = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	if(GLOB.ratvar_risen)
		return
	destroyed = TRUE
	hierophant_message("The Ark has been destroyed, Reebe is becoming unstable!", null, "<span class='large_brass'>")
	for(var/mob/living/M in GLOB.player_list)
		if(!is_reebe(M.z))
			continue
		if(is_servant_of_ratvar(M))
			to_chat(M, "<span class='reallybig hypnophrase'>Your mind is distorted by the distant sound of a thousand screams. <i>YOU HAVE FAILED TO PROTECT MY ARK. YOU WILL BE TRAPPED HERE WITH ME TO SUFFER FOREVER...</i></span>")
			continue
		var/safe_place = find_safe_turf()
		M.SetSleeping(50)
		to_chat(M, "<span class='reallybig hypnophrase'>Your mind is distorted by the distant sound of a thousand screams before suddenly everything falls silent.</span>")
		to_chat(M, "<span class='hypnophrase'>The only thing you remember is suddenly feeling warm and safe.</span>")
		M.forceMove(safe_place)
	STOP_PROCESSING(SSobj, src)
	. = ..()
	//Summon nar'sie
	if(GLOB.narsie_breaching)
		new /obj/eldritch/narsie(GLOB.narsie_arrival)
	INVOKE_ASYNC(src, PROC_REF(explode_reebe))

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/explode_reebe()
	for(var/i in 1 to 30)
		explosion(pick(get_area_turfs(/area/reebe/city_of_cogs)), 0, 2, 4, 4, FALSE)
		sleep(5)
	explosion(pick(GLOB.servant_spawns), 50, 40, 30, 30, FALSE, TRUE)

/obj/structure/destructible/clockwork/massive/celestial_gateway/examine(mob/user)
	. = ..()
	if(GLOB.ratvar_arrival_tick)
		. += "It will open in [max((GLOB.ratvar_arrival_tick - world.time)/10, 0)] seconds."
	else
		. += "It doesn't seem to be doing much right now, maybe one day it will serve its purpose."

/obj/structure/destructible/clockwork/massive/celestial_gateway/process(delta_time)
	if(DT_PROB(10, delta_time))
		to_chat(world, pick(phase_messages))

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			resistance_flags |= INDESTRUCTIBLE
			visible_message("<span class='userdanger'>[src] begins to pulse uncontrollably... you might want to run!</span>")
			sound_to_playing_players(volume = 50, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_disrupted.ogg'))
			for(var/mob/M in GLOB.player_list)
				var/turf/T = get_turf(M)
				if((T && T.get_virtual_z_level() == get_virtual_z_level()) || is_servant_of_ratvar(M))
					M.playsound_local(M, 'sound/machines/clockcult/ark_deathrattle.ogg', 100, FALSE, pressure_affected = FALSE)
			sleep(27)
			explosion(src, 1, 3, 8, 8)
			sound_to_playing_players('sound/effects/explosion_distant.ogg', volume = 50)
			for(var/obj/effect/portal/wormhole/clockcult/CC in GLOB.all_wormholes)
				qdel(CC)
			SSshuttle.clearHostileEnvironment(src)
			set_security_level(SEC_LEVEL_RED)
			sleep(300)
			SSticker.force_ending = TRUE
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
	SSshuttle.registerHostileEnvironment(src)
	if(GLOB.gateway_opening)
		return
	GLOB.gateway_opening = TRUE
	var/s = sound('sound/magic/clockwork/ark_activation_sequence.ogg')
	icon_state = "clockwork_gateway_charging"
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		SEND_SOUND(M.current, s)
		to_chat(M, "<span class='big_brass'>The Ark has been activated, you will be transported soon!</span>")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(hierophant_message), "Invoke 'Clockwork Armaments' using your Clockwork Slab to get powerful armour and weapons.", "Nezbere", "nezbere", FALSE, FALSE), 10)
	addtimer(CALLBACK(src, PROC_REF(announce_gateway)), 300)
	addtimer(CALLBACK(src, PROC_REF(recall_sound)), 270)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_mass_recall()
	if(recalled)
		return
	INVOKE_ASYNC(src, PROC_REF(recall_sound))
	addtimer(CALLBACK(src, PROC_REF(mass_recall)), 30)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/recall_sound()
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		var/mob/living/servant = M.current
		if(!servant)
			continue
		SEND_SOUND(servant, 'sound/machines/clockcult/ark_recall.ogg')

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/announce_gateway()
	activated = TRUE
	set_security_level(SEC_LEVEL_DELTA)
	mass_recall(TRUE)
	var/grace_time = GLOB.narsie_breaching ? 0 : 1800
	addtimer(CALLBACK(src, PROC_REF(begin_assault)), grace_time)
	priority_announce("Massive [Gibberish("bluespace", 100)] anomaly detected on all frequencies. All crew are directed to \
	@!$, [text2ratvar("PURGE ALL UNTRUTHS")] <&. the anomalies and destroy their source to prevent further damage to corporate property. This is \
	not a drill.[grace_period ? " Estimated time of appearance: [grace_time/10] seconds. Use this time to prepare for an attack on [station_name()]." : ""]"\
	,"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg')
	sound_to_playing_players(volume = 10, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_charging.ogg', TRUE))
	GLOB.ratvar_arrival_tick = world.time + 6000 + grace_time

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/mass_recall(add_overlay = FALSE)
	var/list/spawns = GLOB.servant_spawns.Copy()
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		var/mob/living/servant = M.current
		if(!servant || QDELETED(servant))
			continue
		servant.forceMove(pick_n_take(spawns))
		if(!LAZYLEN(spawns))	//Just in case :^)
			spawns = GLOB.servant_spawns.Copy()
		if(ishuman(servant) && add_overlay)
			var/datum/antagonist/servant_of_ratvar/servant_antag = is_servant_of_ratvar(servant)
			if(servant_antag)
				servant_antag.forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
				servant.add_overlay(servant_antag.forbearance)
	for(var/mob/M in GLOB.player_list)
		SEND_SOUND(M, 'sound/magic/clockwork/invoke_general.ogg')

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_assault()
	priority_announce("Space-time anomalies detected near the station. Source determined to be a temporal \
		energy pulse emanating from J1523-215. All crew are to enter [text2ratvar("prep#re %o di%")]\
		and destroy the [text2ratvar("I'd like to see you try")], which has been determined to be the source of the \
		pulse to prevent mass damage to Nanotrasen property.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)

	for(var/i in 1 to 100)
		var/turf/T = get_random_station_turf()
		GLOB.clockwork_portals += new /obj/effect/portal/wormhole/clockcult(T, null, 0, null, FALSE)
	addtimer(CALLBACK(src, PROC_REF(begin_activation)), 2400)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_activation()
	icon_state = "clockwork_gateway_active"
	sound_to_playing_players(volume = 25, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_active.ogg', TRUE))
	addtimer(CALLBACK(src, PROC_REF(begin_ratvar_arrival)), 2400)
	START_PROCESSING(SSobj, src)
	phase_messages = list(
		"<span class='warning'>You hear other-worldly sounds from the north.</span>",
		"<span class='warning'>You feel the fabric of reality twist and bend.</span>",
		"<span class='warning'>Your mind buzzes with fear.</span>",
		"<span class='warning'>You hear otherworldly screams from all around you.</span>"
	)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_ratvar_arrival()
	sound_to_playing_players(volume = 30, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_closing.ogg', TRUE))
	icon_state = "clockwork_gateway_closing"
	addtimer(CALLBACK(src, PROC_REF(ratvar_approaches)), 1200)
	phase_messages = list(
		"<span class='warning'>You hear otherworldly sounds from the north.</span>",
		"<span class='brass'>The Celestial Gateway is feeding into the bluespace rift!</span>",
		"<span class='warning'>You feel reality shudder for a moment...</span>",
		"<span class='brass'>You feel time and space distorting around you...</span>"
	)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/ratvar_approaches()
	if(destroyed)
		return
	STOP_PROCESSING(SSobj, src)
	hierophant_message("Ratvar approaches, you shall be eternally rewarded for your servitude!", null, "<span class='large_brass'>")
	resistance_flags |= INDESTRUCTIBLE
	for(var/mob/living/M in GLOB.all_servants_of_ratvar)
		M.status_flags |= GODMODE
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
	new /obj/eldritch/ratvar(center_station)
	if(GLOB.narsie_breaching)
		new /obj/eldritch/narsie(GLOB.narsie_arrival)
	flee_reebe(TRUE)

//=========Ratvar==========
GLOBAL_VAR(cult_ratvar)

#define RATVAR_CONSUME_RANGE 12
#define RATVAR_GRAV_PULL 10
#define RATVAR_SINGULARITY_SIZE 11

/obj/eldritch/ratvar
	name = "ratvar, the Clockwork Justicar"
	desc = "Oh, that's ratvar!"
	icon = 'icons/effects/512x512.dmi'
	icon_state = "ratvar"
	density = FALSE
	pixel_x = -236
	pixel_y = -256
	var/range = 1
	var/ratvar_target
	var/next_attack_tick

/obj/eldritch/ratvar/Initialize(mapload, starting_energy = 50)
	singularity = WEAKREF(AddComponent(
		/datum/component/singularity, \
		bsa_targetable = FALSE, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = RATVAR_CONSUME_RANGE, \
		disregard_failed_movements = TRUE, \
		grav_pull = RATVAR_GRAV_PULL, \
		roaming = TRUE,\
		singularity_size = RATVAR_SINGULARITY_SIZE, \
	))
	log_game("!!! RATVAR HAS RISEN. !!!")
	GLOB.cult_ratvar = src
	. = ..()
	desc = "[text2ratvar("That's Ratvar, the Clockwork Justicar. The great one has risen.")]"
	SEND_SOUND(world, 'sound/effects/ratvar_reveal.ogg')
	to_chat(world, "<span class='ratvar'>The bluespace veil gives way to Ratvar, his light shall shine upon all mortals!</span>")
	UnregisterSignal(src, COMSIG_ATOM_BSA_BEAM)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(trigger_clockcult_victory), src)
	check_gods_battle()

//tasty
/obj/eldritch/ratvar/process(delta_time)
	var/datum/component/singularity/singularity_component = singularity.resolve()
	if(ratvar_target)
		singularity_component?.target = ratvar_target
		if(get_dist(src, ratvar_target) < 5)
			if(next_attack_tick < world.time)
				next_attack_tick = world.time + rand(50, 100)
				to_chat(world, "<span class='danger'>[pick("Reality shudders around you.","You hear the tearing of flesh.","The sound of bones cracking fills the air.")]</span>")
				SEND_SOUND(world, 'sound/magic/clockwork/ratvar_attack.ogg')
				SpinAnimation(4, 0)
				for(var/mob/living/M in GLOB.player_list)
					shake_camera(M, 25, 6)
					M.Knockdown(5 * delta_time)
				if(prob(max(GLOB.servants_of_ratvar.len/2, 15)))
					SEND_SOUND(world, 'sound/magic/demon_dies.ogg')
					to_chat(world, "<span class='ratvar'>You were a fool for underestimating me...</span>")
					qdel(ratvar_target)
					for(var/datum/mind/M as() in SSticker.mode?.cult)
						to_chat(M, "<span class='userdanger'>You feel a stabbing pain in your chest... This can't be happening!</span>")
						M.current?.dust()
				return

/obj/eldritch/ratvar/consume(atom/A)
	A.ratvar_act()

/obj/eldritch/ratvar/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(T == loc)
		T = get_step(A, A.dir) //please don't slam into a window like a bird, Ratvar
	forceMove(T)

/obj/eldritch/ratvar/attack_ghost(mob/user)
	. = ..()
	var/mob/living/simple_animal/drone/D = new /mob/living/simple_animal/drone/cogscarab(get_turf(src))
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.key = user.key
	add_servant_of_ratvar(D, silent=TRUE)

#undef RATVAR_CONSUME_RANGE
#undef RATVAR_GRAV_PULL
#undef RATVAR_SINGULARITY_SIZE
