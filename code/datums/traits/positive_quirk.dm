//This file contains quirks that provide a gameplay advantage. Players are limited to a maximum of two of these quirks

/datum/quirk/apathetic
	name = "Apathetic"
	desc = "You are used to the awful things that happen here, bad events affect your mood less."
	icon = "meh"
	quirk_value = 1
	mood_quirk = TRUE
	medical_record_text = "Patient was administered the Apathy Evaluation Scale but did not bother to complete it."

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	icon = "wine-bottle"
	quirk_value = 1
	gain_text = span_notice("You feel like a drink would do you good.")
	lose_text = span_danger("You no longer feel like drinking would ease your pain.")
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."

/datum/quirk/drunkhealing/process(delta_time)
	var/need_mob_update = FALSE
	switch(quirk_target.get_drunk_amount())
		if (6 to 40)
			need_mob_update += quirk_target.adjustBruteLoss(-0.1 * delta_time, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_target.adjustFireLoss(-0.05 * delta_time, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
		if (41 to 60)
			need_mob_update += quirk_target.adjustBruteLoss(-0.4 * delta_time, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_target.adjustFireLoss(-0.2 * delta_time, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
		if (61 to INFINITY)
			need_mob_update += quirk_target.adjustBruteLoss(-0.8 * delta_time, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_target.adjustFireLoss(-0.4 * delta_time, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	if(need_mob_update)
		quirk_target.updatehealth()

/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	icon = "smile-beam"
	quirk_value = 1
	mob_trait = TRAIT_EMPATH
	gain_text = span_notice("You feel in tune with those around you.")
	lose_text = span_danger("You feel isolated from others.")
	medical_record_text = "Patient is highly perceptive of and sensitive to social cues, or may possibly have ESP. Further testing needed."

/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly."
	icon = "running"
	quirk_value = 1
	mob_trait = TRAIT_FREERUNNING
	gain_text = span_notice("You feel lithe on your feet!")
	lose_text = span_danger("You feel clumsy again.")
	medical_record_text = "Patient scored highly on cardio tests."

/datum/quirk/friendly
	name = "Friendly"
	desc = "You give the best hugs, especially when you're in the right mood."
	icon = "hands-helping"
	quirk_value = 1
	mob_trait = TRAIT_FRIENDLY
	gain_text = span_notice("You want to hug someone.")
	lose_text = span_danger("You no longer feel compelled to hug others.")
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates low-inhibitions for physical contact and well-developed arms. Requesting another doctor take over this case."

/datum/quirk/jolly
	name = "Jolly"
	desc = "You sometimes just feel happy, for no reason at all."
	icon = "grin"
	quirk_value = 1
	mood_quirk = TRUE
	process = TRUE
	medical_record_text = "Patient demonstrates constant euthymia irregular for environment. It's a bit much, to be honest."

/datum/quirk/jolly/on_process(delta_time)
	if(DT_PROB(0.05, delta_time))
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "jolly", /datum/mood_event/jolly)

/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step; stepping on sharp objects is quieter, less painful and you won't leave footprints behind you. Also, your hands and clothes will not get messed in case of stepping in blood."
	icon = "shoe-prints"
	quirk_value = 1
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = span_notice("You walk with a little more litheness.")
	lose_text = span_danger("You start tromping around like a barbarian.")
	medical_record_text = "Patient's dexterity belies a strong capacity for stealth."

/datum/quirk/linguist
	name = "Linguist"
	desc = "Although you don't know every language, your intense interest in languages allows you to recognise the features of most languages."
	icon = "language"
	quirk_value = 1
	mob_trait = TRAIT_LINGUIST
	gain_text = span_notice("You can recognise the linguistic features of every language.")
	lose_text = span_danger("You can no longer recognise linguistic features for each language.")
	medical_record_text = "Patient possesses extrasensory language feature perception."

/datum/quirk/multilingual
	name = "Multilingual"
	desc = "You spent a portion of your life learning to understand an additional language. You may or may not be able to speak it based on your anatomy."
	icon = "comments"
	quirk_value = 1
	mob_trait = TRAIT_MULTILINGUAL
	gain_text = span_notice("You have learned to understand an additional language.")
	lose_text = span_danger("You have forgotten how to understand a language.")
	medical_record_text = "Patient knows more than one language."
	var/datum/language/known_language

/datum/quirk/multilingual/proc/set_up_language()
	var/datum/language_holder/LH = quirk_target.get_language_holder()
	if(quirk_holder.assigned_role == JOB_NAME_CURATOR)
		return
	var/obj/item/organ/tongue/T = quirk_target.get_organ_slot(ORGAN_SLOT_TONGUE)
	var/list/languages_possible = T.get_possible_languages()
	languages_possible = languages_possible - typecacheof(/datum/language/codespeak) - typecacheof(/datum/language/narsie) - typecacheof(/datum/language/ratvar)
	languages_possible = languages_possible - LH.understood_languages
	languages_possible = languages_possible - LH.spoken_languages
	languages_possible = languages_possible - LH.blocked_languages
	if(length(languages_possible))
		known_language = pick(languages_possible)
//Credit To Yowii/Yoworii/Yorii for a much more streamlined method of language library building

/datum/quirk/multilingual/add()
	known_language = read_choice_preference(/datum/preference/choiced/quirk/multilingual_language)
	if(!known_language) // default to random
		set_up_language()
	var/datum/language_holder/LH = quirk_target.get_language_holder()
	LH.grant_language(known_language, source = LANGUAGE_MULTILINGUAL)

/datum/quirk/multilingual/remove()
	if(!known_language)
		return
	var/datum/language_holder/LH = quirk_target.get_language_holder()
	LH.remove_language(known_language, source = LANGUAGE_MULTILINGUAL)

/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	icon = "eye"
	quirk_value = 1
	mob_trait = TRAIT_NIGHT_VISION_WEAK
	gain_text = span_notice("The shadows seem a little less dark.")
	lose_text = span_danger("Everything seems a little darker.")
	medical_record_text = "Patient possesses a better than average retina."

/datum/quirk/night_vision/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/eyes/eyes = H.get_organ_by_type(/obj/item/organ/eyes)
	if(!eyes || eyes.lighting_alpha)
		return
	eyes.Insert(H) //refresh their eyesight and vision

/datum/quirk/photographer
	name = "Psychic Photographer"
	desc = "You have a special camera that can capture a photo of ghosts. Your experience in photography shortens the delay between each shot."
	icon = "camera"
	quirk_value = 1
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = span_notice("You know everything about photography.")
	lose_text = span_danger("You forget how photo cameras work.")
	medical_record_text = "Patient mentions photography as a stress-relieving hobby."

/datum/quirk/photographer/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/camera/spooky/camera = new(get_turf(H))
	var/list/camera_slots = list (
		"neck" = ITEM_SLOT_NECK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET,
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS
	)
	H.equip_in_one_of_slots(camera, camera_slots , qdel_on_fail = TRUE)
	H.regenerate_icons()

/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "You know your body well, and can accurately assess the extent of your wounds."
	icon = "bone"
	quirk_value = 1
	mob_trait = TRAIT_SELF_AWARE
	medical_record_text = "Patient demonstrates an uncanny knack for self-diagnosis."

/datum/quirk/skittish
	name = "Skittish"
	desc = "You can conceal yourself in danger. Ctrl-shift-click a closed locker to jump into it, as long as you have access."
	icon = "trash"
	quirk_value = 1
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient demonstrates a high aversion to danger and has described hiding in containers out of fear."

/datum/quirk/tagger
	name = "Tagger"
	desc = "You're an experienced artist. While drawing graffiti, you can get twice as many uses out of drawing supplies."
	icon = "spray-can"
	quirk_value = 1
	mob_trait = TRAIT_TAGGER
	gain_text = span_notice("You know how to tag walls efficiently.")
	lose_text = span_danger("You forget how to tag walls properly.")
	medical_record_text = "Patient recently seen for paint poisoning."

/datum/quirk/tagger/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/toy/crayon/spraycan/spraycan = new(get_turf(H))
	H.put_in_hands(spraycan)
	H.equip_to_slot(spraycan, ITEM_SLOT_BACKPACK)
	H.regenerate_icons()

/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine."
	icon = "drumstick-bite"
	quirk_value = 1
	mob_trait = TRAIT_VORACIOUS
	gain_text = span_notice("You feel HONGRY.")
	lose_text = span_danger("You no longer feel HONGRY.")
	medical_record_text = "Patient has an above average appreciation for food and drink."

/datum/quirk/neet
	name = "NEET"
	desc = "For some reason you qualified for social welfare."
	icon = "money-check-alt"
	quirk_value = 1
	gain_text = span_notice("You feel useless to society.")
	lose_text = span_danger("You no longer feel useless to society.")
	mood_quirk = TRUE
	process = TRUE
	medical_record_text = "Patient qualifies for social welfare."

/datum/quirk/neet/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/datum/bank_account/D = H.get_bank_account()
	if(!D) //if their current mob doesn't have a bank account, likely due to them being a special role (ie nuke op)
		return
	D.payment_per_department[ACCOUNT_NEET_ID] += PAYCHECK_WELFARE

/datum/quirk/proskater
	name = "Skater Bro"
	desc = "You're a little too into old-earth skater culture! You're much more used to riding and falling off skateboards, needing less stamina to do kickflips and taking less damage upon bumping into something."
	icon = "hand-middle-finger"
	quirk_value = 1
	mob_trait = TRAIT_PROSKATER
	gain_text = span_notice("You feel like hitting a sick grind!")
	lose_text = span_danger("You no longer feel like you're in touch with the youth.")
	medical_record_text = "Patient demonstrated a high affinity for skateboards."

/datum/quirk/proskater/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	H.equip_to_slot_or_del(new /obj/item/melee/skateboard/pro(H), ITEM_SLOT_BACKPACK)

/datum/quirk/computer_whiz
	name = "Computer Whiz"
	desc = "You have always had a knack for technologies. You are able to manipulate and alter modular computer parts faster and safely."
	icon = "microchip"
	quirk_value = 1
	mob_trait = TRAIT_COMPUTER_WHIZ
	gain_text = span_notice("You feel much more confortable around technology.")
	lose_text = span_danger("You feel your love for technology dissipate.")
	medical_record_text = "Patient's vocational assessment test shows an affinity for technology."
