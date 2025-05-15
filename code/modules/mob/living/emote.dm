
/* EMOTE DATUMS */
/datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(/mob/living/simple_animal/slime, /mob/living/brain)

/// The time it takes for the blush visual to be removed
#define BLUSH_DURATION 5.2 SECONDS

/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes"
	emote_type = EMOTE_VISIBLE
	/// Timer for the blush visual to wear off

/datum/emote/living/blush/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && ishuman(user)) // Give them a visual blush effect if they're human
		var/mob/living/carbon/human/human_user = user
		ADD_TRAIT(human_user, TRAIT_BLUSHING, "[type]")
		human_user.update_body()

		// Use a timer to remove the blush effect after the BLUSH_DURATION has passed
		var/list/key_emotes = GLOB.emote_list["blush"]
		for(var/datum/emote/living/blush/living_emote in key_emotes)

			// The existing timer restarts if it is already running
			addtimer(CALLBACK(living_emote, PROC_REF(end_blush), human_user), BLUSH_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/emote/living/blush/proc/end_blush(mob/living/carbon/human/human_user)
	if(!QDELETED(human_user))
		REMOVE_TRAIT(human_user, TRAIT_BLUSHING, "[type]")
		human_user.update_body()

#undef BLUSH_DURATION

/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "bows"
	message_param = "bows to %t"
	emote_type = EMOTE_VISIBLE
	hands_use_check = TRUE

/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/cross
	key = "cross"
	key_third_person = "crosses"
	message = "crosses their arms"
	emote_type = EMOTE_VISIBLE
	hands_use_check = TRUE

/datum/emote/living/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/collapse/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user) && intentional)
		var/mob/living/living = user
		living.Unconscious(4 SECONDS)

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances around happily"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	message = "seizes up and falls limp, their eyes dead and lifeless"
	message_robot = "shudders violently for a moment before falling still, its eyes slowly darkening"
	message_AI = "lets out a flurry of sparks, its screen flickering as its systems slowly halt"
	message_alien = "lets out a waning guttural screech, green blood bubbling from its maw"
	message_larva = "lets out a sickly hiss of air and falls limply to the floor"
	message_monkey = "lets out a faint chimper as it collapses and stops moving"
	message_ipc = "gives one shrill beep before falling limp, their monitor flashing blue before completely shutting off"
	message_simple =  "stops moving"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_IMPORTANT
	cooldown = (7.5 SECONDS)
	stat_allowed = HARD_CRIT

/datum/emote/living/deathgasp/run_emote(mob/living/user, params, type_override, intentional)
	var/mob/living/simple_animal/S = user
	if(istype(S) && S.deathmessage)
		message_simple = S.deathmessage
	. = ..()
	message_simple = initial(message_simple)
	if(!user.can_speak_vocal() || user.getOxyLoss() >= 50)
		return //stop the sound if oxyloss too high/cant speak
	var/mob/living/carbon/carbon_user = user
	// For masks that give unique death sounds
	if(istype(carbon_user) && isclothing(carbon_user.wear_mask) && carbon_user.wear_mask.unique_death)
		playsound(carbon_user, carbon_user.wear_mask.unique_death, 200, TRUE, TRUE)
		return
	if(user.deathsound)
		playsound(user, user.deathsound, 200, TRUE, TRUE)

/datum/emote/living/drool
	key = "drool"
	key_third_person = "drools"
	message = "drools"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user) && intentional)
		var/mob/living/living = user
		living.SetSleeping(20 SECONDS)

/datum/emote/living/flap
	key = "flap"
	key_third_person = "flaps"
	message = "flaps their wings"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	var/wing_time = 10

/datum/emote/living/flap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/wings/wings = H.getorganslot(ORGAN_SLOT_WINGS)
		if(H.Togglewings())
			addtimer(CALLBACK(H,TYPE_PROC_REF(/mob/living/carbon/human, Togglewings)), wing_time)
		// play moth flutter noise if moth wing
		if(istype(wings, /obj/item/organ/wings/moth))
			playsound(H, 'sound/emotes/moth/moth_flutter.ogg', 50, TRUE)

/datum/emote/living/flap/aflap
	key = "aflap"
	key_third_person = "aflaps"
	name = "flap (Angry)"
	message = "flaps their wings aggressively"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	wing_time = 5

/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "gags"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles"
	message_mime = "giggles silently"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/giggle/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_giggle_sound(H)

/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares"
	message_param = "glares at %t"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans"
	message_mime = "appears to groan"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "grimaces"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "blows a kiss"
	message_param = "blows a kiss to %t"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs"
	message_mime = "laughs silently"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	specific_emote_audio_cooldown = 5 SECONDS
	cooldown_integer_ceiling = 3
	vary = TRUE

/datum/emote/living/laugh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		return !C.silent

/datum/emote/living/laugh/get_sound(mob/living/user)
	if(!iscarbon(user) || user.mind?.miming)
		return
	var/mob/living/carbon/H = user
	return H.dna?.species?.get_laugh_sound(H)

/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "looks"
	message_param = "looks at %t"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/nod
	key = "nod"
	key_third_person = "nods"
	message = "nods"
	message_param = "nods at %t"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "points"
	message_param = "points at %t"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/point/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user) && intentional)
		var/mob/living/carbon/human/H = user
		if(H.usable_hands == 0)
			if(H.usable_legs != 0)
				message_param = "tries to point at %t with a leg, [span_userdanger("falling down")] in the process!"
				H.Paralyze(20)
			else
				message_param = "[span_userdanger("bumps [user.p_their()] head on the ground")] trying to motion towards %t."
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
	..()

/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "pouts"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams"
	message_mime = "acts out a scream"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	mob_type_blacklist_typecache = list(/mob/living/carbon/human) //Humans get specialized scream.
	sound_wall_ignore = TRUE

/datum/emote/living/scream/select_message_type(mob/user, intentional)
	. = ..()
	if(!intentional && isanimal(user))
		return "makes a loud and pained whimper."

/datum/emote/living/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "scowls"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	message = "shakes their head"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers"
	emote_type = EMOTE_VISIBLE

#define SHIVER_LOOP_DURATION (1 SECONDS)
/datum/emote/living/shiver/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	animate(user, pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)
	for(var/i in 1 to SHIVER_LOOP_DURATION / (0.2 SECONDS)) //desired total duration divided by the iteration duration to give the necessary iteration count
		animate(pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
		animate(pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
#undef SHIVER_LOOP_DURATION

/datum/emote/living/sit
	key = "sit"
	key_third_person = "sits"
	message = "sits down"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "grins smugly"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/smirk
	key = "smirk"
	key_third_person = "smirks"
	message = "smirks"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores"
	message_mime = "sleeps soundly"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS

/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "stares"
	message_param = "stares at %t"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "stretches their arms"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "sulks down sadly"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/surrender
	key = "surrender"
	key_third_person = "surrenders"
	message = "puts their hands on their head and falls to the ground, surrendering"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/surrender/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(isliving(user) && intentional)
		var/mob/living/living = user
		living.Paralyze(20 SECONDS)

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "sways around dizzily"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/sway/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	animate(user, pixel_x = user.pixel_x + 2, time = 0.5 SECONDS)
	for(var/i in 1 to 2)
		animate(pixel_x = user.pixel_x - 4, time = 1.0 SECONDS)
		animate(pixel_x = user.pixel_x + 4, time = 1.0 SECONDS)
	animate(pixel_x = user.pixel_x - 2, time = 0.5 SECONDS)

/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "trembles"
	emote_type = EMOTE_VISIBLE

#define TREMBLE_LOOP_DURATION (4.4 SECONDS)
/datum/emote/living/tremble/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	animate(user, pixel_x = user.pixel_x + 2, time = 0.2 SECONDS)
	for(var/i in 1 to TREMBLE_LOOP_DURATION / (0.4 SECONDS)) //desired total duration divided by the iteration duration to give the necessary iteration count
		animate(pixel_x = user.pixel_x - 2, time = 0.2 SECONDS)
		animate(pixel_x = user.pixel_x + 2, time = 0.2 SECONDS)
	animate(pixel_x = user.pixel_x - 2, time = 0.2 SECONDS)
#undef TREMBLE_LOOP_DURATION

/datum/emote/living/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "twitches violently"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/twitch/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	animate(user, pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)
	animate(time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)

/datum/emote/living/twitch_s
	key = "twitch_s"
	name = "twitch (Slight)"
	message = "twitches"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/twitch_s/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	animate(user, pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)

/datum/emote/living/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers"
	message_mime = "appears hurt"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	name = "smile (Weak)"
	message = "smiles weakly"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
	message = null
	mob_type_blacklist_typecache = /mob/living/brain
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/custom/can_run_emote(mob/user, status_check, intentional, params)
	. = ..()
	if(!. || !intentional)
		return FALSE

	if(!isnull(user.ckey) && is_banned_from(user.ckey, "Emote"))
		to_chat(user, "You cannot send custom emotes (banned).")
		return FALSE

	if(QDELETED(user))
		return FALSE

	if(user.client && user.client.prefs.muted & MUTE_IC)
		to_chat(user, "You cannot send IC messages (muted).")
		return FALSE

/datum/emote/living/custom/proc/check_invalid(mob/user, input)
	var/static/regex/stop_bad_mime = regex(@"says|exclaims|yells|asks")
	if(stop_bad_mime.Find(input, 1, 1))
		to_chat(user, span_danger("Invalid emote."))
		return TRUE
	return FALSE

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	if(params && type_override)
		emote_type = type_override
	message = params
	. = ..()
	message = null
	emote_type = null

/datum/emote/living/custom/replace_pronoun(mob/user, message)
	return message

/datum/emote/living/help
	key = "help"

/datum/emote/living/help/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/list/keys = list()
	var/list/message = list("Available emotes, you can use them with say \"*emote\": ")

	for(var/key in GLOB.emote_list)
		for(var/datum/emote/P in GLOB.emote_list[key])
			if(P.key in keys)
				continue
			if(P.can_run_emote(user, status_check = FALSE , intentional = TRUE))
				keys += P.key

	keys = sort_list(keys)

	for(var/emote in keys)
		if(LAZYLEN(message) > 1)
			message += ", [emote]"
		else
			message += "[emote]"

	message += "." // Note that this is adding extras on emotes that already had punctuation

	message = jointext(message, "")

	to_chat(user, message)

/datum/emote/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps"
	message_param = "beeps at %t"
	sound = 'sound/machines/twobeep.ogg'
	emote_type = EMOTE_AUDIBLE
	mob_type_allowed_typecache = list(/mob/living/brain, /mob/living/silicon, /mob/living/simple_animal/hostile/mining_drone)

/datum/emote/living/circle
	key = "circle"
	key_third_person = "circles"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/circle/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(intentional)
		var/obj/item/circlegame/N = new(user)
		if(user.put_in_hands(N))
			to_chat(user, span_notice("You make a circle with your hand."))
		else
			qdel(N)
			to_chat(user, span_warning("You don't have any free hands to make a circle with."))

/datum/emote/living/slap
	key = "slap"
	key_third_person = "slaps"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	cooldown = 2 SECONDS

/datum/emote/living/slap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(intentional)
		var/obj/item/slapper/N = new(user)
		if(user.put_in_hands(N))
			to_chat(user, span_notice("You ready your slapping hand."))
		else
			to_chat(user, span_warning("You're incapable of slapping in your current state."))

/datum/emote/living/raisehand
	key = "highfive"
	key_third_person = "highfives"
	message = "raises their hand"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/raisehand/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(intentional)
		var/obj/item/highfive/N = new(user)
		if(user.put_in_hands(N))
			to_chat(user, span_notice("You raise your hand for a high-five."))
		else
			qdel(N)
			to_chat(user, span_warning("You don't have any free hands to high-five with."))

/datum/emote/living/fingergun
	key = "fingergun"
	key_third_person = "fingerguns"
	message = "forms their fingers into the shape of a crude gun"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/fingergun/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(intentional)
		var/obj/item/gun/ballistic/revolver/mime/N = new(user)
		if(user.put_in_hands(N))
			to_chat(user, span_notice("You form your fingers into a gun."))
		else
			qdel(N)
			to_chat(user, span_warning("You don't have any free hands to make fingerguns with."))

/datum/emote/living/click
	key = "click"
	key_third_person = "clicks their tongue"
	message = "clicks their tongue"
	message_ipc = "makes a click sound"
	message_insect = "clicks their mandibles"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/click/get_sound(mob/living/user)
	if(ismoth(user) || isapid(user) || isflyperson(user) || istype(user, /mob/living/basic/mothroach))
		return 'sound/creatures/rattle.ogg'
	else if(isipc(user))
		return 'sound/machines/click.ogg'
	else
		return FALSE

/datum/emote/living/zap
	key = "zap"
	key_third_person = "zaps"
	message = "zaps"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/zap/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(isethereal(user))
		return TRUE
	else
		return FALSE

/datum/emote/living/zap/get_sound(mob/living/user)
	if(isethereal(user))
		return 'sound/machines/defib_zap.ogg'

/datum/emote/living/hum
	key = "hum"
	key_third_person = "hums"
	message = "hums"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/hiss/get_sound(mob/living/user)
	if(islizard(user))
		return pick('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg', 'sound/voice/hiss5.ogg', 'sound/voice/hiss6.ogg')

/datum/emote/living/thumbs_up
	key = "thumbsup"
	key_third_person = "thumbsup"
	message = "flashes a thumbs up"
	message_robot = "makes a crude thumbs up with their 'hands'"
	message_AI = "flashes a quick hologram of a thumbs up"
	message_ipc = "flashes a thumbs up icon"
	message_simple = "attempts a thumbs up"
	message_param = "flashes a thumbs up at %t"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/thumbs_down
	key = "thumbsdown"
	key_third_person = "thumbsdown"
	message = "flashes a thumbs down"
	message_robot = "makes a crude thumbs down with their 'hands'"
	message_AI = "flashes a quick hologram of a thumbs down"
	message_ipc = "flashes a thumbs down icon"
	message_simple = "attempts a thumbs down"
	message_param = "flashes a thumbs down at %t"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE

/datum/emote/living/whistle
	mob_type_blacklist_typecache = list(/mob/living/simple_animal/slime)
	key="whistle"
	key_third_person="whistle"
	message = "whistles a few notes"
	message_robot = "whistles a few synthesized notes"
	message_AI = "whistles a synthesized song"
	message_ipc = "whistles a few synthesized notes"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/whistle/get_sound(mob/living/user)
	return 'sound/emotes/whistle1.ogg'

/datum/emote/living/tail
	key = "swipe"
	key_third_person = "swipes"
	message = "swipes their tail!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/tail/get_sound(mob/living/user)
	if(islizard(user))
		return pick('sound/effects/tail_swipe1.ogg', 'sound/effects/tail_swipe2.ogg')

/datum/emote/living/tail/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	if(islizard(user))
		var/mob/living/carbon/human/H = user
		return istype(H?.getorganslot(ORGAN_SLOT_TAIL), /obj/item/organ/tail)

/// Breathing required + audible emotes

/datum/emote/living/must_breathe
	vary = TRUE

/datum/emote/living/must_breathe/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	return !HAS_TRAIT(H, TRAIT_NOBREATH)

/datum/emote/living/must_breathe/clear
	key = "clear"
	key_third_person = "clears their throat"
	message = "clears their throat"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/must_breathe/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/must_breathe/cough/can_run_emote(mob/user, status_check = TRUE, intentional)
	return ..() && !HAS_TRAIT(user, TRAIT_SOOTHED_THROAT)

/datum/emote/living/must_breathe/cough/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_cough_sound(H)

/datum/emote/living/must_breathe/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE // You can see a person gasping.

/datum/emote/living/must_breathe/gasp/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_gasp_sound(H)

/datum/emote/living/must_breathe/huff
	key = "huff"
	key_third_person = "huffs"
	message ="lets out a huff"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/must_breathe/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs"
	emote_type = EMOTE_ANIMATED | EMOTE_AUDIBLE | EMOTE_VISIBLE
	emote_length = 3 SECONDS
	overlay_y_offset = -1
	overlay_icon_state = "sigh"

/datum/emote/living/must_breathe/sigh/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_sigh_sound(H)

/datum/emote/living/must_breathe/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/must_breathe/sneeze/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_sneeze_sound(H)

/datum/emote/living/must_breathe/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/must_breathe/sniff/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_sniff_sound(H)
