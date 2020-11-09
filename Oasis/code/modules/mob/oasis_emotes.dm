/datum/emote/living/carbon/human/nya
	key = "nya"
	key_third_person = "lets out a nya"
	message = "lets out a nya!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/nya/get_sound(mob/living/carbon/human/H)
	if(H.gender == FEMALE)
		return 'Oasis/sound/misc/nya.ogg'
	else
		return // I dare you to add sound for this

/datum/emote/living/meow
	key = "meow"
	key_third_person = "mrowls"
	message = "mrowls!"
	emote_type = EMOTE_AUDIBLE
	sound = 'Oasis/sound/misc/meow1_emote.ogg'

/datum/emote/living/meow/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(istype(H))
		return iscatperson(H)
	else
		return iscat(user)

/datum/emote/living/purr
	key = "purr"
	key_third_person = "purrs softly"
	message = "purrs softly."
	emote_type = EMOTE_AUDIBLE
	sound = 'Oasis/sound/misc/purr.ogg'

/datum/emote/living/purr/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(istype(H))
		return iscatperson(H)
	else
		return iscat(user)
