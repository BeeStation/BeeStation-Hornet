/datum/action/spell/vow_of_silence
	name = "Speech"
	desc = "Make (or break) a vow of silence."
	background_icon_state = "bg_mime"
	icon_icon = 'icons/hud/actions/actions_mime.dmi'
	button_icon_state = "mime_speech"

	school = SCHOOL_MIME
	cooldown_time = 5 MINUTES

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIND
	spell_max_level = 1

/datum/action/spell/vow_of_silence/on_cast(mob/user, atom/target)
	. = ..()
	user.mind.miming = !user.mind.miming
	if(user.mind.miming)
		to_chat(user, ("<span class='notice'>You make a vow of silence.</span>"))
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "vow")
	else
		to_chat(user, ("<span class='notice'>You break your vow of silence.</span>"))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "vow", /datum/mood_event/broken_vow)
	user.update_action_buttons_icon()
