/mob/living/carbon/monkey/help_shake_act(mob/living/carbon/M)
	if(health < 0 && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.do_cpr(src)
	else
		..()

/mob/living/carbon/monkey/attack_paw(mob/living/M)
	if(..()) //successful monkey bite.
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		if(M.limb_destroyer)
			dismembering_strike(M, affecting.body_zone)
		if(stat != DEAD)
			var/dmg = rand(1, 5)
			apply_damage(dmg, BRUTE, affecting)

/mob/living/carbon/monkey/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.get_combat_bodyzone(src)))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			apply_damage(damage, BRUTE, affecting)

/mob/living/carbon/monkey/attack_hand(mob/living/carbon/human/M, list/modifiers)
	if(..())	//To allow surgery to return properly.
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(stat < UNCONSCIOUS)
			M.disarm(src)
			return
	if(M.combat_mode)
		M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		visible_message("<span class='danger'>[M] punches [name]!</span>", \
				"<span class='userdanger'>[M] punches you!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, M)
		to_chat(M, "<span class='danger'>You punch [name]!</span>")
		playsound(loc, "punch", 25, 1, -1)
		var/obj/item/bodypart/arm/active_arm = M.get_active_hand()
		var/damage = active_arm.unarmed_damage
		var/obj/item/bodypart/affecting = get_bodypart(check_zone(M.get_combat_bodyzone(src)))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		apply_damage(damage, BRUTE, affecting)
		log_combat(M, src, "attacked", "harm")
	else
		help_shake_act(M)

/mob/living/carbon/monkey/attack_alien(mob/living/carbon/alien/humanoid/M, modifiers)
	if(..()) //if harm or disarm intent.
		if (M.combat_mode)
			if ((prob(95) && health > 0))
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					if(AmountUnconscious() < 300)
						Unconscious(rand(200, 300))
					visible_message(span_danger("[M] wounds [name]!"), \
									span_userdanger("[M] wounds you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, M)
					to_chat(M, span_danger("You wound [name]!"))
				else
					visible_message(span_danger("[M] slashes [name]!"), \
									span_userdanger("[M] slashes you!"), span_hear("You hear a sickening sound of a slice!"), COMBAT_MESSAGE_RANGE, M)
					to_chat(M, span_danger("You slash [name]!"))

				var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.get_combat_bodyzone(src)))
				log_combat(M, src, "attacked", M)
				if(!affecting)
					affecting = get_bodypart(BODY_ZONE_CHEST)
				if(!dismembering_strike(M, affecting.body_zone)) //Dismemberment successful
					return 1
				apply_damage(damage, BRUTE, affecting)

			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				visible_message(span_danger("[M]'s lunge misses [name]!"), \
								span_danger("You avoid [M]'s lunge!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, M)
				to_chat(M, span_warning("Your lunge misses [name]!"))

		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			var/obj/item/I = null
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			if(prob(95))
				Paralyze(20)
				visible_message(span_danger("[M] tackles [name] down!"), \
								span_userdanger("[M] tackles you down!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, M)
				to_chat(M, span_danger("You tackle [name] down!"))
			else
				I = get_active_held_item()
				if(dropItemToGround(I))
					visible_message(span_danger("[M] disarms [name]!"), \
									span_userdanger("[M] disarms you!"), span_hear("You hear aggressive shuffling!"), COMBAT_MESSAGE_RANGE, M)
					to_chat(M, span_danger("You disarm [name]!"))
				else
					I = null
			log_combat(M, src, "disarmed", null, "[I ? " removing \the [I]" : ""]", important = FALSE)
			updatehealth()


/mob/living/carbon/monkey/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = M.melee_damage
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return TRUE
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		apply_damage(damage, M.melee_damage_type, affecting)

/mob/living/carbon/monkey/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = 20
		if(M.is_adult)
			damage = 30
		if(M.transformeffects & SLIME_EFFECT_RED)
			damage *= 1.1
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return 1
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		apply_damage(damage, BRUTE, affecting)

/mob/living/carbon/monkey/acid_act(acidpwr, acid_volume, bodyzone_hit)
	. = 1
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD)
		if(wear_mask)
			if(!(wear_mask.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE)))
				wear_mask.acid_act(acidpwr, acid_volume)
			else
				to_chat(src, span_warning("Your mask protects you from the acid."))
			return
		if(head)
			if(!(head.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE)))
				head.acid_act(acidpwr, acid_volume)
			else
				to_chat(src, span_warning("Your hat protects you from the acid."))
			return
	take_bodypart_damage(acidpwr * min(0.6, acid_volume*0.1))


/mob/living/carbon/monkey/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if(QDELETED(src))
		return
	var/obj/item/organ/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			gib()
			return

		if (EXPLODE_HEAVY)
			take_overall_damage(60, 60)
			damage_clothes(200, BRUTE, BOMB)
			if (ears && !HAS_TRAIT_FROM_ONLY(src, TRAIT_DEAF, EAR_DAMAGE))
				ears.adjustEarDamage(30, 120)
			Unconscious(200)

		if(EXPLODE_LIGHT)
			take_overall_damage(30, 0)
			damage_clothes(50, BRUTE, BOMB)
			if (ears && !HAS_TRAIT_FROM_ONLY(src, TRAIT_DEAF, EAR_DAMAGE))
				ears.adjustEarDamage(15,60)
			Unconscious(160)


	//attempt to dismember bodyparts
	if(severity <= 2)
		var/max_limb_loss = round(4/severity) //so you don't lose four limbs at severity 3.
		for(var/obj/item/bodypart/BP as() in bodyparts)
			if(prob(50/severity) && BP.body_zone != BODY_ZONE_CHEST)
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break
