//Traits that provide only flavor, and do not impose a noteworthy disadvantage to the player

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	icon = "beer"
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = span_notice("You feel like you could drink a whole keg!")
	lose_text = span_danger("You don't feel as resistant to alcohol anymore. Somehow.")
	medical_record_text = "Patient demonstrates a high tolerance for alcohol."

/datum/quirk/no_taste
	name = "Ageusia"
	desc = "You can't taste anything! Toxic food will still poison you."
	icon = "meh-blank"
	mob_trait = TRAIT_AGEUSIA
	gain_text = span_notice("You can't taste anything!")
	lose_text = span_notice("You can taste again!")
	medical_record_text = "Patient suffers from ageusia and is incapable of tasting food or reagents."

/datum/quirk/vegetarian
	name = "Vegetarian"
	desc = "You find the idea of eating meat morally and physically repulsive."
	icon = "carrot"
	gain_text = span_notice("You feel repulsion at the idea of eating meat.")
	lose_text = span_notice("You feel like eating meat isn't that bad.")
	medical_record_text = "Patient reports a vegetarian diet."

/datum/quirk/vegetarian/add()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	T?.liked_foodtypes &= ~MEAT
	T?.disliked_foodtypes |= MEAT

/datum/quirk/vegetarian/remove()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(H)
		if(initial(T.liked_foodtypes) & MEAT)
			T?.liked_foodtypes |= MEAT
		if(!(initial(T.disliked_foodtypes) & MEAT))
			T?.disliked_foodtypes &= ~MEAT

/datum/quirk/pineapple_liker
	name = "Ananas Affinity"
	desc = "You find yourself greatly enjoying fruits of the ananas genus. You can't seem to ever get enough of their sweet goodness!"
	icon = "thumbs-up"
	gain_text = span_notice("You feel an intense craving for pineapple.")
	lose_text = span_notice("Your feelings towards pineapples seem to return to a lukewarm state.")
	medical_record_text = "Patient demonstrates a pathological love of pineapple."

/datum/quirk/pineapple_liker/add()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	T?.liked_foodtypes |= PINEAPPLE

/datum/quirk/pineapple_liker/remove()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	T?.liked_foodtypes &= ~PINEAPPLE

/datum/quirk/pineapple_hater
	name = "Ananas Aversion"
	desc = "You find yourself greatly detesting fruits of the ananas genus. Serious, how the hell can anyone say these things are good? And what kind of madman would even dare putting it on a pizza!?"
	icon = "thumbs-down"
	gain_text = span_notice("You find yourself pondering what kind of idiot actually enjoys pineapples.")
	lose_text = span_notice("Your feelings towards pineapples seem to return to a lukewarm state.")
	medical_record_text = "Patient demonstrates a pathological hate of pineapple."

/datum/quirk/pineapple_hater/add()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	T?.disliked_foodtypes |= PINEAPPLE

/datum/quirk/pineapple_hater/remove()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	T?.disliked_foodtypes &= ~PINEAPPLE

/datum/quirk/deviant_tastes
	name = "Deviant Tastes"
	desc = "You dislike food that most people enjoy, and find delicious what they don't."
	icon = "grin-tongue-squint"
	gain_text = span_notice("You start craving something that tastes strange.")
	lose_text = span_notice("You feel like eating normal food again.")
	medical_record_text = "Patient demonstrates irregular nutrition preferences."

/datum/quirk/deviant_tastes/add()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	var/liked = T?.liked_foodtypes
	T?.liked_foodtypes = T?.disliked_foodtypes
	T?.disliked_foodtypes = liked

/datum/quirk/deviant_tastes/remove()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)
	T?.liked_foodtypes = initial(T?.liked_foodtypes)
	T?.disliked_foodtypes = initial(T?.disliked_foodtypes)

/datum/quirk/light_drinker
	name = "Light Drinker"
	desc = "You just can't handle your drinks and get drunk very quickly."
	icon = "cocktail"
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = span_notice("Just the thought of drinking alcohol makes your head spin.")
	lose_text = span_danger("You're no longer severely affected by alcohol.")
	medical_record_text = "Patient demonstrates a low tolerance for alcohol."

/datum/quirk/monochromatic
	name = "Monochromacy"
	desc = "You suffer from full colorblindness, and perceive nearly the entire world in blacks and whites."
	icon = "adjust"
	medical_record_text = "Patient is afflicted with almost complete color blindness."

/datum/quirk/monochromatic/add()
	quirk_target.add_client_colour(/datum/client_colour/monochrome)

/datum/quirk/monochromatic/post_spawn()
	if(quirk_holder.assigned_role == JOB_NAME_DETECTIVE)
		to_chat(quirk_target, span_boldannounce("Mmm. Nothing's ever clear on this station. It's all shades of gray."))
		quirk_target.playsound_local(quirk_target, 'sound/ambience/ambidet1.ogg', 50, FALSE)

/datum/quirk/monochromatic/remove()
	quirk_target.remove_client_colour(/datum/client_colour/monochrome)

/datum/quirk/musician
	name = "Musician"
	desc = "You start with a delivery beacon for a variety of musical instruments."
	icon = "guitar"
	gain_text = span_notice("You feel an irresistible urge to play Stairway to Heaven in every guitar shop you enter.")
	lose_text = span_danger("Your insatiable urge to play Wonderwall is finally sated.")
	medical_record_text = "Patient has been banned from several music stores for repeatedly playing forbidden riffs."

/datum/quirk/musician/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/choice_beacon/radial/music/B = new(get_turf(H))
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS,
	)
	H.equip_in_one_of_slots(B, slots , qdel_on_fail = TRUE)

/datum/quirk/mute
	name = "Mute"
	desc = "You are unable to speak."
	icon = "volume-mute"
	mob_trait = TRAIT_MUTE
	gain_text = span_danger("You feel unable to talk.")
	lose_text = span_notice("You feel able to talk again.")
	medical_record_text = "Patient is unable to speak."

/datum/quirk/plushielover
	name = "Plushie Lover"
	desc = "You love your squishy friends so much. You start with a plushie delivery beacon."
	icon = "heart"
	gain_text = span_notice("You can't wait to hug a plushie!.")
	lose_text = span_danger("You don't feel that passion for plushies anymore.")
	medical_record_text = "Patient demonstrated a high affinity for plushies."

/datum/quirk/plushielover/on_spawn()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/choice_beacon/radial/plushie/B = new(get_turf(H))
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS,
	)
	H.equip_in_one_of_slots(B, slots , qdel_on_fail = TRUE)

/datum/quirk/spiritual
	name = "Spiritual"
	desc = "You hold a spiritual belief, whether in God, nature or the arcane rules of the universe. You gain comfort from the presence of holy people, and believe that your prayers are more special than others."
	icon = "bible"
	mob_trait = TRAIT_SPIRITUAL
	gain_text = span_notice("You have faith in a higher power.")
	lose_text = span_danger("You lose faith!")
	process = TRUE
	medical_record_text = "Patient reports a belief in a higher power."

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

/datum/quirk/accent	//base accent is medieval
	name = "Accent"
	desc = "You have a distinct way of speaking! (Select one in character creation)"
	icon = "comment-dots"
	gain_text = span_notice("You are afflicted with an accent.")
	lose_text = span_danger("You are no longer afflicted with an accent.")
	medical_record_text = "Patient has a distinct accent."
	/// Accent to be used in accent traits
	var/accent_to_use = null

/datum/quirk/accent/add()
	var/chosen = read_choice_preference(/datum/preference/choiced/quirk/accent)
	accent_to_use = GLOB.accents[chosen || pick(GLOB.accents)]
	RegisterSignal(quirk_target, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/accent/remove()
	UnregisterSignal(quirk_target, COMSIG_MOB_SAY)

/datum/quirk/accent/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	handle_accented_speech(speech_args, accent_to_use)

/datum/quirk/shifty_eyes
	name = "Shifty Eyes"
	desc = "Your eyes tend to wander all over the place, whether you mean to or not, causing people to sometimes think you're looking directly at them when you aren't."
	icon = "fa-eye"
	medical_record_text = "Fucking creep kept staring at me the whole damn checkup. I'm only diagnosing this because it's less awkward than thinking it was on purpose."
	mob_trait = TRAIT_SHIFTY_EYES
