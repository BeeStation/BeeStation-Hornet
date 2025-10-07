/// How long Sol lasts
#define TIME_VAMPIRE_DAY 60
/// The grace period inbetween Sol
#define TIME_VAMPIRE_NIGHT 600
/// First audio warning that Sol is coming
#define TIME_VAMPIRE_DAY_WARN 90
/// Second audio warning that Sol is coming
#define TIME_VAMPIRE_DAY_FINAL_WARN 30
/// Final audio warning that Sol is coming
#define TIME_VAMPIRE_BURN_INTERVAL 5

///How much time Sol can be 'off' by, keeping the time inconsistent.
#define TIME_VAMPIRE_SOL_DELAY 90

SUBSYSTEM_DEF(sunlight)
	name = "Sol"
	can_fire = FALSE
	wait = 2 SECONDS
	flags = SS_NO_INIT | SS_BACKGROUND | SS_TICKER

	///If the Sun is currently out our not.
	var/sunlight_active = FALSE
	///The time between the next cycle, randomized every night.
	var/time_til_cycle = TIME_VAMPIRE_NIGHT
	///If Vampire levels for the night has been given out yet.
	var/issued_XP = FALSE

/datum/controller/subsystem/sunlight/fire(resumed = FALSE)
	time_til_cycle--
	if(sunlight_active)
		if(time_til_cycle > 0)
			SEND_SIGNAL(src, COMSIG_SOL_RISE_TICK)
			if(!issued_XP && time_til_cycle <= 15)
				issued_XP = TRUE
				SEND_SIGNAL(src, COMSIG_SOL_NEAR_END)
		if(time_til_cycle <= 1)
			sunlight_active = FALSE
			issued_XP = FALSE
			//randomize the next sol timer
			time_til_cycle = round(rand((TIME_VAMPIRE_NIGHT-TIME_VAMPIRE_SOL_DELAY), (TIME_VAMPIRE_NIGHT+TIME_VAMPIRE_SOL_DELAY)), 1)
			message_admins("VAMPIRE NOTICE: Daylight Ended. Resetting to Night (Lasts for [time_til_cycle / 60] minutes.")
			SEND_SIGNAL(src, COMSIG_SOL_END)
			warn_daylight(
				danger_level = DANGER_LEVEL_SOL_ENDED,
				vampire_warning_message = span_announce("The solar flare has ended, and the daylight danger has passed... for now."),
				vassal_warning_message = span_announce("The solar flare has ended, and the daylight danger has passed... for now."),
			)
		return

	switch(time_til_cycle)
		if(TIME_VAMPIRE_DAY_WARN)
			SEND_SIGNAL(src, COMSIG_SOL_NEAR_START)
			warn_daylight(
				danger_level = DANGER_LEVEL_FIRST_WARNING,
				vampire_warning_message = span_danger("Solar Flares will bombard the station with dangerous UV radiation in [TIME_VAMPIRE_DAY_WARN / 60] minutes. <b>Prepare to seek cover in a coffin or closet.</b>")
			)
		if(TIME_VAMPIRE_DAY_FINAL_WARN)
			message_admins("VAMPIRE NOTICE: Daylight beginning in [TIME_VAMPIRE_DAY_FINAL_WARN] seconds.")
			warn_daylight(
				danger_level = DANGER_LEVEL_SECOND_WARNING,
				vampire_warning_message = span_danger("Solar Flares are about to bombard the station! You have [TIME_VAMPIRE_DAY_FINAL_WARN] seconds to find cover!"),
				vassal_warning_message = span_danger("In [TIME_VAMPIRE_DAY_FINAL_WARN] seconds, your master will be at risk of a Solar Flare. Make sure they find cover!"),
			)
		if(TIME_VAMPIRE_BURN_INTERVAL)
			warn_daylight(
				danger_level = DANGER_LEVEL_THIRD_WARNING,
				vampire_warning_message = span_danger("Seek cover, for Sol rises!"),
			)
		if(NONE)
			sunlight_active = TRUE
			//set the timer to countdown daytime now.
			time_til_cycle = TIME_VAMPIRE_DAY
			message_admins("VAMPIRE NOTICE: Daylight Beginning (Lasts for [TIME_VAMPIRE_DAY / 60] minutes.)")
			warn_daylight(
				danger_level = DANGER_LEVEL_SOL_ROSE,
				vampire_warning_message = span_danger("Solar flares bombard the station with deadly UV light! Stay in cover for the next [TIME_VAMPIRE_DAY / 60] minute\s!"),
				vassal_warning_message = span_danger("Solar flares bombard the station with UV light!"),
			)

/datum/controller/subsystem/sunlight/proc/warn_daylight(danger_level, vampire_warning_message, vassal_warning_message)
	SEND_SIGNAL(src, COMSIG_SOL_WARNING_GIVEN, danger_level, vampire_warning_message, vassal_warning_message)

#undef TIME_VAMPIRE_SOL_DELAY

#undef TIME_VAMPIRE_DAY
#undef TIME_VAMPIRE_NIGHT
#undef TIME_VAMPIRE_DAY_WARN
#undef TIME_VAMPIRE_DAY_FINAL_WARN
#undef TIME_VAMPIRE_BURN_INTERVAL
