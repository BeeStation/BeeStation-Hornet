/datum/computer_file/data
	filetype = "DAT"
	/// Amount of data to count as "1 GQ"
	var/block_size = 0
	/// Stored data of the file. Use set_stored_data instead of direct assignment.
	var/stored_data
	/// Whether the user will be reminded that the file probably shouldn't be edited.
	var/do_not_edit = FALSE

/datum/computer_file/data/clone()
	var/datum/computer_file/data/temp = ..()
	temp.set_stored_data(stored_data)
	return temp

/// Calculates file size from the stored data
/datum/computer_file/data/proc/calculate_size()
	return 1

/datum/computer_file/data/proc/set_stored_data(data)
	stored_data = data
	calculate_size()



/datum/computer_file/data/text
	filetype = "TXT"
	/// Amount of characters to count as "1 GQ"
	block_size = 250

/// Calculates file size from amount of characters in saved string
/datum/computer_file/data/text/calculate_size()
	size = max(1, round(length(stored_data) / block_size))

/datum/computer_file/data/text/set_stored_data(data)
	if(!istext(data))
		CRASH("MOD_COMPUTERS: Invalid data write attempt on a [src.type]")
	. = ..()

/datum/computer_file/data/text/log_file
	filetype = "LOG"


// /datum/picture
/datum/computer_file/data/picture
	filetype = "PIC"
	do_not_edit = TRUE
	///Amount of tiles per GC of data - The area of the photo taken up
	block_size = 4
	/// The path the RCS uses to refer to `file_data.picture_image` when sharing with clients
	var/image_path

/datum/computer_file/data/picture/clone()
	var/datum/computer_file/data/picture/temp = ..()
	temp.image_path = image_path
	return temp

/datum/computer_file/data/picture/set_stored_data(data)
	if(!istype(data, /datum/picture))
		CRASH("MOD_COMPUTERS: Invalid data write attempt on a [src.type]")
	. = ..()

/datum/computer_file/data/picture/calculate_size()
	var/datum/picture/pic = stored_data
	if(!pic)
		CRASH("MOD_COMPUTER: Invalid data while calculating data size of [src.type]")
	var/tiles = ((pic.psize_x / 96) * (pic.psize_y/ 96))
	size = max(1, round(tiles / block_size))
