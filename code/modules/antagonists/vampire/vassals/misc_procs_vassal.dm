/datum/antagonist/vassal/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER

	if(!owner?.current)
		return
	to_chat(owner, vampire_warning_message)

	switch(danger_level)
		if(DANGER_LEVEL_FIRST_WARNING)
			owner.current.playsound_local(null, 'sound/vampires/griffin_3.ogg', 50, TRUE)
		if(DANGER_LEVEL_SECOND_WARNING)
			owner.current.playsound_local(null, 'sound/vampires/griffin_5.ogg', 50, TRUE)
		if(DANGER_LEVEL_THIRD_WARNING)
			owner.current.playsound_local(null, 'sound/effects/alert.ogg', 75, TRUE)
		if(DANGER_LEVEL_SOL_ROSE)
			owner.current.playsound_local(null, 'sound/ambience/ambimystery.ogg', 75, TRUE)
		if(DANGER_LEVEL_SOL_ENDED)
			owner.current.playsound_local(null, 'sound/misc/ghosty_wind.ogg', 90, TRUE)

/// Used when your Master teaches you a new Power.
/datum/antagonist/vassal/proc/grant_power(datum/action/vampire/power)
	powers += power
	power.Grant(owner.current)
	log_game("[key_name(owner.current)] has received \"[power]\" as a vassal")
