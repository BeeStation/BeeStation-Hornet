
/mob/living/carbon/get_eye_protection()
	. = ..()
	var/obj/item/organ/eyes/E = get_organ_slot(ORGAN_SLOT_EYES)
	if(!E)
		return INFINITY //Can't get flashed without eyes
	. += E.flash_protect
	if(isclothing(head)) //Adds head protection
		. += head.flash_protect
	if(isclothing(glasses)) //Glasses
		. += glasses.flash_protect
	if(isclothing(wear_mask)) //Mask
		. += wear_mask.flash_protect

/mob/living/carbon/get_ear_protection()
	. = ..()
	var/obj/item/organ/ears/E = get_organ_slot(ORGAN_SLOT_EARS)
	if(!E)
		return INFINITY
	. += E.bang_protect
	if(isclothing(head)) //Adds head protection
		. += head.bang_protect
	if(isclothing(ears)) //ear slot
		. += ears.bang_protect
	else if(istype(ears, /obj/item/radio/headset))
		var/obj/item/radio/headset/headset_in_ear = ears
		. += headset_in_ear.bang_protect

/mob/living/carbon/is_mouth_covered(head_only = 0, mask_only = 0)
	if( (!mask_only && head && (head.flags_cover & HEADCOVERSMOUTH)) || (!head_only && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH)) )
		return TRUE

/mob/living/carbon/is_eyes_covered(check_glasses = TRUE, check_head = TRUE, check_mask = TRUE)
	if(check_head && head && (head.flags_cover & HEADCOVERSEYES))
		return head
	if(check_mask && wear_mask && (wear_mask.flags_cover & MASKCOVERSEYES))
		return wear_mask
	if(check_glasses && glasses && (glasses.flags_cover & GLASSESCOVERSEYES))
		return glasses

/mob/living/carbon/check_projectile_dismemberment(obj/projectile/P, def_zone)
	var/obj/item/bodypart/affecting = get_bodypart(def_zone)
	if(affecting && !(affecting.bodypart_flags & BODYPART_UNREMOVABLE) && affecting.get_damage() >= (affecting.max_damage - P.dismemberment))
		affecting.dismember(P.damtype)

/mob/living/carbon/proc/can_catch_item(skip_throw_mode_check)
	. = FALSE
	if(!skip_throw_mode_check && !throw_mode)
		return
	if(get_active_held_item())
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	return TRUE

/mob/living/carbon/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(!skipcatch && can_catch_item() && isitem(AM))
		var/obj/item/I = AM
		if(isturf(I.loc))
			I.attack_hand(src)
			if(get_active_held_item() == I) //if our attack_hand() picks up the item...
				visible_message(span_warning("[src] catches [I]!"), \
						span_userdanger("You catch [I] in mid-air!"))
				throw_mode_off(THROW_MODE_TOGGLE)
				return TRUE
	..(AM, skipcatch, hitpush, blocked, throwingdatum)


/mob/living/carbon/attacked_by(obj/item/I, mob/living/user)
	var/obj/item/bodypart/affecting
	affecting = get_bodypart(check_zone(user.get_combat_bodyzone(src)))
	if(!affecting) //missing limb? we select the first bodypart (you can never have zero, because of chest)
		affecting = bodyparts[1]
	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)
	send_item_attack_message(I, user, parse_zone(affecting.body_zone))
	if (I.bleed_force)
		var/armour_block = run_armor_check(affecting, BLEED, armour_penetration = I.armour_penetration, silent = (I.force > 0))
		var/hit_amount = (100 - armour_block) / 100
		add_bleeding(I.bleed_force * hit_amount)
	if(I.force)
		var/limb_damage = affecting.get_damage() //We need to save this for later to simplify dismemberment
		var/armour_block = run_armor_check(affecting, MELEE, armour_penetration = I.armour_penetration)
		apply_damage(I.force, I.damtype, affecting, armour_block)
		if(I.damtype == BRUTE && (IS_ORGANIC_LIMB(affecting)))
			if(I.get_sharpness() || I.force >= 10)
				I.add_mob_blood(src)
				var/turf/location = get_turf(src)
				add_splatter_floor(location)
				if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(src)
				if(affecting.body_zone == BODY_ZONE_HEAD)
					if(wear_mask)
						wear_mask.add_mob_blood(src)
						update_worn_mask()
					if(wear_neck)
						wear_neck.add_mob_blood(src)
						update_worn_neck()
					if(head)
						head.add_mob_blood(src)
						update_worn_head()
		else if (I.damtype == BURN && is_bleeding() && IS_ORGANIC_LIMB(affecting))
			cauterise_wounds(AMOUNT_TO_BLEED_INTENSITY(I.force / 3))
			to_chat(src, span_userdanger("The heat from [I] cauterizes your bleeding!"))
			playsound(src, 'sound/surgery/cautery2.ogg', 70)

		var/dismember_limb = FALSE
		var/weapon_sharpness = I.get_sharpness()

		if(((HAS_TRAIT(src, TRAIT_EASYDISMEMBER) && limb_damage) || (weapon_sharpness == SHARP_DISMEMBER_EASY)) && prob(I.force))
			dismember_limb = TRUE
			//Easy dismemberment on the mob allows even blunt weapons to potentially delimb, but only if the limb is already damaged
			//Certain weapons are so sharp/strong they have a chance to cleave right through a limb without following the normal restrictions

		else if(weapon_sharpness > SHARP || (weapon_sharpness == SHARP && stat == DEAD))
			//Delimbing cannot normally occur with blunt weapons
			//You also aren't cutting someone's arm off with a scalpel unless they're already dead

			if(limb_damage >= affecting.max_damage)
				dismember_limb = TRUE
				//You can only cut a limb off if it is already damaged enough to be fully disabled

		if(dismember_limb && ((affecting.body_zone != BODY_ZONE_HEAD && affecting.body_zone != BODY_ZONE_CHEST) || stat != CONSCIOUS) && affecting.dismember(I.damtype))
			I.add_mob_blood(src)
			playsound(get_turf(src), I.get_dismember_sound(), 80, 1)

		return TRUE //successful attack

/mob/living/carbon/send_item_attack_message(obj/item/I, mob/living/user, hit_area, obj/item/bodypart/hit_bodypart)
	if(!I.force && !length(I.attack_verb_simple) && !length(I.attack_verb_continuous))
		return
	var/message_verb_continuous = length(I.attack_verb_continuous) ? "[pick(I.attack_verb_continuous)]" : "attacks"
	var/message_verb_simple = length(I.attack_verb_simple) ? "[pick(I.attack_verb_simple)]" : "attack"

	var/extra_wound_details = ""
	/*
	if(I.damtype == BRUTE && hit_bodypart.can_dismember())
		var/mangled_state = hit_bodypart.get_mangled_state()
		var/bio_state = get_biological_state()
		if(mangled_state == BODYPART_MANGLED_BOTH)
			extra_wound_details = ", threatening to sever it entirely"
		else if((mangled_state == BODYPART_MANGLED_FLESH && I.get_sharpness()) || (mangled_state & BODYPART_MANGLED_BONE && bio_state == BIO_JUST_BONE))
			extra_wound_details = ", [I.get_sharpness() == SHARP ? "slicing" : "piercing"] through to the bone"
		else if((mangled_state == BODYPART_MANGLED_BONE && I.get_sharpness()) || (mangled_state & BODYPART_MANGLED_FLESH && bio_state == BIO_JUST_FLESH))
			extra_wound_details = ", [I.get_sharpness() == SHARP ? "slicing" : "piercing"] at the remaining tissue"
	*/

	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message_spectator = "[src] [message_verb_continuous][message_hit_area] with [I][extra_wound_details]!"
	var/attack_message_victim = "You're [message_verb_continuous][message_hit_area] with [I][extra_wound_details]!"
	var/attack_message_attacker = "You [message_verb_simple] [src][message_hit_area] with [I]!"
	if(user in viewers(src, null))
		attack_message_spectator = "[user] [message_verb_continuous] [src][message_hit_area] with [I][extra_wound_details]!"
		attack_message_victim = "[user] [message_verb_continuous] you[message_hit_area] with [I][extra_wound_details]!"
	if(user == src)
		attack_message_victim = "You [message_verb_simple] yourself[message_hit_area] with [I][extra_wound_details]!"
	visible_message(span_danger("[attack_message_spectator]"),\
		span_userdanger("[attack_message_victim]"), null, COMBAT_MESSAGE_RANGE, user)
	if(user != src)
		to_chat(user, span_danger("[attack_message_attacker]"))
	return TRUE


/mob/living/carbon/attack_drone(mob/living/simple_animal/drone/user)
	return //so we don't call the carbon's attack_hand().

/mob/living/carbon/attack_drone_secondary(mob/living/simple_animal/drone/user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/carbon/attack_hand(mob/living/carbon/human/user, modifiers)

	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE

	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
			user.ContactContractDisease(D)

	for(var/thing in user.diseases)
		var/datum/disease/D = thing
		if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
			ContactContractDisease(D)

	for(var/datum/surgery/S in surgeries)
		if(body_position == LYING_DOWN || !S.lying_required)
			if(!user.combat_mode)
				if(S.next_step(user, modifiers))
					return TRUE

	return FALSE


/mob/living/carbon/attack_paw(mob/living/carbon/human/M, modifiers)

	if(try_inject(M, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		for(var/thing in diseases)
			var/datum/disease/D = thing
			if((D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN) && prob(85))
				M.ContactContractDisease(D)

	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
			ContactContractDisease(D)

	if(!M.combat_mode)
		help_shake_act(M)
		return FALSE

	if(..() && can_inject(M, get_combat_bodyzone(), INJECT_CHECK_PENETRATE_THICK | INJECT_TRY_SHOW_ERROR_MESSAGE)) //successful monkey bite.
		for(var/thing in M.diseases)
			var/datum/disease/D = thing
			ForceContractDisease(D)
		return 1


/mob/living/carbon/attack_slime(mob/living/simple_animal/slime/M, list/modifiers)
	if(..()) //successful slime attack
		if(M.powerlevel > 0)
			M.powerlevel--
			visible_message(span_danger("The [M.name] has shocked [src]!"), \
				span_userdanger("The [M.name] has shocked you!"))
			do_sparks(5, TRUE, src)
			Knockdown(M.powerlevel*5)
			set_stutter_if_lower(M.powerlevel * 5)
			if(M.transformeffects & SLIME_EFFECT_ORANGE)
				adjust_fire_stacks(2)
				ignite_mob()
			adjustFireLoss(M.powerlevel * 3)
			updatehealth()
		return TRUE

/mob/living/carbon/proc/dismembering_strike(mob/living/attacker, dam_zone)
	if(!attacker.limb_destroyer)
		return dam_zone
	var/obj/item/bodypart/affecting
	if(dam_zone && attacker.client)
		affecting = get_bodypart(ran_zone(dam_zone))
	else
		var/list/things_to_ruin = shuffle(bodyparts.Copy())
		for(var/B in things_to_ruin)
			var/obj/item/bodypart/bodypart = B
			if(bodypart.body_zone == BODY_ZONE_HEAD || bodypart.body_zone == BODY_ZONE_CHEST)
				continue
			if(!affecting || ((affecting.get_damage() / affecting.max_damage) < (bodypart.get_damage() / bodypart.max_damage)))
				affecting = bodypart
	if(affecting)
		dam_zone = affecting.body_zone
		if(affecting.get_damage() >= affecting.max_damage)
			affecting.dismember()
			return null
		return affecting.body_zone
	return dam_zone

/**
 * Attempt to disarm the target mob.
 * Will shove the target mob back, and drop them if they're in front of something dense
 * or another carbon.
 * src is the attacker
*/
/mob/living/carbon/proc/disarm(mob/living/carbon/target)
	do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	if (ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.w_uniform?.add_fingerprint(src)

	SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, src, get_combat_bodyzone(target))
	target.disarm_effect(src)

/mob/living/carbon/is_shove_knockdown_blocked() //If you want to add more things that block shove knockdown, extend this
	for (var/obj/item/clothing/clothing in get_equipped_items())
		if(clothing.clothing_flags & BLOCKS_SHOVE_KNOCKDOWN)
			return TRUE
	return FALSE

/mob/living/carbon/blob_act(obj/structure/blob/B)
	if (stat == DEAD)
		return
	else
		show_message(span_userdanger("The blob attacks!"))
		adjustBruteLoss(10)

/mob/living/carbon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/X in internal_organs)
		var/obj/item/organ/O = X
		O.emp_act(severity)

///Adds to the parent by also adding functionality to propagate shocks through pulling and doing some fluff effects.
/mob/living/carbon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	. = ..()
	if(!.)
		return
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags)
	//Propagation through pulling, fireman carry
	if(!(flags & SHOCK_ILLUSION))
		var/list/shocking_queue = list()
		if(iscarbon(pulling) && source != pulling)
			shocking_queue += pulling
		if(iscarbon(pulledby) && source != pulledby)
			shocking_queue += pulledby
		if(iscarbon(buckled) && source != buckled)
			shocking_queue += buckled
		for(var/mob/living/carbon/carried in buckled_mobs)
			if(source != carried)
				shocking_queue += carried
		//Found our victims, now lets shock them all
		for(var/victim in shocking_queue)
			var/mob/living/carbon/C = victim
			C.electrocute_act(shock_damage*0.75, src, 1, flags)
	//Stun
	var/should_stun = (!(flags & SHOCK_TESLA) || siemens_coeff > 0.5) && !(flags & SHOCK_NOSTUN)
	if(should_stun)
		Paralyze(40)
	//Jitter and other fluff.
	do_jitter_animation(300)
	adjust_timed_status_effect(20 SECONDS, /datum/status_effect/jitter)
	adjust_stutter(4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(secondary_shock), should_stun), 2 SECONDS)
	return shock_damage

///Called slightly after electrocute act to apply a secondary stun.
/mob/living/carbon/proc/secondary_shock(should_stun)
	if(should_stun)
		Paralyze(60)

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(on_fire)
		to_chat(M, span_warning("You can't put [p_them()] out with just your bare hands!"))
		return

	if(M == src && check_self_for_injuries())
		return

	if(body_position == LYING_DOWN)
		if(buckled)
			to_chat(M, span_warning("You need to unbuckle [src] first to do that!"))
			return
		M.visible_message(span_notice("[M] shakes [src] trying to get [p_them()] up!"), \
						span_notice("You shake [src] trying to get [p_them()] up!"))
	else if(M.is_zone_selected(BODY_ZONE_CHEST))
		M.visible_message(span_notice("[M] hugs [src] to make [p_them()] feel better!"), \
					span_notice("You hug [src] to make [p_them()] feel better!"))

		// Warm them up with hugs
		share_bodytemperature(M)
		if(bodytemperature > M.bodytemperature)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "hug", /datum/mood_event/warmhug, src) // Hugger got a warm hug
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "hug", /datum/mood_event/hug) // Reciver always gets a mood for being hugged
		else
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "hug", /datum/mood_event/warmhug, M) // You got a warm hug

		// Let people know if they hugged someone really warm or really cold
		if(M.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT || M.has_status_effect(/datum/status_effect/vampire_sol))
			to_chat(src, span_warning("It feels like [M] is over heating as [M.p_they()] hug[M.p_s()] you."))
		else if(M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			to_chat(src, span_warning("It feels like [M] is freezing as [M.p_they()] hug[M.p_s()] you."))

		if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT || has_status_effect(/datum/status_effect/vampire_sol))
			to_chat(M, span_warning("It feels like [src] is over heating as you hug [p_them()]."))
		else if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			to_chat(M, span_warning("It feels like [src] is freezing as you hug [p_them()]."))

		if(HAS_TRAIT(M, TRAIT_FRIENDLY))
			var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
			if (mood.sanity >= SANITY_GREAT)
				SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "friendly_hug", /datum/mood_event/besthug, M)
			else if (mood.sanity >= SANITY_DISTURBED)
				SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "friendly_hug", /datum/mood_event/betterhug, M)
		for(var/datum/brain_trauma/trauma in M.get_traumas())
			trauma.on_hug(M, src)
	else if(M.is_zone_selected(BODY_ZONE_HEAD))
		M.visible_message(span_notice("[M] pats [src] on the head."), \
					span_notice("You pat [src] on the head."))
		for(var/datum/brain_trauma/trauma in M.get_traumas())
			trauma.on_hug(M, src)
	else if((M.is_zone_selected(BODY_ZONE_L_ARM)) || (M.is_zone_selected(BODY_ZONE_R_ARM)))
		if(!get_bodypart(check_zone(M.get_combat_bodyzone(src))))
			to_chat(M, span_warning("[src] does not have a [M.get_combat_bodyzone(src) == BODY_ZONE_L_ARM ? "left" : "right"] arm!"))
		else
			M.visible_message(span_notice("[M] shakes [src]'s hand."), \
						span_notice("You shake [src]'s hand."))
	else if(M.is_zone_selected(BODY_ZONE_PRECISE_GROIN, precise_only = TRUE))
		to_chat(M, span_warning("ERP is not allowed on this server!"))
	AdjustStun(-60)
	AdjustKnockdown(-60)
	AdjustUnconscious(-60)
	AdjustSleeping(-100)
	AdjustParalyzed(-60)
	AdjustImmobilized(-60)
	set_resting(FALSE)
	if(body_position != STANDING_UP && !resting && !buckled && !HAS_TRAIT(src, TRAIT_FLOORED))
		get_up(TRUE)

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

/// Check ourselves to see if we've got any shrapnel, return true if we do. This is a much simpler version of what humans do, we only indicate we're checking ourselves if there's actually shrapnel
/mob/living/carbon/proc/check_self_for_injuries()
	if(stat >= UNCONSCIOUS)
		return

	var/embeds = FALSE
	for(var/X in bodyparts)
		var/obj/item/bodypart/LB = X
		for(var/obj/item/I in LB.embedded_objects)
			if(!embeds)
				embeds = TRUE
				// this way, we only visibly try to examine ourselves if we have something embedded, otherwise we'll still hug ourselves :)
				visible_message(span_notice("[src] examines [p_them()]self."), \
					span_notice("You check yourself for shrapnel."))
			if(I.isEmbedHarmless())
				to_chat(src, "\t <a href='byond://?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]' class='warning'>There is \a [I] stuck to your [LB.name]!</a>")
			else
				to_chat(src, "\t <a href='byond://?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]' class='warning'>There is \a [I] embedded in your [LB.name]!</a>")

	return embeds

/mob/living/carbon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	if(NOFLASH in dna?.species?.species_traits)
		return
	var/obj/item/organ/eyes/eyes = get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes || (!override_blindness_check && HAS_TRAIT(src, TRAIT_BLIND))) //can't flash what can't see!
		return
	. = ..()

	var/damage = intensity - get_eye_protection()
	if(.) // we've been flashed
		if(visual)
			return

		if (damage == 1)
			to_chat(src, span_warning("Your eyes sting a little."))
			if(prob(40))
				eyes.apply_organ_damage(1)

		else if (damage == 2)
			to_chat(src, span_warning("Your eyes burn."))
			eyes.apply_organ_damage(rand(2, 4))

		else if( damage >= 3)
			to_chat(src, span_warning("Your eyes itch and burn severely!"))
			eyes.apply_organ_damage(rand(12, 16))

		if(eyes.damage > 10)
			adjust_blindness(damage)
			set_eye_blur_if_lower(damage * rand(6 SECONDS, 12 SECONDS))

			if(eyes.damage > 20)
				if(prob(eyes.damage - 20))
					if(!HAS_TRAIT(src, TRAIT_NEARSIGHT))
						to_chat(src, span_warning("Your eyes start to burn badly!"))
					become_nearsighted(EYE_DAMAGE)

				else if(prob(eyes.damage - 25))
					if(!is_blind())
						to_chat(src, span_warning("You can't see anything!"))
					eyes.apply_organ_damage(eyes.maxHealth)

			else
				to_chat(src, span_warning("Your eyes are really starting to hurt. This can't be good for you!"))
		return 1
	else if(damage == 0) // just enough protection
		if(prob(20))
			to_chat(src, span_notice("Something bright flashes in the corner of your vision!"))

/mob/living/carbon/soundbang_act(intensity = 1, stun_pwr = 20, damage_pwr = 5, deafen_pwr = 15)
	var/list/reflist = list(intensity) // Need to wrap this in a list so we can pass a reference
	SEND_SIGNAL(src, COMSIG_CARBON_SOUNDBANG, reflist)
	intensity = reflist[1]
	var/ear_safety = get_ear_protection()
	var/obj/item/organ/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
	var/effect_amount = intensity - ear_safety
	if(effect_amount > 0)
		if(stun_pwr)
			if(!ears.deaf)
				Paralyze((stun_pwr*effect_amount)*0.1)
			Knockdown(stun_pwr*effect_amount)

		if(ears && (deafen_pwr || damage_pwr))
			var/ear_damage = damage_pwr * effect_amount
			var/deaf = deafen_pwr * effect_amount
			ears.adjustEarDamage(ear_damage,deaf)

			if(ears.damage >= 15)
				to_chat(src, span_warning("Your ears start to ring badly!"))
				if(prob(ears.damage - 5))
					to_chat(src, span_userdanger("You can't hear anything!"))
					// Makes you deaf, enough that you need a proper source of healing, it won't self heal
					// you need earmuffs, inacusiate, or replacement
					ears.set_organ_damage(ears.maxHealth)
			else if(ears.damage >= 5)
				to_chat(src, span_warning("Your ears start to ring!"))
			SEND_SOUND(src, sound('sound/weapons/flash_ring.ogg',0,1,0,250))
		return effect_amount //how soundbanged we are


/mob/living/carbon/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/hit_clothes
		if(wear_mask)
			hit_clothes = wear_mask
		if(wear_neck)
			hit_clothes = wear_neck
		if(head)
			hit_clothes = head
		if(hit_clothes)
			hit_clothes.take_damage(damage_amount, damage_type, damage_flag, 0)

/mob/living/carbon/can_hear()
	. = FALSE
	var/obj/item/organ/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
	if(ears && !HAS_TRAIT(src, TRAIT_DEAF))
		. = TRUE

/mob/living/carbon/adjustOxyLoss(amount, updating_health = TRUE, forced, required_biotype)
	if(!forced && HAS_TRAIT(src, TRAIT_NOBREATH))
		amount = min(amount, 0) //Prevents oxy damage but not healing

	. = ..()
	check_passout()

/mob/living/carbon/setOxyLoss(amount, updating_health = TRUE, forced, required_biotype)
	. = ..()
	check_passout()

/**
* Check to see if we should be passed out from oxyloss
*/
/mob/living/carbon/proc/check_passout()
	var/mob_oxyloss = getOxyLoss()
	if(mob_oxyloss >= 50)
		if(!HAS_TRAIT_FROM(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT))
			ADD_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	else if(mob_oxyloss < 50)
		REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)

/mob/living/carbon/get_organic_health()
	. = health
	for (var/obj/item/bodypart/limb as anything in bodyparts)
		if (!IS_ORGANIC_LIMB(limb))
			. += (limb.brute_dam * limb.body_damage_coeff) + (limb.burn_dam * limb.body_damage_coeff)

/mob/living/carbon/bullet_act(obj/projectile/P, def_zone, piercing_hit)
	var/obj/item/bodypart/affecting = get_bodypart(check_zone(def_zone))
	if(!affecting) //missing limb? we select the first bodypart (you can never have zero, because of chest)
		affecting = bodyparts[1]
	if (P.bleed_force)
		var/armour_block = run_armor_check(affecting, BLEED, armour_penetration = P.armour_penetration, silent = TRUE)
		var/hit_amount = (100 - armour_block) / 100
		add_bleeding(P.bleed_force * hit_amount)
	if (P.damage_type == BURN && is_bleeding() && IS_ORGANIC_LIMB(affecting))
		cauterise_wounds(AMOUNT_TO_BLEED_INTENSITY(P.damage / 3))
		playsound(src, 'sound/surgery/cautery2.ogg', 70)
		to_chat(src, span_userdanger("The heat from [P] cauterizes your bleeding!"))

	return ..()

/mob/living/carbon/attack_basic_mob(mob/living/basic/user)
	. = ..()
	if(!.)
		return
	var/affected_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/dam_zone = dismembering_strike(user, affected_zone)
	if(!dam_zone) //Dismemberment successful
		return TRUE
	var/obj/item/bodypart/affecting = get_bodypart(affected_zone)
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)
	var/armor = run_armor_check(affecting, MELEE, armour_penetration = user.armour_penetration)
	apply_damage(user.melee_damage, user.melee_damage_type, affecting, armor)
	// Apply bleeding
	if (user.melee_damage_type == BRUTE)
		var/armour_block = run_armor_check(dam_zone, BLEED, armour_penetration = user.armour_penetration, silent = TRUE)
		var/hit_amount = (100 - armour_block) / 100
		add_bleeding(user.melee_damage * 0.1 * hit_amount)

/mob/living/carbon/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(!.)
		return
	var/affected_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/dam_zone = dismembering_strike(M, affected_zone)
	if(!dam_zone) //Dismemberment successful
		return TRUE
	var/obj/item/bodypart/affecting = get_bodypart(affected_zone)
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)
	var/armor = run_armor_check(affecting, MELEE, armour_penetration = M.armour_penetration)
	apply_damage(M.melee_damage, M.melee_damage_type, affecting, armor)
	// Apply bleeding
	if (M.melee_damage_type == BRUTE)
		var/armour_block = run_armor_check(dam_zone, BLEED, armour_penetration = M.armour_penetration, silent = TRUE)
		var/hit_amount = (100 - armour_block) / 100
		add_bleeding(M.melee_damage * 0.1 * hit_amount)

/mob/living/carbon/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s grab!"), \
						span_userdanger("You block [user]'s grab!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your grab at [target] was blocked!"))
		return FALSE
	if(attacker_style?.grab_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	target.grabbedby(user)
	return TRUE

/mob/living/carbon/proc/check_block()
	if(mind)
		if(mind.martial_art && prob(mind.martial_art.block_chance) && mind.martial_art.can_use(src) && throw_mode && INCAPACITATED_IGNORING(src, INCAPABLE_GRAB))
			return TRUE
	return FALSE
