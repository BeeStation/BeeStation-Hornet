// A decorational representation of SSblackbox, usually placed alongside the message server. Also contains a traitor theft item.
/obj/machinery/blackbox_recorder
	name = "Blackbox Recorder"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	armor_type = /datum/armor/machinery_blackbox_recorder
	/// The object that's stored in the machine, which is to say, the blackbox itself.
	/// When it hasn't already been stolen, of course.
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

/obj/machinery/blackbox_recorder/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/blackbox))
		if(HAS_TRAIT(attacking_item, TRAIT_NODROP) || !user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_warning("[attacking_item] is stuck to your hand!"))
			return
		user.visible_message(span_notice("[user] clicks [attacking_item] into [src]!"), \
		span_notice("You press the device into [src], and it clicks into place. The tapes begin spinning again."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		stored = attacking_item
		update_appearance()
		return
	return ..()

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

/**
 * The equivalent of the server, for PDA and request console messages.
 * Without it, PDA and request console messages cannot be transmitted.
 * PDAs require the rest of the telecomms setup, but request consoles only
 * require the message server.
 */
/obj/machinery/telecomms/message_server
	name = "Messaging Server"
	desc = "A machine that processes and routes PDA and request console messages."
	icon_state = "message_server"
	telecomms_type = /obj/machinery/telecomms/message_server
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 40
	circuit = /obj/item/circuitboard/machine/telecomms/message_server

	/// A list of all the PDA messages that were intercepted and processed by
	/// this messaging server.
	var/list/datum/data_tablet_msg/modular_msgs = list()
	/// A list of all the Request Console messages that were intercepted and
	/// processed by this messaging server.
	var/list/datum/data_rc_msg/rc_msgs = list()
	/// The password of this messaging server.
	var/decryptkey = "password"
	/// Init reads this and adds world.time, then becomes 0 when that time has
	/// passed and the machine works.
	/// Basically, if it's not 0, it's calibrating and therefore non-functional.
	var/calibrating = 15 MINUTES

#define MESSAGE_SERVER_FUNCTIONING_MESSAGE "This is an automated message. The messaging system is functioning correctly."

/obj/machinery/telecomms/message_server/Initialize(mapload)
	. = ..()
	if (!decryptkey)
		decryptkey = generate_key()

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

/**
 * Handles generating a key for the message server, returning it. Doesn't assign
 * it in this proc, you have to do so yourself.
 */
/obj/machinery/telecomms/message_server/proc/generate_key()
	var/generated_key
	generated_key += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	generated_key += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	generated_key += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return generated_key

/obj/machinery/telecomms/message_server/process()
	. = ..()
	if(calibrating && calibrating <= world.time)
		calibrating = 0
		modular_msgs += new /datum/data_tablet_msg("System Administrator", "system", MESSAGE_SERVER_FUNCTIONING_MESSAGE)

#undef MESSAGE_SERVER_FUNCTIONING_MESSAGE

/obj/machinery/telecomms/message_server/receive_information(datum/signal/subspace/messaging/signal, obj/machinery/telecomms/machine_from)
	// can't log non-message signals
	if(!istype(signal) || !signal.data["message"] || !on || calibrating)
		return

	// log the signal
	if(istype(signal, /datum/signal/subspace/messaging/tablet_msg))
		var/datum/signal/subspace/messaging/tablet_msg/PDanomaly_core = signal
		var/datum/data_tablet_msg/msg = new(PDanomaly_core.format_target(), "[PDanomaly_core.data["name"]] ([PDanomaly_core.data["job"]])", PDanomaly_core.data["message"], PDanomaly_core.data["photo"], PDanomaly_core.data["emojis"])
		modular_msgs += msg
		signal.logged = msg
	else if(istype(signal, /datum/signal/subspace/messaging/rc))
		var/datum/data_rc_msg/msg = new(signal.data["receiving_department"], signal.data["sender_department"], signal.data["message"], signal.data["stamped"], signal.data["verified"], signal.data["priority"])
		signal.logged = msg
		if(signal.data["sender_department"]) // don't log messages not from a department but allow them to work
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


// Preset messaging server
/obj/machinery/telecomms/message_server/preset
	id = "Messaging Server"
	network = "tcommsat"
	autolinkers = list("messaging")
	decryptkey = null //random
	calibrating = 0

// Root messaging signal datum
/datum/signal/subspace/messaging
	frequency = FREQ_COMMON
	server_type = /obj/machinery/telecomms/message_server
	var/datum/logged

/datum/signal/subspace/messaging/New(init_source, init_data)
	source = init_source
	data = init_data
	var/turf/origin_turf = get_turf(source)
	levels = list(origin_turf.get_virtual_z_level())
	if(!("reject" in data))
		data["reject"] = TRUE

/datum/signal/subspace/messaging/copy()
	var/datum/signal/subspace/messaging/copy = new type(source, data.Copy())
	copy.original = src
	copy.levels = levels
	return copy

// Tablet message signal datum
/// Returns a string representing the target of this message, formatted properly.
/datum/signal/subspace/messaging/tablet_msg/proc/format_target()
	if (length(data["targets"]) > 1)
		return "Everyone"
	var/obj/item/modular_computer/target = data["targets"][1]
	return "[target.saved_identification] ([target.saved_job])"

/// Returns the formatted message contained in this message. Use this to apply
/// any processing to it if it needs to be formatted in a specific way.
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
	var/recipient_department = ckey(data["recipient_department"])
	for (var/obj/machinery/requests_console/Console in GLOB.allConsoles)
		if(ckey(Console.department) == recipient_department || (data["ore_update"] && Console.receive_ore_updates))
			Console.createmessage(data["sender"], data["sender_department"], data["message"], data["verified"], data["stamped"], data["priority"], data["notify_freq"])

/// Log datums stored by the message server.
/datum/data_tablet_msg
	/// Who sent the message.
	var/sender = "Unspecified"
	/// Who was targeted by the message.
	var/recipient = "Unspecified"
	/// The transfered message.
	var/message = "Blank"
	var/datum/picture/picture  // attached photo
	/// Whether or not it's an automated message. Defaults to `FALSE`.
	var/automated = FALSE
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

#define REQUEST_PRIORITY_NORMAL "Normal"
#define REQUEST_PRIORITY_HIGH "High"
#define REQUEST_PRIORITY_EXTREME "Extreme"
#define REQUEST_PRIORITY_UNDETERMINED "Undetermined"

/datum/data_rc_msg
	/// The department that sent the request.
	var/sender_department = "Unspecified"
	/// The department that was targeted by the request.
	var/receiving_department = "Unspecified"
	/// The message of the request.
	var/message = "Blank"
	/// The stamp that authenticated this message, if any.
	var/stamp = "Unstamped"
	/// The ID that authenticated this message, if any.
	var/id_auth = "Unauthenticated"
	/// The priority of this request.
	var/priority = REQUEST_PRIORITY_NORMAL

/datum/data_rc_msg/New(param_rec, param_sender, param_message, param_stamp, param_id_auth, param_priority)
	if(param_rec)
		receiving_department = param_rec
	if(param_sender)
		sender_department = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(REQ_NORMAL_MESSAGE_PRIORITY)
				priority = REQUEST_PRIORITY_NORMAL
			if(REQ_HIGH_MESSAGE_PRIORITY)
				priority = REQUEST_PRIORITY_HIGH
			if(REQ_EXTREME_MESSAGE_PRIORITY)
				priority = REQUEST_PRIORITY_EXTREME
			else
				priority = REQUEST_PRIORITY_UNDETERMINED

#undef REQUEST_PRIORITY_NORMAL
#undef REQUEST_PRIORITY_HIGH
#undef REQUEST_PRIORITY_EXTREME
#undef REQUEST_PRIORITY_UNDETERMINED
