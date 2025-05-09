/datum/computer_file/data
	filetype = "DAT"
	/// Amount of characters to count as "1 GQ". 16GQ (Amount of Data Disk) reaches 5000, the paper limit.
	var/block_size = 315
	/// Stored data in string format. Use set_stored_data instead of direct assignment.
	var/stored_data = ""
	/// Whether the user will be reminded that the file probably shouldn't be edited.
	var/do_not_edit = FALSE

/datum/computer_file/data/clone()
	var/datum/computer_file/data/temp = ..()
	temp.set_stored_data(stored_data)
	return temp

/// Calculates file size from amount of characters in saved string
/datum/computer_file/data/proc/calculate_size()
	size = max(1, round(length(stored_data) / block_size))

/datum/computer_file/data/proc/set_stored_data(data)
	stored_data = data
	calculate_size()

/datum/computer_file/data/log_file
	filetype = "LOG"

