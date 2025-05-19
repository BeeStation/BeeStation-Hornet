/datum/antagonist/vassal/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(vassal_warning_message)
		to_chat(owner, vassal_warning_message)

/// Used when your Master teaches you a new Power.
/datum/antagonist/vassal/proc/BuyPower(datum/action/vampire/power)
	powers += power
	power.Grant(owner.current)
	log_game("[key_name(owner.current)] purchased [power] as a vassal.")

/datum/antagonist/vassal/proc/LevelUpPowers()
	for(var/datum/action/vampire/power in powers)
		power.level_current++

/// Called when we are made into the Favorite Vassal
/datum/antagonist/vassal/proc/make_special(datum/antagonist/vassal/vassal_type)
	//store what we need
	var/datum/mind/vassal_owner = owner
	var/datum/antagonist/vampire/vampiredatum = master

	//remove our antag datum
	silent = TRUE
	vassal_owner.remove_antag_datum(/datum/antagonist/vassal)

	//give our new one
	var/datum/antagonist/vassal/vassaldatum = new vassal_type(vassal_owner)
	vassaldatum.master = vampiredatum
	vassaldatum.silent = TRUE
	vassal_owner.add_antag_datum(vassaldatum)
	vassaldatum.silent = FALSE

	//send alerts of completion
	to_chat(master, span_danger("You have turned [vassal_owner.current] into your [vassaldatum.name]! They will no longer be deconverted upon Mindshielding!"))
	to_chat(vassal_owner, span_notice("As Blood drips over your body, you feel closer to your Master... You are now the [vassaldatum.name]!"))
	vassal_owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 75, FALSE, pressure_affected = FALSE)
