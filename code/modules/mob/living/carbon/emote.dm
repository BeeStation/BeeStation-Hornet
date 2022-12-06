/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp"
	restraint_check = TRUE

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "blinks"

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "blinks rapidly"

/datum/emote/living/carbon/clap
	key = "clap"
	key_third_person = "claps"
	message = "claps"
	muzzle_ignore = TRUE
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/clap/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	// sorry pal, but you need arms to clap
	var/mob/living/carbon/C = user
	return C.get_bodypart(BODY_ZONE_L_ARM) && C.get_bodypart(BODY_ZONE_R_ARM)

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	return pick(
		'sound/misc/clap1.ogg',
		'sound/misc/clap2.ogg',
		'sound/misc/clap3.ogg',
		'sound/misc/clap4.ogg',
	)

/datum/emote/living/carbon/eyeroll
	key = "eyeroll"
	key_third_person = "eyerolls"
	message = "rolls their eyes"
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/carbon/alien)

/datum/emote/living/carbon/eyeroll/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	return istype(E)

/datum/emote/living/carbon/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth.."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey)

/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans"
	message_mime = "appears to moan"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/roll
	key = "roll"
	key_third_person = "rolls"
	message = "rolls"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "scratches"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/screech
	key = "screech"
	key_third_person = "screeches"
	message = "screeches"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey)
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/screech/get_sound(mob/living/user)
	return pick('sound/creatures/monkey/monkey_screech_1.ogg',
				'sound/creatures/monkey/monkey_screech_2.ogg',
				'sound/creatures/monkey/monkey_screech_3.ogg',
				'sound/creatures/monkey/monkey_screech_4.ogg',
				'sound/creatures/monkey/monkey_screech_5.ogg',
				'sound/creatures/monkey/monkey_screech_6.ogg',
				'sound/creatures/monkey/monkey_screech_7.ogg')

/datum/emote/living/carbon/snap
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = TRUE
	vary = TRUE

/datum/emote/living/carbon/snap/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	// sorry pal, but you need an arm to snap
	var/mob/living/carbon/C = user
	return C.get_bodypart(BODY_ZONE_L_ARM) || C.get_bodypart(BODY_ZONE_R_ARM)

/datum/emote/living/carbon/snap/one
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers"
	message_param = "snaps their fingers at %t"
	sound = 'sound/emotes/snap.ogg'

/datum/emote/living/carbon/snap/two
	key = "snap2"
	key_third_person = "snaps2"
	message = "snaps their fingers twice"
	message_param = "snaps their fingers at %t twice"
	sound = 'sound/emotes/snap2.ogg'

/datum/emote/living/carbon/snap/three
	key = "snap3"
	key_third_person = "snaps3"
	message = "snaps their fingers thrice"
	message_param = "snaps their fingers at %t thrice"
	sound = 'sound/emotes/snap3.ogg'

/datum/emote/living/carbon/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars"

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "signs the number %t"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/sign/select_param(mob/user, params)
	. = ..()
	if(!isnum_safe(text2num(params)))
		return message

/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "raises %t fingers"
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	restraint_check = TRUE

/datum/emote/living/carbon/tail
	key = "tail"
	message = "waves their tail"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks"

/datum/emote/living/carbon/sweatdrop
	key = "sweatdrop"
	key_third_person = "sweatdrops"
	message = "sweats"
	emote_type = EMOTE_ANIMATED
	sound_volume = 25
	vary = TRUE
	overlay_icon_state = "sweatdrop"
	overlay_x_offset = 10
	overlay_y_offset = 10
	emote_length = 3 SECONDS
	sound = 'sound/emotes/sweatdrop.ogg'

/datum/emote/living/carbon/annoyed
	key = "annoyed"
	emote_type = EMOTE_ANIMATED
	sound_volume = 25
	vary = TRUE
	overlay_icon_state = "annoyed"
	overlay_x_offset = 10
	overlay_y_offset = 10
	emote_length = 5 SECONDS
	sound = 'sound/emotes/annoyed.ogg'

/datum/emote/living/carbon/glasses
	key = "glasses"
	message = "pushes up their glasses"
	emote_type = EMOTE_ANIMATED
	overlay_icon_state = "glasses"
	emote_length = 1 SECONDS

/datum/emote/living/carbon/glasses/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	return istype(user.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses)
