/// Adds a newline to the examine list if the above entry is not empty and it is not the first element in the list
#define ADD_NEWLINE_IF_NECESSARY(list) if(length(list) > 0 && list[length(list)]) { list += "" }
#define CARBON_EXAMINE_EMBEDDING_MAX_DIST 4

/mob/living/carbon/human/get_examine_icon(mob/user)
	return null

/mob/living/carbon/examine(mob/user)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		return list(span_warning("You're struggling to make out any details..."))

	var/t_He = p_They()
	var/t_His = p_Their()
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	. = list()
	. += get_clothing_examine_info(user)
	// give us some space between clothing examine and the rest
	ADD_NEWLINE_IF_NECESSARY(.)

	var/appears_dead = FALSE
	var/just_sleeping = FALSE

	if(!appears_alive())
		appears_dead = TRUE

		var/obj/item/clothing/glasses/shades = get_item_by_slot(ITEM_SLOT_EYES)
		var/are_we_in_weekend_at_bernies = shades?.tint && buckled && istype(buckled, /obj/vehicle/ridden/wheelchair)

		if(isliving(user) && (HAS_MIND_TRAIT(user, TRAIT_NAIVE) || are_we_in_weekend_at_bernies))
			just_sleeping = TRUE

		if(!just_sleeping)
			// since this is relatively important and giving it space makes it easier to read
			ADD_NEWLINE_IF_NECESSARY(.)

			if(suiciding)
				. += span_warning("[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.")

			. += generate_death_examine_text()

	//Status effects
	var/list/status_examines = get_status_effect_examinations()
	if (length(status_examines))
		. += status_examines

	if(get_bodypart(BODY_ZONE_HEAD) && !get_organ_by_type(/obj/item/organ/brain))
		. += span_deadsay("It appears that [t_his] brain is missing...")

	var/list/disabled = list()
	for(var/obj/item/bodypart/body_part as anything in bodyparts)
		if(body_part.bodypart_disabled)
			disabled += body_part
		for(var/obj/item/embedded as anything in body_part.embedded_objects)
			var/harmless = embedded.embedding == EMBED_HARMLESS
			var/stuck_wordage = harmless ? "stuck to" : "embedded in"
			var/embed_line = "\a [embedded]"
			if (get_dist(src, user) <= CARBON_EXAMINE_EMBEDDING_MAX_DIST)
				embed_line = "<a href='byond://?src=[REF(src)];embedded_object=[REF(embedded)];embedded_limb=[REF(body_part)]'>\a [embedded]</a>"
			var/embed_text = "[t_He] [t_has] [icon2html(embedded, user)] [embed_line] [stuck_wordage] [t_his] [body_part.plaintext_zone]!"
			if (harmless)
				. += span_italics(span_notice(embed_text))
			else
				. += span_boldwarning(embed_text)

	for(var/obj/item/bodypart/body_part as anything in disabled)
		var/damage_text
		if(body_part.get_damage() < body_part.max_damage) //we don't care if it's stamcritted
			damage_text = "limp and lifeless"
		else
			damage_text = (body_part.brute_dam >= body_part.burn_dam) ? body_part.heavy_brute_msg : body_part.heavy_burn_msg
		. += span_boldwarning("[capitalize(t_his)] [body_part.plaintext_zone] looks [damage_text]!")

	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/missing_limb in get_missing_limbs())
		if(missing_limb == BODY_ZONE_HEAD)
			. += span_deadsay("<B>[t_His] [parse_zone(missing_limb)] is missing!</B>")
			continue
		if(missing_limb == BODY_ZONE_L_ARM || missing_limb == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(missing_limb == BODY_ZONE_R_ARM || missing_limb == BODY_ZONE_R_LEG)
			r_limbs_missing++

		. += span_boldwarning("[capitalize(t_his)] [parse_zone(missing_limb)] is missing!")

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		. += span_tinydanger("[t_He] look[p_s()] all right now...")
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		. += span_tinydanger("[t_He] really keep[p_s()] to the left...")
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		. += span_tinydanger("[t_He] [p_do()]n't seem all there...")

	var/list/damage_desc = get_harm_descriptors()
	if(!(user == src && has_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy))) //fake healthy
		var/temp
		if(user == src && has_status_effect(/datum/status_effect/grouped/screwy_hud/fake_crit))//fake damage
			temp = 50
		else
			temp = getBruteLoss()
		if(temp)
			if(temp < 25)
				. += span_danger("[t_He] [t_has] minor [damage_desc[BRUTE]].")
			else if(temp < 50)
				. += span_danger("[t_He] [t_has] <b>moderate</b> [damage_desc[BRUTE]]!")
			else
				. += span_bolddanger("[t_He] [t_has] severe [damage_desc[BRUTE]]!")

		temp = getFireLoss()
		if(temp)
			if(temp < 25)
				. += span_danger("[t_He] [t_has] minor [damage_desc[BURN]].")
			else if (temp < 50)
				. += span_danger("[t_He] [t_has] <b>moderate</b> [damage_desc[BURN]]!")
			else
				. += span_bolddanger("[t_He] [t_has] severe [damage_desc[BURN]]!")

	if(pulledby?.grab_state)
		. += span_warning("[t_He] [t_is] restrained by [pulledby]'s grip.")

	if(nutrition < NUTRITION_LEVEL_STARVING - 50)
		. += span_warning("[t_He] [t_is] severely malnourished.")
	else if(nutrition >= NUTRITION_LEVEL_FAT)
		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
			. += span_hypnophrase("[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.")
		else
			. += "<b>[t_He] [t_is] quite chubby.</b>"
	switch(disgust)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			. += "[t_He] look[p_s()] a bit grossed out."
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			. += "[t_He] look[p_s()] really grossed out."
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			. += "[t_He] look[p_s()] extremely disgusted."

	var/apparent_blood_volume = blood_volume
	if(ishuman(src))
		var/mob/living/carbon/human/human_us = src // gross istypesrc but easier than refactoring even further for now
		if(human_us.dna.species.use_skintones && human_us.skin_tone == "albino")
			apparent_blood_volume -= (BLOOD_VOLUME_NORMAL * 0.25) // knocks you down a few pegs
	switch(apparent_blood_volume)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			. += span_warning("[t_He] [t_has] pale skin.")
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			. += span_boldwarning("[t_He] look[p_s()] like pale death.")
		if(-INFINITY to BLOOD_VOLUME_BAD)
			. += span_deadsay("<b>[t_He] resemble[p_s()] a crushed, empty juice pouch.</b>")

	if (is_bleeding())
		switch (get_bleed_rate())
			if (BLEED_DEEP_WOUND to INFINITY)
				. += span_warning("[src] is [damage_desc[BLEED]] extremely quickly.")
			if (BLEED_RATE_MINOR to BLEED_DEEP_WOUND)
				. += span_warning("[src] is [damage_desc[BLEED]] at a significant rate.")
			else
				. += span_warning("[src] has some minor [damage_desc[BLEED]] which looks like it will stop soon.")
	else if (is_bandaged())
		. += span_warning("[src] is [damage_desc[BLEED]], but it is covered.")

	if(reagents.has_reagent(/datum/reagent/teslium, needs_metabolizing = TRUE))
		. += span_smallnoticeital("[t_He] [t_is] emitting a gentle blue glow!") // this should be signalized

	if(just_sleeping)
		. += span_notice("[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.")

	else if(!appears_dead)
		if(src != user)
			if(HAS_TRAIT(user, TRAIT_EMPATH))
				if (combat_mode)
					. += "[t_He] seem[p_s()] to be on guard."
				if (getOxyLoss() >= 10)
					. += "[t_He] seem[p_s()] winded."
				if (getToxLoss() >= 10)
					. += "[t_He] seem[p_s()] sickly."
				var/datum/component/mood/mood = GetComponent(/datum/component/mood)
				if(mood.sanity <= SANITY_DISTURBED)
					. += "[t_He] seem[p_s()] distressed.\n"
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "empath", /datum/mood_event/sad_empath, src)
				if(is_blind())
					. += "[t_He] appear[p_s()] to be staring off into space."
				if (HAS_TRAIT(src, TRAIT_DEAF))
					. += "[t_He] appear[p_s()] to not be responding to noises."
				if (bodytemperature > dna.species.bodytemp_heat_damage_limit)
					. += "[t_He] [t_is] flushed and wheezing."
				if (bodytemperature < dna.species.bodytemp_cold_damage_limit)
					. += "[t_He] [t_is] shivering."

			if(HAS_TRAIT(user, TRAIT_SPIRITUAL) && mind?.holy_role)
				. += "[t_He] [t_has] a holy aura about [t_him]."
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "religious_comfort", /datum/mood_event/religiously_comforted)

		switch(stat)
			if(UNCONSCIOUS, HARD_CRIT)
				. += span_notice("[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.")
			if(SOFT_CRIT)
				. += span_notice("[t_He] [t_is] barely conscious.")
			if(CONSCIOUS)
				if(HAS_TRAIT(src, TRAIT_DUMB))
					. += "[t_He] [t_has] a stupid expression on [t_his] face."
		var/obj/item/organ/brain/brain = get_organ_by_type(/obj/item/organ/brain)
		if(brain && isnull(ai_controller))
			var/npc_message = ""
			if(!key)
				npc_message = "[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely."
			else if(!client)
				npc_message ="[t_He] [t_has] a blank, absent-minded stare and appears completely unresponsive to anything. [t_He] may snap out of it soon."
			if(npc_message)
				// give some space since this is usually near the end
				ADD_NEWLINE_IF_NECESSARY(.)
				. += span_deadsay(npc_message)

	if(HAS_TRAIT(src, TRAIT_HUSK))
		. += span_warning("This body has been reduced to a grotesque husk.")

	var/hud_info = get_hud_examine_info(user)
	if(length(hud_info))
		. += hud_info

	if(isobserver(user))
		ADD_NEWLINE_IF_NECESSARY(.)
		. += "<b>Quirks:</b> [get_quirk_string(FALSE, CAT_QUIRK_ALL)]"

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE, user, .)
	if(length(.))
		.[1] = "<span class='info'>" + .[1]
		.[length(.)] += "</span>"
	return .

/**
 * Shows any and all examine text related to any status effects the user has.
 */
/mob/living/proc/get_status_effect_examinations()
	var/list/examine_list = list()

	for(var/datum/status_effect/effect as anything in status_effects)
		var/effect_text = effect.get_examine_text()
		if(!effect_text)
			continue

		examine_list += effect_text

	if(!length(examine_list))
		return

	return examine_list.Join("<br>")

/// Returns death message for mob examine text
/mob/living/carbon/proc/generate_death_examine_text()
	var/t_He = p_They()
	var/t_his = p_their()
	var/t_is = p_are()

	if(suiciding)
		return span_warning("[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.")
	if(get_organ_by_type(/obj/item/organ/brain) && !key && !get_ghost(FALSE, TRUE))
		return span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life and [t_his] soul has departed...")
	else if(!client && key)
		return span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life and [t_his] soul seems distant, it may return soon...")
	else
		return span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life...")

/// Returns a list of "damtype" => damage description based off of which bodypart description is most common
/mob/living/carbon/proc/get_harm_descriptors()
	return dna?.species.get_harm_descriptors() || list(BLEED = "bleeding", BRUTE = "bruising", BURN = "burns")

/// Collects examine information about the mob's clothing and equipment
/mob/living/carbon/proc/get_clothing_examine_info(mob/living/user)
	. = list()
	var/obscured = check_obscured_slots()
	var/t_He = p_They()
	var/t_His = p_Their()
	var/t_his = p_their()
	var/t_has = p_have()
	var/t_is = p_are()
	//head
	if(head && !(obscured & ITEM_SLOT_HEAD) && !HAS_TRAIT(head, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [head.examine_title(user)] on [t_his] head."
	//back
	if(back && !HAS_TRAIT(back, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [back.examine_title(user)] on [t_his] back."
	//Hands
	for(var/obj/item/held_thing in held_items)
		if((held_thing.item_flags & (ABSTRACT|HAND_ITEM)) || HAS_TRAIT(held_thing, TRAIT_EXAMINE_SKIP))
			continue
		. += "[t_He] [t_is] holding [held_thing.examine_title(user)] in [t_his] [get_held_index_name(get_held_index_of_item(held_thing))]."
	//gloves
	if(gloves && !(obscured & ITEM_SLOT_GLOVES) && !HAS_TRAIT(gloves, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [gloves.examine_title(user)] on [t_his] hands."
	else if(GET_ATOM_BLOOD_DNA_LENGTH(src) && num_hands)
		. += span_warning("[t_He] [t_has] [num_hands > 1 ? "" : "a"] blood-stained hand[num_hands > 1 ? "s" : ""]!")
	//handcuffed?
	if(handcuffed)
		var/cables_or_cuffs = istype(handcuffed, /obj/item/restraints/handcuffs/cable) ? "restrained with cable" : "handcuffed"
		. += span_warning("[t_He] [t_is] [icon2html(handcuffed, user)] [cables_or_cuffs]!")
	//shoes
	if(shoes && !(obscured & ITEM_SLOT_FEET)  && !HAS_TRAIT(shoes, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [shoes.examine_title(user)] on [t_his] feet."
	//mask
	if(wear_mask && !(obscured & ITEM_SLOT_MASK)  && !HAS_TRAIT(wear_mask, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [wear_mask.examine_title(user)] on [t_his] face."
	if(wear_neck && !(obscured & ITEM_SLOT_NECK)  && !HAS_TRAIT(wear_neck, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_neck.examine_title(user)] around [t_his] neck."
	//eyes
	if(!(obscured & ITEM_SLOT_EYES) )
		if(glasses  && !HAS_TRAIT(glasses, TRAIT_EXAMINE_SKIP))
			. += "[t_He] [t_has] [glasses.examine_title(user)] covering [t_his] eyes."
		else if(HAS_TRAIT(src, CULT_EYES))
			. += span_boldwarning("[t_His] eyes are glowing with an unnatural red aura!")
		else if(HAS_TRAIT(src, TRAIT_BLOODSHOT_EYES))
			. += span_boldwarning("[t_His] eyes are bloodshot!")
	//ears
	if(ears && !(obscured & ITEM_SLOT_EARS) && !HAS_TRAIT(ears, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [ears.examine_title(user)] on [t_his] ears."

// Yes there's a lot of copypasta here, we can improve this later when carbons are less dumb in general
/mob/living/carbon/human/get_clothing_examine_info(mob/living/user)
	. = list()
	var/obscured = check_obscured_slots()
	var/t_He = p_They()
	var/t_His = p_Their()
	var/t_his = p_their()
	var/t_has = p_have()
	var/t_is = p_are()

	//uniform
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING) && !HAS_TRAIT(w_uniform, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [w_uniform.examine_worn_title(src, user)]."
	//head
	if(head && !(obscured & ITEM_SLOT_HEAD) && !HAS_TRAIT(head, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [head.examine_worn_title(src, user)] on [t_his] head."
	//mask
	if(wear_mask && !(obscured & ITEM_SLOT_MASK)  && !HAS_TRAIT(wear_mask, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [wear_mask.examine_worn_title(src, user)] on [t_his] face."
	//neck
	if(wear_neck && !(obscured & ITEM_SLOT_NECK)  && !HAS_TRAIT(wear_neck, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_neck.examine_worn_title(src, user)] around [t_his] neck."
	//eyes
	if(!(obscured & ITEM_SLOT_EYES) )
		if(glasses  && !HAS_TRAIT(glasses, TRAIT_EXAMINE_SKIP))
			. += "[t_He] [t_has] [glasses.examine_worn_title(src, user)] covering [t_his] eyes."
		else if(HAS_TRAIT(src, CULT_EYES))
			. += span_boldwarning("[t_His] eyes are glowing with an unnatural red aura!")
		else if(HAS_TRAIT(src, TRAIT_BLOODSHOT_EYES))
			. += span_boldwarning("[t_His] eyes are bloodshot!")
	//ears
	if(ears && !(obscured & ITEM_SLOT_EARS) && !HAS_TRAIT(ears, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [ears.examine_worn_title(src, user)] on [t_his] ears."
	//suit/armor
	if(wear_suit && !HAS_TRAIT(wear_suit, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_suit.examine_worn_title(src, user)]."
		//suit/armor storage
		if(s_store && !(obscured & ITEM_SLOT_SUITSTORE) && !HAS_TRAIT(s_store, TRAIT_EXAMINE_SKIP))
			. += "[t_He] [t_is] carrying [s_store.examine_worn_title(src, user)] on [t_his] [wear_suit.name]."
	//back
	if(back && !HAS_TRAIT(back, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [back.examine_worn_title(src, user)] on [t_his] back."
	//ID
	if(wear_id && !HAS_TRAIT(wear_id, TRAIT_EXAMINE_SKIP))
		var/obj/item/card/id/id = wear_id.GetID()
		if(id && get_dist(user, src) <= ID_EXAMINE_DISTANCE)
			// Get the item description without any examine link, then add our own clickable [Look at ID] link
			var/id_line = wear_id.examine_worn_title(src, user, skip_examine_link = TRUE)
			var/id_link = "<a href='byond://?src=[REF(src)];see_id=1;id_ref=[REF(id)];id_name=[id.registered_name];examine_time=[world.time]'>\[Look at ID\]</a>"
			. += "[t_He] [t_is] wearing [id_line] [id_link]."

		else
			. += "[t_He] [t_is] wearing [wear_id.examine_worn_title(src, user)]."
	//Hands
	for(var/obj/item/held_thing in held_items)
		if((held_thing.item_flags & (ABSTRACT|HAND_ITEM)) || HAS_TRAIT(held_thing, TRAIT_EXAMINE_SKIP))
			continue
		. += "[t_He] [t_is] holding [held_thing.examine_worn_title(src, user)] in [t_his] [get_held_index_name(get_held_index_of_item(held_thing))]."
	//gloves
	if(gloves && !(obscured & ITEM_SLOT_GLOVES) && !HAS_TRAIT(gloves, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [gloves.examine_worn_title(src, user)] on [t_his] hands."
	else if(GET_ATOM_BLOOD_DNA_LENGTH(src) || blood_in_hands)
		if(num_hands)
			. += span_warning("[t_He] [t_has] [num_hands > 1 ? "" : "a "]blood-stained hand[num_hands > 1 ? "s" : ""]!")
	//handcuffed?
	if(handcuffed)
		var/cables_or_cuffs = istype(handcuffed, /obj/item/restraints/handcuffs/cable) ? "restrained with cable" : "handcuffed"
		. += span_warning("[t_He] [t_is] [icon2html(handcuffed, user)] [cables_or_cuffs]!")
	//belt
	if(belt && !(obscured & ITEM_SLOT_BELT) && !HAS_TRAIT(belt, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_has] [belt.examine_worn_title(src, user)] about [t_his] waist."
	//shoes
	if(shoes && !(obscured & ITEM_SLOT_FEET)  && !HAS_TRAIT(shoes, TRAIT_EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [shoes.examine_worn_title(src, user)] on [t_his] feet."

/// Collects info displayed about any HUDs the user has when examining src
/mob/living/carbon/proc/get_hud_examine_info(mob/living/user)
	return

/mob/living/carbon/human/get_hud_examine_info(mob/living/user)
	. = list()

	var/perpname = get_face_name(get_id_name(""))
	var/title = ""
	if(perpname && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)) && (user.stat == CONSCIOUS || isobserver(user)) && user != src)
		var/datum/record/crew/target_record = find_record(perpname, GLOB.manifest.general)
		if(target_record)
			. += "Rank: [target_record.rank]"
			. += "<a href='byond://?src=[REF(src)];hud=1;photo_front=1;examine_time=[world.time]'>\[Front photo\]</a><a href='byond://?src=[REF(src)];hud=1;photo_side=1;examine_time=[world.time]'>\[Side photo\]</a>"
		if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD) && HAS_TRAIT(user, TRAIT_SECURITY_HUD))
			title = separator_hr("Medical & Security Analysis")
			. += get_medhud_examine_info(user, target_record)
			. += get_sechud_examine_info(user, target_record)

		else if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
			title = separator_hr("Medical Analysis")
			. += get_medhud_examine_info(user, target_record)

		else if(HAS_TRAIT(user, TRAIT_SECURITY_HUD))
			title = separator_hr("Security Analysis")
			. += get_sechud_examine_info(user, target_record)

	// applies the separator correctly without an extra line break
	if(title && length(.))
		.[1] = title + .[1]
	return .

/// Collects information displayed about src when examined by a user with a medical HUD.
/mob/living/carbon/proc/get_medhud_examine_info(mob/living/user, datum/record/crew/target_record)
	. = list()

	var/list/cybers = list()
	for(var/obj/item/organ/cyberimp/cyberimp in internal_organs)
		if(cyberimp.status == ORGAN_ROBOTIC && !cyberimp.syndicate_implant)
			cybers += cyberimp.examine_title(user)
	if(length(cybers))
		. += "<span class='notice ml-1'>Detected cybernetic modifications:</span>"
		. += "<span class='notice ml-2'>[english_list(cybers, and_text = ", and")]</span>"
	if(target_record)
		. += "<a href='byond://?src=[REF(src)];hud=m;physical_status=1;examine_time=[world.time]'>\[[target_record.physical_status]\]</a>"
		. += "<a href='byond://?src=[REF(src)];hud=m;mental_status=1;examine_time=[world.time]'>\[[target_record.mental_status]\]</a>"
	else
		. += "\[Record Missing\]"
		. += "\[Record Missing\]"
	. += "<a href='byond://?src=[REF(src)];hud=m;evaluation=1;examine_time=[world.time]'>\[Medical evaluation\]</a>"
	. += "<a href='byond://?src=[REF(src)];hud=m;quirk=1;examine_time=[world.time]'>\[See quirks\]</a>"

/// Collects information displayed about src when examined by a user with a security HUD.
/mob/living/carbon/proc/get_sechud_examine_info(mob/living/user, datum/record/crew/target_record)
	. = list()

	var/wanted_status = WANTED_NONE
	var/security_note = "None."

	if(target_record)
		wanted_status = target_record.wanted_status
		if(target_record.security_note)
			security_note = target_record.security_note
	if(ishuman(user))
		. += "Criminal status: <a href='byond://?src=[REF(src)];hud=s;status=1;examine_time=[world.time]'>\[[wanted_status]\]</a>"
	else
		. += "Criminal status: [wanted_status]"
	. += "Important Notes: [security_note]"
	. += "Security record: <a href='byond://?src=[REF(src)];hud=s;view=1;examine_time=[world.time]'>\[View\]</a>"
	if(ishuman(user))
		. += "<a href='byond://?src=[REF(src)];hud=s;add_citation=1;examine_time=[world.time]'>\[Add citation\]</a>\
			<a href='byond://?src=[REF(src)];hud=s;add_crime=1;examine_time=[world.time]'>\[Add crime\]</a>\
			<a href='byond://?src=[REF(src)];hud=s;add_note=1;examine_time=[world.time]'>\[Add note\]</a>"

/mob/living/carbon/human/examine_more(mob/user)
	. = ..()

	if(istype(w_uniform, /obj/item/clothing/under) && !(check_obscured_slots() & ITEM_SLOT_ICLOTHING) && !HAS_TRAIT(w_uniform, TRAIT_EXAMINE_SKIP))
		var/obj/item/clothing/under/undershirt = w_uniform
		if(undershirt.has_sensor == BROKEN_SENSORS)
			. += list(span_notice("\The [undershirt]'s medical sensors are sparking."))

	var/limbs_text = get_mismatched_limb_text()
	if(LAZYLEN(limbs_text))
		. += limbs_text

	var/agetext = get_age_text()
	if(agetext)
		. += agetext

/// Reports all body parts which are mismatched with the user's species
/mob/living/carbon/human/proc/get_mismatched_limb_text()
	. = list()
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(part.limb_id == (dna.species.examine_limb_id || dna.species.id))
			continue
		. += span_notice("[p_They()] [p_have()] \a [part].")

/// Reports how old the mob appears to be
/mob/living/carbon/human/proc/get_age_text()
	if((wear_mask?.flags_inv & HIDEFACE) || (head?.flags_inv & HIDEFACE))
		return

	var/age_text
	switch(age)
		if(-INFINITY to 25)
			age_text = "very young"
		if(26 to 35)
			age_text = "of adult age"
		if(36 to 55)
			age_text = "middle-aged"
		if(56 to 75)
			age_text = "rather old"
		if(76 to 100)
			age_text = "very old"
		if(101 to INFINITY)
			age_text = "withering away"

	return span_notice("[p_They()] appear[p_s()] to be [age_text].")

#undef ADD_NEWLINE_IF_NECESSARY
#undef CARBON_EXAMINE_EMBEDDING_MAX_DIST
