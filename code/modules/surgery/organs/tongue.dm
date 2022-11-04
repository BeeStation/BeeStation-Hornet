/obj/item/organ/tongue
	name = "tongue"
	desc = "A fleshy muscle mostly used for lying."
	icon_state = "tonguenormal"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_TONGUE
	attack_verb = list("licked", "slobbered", "slapped", "frenched", "tongued")
	var/list/languages_possible
	var/say_mod = "says"   // normal talk
	var/ask_mod = "asks"   // ends with "?"                  -- ideas pool: softly, inquisitively, inquiringly
	var/exclaim_mod = "exclaims" // ends with single "!"     -- ideas pool: sharply, surprisingly, exclamingly, clamingly
	var/yell_mod = "yells"       // ends with multiple "!!" -- ideas pool: loudly, greatly, roaringly
	var/liked_food = JUNKFOOD | FRIED
	var/disliked_food = GROSS | RAW
	var/toxic_food = TOXIC
	var/taste_sensitivity = 15 // lower is more sensitive.
	var/modifies_speech = FALSE
	var/static/list/languages_possible_base = typecacheof(list(
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
		/datum/language/uncommon))

/obj/item/organ/tongue/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base

/obj/item/organ/tongue/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

/obj/item/organ/tongue/Insert(mob/living/carbon/M, special = 0)
	if(modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)
	M.UnregisterSignal(M, COMSIG_MOB_SAY)
	return ..()

/obj/item/organ/tongue/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)
	M.RegisterSignal(M, COMSIG_MOB_SAY, /mob/living/carbon/.proc/handle_tongueless_speech)
	return ..()

/obj/item/organ/tongue/could_speak_language(datum/language/dt)
	return is_type_in_typecache(dt, languages_possible)

// hisses, and roars
/obj/item/organ/tongue/lizard
	name = "forked tongue"
	desc = "A thin and long muscle typically found in reptilian races, apparently moonlights as a nose."
	icon_state = "tonguelizard"
	say_mod = "hisses"
	ask_mod = "hissingly asks"
	exclaim_mod = "surprisingly hisses"
	yell_mod = "hissingly roars"
	taste_sensitivity = 10 // combined nose + tongue, extra sensitive
	modifies_speech = TRUE
	disliked_food = GRAIN | DAIRY
	liked_food = GROSS | MEAT

/obj/item/organ/tongue/lizard/handle_speech(datum/source, list/speech_args)
	var/static/regex/lizard_hiss = new("s+", "g")
	var/static/regex/lizard_hiSS = new("S+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = lizard_hiss.Replace(message, "sss")
		message = lizard_hiSS.Replace(message, "SSS")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/alien
	name = "alien tongue" // this is xeno tongue, not lizard's
	desc = "According to leading xenobiologists the evolutionary benefit of having a second mouth in your mouth is \"that it looks badass\"."
	icon_state = "tonguexeno"
	say_mod = "creepily hisses"
	ask_mod = "softly hisses"
	exclaim_mod = "sharply hisses"
	yell_mod = "loudly hisses"
	taste_sensitivity = 10 // LIZARDS ARE XENOS CONFIRMED
	modifies_speech = TRUE // not really, they just hiss
	var/static/list/languages_possible_alien = typecacheof(list(
		/datum/language/xenocommon,
		/datum/language/common,
		/datum/language/draconic,
		/datum/language/ratvar,
		/datum/language/monkey))

/obj/item/organ/tongue/alien/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_alien

/obj/item/organ/tongue/alien/handle_speech(datum/source, list/speech_args)
	playsound(owner, "hiss", 25, 1, 1)

// meows, and roars
/obj/item/organ/tongue/cat
	name = "cat tongue"
	desc = "A rough tongue, full of small, boney spines all over it's surface."
	say_mod = "meows"
	ask_mod = "imploringly meows"
	exclaim_mod = "sharply meows"
	yell_mod = "meowingly roars"
	disliked_food = VEGETABLES | SUGAR
	liked_food = DAIRY | MEAT

// abductor's
/obj/item/organ/tongue/abductor
	name = "superlingual matrix"
	desc = "A mysterious structure that allows for instant communication between users. Pretty impressive until you need to eat something."
	icon_state = "tongueayylmao"
	say_mod = "gibbers" // I don't think they can talk, but let's put something anyways just in case
	ask_mod = "sofly gibbers"
	exclaim_mod = "surprisingly gibbers"
	yell_mod = "loudly gibbers"
	taste_sensitivity = 101 // ayys cannot taste anything.
	modifies_speech = TRUE
	var/mothership

/obj/item/organ/tongue/abductor/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return

	var/obj/item/organ/tongue/abductor/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	if(!istype(T))
		return

	if(T.mothership == mothership)
		to_chat(H, "<span class='notice'>[src] is already attuned to the same channel as your own.</span>")

	H.visible_message("<span class='notice'>[H] holds [src] in their hands, and concentrates for a moment.</span>", "<span class='notice'>You attempt to modify the attenuation of [src].</span>")
	if(do_after(H, delay=15, target=src))
		to_chat(H, "<span class='notice'>You attune [src] to your own channel.</span>")
		mothership = T.mothership

/obj/item/organ/tongue/abductor/examine(mob/M)
	. = ..()
	if(HAS_TRAIT(M, TRAIT_ABDUCTOR_TRAINING) || HAS_TRAIT(M.mind, TRAIT_ABDUCTOR_TRAINING) || isobserver(M))
		if(!mothership)
			. += "<span class='notice'>It is not attuned to a specific mothership.</span>"
		else
			. += "<span class='notice'>It is attuned to [mothership].</span>"

/obj/item/organ/tongue/abductor/handle_speech(datum/source, list/speech_args)
	//Hacks
	var/message = speech_args[SPEECH_MESSAGE]
	speech_args[SPEECH_MESSAGE] = ""
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	var/rendered = "<span class='abductor'><b>[user.real_name]:</b> [message]</span>"
	user.log_talk(message, LOG_SAY, tag="abductor")
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		var/obj/item/organ/tongue/abductor/T = H.getorganslot(ORGAN_SLOT_TONGUE)
		if(!istype(T))
			continue
		if(mothership == T.mothership)
			to_chat(H, rendered)

	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		to_chat(M, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""

// undead species
/obj/item/organ/tongue/zombie
	name = "rotting tongue"
	desc = "Between the decay and the fact that it's just lying there you doubt a tongue has ever seemed less sexy."
	icon_state = "tonguezombie"
	say_mod = "moans"
	ask_mod = "horribly asks"
	exclaim_mod = "horribly exclaims"
	yell_mod = "horribly yells"
	modifies_speech = TRUE
	taste_sensitivity = 32
	liked_food = GROSS | MEAT | RAW

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

/obj/item/organ/tongue/bone
	name = "bone \"tongue\""
	desc = "Apparently skeletons alter the sounds they produce through oscillation of their teeth, hence their characteristic rattling."
	icon_state = "tonguebone"
	say_mod = "rattles"
	ask_mod = "rattly asks"
	exclaim_mod = "rattly exclaims"
	yell_mod = "rattly yells"
	attack_verb = list("bitten", "chattered", "chomped", "enamelled", "boned")
	taste_sensitivity = 101 // skeletons cannot taste anything
	modifies_speech = TRUE
	liked_food = GROSS | MEAT | RAW
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
	disliked_food = FRUIT
	liked_food = VEGETABLES

// IPC
/obj/item/organ/tongue/robot
	name = "robotic voicebox"
	desc = "A voice synthesizer that can interface with organic lifeforms."
	status = ORGAN_ROBOTIC
	icon_state = "tonguerobot"
	say_mod = "states"
	ask_mod = "queries"
	exclaim_mod = "loudly states"
	yell_mod = "alarmingly states"
	attack_verb = list("beeped", "booped")
	modifies_speech = TRUE
	taste_sensitivity = 25 // not as good as an organic tongue

/obj/item/organ/tongue/robot/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/machine) + typecacheof(/datum/language/voltaic)

/obj/item/organ/tongue/robot/emp_act(severity)
	owner.emote("scream")
	owner.apply_status_effect(STATUS_EFFECT_SPANISH)
	owner.apply_status_effect(STATUS_EFFECT_IPC_EMP)

/obj/item/organ/tongue/robot/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

// ETC
/obj/item/organ/tongue/snail
	name = "snail tongue"
	modifies_speech = TRUE
	say_mod = list("slowly says", "slurs")
	ask_mod = list("slowly asks", "slurringly asks")
	exclaim_mod = list("slowly exclaims", "slurringly exclaims")
	yell_mod = list("slowly yells", "slurringly yells")

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
	say_mod = list("sparks", "crackles")
	ask_mod = list("sparkly asks", "crackly asks")
	exclaim_mod = list("sparkly exclaims", "crackly exclaims")
	yell_mod = list("sparkly yells", "crackly yells")
	attack_verb = list("shocked", "jolted", "zapped")
	taste_sensitivity = 101 // Not a tongue, they can't taste shit
	toxic_food = NONE

/obj/item/organ/tongue/ethereal/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/voltaic)

/obj/item/organ/tongue/golem
	name = "mineral tongue"
	desc = "A strange tongue made out of some kind of mineral. It's smooth, but flexible."
	say_mod = "rumbles"
	ask_mod = "inquisitively rumbles"
	exclaim_mod = "loudly rumbles"
	yell_mod = "verbally quakes"
	taste_sensitivity = 101 //They don't eat.
	icon_state = "adamantine_cords"

/obj/item/organ/tongue/golem/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/terrum)

/obj/item/organ/tongue/golem/bananium
	name = "bananium tongue"
	desc = "It's a tongue made out of pure bananium."
	say_mod = "honks"
	ask_mod = "curiously honks"
	exclaim_mod = "surprisingly honks"
	yell_mod = "honkingly honks"

/obj/item/organ/tongue/golem/clockwork
	name = "clockwork tongue"
	desc = "It's a tongue made out of many tiny cogs. You can hear a very subtle clicking noise emanating from it."
	say_mod = "clicks"
	ask_mod = "tickly asks"
	exclaim_mod = "tickly alarms" // this has similar verb type with IPC's
	yell_mod = "alarmingly clicks"

/obj/item/organ/tongue/slime
	name = "slimey tongue"
	desc = "It's a piece of slime, shaped like a tongue."
	say_mod = list("blorbles", "bubbles")
	ask_mod = list("inquisitively blorbles", "inquisitively blorbles")
	yell_mod = list("shrilly blorbles", "shrilly blorbles")
	exclaim_mod = list("loudly blorbles", "loudly bubbles")
	toxic_food = NONE
	disliked_food = NONE

/obj/item/organ/tongue/slime/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/slime)

/obj/item/organ/tongue/teratoma
	name = "malformed tongue"
	desc = "It's a tongue that looks off... Must be from a creature that shouldn't exist."
	say_mod = "mumbles"
	ask_mod = "softly mumbles"
	exclaim_mod = "sharply mumbles"
	yell_mod = "loudly mumbles"
	icon_state = "tonguefly"
	liked_food = JUNKFOOD | FRIED | GROSS | RAW

/obj/item/organ/tongue/podperson
	name = "plant tongue"
	desc = "It's an odd tongue, seemingly made of plant matter."
	say_mod = "windily says" // like plants are blown by winds
	ask_mod = "windily asks"
	exclaim_mod = "windily exclaims"
	yell_mod = "windily yells"
	disliked_food = MEAT | DAIRY
	liked_food = VEGETABLES | FRUIT | GRAIN //cannibals apparently

// insect people
/obj/item/organ/tongue/fly
	name = "proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids."
	icon_state = "tonguefly"
	say_mod = "buzzes"
	ask_mod = "inquisitively buzzes"
	exclaim_mod = "surprisingly buzzes"
	yell_mod = "loudly buzzes"
	taste_sensitivity = 25 // you eat vomit, this is a mercy
	modifies_speech = TRUE
	liked_food = GROSS | MEAT | RAW | FRUIT

/obj/item/organ/tongue/fly/handle_speech(datum/source, list/speech_args)
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/bee
	name = "proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids, this one smells slighlty like flowers."
	icon_state = "tonguefly"
	say_mod = "buzzes" // nothing different from fly's
	ask_mod = "inquisitively buzzes"
	exclaim_mod = "surprisingly buzzes"
	yell_mod = "loudly buzzes"
	taste_sensitivity = 5
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | DAIRY
	toxic_food = MEAT | RAW

/obj/item/organ/tongue/moth
	name = "mothic tongue"
	desc = "It's long and noodly."
	say_mod = "flutters"
	ask_mod = "vaguely flutters"
	exclaim_mod = "clamingly flutters"
	yell_mod = "explosively flutters"
	icon_state = "tonguemoth"
	liked_food = VEGETABLES | DAIRY | CLOTH
	disliked_food = FRUIT | GROSS
	toxic_food = MEAT | RAW
