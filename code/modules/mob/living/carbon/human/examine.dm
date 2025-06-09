/mob/living/carbon/human/examine(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()
	var/t_es = p_es()
	var/obscure_name
	var/obscure_examine

	var/obscured = check_obscured_slots()
	var/skipface = ((wear_mask?.flags_inv & HIDEFACE) || (head?.flags_inv & HIDEFACE))

	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_PROSOPAGNOSIA))
			obscure_name = TRUE
		if(HAS_TRAIT(src, TRAIT_UNKNOWN))
			obscure_name = TRUE
			obscure_examine = TRUE

	/*
	 * Inherent Examine
	*/
	var/list/inherent_examine = list()

	// Potted Plants
	if(obscure_examine)
		return list(span_warning("You're struggling to make out any details..."))

	// Psyphoza sense. THIS SHOULDN'T BE HERE!
	if(HAS_TRAIT(user, TRAIT_PSYCHIC_SENSE) && mind)
		to_chat(user, "[span_notice("[src] has a <span class='[GLOB.soul_glimmer_cfc_list[mind.soul_glimmer]]'>[mind.soul_glimmer]</span>")] presence.")

	// Uniform
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING) && !(w_uniform.item_flags & EXAMINE_SKIP))
		// Accessory (badges/etc)
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.attached_accessory)
				accessory_msg += " with [icon2html(U.attached_accessory, user)] \a [U.attached_accessory]"

		inherent_examine += "[t_He] [t_is] wearing [w_uniform.get_examine_string(user)][accessory_msg]."

	// Head
	if(head && !(head.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head."

	// Suit/armor
	if(wear_suit && !(wear_suit.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_is] wearing [wear_suit.get_examine_string(user)]."
		// Storage
		if(s_store && !(obscured & ITEM_SLOT_SUITSTORE) && !(s_store.item_flags & EXAMINE_SKIP))
			inherent_examine += "[t_He] [t_is] carrying [s_store.get_examine_string(user)] on [t_his] [wear_suit.name]."

	// Back
	if(back && !(back.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."

	// Hands
	for(var/obj/item/item in held_items)
		if(!(item.item_flags & ABSTRACT) && !(item.item_flags & EXAMINE_SKIP))
			inherent_examine += "[t_He] [t_is] holding [item.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(item))]."

	// Gloves
	var/datum/component/forensics/FR = GetComponent(/datum/component/forensics)
	if(gloves && !(obscured & ITEM_SLOT_GLOVES) && !(gloves.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_has] [gloves.get_examine_string(user)] on [t_his] hands."
	else if(FR && length(FR.blood_DNA))
		if(num_hands)
			inherent_examine += span_warning("[t_He] [t_has] [num_hands > 1 ? "" : "a"] blood-stained hand[num_hands > 1 ? "s" : ""]!")

	// Belt
	if(belt && !(belt.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_has] [belt.get_examine_string(user)] about [t_his] waist."

	// Shoes
	if(shoes && !(obscured & ITEM_SLOT_FEET) && !(shoes.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_is] wearing [shoes.get_examine_string(user)] on [t_his] feet."

	// Mask
	if(wear_mask && !(obscured & ITEM_SLOT_MASK) && !(wear_mask.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_has] [wear_mask.get_examine_string(user)] on [t_his] face."

	if(wear_neck && !(obscured & ITEM_SLOT_NECK) && !(wear_neck.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck."

	// Eyes
	if(!(obscured & ITEM_SLOT_EYES))
		if(glasses && !(glasses.item_flags & EXAMINE_SKIP))
			inherent_examine += "[t_He] [t_has] [glasses.get_examine_string(user)] covering [t_his] eyes."
		else if(eye_color == BLOODCULT_EYE && iscultist(src) && HAS_TRAIT(src, CULT_EYES))
			inherent_examine += span_warning("<B>[t_His] eyes are glowing an unnatural red!</B>")

	// Ears
	if(ears && !(obscured & ITEM_SLOT_EARS) && !(ears.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_has] [ears.get_examine_string(user)] on [t_his] ears."

	// ID Card
	if(wear_id && !(wear_id.item_flags & EXAMINE_SKIP))
		inherent_examine += "[t_He] [t_is] wearing [wear_id.get_examine_string(user)]."

	// Status effects
	inherent_examine += status_effect_examines()

	// Jittering
	switch(jitteriness)
		if(300 to INFINITY)
			inherent_examine += span_warning("<B>[t_He] [t_is] convulsing violently!</B>")
		if(200 to 300)
			inherent_examine += span_warning("[t_He] [t_is] extremely jittery.")
		if(100 to 200)
			inherent_examine += span_warning("[t_He] [t_is] twitching ever so slightly.")

	var/appears_dead = FALSE
	var/just_sleeping = FALSE

	// Death
	if(stat == DEAD || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		appears_dead = TRUE

		if(isliving(user) && HAS_TRAIT(user, TRAIT_NAIVE))
			just_sleeping = TRUE

		if(!just_sleeping)
			if(suiciding)
				inherent_examine += span_warning("[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.")
			else if(ishellbound())
				inherent_examine += span_warning("[t_His] soul seems to have been ripped out of [t_his] body. Revival is impossible.")
			else if(soul_departed())
				inherent_examine += span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life and [t_his] soul has departed...")
			else if(!client && key)
				inherent_examine += span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life and [t_his] soul seems distant, it may return soon...")
			else
				inherent_examine += span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life...")

	// Sleeping
	if(just_sleeping)
		inherent_examine += "[capitalize(user.p_they(TRUE))] isn't responding to anything around [user.p_them()] and seems to be asleep."

	// Brain
	if(get_bodypart(BODY_ZONE_HEAD) && !getorgan(/obj/item/organ/brain))
		inherent_examine += span_deadsay("It appears that [t_his] brain is missing.")

	// Handcuffs
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			inherent_examine += span_warning("[t_He] [t_is] restrained with cable!")
		else
			inherent_examine += span_warning("[t_He] [t_is] handcuffed with [handcuffed]!")

	// Legcuffs
	if(legcuffed)
		inherent_examine += span_warning("[t_He] [t_is] legcuffed with [legcuffed]!")

	/*
	 * Damage Examine
	*/
	var/list/damage_examine = list()

	// Embedded Objects
	for(var/obj/item/bodypart/body_part as() in bodyparts)
		for(var/obj/item/I in body_part.embedded_objects)
			if(I.isEmbedHarmless())
				damage_examine += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] stuck to [t_his] [body_part.name]!</B>"
			else
				damage_examine += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] embedded in [t_his] [body_part.name]!</B>"

	// Disabled Limbs
	for(var/obj/item/bodypart/body_part as() in bodyparts)
		if(!body_part.bodypart_disabled)
			continue

		var/damage_text
		if(!(body_part.get_damage(include_stamina = FALSE) >= body_part.max_damage)) //we don't care if it's stamcritted
			damage_text = "limp and lifeless"
		else
			damage_text = (body_part.brute_dam >= body_part.burn_dam) ? body_part.heavy_brute_msg : body_part.heavy_burn_msg
		damage_examine += "<B>[capitalize(t_his)] [body_part.name] is [damage_text]!</B>"

	// Missing Limbs
	var/list/missing_limbs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	for(var/obj/item/bodypart/body_part as() in bodyparts)
		missing_limbs -= body_part.body_zone

	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing_limbs)
		if(t == BODY_ZONE_HEAD)
			damage_examine += span_deadsay("[capitalize(t_his)] [parse_zone(t)] is missing!</B>")
			continue
		if(t == BODY_ZONE_L_ARM || t == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(t == BODY_ZONE_R_ARM || t == BODY_ZONE_R_LEG)
			r_limbs_missing++

		damage_examine += "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>"

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		damage_examine += "[capitalize(t_He)] look[p_s()] all right now."
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		damage_examine += "[capitalize(t_He)] really keeps to the left."
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		damage_examine += "[capitalize(t_He)] [p_do()]n't seem all there."

	// Unique Limbs
	for(var/obj/item/bodypart/body_part as() in bodyparts)
		if(body_part.limb_id != (dna.species.examine_limb_id ? dna.species.examine_limb_id : dna.species.id))
			damage_examine += span_info("[capitalize(t_He)] [t_has] \an [body_part.name].")

	var/list/harm_descriptors = dna?.species.get_harm_descriptors()

	// Bleeding
	var/bleed_msg = harm_descriptors ? harm_descriptors?["bleed"] : "bleeding"
	if(is_bleeding())
		switch(get_bleed_rate())
			if(BLEED_DEEP_WOUND to INFINITY)
				damage_examine += span_warning("[src] is [bleed_msg] extremely quickly.")
			if(BLEED_RATE_MINOR to BLEED_DEEP_WOUND)
				damage_examine += span_warning("[src] is [bleed_msg] at a significant rate.")
			else
				damage_examine += span_warning("[src] has some minor [bleed_msg] which look like it will stop soon.")
	else if (is_bandaged())
		damage_examine += "[src] is [bleed_msg], but it is covered."

	// Damage
	var/brute_msg = harm_descriptors ? harm_descriptors?["brute"] : "bruising"
	var/burn_msg = harm_descriptors ? harm_descriptors?["burn"] : "burns"

	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY))
		var/current_damage = getBruteLoss()
		if(current_damage)
			switch (current_damage)
				if(1 to 25)
					damage_examine += "[t_He] [t_has] minor [brute_msg]."
				if(25 to 50)
					damage_examine += "[t_He] [t_has] <b>moderate</b> [brute_msg]!"
				if(50 to INFINITY)
					damage_examine += "<B>[t_He] [t_has] severe [brute_msg]!</B>"

		current_damage = getFireLoss()
		if(current_damage)
			switch (current_damage)
				if(1 to 25)
					damage_examine += "[t_He] [t_has] minor [burn_msg]."
				if(25 to 50)
					damage_examine += "[t_He] [t_has] <b>moderate</b> [burn_msg]!"
				if(50 to INFINITY)
					damage_examine += "<B>[t_He] [t_has] severe [burn_msg]!</B>"

	// Fire stacks
	if(fire_stacks > 0)
		damage_examine += "[capitalize(t_He)] [t_is] covered in something flammable."
	if(fire_stacks < 0)
		damage_examine += "[capitalize(t_He)] look[p_s()] a little soaked."

	// Pulled
	if(pulledby?.grab_state)
		damage_examine += "[capitalize(t_He)] [t_is] restrained by [pulledby]'s grip."

	// Nutrition
	if(nutrition < NUTRITION_LEVEL_STARVING - 50)
		damage_examine += "[capitalize(t_He)] [t_is] severely malnourished."
	else if(nutrition >= NUTRITION_LEVEL_FAT)
		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
			damage_examine += "[capitalize(t_He)] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy."
		else
			damage_examine += "[capitalize(t_He)] [t_is] quite chubby."
	switch(disgust)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			damage_examine += "[capitalize(t_He)] look[p_s()] a bit grossed out."
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			damage_examine += "[capitalize(t_He)] look[p_s()] really grossed out."
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			damage_examine += "[capitalize(t_He)] look[p_s()] extremely disgusted."

	// Blood
	if(blood_volume < BLOOD_VOLUME_SAFE)
		damage_examine += "[capitalize(t_He)] appear[p_s()] faint."

	// Teslium. THIS SHOULDN'T BE HERE!
	if(reagents.has_reagent(/datum/reagent/teslium, needs_metabolizing = TRUE))
		damage_examine += "[capitalize(t_He)] [t_is] emitting a gentle blue glow!"

	// Honestly, idk what this is
	if(islist(stun_absorption))
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && stun_absorption[i]["examine_message"])
				damage_examine += "[t_He] [t_is][stun_absorption[i]["examine_message"]]"

	// Drunk
	if(drunkenness && !skipface && !appears_dead)
		switch(drunkenness)
			if(11 to 21)
				damage_examine += "[capitalize(t_He)] [t_is] slightly flushed."
			if(21 to 41)
				damage_examine += "[capitalize(t_He)] [t_is] flushed."
			if(41 to 51)
				damage_examine += "[capitalize(t_He)] [t_is] quite flushed and [t_his] breath smells of alcohol."
			if(51 to 61)
				damage_examine += "[capitalize(t_He)] [t_is] very flushed and [t_his] movements jerky, with breath reeking of alcohol."
			if(61 to 91)
				damage_examine += "[capitalize(t_He)] look[p_s()] like a drunken mess."
			if(91 to INFINITY)
				damage_examine += "[capitalize(t_He)] [t_is] a shitfaced, slobbering wreck."

	// Empath examine
	if(ismob(user))
		if(HAS_TRAIT(user, TRAIT_EMPATH) && !appears_dead && (src != user))
			if(combat_mode)
				damage_examine += "[capitalize(t_He)] seem[p_s()] to be on guard."
			if(getOxyLoss() >= 10)
				damage_examine += "[capitalize(t_He)] seem[p_s()] winded."
			if(getToxLoss() >= 10)
				damage_examine += "[capitalize(t_He)] seem[p_s()] sickly."

			var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
			if(mood.sanity <= SANITY_DISTURBED)
				damage_examine += "[capitalize(t_He)] seem[p_s()] distressed."
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "empath", /datum/mood_event/sad_empath, src)
			if(is_blind())
				damage_examine += "[capitalize(t_He)] appear[p_s()] to be staring off into space."
			if(HAS_TRAIT(src, TRAIT_DEAF))
				damage_examine += "[capitalize(t_He)] appear[p_s()] to not be responding to noises."

	/*
	 * Misc Examine
	*/
	var/list/misc_examine = list()

	// Holy
	if(HAS_TRAIT(user, TRAIT_SPIRITUAL) && mind?.holy_role)
		misc_examine += "[capitalize(t_He)] [t_has] a holy aura about [t_him]."
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "religious_comfort", /datum/mood_event/religiously_comforted)

	// Misc
	if(!appears_dead)
		switch(stat)
			if(UNCONSCIOUS, HARD_CRIT)
				misc_examine += "[capitalize(t_He)] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep."
			if(SOFT_CRIT)
				misc_examine += "[capitalize(t_He)] [t_is] barely conscious."
			if(CONSCIOUS)
				if(HAS_TRAIT(src, TRAIT_DUMB))
					misc_examine += "[capitalize(t_He)] [t_has] a stupid expression on [t_his] face."
		if(getorgan(/obj/item/organ/brain))
			if(ai_controller?.ai_status == AI_STATUS_ON)
				misc_examine += span_deadsay("[capitalize(t_He)] do[t_es]n't appear to be [t_him]self.")
			if(!key)
				misc_examine += span_deadsay("[capitalize(t_He)] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.")
			else if(!client)
				misc_examine += "[capitalize(t_He)] [t_has] a blank, absent-minded stare and appears completely unresponsive to anything. [t_He] may snap out of it soon."

	// Visible traits
	var/trait_exam = common_trait_examine()
	if(!isnull(trait_exam))
		misc_examine += trait_exam



	/*
	 * Hud Examine
	*/
	var/list/hud_examine = list()

	var/perpname = get_face_name(get_id_name(""))
	if(perpname && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)))
		var/datum/record/crew/target_record = find_record(perpname, GLOB.manifest.general)
		if(target_record)
			hud_examine += "Rank: [target_record.rank]"

		// Health Hud
		if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
			var/list/detected_implants = list()
			for(var/obj/item/organ/cyberimp/cybernetic_implant in internal_organs)
				if(cybernetic_implant.status == ORGAN_ROBOTIC && !cybernetic_implant.syndicate_implant)
					detected_implants += cybernetic_implant.name
			if(length(detected_implants))
				hud_examine += "Detected cybernetic modifications: [english_list(detected_implants)]"

			if(target_record)
				hud_examine += "Physical status: <a href='byond://?src=[REF(src)];hud=m;physical_status=1;examine_time=[world.time]'>\[[target_record.physical_status]\]</a>"
				hud_examine += "Mental status: <a href='byond://?src=[REF(src)];hud=m;mental_status=1;examine_time=[world.time]'>\[[target_record.mental_status]\]</a>"

			hud_examine += "<a href='byond://?src=[REF(src)];hud=m;evaluation=1;examine_time=[world.time]'>\[Medical evaluation\]</a><br>"

			var/traitstring = get_quirk_string()
			if(traitstring)
				hud_examine += span_info("Detected physiological traits:\n[traitstring]")

		// Sec Hud
		if(HAS_TRAIT(user, TRAIT_SECURITY_HUD) && user.stat == CONSCIOUS && user != src)
			var/wanted_status = WANTED_NONE
			var/security_note = "None."

			if(target_record)
				wanted_status = target_record.wanted_status
				if(target_record.security_note)
					security_note = target_record.security_note

			if(ishuman(user))
				hud_examine += "Criminal status: <a href='byond://?src=[REF(src)];hud=s;status=1;examine_time=[world.time]'>\[[wanted_status]\]</a>"
			else
				hud_examine += "Criminal status: [target_record.wanted_status]"

			hud_examine += "Important Notes: [security_note]"
			hud_examine += "Security record: <a href='byond://?src=[REF(src)];hud=s;view=1;examine_time=[world.time]'>\[View\]</a>"
			if(ishuman(user))
				hud_examine += jointext(list("<a href='byond://?src=[REF(src)];hud=s;add_citation=1;examine_time=[world.time]'>\[Add citation\]</a>",
					"<a href='byond://?src=[REF(src)];hud=s;add_crime=1;examine_time=[world.time]'>\[Add crime\]</a>",
					"<a href='byond://?src=[REF(src)];hud=s;add_note=1;examine_time=[world.time]'>\[Add note\]</a>"), "")

	. = list(span_info("This is <EM>[!obscure_name ? name : "Unknown"][dna?.species && !skipface ? ", \an [dna.species.name]" : ""]</EM>!\n"))
	if(length(inherent_examine))
		. += span_notice(inherent_examine.Join("\n"))
	if(length(damage_examine))
		. += span_warning(damage_examine.Join("\n"))
	if(length(misc_examine))
		. += "\n" + span_notice(misc_examine.Join("\n"))
	if(length(hud_examine))
		. += "\n" + span_notice(hud_examine.Join("\n"))

/mob/living/proc/status_effect_examines(pronoun_replacement) //You can include this in any mob's examine() to show the examine texts of status effects!
	var/list/dat = list()
	if(!pronoun_replacement)
		pronoun_replacement = p_they(TRUE)
	for(var/V in status_effects)
		var/datum/status_effect/E = V
		var/effect_text = E.get_examine_text()
		if(effect_text)
			var/new_text = replacetext(effect_text, "SUBJECTPRONOUN", pronoun_replacement)
			new_text = replacetext(new_text, "[pronoun_replacement] is", "[pronoun_replacement] [p_are()]") //To make sure something become "They are" or "She is", not "They are" and "She are"
			dat += "[new_text]\n" //dat.Join("\n") doesn't work here, for some reason
	if(dat.len)
		return dat.Join()

/mob/proc/soul_departed()
	return !key && !get_ghost(FALSE, TRUE)

/mob/living/soul_departed()
	return getorgan(/obj/item/organ/brain) && !key && !get_ghost(FALSE, TRUE)
