// A receptionist's bhell

/obj/structure/desk_bell
	name = "desk bell"
	desc = "The cornerstone of any customer service job. You feel an unending urge to ring it."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "desk_bell"
	layer = OBJ_LAYER
	anchored = FALSE
	pass_flags = PASSTABLE // Able to place on tables
	max_integrity = 5000 // To make attacking it not instantly break it
	/// The amount of times this bell has been rang, used to check the chance it breaks
	var/times_rang = 0
	/// Is this bell broken?
	var/broken_ringer = FALSE
	/// The cooldown for ringing the bell
	COOLDOWN_DECLARE(ring_cooldown)
	/// The length of the cooldown. Setting it to 0 will skip all cooldowns alltogether.
	var/ring_cooldown_length = 0.3 SECONDS // This is here to protect against tinnitus.
	/// The sound the bell makes
	var/ring_sound = 'sound/machines/bellsound.ogg'

/obj/structure/desk_bell/Initialize(mapload)
	. = ..()


/obj/structure/desk_bell/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, ring_cooldown) && ring_cooldown_length)
		return TRUE
	if(!ring_bell(user))
		to_chat(user,span_notice("[src] is silent. Some idiot broke it."))
	if(ring_cooldown_length)
		COOLDOWN_START(src, ring_cooldown, ring_cooldown_length)
	return TRUE

/obj/structure/desk_bell/attackby(obj/item/I, mob/user, params)
	. = ..()
	times_rang += I.force
	ring_bell(user)

// Fix the clapper
/obj/structure/desk_bell/screwdriver_act(mob/living/user, obj/item/I)
	if(broken_ringer)
		balloon_alert(user, "repairing...")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 5 SECONDS))
			balloon_alert_to_viewers("repaired")
			playsound(user, 'sound/items/change_drill.ogg', 50, vary = TRUE)
			broken_ringer = FALSE
			times_rang = 0
			return TOOL_ACT_TOOLTYPE_SUCCESS
		return FALSE
	return ..()

// Deconstruct
/obj/structure/desk_bell/wrench_act(mob/living/user, obj/item/I)
	balloon_alert(user, "taking apart...")
	I.play_tool_sound(src)
	if(I.use_tool(src, user, 5 SECONDS))
		playsound(user, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		if(!broken_ringer) // Drop 2 if it's not broken.
			new/obj/item/stack/sheet/iron(drop_location())
		new/obj/item/stack/sheet/iron(drop_location())
		qdel(src)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return ..()

/// Check if the clapper breaks, and if it does, break it
/obj/structure/desk_bell/proc/check_clapper(mob/living/user)
	if(((times_rang >= 10000) || prob(times_rang/100)) && ring_cooldown_length)
		to_chat(user, span_notice("You hear [src]'s clapper fall off of its hinge. Nice job, you broke it."))
		broken_ringer = TRUE

/// Ring the bell
/obj/structure/desk_bell/proc/ring_bell(mob/living/user)
	if(broken_ringer)
		return FALSE
	check_clapper(user)
	// The lack of varying is intentional. The only variance occurs on the strike the bell breaks.
	playsound(src, ring_sound, 70, vary = broken_ringer, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	flick("[initial(icon_state)]_ring", src)
	times_rang++
	return TRUE

// A warning to all who enter; the ringing sound STACKS. It won't be deafening because it only goes every decisecond,
// but I did feel like my ears were going to start bleeding when I tested it with my autoclicker.
/obj/structure/desk_bell/speed_demon
	desc = "The cornerstone of any customer service job. This one's been modified for hyper-performance."
	icon_state = "desk_bell_fancy"
	ring_cooldown_length = 0

/obj/structure/desk_bell/wired
	name = "wired desk bell"
	desc = "The cornerstone of any customer service job. This one has some wires coming out of it."
	var/obj/item/radio/internal_radio
	var/radio_key = /obj/item/encryptionkey
	var/radio_channel = null
	var/msg = null
	var/location = null
	var/job_title = "Staff"
	COOLDOWN_DECLARE(radio_cooldown)

/obj/structure/desk_bell/wired/Initialize(mapload)
	. = ..()
	if(!location)	//so you can set custom location names in a mapping editor
		var/area = get_area(loc)
		location = "[get_area_name(area, TRUE)]"
	internal_radio = new(src)
	internal_radio.keyslot = new radio_key
	internal_radio.canhear_range = 0
	internal_radio.recalculateChannels()

/obj/structure/desk_bell/wired/ring_bell(mob/living/user)
	. = ..()
	if(COOLDOWN_FINISHED(src, radio_cooldown))
		COOLDOWN_START(src, radio_cooldown, 3 MINUTES)
		msg = "[station_time_timestamp(format = "hh:mm")] - [job_title] requested to \"[location]\"."
		internal_radio.talk_into(src, msg, radio_channel)
	return

/obj/structure/desk_bell/wired/Destroy()
	QDEL_NULL(internal_radio)
	return ..()

/obj/structure/desk_bell/wired/medical
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL

/obj/structure/desk_bell/wired/command
	radio_key = /obj/item/encryptionkey/headset_com
	radio_channel = RADIO_CHANNEL_COMMAND

/obj/structure/desk_bell/wired/security
	radio_key = /obj/item/encryptionkey/headset_sec
	radio_channel = RADIO_CHANNEL_SECURITY

/obj/structure/desk_bell/wired/science
	radio_key = /obj/item/encryptionkey/headset_sci
	radio_channel = RADIO_CHANNEL_SCIENCE

/obj/structure/desk_bell/wired/service
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE

/obj/structure/desk_bell/wired/cargo
	radio_key = /obj/item/encryptionkey/headset_cargo
	radio_channel = RADIO_CHANNEL_SUPPLY

/obj/structure/desk_bell/wired/engineering
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING

/obj/structure/desk_bell/wired/syndicate //funny
	radio_key = /obj/item/encryptionkey/syndicate
	radio_channel = RADIO_CHANNEL_SYNDICATE
