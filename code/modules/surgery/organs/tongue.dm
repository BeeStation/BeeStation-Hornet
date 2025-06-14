/obj/item/organ/tongue
	name = "tongue"
	desc = "A fleshy muscle mostly used for lying."
	icon_state = "tonguenormal"
	visual = FALSE
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_TONGUE
	attack_verb_continuous = list("licks", "slobbers", "slaps", "frenches", "tongues")
	attack_verb_simple = list("lick", "slobber", "slap", "french", "tongue")
	/**
	 * A cached list of paths of all the languages this tongue is capable of speaking
	 *
	 * Relates to a mob's ability to speak a language - a mob must be able to speak the language
	 * and have a tongue able to speak the language (or omnitongue) in order to actually speak said language
	 *
	 * To modify this list for subtypes, see [/obj/item/organ/tongue/proc/get_possible_languages]. Do not modify directly.
	 */
	VAR_PRIVATE/list/languages_possible
	var/say_mod = "says"
	var/ask_mod = "asks"
	var/yell_mod = "yells"
	var/exclaim_mod = "exclaims"
	var/liked_food = JUNKFOOD | FRIED
	var/disliked_food = GROSS | RAW | CLOTH | GORE
	var/toxic_food = TOXIC
	// Determines how "sensitive" this tongue is to tasting things, lower is more sensitive.
	/// See [/mob/living/proc/get_taste_sensitivity].
	var/taste_sensitivity = 15
	/// Whether this tongue modifies speech via signal
	var/modifies_speech = FALSE

/obj/item/organ/tongue/Initialize(mapload)
	. = ..()
	// Setup the possible languages list
	// - get_possible_languages gives us a list of language paths
	// - then we cache it via string list
	// this results in tongues with identical possible languages sharing a cached list instance
	languages_possible = string_list(get_possible_languages())

/**
 * Used in setting up the "languages possible" list.
 *
 * Override to have your tongue be only capable of speaking certain languages
 * Extend to hvae a tongue capable of speaking additional languages to the base tongue
 *
 * While a user may be theoretically capable of speaking a language, they cannot physically speak it
 * UNLESS they have a tongue with that language possible, UNLESS UNLESS they have omnitongue enabled.
 */
/obj/item/organ/tongue/proc/get_possible_languages()
	RETURN_TYPE(/list)
	// This is the default list of languages most humans should be capable of speaking
	return list(
		/datum/language/aphasia,
		/datum/language/apidite,
		/datum/language/beachbum,
		/datum/language/buzzwords,
		/datum/language/calcic,
		/datum/language/codespeak,
		/datum/language/common,
		/datum/language/draconic,
		/datum/language/moffic,
		/datum/language/monkey,
		/datum/language/narsie,
		/datum/language/piratespeak,
		/datum/language/ratvar,
		/datum/language/shadowtongue,
		/datum/language/slime,
		/datum/language/sylvan,
		/datum/language/terrum,
		/datum/language/uncommon,
		/datum/language/sonus,
	)

/obj/item/organ/tongue/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

/obj/item/organ/tongue/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(!.)
		return
	if(modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	M.UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/organ/tongue/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	UnregisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	M.RegisterSignal(M, COMSIG_MOB_SAY, TYPE_PROC_REF(/mob/living/carbon, handle_tongueless_speech))
	return ..()

/obj/item/organ/tongue/could_speak_language(datum/language/language_path)
	return (language_path in languages_possible)

/obj/item/organ/tongue/lizard
	name = "forked tongue"
	desc = "A thin and long muscle typically found in reptilian races, apparently moonlights as a nose."
	icon_state = "tonguelizard"
	say_mod = "hisses"
	taste_sensitivity = 10 // combined nose + tongue, extra sensitive
	modifies_speech = TRUE
	disliked_food = GRAIN | DAIRY | CLOTH | GROSS
	liked_food = GORE | MEAT

/obj/item/organ/tongue/lizard/handle_speech(datum/source, list/speech_args)
	var/static/regex/lizard_hiss = new("s+", "g")
	var/static/regex/lizard_hiSS = new("S+", "g")
	var/static/regex/lizard_kss = new(@"(\w)x", "g")
	var/static/regex/lizard_kSS = new(@"(\w)X", "g")
	var/static/regex/lizard_ecks = new(@"\bx([-rR]|\b)", "g")
	var/static/regex/lizard_eckS = new(@"\bX([-rR]|\b)", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = lizard_hiss.Replace(message, "sss")
		message = lizard_hiSS.Replace(message, "SSS")
		message = lizard_kss.Replace(message, "$1kss")
		message = lizard_kSS.Replace(message, "$1KSS")
		message = lizard_ecks.Replace(message, "ecks$1")
		message = lizard_eckS.Replace(message, "ECKS$1")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/fly
	name = "proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids."
	icon_state = "tonguefly"
	say_mod = "buzzes"
	taste_sensitivity = 25 // you eat vomit, this is a mercy
	modifies_speech = TRUE
	liked_food = GROSS | RAW | GORE // Limit how much food they actually like. They already have carte blanche on like 90% of food
	disliked_food = NONE
	toxic_food = NONE

/obj/item/organ/tongue/fly/handle_speech(datum/source, list/speech_args)
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/abductor
	name = "superlingual matrix"
	desc = "A mysterious structure that allows for instant communication between users. Pretty impressive until you need to eat something."
	icon_state = "tongueayylmao"
	say_mod = "gibbers"
	taste_sensitivity = 101 // ayys cannot taste anything.
	modifies_speech = TRUE
	var/mothership

/obj/item/organ/tongue/abductor/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return

	var/obj/item/organ/tongue/abductor/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!istype(T))
		return

	if(T.mothership == mothership)
		to_chat(H, span_notice("[src] is already attuned to the same channel as your own."))

	H.visible_message(span_notice("[H] holds [src] in their hands, and concentrates for a moment."), span_notice("You attempt to modify the attenuation of [src]."))
	if(do_after(H, delay=15, target=src))
		to_chat(H, span_notice("You attune [src] to your own channel."))
		mothership = T.mothership

/obj/item/organ/tongue/abductor/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user.mind, TRAIT_ABDUCTOR_TRAINING) || isobserver(user))
		if(!mothership)
			. += span_notice("It is not attuned to a specific mothership.")
		else
			. += span_notice("It is attuned to [mothership].")

/obj/item/organ/tongue/abductor/handle_speech(datum/source, list/speech_args)
	//Hacks
	var/message = speech_args[SPEECH_MESSAGE]
	speech_args[SPEECH_MESSAGE] = ""
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	var/rendered = span_abductor("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag="abductor")
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		var/obj/item/organ/tongue/abductor/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
		if(!istype(T))
			continue
		if(mothership == T.mothership)
			to_chat(H, rendered)

	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		to_chat(M, "[link] [rendered]")

/obj/item/organ/tongue/zombie
	name = "rotting tongue"
	desc = "Between the decay and the fact that it's just lying there you doubt a tongue has ever seemed less sexy."
	icon_state = "tonguezombie"
	say_mod = "moans"
	modifies_speech = TRUE
	taste_sensitivity = 32
	liked_food = GROSS | MEAT | RAW | GORE

/obj/item/organ/tongue/zombie/handle_speech(datum/source, list/speech_args)
	var/list/message_list = splittext(speech_args[SPEECH_MESSAGE], " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, -3) == "..."))//3 == length("...")
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	speech_args[SPEECH_MESSAGE] = jointext(message_list, " ")

/obj/item/organ/tongue/alien
	name = "alien tongue"
	desc = "According to leading xenobiologists the evolutionary benefit of having a second mouth in your mouth is \"that it looks badass\"."
	icon_state = "tonguexeno"
	say_mod = "hisses"
	taste_sensitivity = 10 // LIZARDS ARE ALIENS CONFIRMED
	modifies_speech = TRUE // not really, they just hiss

// Aliens can only speak alien and a few other languages.
/obj/item/organ/tongue/alien/get_possible_languages()
	return list(
		/datum/language/xenocommon,
		/datum/language/common,
		/datum/language/uncommon,
		/datum/language/draconic,
		/datum/language/ratvar,
		/datum/language/monkey,
	)

/obj/item/organ/tongue/alien/handle_speech(datum/source, list/speech_args)
	playsound(owner, "hiss", 25, 1, 1)

/obj/item/organ/tongue/bee
	name = "proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids, this one smells slighlty like flowers."
	icon_state = "tonguefly"
	say_mod = "buzzes"
	taste_sensitivity = 5
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | DAIRY
	toxic_food = MEAT | RAW

/obj/item/organ/tongue/bone
	name = "bone \"tongue\""
	desc = "Apparently skeletons alter the sounds they produce through oscillation of their teeth, hence their characteristic rattling."
	icon_state = "tonguebone"
	say_mod = "rattles"
	attack_verb_continuous = list("bites", "chatters", "chomps", "enamelles", "bones")
	attack_verb_simple = list("bite", "chatter", "chomp", "enamel", "bone")
	taste_sensitivity = 101 // skeletons cannot taste anything
	modifies_speech = TRUE
	liked_food = GROSS | MEAT | RAW | GORE
	disliked_food = NONE // why would they care
	toxic_food = NONE
	var/chattering = FALSE
	var/phomeme_type = "sans"
	var/list/phomeme_types = list("sans", "papyrus")

/obj/item/organ/tongue/bone/Initialize(mapload)
	. = ..()
	phomeme_type = pick(phomeme_types)

/obj/item/organ/tongue/bone/handle_speech(datum/source, list/speech_args)
	if(chattering)
		chatter(speech_args[SPEECH_MESSAGE], phomeme_type, source)
	switch(phomeme_type)
		if("sans")
			speech_args[SPEECH_SPANS] |= SPAN_SANS
		if("papyrus")
			speech_args[SPEECH_SPANS] |= SPAN_PAPYRUS

/obj/item/organ/tongue/bone/plasmaman
	name = "plasma bone \"tongue\""
	desc = "Like animated skeletons, Plasmamen vibrate their teeth in order to produce speech."
	icon_state = "tongueplasma"
	modifies_speech = FALSE
	disliked_food = FRUIT | CLOTH
	liked_food = VEGETABLES

/obj/item/organ/tongue/robot
	name = "robotic voicebox"
	desc = "A voice synthesizer that can interface with organic lifeforms."
	status = ORGAN_ROBOTIC
	organ_flags = NONE
	icon_state = "tonguerobot"
	say_mod = "states"
	attack_verb_continuous = list("beeps", "boops")
	attack_verb_simple = list("beep", "boop")
	modifies_speech = TRUE
	taste_sensitivity = 25 // not as good as an organic tongue

/obj/item/organ/tongue/robot/get_possible_languages()
	return ..() + /datum/language/machine + /datum/language/voltaic

/obj/item/organ/tongue/robot/emp_act(severity)
	if(prob(30/severity))
		owner.emote("scream")
		owner.apply_status_effect(/datum/status_effect/spanish)


/obj/item/organ/tongue/robot/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/obj/item/organ/tongue/snail
	name = "snail tongue"
	modifies_speech = TRUE
	say_mod = "slurs"

/obj/item/organ/tongue/snail/handle_speech(datum/source, list/speech_args)
	var/new_message
	var/message = speech_args[SPEECH_MESSAGE]
	for(var/i in 1 to length(message))
		if(findtext("ABCDEFGHIJKLMNOPWRSTUVWXYZabcdefghijklmnopqrstuvwxyz", message[i])) //Im open to suggestions
			new_message += message[i] + message[i] + message[i] //aaalllsssooo ooopppeeennn tttooo sssuuuggggggeeessstttiiiooonsss
		else
			new_message += message[i]
	speech_args[SPEECH_MESSAGE] = new_message

/obj/item/organ/tongue/ethereal
	name = "electric discharger"
	desc = "A sophisticated ethereal organ, capable of synthesising speech via electrical discharge."
	icon_state = "electrotongue"
	say_mod = "crackles"
	attack_verb_continuous = list("shocks", "jolts", "zaps")
	attack_verb_simple = list("shock", "jolt", "zap")
	taste_sensitivity = 101 // Not a tongue, they can't taste shit
	toxic_food = NONE

/obj/item/organ/tongue/ethereal/get_possible_languages()
	return ..() + /datum/language/voltaic

/obj/item/organ/tongue/golem
	name = "mineral tongue"
	desc = "A strange tongue made out of some kind of mineral. It's smooth, but flexible."
	say_mod = "rumbles"
	taste_sensitivity = 101 //They don't eat.
	icon_state = "adamantine_cords"

/obj/item/organ/tongue/golem/get_possible_languages()
	return ..() + /datum/language/terrum

/obj/item/organ/tongue/golem/bananium
	name = "bananium tongue"
	desc = "It's a tongue made out of pure bananium."
	say_mod = "honks"

/obj/item/organ/tongue/golem/clockwork
	name = "clockwork tongue"
	desc = "It's a tongue made out of many tiny cogs. You can hear a very subtle clicking noise emanating from it."
	say_mod = "clicks"

/obj/item/organ/tongue/cat
	name = "cat tongue"
	desc = "A rough tongue, full of small, boney spines all over it's surface."
	say_mod = "meows"
	disliked_food = GROSS | VEGETABLES | SUGAR | CLOTH
	liked_food = DAIRY | MEAT | GORE

/obj/item/organ/tongue/slime
	name = "slimey tongue"
	desc = "It's a piece of slime, shaped like a tongue."
	say_mod = "blorbles"
	ask_mod = "inquisitively blorbles"
	yell_mod = "shrilly blorbles"
	exclaim_mod = "loudly blorbles"
	liked_food = MEAT | BUGS //cause slimes are mostly carnivores, however the ability to consume RAW or GORE was lost when spliced with humans
	toxic_food = NONE
	disliked_food = NONE

/obj/item/organ/tongue/slime/get_possible_languages()
	return ..() + /datum/language/slime

/obj/item/organ/tongue/moth
	name = "mothic tongue"
	desc = "It's long and noodly."
	say_mod = "flutters"
	icon_state = "tonguemoth"
	liked_food = FRUIT | VEGETABLES | DAIRY | CLOTH
	disliked_food = GROSS | GORE
	toxic_food = MEAT | RAW

/obj/item/organ/tongue/teratoma
	name = "malformed tongue"
	desc = "It's a tongue that looks off... Must be from a creature that shouldn't exist."
	say_mod = "mumbles"
	icon_state = "tonguefly"
	disliked_food = CLOTH
	liked_food = JUNKFOOD | FRIED | GROSS | RAW | GORE

/obj/item/organ/tongue/diona
	name = "diona tongue"
	desc = "It's an odd tongue, seemingly made of plant matter."
	icon_state = "diona_tongue"
	say_mod = "rustles"
	ask_mod = "quivers"
	yell_mod = "shrieks"
	exclaim_mod = "ripples"
	disliked_food = DAIRY | FRUIT | GRAIN | CLOTH | VEGETABLES
	liked_food = MEAT | RAW

/obj/item/organ/tongue/diona/pumpkin
	modifies_speech = TRUE
	///Is this tongue carved?
	var/carved = FALSE

/obj/item/organ/tongue/diona/pumpkin/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if((message[1] != "*" || message[1] != "#") && !carved)
		message = "..."
		to_chat(owner, span_warning("Something is covering your mouth!"))
		to_chat(owner, span_notice("Try carving your head."))
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/psyphoza
	name = "fungal tongue"
	desc = "Black and moldy."
	icon_state = "tonguepsyphoza"
	say_mod = "clicks"
	//Black tongue
	color = "#1b1b1b"
	liked_food = RAW | GROSS
	disliked_food = DAIRY
