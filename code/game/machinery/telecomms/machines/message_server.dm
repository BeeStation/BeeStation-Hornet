/*
	The equivalent of the server, for PDA and request console messages.
	Without it, PDA and request console messages cannot be transmitted.
	PDAs require the rest of the telecomms setup, but request consoles only
	require the message server.
*/

// A decorational representation of SSblackbox, usually placed alongside the message server. Also contains a traitor theft item.
/obj/machinery/blackbox_recorder
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	name = "Blackbox Recorder"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	armor_type = /datum/armor/machinery_blackbox_recorder
	var/obj/item/stored
	investigate_flags = ADMIN_INVESTIGATE_TARGET


/datum/armor/machinery_blackbox_recorder
	melee = 25
	bullet = 10
	laser = 10
	fire = 50
	acid = 70

/obj/machinery/blackbox_recorder/Initialize(mapload)
	. = ..()
	stored = new /obj/item/blackbox(src)

/obj/machinery/blackbox_recorder/attack_hand(mob/living/user)
	. = ..()
	if(stored)
		user.put_in_hands(stored)
		stored = null
		to_chat(user, span_notice("You remove the blackbox from [src]. The tapes stop spinning."))
		update_icon()
	else
		to_chat(user, span_warning("It seems that the blackbox is missing..."))

/obj/machinery/blackbox_recorder/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/blackbox))
		if(HAS_TRAIT(I, TRAIT_NODROP) || !user.transferItemToLoc(I, src))
			to_chat(user, span_warning("[I] is stuck to your hand!"))
			return
		user.visible_message(span_notice("[user] clicks [I] into [src]!"), \
		span_notice("You press the device into [src], and it clicks into place. The tapes begin spinning again."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		stored = I
		update_icon()

/obj/machinery/blackbox_recorder/Destroy()
	if(stored)
		stored.forceMove(loc)
		new /obj/effect/decal/cleanable/oil(loc)
	return ..()

/obj/machinery/blackbox_recorder/update_icon_state()
	if(stored)
		icon_state = "blackbox"
	else
		icon_state = "blackbox_b"
	return ..()
/obj/item/blackbox
	name = "the blackbox"
	desc = "A strange relic, capable of recording data on extradimensional vertices. It lives inside the blackbox recorder for safe keeping."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackcube"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_LARGE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

#define MESSAGE_SERVER_FUNCTIONING_MESSAGE "This is an automated message. The messaging system is functioning correctly."

// The message server itself.
/obj/machinery/telecomms/message_server
	icon_state = "message_server"
	name = "Messaging Server"
	desc = "A machine that processes and routes PDA and request console messages."
	telecomms_type = /obj/machinery/telecomms/message_server
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 40
	circuit = /obj/item/circuitboard/machine/telecomms/message_server

	var/list/datum/data_tablet_msg/modular_msgs = list()
	var/list/datum/data_rc_msg/rc_msgs = list()
	var/decryptkey = "password"
	var/calibrating = 15 MINUTES //Init reads this and adds world.time, then becomes 0 when that time has passed and the machine works

/obj/machinery/telecomms/message_server/Initialize(mapload)
	. = ..()
	if (!decryptkey)
		decryptkey = GenerateKey()

	if (calibrating)
		calibrating += world.time
		say("Calibrating... Estimated wait time: [rand(3, 9)] minutes.")
		modular_msgs += new /datum/data_tablet_msg("System Administrator", "system", "This is an automated message. System calibration started at [station_time_timestamp()].")
	else
		modular_msgs += new /datum/data_tablet_msg("System Administrator", "system", MESSAGE_SERVER_FUNCTIONING_MESSAGE)

/obj/machinery/telecomms/message_server/examine(mob/user)
	. = ..()
	if(calibrating)
		. += span_warning("It's still calibrating.")

/obj/machinery/telecomms/message_server/proc/GenerateKey()
	var/newKey
	newKey += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	newKey += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	newKey += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return newKey

/obj/machinery/telecomms/message_server/process()
	. = ..()
	if(calibrating && calibrating <= world.time)
		calibrating = 0
		modular_msgs += new /datum/data_tablet_msg("System Administrator", "system", MESSAGE_SERVER_FUNCTIONING_MESSAGE)

/obj/machinery/telecomms/message_server/receive_information(datum/signal/subspace/messaging/signal, obj/machinery/telecomms/machine_from)
	// can't log non-message signals
	if(!istype(signal) || !signal.data["message"] || !on || calibrating)
		return

	// log the signal
	if(istype(signal, /datum/signal/subspace/messaging/tablet_msg))
		var/datum/signal/subspace/messaging/tablet_msg/PDAsignal = signal
		var/datum/data_tablet_msg/msg = new(PDAsignal.format_target(), "[PDAsignal.data["name"]] ([PDAsignal.data["job"]])", PDAsignal.data["message"], PDAsignal.data["photo"], PDAsignal.data["emojis"])
		modular_msgs += msg
		signal.logged = msg
	else if(istype(signal, /datum/signal/subspace/messaging/rc))
		var/datum/data_rc_msg/msg = new(signal.data["rec_dpt"], signal.data["send_dpt"], signal.data["message"], signal.data["stamped"], signal.data["verified"], signal.data["priority"])
		signal.logged = msg
		if(signal.data["send_dpt"]) // don't log messages not from a department but allow them to work
			rc_msgs += msg
	signal.data["reject"] = FALSE

	// pass it along to either the hub or the broadcaster
	if(!relay_information(signal, /obj/machinery/telecomms/hub))
		relay_information(signal, /obj/machinery/telecomms/broadcaster)

/obj/machinery/telecomms/message_server/update_icon()
	..()
	cut_overlays()
	if(calibrating)
		add_overlay("message_server_calibrate")


// Root messaging signal datum
/datum/signal/subspace/messaging
	frequency = FREQ_COMMON
	server_type = /obj/machinery/telecomms/message_server
	var/datum/logged

/datum/signal/subspace/messaging/New(init_source, init_data)
	source = init_source
	data = init_data
	var/turf/T = get_turf(source)
	levels = list(T.get_virtual_z_level())
	if(!("reject" in data))
		data["reject"] = TRUE

/datum/signal/subspace/messaging/copy()
	var/datum/signal/subspace/messaging/copy = new type(source, data.Copy())
	copy.original = src
	copy.levels = levels
	return copy

// Tablet message signal datum
/datum/signal/subspace/messaging/tablet_msg/proc/format_target()
	if (length(data["targets"]) > 1)
		return "Everyone"
	var/obj/item/modular_computer/target = data["targets"][1]
	return "[target.saved_identification] ([target.saved_job])"

/datum/signal/subspace/messaging/tablet_msg/proc/format_message(include_photo = FALSE)
	if (include_photo && logged && data["photo"])
		return "\"[data["message"]]\" (<a href='byond://?src=[REF(logged)];photo=1'>Photo</a>)"
	return "\"[data["message"]]\""

/datum/signal/subspace/messaging/tablet_msg/broadcast()
	if (!logged)  // Can only go through if a message server logs it
		return
	for (var/obj/item/modular_computer/comp in data["targets"])
		var/obj/item/computer_hardware/hard_drive/drive = comp.all_components[MC_HDD]
		for(var/datum/computer_file/program/messenger/app in drive.stored_files)
			app.receive_message(src)

// Request Console signal datum
/datum/signal/subspace/messaging/rc/broadcast()
	if (!logged)  // Like /pda, only if logged
		return
	var/rec_dpt = ckey(data["rec_dpt"])
	for (var/obj/machinery/requests_console/Console in GLOB.allConsoles)
		if(ckey(Console.department) == rec_dpt || (data["ore_update"] && Console.receive_ore_updates))
			Console.createmessage(data["sender"], data["send_dpt"], data["message"], data["verified"], data["stamped"], data["priority"], data["notify_freq"])

// Log datums stored by the message server.
/datum/data_tablet_msg
	var/sender = "Unspecified"
	var/recipient = "Unspecified"
	var/message = "Blank"  // transferred message
	var/datum/picture/picture  // attached photo
	var/automated = FALSE //automated message
	/// If this message is allowed to render emojis
	var/emojis = FALSE

/datum/data_tablet_msg/New(param_rec, param_sender, param_message, param_photo, param_emojis)
	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message
	if(param_photo)
		picture = param_photo
	if(param_emojis)
		emojis = param_emojis

/datum/data_tablet_msg/Topic(href,href_list)
	..()
	if(href_list["photo"])
		var/mob/M = usr
		M << browse_rsc(picture.picture_image, "pda_photo.png")
		M << browse("<!DOCTYPE html><html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>PDA Photo</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='pda_photo.png' width='480' style='-ms-interpolation-mode:nearest-neighbor;image-rendering:pixelated' />" \
		+ "</body></html>", "window=photo_showing;size=480x608")
		onclose(M, "pdaphoto")

/datum/data_rc_msg
	var/rec_dpt = "Unspecified"  // receiving department
	var/send_dpt = "Unspecified"  // sending department
	var/message = "Blank"
	var/stamp = "Unstamped"
	var/id_auth = "Unauthenticated"
	var/priority = "Normal"

/datum/data_rc_msg/New(param_rec, param_sender, param_message, param_stamp, param_id_auth, param_priority)
	if(param_rec)
		rec_dpt = param_rec
	if(param_sender)
		send_dpt = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(REQ_NORMAL_MESSAGE_PRIORITY)
				priority = "Normal"
			if(REQ_HIGH_MESSAGE_PRIORITY)
				priority = "High"
			if(REQ_EXTREME_MESSAGE_PRIORITY)
				priority = "Extreme"
			else
				priority = "Undetermined"

#undef MESSAGE_SERVER_FUNCTIONING_MESSAGE

/obj/machinery/telecomms/message_server/preset
	id = "Messaging Server"
	network = "tcommsat"
	autolinkers = list("messaging")
	decryptkey = null //random
	calibrating = 0
