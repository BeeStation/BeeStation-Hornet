
/obj/item/alienartifact
	name = "artifact"
	desc = "A strange artifact of unknown origin."
	icon = 'icons/obj/artifact.dmi'
	icon_state = "artifact"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/list/datum/artifact_effect/effects

/obj/item/alienartifact/examine(mob/user)
	. = ..()
	var/mob/living/L = user
	if(istype(L) && L.mind?.assigned_role != JOB_NAME_CURATOR)
		return
	for(var/datum/artifact_effect/effect in effects)
		for(var/verb in effect.effect_act_descs)
			. += "[src] likely does something when [verb]."

/obj/item/alienartifact/ComponentInitialize()
	AddComponent(/datum/component/discoverable, 10000, TRUE)

/obj/item/alienartifact/objective/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)
	AddComponent(/datum/component/tracking_beacon, EXPLORATION_TRACKING, null, null, TRUE, "#eb4d4d", TRUE, TRUE)

/obj/item/alienartifact/Initialize(mapload)
	. = ..()
	effects = list()
	for(var/i in 1 to pick(1, 500; 2, 70; 3, 20; 1))
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

/area/tear_in_reality
	name = "tear in the fabric of reality"
	area_flags = UNIQUE_AREA | HIDDEN_AREA
	clockwork_warp_allowed = FALSE
	requires_power = FALSE
	mood_bonus = -999
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_NONE
	sound_environment = SOUND_ENVIRONMENT_DRUGGED
	teleport_restriction = TELEPORT_ALLOW_NONE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/tear_in_reality/Initialize(mapload)
	. = ..()
	mood_message = "<span class='warning'>[scramble_message_replace_chars("###### ### #### ###### #######", 100)]!</span>"

/area/tear_in_reality/get_virtual_z(turf/T)
	return REALITY_TEAR_VIRTUAL_Z

//===================
// Raw artifact datum
//===================

/datum/artifact_effect
	var/requires_processing = FALSE
	var/effect_act_descs = list()	//List of verbs for things that can be done with the artifact.
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

	return ..()

//===================
// Chaos Throw
//===================

/datum/artifact_effect/throwchaos
	signal_types = list(COMSIG_MOVABLE_PRE_THROW)
	effect_act_descs = list("thrown")

/datum/artifact_effect/throwchaos/register_signals(source)
	RegisterSignal(source, COMSIG_MOVABLE_PRE_THROW, PROC_REF(throw_thing_randomly))

/datum/artifact_effect/throwchaos/proc/throw_thing_randomly(datum/source, list/arguments)
	if(prob(40))
		return
	var/atom/new_throw_target = pick(view(5, source))
	if(ismovable(new_throw_target))
		arguments[1] = new_throw_target //target
		arguments[2] = 5 //range
		arguments[3] = 4 //speed

//===================
// Laughing
//===================

/datum/artifact_effect/soundindark
	requires_processing = TRUE
	effect_act_descs = list("in darkness")

/datum/artifact_effect/soundindark/process(delta_time)
	var/turf/T = get_turf(source_object)
	if(!T || T.get_lumcount())
		return
	if(prob(5))
		playsound(T, pick('sound/voice/human/womanlaugh.ogg', 'sound/voice/human/manlaugh1.ogg'), 40)

//===================
// Spasm inducing
//===================

/datum/artifact_effect/inducespasm
	signal_types = list(COMSIG_PARENT_EXAMINE)
	effect_act_descs = list("examined")

/datum/artifact_effect/inducespasm/register_signals(source)
	RegisterSignal(source, COMSIG_PARENT_EXAMINE, PROC_REF(do_effect))

/datum/artifact_effect/inducespasm/proc/do_effect(datum/source, mob/observer, list/examine_text)
	if(ishuman(observer))
		var/mob/living/carbon/human/H = observer
		H.gain_trauma(/datum/brain_trauma/mild/muscle_spasms, TRAUMA_RESILIENCE_BASIC)

//===================
// Projectile Reflector
//===================

/atom/movable/proximity_monitor_holder
	var/datum/proximity_monitor/monitor
	var/datum/callback/callback

/atom/movable/proximity_monitor_holder/Initialize(mapload, datum/proximity_monitor/_monitor, datum/callback/_callback)
	monitor = _monitor
	callback = _callback
	monitor?.hasprox_receiver = src

/atom/movable/proximity_monitor_holder/HasProximity(atom/movable/AM)
	return callback.Invoke(AM)

/atom/movable/proximity_monitor_holder/Destroy()
	QDEL_NULL(monitor)
	QDEL_NULL(callback)
	return ..()

/datum/artifact_effect/projreflect
	effect_act_descs = list("shot at")
	var/atom/movable/proximity_monitor_holder/monitor_holder

/datum/artifact_effect/projreflect/Initialize(source)
	. = ..()
	if(monitor_holder)
		QDEL_NULL(monitor_holder)
	var/datum/proximity_monitor/monitor = new(source, 3, FALSE)
	monitor_holder = new(null, monitor, CALLBACK(src, PROC_REF(HasProximity)))

/datum/artifact_effect/projreflect/Destroy()
	QDEL_NULL(monitor_holder)
	return ..()

/datum/artifact_effect/projreflect/proc/HasProximity(atom/movable/AM)
	if(istype(AM, /obj/item/projectile))
		var/obj/item/projectile/P = AM
		P.setAngle(rand(0, 360))
		P.ignore_source_check = TRUE //Allow the projectile to hit the shooter after it gets reflected

//===================
// Air Blocker
//===================

/datum/artifact_effect/airfreeze
	signal_types = list(COMSIG_MOVABLE_MOVED)
	effect_act_descs = list("depressurised")

/datum/artifact_effect/airfreeze/Initialize(atom/source)
	. = ..()
	source.CanAtmosPass = ATMOS_PASS_NO

/datum/artifact_effect/airfreeze/register_signals(source)
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(updateAir))

/datum/artifact_effect/airfreeze/proc/updateAir(atom/source, atom/oldLoc)
	if(isturf(oldLoc))
		var/turf/oldTurf = oldLoc
		oldTurf.air_update_turf(TRUE)
	if(isturf(source.loc))
		var/turf/newTurf = source.loc
		newTurf.air_update_turf(TRUE)

//===================
// Atmos Stabilizer
//===================

/datum/artifact_effect/atmosfix
	effect_act_descs = list("depressurised")
	requires_processing = TRUE

/datum/artifact_effect/atmosfix/process(delta_time)
	var/turf/T = get_turf(source_object)
	var/datum/gas_mixture/air = T.return_air()
	air.parse_gas_string(T.initial_gas_mix)

//===================
// Gravity Well
//===================

/datum/artifact_effect/gravity_well
	effect_act_descs = list("used")
	signal_types = list(COMSIG_ITEM_ATTACK_SELF)
	var/next_use_world_time = 0

/datum/artifact_effect/gravity_well/register_signals(source)
	RegisterSignal(source, COMSIG_ITEM_ATTACK_SELF, PROC_REF(suck))

/datum/artifact_effect/gravity_well/proc/suck(datum/source, mob/warper)
	if(world.time < next_use_world_time)
		return
	var/turf/T = get_turf(warper)
	if(T)
		goonchem_vortex(T, FALSE, 8)
		playsound(source_object, 'sound/magic/repulse.ogg', 60)
		next_use_world_time = world.time + 150

//===================
// Access Modifier
// Just replaces access 4noraisin
//===================

/datum/artifact_effect/access
	effect_act_descs = list("near something")
	requires_processing = TRUE
	var/next_use_time = 0

/datum/artifact_effect/access/process(delta_time)
	if(world.time < next_use_time)
		return
	next_use_time = world.time + rand(30 SECONDS, 5 MINUTES)
	var/list/idcards = list()
	var/list/things_in_view = view(5, source_object)
	for(var/mob/living/carbon/human/H in things_in_view)
		if(H.get_idcard())
			idcards += H.get_idcard()
	for(var/obj/item/card/id/id_card in things_in_view)
		idcards += id_card
	var/list/accesses_to_add = get_all_accesses()
	for(var/obj/item/card/id/id_card as() in idcards)
		if(length(id_card.card_access))
			remove_accesses_from_card(id_card.card_access, pick(id_card.card_access))
			grant_accesses_to_card(id_card.card_access, pick(accesses_to_add))

//===================
// Reality Destabilizer
//===================

GLOBAL_LIST_EMPTY(destabilization_spawns)
GLOBAL_LIST_EMPTY(destabliization_exits)

/obj/effect/landmark/destabilization_loc
	name = "destabilization spawn"

/obj/effect/landmark/destabilization_loc/Initialize(mapload)
	..()
	GLOB.destabilization_spawns += get_turf(src)
	return INITIALIZE_HINT_QDEL

/datum/artifact_effect/reality_destabilizer
	requires_processing = TRUE
	effect_act_descs = list("near something")
	var/cooldown = 0
	var/list/contained_things = list()

/datum/artifact_effect/reality_destabilizer/Initialize(source)
	. = ..()
	GLOB.destabliization_exits += source

/datum/artifact_effect/reality_destabilizer/Destroy()
	for(var/atom/movable/AM as() in contained_things)
		if(istype(get_area(AM), /area/tear_in_reality))
			AM.forceMove(get_turf(source_object))
	contained_things.Cut()
	GLOB.destabliization_exits -= source_object
	. = ..()

/datum/artifact_effect/reality_destabilizer/process(delta_time)
	if(world.time < cooldown)
		return
	cooldown = world.time + rand(0, 30 SECONDS)
	var/turf/T = get_turf(source_object)
	if(!T)
		return
	for(var/atom/movable/AM in view(3, T))
		if(AM == source_object)
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
	addtimer(CALLBACK(src, PROC_REF(restabilize), AM, get_turf(AM)), rand(10 SECONDS, 90 SECONDS))
	//Forcemove to ignore teleport checks
	AM.forceMove(pick(GLOB.destabilization_spawns))
	contained_things += AM

/datum/artifact_effect/reality_destabilizer/proc/restabilize(atom/movable/AM, turf/T)
	if(QDELETED(src))
		return
	if(QDELETED(AM))
		return
	var/area/A = get_area(AM)
	//already left the tear.
	if(!istype(A, /area/tear_in_reality))
		return
	AM.forceMove(T)
	contained_things -= AM

//===================
// Teleport
//===================

/datum/artifact_effect/warp
	signal_types = list(COMSIG_ITEM_ATTACK_SELF)
	effect_act_descs = list("used")
	var/next_use_world_time = 0

/datum/artifact_effect/warp/register_signals(source)
	RegisterSignal(source, COMSIG_ITEM_ATTACK_SELF, PROC_REF(teleport))

/datum/artifact_effect/warp/proc/teleport(datum/source, mob/warper)
	if(world.time < next_use_world_time)
		return
	var/turf/T = get_turf(warper)
	if(T)
		do_teleport(warper, pick(RANGE_TURFS(10, T)), channel = TELEPORT_CHANNEL_BLINK)
		next_use_world_time = world.time + 150

//===================
// Curse
//===================

/datum/artifact_effect/curse
	var/used = FALSE
	effect_act_descs = list("picked up")
	signal_types = list(COMSIG_ITEM_PICKUP)

/datum/artifact_effect/curse/register_signals(source)
	RegisterSignal(source, COMSIG_ITEM_PICKUP, PROC_REF(curse))

/datum/artifact_effect/curse/proc/curse(datum/source, mob/taker)
	var/mob/living/carbon/human/H = taker
	if(istype(H) && !used)
		used = TRUE
		H.gain_trauma(/datum/brain_trauma/magic/stalker, TRAUMA_LIMIT_LOBOTOMY)

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
		/datum/gas/plasma = 3,
		/datum/gas/tritium = 2,
		/datum/gas/nitryl = 1
	)
	var/datum/gas/input
	var/datum/gas/output

/datum/artifact_effect/gas_remove/Initialize(source)
	. = ..()
	input = pick_weight(valid_inputs)
	effect_act_descs = list("near gas")
	output = pick_weight(valid_outputs)

/datum/artifact_effect/gas_remove/process(delta_time)
	var/turf/T = get_turf(source_object)
	var/datum/gas_mixture/air = T.return_air()
	var/input_id = initial(input.id)
	var/output_id = initial(output.id)
	var/moles = min(air.get_moles(input_id), 5)
	if(moles)
		air.adjust_moles(input_id, -moles)
		air.adjust_moles(output_id, moles)

//===================
// Recharger
//===================

/datum/artifact_effect/recharger
	effect_act_descs = list("near something")
	requires_processing = TRUE

/datum/artifact_effect/recharger/process(delta_time)
	var/turf/T = get_turf(source_object)
	if(!T)
		return
	for(var/atom/movable/thing in view(3, T))
		var/obj/item/stock_parts/cell/C = thing.get_cell()
		if(C)
			C.give(250 * delta_time)
			thing.update_icon()

//===================
// Light Breaker
//===================

/datum/artifact_effect/light_breaker
	requires_processing = TRUE
	effect_act_descs = list("near something")
	var/next_world_time

/datum/artifact_effect/light_breaker/process(delta_time)
	if(world.time < next_world_time)
		return
	var/turf/T = get_turf(source_object)
	for(var/datum/light_source/light_source in T.light_sources)
		var/atom/movable/AM = light_source.source_atom
		//Starts at light but gets stronger the longer it is in light.
		AM.lighteater_act()
	next_world_time = world.time + rand(30 SECONDS, 5 MINUTES)

//===================
// Insanity Pulse
//===================

/datum/artifact_effect/insanity_pulse
	var/next_use_time = 0
	var/cooldown
	var/first_time = TRUE
	signal_types = list(COMSIG_ITEM_ATTACK_SELF)
	effect_act_descs = list("used")

/datum/artifact_effect/insanity_pulse/Initialize(source)
	. = ..()
	cooldown = rand(5 MINUTES, 15 MINUTES)

/datum/artifact_effect/insanity_pulse/register_signals(source)
	RegisterSignal(source, COMSIG_ITEM_ATTACK_SELF, PROC_REF(pulse))

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
