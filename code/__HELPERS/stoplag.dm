//Key thing that stops lag. Cornerstone of performance in ss13, finally sitting in it's own file, as it should be.

//Increases delay as the server gets more overloaded, as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

/// Returns the number of ticks slept
/proc/stoplag(initial_delay)
	//No master controller active, sleep for the tick lag to allow other things to run
	if (!Master || !(Master.current_runlevel & RUNLEVELS_DEFAULT))
		sleep(world.tick_lag)
		return 1
	//Set the default initial delay, if one isn't provided
	if (!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	//Begin tracking if we are in debugging
	//Calculate the delay in terms of ticks
	var/i = DS2TICKS(initial_delay)
	do
		//Increment the total amount of time slept
		. += CEILING(i*DELTA_CALC, 1)
		//Sleep and allow other processes to run
		sleep(i*world.tick_lag*DELTA_CALC)
		//Sleep for double the time as before, sleeping incurs overhead so the longer something sleeps
		//the less we check for wake ups
		i *= 2
	//Repeat until we have some tick left
	while (TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

#define UNTIL(X) while(!(X)) stoplag()
