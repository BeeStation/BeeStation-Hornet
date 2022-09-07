/datum/orbital_comms_manager
	/// The name
	var/messenger_name
	/// Manager name
	var/messenger_id
	/// List of messages
	var/list/datum/orbital_communication_message/messages = list()

/datum/orbital_comms_manager/New(id, name)
	. = ..()
	messenger_id = id
	messenger_name = name

/datum/orbital_comms_manager/Destroy(force, ...)
	. = ..()
	SSorbits.communication_managers -= messenger_id

/datum/orbital_comms_manager/proc/send_emergency_message_to(target_id, message)
	//Get the thing we want to talk to
	var/datum/orbital_comms_manager/target = SSorbits.communication_managers[target_id]
	if(!target)
		return
	target.handle_emergency_message(src, message)

/datum/orbital_comms_manager/proc/send_message_to(target_id, message)
	//Get the thing we want to talk to
	var/datum/orbital_comms_manager/target = SSorbits.communication_managers[target_id]
	if(!target)
		return
	target.handle_message(src, message)

/datum/orbital_comms_manager/proc/handle_emergency_message(datum/orbital_comms_manager/source, message)
	handle_message(source, message, TRUE)

/datum/orbital_comms_manager/proc/handle_message(datum/orbital_comms_manager/source, message, emergency = FALSE)
	//Our message
	var/datum/orbital_communication_message/our_message = new()
	our_message.source = messenger_id
	our_message.message = message
	our_message.sourced_locally = TRUE
	source.messages += our_message
	//Their message
	var/datum/orbital_communication_message/new_message = new()
	new_message.source = source.messenger_id
	new_message.message = message
	messages += new_message
	//Send them a signal
	SEND_SIGNAL(src, COMSIG_COMMUNICATION_RECEIEVED, source.messenger_id, message, emergency)

/datum/orbital_comms_manager/proc/get_ui_data()
	var/data = list()
	data["messages"] = list()

	for(var/datum/orbital_communication_message/message as() in messages)
		if (!data["messages"][message.source])
			data["messages"][message.source] = list()
		data["messages"][message.source] += list(list(
			"sourced_locally" = message.sourced_locally,
			"message" = message.message,
		))

	return data
