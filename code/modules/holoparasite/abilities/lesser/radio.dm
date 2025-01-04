/datum/holoparasite_ability/lesser/misaka
	name = "Radio Noise"
	desc = "The $theme can hear communications over all common radio frequencies, although it normally cannot transmit communications."
	ui_icon = "phone"
	cost = 1
	thresholds = list(
		list(
			"stat" = "Potential",
			"minimum" = 4,
			"desc" = "The $theme can intercept and decode communications sent over the binary frequency used by silicons."
		),
		list(
			"stat" = "Range",
			"minimum" = 4,
			"desc" = "The $theme can communicate over the frequencies it can hear."
		)
	)
	var/can_talk = FALSE
	var/binary = FALSE
	var/regex/prefix_regex
	var/obj/item/radio/holoparasite/radio

/datum/holoparasite_ability/lesser/misaka/Destroy()
	. = ..()
	QDEL_NULL(radio)

/datum/holoparasite_ability/lesser/misaka/apply()
	..()
	if(radio)
		QDEL_NULL(radio)
	radio = new(owner)
	can_talk = master_stats.range >= 4
	if(master_stats.potential >= 4)
		binary = TRUE
		radio.keyslot.translate_binary = TRUE
	if(!can_talk)
		radio.wires.cut(WIRE_TX, null)
	radio.recalculateChannels()
	generate_regex()

/**
 * Generates a regex for detecting if a message is meant to go over this radio or not.
 */
/datum/holoparasite_ability/lesser/misaka/proc/generate_regex()
	var/list/prefixes = list()
	for(var/prefix in GLOB.department_radio_prefixes)
		prefixes += REGEX_QUOTE(prefix)
	var/list/keys = list()
	for(var/channel in radio.channels)
		keys += REGEX_QUOTE(copytext(GLOB.channel_tokens[channel], 2))
	if(binary)
		keys += MODE_KEY_BINARY
	prefix_regex = new("^([RADIO_KEY_COMMON]|(([prefixes.Join("|")])([keys.Join("|")])))", "i")

/datum/holoparasite_ability/lesser/misaka/notify_user()
	var/list/text = list(span_holoparasitebold("You are able to [can_talk ? "both hear and talk over" : "hear"] most radio channels!"))
	var/list/channels = list("Use [RADIO_KEY_COMMON] for the common frequency")
	if(binary)
		channels += "use [MODE_TOKEN_BINARY] for [MODE_BINARY]"
	for(var/channel in radio.channels)
		channels += "use [GLOB.channel_tokens[channel]] for [LOWER_TEXT(channel)]"
	text += span_holoparasite("[english_list(channels)]")
	return text.Join("\n")

/obj/item/radio/holoparasite
	name = "internal holoparasite radio"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF | UNACIDABLE
	canhear_range = -1
	subspace_transmission = TRUE
	radio_silent = TRUE

/obj/item/radio/holoparasite/Initialize(mapload)
	. = ..()
	keyslot = new /obj/item/encryptionkey/holoparasite

/obj/item/radio/holoparasite/emp_act(severity)
	return EMP_PROTECT_SELF | EMP_PROTECT_WIRES // This isn't a electronic radio, and therefore is unaffected by EMPs.

/obj/item/radio/holoparasite/get_specific_hearers()
	if(isholopara(loc))
		return loc

/obj/item/encryptionkey/holoparasite
	channels = list(
		RADIO_CHANNEL_COMMAND = TRUE,
		RADIO_CHANNEL_SECURITY = TRUE,
		RADIO_CHANNEL_ENGINEERING = TRUE,
		RADIO_CHANNEL_SCIENCE = TRUE,
		RADIO_CHANNEL_MEDICAL = TRUE,
		RADIO_CHANNEL_SUPPLY = TRUE,
		RADIO_CHANNEL_SERVICE = TRUE,
		RADIO_CHANNEL_EXPLORATION = TRUE,
		RADIO_CHANNEL_AI_PRIVATE = TRUE
	)
