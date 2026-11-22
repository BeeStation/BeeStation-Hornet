/// Logs the contents of the gasmix to the game log, prefixed by text
/proc/log_atmos(text, datum/gas_mixture/gas_mixture)
	var/message = "[text]\"[print_gas_mixture(gas_mixture)]\""
	log_game(message)
