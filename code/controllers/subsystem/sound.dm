/*
 * Sound subsystem:
 * Used for things that need constant updating (sound fading in / out)
*/

SUBSYSTEM_DEF(sound_effects)
	name = "Sound"
	wait = 1
	priority = FIRE_PRIORITY_AMBIENCE
	flags = SS_NO_INIT
	//Note: Make sure you update this if you use sound fading pre-game
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/acting_effects = list()	//key = sound, value = datum
	var/list/currentrun = list()

/datum/controller/subsystem/sound_effects/fire(resumed = 0)
	if (!resumed)
		src.currentrun = acting_effects.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(LAZYLEN(currentrun))
		var/datum/sound_effect/sound_effect = currentrun[currentrun[currentrun.len]]
		currentrun.len--

		var/time_multiplier = CLAMP((world.time - sound_effect.start_tick) / (sound_effect.end_tick - sound_effect.start_tick), 0, 1)
		sound_effect.current_vol = (time_multiplier * sound_effect.out_vol) + ((1-time_multiplier) * sound_effect.in_vol)
		var/sound/S = sound_effect.sound
		S.status = SOUND_UPDATE
		S.volume = sound_effect.current_vol

		for(var/reciever in sound_effect.listeners)
			SEND_SOUND(reciever, S)

		if(world.time > sound_effect.end_tick)
			if(!sound_effect.out_vol)
				S.repeat = FALSE
			acting_effects -= sound_effect.effect_id

		if (MC_TICK_CHECK)
			return

// ===== Sound effect procs =====

/proc/sound_fade(sound/S, start_volume = 100, end_volume = 0, time = 10, var/listeners)
	//Check basics
	if(!S)
		CRASH("sound_fade called without a sound file.")
	if(!listeners)
		return
	//Check in list format
	var/listeners_list = listeners
	if(!islist(listeners_list))
		listeners_list = list(listeners)
	//Create datum
	var/datum/sound_effect/SE = new(S, listeners_list, start_volume, end_volume, time)
	//If the sound is already playing, make it fade from the current point
	if(SSsound_effects.acting_effects[SE.effect_id])
		var/datum/sound_effect/old_sound = SSsound_effects.acting_effects[SE.effect_id]
		SE.in_vol = old_sound.current_vol
	else
		SE.send_sound()
	SSsound_effects.acting_effects[SE.effect_id] = SE

// ===== Sound effect datum =====

/datum/sound_effect
	var/sound/sound
	var/list/listeners
	var/in_vol
	var/out_vol
	var/start_tick
	var/end_tick
	//Calculated
	var/current_vol
	var/effect_id

/datum/sound_effect/New(S, list/_listeners, start_vol, end_vol, time)
	. = ..()
	sound = S
	listeners = _listeners
	in_vol = start_vol
	out_vol = end_vol
	start_tick = world.time
	end_tick = world.time + time
	effect_id = generate_id()

/datum/sound_effect/proc/generate_id()
	var/id = "[sound.file]"
	for(var/A in listeners)
		id = "[id][A]"
	return id

/datum/sound_effect/proc/send_sound()
	for(var/reciever in listeners)
		SEND_SOUND(reciever, sound)
