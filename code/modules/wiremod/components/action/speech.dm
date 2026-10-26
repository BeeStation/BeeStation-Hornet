/**
 * # Speech Component
 *
 * Sends a message. Requires a shell.
 */
/obj/item/circuit_component/speech
	display_name = "Speech"
	desc = "A component that sends a message. Requires a shell."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The message to send
	var/datum/port/input/message

	/// The cooldown for this component of how often it can send speech messages.
	var/speech_cooldown = 1 SECONDS

	/// Language the circuit speaks in
	var/datum/port/input/option/language_option

/obj/item/circuit_component/speech/get_ui_notices()
	. = ..()
	. += create_ui_notice("Speech Cooldown: [DisplayTimeText(speech_cooldown)]", "orange", "stopwatch")

/obj/item/circuit_component/speech/populate_ports()
	message = add_input_port("Message", PORT_TYPE_STRING, trigger = null)

/obj/item/circuit_component/speech/populate_options()
	var/static/list/component_options = assoc_to_keys(GLOB.language_types_by_name)
	language_option = add_option_port("Language", component_options)

/obj/item/circuit_component/speech/input_received(datum/port/input/port)

	if(TIMER_COOLDOWN_CHECK(parent, COOLDOWN_CIRCUIT_SPEECH))
		return

	if(message.value)
		var/atom/movable/shell = parent.shell
		var/datum/language/language_choosen = null
		if(language_option.value)
			language_choosen = GLOB.language_types_by_name[language_option.value]
		// Prevents appear as the individual component if there is a shell.
		if(shell)
			shell.say(message.value, language = language_choosen, forced = "circuit speech | [key_name(parent.get_creator())]")
		else
			say(message.value, language = language_choosen, forced = "circuit speech | [parent.get_creator()]")
		TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_SPEECH, speech_cooldown)
