/// How long the chat message's spawn-in animation will occur for
#define CHAT_MESSAGE_SPAWN_TIME		0.2 SECONDS
/// How long the chat message will exist prior to any exponential decay
#define CHAT_MESSAGE_LIFESPAN		5.4 SECONDS
/// How long the chat message's end of life fading animation will occur for
#define CHAT_MESSAGE_EOL_FADE		0.3 SECONDS
/// Factor of how much the message index (number of messages) will account to exponential decay
#define CHAT_MESSAGE_EXP_DECAY		0.7
/// Factor of how much height will account to exponential decay
#define CHAT_MESSAGE_HEIGHT_DECAY	0.9
/// Approximate height in pixels of an 'average' line, used for height decay
#define CHAT_MESSAGE_APPROX_LHEIGHT	10
/// Max width of chat message in pixels
#define CHAT_MESSAGE_WIDTH			128
/// Max length of chat message in characters
#define CHAT_MESSAGE_MAX_LENGTH		110
/// The dimensions of the chat message icons
#define CHAT_MESSAGE_ICON_SIZE		7
/// How much the message moves up before fading out.
#define MESSAGE_FADE_PIXEL_Y 10

// Message types
#define CHATMESSAGE_CANNOT_HEAR 0
#define CHATMESSAGE_HEAR 1
#define CHATMESSAGE_SHOW_LANGUAGE_ICON 2

#define BUCKET_LIMIT (world.time + TICKS2DS(min(BUCKET_LEN - (SSrunechat.practical_offset - DS2TICKS(world.time - SSrunechat.head_offset)) - 1, BUCKET_LEN - 1)))
#define BALLOON_TEXT_WIDTH 200
#define BALLOON_TEXT_SPAWN_TIME (0.3 SECONDS)
#define BALLOON_TEXT_FADE_TIME (0.4 SECONDS)
#define BALLOON_TEXT_FULLY_VISIBLE_TIME (0.9 SECONDS)
#define BALLOON_TEXT_TOTAL_LIFETIME(mult) (BALLOON_TEXT_SPAWN_TIME + BALLOON_TEXT_FULLY_VISIBLE_TIME*mult + BALLOON_TEXT_FADE_TIME)
/// The increase in duration per character in seconds
#define BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MULT (0.05)
/// The amount of characters needed before this increase takes into effect
#define BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MIN 10

#define COLOR_PERSON_UNKNOWN "#999999"
#define COLOR_CHAT_EMOTE "#727272"


/**
  * # Chat Message Overlay
  *
  * Datum for generating a message overlay on the map
  */
/datum/chatmessage
	/// The visual element of the chat messsage
	var/image/message
	/// The location in which the message is appearing
	var/atom/message_loc
	/// A list of clients who hear this message
	var/list/client/hearers
	/// Contains the scheduled destruction time, used for scheduling EOL
	var/scheduled_destruction
	/// Contains the time that the EOL for the message will be complete, used for qdel scheduling
	var/eol_complete
	/// Contains the approximate amount of lines for height decay
	var/approx_lines
	/// Contains the reference to the next chatmessage in the bucket, used by runechat subsystem
	var/datum/chatmessage/next
	/// Contains the reference to the previous chatmessage in the bucket, used by runechat subsystem
	var/datum/chatmessage/prev
	/// The current index used for adjusting the layer of each sequential chat message such that recent messages will overlay older ones
	var/static/current_z_idx = 0
	/// Color of the message
	var/tgt_color
	/// Contains ID of assigned timer for end_of_life fading event
	var/fadertimer = null
	/// States if end_of_life is being executed
	var/isFading = FALSE

/**
  * Constructs a chat message overlay
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * owner - The mob that owns this overlay, only this mob will be able to view it
  * * extra_classes - Extra classes to apply to the span that holds the text
  * * lifespan - The lifespan of the message in deciseconds
  */
/datum/chatmessage/New(text, atom/target, list/client/hearers, language_icon, list/extra_classes = list(), lifespan = CHAT_MESSAGE_LIFESPAN)
	. = ..()
	if (!istype(target))
		CRASH("Invalid target given for chatmessage")
	INVOKE_ASYNC(src, PROC_REF(generate_image), text, target, hearers, language_icon, extra_classes, lifespan)

/datum/chatmessage/Destroy()
	if (hearers)
		for(var/client/C in hearers)
			if(!C)
				continue
			C.images.Remove(message)
			UnregisterSignal(C, COMSIG_PARENT_QDELETING)
	if(!QDELETED(message_loc))
		LAZYREMOVE(message_loc.chat_messages, src)
	hearers = null
	message_loc = null
	message = null
	return ..()

/**
  * Calls qdel on the chatmessage when its parent is deleted, used to register qdel signal
  */
/datum/chatmessage/proc/on_parent_qdel()
	SIGNAL_HANDLER
	qdel(src)

/**
  * Generates a chat message image representation
  *
  * Arguments:
  * * text - The text content of the overlay
  * * target - The target atom to display the overlay at
  * * owner - The mob that owns this overlay, only this mob will be able to view it
  * * language - The language this message was spoken in
  * * extra_classes - Extra classes to apply to the span that holds the text
  * * lifespan - The lifespan of the message in deciseconds
  */
/datum/chatmessage/proc/generate_image(text, atom/target, list/client/hearers, datum/language/language, list/extra_classes, lifespan)
	/// Cached icons to show what language the user is speaking
	var/static/list/language_icons

	// Store the hearers
	src.hearers = hearers

	if(!LAZYLEN(hearers))
		return

	var/client/first_hearer = hearers[1]

	// Delete when the atom its above gets deleted.
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_qdel))

	for(var/client/C as() in hearers)
		if(C)
			RegisterSignal(C, COMSIG_PARENT_QDELETING, PROC_REF(client_deleted))

	// Remove spans in the message from things like the recorder
	var/static/regex/span_check = new(@"<\/?span[^>]*>", "gi")
	text = replacetext(text, span_check, "")

	// Clip message
	if (length_char(text) > CHAT_MESSAGE_MAX_LENGTH)
		text = copytext_char(text, 1, CHAT_MESSAGE_MAX_LENGTH + 1) + "..." // BYOND index moment

	//The color of the message.

	// Get the chat color
	if(!tgt_color)		//in case we have color predefined
		if(isliving(target))		//target is living, thus we have preset color for him
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if(H.wear_id?.GetID())
					var/obj/item/card/id/idcard = H.wear_id.GetID()
					if(idcard)
						tgt_color = get_chatcolor_by_hud(idcard.hud_state)
				else
					tgt_color = COLOR_PERSON_UNKNOWN
			else
				if(!target.chat_color)		//extreme case - mob doesn't have set color
					stack_trace("Error: Mob did not have a chat_color. The only way this can happen is if you set it to null purposely in the thing. Don't do that please.")
					target.chat_color = colorize_string(target.name)
					target.chat_color_name = target.name
				tgt_color = target.chat_color
		else		//target is not living, randomizing its color
			if(!target.chat_color || target.chat_color_name != target.name)
				target.chat_color = colorize_string(target.name)
				target.chat_color_name = target.name
			tgt_color = target.chat_color

	// Get rid of any URL schemes that might cause BYOND to automatically wrap something in an anchor tag
	var/static/regex/url_scheme = new(@"[A-Za-z][A-Za-z0-9+-\.]*:\/\/", "g")
	text = replacetext(text, url_scheme, "")

	// Reject whitespace
	var/static/regex/whitespace = new(@"^\s*$")
	if (whitespace.Find(text))
		qdel(src)
		return

	var/list/prefixes

	// Append radio icon if from a virtual speaker
	if (extra_classes.Find("virtual-speaker"))
		var/image/r_icon = image('icons/UI_Icons/chat/chat_icons.dmi', icon_state = "radio")
		LAZYADD(prefixes, "\icon[r_icon]")
	else if (extra_classes.Find("emote"))
		var/image/r_icon = image('icons/UI_Icons/chat/chat_icons.dmi', icon_state = "emote")
		LAZYADD(prefixes, "\icon[r_icon]")
		tgt_color = COLOR_CHAT_EMOTE

	// Append language icon if the language uses one
	var/datum/language/language_instance = GLOB.language_datum_instances[language]
	if (language_instance?.display_icon(first_hearer.mob))
		var/icon/language_icon = LAZYACCESS(language_icons, language)
		if (isnull(language_icon))
			language_icon = icon(language_instance.icon, icon_state = language_instance.icon_state)
			language_icon.Scale(CHAT_MESSAGE_ICON_SIZE, CHAT_MESSAGE_ICON_SIZE)
			LAZYSET(language_icons, language, language_icon)
		LAZYADD(prefixes, "\icon[language_icon]")

	//Add on the icons.
	text = "[prefixes?.Join("&nbsp;")][text]"

	// Approximate text height
	var/complete_text = "<span class='center [extra_classes.Join(" ")]' style='color: [tgt_color]'>[target.say_emphasis(text)]</span>"
	var/mheight = WXH_TO_HEIGHT(first_hearer.MeasureText(complete_text, null, CHAT_MESSAGE_WIDTH))
	approx_lines = max(1, mheight / CHAT_MESSAGE_APPROX_LHEIGHT)

	// Translate any existing messages upwards, apply exponential decay factors to timers
	message_loc = get_atom_on_turf(target)
	if (LAZYLEN(message_loc.chat_messages))
		var/idx = 1
		var/combined_height = approx_lines
		for(var/datum/chatmessage/m as() in message_loc.chat_messages)
			if(!m?.message)
				continue
			animate(m.message, pixel_y = m.message.pixel_y + mheight, time = CHAT_MESSAGE_SPAWN_TIME)
			combined_height += m.approx_lines

			// When choosing to update the remaining time we have to be careful not to update the
			// scheduled time once the EOL has been executed.
			if (!m.isFading)
				var/sched_remaining = timeleft(m.fadertimer, SSrunechat)
				var/remaining_time = (sched_remaining) * (CHAT_MESSAGE_EXP_DECAY ** idx++) * (CHAT_MESSAGE_HEIGHT_DECAY ** CEILING(combined_height, 1))
				if (remaining_time)
					deltimer(m.fadertimer, SSrunechat)
					m.fadertimer = addtimer(CALLBACK(m, PROC_REF(end_of_life)), remaining_time, TIMER_STOPPABLE|TIMER_DELETE_ME, SSrunechat)
				else
					m.end_of_life()

	// Reset z index if relevant
	if (current_z_idx >= CHAT_LAYER_MAX_Z)
		current_z_idx = 0

	var/bound_height = world.icon_size
	var/bound_width = world.icon_size
	if(ismovable(message_loc))
		var/atom/movable/AM = message_loc
		bound_height = AM.bound_height
		bound_width = AM.bound_width
	// Build message image
	message = image(loc = message_loc, layer = CHAT_LAYER + CHAT_LAYER_Z_STEP * current_z_idx++)
	message.plane = RUNECHAT_PLANE
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	message.alpha = 0
	message.pixel_y = bound_height - MESSAGE_FADE_PIXEL_Y
	message.maptext_width = CHAT_MESSAGE_WIDTH
	message.maptext_height = mheight
	message.maptext_x = (CHAT_MESSAGE_WIDTH - bound_width) * -0.5
	if(extra_classes.Find("italics"))
		message.color = "#CCCCCC"
	message.maptext = MAPTEXT(complete_text)

	// Show the message to clients
	for(var/client/C as() in hearers)
		C?.images |= message
	animate(message, alpha = 255, pixel_y = bound_height, time = CHAT_MESSAGE_SPAWN_TIME)

	LAZYADD(message_loc.chat_messages, src)

	// Register with the runechat SS to handle EOL and destruction
	var/duration = lifespan - CHAT_MESSAGE_EOL_FADE
	fadertimer = addtimer(CALLBACK(src, PROC_REF(end_of_life)), duration, TIMER_STOPPABLE|TIMER_DELETE_ME, SSrunechat)

/datum/chatmessage/proc/client_deleted(client/source)
	SIGNAL_HANDLER
	hearers -= source

/**
  * Applies final animations to overlay CHAT_MESSAGE_EOL_FADE deciseconds prior to message deletion,
  * sets timer for scheduling deletion
  *
  * Arguments:
  * * fadetime - The amount of time to animate the message's fadeout for
  */
/datum/chatmessage/proc/end_of_life(fadetime = CHAT_MESSAGE_EOL_FADE)
	isFading = TRUE
	animate(message, alpha = 0, pixel_y = message.pixel_y + MESSAGE_FADE_PIXEL_Y, time = fadetime, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), fadetime, TIMER_DELETE_ME, SSrunechat)

/mob/proc/should_show_chat_message(atom/movable/speaker, datum/language/message_language, is_emote = FALSE, is_heard = FALSE)
	if(!client)
		return CHATMESSAGE_CANNOT_HEAR
	if(!(client.prefs.toggles & PREFTOGGLE_RUNECHAT_GLOBAL) || (!(client.prefs.toggles & PREFTOGGLE_RUNECHAT_NONMOBS) && !ismob(speaker)))
		return CHATMESSAGE_CANNOT_HEAR
	if(!(client.prefs.toggles & PREFTOGGLE_RUNECHAT_EMOTES) && is_emote)
		return CHATMESSAGE_CANNOT_HEAR
	if(is_heard && !can_hear())
		return CHATMESSAGE_CANNOT_HEAR
	//If the speaker is a virtual speaker, check to make sure we couldnt hear the original message.
	if(istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/v = speaker
		//Dont create the overhead chat if we said the message.
		if(v.source == src)
			return CHATMESSAGE_CANNOT_HEAR
		//Dont create the overhead radio chat if we are a ghost and can hear global messages.
		if(isobserver(src))
			return CHATMESSAGE_CANNOT_HEAR
		//Dont create the overhead radio chat if we heard the speaker speak
		if(get_dist(get_turf(v.source), get_turf(src)) <= 1)
			return CHATMESSAGE_CANNOT_HEAR
		//The AI shouldn't be able to see the overhead chat trough the static
		if(isAI(src) && !GLOB.cameranet.checkCameraVis(v.source))
			return CHATMESSAGE_CANNOT_HEAR
	var/datum/language/language_instance = GLOB.language_datum_instances[message_language]
	if(language_instance?.display_icon(src))
		return CHATMESSAGE_SHOW_LANGUAGE_ICON
	return CHATMESSAGE_HEAR

/mob/living/should_show_chat_message(atom/movable/speaker, datum/language/message_language, is_emote = FALSE, is_heard = FALSE)
	if(stat != CONSCIOUS && stat != DEAD)
		return CHATMESSAGE_CANNOT_HEAR
	return ..()

/proc/create_chat_message(atom/movable/speaker, datum/language/message_language, list/hearers, raw_message, list/spans, list/message_mods)
	if(!length(hearers))
		return

	if(!islist(message_mods))
		message_mods = list()

	// Ensure the list we are using, if present, is a copy so we don't modify the list provided to us
	spans = spans ? spans.Copy() : list()

	var/handled_message = raw_message

	// Message language override, if no language was spoken emote 'makes a strange noise'
	if(!message_language && !message_mods[CHATMESSAGE_EMOTE])
		message_mods[CHATMESSAGE_EMOTE] = TRUE
		handled_message = "makes a strange sound."

	// Check for virtual speakers (aka hearing a message through a radio)
	if (istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/v = speaker
		speaker = v.source
		spans |= "virtual-speaker"

	//If the message has the radio message flag
	else if (message_mods[MODE_RADIO_MESSAGE])
		//You are now a virtual speaker
		spans |= "virtual-speaker"
		//You are no longer italics
		spans -= "italics"

	// Display visual above source
	if(message_mods.Find(CHATMESSAGE_EMOTE))
		var/list/clients = list()
		for(var/mob/M as() in hearers)
			if(M?.should_show_chat_message(speaker, message_language, TRUE))
				clients += M.client
		new /datum/chatmessage(handled_message, speaker, clients, message_language, list("emote"))
	else
		//4 Possible chat message states:
		//Show Icon, Understand (Most other languages)
		//Hide Icon, Understand (Normal galactic common)
		//Show Icon, Don't understand (Most languages you can't understand)
		//Hide Icon, Don't understand (Not understanding common)
		var/list/client/show_icon_understand
		var/list/client/hide_icon_understand
		var/list/client/show_icon_scrambled
		var/list/client/hide_icon_scrambled
		for(var/mob/M as() in hearers)
			switch(M?.should_show_chat_message(speaker, message_language, FALSE))
				if(CHATMESSAGE_HEAR)
					if(!message_language || M.has_language(message_language))
						LAZYADD(hide_icon_understand, M.client)
					else
						LAZYADD(hide_icon_scrambled, M.client)
				if(CHATMESSAGE_SHOW_LANGUAGE_ICON)
					if(!message_language || M.has_language(message_language))
						LAZYADD(show_icon_understand, M.client)
					else
						LAZYADD(show_icon_scrambled, M.client)
		var/scrambled_message
		var/datum/language/language_instance = message_language ? GLOB.language_datum_instances[message_language] : null
		if(LAZYLEN(show_icon_scrambled) || LAZYLEN(hide_icon_scrambled))
			scrambled_message = language_instance?.scramble(handled_message) || scramble_message_replace_chars(handled_message, 100)
		//Show the correct message to people who should see the icon and understand the language
		if(LAZYLEN(show_icon_understand))
			new /datum/chatmessage(handled_message, speaker, show_icon_understand, message_language, spans)
		//Show the correct message to people who should see the icon but not understand the language
		if(LAZYLEN(hide_icon_understand))
			new /datum/chatmessage(handled_message, speaker, hide_icon_understand, message_language, spans)
		//Show the correct message to people who don't understand the language and should see the icon
		if(LAZYLEN(show_icon_scrambled))
			new /datum/chatmessage(scrambled_message, speaker, show_icon_scrambled, message_language, spans)
		//Show the correct message to people who don't understand the language but no icon should be displayed
		if(LAZYLEN(hide_icon_scrambled))
			new /datum/chatmessage(scrambled_message, speaker, hide_icon_scrambled, message_language, spans)

/**
  * Creates a message overlay at a defined location for a given speaker
  *
  * Arguments:
  * * speaker - The atom who is saying this message
  * * message_language - The language that the message is said in
  * * raw_message - The text content of the message
  * * spans - Additional classes to be added to the message
  */



// Tweak these defines to change the available color ranges
#define CM_COLOR_SAT_MIN	0.6
#define CM_COLOR_SAT_MAX	0.7
#define CM_COLOR_LUM_MIN	0.65
#define CM_COLOR_LUM_MAX	0.75

/**
  * Gets a color for a name, will return the same color for a given string consistently within a round.atom
  *
  * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
  *
  * Arguments:
  * * name - The name to generate a color for
  * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
  * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
  */
/datum/chatmessage/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1,26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + GLOB.round_id), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s *= clamp(sat_shift, 0, 1)
	l *= clamp(lum_shift, 0, 1)

	// convert to rgb
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return "#[num2hex(c, 2)][num2hex(x, 2)][num2hex(m, 2)]"
		if(1)
			return "#[num2hex(x, 2)][num2hex(c, 2)][num2hex(m, 2)]"
		if(2)
			return "#[num2hex(m, 2)][num2hex(c, 2)][num2hex(x, 2)]"
		if(3)
			return "#[num2hex(m, 2)][num2hex(x, 2)][num2hex(c, 2)]"
		if(4)
			return "#[num2hex(x, 2)][num2hex(m, 2)][num2hex(c, 2)]"
		if(5)
			return "#[num2hex(c, 2)][num2hex(m, 2)][num2hex(x, 2)]"

/atom/proc/balloon_alert(mob/viewer, text, color = null)
	if(!viewer?.client)
		return
	switch(viewer.client.prefs.see_balloon_alerts)
		if(BALLOON_ALERT_ALWAYS)
			new /datum/chatmessage/balloon_alert(text, src, viewer, color)
		if(BALLOON_ALERT_WITH_CHAT)
			new /datum/chatmessage/balloon_alert(text, src, viewer, color)
			to_chat(viewer, "<span class='notice'>[text].</span>")
		if(BALLOON_ALERT_NEVER)
			to_chat(viewer, "<span class='notice'>[text].</span>")

/atom/proc/balloon_alert_to_viewers(message, self_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs)
	var/list/hearers = get_hearers_in_view(vision_distance, src)
	hearers -= ignored_mobs

	for (var/mob/hearer in hearers)
		if (hearer.is_blind())
			continue

		balloon_alert(hearer, (hearer == src && self_message) || message)

/datum/chatmessage/balloon_alert
	tgt_color = "#ffffff" //default color

/datum/chatmessage/balloon_alert/New(text, atom/target, mob/owner, color)
	if (!istype(target))
		CRASH("Invalid target given for chatmessage")
	if(QDELETED(owner) || !istype(owner) || !owner.client)
		stack_trace("/datum/chatmessage created with [isnull(owner) ? "null" : "invalid"] mob owner")
		qdel(src)
		return
	//handle color
	if(color)
		tgt_color = color
	INVOKE_ASYNC(src, PROC_REF(generate_image), text, target, owner)

/datum/chatmessage/balloon_alert/Destroy()
	if(!QDELETED(message_loc))
		LAZYREMOVE(message_loc.balloon_alerts, src)
	return ..()

/datum/chatmessage/balloon_alert/end_of_life(fadetime = BALLOON_TEXT_FADE_TIME)
	isFading = TRUE
	animate(message, alpha = 0, pixel_y = message.pixel_y + MESSAGE_FADE_PIXEL_Y, time = fadetime, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), fadetime, TIMER_DELETE_ME, SSrunechat)

/datum/chatmessage/balloon_alert/generate_image(text, atom/target, mob/owner)
	// Register client who owns this message
	var/client/owned_by = owner.client
	RegisterSignal(owned_by, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_qdel))

	var/bound_width = world.icon_size
	if (ismovable(target))
		var/atom/movable/movable_source = target
		bound_width = movable_source.bound_width

	if(isturf(target))
		message_loc = target
	else
		message_loc = get_atom_on_turf(target)

	if(LAZYLEN(message_loc.balloon_alerts))
		for(var/datum/chatmessage/balloon_alert/m as() in message_loc.balloon_alerts)  //We get rid of old alerts so it doesn't clutter up the screen
			if (!m.isFading)
				var/sched_remaining = timeleft(m.fadertimer, SSrunechat)
				if (sched_remaining)
					deltimer(m.fadertimer, SSrunechat)
				m.end_of_life()

	// Build message image
	message = image(loc = message_loc, layer = CHAT_LAYER)
	message.plane = BALLOON_CHAT_PLANE
	message.alpha = 0
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	message.maptext_width = BALLOON_TEXT_WIDTH
	message.maptext_height = WXH_TO_HEIGHT(owned_by?.MeasureText(text, null, BALLOON_TEXT_WIDTH))
	message.maptext_x = (BALLOON_TEXT_WIDTH - bound_width) * -0.5
	message.maptext = MAPTEXT("<span style='text-align: center; -dm-text-outline: 1px #0005; color: [tgt_color]'>[text]</span>")

	// View the message
	owned_by.images += message

	var/duration_mult = 1
	var/duration_length = length(text) - BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MIN

	if(duration_length > 0)
		duration_mult += duration_length * BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MULT

	// Animate the message
	animate(message, alpha = 255, pixel_y = world.icon_size * 1.1, time = BALLOON_TEXT_SPAWN_TIME)

	LAZYADD(message_loc.balloon_alerts, src)

	// Register with the runechat SS to handle EOL and destruction
	var/duration = BALLOON_TEXT_TOTAL_LIFETIME(duration_mult)
	fadertimer = addtimer(CALLBACK(src, PROC_REF(end_of_life)), duration, TIMER_STOPPABLE|TIMER_DELETE_ME, SSrunechat)


#undef BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MIN
#undef BALLOON_TEXT_CHAR_LIFETIME_INCREASE_MULT
#undef CHAT_MESSAGE_SPAWN_TIME
#undef CHAT_MESSAGE_LIFESPAN
#undef CHAT_MESSAGE_EOL_FADE
#undef CHAT_MESSAGE_EXP_DECAY
#undef CHAT_MESSAGE_HEIGHT_DECAY
#undef CHAT_MESSAGE_APPROX_LHEIGHT
#undef CHAT_MESSAGE_WIDTH
#undef CHAT_LAYER_Z_STEP
#undef CHAT_LAYER_MAX_Z
#undef CHAT_MESSAGE_ICON_SIZE
#undef BALLOON_TEXT_FADE_TIME
#undef BALLOON_TEXT_FULLY_VISIBLE_TIME
#undef BALLOON_TEXT_SPAWN_TIME
#undef BALLOON_TEXT_TOTAL_LIFETIME
#undef BALLOON_TEXT_WIDTH
#undef CHATMESSAGE_CANNOT_HEAR
#undef CHATMESSAGE_HEAR
#undef CHATMESSAGE_SHOW_LANGUAGE_ICON
#undef COLOR_PERSON_UNKNOWN
#undef COLOR_CHAT_EMOTE
