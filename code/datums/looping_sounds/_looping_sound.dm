/**
 * A datum for sounds that need to loop, with a high amount of configurability.
 */
/datum/looping_sound
	/// The source of the sound, or the recipient of the sound.
	var/atom/parent
	/// (list or soundfile) Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	var/mid_sounds
	/// The length of time to wait between playing mid_sounds.
	var/mid_length
	/// Override for volume of start sound.
	var/start_volume
	/// (soundfile) Played before starting the mid_sounds loop.
	var/start_sound
	/// How long to wait before starting the main loop after playing start_sound.
	var/start_length
	/// Override for volume of end sound.
	var/end_volume
	/// (soundfile) The sound played after the main loop has concluded.
	var/end_sound
	/// Chance per loop to play a mid_sound.
	var/chance
	/// Sound output volume.
	var/volume = 100
	/// Whether or not the sounds will vary in pitch when played.
	var/vary = FALSE
	/// The max amount of loops to run for.
	var/max_loops
	/// If true, plays directly to provided atoms instead of from them.
	var/direct
	/// The extra range of the sound in tiles, defaults to 0.
	var/extra_range = 0
	/// The ID of the timer that's used to loop the sounds.
	var/timer_id
	/// How much the sound will be affected by falloff per tile.
	var/falloff_exponent
	/// The falloff distance of the sound,
	var/falloff_distance
	/// Do we skip the starting sounds?
	var/skip_starting_sounds = FALSE
	/// Are the sounds affected by pressure? Defaults to TRUE.
	var/pressure_affected = TRUE
	/// Are the sounds subject to reverb? Defaults to TRUE.
	var/use_reverb = TRUE
	/// Are we ignoring walls? Defaults to TRUE.
	var/ignore_walls = TRUE
	/// Has the looping started yet?
	var/loop_started = FALSE

/datum/looping_sound/New(_parent, start_immediately = FALSE, _direct = FALSE, _skip_starting_sounds = FALSE)
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

/**
 * The proc to actually kickstart the whole sound sequence. This is what you should call to start the `looping_sound`.
 *
 * Arguments:
 * * on_behalf_of - The new object to set as a parent.
 */
/datum/looping_sound/proc/start(on_behalf_of)
	if(on_behalf_of)
		set_parent(on_behalf_of)
	if(timer_id)
		return
	on_start()

/**
 * The proc to call to stop the sound loop.
 *
 * Arguments:
 * * null_parent - Whether or not we should set the parent to null (useful when destroying the `looping_sound` itself). Defaults to FALSE.
 */
/datum/looping_sound/proc/stop(null_parent)
	if(null_parent)
		set_parent(null)
	if(!timer_id)
		return
	on_stop()
	deltimer(timer_id, SSsound_loops)
	timer_id = null
	loop_started = FALSE

/// The proc that handles starting the actual core sound loop.
/datum/looping_sound/proc/start_sound_loop()
	loop_started = TRUE
	sound_loop()
	timer_id = addtimer(CALLBACK(src, PROC_REF(sound_loop), world.time), mid_length, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME, SSsound_loops)

/**
 * A simple proc handling the looping of the sound itself.
 *
 * Arguments:
 * * start_time - The time at which the `mid_sounds` started being played (so we know when to stop looping).
 */
/datum/looping_sound/proc/sound_loop(start_time)
	if(max_loops && world.time >= start_time + mid_length * max_loops)
		stop()
		return
	if(!chance || prob(chance))
		play(get_sound())

/**
 * The proc that handles actually playing the sound.
 *
 * Arguments:
 * * soundfile - The soundfile we want to play.
 * * volume_override - The volume we want to play the sound at, overriding the `volume` variable.
 */
/datum/looping_sound/proc/play(soundfile, volume_override)
	var/sound/sound_to_play = sound(soundfile)
	if(direct)
		sound_to_play.channel = SSsounds.random_available_channel()
		sound_to_play.volume = volume_override || volume //Use volume as fallback if theres no override
		SEND_SOUND(parent, sound_to_play)
	else
		playsound(
			parent,
			sound_to_play,
			volume,
			vary,
			extra_range,
			falloff_exponent = falloff_exponent,
			pressure_affected = pressure_affected,
			ignore_walls = ignore_walls,
			falloff_distance = falloff_distance,
			use_reverb = use_reverb
		)

/// Returns the sound we should now be playing.
/datum/looping_sound/proc/get_sound(_mid_sounds)
	. = _mid_sounds || mid_sounds
	while(!isfile(.) && !isnull(.))
		. = pick_weight(.)

/// A proc that's there to handle delaying the main sounds if there's a start_sound, and simply starting the sound loop in general.
/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	if(start_sound && !skip_starting_sounds)
		play(start_sound, start_volume)
		start_wait = start_length
	timer_id = addtimer(CALLBACK(src, PROC_REF(start_sound_loop)), start_wait, TIMER_CLIENT_TIME | TIMER_DELETE_ME | TIMER_STOPPABLE, SSsound_loops)

/// Simple proc that's executed when the looping sound is stopped, so that the `end_sound` can be played, if there's one.
/datum/looping_sound/proc/on_stop()
	if(end_sound && loop_started)
		play(end_sound, end_volume)

/// A simple proc to change who our parent is set to, also handling registering and unregistering the QDELETING signals on the parent.
/datum/looping_sound/proc/set_parent(new_parent)
	if(parent)
		UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	parent = new_parent
	if(parent)
		RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(handle_parent_del))

/// A simple proc that lets us know whether the sounds are currently active or not.
/datum/looping_sound/proc/is_active()
	return !!timer_id

/// A simple proc to handle the deletion of the parent, so that it does not force it to hard-delete.
/datum/looping_sound/proc/handle_parent_del(datum/source)
	SIGNAL_HANDLER
	set_parent(null)
