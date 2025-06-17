/**
 * Player-written medical note.
 */
/datum/medical_note
	/// Player that wrote the note
	var/author
	/// Details of the note
	var/content
	/// Station timestamp
	var/time

/datum/medical_note/New(author = "Anonymous", content = "No details provided.")
	src.author = author
	src.content = content
	src.time = station_time_timestamp()

/datum/medical_note/proc/get_info_list()
	return list(
			author = src.author,
			content = src.content,
			note_ref = FAST_REF(src),
			time = src.time
		)
