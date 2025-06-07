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

	var/apparent_species
	if(dna?.species && !skipface)
		apparent_species = ", \an [dna.species.name]"
	. = list(span_info("This is <EM>[!obscure_name ? name : "Unknown"][apparent_species]</EM>!"))

	if(obscure_examine)
		return list(span_warning("You're struggling to make out any details..."))

	//Psychic soul stuff
	if(HAS_TRAIT(user, TRAIT_PSYCHIC_SENSE) && mind)
		to_chat(user, "[span_notice("[src] has a <span class='[GLOB.soul_glimmer_cfc_list[mind.soul_glimmer]]'>[mind.soul_glimmer]")] presence.")

	//uniform
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING) && !(w_uniform.item_flags & EXAMINE_SKIP))
		//accessory
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.attached_accessory)
				accessory_msg += " with [icon2html(U.attached_accessory, user)] \a [U.attached_accessory]"

		. += "[t_He] [t_is] wearing [w_uniform.get_examine_string(user)][accessory_msg]."
	//head
	if(head && !(head.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head."
	//suit/armor
	if(wear_suit && !(wear_suit.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_suit.get_examine_string(user)]."
		//suit/armor storage
		if(s_store && !(obscured & ITEM_SLOT_SUITSTORE) && !(s_store.item_flags & EXAMINE_SKIP))
			. += "[t_He] [t_is] carrying [s_store.get_examine_string(user)] on [t_his] [wear_suit.name]."
	//back
	if(back && !(back.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT) && !(I.item_flags & EXAMINE_SKIP))
			. += "[t_He] [t_is] holding [I.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(I))]."

	var/datum/component/forensics/FR = GetComponent(/datum/component/forensics)
	//gloves
	if(gloves && !(obscured & ITEM_SLOT_GLOVES) && !(gloves.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [gloves.get_examine_string(user)] on [t_his] hands."
	else if(FR && length(FR.blood_DNA))
		if(num_hands)
			. += span_warning("[t_He] [t_has] [num_hands > 1 ? "" : "a"] blood-stained hand[num_hands > 1 ? "s" : ""]!")

	//belt
	if(belt && !(belt.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [belt.get_examine_string(user)] about [t_his] waist."

	//shoes
	if(shoes && !(obscured & ITEM_SLOT_FEET) && !(shoes.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [shoes.get_examine_string(user)] on [t_his] feet."

	//mask
	if(wear_mask && !(obscured & ITEM_SLOT_MASK) && !(wear_mask.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [wear_mask.get_examine_string(user)] on [t_his] face."

	if(wear_neck && !(obscured & ITEM_SLOT_NECK) && !(wear_neck.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck."

	//eyes
	if(!(obscured & ITEM_SLOT_EYES))
		if(glasses && !(glasses.item_flags & EXAMINE_SKIP))
			. += "[t_He] [t_has] [glasses.get_examine_string(user)] covering [t_his] eyes."
		else if(eye_color == BLOODCULT_EYE && iscultist(src) && HAS_TRAIT(src, CULT_EYES))
			. += span_warning("<B>[t_His] eyes are glowing an unnatural red!</B>")

	//ears
	if(ears && !(obscured & ITEM_SLOT_EARS) && !(ears.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_has] [ears.get_examine_string(user)] on [t_his] ears."

	//ID
	if(wear_id && !(wear_id.item_flags & EXAMINE_SKIP))
		. += "[t_He] [t_is] wearing [wear_id.get_examine_string(user)]."

	//Status effects
	. += status_effect_examines()

	//Jitters
	switch(jitteriness)
		if(300 to INFINITY)
			. += span_warning("<B>[t_He] [t_is] convulsing violently!</B>")
		if(200 to 300)
			. += span_warning("[t_He] [t_is] extremely jittery.")
		if(100 to 200)
			. += span_warning("[t_He] [t_is] twitching ever so slightly.")

	var/appears_dead = FALSE
	var/just_sleeping = FALSE
	if(stat == DEAD || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		appears_dead = TRUE

		if(isliving(user) && HAS_TRAIT(user, TRAIT_NAIVE))
			just_sleeping = TRUE

		if(!just_sleeping)
			if(suiciding)
				. += span_warning("[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.")
			if(ishellbound())
				. += span_warning("[t_His] soul seems to have been ripped out of [t_his] body. Revival is impossible.")
			. += ""
			if(soul_departed())
				. += span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life and [t_his] soul has departed...")
			else if(!client && key)
				. += span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life and [t_his] soul seems distant, it may return soon...")
			else
				. += span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life...")

	if(get_bodypart(BODY_ZONE_HEAD) && !get_organ_by_type(/obj/item/organ/brain))
		. += span_deadsay("It appears that [t_his] brain is missing.")

	var/temp = getBruteLoss() //no need to calculate each of these twice

	var/list/msg = list("<span class='warning'>")
	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/list/disabled = list()

	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP.bodypart_disabled)
			disabled += BP
		missing -= BP.body_zone
		for(var/obj/item/I in BP.embedded_objects)
			if(I.isEmbedHarmless())
				msg += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] stuck to [t_his] [BP.name]!</B>\n"
			else
				msg += "<B>[t_He] [t_has] [icon2html(I, user)] \a [I] embedded in [t_his] [BP.name]!</B>\n"

	for(var/X in disabled)
		var/obj/item/bodypart/body_part = X
		var/damage_text
		/*
		if(HAS_TRAIT(body_part, TRAIT_DISABLED_BY_WOUND))
			continue // skip if it's disabled by a wound (cuz we'll be able to see the bone sticking out!)
		*/
		if(!(body_part.get_damage(include_stamina = FALSE) >= body_part.max_damage)) //we don't care if it's stamcritted
			damage_text = "limp and lifeless"
		else
			damage_text = (body_part.brute_dam >= body_part.burn_dam) ? body_part.heavy_brute_msg : body_part.heavy_burn_msg
		msg += "<B>[capitalize(t_his)] [body_part.name] is [damage_text]!</B>\n"

	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "<span class='deadsay'><B>[t_His] [parse_zone(t)] is missing!</B><span class='warning'>\n"
			continue
		if(t == BODY_ZONE_L_ARM || t == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(t == BODY_ZONE_R_ARM || t == BODY_ZONE_R_LEG)
			r_limbs_missing++

		msg += "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>\n"

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		msg += "[t_He] look[p_s()] all right now.\n"
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		msg += "[t_He] really keeps to the left.\n"
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		msg += "[t_He] [p_do()]n't seem all there.\n"


	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP.limb_id != (dna.species.examine_limb_id ? dna.species.examine_limb_id : dna.species.id))
			msg += "[span_info("[t_He] [t_has] \an [BP.name].")]\n"

	var/list/harm_descriptors = dna?.species.get_harm_descriptors()
	var/brute_msg = harm_descriptors?["brute"]
	var/burn_msg = harm_descriptors?["burn"]
	var/bleed_msg = harm_descriptors?["bleed"]

	brute_msg = brute_msg ? brute_msg : "bruising"
	burn_msg = burn_msg ? burn_msg : "burns"
	bleed_msg = bleed_msg ? bleed_msg : "bleeding"

	if (is_bleeding())
		switch (get_bleed_rate())
			if (BLEED_DEEP_WOUND to INFINITY)
				msg += "[span_warning("[src] is [bleed_msg] extremely quickly.")]\n"
			if (BLEED_RATE_MINOR to BLEED_DEEP_WOUND)
				msg += "[span_warning("[src] is [bleed_msg] at a significant rate.")]\n"
			else
				msg += "[span_warning("[src] has some minor [bleed_msg] which look like it will stop soon.")]\n"
	else if (is_bandaged())
		msg += "[src] is [bleed_msg], but it is covered.\n"

	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor [brute_msg].\n"
			else if(temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> [brute_msg]!\n"
			else
				msg += "<B>[t_He] [t_has] severe [brute_msg]!</B>\n"

		temp = getFireLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_has] minor [burn_msg].\n"
			else if (temp < 50)
				msg += "[t_He] [t_has] <b>moderate</b> [burn_msg]!\n"
			else
				msg += "<B>[t_He] [t_has] severe [burn_msg]!</B>\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[p_s()] a little soaked.\n"


	if(pulledby?.grab_state)
		msg += "[t_He] [t_is] restrained by [pulledby]'s grip.\n"

	if(nutrition < NUTRITION_LEVEL_STARVING - 50)
		msg += "[t_He] [t_is] severely malnourished.\n"
	else if(nutrition >= NUTRITION_LEVEL_FAT)
		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
			msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
		else
			msg += "[t_He] [t_is] quite chubby.\n"
	switch(disgust)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			msg += "[t_He] look[p_s()] a bit grossed out.\n"
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			msg += "[t_He] look[p_s()] really grossed out.\n"
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			msg += "[t_He] look[p_s()] extremely disgusted.\n"

	if(blood_volume < BLOOD_VOLUME_SAFE)
		msg += "[t_He] appear[p_s()] faint.\n"

	if(reagents.has_reagent(/datum/reagent/teslium, needs_metabolizing = TRUE))
		msg += "[t_He] [t_is] emitting a gentle blue glow!\n"

	if(islist(stun_absorption))
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && stun_absorption[i]["examine_message"])
				msg += "[t_He] [t_is][stun_absorption[i]["examine_message"]]\n"

	if(just_sleeping)
		msg += "[user.p_they(TRUE)] isn't responding to anything around [user.p_them()] and seems to be asleep.\n"

	if(drunkenness && !skipface && !appears_dead) //Drunkenness
		switch(drunkenness)
			if(11 to 21)
				msg += "[t_He] [t_is] slightly flushed.\n"
			if(21.01 to 41) //.01s are used in case drunkenness ends up to be a small decimal
				msg += "[t_He] [t_is] flushed.\n"
			if(41.01 to 51)
				msg += "[t_He] [t_is] quite flushed and [t_his] breath smells of alcohol.\n"
			if(51.01 to 61)
				msg += "[t_He] [t_is] very flushed and [t_his] movements jerky, with breath reeking of alcohol.\n"
			if(61.01 to 91)
				msg += "[t_He] look[p_s()] like a drunken mess.\n"
			if(91.01 to INFINITY)
				msg += "[t_He] [t_is] a shitfaced, slobbering wreck.\n"

	if(ismob(user))
		if(HAS_TRAIT(user, TRAIT_EMPATH) && !appears_dead && (src != user))
			if (combat_mode)
				msg += "[t_He] seem[p_s()] to be on guard.\n"
			if (getOxyLoss() >= 10)
				msg += "[t_He] seem[p_s()] winded.\n"
			if (getToxLoss() >= 10)
				msg += "[t_He] seem[p_s()] sickly.\n"
			var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
			if(mood.sanity <= SANITY_DISTURBED)
				msg += "[t_He] seem[p_s()] distressed.\n"
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "empath", /datum/mood_event/sad_empath, src)
			if (is_blind())
				msg += "[t_He] appear[p_s()] to be staring off into space.\n"
			if (HAS_TRAIT(src, TRAIT_DEAF))
				msg += "[t_He] appear[p_s()] to not be responding to noises.\n"

	msg += "</span>"

	if(HAS_TRAIT(user, TRAIT_SPIRITUAL) && mind?.holy_role)
		msg += "[t_He] [t_has] a holy aura about [t_him].\n"
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "religious_comfort", /datum/mood_event/religiously_comforted)

	if(!appears_dead)
		switch(stat)
			if(UNCONSCIOUS, HARD_CRIT)
				msg += "[t_He] [t_is]n't responding to anything around [t_him] and seem[p_s()] to be asleep.\n"
			if(SOFT_CRIT)
				msg += "[t_He] [t_is] barely conscious.\n"
			if(CONSCIOUS)
				if(HAS_TRAIT(src, TRAIT_DUMB))
					msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"
		if(get_organ_by_type(/obj/item/organ/brain))
			if(ai_controller?.ai_status == AI_STATUS_ON)
				msg += "[span_deadsay("[t_He] do[t_es]n't appear to be [t_him]self.")]\n"
			if(!key)
				msg += "[span_deadsay("[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.")]\n"
			else if(!client)
				msg += "[t_He] [t_has] a blank, absent-minded stare and appears completely unresponsive to anything. [t_He] may snap out of it soon.\n"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			. += span_warning("[t_He] [t_is] restrained with cable!")
		else
			. += span_warning("[t_He] [t_is] handcuffed with [handcuffed]!")

	//legcuffed?
	if(legcuffed)
		. += span_warning("[t_He] [t_is] legcuffed with [legcuffed]!")

	if (length(msg))
		. += span_warning("[msg.Join("")]")

	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	var/traitstring = get_quirk_string()

	var/perpname = get_face_name(get_id_name(""))
	if(perpname && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)))
		var/datum/record/crew/target_record = find_record(perpname, GLOB.manifest.general)
		if(target_record)
			. += "[span_deptradio("Rank:")] [target_record.rank]"
		if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
			var/list/cyberimp_detect = list()
			for(var/obj/item/organ/cyberimp/CI in internal_organs)
				if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
					cyberimp_detect += CI.name
			if(length(cyberimp_detect))
				. += "Detected cybernetic modifications: [english_list(cyberimp_detect)]"
			if(target_record)
				var/physical_status = target_record.physical_status
				. += "Physical status: <a href='byond://?src=[REF(src)];hud=m;physical_status=1;examine_time=[world.time]'>\[[physical_status]\]</a>"
				var/mental_status = target_record.mental_status
				. += "Mental status: <a href='byond://?src=[REF(src)];hud=m;mental_status=1;examine_time=[world.time]'>\[[mental_status]\]</a>"
			target_record = find_record(perpname, GLOB.manifest.general)
			. += "<a href='byond://?src=[REF(src)];hud=m;evaluation=1;examine_time=[world.time]'>\[Medical evaluation\]</a><br>"
			if(traitstring)
				. += span_info("Detected physiological traits:\n[traitstring]")

		if(HAS_TRAIT(user, TRAIT_SECURITY_HUD))
			if((user.stat == CONSCIOUS || isobserver(user)) && user != src)
				var/wanted_status = WANTED_NONE
				var/security_note = "None."

				target_record = find_record(perpname, GLOB.manifest.general)
				if(target_record)
					wanted_status = target_record.wanted_status
					if(target_record.security_note)
						security_note = target_record.security_note

				if(ishuman(user))
					. += "[span_deptradio("Criminal status:")] <a href='byond://?src=[REF(src)];hud=s;status=1;examine_time=[world.time]'>\[[wanted_status]\]</a>"
				else
					. += "[span_deptradio("Criminal status:")] [wanted_status]"
				. += "<span class='deptradio'>Important Notes: [security_note]"
				. += "[span_deptradio("Security record:")] <a href='byond://?src=[REF(src)];hud=s;view=1;examine_time=[world.time]'>\[View\]</a>"
				if(ishuman(user))
					. += jointext(list("<a href='byond://?src=[REF(src)];hud=s;add_citation=1;examine_time=[world.time]'>\[Add citation\]</a>",
						"<a href='byond://?src=[REF(src)];hud=s;add_crime=1;examine_time=[world.time]'>\[Add crime\]</a>",
						"<a href='byond://?src=[REF(src)];hud=s;add_note=1;examine_time=[world.time]'>\[Add note\]</a>"), "")
	else if(isobserver(user) && traitstring)
		. += span_info("<b>Traits:</b> [traitstring]")

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
	return get_organ_by_type(/obj/item/organ/brain) && !key && !get_ghost(FALSE, TRUE)
