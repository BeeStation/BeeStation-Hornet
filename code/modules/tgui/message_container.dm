/// A container for holding unsanitised user inputs so that they can be passed on
/// to TGUI to be rendered properly. This container protects the message from being
/// used improperly while in byond land, so that it can be cleanly passed through into
/// TGUI land where it is safe once again.
/datum/unsafe_message
	/// The unsafe message from user input, which has not been sanitised. This can be
	/// passed into TGUI, as that will perform sanitisation but you should take great
	/// care using this inside byond prior to sanitisation.
	VAR_PRIVATE/_unsafe_message

/datum/unsafe_message/New(unsafe_message)
	. = ..()
	_unsafe_message = unsafe_message

/// Get the unsanitised message so that it can be passed into TGUI, which performs
/// sanitisation on the TGUI side.
/// Do not pass this into message_admins.
/// Do not pass this into to_chat unless you explicitly pass it into the text parameter ONLY.
/// You may pass this into ui_data.
/datum/unsafe_message/proc/get_unsafe_message()
	return _unsafe_message

/// Will return a sanitised version of the unsafe message which can safely be used
/// inside HTML UIs, to_chat or other byond constructs.
/// Passing this into TGUI is not recommended, as TGUI will perform another layer
/// of sanitisation on its inputs which will result in <> being converted into
/// encoded text, which renders as &gt; instead of >.
/datum/unsafe_message/proc/get_sanitised()
	return sanitize(_unsafe_message)
