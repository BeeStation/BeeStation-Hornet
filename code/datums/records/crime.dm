/**
 * Crime data. Used to store information about crimes.
 */
/datum/crime
	/// Name of the crime
	var/name
	/// Details about the crime
	var/details
	/// Player that wrote the crime
	var/author
	/// Time of the crime
	var/time
	/// Whether the crime is active or not
	var/valid = TRUE

/datum/crime/New(name = "Crime", details = "No details provided.", author = "Anonymous")
	src.author = author
	src.details = details
	src.name = name
	src.time = station_time_timestamp()

/datum/crime/citation
	/// Fine for the crime
	var/fine
	/// Amount of money paid for the crime
	var/paid

/datum/crime/citation/New(name = "Citation", details = "No details provided.", author = "Anonymous", fine = 0)
	. = ..()
	src.fine = fine
	src.paid = 0

/// Pays off a fine and attempts to fix any weird values.
/datum/crime/citation/proc/pay_fine(amount)
	paid += amount
	if(paid > fine)
		paid = fine

	fine -= amount
	if(fine < 0)
		fine = 0

	return TRUE

/// Sends a citation alert message to the target's PDA.
/datum/crime/citation/proc/alert_owner(mob/sender, atom/source, target_name, message)
	for(var/obj/item/modular_computer/tablet in GLOB.TabletMessengers)
		if(tablet.saved_identification != target_name)
			continue

		var/datum/signal/subspace/messaging/tablet_msg/signal = new(source, list(
			name = "Security Citation",
			job = "Citation Server",
			message = message,
			targets = list(tablet),
			automated = TRUE
		))
		signal.send_to_receivers()
		sender.log_message("(PDA: Citation Server) sent \"[message]\" to [signal.format_target()]", LOG_PDA)
		break

	return TRUE
