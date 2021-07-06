
/obj/item/alienartifact
	name = "artifact"
	desc = "A strange artifact of unknown origin."
	icon = 'icons/obj/artifact.dmi'
	icon_state = "artifact"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/list/datum/artifact_effect/effects

/obj/item/alienartifact/objective/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)

/obj/item/alienartifact/Initialize()
	. = ..()
	effects = list()
	for(var/i in 1 to pick(1, 500; 2, 70; 3, 20))
		var/picked_type = pick(subtypesof(/datum/artifact_effect))
		var/valid = TRUE
		var/datum/artifact_effect/effect = new picked_type
		for(var/datum/artifact_effect/old_effect as() in effects)
			//Cant have the same one twice
			if(istype(old_effect, picked_type))
				valid = FALSE
				qdel(effect)
				break
			//Cant have incompatible signals
			for(var/signal_type in old_effect.signal_types)
				if(signal_type in effect.signal_types)
					valid = FALSE
					qdel(effect)
					break
		if(valid)
			effect.register_signals(src)
			effect.Initialize(src)
			effects += effect

/obj/item/alienartifact/Destroy()
	. = ..()
	QDEL_LIST(effects)

//===================
// Raw artifact datum
//===================

/datum/artifact_effect
	var/requires_processing = FALSE
	var/obj/item/source_object
	var/list/signal_types = list()

/datum/artifact_effect/proc/register_signals(source)
	return

/datum/artifact_effect/proc/Initialize(source)
	source_object = source
	if(requires_processing)
		START_PROCESSING(SSobj, src)

/datum/artifact_effect/Destroy()
	if(requires_processing)
		STOP_PROCESSING(SSobj, src)

//===================
// Reality Destabilizer
//===================

GLOBAL_LIST_EMPTY(destabilization_spawns)

/obj/effect/landmark/destabilization_loc
	name = "destabilization spawn"

/obj/effect/landmark/destabilization_loc/Initialize()
	..()
	GLOB.destabilization_spawns += get_turf(src)
	return INITIALIZE_HINT_QDEL

/datum/artifact_effect/reality_destabilizer
	requires_processing = TRUE
	var/cooldown = 0

/datum/artifact_effect/reality_destabilizer/process(delta_time)
	if(world.time < cooldown)
		return
	cooldown = world.time + rand(0, 30 SECONDS)
	var/turf/T = get_turf(source_object)
	if(!T)
		return
	for(var/atom/movable/AM in view(3, T))
		if(AM == src)
			continue
		if(isobj(AM))
			var/obj/O = AM
			if(O.resistance_flags & INDESTRUCTIBLE)
				continue
		if(AM.anchored)
			continue
		if(prob(3))
			destabilize(AM)

/datum/artifact_effect/reality_destabilizer/proc/destabilize(atom/movable/AM)
	//Banish to the void
	addtimer(CALLBACK(src, .proc/restabilize, AM, get_turf(AM)), rand(10 SECONDS, 90 SECONDS))
	//Forcemove to ignore teleport checks
	AM.forceMove(pick(GLOB.destabilization_spawns))
	if(ismob(AM))
		to_chat(AM, "<span class='warning'>What the hell is that thing...?</span>")

/datum/artifact_effect/reality_destabilizer/proc/restabilize(atom/movable/AM, turf/T)
	if(QDELETED(AM))
		return
	AM.forceMove(T)

//===================
// Teleport
//===================

/datum/artifact_effect/warp
	signal_types = list(COMSIG_ITEM_ATTACK_SELF)
	var/next_use_world_time = 0

/datum/artifact_effect/warp/register_signals(source)
	RegisterSignal(source, COMSIG_ITEM_ATTACK_SELF, .proc/teleport)

/datum/artifact_effect/warp/proc/teleport(datum/source, mob/warper)
	if(world.time < next_use_world_time)
		return
	var/turf/T = get_turf(warper)
	if(T)
		do_teleport(warper, pick(RANGE_TURFS(10, T)), channel = TELEPORT_CHANNEL_FREE)
		next_use_world_time = world.time + 150

//===================
// Curse
//===================

/datum/artifact_effect/curse
	var/used = FALSE
	signal_types = list(COMSIG_ITEM_PICKUP)

/datum/artifact_effect/curse/register_signals(source)
	RegisterSignal(source, COMSIG_ITEM_PICKUP, .proc/curse)

/datum/artifact_effect/curse/proc/curse(datum/source, mob/taker)
	var/mob/living/carbon/human/H = taker
	if(istype(H) && !used)
		used = TRUE
		H.gain_trauma(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_MAGIC)

//===================
// Gas ~~Remover~~ Converter
// Probably one of the most obvious but also the most potentially dangerous.
//===================

/datum/artifact_effect/gas_remove
	requires_processing = TRUE
	var/static/list/valid_inputs = list(
		/datum/gas/oxygen = 6,
		/datum/gas/nitrogen = 3,
		/datum/gas/plasma = 1,
		/datum/gas/carbon_dioxide = 1,
		/datum/gas/water_vapor = 3
	)
	var/static/list/valid_outputs = list(
		/datum/gas/bz = 3,
		/datum/gas/hypernoblium = 1,
		/datum/gas/miasma = 3,
		/datum/gas/plasma = 3,
		/datum/gas/tritium = 2,
		/datum/gas/nitryl = 1
	)
	var/datum/gas/input
	var/datum/gas/output

/datum/artifact_effect/gas_remove/Initialize(source)
	. = ..()
	input = pickweight(valid_inputs)
	output = pickweight(valid_outputs)

/datum/artifact_effect/gas_remove/process(delta_time)
	var/turf/T = get_turf(source_object)
	var/datum/gas_mixture/air = T.return_air()
	var/moles = min(air.get_moles(input), 5)
	if(moles)
		air.adjust_moles(input, -moles)
		air.adjust_moles(output, moles)

//===================
// Recharger
//===================

/datum/artifact_effect/recharger
	requires_processing = TRUE

/datum/artifact_effect/recharger/process(delta_time)
	var/turf/T = get_turf(source_object)
	if(!T)
		return
	for(var/atom/movable/thing in view(3, T))
		var/obj/item/stock_parts/cell/C = thing.get_cell()
		if(C)
			C.give(250 * delta_time)

//===================
// Light Breaker
//===================

/datum/artifact_effect/light_breaker
	requires_processing = TRUE
	var/next_world_time
	var/ticks_in_light = 0

/datum/artifact_effect/light_breaker/process(delta_time)
	if(world.time < next_world_time)
		return
	var/turf/T = get_turf(source_object)
	var/is_in_light = FALSE
	for(var/datum/light_source/light_source in T.affecting_lights)
		is_in_light = TRUE
		var/atom/A = light_source.source_atom
		//Starts at light but gets stronger the longer it is in light.
		A.ex_act(ticks_in_light)
	if(!is_in_light)
		ticks_in_light = 3
	else
		ticks_in_light = max(ticks_in_light--, 1)
	next_world_time = world.time + rand(30 SECONDS, 5 MINUTES)

//===================
// Insanity Pulse
//===================

/datum/artifact_effect/insanity_pulse
	var/next_use_time = 0
	var/cooldown
	var/first_time = TRUE
	signal_types = list(COMSIG_ITEM_ATTACK_SELF)

/datum/artifact_effect/insanity_pulse/Initialize(source)
	. = ..()
	cooldown = rand(5 MINUTES, 15 MINUTES)

/datum/artifact_effect/insanity_pulse/register_signals(source)
	RegisterSignal(source, COMSIG_ITEM_ATTACK_SELF, .proc/pulse)

/datum/artifact_effect/insanity_pulse/proc/pulse(datum/source, mob/living/pulser)
	if(!istype(pulser))
		return
	if(world.time < next_use_time)
		return
	SEND_SOUND(world, 'sound/magic/repulse.ogg')
	next_use_time = world.time + cooldown
	var/turf/T = get_turf(pulser)
	log_attack("[key_name_admin(pulser)] activated an insanity pulse at [COORD(T)]. [first_time ? " (Effects were unknown)" : " (Artifact had been activated before)"]")
	message_admins("[ADMIN_LOOKUPFLW(pulser)] activated an insanity pulse [first_time ? " (Effects were unknown)" : " (Artifact had been activated before)"].")
	if(first_time)
		var/research_reward = rand(5000, 20000)
		priority_announce("Spacetime anomaly detected at [T.loc]. Data analysis completed, [research_reward] research points rewarded.", "Nanotrasen Research Division", ANNOUNCER_SPANOMALIES)
		SSresearch.science_tech.add_points_all(research_reward)
	first_time = FALSE
	var/xrange = 50
	var/yrange = 50
	var/cx = T.x
	var/cy = T.y
	pulser.blind_eyes(300)
	pulser.Stun(100)
	pulser.emote("scream")
	pulser.hallucination = 500
	for(var/r in 1 to max(xrange, yrange))
		var/xr = min(xrange, r)
		var/yr = min(yrange, r)
		var/turf/TL = locate(cx - xr, cy + yr, T.z)
		var/turf/BL = locate(cx - xr, cy - yr, T.z)
		var/turf/TR = locate(cx + xr, cy + yr, T.z)
		var/turf/BR = locate(cx + xr, cy - yr, T.z)
		var/list/turfs = list()
		turfs += block(TL, TR)
		turfs += block(TL, BL)
		turfs |= block(BL, BR)
		turfs |= block(BR, TR)
		for(var/turf/T1 as() in turfs)
			new /obj/effect/temp_visual/mining_scanner(T1)
			var/mob/living/M = locate() in T1
			if(M)
				to_chat(M, "<span class='warning'>A wave of dread washes over you...</span>")
				M.blind_eyes(30)
				M.Knockdown(10)
				M.emote("scream")
				M.Jitter(50)
				M.hallucination = M.hallucination + 20
			CHECK_TICK
		sleep(2)
