/datum/action/spell/vow_of_silence
	name = "Speech"
	desc = "Make (or break) a vow of silence."
	background_icon_state = "bg_mime"
	button_icon = 'icons/hud/actions/actions_mime.dmi'
	button_icon_state = "mime_speech"

	school = SCHOOL_MIME
	cooldown_time = 5 MINUTES
	spell_requirements = NONE

	spell_max_level = 1

/datum/action/spell/vow_of_silence/Grant(mob/grant_to)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_MIMING, "[type]")

/datum/action/spell/vow_of_silence/Remove(mob/living/remove_from)
	. = ..()
	REMOVE_TRAIT(remove_from, TRAIT_MIMING, "[type]")

/datum/action/spell/vow_of_silence/pre_cast(mob/user, atom/target)
	if(tgui_alert(user, "Are you sure? There's no going back.", "Break Vow", list("I'm Sure", "Abort")) != "I'm Sure")
		return SPELL_CANCEL_CAST
	return ..()

/datum/action/spell/vow_of_silence/on_cast(mob/user, atom/target)
	. = ..()
	to_chat(user, span_notice("You break your vow of silence."))
	user.log_message("broke [user.p_their()] vow of silence.", LOG_GAME)
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "vow", /datum/mood_event/broken_vow)
	REMOVE_TRAIT(user, TRAIT_MIMING, "[type]")

	var/datum/job/mime/mime_job = SSjob.GetJob(JOB_NAME_MIME)
	mime_job.total_positions += 1

	qdel(src)
