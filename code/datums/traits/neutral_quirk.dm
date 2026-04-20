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

/datum/quirk/lizard_shedding
	name = "Shedding"
	desc = "Your scales naturally shed and regrow in cycles, changing your scale color each time."
	icon = "layer-group"
	process = TRUE
	restricted_species = list(/datum/species/lizard)
	species_whitelist = TRUE
	pref_restricted_species_id = SPECIES_LIZARD
	gain_text = span_notice("Your scales feel loose and itchy. You feel like you'll shed soon.")
	lose_text = span_notice("Your scales feel moisturized and stop their shedding cycle.")
	medical_record_text = "Patient exhibits a periodic shedding cycle. Pigment changes with each shed. No medical risk associated with this condition."
	var/shed_timer = 0
	var/shed_warning_stage = 0

/datum/quirk/lizard_shedding/add()
	shed_timer = rand(600, 9000) // 1-15 minutes before the first shed happens

/datum/quirk/lizard_shedding/on_process(delta_time)
	shed_timer -= delta_time
	if(shed_timer > 0)
		var/mob/living/carbon/human/H = quirk_target
		if(istype(H) && H.client)
			if(shed_timer <= 60 && shed_warning_stage == 0)
				shed_warning_stage = 1
				H.overlay_fullscreen("lizard_shed", /atom/movable/screen/fullscreen/brute, 2)
				to_chat(H, span_warning("Your scales feel dry and itchy."))
			if(shed_timer <= 12 && shed_warning_stage == 1)
				shed_warning_stage = 2
				H.overlay_fullscreen("lizard_shed", /atom/movable/screen/fullscreen/brute, 3)
				to_chat(H, span_warning("The itching from your scales intensifies - you feel like your shed is imminent!"))
				H.adjust_jitter(12 SECONDS)
		return
	shed_timer = rand(1800, 108000) // 3minutes to 3hours till next shed
	do_shed()

/datum/quirk/lizard_shedding/proc/do_shed()
	var/mob/living/carbon/human/H = quirk_target
	if(!istype(H) || H.stat == DEAD)
		return
	var/old_color = H.dna.features["mcolor"]
	if(!old_color)
		return
	shed_warning_stage = 0
	H.clear_fullscreen("lizard_shed", 20)

	var/list/old_hsv = rgb2hsv(old_color)
	var/hue_shift = rand(30, 60) * pick(1, -1)
	var/new_hue = (old_hsv[1] + hue_shift + 360) % 360
	var/new_sat = clamp(old_hsv[2] + rand(-15, 15), 20, 100)
	var/new_val = clamp(old_hsv[3] + rand(-10, 10), 20, 100)
	var/new_color = hsv2rgb(list(new_hue, new_sat, new_val))

	var/obj/item/skin = new /obj/item/stack/sheet/animalhide/lizard/shed_lizard_skin(H.drop_location())
	skin.color = old_color

	new /obj/effect/temp_visual/heal(get_turf(H), old_color)
	playsound(H, pick('sound/effects/rustle1.ogg', 'sound/effects/rustle2.ogg', 'sound/effects/rustle3.ogg', 'sound/effects/rustle4.ogg', 'sound/effects/rustle5.ogg'), 50, TRUE)

	H.dna.features["mcolor"] = new_color
	H.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
	H.update_body()
	H.update_body_parts(TRUE)

	var/atom/movable/shed_debris = new /obj/emitter/debris/colored(get_turf(H), old_color)
	QDEL_IN(shed_debris, 0.5 SECONDS)

	to_chat(H, span_notice("Your scales peel away as your old skin falls to the floor revealing a bright new pigmentation beneath!"))
	H.visible_message(span_notice("[H.name] shudders as their scales peel away, revealing a new pigmentation beneath!"))

/datum/quirk/shifty_eyes
	name = "Shifty Eyes"
	desc = "Your eyes tend to wander all over the place, whether you mean to or not, causing people to sometimes think you're looking directly at them when you aren't."
	icon = "fa-eye"
	medical_record_text = "Fucking creep kept staring at me the whole damn checkup. I'm only diagnosing this because it's less awkward than thinking it was on purpose."
	mob_trait = TRAIT_SHIFTY_EYES

/datum/quirk/emotional_luminescence
	name = "Emotional Luminescence"
	desc = "Your inner light is tied to your emotional state. Happiness makes you glow brighter, while a poor mood dims your light entirely."
	icon = "lightbulb"
	quirk_value = 0
	restricted_species = list(/datum/species/ethereal)
	species_whitelist = TRUE
	pref_restricted_species_id = SPECIES_ETHEREAL
	process = TRUE
	gain_text = span_notice("You feel your inner light connect with your emotions.")
	lose_text = span_notice("Your light settles back to a natural rhythm.")
	medical_record_text = "Patient's luminescence levels are dependant on their emotional state. Fufillment caused the subject to emit is significantly brighter light, while distress caused it to dim."

/datum/quirk/emotional_luminescence/on_process(delta_time)
	var/mob/living/carbon/human/H = quirk_target
	if(!istype(H))
		return
	var/datum/species/ethereal/E = H.dna?.species
	if(!istype(E) || !E.ethereal_light || E.EMPeffect || H.stat == DEAD)
		return
	var/datum/component/mood/mood_comp = H.GetComponent(/datum/component/mood)
	if(!mood_comp)
		return
	var/healthpercent = max(H.health, 0) / 100
	var/base_range = 1 + (2 * healthpercent)
	var/base_power = 1 + (1 * healthpercent)
	var/mood_mult = (mood_comp.mood_level - 1) * 0.25
	if(mood_mult <= 0)
		E.ethereal_light.set_light_on(FALSE)
	else
		E.ethereal_light.set_light_range_power_color(base_range * mood_mult, base_power * mood_mult, E.current_color)
		E.ethereal_light.set_light_on(TRUE)

/datum/quirk/shadowsynthesis
	name = "Shadowsynthesis"
	desc = "Your biology has adapted to draw sustenance from the dark. You now thrive in darkness instead of light."
	icon = "moon"
	quirk_value = 0
	restricted_species = list(/datum/species/diona)
	species_whitelist = TRUE
	pref_restricted_species_id = SPECIES_DIONA
	process = TRUE
	gain_text = span_notice("The excessive light feels discomforting to you. You yearn for the dark.")
	lose_text = span_notice("The darkness loses its comfort, you feel like you can finally enjoy the light again.")
	medical_record_text = "Patient's photosynthetic processes are reversed - they respond to darkness rather than light."
	var/time_spent_in_dark = 0

/datum/quirk/shadowsynthesis/add()
	var/mob/living/carbon/human/H = quirk_target
	H.remove_status_effect(/datum/status_effect/planthealing)

/datum/quirk/shadowsynthesis/remove()
	var/mob/living/carbon/human/H = quirk_target
	H.remove_status_effect(/datum/status_effect/plant_darkhealing)
	time_spent_in_dark = 0

/datum/quirk/shadowsynthesis/on_process(delta_time)
	var/mob/living/carbon/human/H = quirk_target
	if(!istype(H))
		return
	H.remove_status_effect(/datum/status_effect/planthealing)
	if(H.stat != CONSCIOUS || !isturf(H.loc))
		H.remove_status_effect(/datum/status_effect/plant_darkhealing)
		time_spent_in_dark = 0
		return
	var/turf/T = H.loc
	var/light_amount = min(1, T.get_lumcount())
	if(light_amount < 0.2) // Mob is in the dark if its below this threshold.
		time_spent_in_dark += delta_time
		if(time_spent_in_dark > 5)
			H.apply_status_effect(/datum/status_effect/plant_darkhealing)
	else
		H.remove_status_effect(/datum/status_effect/plant_darkhealing)
		time_spent_in_dark = 0
