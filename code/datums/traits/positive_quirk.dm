//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You feel like you could drink a whole keg!</span>"
	lose_text = "<span class='danger'>You don't feel as resistant to alcohol anymore. Somehow.</span>"

/datum/quirk/apathetic
	name = "Apathetic"
	desc = "You just don't care as much as other people. That's nice to have in a place like this, I guess."
	value = 1
	mood_quirk = TRUE

/datum/quirk/apathetic/add()
	var/datum/component/mood/mood = quirk_target.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier -= 0.2

/datum/quirk/apathetic/remove()
	var/datum/component/mood/mood = quirk_target.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier += 0.2

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	value = 2
	mob_trait = TRAIT_DRUNK_HEALING
	gain_text = "<span class='notice'>You feel like a drink would do you good.</span>"
	lose_text = "<span class='danger'>You no longer feel like drinking would ease your pain.</span>"
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."

/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	value = 2
	mob_trait = TRAIT_EMPATH
	gain_text = "<span class='notice'>You feel in tune with those around you.</span>"
	lose_text = "<span class='danger'>You feel isolated from others.</span>"

/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly."
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>You feel lithe on your feet!</span>"
	lose_text = "<span class='danger'>You feel clumsy again.</span>"

/datum/quirk/friendly
	name = "Friendly"
	desc = "You give the best hugs, especially when you're in the right mood."
	value = 1
	mob_trait = TRAIT_FRIENDLY
	gain_text = "<span class='notice'>You want to hug someone.</span>"
	lose_text = "<span class='danger'>You no longer feel compelled to hug others.</span>"
	mood_quirk = TRUE

/datum/quirk/jolly
	name = "Jolly"
	desc = "You sometimes just feel happy, for no reason at all."
	value = 1
	mob_trait = TRAIT_JOLLY
	mood_quirk = TRUE
	process = TRUE

/datum/quirk/jolly/on_process(delta_time)
	if(DT_PROB(0.05, delta_time))
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "jolly", /datum/mood_event/jolly)

/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step; stepping on sharp objects is quieter, less painful and you won't leave footprints behind you."
	value = 1
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = "<span class='notice'>You walk with a little more litheness.</span>"
	lose_text = "<span class='danger'>You start tromping around like a barbarian.</span>"

/datum/quirk/musician
	name = "Musician"
	desc = "You can tune handheld musical instruments to play melodies that clear certain negative effects and soothe the soul."
	value = 1
	mob_trait = TRAIT_MUSICIAN
	gain_text = "<span class='notice'>You know everything about musical instruments.</span>"
	lose_text = "<span class='danger'>You forget how musical instruments work.</span>"

/datum/quirk/musician/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/choice_beacon/music/B = new(get_turf(H))
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS,
	)
	H.equip_in_one_of_slots(B, slots , qdel_on_fail = TRUE)

/datum/quirk/linguist
	name = "Linguist"
	desc = "Although you don't know every language, your intense interest in languages allows you to recognise the features of most languages."
	value = 1
	mob_trait = TRAIT_LINGUIST
	gain_text = "<span class='notice'>You can recognise the linguistic features of every language.</span>"
	lose_text = "<span class='danger'>You can no longer recognise linguistic features for each language.</span>"

/datum/quirk/multilingual
	name = "Multilingual"
	desc = "You spent a portion of your life learning to understand an additional language. You may or may not be able to speak it based on your anatomy."
	value = 1
	mob_trait = TRAIT_MULTILINGUAL
	gain_text = "<span class='notice'>You have learned to understand an additional language.</span>"
	lose_text = "<span class='danger'>You have forgotten how to understand a language.</span>"
	var/datum/language/known_language

/datum/quirk/multilingual/proc/set_up_language()
	var/datum/language_holder/LH = quirk_holder.get_language_holder()
	if(quirk_holder.assigned_role == JOB_NAME_CURATOR)
		return
	var/obj/item/organ/tongue/T = quirk_target.getorganslot(ORGAN_SLOT_TONGUE)
	var/list/languages_possible = T.languages_possible
	languages_possible = languages_possible - typecacheof(/datum/language/codespeak) - typecacheof(/datum/language/narsie) - typecacheof(/datum/language/ratvar)
	languages_possible = languages_possible - LH.understood_languages
	languages_possible = languages_possible - LH.spoken_languages
	languages_possible = languages_possible - LH.blocked_languages
	if(length(languages_possible))
		known_language = pick(languages_possible)
//Credit To Yowii/Yoworii/Yorii for a much more streamlined method of language library building

/datum/quirk/multilingual/add()
	if(!known_language)
		set_up_language()
	var/datum/language_holder/LH = quirk_holder.get_language_holder()
	LH.grant_language(known_language, TRUE, TRUE, LANGUAGE_MULTILINGUAL)

/datum/quirk/multilingual/remove()
	if(!known_language)
		return
	var/datum/language_holder/LH = quirk_holder.get_language_holder()
	LH.remove_language(known_language, TRUE, TRUE, LANGUAGE_MULTILINGUAL)

/datum/quirk/night_vision
	name = "Night Vision"
	desc = "You can see slightly more clearly in full darkness than most people."
	value = 1
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = "<span class='notice'>The shadows seem a little less dark.</span>"
	lose_text = "<span class='danger'>Everything seems a little darker.</span>"

/datum/quirk/night_vision/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/eyes/eyes = H.getorgan(/obj/item/organ/eyes)
	if(!eyes || eyes.lighting_alpha)
		return
	eyes.Insert(H) //refresh their eyesight and vision

/datum/quirk/photographer
	name = "Psychic Photographer"
	desc = "You have a special camera that can capture a photo of ghosts. Your experience in photography shortens the delay between each shot."
	value = 1
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = "<span class='notice'>You know everything about photography.</span>"
	lose_text = "<span class='danger'>You forget how photo cameras work.</span>"

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
	value = 2
	mob_trait = TRAIT_SELF_AWARE

/datum/quirk/skittish
	name = "Skittish"
	desc = "You can conceal yourself in danger. Ctrl-shift-click a closed locker to jump into it, as long as you have access."
	value = 2
	mob_trait = TRAIT_SKITTISH

/datum/quirk/spiritual
	name = "Spiritual"
	desc = "You hold a spiritual belief, whether in God, nature or the arcane rules of the universe. You gain comfort from the presence of holy people, and believe that your prayers are more special than others."
	value = 1
	mob_trait = TRAIT_SPIRITUAL
	gain_text = "<span class='notice'>You have faith in a higher power.</span>"
	lose_text = "<span class='danger'>You lose faith!</span>"
	process = TRUE

/datum/quirk/spiritual/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	H.equip_to_slot_or_del(new /obj/item/storage/fancy/candle_box(H), ITEM_SLOT_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/matches(H), ITEM_SLOT_BACKPACK)

/datum/quirk/spiritual/on_process()
	var/comforted = FALSE
	for(var/mob/living/carbon/human/H in oview(5, quirk_target))
		if(H.mind?.holy_role && H.stat == CONSCIOUS)
			comforted = TRUE
			break
	if(comforted)
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "religious_comfort", /datum/mood_event/religiously_comforted)
	else
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "religious_comfort")

/datum/quirk/tagger
	name = "Tagger"
	desc = "You're an experienced artist. While drawing graffiti, you can get twice as many uses out of drawing supplies."
	value = 1
	mob_trait = TRAIT_TAGGER
	gain_text = "<span class='notice'>You know how to tag walls efficiently.</span>"
	lose_text = "<span class='danger'>You forget how to tag walls properly.</span>"

/datum/quirk/tagger/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/toy/crayon/spraycan/spraycan = new(get_turf(H))
	H.put_in_hands(spraycan)
	H.equip_to_slot(spraycan, ITEM_SLOT_BACKPACK)
	H.regenerate_icons()

/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine."
	value = 1
	mob_trait = TRAIT_VORACIOUS
	gain_text = "<span class='notice'>You feel HONGRY.</span>"
	lose_text = "<span class='danger'>You no longer feel HONGRY.</span>"

/datum/quirk/neet
	name = "NEET"
	desc = "For some reason you qualified for social welfare."
	value = 1
	mob_trait = TRAIT_NEET
	gain_text = "<span class='notice'>You feel useless to society.</span>"
	lose_text = "<span class='danger'>You no longer feel useless to society.</span>"
	mood_quirk = TRUE
	process = TRUE

/datum/quirk/neet/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/datum/bank_account/D = H.get_bank_account()
	if(!D) //if their current mob doesn't have a bank account, likely due to them being a special role (ie nuke op)
		return
	D.payment_per_department[ACCOUNT_NEET_ID] += PAYCHECK_WELFARE

/datum/quirk/proskater
	name = "Skater Bro"
	desc = "You’re a little too into old-earth skater culture! You're much more used to riding and falling off skateboards, needing less stamina to do kickflips and taking less damage upon bumping into something."
	value = 2
	mob_trait = TRAIT_PROSKATER
	gain_text = "<span class='notice'>You feel like hitting a sick grind!</span>"
	lose_text = "<span class='danger'>You no longer feel like you're in touch with the youth.</span>"

/datum/quirk/proskater/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	H.equip_to_slot_or_del(new /obj/item/melee/skateboard/pro(H), ITEM_SLOT_BACKPACK)
