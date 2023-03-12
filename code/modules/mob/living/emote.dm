
/* EMOTE DATUMS */
/datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(/mob/living/simple_animal/slime, /mob/living/brain)

/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes"

/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "bows"
	message_param = "bows to %t"
	restraint_check = TRUE

/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/cross
	key = "cross"
	key_third_person = "crosses"
	message = "crosses their arms"
	restraint_check = TRUE

/datum/emote/living/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/collapse/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.Unconscious(40)

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances around happily"
	restraint_check = TRUE

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
	stat_allowed = UNCONSCIOUS

/datum/emote/living/deathgasp/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/simple_animal/S = user
	if(istype(S) && S.deathmessage)
		message_simple = S.deathmessage
	. = ..()
	message_simple = initial(message_simple)
	if(. && user.deathsound)
		if(isliving(user))
			var/mob/living/L = user
			if(!L.can_speak_vocal() || L.oxyloss >= 50)
				return //stop the sound if oxyloss too high/cant speak
		playsound(user, user.deathsound, 200, TRUE, TRUE)

/datum/emote/living/drool
	key = "drool"
	key_third_person = "drools"
	message = "drools"

/datum/emote/living/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints"

/datum/emote/living/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.SetSleeping(200)

/datum/emote/living/flap
	key = "flap"
	key_third_person = "flaps"
	message = "flaps their wings"
	restraint_check = TRUE
	var/wing_time = 10

/datum/emote/living/flap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.Togglewings())
			addtimer(CALLBACK(H,TYPE_PROC_REF(/mob/living/carbon/human, Togglewings)), wing_time)

/datum/emote/living/flap/aflap
	key = "aflap"
	key_third_person = "aflaps"
	message = "flaps their wings aggressively"
	restraint_check = TRUE
	wing_time = 5

/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns"

/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "gags"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles"
	message_mime = "giggles silently"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares"
	message_param = "glares at %t"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins"

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans"
	message_mime = "appears to groan"

/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "grimaces"

/datum/emote/living/jump
	key = "jump"
	key_third_person = "jumps"
	message = "jumps"
	restraint_check = TRUE

/datum/emote/living/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "blows a kiss"
	message_param = "blows a kiss to %t"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs"
	message_mime = "laughs silently"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/laugh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(!.)
		return FALSE
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

/datum/emote/living/nod
	key = "nod"
	key_third_person = "nods"
	message = "nods"
	message_param = "nods at %t"

/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "points"
	message_param = "points at %t"
	restraint_check = TRUE

/datum/emote/living/point/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.get_num_arms() == 0)
			if(H.get_num_legs() != 0)
				message_param = "tries to point at %t with a leg, <span class='userdanger'>falling down</span> in the process!"
				H.Paralyze(20)
			else
				message_param = "<span class='userdanger'>bumps [user.p_their()] head on the ground</span> trying to motion towards %t."
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
	..()

/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "pouts"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams"
	message_mime = "acts out a scream"
	emote_type = EMOTE_AUDIBLE
	mob_type_blacklist_typecache = list(/mob/living/carbon/human) //Humans get specialized scream.

/datum/emote/living/scream/select_message_type(mob/user, intentional)
	. = ..()
	if(!intentional && isanimal(user))
		return "makes a loud and pained whimper."

/datum/emote/living/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "scowls"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	message = "shakes their head"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/sit
	key = "sit"
	key_third_person = "sits"
	message = "sits down"

/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles"

/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "grins smugly"

/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores"
	message_mime = "sleeps soundly"
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS

/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "stares"
	message_param = "stares at %t"

/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "stretches their arms"

/datum/emote/living/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "sulks down sadly"

/datum/emote/living/surrender
	key = "surrender"
	key_third_person = "surrenders"
	message = "puts their hands on their head and falls to the ground, surrendering"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/surrender/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.Paralyze(200)

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "sways around dizzily"

/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "trembles in fear"

/datum/emote/living/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "twitches violently"

/datum/emote/living/twitch_s
	key = "twitch_s"
	message = "twitches"

/datum/emote/living/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves"

/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers"
	message_mime = "appears hurt"

/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	message = "smiles weakly"

/datum/emote/living/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
	message = null
	mob_type_blacklist_typecache = /mob/living/brain

/datum/emote/living/custom/proc/check_invalid(mob/user, input)
	var/static/regex/stop_bad_mime = regex(@"says|exclaims|yells|asks")
	if(stop_bad_mime.Find(input, 1, 1))
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
		return TRUE
	return FALSE

/datum/emote/living/custom/can_run_emote(mob/user, status_check, intentional)
	. = ..() && intentional

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	if(is_banned_from(user.ckey, "Emote"))
		to_chat(user, "You cannot send custom emotes (banned).")
		return FALSE
	else if(QDELETED(user))
		return FALSE
	else if(user.client && user.client.prefs.muted & MUTE_IC)
		to_chat(user, "You cannot send IC messages (muted).")
		return FALSE
	else if(!params)
		var/custom_emote = stripped_input(usr, "Choose an emote to display.")
		if(custom_emote && !check_invalid(user, custom_emote))
			var/type = input("Is this a visible or hearable emote?") as null|anything in list("Visible", "Hearable")
			if(type == "Hearable")
				emote_type |= EMOTE_AUDIBLE
			message = user.say_emphasis(custom_emote)
	else
		message = params
		if(type_override)
			emote_type = type_override
	. = ..()
	message = null
	emote_type = 0

/datum/emote/living/custom/replace_pronoun(mob/user, message)
	return message

/datum/emote/living/help
	key = "help"

/datum/emote/living/help/run_emote(mob/user, params, type_override, intentional)
	var/list/keys = list()
	var/list/message = list("Available emotes, you can use them with say \"*emote\": ")

	for(var/key in GLOB.emote_list)
		for(var/datum/emote/P in GLOB.emote_list[key])
			if(P.key in keys)
				continue
			if(P.can_run_emote(user, status_check = FALSE , intentional = TRUE))
				keys += P.key

	keys = sortList(keys)

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
	mob_type_allowed_typecache = list(/mob/living/brain, /mob/living/silicon, /mob/living/simple_animal/hostile/mining_drone)

/datum/emote/living/circle
	key = "circle"
	key_third_person = "circles"
	restraint_check = TRUE

/datum/emote/living/circle/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/circlegame/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>You make a circle with your hand.</span>")
	else
		qdel(N)
		to_chat(user, "<span class='warning'>You don't have any free hands to make a circle with.</span>")

/datum/emote/living/slap
	key = "slap"
	key_third_person = "slaps"
	restraint_check = TRUE

/datum/emote/living/slap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/obj/item/slapper/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>You ready your slapping hand.</span>")
	else
		to_chat(user, "<span class='warning'>You're incapable of slapping in your current state.</span>")

/datum/emote/living/raisehand
	key = "highfive"
	key_third_person = "highfives"
	message = "raises their hand"
	restraint_check = TRUE

/datum/emote/living/raisehand/run_emote(mob/user, params)
	. = ..()
	var/obj/item/highfive/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>You raise your hand for a high-five.</span>")
	else
		qdel(N)
		to_chat(user, "<span class='warning'>You don't have any free hands to high-five with.</span>")

/datum/emote/living/fingergun
	key = "fingergun"
	key_third_person = "fingerguns"
	message = "forms their fingers into the shape of a crude gun"
	restraint_check = TRUE

/datum/emote/living/fingergun/run_emote(mob/user, params)
	. = ..()
	var/obj/item/gun/ballistic/revolver/mime/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>You form your fingers into a gun.</span>")
	else
		qdel(N)
		to_chat(user, "<span class='warning'>You don't have any free hands to make fingerguns with.</span>")

/datum/emote/living/click
	key = "click"
	key_third_person = "clicks their tongue"
	message = "clicks their tongue"
	message_ipc = "makes a click sound"
	message_insect = "clicks their mandibles"

/datum/emote/living/click/get_sound(mob/living/user)
	if(ismoth(user) || isapid(user) || isflyperson(user) || istype(user, /mob/living/simple_animal/mothroach))
		return 'sound/creatures/rattle.ogg'
	else if(isipc(user))
		return 'sound/machines/click.ogg'
	else
		return FALSE

/datum/emote/living/zap
	key = "zap"
	key_third_person = "zaps"
	message = "zaps"

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

/datum/emote/living/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses"

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
	restraint_check = TRUE

/datum/emote/living/thumbs_down
	key = "thumbsdown"
	key_third_person = "thumbsdown"
	message = "flashes a thumbs down"
	message_robot = "makes a crude thumbs down with their 'hands'"
	message_AI = "flashes a quick hologram of a thumbs down"
	message_ipc = "flashes a thumbs down icon"
	message_simple = "attempts a thumbs down"
	message_param = "flashes a thumbs down at %t"
	restraint_check = TRUE

/datum/emote/living/whistle
	key="whistle"
	key_third_person="whistle"
	message = "whistles a few notes"
	message_robot = "whistles a few synthesized notes"
	message_AI = "whistles a synthesized song"
	message_ipc = "whistles a few synthesized notes"

/datum/emote/living/whistle/get_sound(mob/living/user)
	return 'sound/items/megaphone.ogg'

/// Breathing required + audible emotes

/datum/emote/living/must_breathe
	emote_type = EMOTE_AUDIBLE
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

/datum/emote/living/must_breathe/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs!"

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
	message = "gasps!"

/datum/emote/living/must_breathe/gasp/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_gasp_sound(H)

/datum/emote/living/must_breathe/huff
	key = "huff"
	key_third_person = "huffs"
	message ="lets out a huff!"

/datum/emote/living/must_breathe/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs!"
	emote_type = EMOTE_AUDIBLE|EMOTE_ANIMATED
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
	message = "sneezes!"

/datum/emote/living/must_breathe/sneeze/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_sneeze_sound(H)

/datum/emote/living/must_breathe/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs."

/datum/emote/living/must_breathe/sniff/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	return H?.dna?.species?.get_sniff_sound(H)
