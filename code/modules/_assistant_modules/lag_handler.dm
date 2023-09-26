GLOBAL_LIST_EMPTY(assistant_modules_lag_handlers)

/datum/lag_handler
	/// whenever count meets max_count, it triggers sleep() proc.
	var/_count = 0
	var/_max_count
	var/_base_max_count
	var/_sleep_duration
	/// max_count will be randomly determined with this value
	var/_rand_range

	// for every specific time interval, resets count.
	var/_count_timeout_interval
	COOLDOWN_DECLARE(count_timeout)

	/// used to prevent reset when it's static
	var/_currently_triggered = 0

/datum/lag_handler/New(id, max_count=100, sleep_duration=5, rand_range=0, timeout=0)
	if(!id || isnum(id))
		CRASH("lag handler has been created without id, or id being number. It should have a string.")
	if(GLOB.assistant_modules_lag_handlers[id])
		CRASH("lag handler '[id]' already exists. Was it supposed to be static?")
	GLOB.assistant_modules_lag_handlers[id] = src
	_base_max_count = max_count
	_sleep_duration = sleep_duration
	_count_timeout_interval = timeout

/datum/lag_handler/proc/_calculate_max_count()
	_max_count = max(1, _base_max_count + rand(0, _rand_range))

/datum/lag_handler/proc/start_lag_handle()
	_currently_triggered++

/datum/lag_handler/proc/finish_lag_handle()
	_currently_triggered--

/datum/lag_handler/proc/handle_lag()
	check_count_timeout()
	_count++
	if(_count >= _max_count)
		_count = 0
		_calculate_max_count()
		sleep(_sleep_duration)

/datum/lag_handler/proc/check_count_timeout()
	if(!_count_timeout_interval || _currently_triggered)
		return
	// if lag handler is not called again until timeout is expired, resets count to 0.
	if(COOLDOWN_FINISHED(src, count_timeout))
		lag_check_reset()
	COOLDOWN_START(src, count_timeout, _count_timeout_interval)

/datum/lag_handler/proc/lag_check_reset()
	if(_currently_triggered)
		return
	_count = 0
