/// Used when your Master teaches you a new Power.
/datum/antagonist/vassal/proc/grant_power(datum/action/vampire/power)
	powers += power
	power.Grant(owner.current)
	log_game("[key_name(owner.current)] has received \"[power]\" as a vassal")
