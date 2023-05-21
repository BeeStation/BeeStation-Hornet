/datum/brain_trauma/special/imaginary_friend/mrat
	name = "Epistemania"
	desc = "Patient suffers from a manic pursuit of knowlewdge."
	scan_desc = "epistemania"
	gain_text = "<span class='notice'>Requesting mentor...</span>"
	lose_text = ""
	random_gain = FALSE
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/special/imaginary_friend/mrat/make_friend()
	friend = new /mob/camera/imaginary_friend/mrat(get_turf(owner), src)

/datum/brain_trauma/special/imaginary_friend/mrat/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollMentorCandidatesForMob("Do you want to play as [owner]'s mentor rat?", ROLE_PAI, null, null, 75, friend, POLL_IGNORE_IMAGINARYFRIEND)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		friend.key = C.key
		friend.real_name = friend.key
		friend.name = "Mentor Rat ([friend.real_name])"

		var/mob/camera/imaginary_friend/mrat/I = friend
		I.PickName()
		I.Costume()
		I.add_kick_action()

		friend_initialized = TRUE
		to_chat(owner, "<span class='notice'>You have acquired the mentor rat [friend.key], ask them any question you like. They will leave your presence when they are done.</span>")
	else
		to_chat(owner, "<span class='warning'>No mentor responded to your request. Try again later.</span>")
		qdel(src)

/datum/mrat_type
	var/name
	var/icon
	var/icon_state
	var/color
	var/list/radial_icon
	var/sound
	var/volume

/datum/mrat_type/New(type_name, type_icon, type_icon_state, type_sound, type_color = null, type_volume = 100)
	name = type_name
	icon = type_icon
	icon_state = type_icon_state
	color = type_color
	sound = type_sound
	volume = type_volume

/mob/camera/imaginary_friend/mrat
	name = "Mentor Rat"
	real_name = "Mentor Rat"
	desc = "Your personal mentor assistant."

	var/datum/action/innate/mrat_costume/costume
	var/datum/action/innate/mrat_leave/leave
	var/datum/action/innate/mrat_kick/kick
	var/static/list/icons_available = null
	var/datum/mrat_type/current_costume = null
	var/static/list/mrat_types = list(
		new /datum/mrat_type("Mouse", 'icons/mob/animal.dmi', "mouse_white", "sound/effects/mousesqueek.ogg", "#1ABC9C"),
		new /datum/mrat_type("Corgi", 'icons/mob/pets.dmi', "corgi", "sound/machines/uplinkpurchase.ogg"),
		new /datum/mrat_type("Hamster", 'icons/mob/pets.dmi', "hamster", "sound/effects/mousesqueek.ogg", "#1ABC9C"),
		new /datum/mrat_type("Kitten", 'icons/mob/pets.dmi', "kitten", "sound/machines/uplinkpurchase.ogg"),
		new /datum/mrat_type("Crab", 'icons/mob/animal.dmi', "crab", "sound/machines/uplinkpurchase.ogg"),
		new /datum/mrat_type("Slime Puppy", 'icons/mob/pets.dmi', "slime_puppy", "sound/machines/uplinkpurchase.ogg"),
		new /datum/mrat_type("Chick", 'icons/mob/animal.dmi', "chick", "sound/effects/mousesqueek.ogg"),
		new /datum/mrat_type("Mothroach", 'icons/mob/animal.dmi', "mothroach", "sound/voice/moth/scream_moth.ogg", type_volume=25),
		new /datum/mrat_type("Bee", 'icons/mob/animal.dmi', "bee_big", "sound/voice/moth/scream_moth.ogg", type_volume=25),
		new /datum/mrat_type("Butterfly", 'icons/mob/animal.dmi', "butterfly", "sound/voice/moth/scream_moth.ogg", type_color="#1ABC9C", type_volume=25),
		new /datum/mrat_type("Hologram", 'icons/mob/ai.dmi', "default", "sound/machines/ping.ogg", type_volume=50),
		new /datum/mrat_type("Spaceman", 'icons/mob/animal.dmi', "old", "sound/machines/buzz-sigh.ogg", type_volume=50)
	)

/mob/camera/imaginary_friend/mrat/proc/update_available_icons()
	if(icons_available)
		return
	icons_available = list()

	for(var/datum/mrat_type/T in mrat_types)
		icons_available += list("[T.name]" = image(icon = T.icon, icon_state = T.icon_state))

/mob/camera/imaginary_friend/mrat/proc/Costume()
	update_available_icons()
	var/selection = show_radial_menu(src, src, icons_available, radius = 38)
	if(!selection)
		return

	for(var/datum/mrat_type/T in mrat_types)
		if(T.name == selection)
			current_costume = T
			human_image = image(icon = T.icon, icon_state = T.icon_state)
			color = T.color
			Show()
			return

/mob/camera/imaginary_friend/mrat/proc/PickName()
	var/picked_name = sanitize_name(stripped_input(src, "Enter your mentor rat's name", "Rat Name", "Mentor Rat", MAX_NAME_LEN - 3 - length(key)))
	if(!picked_name || picked_name == "")
		picked_name = "Mentor Rat"
	log_game("[key_name(src)] has set \"[picked_name]\" as their mentor rat's name for [key_name(owner)]")
	name = "[picked_name] ([key])"

/mob/camera/imaginary_friend/mrat/friend_talk()
	. = ..()
	if(!current_costume || !istype(current_costume))
		return
	SEND_SOUND(owner, sound(current_costume.sound, volume=current_costume.volume))
	SEND_SOUND(src, sound(current_costume.sound, volume=(current_costume.volume / 2)))

/mob/camera/imaginary_friend/mrat/greet()
	to_chat(src, "<span class='notice'><b>You are the mentor rat of [owner]!</b></span>")
	to_chat(src, "<span class='notice'>Do not give [owner] any OOC information from your time as a ghost.</span>")
	to_chat(src, "<span class='notice'>Your job is to answer [owner]'s question(s) and you are given this form to assist in that.</span>")
	to_chat(src, "<span class='notice'>Don't be stupid with this or you will face the consequences.</span>")

/mob/camera/imaginary_friend/mrat/Initialize(mapload, _trauma)
	. = ..()
	costume = new
	costume.Grant(src)
	leave = new
	leave.Grant(src)

	grant_all_languages()

/mob/camera/imaginary_friend/mrat/proc/add_kick_action()
	kick = new
	kick.friend = src
	kick.Grant(trauma.owner)

/mob/camera/imaginary_friend/mrat/Destroy()
	QDEL_NULL(costume)
	QDEL_NULL(leave)
	QDEL_NULL(kick)
	return ..()

/mob/camera/imaginary_friend/mrat/setup_friend()
	human_image = null

/datum/action/innate/mrat_costume
	name = "Change Appearance"
	desc = "Shape your appearance to whatever you desire."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "ninja_phase"

/datum/action/innate/mrat_costume/Activate()
	var/mob/camera/imaginary_friend/mrat/I = owner
	if(!istype(I))
		qdel(src)
	I.Costume()

/datum/action/innate/mrat_leave
	name = "Leave"
	desc = "Leave and return to your ghost form."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "beam_up"

/datum/action/innate/mrat_leave/Activate()
	var/mob/camera/imaginary_friend/friend = owner
	if(!istype(friend))
		qdel(src)
	if(alert(friend, "Are you sure you want to leave?", "Leave:", "Yes", "No") != "Yes")
		return
	to_chat(friend, "<span class='warning'>You have ejected yourself from [friend.owner].</span>")
	to_chat(friend.owner, "<span class='warning'>Your mentor has left.</span>")
	qdel(friend.trauma)

/datum/action/innate/mrat_kick
	name = "Remove Mentor"
	desc = "Removes your mentor."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "beam_up"
	var/mob/camera/imaginary_friend/mrat/friend

/datum/action/innate/mrat_kick/Destroy()
	. = ..()
	friend = null

/datum/action/innate/mrat_kick/Activate()
	if(!istype(friend))
		qdel(src)
	if(!istype(friend) || alert(friend, "Are you sure you want to remove your mentor?", "Remove:", "Yes", "No") != "Yes")
		return
	to_chat(friend, "<span class='warning'>You have been removed from [friend.owner].</span>")
	to_chat(friend.owner, "<span class='warning'>Your mentor has been removed.</span>")
	qdel(friend.trauma)
