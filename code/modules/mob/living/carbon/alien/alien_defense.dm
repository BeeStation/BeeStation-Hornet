/mob/living/carbon/alien/get_eye_protection()
	return ..() + 2 //potential cyber implants + natural eye protection

/mob/living/carbon/alien/get_ear_protection()
	return 2 //no ears

/mob/living/carbon/alien/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..(AM, skipcatch = TRUE, hitpush = FALSE)

//You cant knock down aliens through shoving
/mob/living/carbon/alien/is_shove_knockdown_blocked()
	return TRUE

/*Code for aliens attacking aliens. Because aliens act on a hivemind, I don't see them as very aggressive with each other.
As such, they can either help or harm other aliens. Help works like the human help command while harm is a simple nibble.
In all, this is a lot like the monkey code. /N
*/
/mob/living/carbon/alien/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	if(isturf(loc) && istype(loc.loc, /area/start))
		to_chat(user, "No attacking people at spawn, you jackass.")
		return

	var/martial_result = user.apply_martial_art(src, modifiers)
	if (martial_result != MARTIAL_ATTACK_INVALID)
		return martial_result

	if(!user.combat_mode)
		if(user == src && check_self_for_injuries())
			return
		set_resting(FALSE)
		AdjustStun(-60)
		AdjustKnockdown(-60)
		AdjustImmobilized(-60)
		AdjustParalyzed(-60)
		AdjustUnconscious(-60)
		AdjustSleeping(-100)
		visible_message("<span class='notice'>[user.name] nuzzles [src] trying to wake [p_them()] up!</span>")
	else if(health > 1)
		user.do_attack_animation(src, ATTACK_EFFECT_BITE)
		playsound(loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
		visible_message("<span class='danger'>[user.name] playfully bites [src]!</span>", \
				"<span class='userdanger'>[user.name] playfully bites you!</span>", null, COMBAT_MESSAGE_RANGE)
		to_chat(user, "<span class='danger'>You playfully bite [src]!</span>")
		adjustBruteLoss(1)
		log_combat(user, src, "attacked", user)
		updatehealth()
	else
		to_chat(user, "<span class='warning'>[name] is too injured for that.</span>")


/mob/living/carbon/alien/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	return attack_alien(L)

/mob/living/carbon/alien/attack_paw(mob/living/carbon/monkey/M)
	if(!..())
		return
	if(stat != DEAD)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.get_combat_bodyzone(src)))
		apply_damage(rand(3), BRUTE, affecting)

/mob/living/carbon/alien/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.) //to allow surgery to return properly.
		return FALSE

	var/martial_result = user.apply_martial_art(src, modifiers)
	if (martial_result != MARTIAL_ATTACK_INVALID)
		return martial_result

	if(user.combat_mode)
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			user.disarm(src)
			return TRUE
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, span_notice("You don't want to hurt [src]!"))
			return
		playsound(loc, "punch", 25, 1, -1)
		visible_message(span_danger("[user] punches [src]!"), \
				span_userdanger("[user] punches you!"), null, COMBAT_MESSAGE_RANGE)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.get_combat_bodyzone(src)))

		var/obj/item/bodypart/arm/active_arm = user.get_active_hand()
		var/damage = active_arm.unarmed_damage
		apply_damage(damage, active_arm.attack_type, affecting)
		log_combat(user, src, "attacked", user)
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		return TRUE
	else
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			user.disarm(src)
			return TRUE
		else
			help_shake_act(user)

/mob/living/carbon/alien/attack_animal(mob/living/simple_animal/M)
	if(!..())
		return
	var/damage = M.melee_damage
	switch(M.melee_damage_type)
		if(BRUTE)
			adjustBruteLoss(damage)
		if(BURN)
			adjustFireLoss(damage)
		if(TOX)
			adjustToxLoss(damage)
		if(OXY)
			adjustOxyLoss(damage)
		if(CLONE)
			adjustCloneLoss(damage)
		if(STAMINA)
			adjustStaminaLoss(damage)

/mob/living/carbon/alien/attack_slime(mob/living/simple_animal/slime/M, list/modifiers)
	if(!..())
		return //gotta be a successful slime attack
	var/damage = rand(20)
	if(M.is_adult)
		damage = rand(30)
	if(M.transformeffects & SLIME_EFFECT_RED)
		damage *= 1.1
	adjustBruteLoss(damage)
	log_combat(M, src, "attacked", M)
	updatehealth()

/mob/living/carbon/alien/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	. = ..()
	if(QDELETED(src))
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
			return

		if(EXPLODE_HEAVY)
			take_overall_damage(60, 60)
			adjustEarDamage(30,120)

		if(EXPLODE_LIGHT)
			take_overall_damage(30,0)
			if(prob(50))
				Unconscious(20)
			adjustEarDamage(15,60)

/mob/living/carbon/alien/soundbang_act(intensity = 1, stun_pwr = 20, damage_pwr = 5, deafen_pwr = 15)
	return FALSE

/mob/living/carbon/alien/acid_act(acidpwr, acid_volume)
	return FALSE//aliens are immune to acid.
