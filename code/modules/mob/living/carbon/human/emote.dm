/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/// The time it takes for the crying visual to be removed
#define CRY_DURATION 12.8 SECONDS

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/cry/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && ishuman(user)) // Give them a visual crying effect if they're human
		var/mob/living/carbon/human/human_user = user
		ADD_TRAIT(human_user, TRAIT_CRYING, "[type]")
		human_user.update_body()

		// Use a timer to remove the effect after the defined duration has passed
		var/list/key_emotes = GLOB.emote_list["cry"]
		for(var/datum/emote/living/carbon/human/cry/human_emote in key_emotes)
			// The existing timer restarts if it is already running
			addtimer(CALLBACK(human_emote, PROC_REF(end_visual), human_user), CRY_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/emote/living/carbon/human/cry/proc/end_visual(mob/living/carbon/human/human_user)
	if(!QDELETED(human_user))
		REMOVE_TRAIT(human_user, TRAIT_CRYING, "[type]")
		human_user.update_body()

#undef CRY_DURATION

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful"
	message_param = "give daps to %t"
	hands_use_check = TRUE

/datum/emote/living/carbon/human/etwitch
	key = "etwitch"
	key_third_person = "twitches their ears"
	message = "twitches their ears"
	vary = TRUE

/datum/emote/living/carbon/human/etwitch/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	return ("ears" in H.dna?.species?.mutant_bodyparts)

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow"

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hand"
	message_param = "shakes hands with %t"
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself"
	message_param = "hugs %t"
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/offer
	key = "offer"
	message = "offers an item"

/datum/emote/living/carbon/human/moth
	// allow mothroach as well as human base mob - species check is done in can_run_emote
	mob_type_allowed_typecache = list(/mob/living/carbon/human,/mob/living/basic/mothroach)

/datum/emote/living/carbon/human/moth/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	if(ishuman(user))
		return ismoth(user)
	return istype(user, /mob/living/basic/mothroach)

/datum/emote/living/carbon/human/moth/squeak
	key = "msqueak"
	key_third_person = "squeaks"
	message = "lets out a tiny squeak"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/emotes/mothsqueak.ogg'

/datum/emote/living/carbon/human/moth/chitter
	key = "chitter"
	key_third_person = "chitters"
	message = "chitters"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/emotes/mothchitter.ogg'

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(!ishuman(user) || user.mind?.miming)
		return
	var/mob/living/carbon/H = user
	return H.dna?.species?.get_scream_sound(H)

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second"

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand"
	hands_use_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes"
	message_param = "salutes to %t"
	hands_use_check = TRUE

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs"

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "wags their tail"

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/tail/tail = H?.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return
	tail.toggle_wag(H)

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	return istype(H?.getorganslot(ORGAN_SLOT_TAIL), /obj/item/organ/tail)

/datum/emote/living/carbon/human/wag/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/tail/tail = H.getorganslot(ORGAN_SLOT_TAIL)
	if(tail?.is_wagging(H))
		. = null

/datum/emote/living/carbon/human/wing
	key = "wing"
	key_third_person = "wings"
	message = "their wings"

/datum/emote/living/carbon/human/wing/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = user
		H.Togglewings()

/datum/emote/living/carbon/human/wing/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if((H.dna.species.mutant_bodyparts["wings"]) || (H.dna.species.mutant_bodyparts["moth_wings"]))
		. = "opens " + message
	else
		. = "closes " + message

/datum/emote/living/carbon/human/wing/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.dna && H.dna.species)
		if(H.dna.features["wings"] != "None")
			return TRUE
		if(H.dna.features["moth_wings"] != "None")
			var/obj/item/organ/wings/wings = H.getorganslot(ORGAN_SLOT_WINGS)
			if(istype(wings))
				if(wings.flight_level >= WINGS_FLYING)
					return TRUE

/mob/living/carbon/human/proc/Togglewings()
	if(!dna || !dna.species)
		return FALSE
	var/obj/item/organ/wings/wings = getorganslot(ORGAN_SLOT_WINGS)
	if(istype(wings))
		if(ismoth(src) && HAS_TRAIT(src, TRAIT_MOTH_BURNT))
			return FALSE
		if(wings.toggleopen(src))
			return TRUE
	return FALSE


/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"
	message = "farts"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/human/fart/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	return 'sound/misc/fart1.ogg'

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	if(ishuman(user))
		var/mob/living/carbon/human/fartee = user
		if(COOLDOWN_FINISHED(fartee, special_emote_cooldown))
			..()
			COOLDOWN_START(fartee, special_emote_cooldown, 20 SECONDS)
		else
			to_chat(user, "<span class='warning'>You strain, but can't seem to fart again just yet.</span>")
		return TRUE

// Robotic Tongue emotes. Beep!

/datum/emote/living/carbon/human/robot_tongue/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	var/obj/item/organ/tongue/T = user.getorganslot(ORGAN_SLOT_TONGUE)
	if(T.status == ORGAN_ROBOTIC)
		return TRUE

/datum/emote/living/carbon/human/robot_tongue/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps"
	message_param = "beeps at %t"

/datum/emote/living/carbon/human/robot_tongue/boop
	key = "boop"
	key_third_person = "boops"
	message = "boops."
	sound = 'sound/machines/boop.ogg'

/datum/emote/living/carbon/human/robot_tongue/beep/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/twobeep.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "buzzes"
	message_param = "buzzes at %t"

/datum/emote/living/carbon/human/robot_tongue/buzz/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/buzz-sigh.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/buzz2
	key = "buzz2"
	message = "buzzes twice"

/datum/emote/living/carbon/human/robot_tongue/buzz2/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/buzz-two.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/chime
	key = "chime"
	key_third_person = "chimes"
	message = "chimes"

/datum/emote/living/carbon/human/robot_tongue/chime/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/chime.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/ping
	key = "ping"
	key_third_person = "pings"
	message = "pings"
	message_param = "pings at %t"

/datum/emote/living/carbon/human/robot_tongue/ping/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/machines/ping.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/dwoop
	key = "dwoop"
	key_third_person = "dwoops"
	message = "emits a dwoop sound."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/robot_tongue/dwoop/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/emotes/dwoop.ogg', 50)

// Clown Robotic Tongue ONLY. Henk.

/datum/emote/living/carbon/human/robot_tongue/clown/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	if(user.mind.assigned_role == JOB_NAME_CLOWN)
		return TRUE

/datum/emote/living/carbon/human/robot_tongue/clown/honk
	key = "honk"
	key_third_person = "honks"
	message = "honks"

/datum/emote/living/carbon/human/robot_tongue/clown/honk/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/items/bikehorn.ogg', 50)

/datum/emote/living/carbon/human/robot_tongue/clown/sad
	key = "sad"
	key_third_person = "plays a sad trombone"
	message = "plays a sad trombone"

/datum/emote/living/carbon/human/robot_tongue/clown/sad/run_emote(mob/user, params)
	if(..())
		playsound(user.loc, 'sound/misc/sadtrombone.ogg', 50)

/datum/emote/living/carbon/human/diona
	// allow mothroach as well as human base mob - species check is done in can_run_emote
	mob_type_allowed_typecache = list(/mob/living/carbon/human,/mob/living/simple_animal/hostile/retaliate/nymph)

/datum/emote/living/carbon/human/diona/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	if(ishuman(user))
		return isdiona(user)
	return istype(user, /mob/living/simple_animal/hostile/retaliate/nymph)

/datum/emote/living/carbon/human/diona/chitter
	key = "chitter"
	key_third_person = "chitters"
	message = "chitters"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/emotes/diona/chitter.ogg'

/datum/emote/living/carbon/human/diona/cricket
	key = "cricket"
	key_third_person = "chirps"
	message = "chirps"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/emotes/diona/cricket.ogg'
	sound_volume = 30
