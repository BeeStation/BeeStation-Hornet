/obj/structure/destructible/clockwork/massive
	name = "massive construct"
	desc = "A very large construction."
	plane = MASSIVE_OBJ_PLANE
	zmm_flags = ZMM_WIDE_LOAD
	density = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/proc/flee_reebe()
	for(var/mob/living/M in GLOB.mob_list)
		if(!is_on_reebe(M))
			continue
		var/safe_place = find_safe_turf()
		M.forceMove(safe_place)
		if(!IS_SERVANT_OF_RATVAR(M))
			M.SetSleeping(50)

/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "\improper Ark of the Clockwork Justiciar"
	desc = "A massive, hulking amalgamation of parts. It seems to be maintaining a very unstable bluespace anomaly."
	clockwork_desc = span_brass("Nezbere's magnum opus: a hulking clockwork machine capable of combining bluespace and steam power to summon Ratvar. Once activated, \
		its instability will cause one-way bluespace rifts to open across the station to the City of Cogs, so be prepared to defend it at all costs.")
	max_integrity = 1000
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_components"
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	can_be_repaired = FALSE
	layer = BELOW_MOB_LAYER

	/// Whether or not the gateway is open
	var/activated = FALSE
	/// The time from announcing the gateway opening to the portals opening. If nar'sie is breaching, this is set to 0 SECONDS
	var/grace_period = 3 MINUTES
	/// List of possible messages that can play when the ark is opening
	var/list/phase_messages = list()
	/// Whether or not the gateway has been destroyed. Defined here so that ratvar can't rise if the gateway is destroyed
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
		if(!is_on_reebe(M))
			continue
		if(IS_SERVANT_OF_RATVAR(M))
			to_chat(M, span_reallybighypnophrase("Your mind is distorted by the distant sound of a thousand screams. <i>YOU HAVE FAILED TO PROTECT MY ARK. YOU WILL BE TRAPPED HERE WITH ME TO SUFFER FOREVER...</i>"))
			continue
		var/safe_place = find_safe_turf()
		M.SetSleeping(50)
		to_chat(M, span_reallybighypnophrase("Your mind is distorted by the distant sound of a thousand screams before suddenly everything falls silent."))
		to_chat(M, span_hypnophrase("The only thing you remember is suddenly feeling warm and safe."))
		M.forceMove(safe_place)
	STOP_PROCESSING(SSobj, src)
	destroyed = TRUE

	// Alert the crew
	hierophant_message("The Ark has been destroyed, Reebe is becoming unstable!", null, "<span class='large_brass'>")

	// Release the non-servants from Reebe
	for(var/mob/living/person in GLOB.player_list)
		if(!is_on_reebe(person))
			continue
		if(IS_SERVANT_OF_RATVAR(person))
			to_chat(person, span_reallybighypnophrase("Your mind is distorted by the distant sound of a thousand screams. <i>YOU HAVE FAILED TO PROTECT MY ARK. YOU WILL BE TRAPPED HERE WITH ME TO SUFFER FOREVER...</i>"))
			continue

		person.SetSleeping(5 SECONDS)
		to_chat(person, span_reallybighypnophrase("Your mind is distorted by the distant sound of a thousand screams before suddenly everything falls silent."))
		to_chat(person, span_hypnophrase("The only thing you remember is suddenly feeling warm and safe."))
		person.forceMove(find_safe_turf())

	// Summon nar'sie
	if(GLOB.narsie_breaching)
		new /obj/eldritch/narsie(GLOB.narsie_arrival)

	// Explode Reebe
	INVOKE_ASYNC(src, PROC_REF(explode_reebe))
	. = ..()

/obj/structure/destructible/clockwork/massive/celestial_gateway/examine(mob/user)
	. = ..()
	if(GLOB.ratvar_arrival_tick)
		. += span_brass("It will open in [DisplayTimeText(GLOB.ratvar_arrival_tick - world.time)].")
	else
		. += span_brass("It doesn't seem to be doing much right now, maybe one day it will serve its purpose.")

/obj/structure/destructible/clockwork/attacked_by(obj/item/attacking_item, mob/living/user)
	if(IS_SERVANT_OF_RATVAR(user))
		return
	. = ..()

/*
* Boom
* Called when the gateway is destroyed
*/
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/explode_reebe()
	for(var/i in 1 to 30)
		explosion(pick(get_area_turfs(/area/reebe/city_of_cogs)), 0, 2, 4, 4, FALSE)
		sleep(5)

	explosion(pick(GLOB.servant_spawns), 50, 40, 30, 30, FALSE, TRUE)

/*
* 10% chance to send a message to the server every second
* We only start processing at STAGE 2
*/
/obj/structure/destructible/clockwork/massive/celestial_gateway/process(delta_time)
	// 10% chance to send a message every second.
	if(length(phase_messages) && DT_PROB(10, delta_time))
		to_chat(world, pick(phase_messages))

/*
* Alert clock cultists that the ark is taking damage
*/
/obj/structure/destructible/clockwork/massive/celestial_gateway/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(!.)
		return

	hierophant_message("The ark is taking damage!", null, "<span class='large_brass'>")
	flick("clockwork_gateway_damaged", src)
	playsound(src, 'sound/machines/clockcult/ark_damage.ogg', 75, FALSE)

/**
 * Called from ratvar_approaches()
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if((flags_1 & NODECONSTRUCT_1))
		return
	if(disassembled)
		return
	resistance_flags |= INDESTRUCTIBLE

	// Alert
	visible_message(span_userdanger("[src] begins to pulse uncontrollably... you might want to run!"))
	sound_to_playing_players(volume = 50, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_disrupted.ogg'))
	for(var/mob/player in GLOB.player_list)
		var/turf/player_turf = get_turf(player)
		if((player_turf && player_turf.get_virtual_z_level() == get_virtual_z_level()) || IS_SERVANT_OF_RATVAR(player))
			player.playsound_local(player, 'sound/machines/clockcult/ark_deathrattle.ogg', 100, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(last_call)), 27)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/last_call()
	explosion(src, 5, 10, 20, 30)

	// Remove portals to Reebe
	for(var/obj/effect/portal/wormhole/clockcult/portal in GLOB.all_wormholes)
		qdel(portal)

/**
 * Time to open the gateway
 * Declare a hostile enviroment and after 30 seconds alert the crew and recall the servants
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/open_gateway()
	if(GLOB.gateway_opening)
		return

	icon_state = "clockwork_gateway_charging"
	SSshuttle.registerHostileEnvironment(src)
	GLOB.gateway_opening = TRUE

	// Alert servants
	for(var/datum/mind/servant_mind in GLOB.servants_of_ratvar)
		SEND_SOUND(servant_mind.current, 'sound/magic/clockwork/ark_activation_sequence.ogg')
		to_chat(servant_mind, span_bigbrass("The Ark has been activated, you will be transported soon!"))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(hierophant_message), "Invoke 'Clockwork Armaments' using your Clockwork Slab to get powerful armour and weapons.", "Nezbere", "nezbere", FALSE, FALSE), 1 SECONDS)

	// Announce gateway
	addtimer(CALLBACK(src, PROC_REF(begin_mass_recall)), 27 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(announce_gateway)), 30 SECONDS)

/**
 * STAGE 0: Pre-attack phase, lasts 3 minutes
 * The gateway is opened and the crew is alerted. The crew has 3 minutes to prepare for the attack.
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/announce_gateway()
	activated = TRUE
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	apply_overlays()

	// If Narsie is breaching, we don't want to wait for the grace time
	var/grace_time = GLOB.narsie_breaching ? 0 SECONDS : grace_period
	addtimer(CALLBACK(src, PROC_REF(begin_assault)), grace_time)

	GLOB.ratvar_arrival_tick = world.time + 10 MINUTES + grace_time

	// Announce to crew
	priority_announce("Massive [Gibberish("bluespace", 100)] anomaly detected on all frequencies. All crew are directed to \
		@!$, [text2ratvar("PURGE ALL UNTRUTHS")] <&. the anomalies and destroy their source to prevent further damage to corporate property. This is \
		not a drill. Estimated time of appearance: [DisplayTimeText(grace_time)]. Use this time to prepare for an attack on [station_name()]."\
		,"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg')
	sound_to_playing_players(volume = 10, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_charging.ogg', TRUE))

	log_game("The clock cult has begun opening the Ark of the Clockwork Justiciar.")

/**
 * STAGE 1: Defense phase, lasts 4 minutes
 * Start of the crew's attack, lets announce it and open portals to Reebe
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_assault()
	priority_announce("Space-time anomalies detected near the station. Source determined to be a temporal \
		energy pulse emanating from J1523-215. All crew are to enter [text2ratvar("prep#re %o di%")]\
		and destroy the [text2ratvar("I'd like to see you try")], which has been determined to be the source of the \
		pulse to prevent mass damage to Nanotrasen property.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)

	for(var/i in 1 to 100)
		new /obj/effect/portal/wormhole/clockcult(get_random_station_turf(), null, 0, null, FALSE)
	log_game("The opening of the Ark of the Clockwork Justiciar has caused portals to open around the station.")

	addtimer(CALLBACK(src, PROC_REF(begin_activation)), 4 MINUTES)

/**
 * STAGE 2: Assault phase, lasts 4 minutes
 * Mid-way point of the crew's attack.
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_activation()
	sound_to_playing_players(volume = 25, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_active.ogg', TRUE))
	icon_state = "clockwork_gateway_active"

	// Start sending messages
	START_PROCESSING(SSobj, src)
	phase_messages = list(
		span_warning("You hear other-worldly sounds from the north."),
		span_warning("You feel the fabric of reality twist and bend."),
		span_warning("Your mind buzzes with fear."),
		span_warning("You hear otherworldly screams from all around you.")
	)

	addtimer(CALLBACK(src, PROC_REF(begin_ratvar_arrival)), 4 MINUTES)

/**
 * STAGE 3: Cleanup phase, lasts 2 minutes
 * Final stretch
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_ratvar_arrival()
	sound_to_playing_players(volume = 30, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_closing.ogg', TRUE))
	icon_state = "clockwork_gateway_closing"

	// Update messages
	phase_messages = list(
		span_warning("You hear other-worldly sounds from the north."),
		span_brass("The Celestial Gateway is feeding into the bluespace rift!"),
		span_warning("You feel reality shudder for a moment..."),
		span_brass("You feel time and space distorting around you...")
	)

	addtimer(CALLBACK(src, PROC_REF(ratvar_approaches)), 2 MINUTES)

/**
 * STAGE 4: Ratvar approaches
 * Ratvar is here, the crew has lost.
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/ratvar_approaches()
	if(destroyed)
		return
	resistance_flags |= INDESTRUCTIBLE
	GLOB.ratvar_risen = TRUE

	// Stop sending messages
	STOP_PROCESSING(SSobj, src)

	// Give servants godmode
	hierophant_message("Ratvar approaches, you shall be eternally rewarded for your servitude!", null, "<span class='large_brass'>")
	for(var/mob/living/servant in GLOB.all_servants_of_ratvar)
		ADD_TRAIT(servant, TRAIT_GODMODE, REF(src))

	// Sfx
	sound_to_playing_players(volume = 100, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/ratvar_rises.ogg'))

	// Delete the gateway
	var/original_matrix = matrix()
	animate(src, transform = original_matrix * 1.5, alpha = 255, time = 125)
	sleep(125)
	transform = original_matrix
	animate(src, transform = original_matrix * 3, alpha = 0, time = 5)
	QDEL_IN(src, 3)
	sleep(3)

	// Remove portals to Reebe
	for(var/obj/effect/portal/wormhole/clockcult/portal in GLOB.all_wormholes)
		qdel(portal)

	// Summon Ratvar
	var/turf/center_station = SSmapping.get_station_center()
	new /obj/eldritch/ratvar(center_station)
	if(GLOB.narsie_breaching)
		new /obj/eldritch/narsie(GLOB.narsie_arrival)

	// Send to the station
	for(var/mob/living/person in GLOB.mob_list)
		if(!is_on_reebe(person))
			continue
		person.forceMove(find_safe_turf())

		if(!IS_SERVANT_OF_RATVAR(person))
			person.SetSleeping(5 SECONDS)

/**
 * Play a sound to all clock cultists and then after 3 seconds recall them to Reebe
 * Used when the gateway is opened and when the eminence uses their recall power
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_mass_recall()
	// Play sound to all servants
	for(var/datum/mind/servant_mind in GLOB.servants_of_ratvar)
		var/mob/living/servant = servant_mind.current
		if(!servant)
			continue

		SEND_SOUND(servant, 'sound/machines/clockcult/ark_recall.ogg')

	// Recall them in 3 seconds
	addtimer(CALLBACK(src, PROC_REF(mass_recall)), 3 SECONDS)

/**
 * Teleports all clock cultists to Reebe
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/mass_recall()
	teleport_all_servants_to_reebe()
	for(var/mob/player in GLOB.player_list)
		SEND_SOUND(player, 'sound/magic/clockwork/invoke_general.ogg')

/**
 * Apply an overlay to all servants of Ratvar
 * Called when the ark is opened
 */
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/apply_overlays()
	for(var/datum/mind/servant_mind in GLOB.servants_of_ratvar)
		var/mob/living/servant = servant_mind.current
		if(!servant || QDELETED(servant))
			continue

		if(ishuman(servant))
			var/datum/antagonist/servant_of_ratvar/servant_antag = IS_SERVANT_OF_RATVAR(servant)
			if(servant_antag)
				servant_antag.forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", CALCULATE_MOB_OVERLAY_LAYER(MUTATIONS_LAYER))
				servant.add_overlay(servant_antag.forbearance)
