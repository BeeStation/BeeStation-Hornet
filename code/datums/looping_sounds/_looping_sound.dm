/*
	output_atoms	(list of atoms)			The destination(s) for the sounds

	mid_sounds		(list or soundfile)		Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	mid_length		(num)					The length to wait between playing mid_sounds

	start_sound		(soundfile)				Played before starting the mid_sounds loop
	start_length	(num)					How long to wait before starting the main loop after playing start_sound

	end_sound		(soundfile)				The sound played after the main loop has concluded

	chance			(num)					Chance per loop to play a mid_sound
	volume			(num)					Sound output volume
	max_loops		(num)					The max amount of loops to run for.
	direct			(bool)					If true plays directly to provided atoms instead of from them
*/
/datum/looping_sound
	var/atom/parent
	var/mid_sounds
	var/mid_length
	var/start_sound
	var/start_length
	var/end_sound
	var/chance
	var/volume = 100
	var/max_loops
	var/direct
	var/extra_range

	var/timerid
	var/skip_starting_sounds = FALSE
	var/loop_started = FALSE

/datum/looping_sound/New(_parent, start_immediately=FALSE, _direct=FALSE, _skip_starting_sounds = FALSE)
	if(!mid_sounds)
		WARNING("A looping sound datum was created without sounds to play.")
		return

	set_parent(_parent)
	direct = _direct
	skip_starting_sounds = _skip_starting_sounds

	if(start_immediately)
		start()

/datum/looping_sound/Destroy()
	stop(TRUE)
	return ..()

/datum/looping_sound/proc/start(on_behalf_of)
	if(on_behalf_of)
		set_parent(on_behalf_of)
	if(timerid)
		return
	on_start()

/datum/looping_sound/proc/stop(null_parent)
	if(null_parent)
		set_parent(null)
	if(!timerid)
		return
	on_stop()
	deltimer(timerid, SSsound_loops)
	timerid = null
	loop_started = FALSE

/datum/looping_sound/proc/start_sound_loop()
	loop_started = TRUE
	sound_loop()
	timerid = addtimer(CALLBACK(src, PROC_REF(sound_loop), world.time), mid_length, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME, SSsound_loops)

/datum/looping_sound/proc/sound_loop(starttime)
	if(max_loops && world.time >= starttime + mid_length * max_loops)
		stop()
		return
	if(!chance || prob(chance))
		play(get_sound(starttime))

/datum/looping_sound/proc/play(soundfile)
	var/sound/S = sound(soundfile)
	if(direct)
		S.channel = SSsounds.random_available_channel()
		S.volume = volume
		SEND_SOUND(parent, S)
	else
		playsound(parent, S, volume, extra_range)

/datum/looping_sound/proc/get_sound(starttime, _mid_sounds)
	. = _mid_sounds || mid_sounds
	while(!isfile(.) && !isnull(.))
		. = pickweight(.)

/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	if(start_sound && !skip_starting_sounds)
		play(start_sound)
		start_wait = start_length
	timerid = addtimer(CALLBACK(src, PROC_REF(start_sound_loop)), start_wait, TIMER_CLIENT_TIME | TIMER_DELETE_ME | TIMER_STOPPABLE, SSsound_loops)

/datum/looping_sound/proc/on_stop()
	if(end_sound && loop_started)
		play(end_sound)

/datum/looping_sound/proc/set_parent(new_parent)
	if(parent)
		UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	parent = new_parent
	if(parent)
		RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(handle_parent_del))

/datum/looping_sound/proc/handle_parent_del(datum/source)
	SIGNAL_HANDLER
	set_parent(null)
