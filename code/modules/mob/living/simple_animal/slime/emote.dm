/datum/emote/slime
	mob_type_allowed_typecache = /mob/living/simple_animal/slime
	mob_type_blacklist_typecache = list()

/datum/emote/slime/bounce
	key = "bounce"
	key_third_person = "bounces"
	message = "bounces in place."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/slime/jiggle
	key = "jiggle"
	key_third_person = "jiggles"
	message = "jiggles!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/slime/light
	key = "light"
	key_third_person = "lights"
	message = "lights up for a bit, then stops."
	emote_type = EMOTE_VISIBLE

/datum/emote/slime/vibrate
	key = "vibrate"
	key_third_person = "vibrates"
	message = "vibrates!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/slime/squish
	key = "squish"
	key_third_person = "squishes"
	message = "squishes"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	sound_volume = 25

/datum/emote/slime/squish/get_sound(mob/living/user)
	return 'sound/effects/blobattack.ogg'

/datum/emote/slime/mood
	key = "moodnone"
	var/mood = null
	emote_type = EMOTE_VISIBLE

/datum/emote/slime/mood/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/mob/living/simple_animal/slime/S = user
	S.mood = mood
	S.regenerate_icons()

/datum/emote/slime/mood/sneaky
	key = "moodsneaky"
	mood = "mischievous"

/datum/emote/slime/mood/smile
	key = "moodsmile"
	mood = ":3"

/datum/emote/slime/mood/cat
	key = "moodcat"
	mood = ":33"

/datum/emote/slime/mood/pout
	key = "moodpout"
	mood = "pout"

/datum/emote/slime/mood/sad
	key = "moodsad"
	mood = "sad"

/datum/emote/slime/mood/angry
	key = "moodangry"
	mood = "angry"
