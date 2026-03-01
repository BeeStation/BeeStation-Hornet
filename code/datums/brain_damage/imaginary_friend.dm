/datum/brain_trauma/special/imaginary_friend
	name = "Imaginary Friend"
	desc = "Patient can see and hear an imaginary person."
	scan_desc = "partial schizophrenia"
	gain_text = span_notice("You feel in good company, for some reason.")
	lose_text = span_warning("You feel lonely again.")
	var/mob/camera/imaginary_friend/friend
	var/friend_initialized = FALSE

/datum/brain_trauma/special/imaginary_friend/on_gain()
	var/mob/living/M = owner
	// dead or clientless mobs dont get the brain trauma
	if(M.stat == DEAD || !M.client)
		qdel(src)
		return
	..()
	make_friend()
	get_ghost()

/datum/brain_trauma/special/imaginary_friend/on_life(delta_time, times_fired)
	if(get_dist(owner, friend) > 9)
		friend.recall()
	if(!friend)
		qdel(src)
		return
	if(!friend.client && friend_initialized)
		addtimer(CALLBACK(src, PROC_REF(reroll_friend)), 600)

/datum/brain_trauma/special/imaginary_friend/on_death()
	..()
	qdel(src) //friend goes down with the ship

/datum/brain_trauma/special/imaginary_friend/on_lose()
	..()
	QDEL_NULL(friend)

//If the friend goes afk, make a brand new friend. Plenty of fish in the sea of imagination.
/datum/brain_trauma/special/imaginary_friend/proc/reroll_friend()
	if(friend.client) //reconnected
		return
	friend_initialized = FALSE
	QDEL_NULL(friend)
	make_friend()
	get_ghost()

/datum/brain_trauma/special/imaginary_friend/proc/make_friend()
	friend = new(get_turf(owner), src)

/datum/brain_trauma/special/imaginary_friend/proc/get_ghost()
	set waitfor = FALSE
	if(owner.stat == DEAD || !owner.mind)
		qdel(src)
		return

	var/datum/poll_config/config = new()
	config.check_jobban = ROLE_IMAGINARY_FRIEND
	config.poll_time = 10 SECONDS
	config.jump_target = owner
	config.role_name_text = "[owner]'s imaginary friend"
	config.alert_pic = owner
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(config, owner)
	if(candidate)
		friend.key = candidate.key
		friend_initialized = TRUE
	else
		qdel(src)

/mob/camera/imaginary_friend
	name = "imaginary friend"
	real_name = "imaginary friend"
	move_on_shuttle = TRUE
	desc = "A wonderful yet fake friend."
	see_in_dark = 0
	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	sight = NONE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	see_invisible = SEE_INVISIBLE_LIVING
	invisibility = INVISIBILITY_MAXIMUM
	can_hear_init = TRUE // Enable hearing sensitive trait
	initial_language_holder = /datum/language_holder/empty // language will be changed from init()
	var/icon/human_image
	var/image/current_image
	var/hidden = FALSE
	var/move_delay = 0
	var/mob/living/carbon/owner
	var/datum/brain_trauma/special/imaginary_friend/trauma

	var/datum/action/innate/imaginary_join/join
	var/datum/action/innate/imaginary_hide/hide

/mob/camera/imaginary_friend/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	greet()
	Show()

/mob/camera/imaginary_friend/proc/greet()
	to_chat(src, span_notice("<b>You are the imaginary friend of [owner]!</b>"))
	to_chat(src, span_notice("You are absolutely loyal to your friend, no matter what."))
	to_chat(src, span_notice("You cannot directly influence the world around you, but you can see what [owner] cannot."))

CREATION_TEST_IGNORE_SUBTYPES(/mob/camera/imaginary_friend)

/mob/camera/imaginary_friend/Initialize(mapload, _trauma)
	. = ..()

	trauma = _trauma
	owner = trauma.owner
	copy_languages(owner, LANGUAGE_FRIEND, spoken=FALSE) // they don't have to speak in a language of their owner knows - as their language is imaginary echoes from their owner.
	grant_language(/datum/language/metalanguage) // they only speak in metalanguage
	language_holder.selected_language = /datum/language/metalanguage

	setup_friend()

	join = new
	join.Grant(src)
	hide = new
	hide.Grant(src)

	// Update icon on turn
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(Show))

	// Hear owner if they're out of range
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(owner_speech))

/mob/camera/imaginary_friend/Destroy()
	qdel(join)
	qdel(hide)
	UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE)
	if(owner)
		UnregisterSignal(owner, COMSIG_MOB_SAY)
	return ..()

/mob/camera/imaginary_friend/proc/setup_friend()
	gender = pick(MALE, FEMALE)
	real_name = generate_random_name_species_based(gender, FALSE, /datum/species/human)
	name = real_name
	human_image = get_flat_human_icon(null, pick(SSjob.occupations))

/mob/camera/imaginary_friend/proc/Show()
	SIGNAL_HANDLER
	if(!client) //nobody home
		return

	//Remove old image from owner and friend
	if(owner.client)
		owner.client.images.Remove(current_image)

	client.images.Remove(current_image)

	//Generate image from the static icon and the current dir
	current_image = image(human_image, src, , MOB_LAYER, dir=src.dir)
	current_image.override = TRUE
	current_image.name = name
	if(hidden)
		current_image.alpha = 150

	//Add new image to owner and friend
	if(!hidden && owner.client)
		owner.client.images |= current_image

	client.images |= current_image

/mob/camera/imaginary_friend/Destroy()
	if(owner?.client)
		owner.client.images.Remove(human_image)
	if(client)
		client.images.Remove(human_image)
	return ..()

/mob/camera/imaginary_friend/proc/owner_speech(speaker, speech_args)
	SIGNAL_HANDLER
	var/list/listening = get_hearers_in_view(6, owner, SEE_INVISIBLE_MAXIMUM)
	if(!(src in listening))
		to_chat(src, span_hear("You hear a distant voice in your head..."))
		to_chat(src, span_gamesay("[span_name("[speaker]")] [span_message("[say_quote(speech_args[SPEECH_MESSAGE])]")]"))

/mob/camera/imaginary_friend/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, message_range = 7, datum/saymode/saymode = null)
	if (!message)
		return

	if (src.client)
		if(client.player_details.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	friend_talk(message)

/mob/camera/imaginary_friend/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	to_chat(src, compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode))

/mob/camera/imaginary_friend/proc/friend_talk(message)
	message = treat_message_min(trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if(!message)
		return

	src.log_talk(message, LOG_SAY, tag="imaginary friend")

	// Display message
	var/owner_chat_map = owner.client?.prefs.read_player_preference(/datum/preference/toggle/enable_runechat) && owner.client.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_non_mobs)
	var/friend_chat_map = client?.prefs.read_player_preference(/datum/preference/toggle/enable_runechat) && client.prefs.read_player_preference(/datum/preference/toggle/enable_runechat_non_mobs)
	if (!owner_chat_map)
		var/mutable_appearance/MA = mutable_appearance('icons/mob/talk.dmi', src, "default[say_test(message)]", FLY_LAYER)
		MA.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay_global), MA, list(owner.client), 30)

	if(owner_chat_map || friend_chat_map)
		var/list/hearers = list()
		if(friend_chat_map)
			hearers += client
		if(owner_chat_map)
			hearers += owner.client
		new /datum/chatmessage(message, src, hearers, null)

	var/rendered = span_gamesay("[span_name("[name]")] [span_message("[say_quote(message)]")]")
	var/dead_rendered = span_gamesay("[span_name("[name] (Imaginary friend of [owner])")] [span_message("[say_quote(message)]")]")

	to_chat(owner, "[rendered]")
	to_chat(src, "[rendered]")

	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, owner)
		to_chat(M, "[link] [dead_rendered]")

/mob/camera/imaginary_friend/Move(NewLoc, Dir = 0)
	if(world.time < move_delay)
		return FALSE
	if(get_dist(src, owner) > 9)
		recall()
		move_delay = world.time + 10
		return FALSE
	abstract_move(NewLoc)
	move_delay = world.time + 1

/mob/camera/imaginary_friend/abstract_move(atom/destination)
	. = ..()
	Show()

/mob/camera/imaginary_friend/proc/recall()
	if(!owner || loc == owner)
		return FALSE
	abstract_move(owner)

/mob/camera/imaginary_friend/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return FALSE
	to_chat(owner, "<b>[src]</b> points at [A].")
	to_chat(src, span_notice("You point at [A]."))

	var/turf/our_tile = get_turf(src)
	var/turf/tile = get_turf(A)
	var/image/arrow = image(icon = 'icons/hud/screen_gen.dmi', loc = our_tile, icon_state = "arrow")
	arrow.plane = POINT_PLANE
	animate(arrow, pixel_x = (tile.x - our_tile.x) * world.icon_size + A.pixel_x, pixel_y = (tile.y - our_tile.y) * world.icon_size + A.pixel_y, time = 1.7, easing = EASE_OUT)
	owner?.client?.images += arrow
	client?.images += arrow
	addtimer(CALLBACK(src, PROC_REF(remove_arrow), arrow, client, owner?.client), 2.5 SECONDS)
	return TRUE

/mob/camera/imaginary_friend/proc/remove_arrow(image/arrow, client/client_1, client/client_2)
	client_1?.images -= arrow
	client_2?.images -= arrow
	qdel(arrow)

/datum/action/innate/imaginary_join
	name = "Join"
	desc = "Join your owner, following them from inside their mind."
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "join"

/datum/action/innate/imaginary_join/on_activate()
	var/mob/camera/imaginary_friend/I = owner
	I.recall()

/datum/action/innate/imaginary_hide
	name = "Hide"
	desc = "Hide yourself from your owner's sight."
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "hide"

/datum/action/innate/imaginary_hide/proc/update_status()
	var/mob/camera/imaginary_friend/I = owner
	if(I.hidden)
		name = "Show"
		desc = "Become visible to your owner."
		button_icon_state = "unhide"
	else
		name = "Hide"
		desc = "Hide yourself from your owner's sight."
		button_icon_state = "hide"
	update_buttons()

/datum/action/innate/imaginary_hide/on_activate()
	var/mob/camera/imaginary_friend/I = owner
	I.hidden = !I.hidden
	I.Show()
	update_status()

//down here is the trapped mind
//like imaginary friend but a lot less imagination and more like mind prison//

/datum/brain_trauma/special/imaginary_friend/trapped_owner
	name = "Trapped Victim"
	desc = "Patient appears to be targeted by an invisible entity."
	gain_text = ""
	lose_text = ""
	trauma_flags = TRAUMA_DEFAULT_FLAGS | TRAUMA_NOT_RANDOM

/datum/brain_trauma/special/imaginary_friend/trapped_owner/make_friend()
	friend = new /mob/camera/imaginary_friend/trapped(get_turf(owner), src)

/datum/brain_trauma/special/imaginary_friend/trapped_owner/reroll_friend() //no rerolling- it's just the last owner's hell
	if(friend.client) //reconnected
		return
	friend_initialized = FALSE
	QDEL_NULL(friend)
	qdel(src)

/datum/brain_trauma/special/imaginary_friend/trapped_owner/get_ghost() //no randoms
	return

/mob/camera/imaginary_friend/trapped
	name = "figment of imagination?"
	real_name = "figment of imagination?"
	desc = "The previous host of this body."

/mob/camera/imaginary_friend/trapped/greet()
	to_chat(src, span_notice("<b>You have managed to hold on as a figment of the new host's imagination!</b>"))
	to_chat(src, span_notice("All hope is lost for you, but at least you may interact with your host. You do not have to be loyal to them."))
	to_chat(src, span_notice("You cannot directly influence the world around you, but you can see what the host cannot."))

/mob/camera/imaginary_friend/trapped/setup_friend()
	real_name = "[owner.real_name]?"
	name = real_name
	human_image = icon('icons/mob/lavaland/lavaland_monsters.dmi', icon_state = "curseblob")
