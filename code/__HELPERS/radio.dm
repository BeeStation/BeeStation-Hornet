// Ensure the frequency is within bounds of what it should be sending/receiving at
/proc/sanitize_frequency(frequency, free = FALSE)
	. = round(frequency)
	if(free)
		. = clamp(frequency, MIN_FREE_FREQ, MAX_FREE_FREQ)
	else
		. = clamp(frequency, MIN_FREQ, MAX_FREQ)

// Format frequency by adding kHz.
/proc/format_frequency(frequency)
	frequency = text2num(frequency)
	return "[frequency].kHz"

//Opposite of format, returns as a number
/proc/unformat_frequency(frequency)
	frequency = text2num(frequency)
	return frequency
