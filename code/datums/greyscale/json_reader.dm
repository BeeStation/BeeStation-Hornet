/// Takes a json list and extracts a single value.
/// Subtypes represent different conversions of that value.
/datum/json_reader

/// Takes a value read directly from json and verifies/converts as needed to a result
/datum/json_reader/proc/ReadJson(value)
	return

/datum/json_reader/text/ReadJson(value)
	if(!istext(value))
		CRASH("Text value expected but got '[value]'")
	return value

/datum/json_reader/number/ReadJson(value)
	var/newvalue = text2num(value)
	if(!isnum(newvalue))
		CRASH("Number expected but got [newvalue]")
	return newvalue

/datum/json_reader/number_color_list/ReadJson(list/value)
	if(!istype(value))
		CRASH("Expected a list but got [value]")
	var/list/new_values = list()
	for(var/number_string in value)
		var/new_value = text2num(number_string)
		if(!isnum(new_value))
			if(!istext(number_string) || number_string[1] != "#")
				stack_trace("Expected list to only contain numbers or colors but got '[number_string]'")
				continue
			new_value = number_string
		new_values += new_value
	return new_values

/datum/json_reader/blend_mode
	var/static/list/blend_modes = list(
		"add" = ICON_ADD,
		"subtract" = ICON_SUBTRACT,
		"multiply" = ICON_MULTIPLY,
		"or" = ICON_OR,
		"overlay" = ICON_OVERLAY,
		"underlay" = ICON_UNDERLAY,
	)

/datum/json_reader/blend_mode/ReadJson(value)
	var/new_value = blend_modes[lowertext(value)]
	if(isnull(new_value))
		CRASH("Blend mode expected but got '[value]'")
	return new_value

/datum/json_reader/greyscale_config/ReadJson(value)
	var/newvalue = SSgreyscale.configurations[value]
	if(!newvalue)
		CRASH("Greyscale configuration type expected but got '[value]'")
	return newvalue
