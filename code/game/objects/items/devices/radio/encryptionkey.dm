/obj/item/encryptionkey
	name = "standard encryption key"
	desc = "An encryption key for a radio headset."
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	w_class = WEIGHT_CLASS_TINY
	var/translate_binary = FALSE
	var/syndie = FALSE
	var/independent = FALSE
	var/amplification = FALSE
	var/list/channels = list()

/obj/item/encryptionkey/Initialize(mapload)
	. = ..()
	if(!(translate_binary || syndie || independent || amplification || length(channels)))
		desc = "An encryption key for a radio headset. Has no special codes in it. You should probably tell a coder!"

/obj/item/encryptionkey/examine(mob/user)
	. = ..()
	if(LAZYLEN(channels))
		var/list/examine_text_list = list()
		for(var/i in channels)
			examine_text_list += "[GLOB.channel_tokens[i]] - [LOWER_TEXT(i)]"

		. += span_notice("It can access the following channels; [jointext(examine_text_list, ", ")].")

/obj/item/encryptionkey/syndicate
	name = "syndicate encryption key"
	icon_state = "syn_cypherkey"
	channels = list(RADIO_CHANNEL_SYNDICATE = 1)
	syndie = TRUE//Signifies that it de-crypts Syndicate transmissions

/obj/item/encryptionkey/binary
	name = "binary translator key"
	desc = "An encryption key that interchanges the form of anaologue brainwave and binary electric signals."
	icon_state = "bin_cypherkey"
	translate_binary = TRUE

/obj/item/encryptionkey/amplification
	name = "amplification module key"
	desc = "An amplification module key for a radio headset. It will enable the \"Loud mode\" ability on any headset it is inserted into."
	amplification = TRUE

/obj/item/encryptionkey/headset_sec
	name = "security radio encryption key"
	icon_state = "sec_cypherkey"
	channels = list(RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_eng
	name = "engineering radio encryption key"
	icon_state = "eng_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1)

/obj/item/encryptionkey/headset_rob
	name = "robotics radio encryption key"
	icon_state = "rob_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_ENGINEERING = 1)

/obj/item/encryptionkey/headset_med
	name = "medical radio encryption key"
	icon_state = "med_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1)

/obj/item/encryptionkey/headset_sci
	name = "science radio encryption key"
	icon_state = "sci_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_srvsec
	name = "law and order radio encryption key"
	icon_state = "srvsec_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_medsec
	name = "medical-security encryption key"
	icon_state = "medsec_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_com
	name = "command radio encryption key"
	icon_state = "com_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/captain
	name = "\proper the captain's encryption key"
	icon_state = "cap_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 0, RADIO_CHANNEL_SCIENCE = 0, RADIO_CHANNEL_MEDICAL = 0, RADIO_CHANNEL_SUPPLY = 0, RADIO_CHANNEL_SERVICE = 0, RADIO_CHANNEL_EXPLORATION = 0)

/obj/item/encryptionkey/heads/captain/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/rd
	name = "\proper the research director's encryption key"
	icon_state = "rd_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_EXPLORATION = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/rd/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/hos
	name = "\proper the head of security's encryption key"
	icon_state = "hos_cypherkey"
	channels = list(RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/hos/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/ce
	name = "\proper the chief engineer's encryption key"
	icon_state = "ce_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/ce/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/cmo
	name = "\proper the chief medical officer's encryption key"
	icon_state = "cmo_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/cmo/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/hop
	name = "\proper the head of personnel's encryption key"
	icon_state = "hop_cypherkey"
	channels = list(RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/hop/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/headset_cargo
	name = "supply radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list(RADIO_CHANNEL_SUPPLY = 1)

/obj/item/encryptionkey/headset_mining
	name = "mining radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list(RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_exp
	name = "exploration encryption key"
	icon_state = "exp_cypherkey"
	channels = list(RADIO_CHANNEL_EXPLORATION = 1)

/obj/item/encryptionkey/headset_expteam
	name = "exploration team encryption key"
	icon_state = "expteam_cypherkey"
	channels = list(RADIO_CHANNEL_EXPLORATION = 1, RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_service
	name = "service radio encryption key"
	icon_state = "srv_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/headset_curator
	name = "curator radio encryption key"
	icon_state = "srv_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_EXPLORATION = 1)

/obj/item/encryptionkey/headset_cent
	name = "\improper CentCom radio encryption key"
	icon_state = "cent_cypherkey"
	independent = TRUE
	channels = list(RADIO_CHANNEL_CENTCOM = 1)

/obj/item/encryptionkey/debug
	name = "\improper omni radio encryption key"
	desc = "A god-like key of omni-presence to eavesdrop anything you would want to hear."
	icon_state = "cent_cypherkey"
	translate_binary = TRUE
	syndie = TRUE
	independent = TRUE
	amplification = TRUE

/obj/item/encryptionkey/debug/Initialize(mapload)
	. = ..()
	for(var/each in GLOB.radiochannels)
		channels |= list("[each]" = 1)

/obj/item/encryptionkey/ai //ported from NT, this goes 'inside' the AI.
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 1, RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_EXPLORATION = 1, RADIO_CHANNEL_AI_PRIVATE = 1)

/obj/item/encryptionkey/secbot
	channels = list(RADIO_CHANNEL_AI_PRIVATE = 1, RADIO_CHANNEL_SECURITY = 1)


/obj/item/storage/box/command_keys // heads toys
	name = "box of amplification keys"

/obj/item/storage/box/command_keys/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/encryptionkey/amplification(src)
