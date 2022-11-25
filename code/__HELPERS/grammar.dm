/// Returns a list in plain english as a string
/proc/english_list(list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = length(input)
	switch(total)
		if (0)
			return "[nothing_text]"
		if (1)
			return "[input[1]]"
		if (2)
			return "[input[1]][and_text][input[2]]"
		else
			var/output = ""
			var/index = 1
			while (index < total)
				if (index == total - 1)
					comma_text = final_comma_text

				output += "[input[index]][comma_text]"
				index++

			return "[output][and_text][input[index]]"

/// Makes the first letter of a string to capital
/proc/replace_first_letter_to_capital(string)
	if(!string)
		return ""
	if(!istext(string))
		return string

	var/return_string = uppertext(string[1])
	var/count = 1
	for(var/each in splittext(string,1))
		if(count)
			count-- // I don't know why, but putting count-- to if condition doesn't work this.
			continue
		return_string += each
	return return_string
