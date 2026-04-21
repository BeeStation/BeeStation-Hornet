///Calculate the angle between two points and the west|east coordinate
/proc/get_angle(atom/movable/start, atom/movable/end)//For beams.
	if(!start || !end)
		return 0
	var/dy
	var/dx
	dy=(32 * end.y + end.pixel_y) - (32 * start.y + start.pixel_y)
	dx=(32 * end.x + end.pixel_x) - (32 * start.x + start.pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx/dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

/// Calculate the angle produced by a pair of x and y deltas
/proc/delta_to_angle(x, y)
	if(!y)
		return (x >= 0) ? 90 : 270
	. = arctan(x/y)
	if(y < 0)
		. += 180
	else if(x < 0)
		. += 360

/// Angle between two arbitrary points and horizontal line same as [/proc/get_angle]
/proc/get_angle_raw(start_x, start_y, start_pixel_x, start_pixel_y, end_x, end_y, end_pixel_x, end_pixel_y)
	var/dy = (32 * end_y + end_pixel_y) - (32 * start_y + start_pixel_y)
	var/dx = (32 * end_x + end_pixel_x) - (32 * start_x + start_pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx/dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360

///for getting the angle when animating something's pixel_x and pixel_y
/proc/get_pixel_angle(y, x)
	if(!y)
		return (x >= 0) ? 90 : 270
	. = arctan(x/y)
	if(y < 0)
		. += 180
	else if(x < 0)
		. += 360

/**
 * Get a list of turfs in a line from `starting_atom` to `ending_atom`.
 *
 * Uses the ultra-fast [Bresenham Line-Drawing Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
 */
/proc/get_line(atom/starting_atom, atom/ending_atom)
	var/current_x_step = starting_atom.x//start at x and y, then add 1 or -1 to these to get every turf from starting_atom to ending_atom
	var/current_y_step = starting_atom.y
	var/starting_z = starting_atom.z

	var/list/line = list(get_turf(starting_atom))//get_turf(atom) is faster than locate(x, y, z)

	var/x_distance = ending_atom.x - current_x_step //x distance
	var/y_distance = ending_atom.y - current_y_step

	var/abs_x_distance = abs(x_distance)//Absolute value of x distance
	var/abs_y_distance = abs(y_distance)

	var/x_distance_sign = SIGN(x_distance) //Sign of x distance (+ or -)
	var/y_distance_sign = SIGN(y_distance)

	var/x = abs_x_distance >> 1 //Counters for steps taken, setting to distance/2
	var/y = abs_y_distance >> 1 //Bit-shifting makes me l33t.  It also makes get_line() unnecessarily fast.

	if(abs_x_distance >= abs_y_distance) //x distance is greater than y
		for(var/distance_counter in 0 to (abs_x_distance - 1))//It'll take abs_x_distance steps to get there
			y += abs_y_distance

			if(y >= abs_x_distance) //Every abs_y_distance steps, step once in y direction
				y -= abs_x_distance
				current_y_step += y_distance_sign

			current_x_step += x_distance_sign //Step on in x direction
			line += locate(current_x_step, current_y_step, starting_z)//Add the turf to the list
	else
		for(var/distance_counter in 0 to (abs_y_distance - 1))
			x += abs_x_distance

			if(x >= abs_y_distance)
				x -= abs_y_distance
				current_x_step += x_distance_sign

			current_y_step += y_distance_sign
			line += locate(current_x_step, current_y_step, starting_z)
	return line

/**
 * Formats a number into a list representing the si unit.
 * Access the coefficient with [SI_COEFFICIENT], and access the unit with [SI_UNIT].
 *
 * Supports SI exponents between 1e-15 to 1e15, but properly handles numbers outside that range as well.
 * Arguments:
 * * value - The number to convert to text. Can be positive or negative.
 * * unit - The base unit of the number, such as "Pa" or "W".
 * * maxdecimals - Maximum amount of decimals to display for the final number. Defaults to 1.
 * Returns: [SI_COEFFICIENT = si unit coefficient, SI_UNIT = prefixed si unit.]
 */
/proc/siunit_isolated(value, unit, maxdecimals=1)
	var/static/list/prefixes = list("q","r","y","z","a","f","p","n","μ","m","","k","M","G","T","P","E","Z","Y","R","Q")

	// We don't have prefixes beyond this point
	// and this also captures value = 0 which you can't compute the logarithm for
	// and also byond numbers are floats and doesn't have much precision beyond this point anyway
	if(abs(value) < 1e-30)
		. = list(SI_COEFFICIENT = 0, SI_UNIT = " [unit]")
		return

	var/exponent = clamp(log(10, abs(value)), -30, 30) // Calculate the exponent and clamp it so we don't go outside the prefix list bounds
	var/divider = 10 ** (round(exponent / 3) * 3) // Rounds the exponent to nearest SI unit and power it back to the full form
	var/coefficient = round(value / divider, 10 ** -maxdecimals) // Calculate the coefficient and round it to desired decimals
	var/prefix_index = round(exponent / 3) + 11 // Calculate the index in the prefixes list for this exponent

	// An edge case which happens if we round 999.9 to 0 decimals for example, which gets rounded to 1000
	// In that case, we manually swap up to the next prefix if there is one available
	if(coefficient >= 1000 && prefix_index < 21)
		coefficient /= 1e3
		prefix_index++

	var/prefix = prefixes[prefix_index]
	. = list(SI_COEFFICIENT = coefficient, SI_UNIT = " [prefix][unit]")

/**
 * Format an energy value in prefixed joules.
 * Arguments
 *
 * * units - the value t convert
 */
/proc/display_energy(units)
	return siunit(units, "J", 3)

/// Format a power value in W, kW, MW, GW.
/proc/display_power(powerused)
	if(powerused < 1000)
		return "[powerused] W"	//Watt equivalent
	else if(powerused < 1000000)
		return "[round((powerused * 0.001), 0.1)] kW"	//KiloWatt equivalent
	else if(powerused < 1000000000)
		return "[round((powerused * 0.000001), 0.1)] MW"	//MegaWatt equivalent
	return "[round((powerused * 0.000000001), 0.1)] GW"	//Gigawatt equivalent

/// Format power value per second
/proc/display_power_persec(powerused)
	if(powerused < 1000)
		return "[powerused] W/s"	//Watt/s equivalent
	else if(powerused < 1000000)
		return "[round((powerused * 0.001), 0.1)] kW/s"	//KiloWatt/s equivalent
	else if(powerused < 1000000000)
		return "[round((powerused * 0.000001), 0.1)] MW/s"	//MegaWatt/s equivalent
	return "[round((powerused * 0.000000001), 0.1)] GW/s"	//GigaWatt/s equivalent

///counts the number of bits in Byond's 16-bit width field, in constant time and memory!
/proc/bit_count(bit_field)
	var/temp = bit_field - ((bit_field >> 1) & 46811) - ((bit_field >> 2) & 37449) //0133333 and 0111111 respectively
	temp = ((temp + (temp >> 3)) & 29127) % 63 //070707
	return temp

/**
 * random code generator (only numbers)
 * This returns a string
 * Arguments
 * n_length - length of the random code
 *
**/
/proc/random_code(n_length = 0)
	if(!n_length) //incase someone forgets to say how long they want the code to be
		stack_trace("No code length forwarded as argument")
	while(length(.) < n_length)
		. += "[rand(0, 9)]" // we directly write into the return value (.) here
