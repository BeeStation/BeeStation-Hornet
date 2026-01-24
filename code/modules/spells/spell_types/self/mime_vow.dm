/datum/action/spell/vow_of_silence
	name = "Speech"
	desc = "Make (or break) a vow of silence."
	background_icon_state = "bg_mime"
	button_icon = 'icons/hud/actions/actions_mime.dmi'
	button_icon_state = "mime_speech"

	school = SCHOOL_MIME
	cooldown_time = 5 MINUTES

	spell_max_level = 1

/datum/action/cooldown/spell/vow_of_silence/Grant(mob/grant_to)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_MIMING, "[type]")

/datum/action/cooldown/spell/vow_of_silence/Remove(mob/living/remove_from)
	. = ..()
	REMOVE_TRAIT(remove_from, TRAIT_MIMING, "[type]")
	SEND_SIGNAL(remove_from, COMSIG_CLEAR_MOOD_EVENT, "vow")

/datum/action/spell/vow_of_silence/on_cast(mob/user, atom/target)
	. = ..()
	if(HAS_TRAIT_FROM(user, TRAIT_MIMING, "[type]"))
		to_chat(user, span_notice("You break your vow of silence."))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "vow", /datum/mood_event/broken_vow)
		REMOVE_TRAIT(user, TRAIT_MIMING, "[type]")
	else
		to_chat(user, span_notice("You make a vow of silence."))
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "vow")
		ADD_TRAIT(user, TRAIT_MIMING, "[type]")
	user.update_action_buttons_icon()
