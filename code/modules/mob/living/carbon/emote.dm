/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp"
	restraint_check = TRUE

/datum/emote/living/carbon/blep
	key = "blep"
	key_third_person = "bleps"
	message = "bleps their tongue out."
	message_AI = "shows an image of a random blepping animal."
	emote_type = EMOTE_VISIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/carbon/alien,/mob/living/carbon/human/species/abductor,/mob/living/carbon/human/species/fly,/mob/living/silicon/robot)

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

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return pick('sound/misc/clap1.ogg',
							'sound/misc/clap2.ogg',
							'sound/misc/clap3.ogg',
							'sound/misc/clap4.ogg')

/datum/emote/living/carbon/clear
	key = "clear"
	key_third_person = "clears their throat"
	message = "clears their throat."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/carbon/alien,/mob/living/carbon/human/species/abductor)

/datum/emote/living/carbon/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/carbon/human/species/abductor,/mob/living/silicon,/mob/living/carbon/alien/,/mob/living/carbon/human/species/ipc,/mob/living/carbon/human/species/android,/mob/living/carbon/human/species/golem,/mob/living/carbon/human/species/moth)

/datum/emote/living/carbon/cough/get_sound(mob/living/user)
	if(user.gender==MALE)
		return pick('code/datums/emote_sounds/emotes/male/male_cough_1.ogg',
					'code/datums/emote_sounds/emotes/male/male_cough_2.ogg',
					'code/datums/emote_sounds/emotes/male/male_cough_3.ogg')
	return pick('code/datums/emote_sounds/emotes/female/female_cough_1.ogg',
				'code/datums/emote_sounds/emotes/female/female_cough_2.ogg',
				'code/datums/emote_sounds/emotes/female/female_cough_3.ogg')

/datum/emote/living/carbon/cough/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_SOOTHED_THROAT))
		return FALSE
/datum/emote/living/carbon/dwoop
	key = "dwoop"
	key_third_person = "dwoops"
	message = "emits a dwoop sound."
	mob_type_allowed_typecache = list(/mob/living/silicon,/mob/living/carbon/human/species/ipc)
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/dwoop/get_sound(mob/living/user)
		return pick ('code/datums/emote_sounds/emotes/dwoop.ogg')

/datum/emote/living/carbon/etwitch
	key = "etwitch"
	key_third_person = "twitches their ears"
	message = "twitches their ears!"
	emote_type = EMOTE_VISIBLE
	vary = TRUE
	mob_type_allowed_typecache = /mob/living/carbon/human/species/felinid

/datum/emote/living/carbon/eyeroll
	key = "eyeroll"
	key_third_person = "eyerolls"
	message = "rolls their eyes"
	emote_type = EMOTE_VISIBLE
	vary = TRUE
	mob_type_blacklist_typecache = /mob/living/carbon/alien

/datum/emote/living/carbon/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/carbon/human/species/abductor,/mob/living/silicon,/mob/living/carbon/alien/,/mob/living/carbon/human/species/ipc,/mob/living/carbon/human/species/android,/mob/living/carbon/human/species/golem,/mob/living/carbon/human/species/moth)

/datum/emote/living/carbon/gasp/get_sound(mob/living/user)
	if(user.gender==MALE)
		return pick('code/datums/emote_sounds/emotes/male/gasp_m1.ogg',
				'code/datums/emote_sounds/emotes/male/gasp_m2.ogg',
				'code/datums/emote_sounds/emotes/male/gasp_m3.ogg',
				'code/datums/emote_sounds/emotes/male/gasp_m4.ogg',
				'code/datums/emote_sounds/emotes/male/gasp_m5.ogg',
				'code/datums/emote_sounds/emotes/male/gasp_m6.ogg')
	return pick('code/datums/emote_sounds/emotes/female/gasp_f1.ogg',
				'code/datums/emote_sounds/emotes/female/gasp_f2.ogg',
				'code/datums/emote_sounds/emotes/female/gasp_f3.ogg',
				'code/datums/emote_sounds/emotes/female/gasp_f4.ogg',
				'code/datums/emote_sounds/emotes/female/gasp_f5.ogg',
				'code/datums/emote_sounds/emotes/female/gasp_f6.ogg')

/datum/emote/living/carbon/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "gnarls and shows its teeth.."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey)

/datum/emote/living/carbon/huff
	key = "huff"
	key_third_person = "huffs"
	message ="lets out a huff!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/carbon/human/species/abductor,/mob/living/silicon,/mob/living/carbon/alien/,/mob/living/carbon/human/species/ipc,/mob/living/carbon/human/species/android,/mob/living/carbon/human/species/golem)

/datum/emote/living/carbon/headtilt
	key = "tilt"
	key_third_person = "tilts"
	message = "tilts their head."
	message_AI = "tilts the image on their display."
	emote_type = EMOTE_VISIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/silicon/robot,/mob/living/carbon/alien/larva)

/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "moans"
	message_mime = "appears to moan"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/mothsqueak
	key = "msqueak"
	key_third_person = "lets out a tiny squeak"
	message = "lets out a tiny squeak!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon/human/species/moth,/mob/living/simple_animal/mothroach)
	sound = 'code/datums/emote_sounds/emotes/mothsqueak.ogg'

/datum/emote/living/carbon/mothchitter
	key = "chitter"
	key_third_person = "chitters"
	message = "chitters."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon/human/species/moth,/mob/living/simple_animal/mothroach)
	sound = 'code/datums/emote_sounds/emotes/mothchitter.ogg'

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
	key = "snap"
	key_third_person = "snaps"
	message = "snaps."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = TRUE
	vary = TRUE
	sound = 'code/datums/emote_sounds/voice/snap.ogg'

/datum/emote/living/carbon/snap2
	key = "snap2"
	key_third_person = "snaps twice"
	message = "snaps twice."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = TRUE
	vary = TRUE
	sound = 'code/datums/emote_sounds/voice/snap2.ogg'

/datum/emote/living/carbon/snap3
	key = "snap3"
	key_third_person = "snaps thrice"
	message = "snaps thrice."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = TRUE
	vary = TRUE
	sound = 'code/datums/emote_sounds/voice/snap3.ogg'

/datum/emote/living/carbon/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes!"
	mob_type_blacklist_typecache = list(/mob/living/silicon,/mob/living/carbon/alien/,/mob/living/carbon/human/species/ipc,/mob/living/carbon/human/species/android,/mob/living/carbon/human/species/golem,/mob/living/carbon/human/species/moth)
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/sneeze/get_sound(mob/living/user)
	if(user.gender==MALE)
		return 'code/datums/emote_sounds/emotes/male/male_sneeze.ogg'
	return 'code/datums/emote_sounds/emotes/female/female_sneeze.ogg'

/datum/emote/living/carbon/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "roars."

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

/datum/emote/living/carbon/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/silicon,/mob/living/carbon/alien/,/mob/living/carbon/human/species/ipc,/mob/living/carbon/human/species/android,/mob/living/carbon/human/species/golem)

/datum/emote/living/carbon/sniff/get_sound(mob/living/user)
	if(user.gender==MALE)
		return ('code/datums/emote_sounds/emotes/male/male_sniff.ogg')
	return ('code/datums/emote_sounds/emotes/female/female_sniff.ogg')

/datum/emote/living/carbon/tail
	key = "tail"
	message = "waves their tail"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "whistles!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/carbon/human/species/abductor,/mob/living/silicon,/mob/living/carbon/alien/,/mob/living/carbon/human/species/ipc,/mob/living/carbon/human/species/android,/mob/living/carbon/human/species/golem)

/datum/emote/living/carbon/wink
	key = "wink"
	key_third_person = "winks"
	message = "winks"

// HERE IS AN ATTEMPT AT PORTING SKYRAT'S ANIMATED EMOTES. EXPERIMENTAL

/datum/emote
	var/overlay_emote = 'icons/effects/overlay_effects.dmi'

/datum/emote/living/carbon/sweatdrop
	key = "sweatdrop"
	key_third_person = "sweatdrops"

/datum/emote/living/carbon/sweatdrop/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mutable_appearance/overlay = mutable_appearance(overlay_emote, "sweatdrop", ABOVE_MOB_LAYER)
		overlay.pixel_x = 10
		overlay.pixel_y = 10
		flick_overlay_static(overlay, user, 50)
		playsound(get_turf(user), 'code/datums/emote_sounds/emotes/sweatdrop.ogg', 25, TRUE)

/datum/emote/living/carbon/exclaim
	key = "exclaim"
	key_third_person = "exclaims"

/datum/emote/living/carbon/exclaim/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mutable_appearance/overlay = mutable_appearance(overlay_emote, "exclamation", ABOVE_MOB_LAYER)
		overlay.pixel_x = 10
		overlay.pixel_y = 28
		flick_overlay_static(overlay, user, 50)
		playsound(get_turf(user), 'sound/machines/chime.ogg', 25, TRUE)

/datum/emote/living/carbon/question
	key = "question"
	key_third_person = "questions"

/datum/emote/living/carbon/question/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mutable_appearance/overlay = mutable_appearance(overlay_emote, "question", ABOVE_MOB_LAYER)
		overlay.pixel_x = 10
		overlay.pixel_y = 28
		flick_overlay_static(overlay, user, 50)
		playsound(get_turf(user), 'code/datums/emote_sounds/emotes/question.ogg', 25, TRUE)

/datum/emote/living/carbon/realize
	key = "realize"
	key_third_person = "realizes"

/datum/emote/living/carbon/realize/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mutable_appearance/overlay = mutable_appearance(overlay_emote, "realize", ABOVE_MOB_LAYER)
		overlay.pixel_y = 15
		flick_overlay_static(overlay, user, 50)
		playsound(get_turf(user), 'code/datums/emote_sounds/emotes/realize.ogg', 25, TRUE)

/datum/emote/living/carbon/annoyed
	key = "annoyed"
	key_third_person = "is annoyed"

/datum/emote/living/carbon/annoyed/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mutable_appearance/overlay = mutable_appearance(overlay_emote, "annoyed", ABOVE_MOB_LAYER)
		overlay.pixel_x = 10
		overlay.pixel_y = 10
		flick_overlay_static(overlay, user, 50)
		playsound(get_turf(user), 'code/datums/emote_sounds/emotes/annoyed.ogg', 25, TRUE)

/datum/emote/living/carbon/glasses
	key = "glasses"
	key_third_person = "glasses"
	message = "pushes up their glasses"

/datum/emote/living/carbon/glasses/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/O = user.get_item_by_slot(ITEM_SLOT_EYES)
	if((istype(O, /obj/item/clothing/glasses)))
		var/mutable_appearance/overlay = mutable_appearance(overlay_emote, "glasses", ABOVE_MOB_LAYER)
		if(isliving(user))
			overlay.pixel_y = 0
		flick_overlay_static(overlay, user, 10)
	else
		return FALSE
/datum/emote/living/carbon/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	mob_type_blacklist_typecache = list(/mob/living/silicon,/mob/living/carbon/alien/,/mob/living/carbon/human/species/ipc,/mob/living/carbon/human/species/android,/mob/living/carbon/human/species/golem,/mob/living/carbon/human/species/moth)

/datum/emote/living/carbon/sigh/get_sound(mob/living/user)
	if(user.gender==MALE)
		return 'code/datums/emote_sounds/emotes/male/male_sigh.ogg'
	return 'code/datums/emote_sounds/emotes/female/female_sigh.ogg'

/datum/emote/living/carbon/sigh/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	. = ..()
	if(isliving(user))
		var/mutable_appearance/overlay = mutable_appearance(overlay_emote, "sigh", ABOVE_MOB_LAYER)
		overlay.pixel_y = -1

		flick_overlay_static(overlay, user, 50)
