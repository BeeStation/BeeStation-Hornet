
/mob/living/silicon/grippedby(mob/living/user, instant = FALSE)
	return //can't upgrade a simple pull into a more aggressive grab.

/mob/living/silicon/get_ear_protection()//no ears
	return 2

/mob/living/silicon/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent
		var/damage = 20
		if (prob(90))
			log_combat(M, src, "attacked", M)
			playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			visible_message(span_danger("[M] slashes at [src]!"), \
							span_userdanger("[M] slashes at you!"), null, null, M)
			to_chat(M, span_danger("You slash at [src]!"))
			if(prob(8))
				flash_act(affect_silicon = 1)
			log_combat(M, src, "attacked", M)
			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
			visible_message(span_danger("[M]'s swipe misses [src]!"), \
							span_danger("You avoid [M]'s swipe!"), null, null, M)
			to_chat(M, span_warning("Your swipe misses [src]!"))

/mob/living/silicon/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = M.melee_damage
		if(prob(damage))
			for(var/mob/living/N in buckled_mobs)
				N.Paralyze(20)
				unbuckle_mob(N)
				N.visible_message(span_danger("[N] is knocked off of [src] by [M]!"), \
								span_userdanger("You're knocked off of [src] by [M]!"), null, null, M)
				to_chat(M, span_danger("You knock [N] off of [src]!"))
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

/mob/living/silicon/attack_paw(mob/living/user)
	return attack_hand(user)

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(!L.combat_mode)
		visible_message("<span class='notice'>[L.name] rubs its head against [src].</span>")

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.combat_mode)
		..(user, 1)
		adjustBruteLoss(rand(10, 15))
		playsound(loc, "punch", 25, 1, -1)
		visible_message(span_danger("[user] punches [src]!"), \
				span_userdanger("[user] punches you!"), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You punch [src]!"))
		return 1
	return 0

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/attack_hand(mob/living/carbon/human/user, modifiers)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE
	if(has_buckled_mobs() && !user.combat_mode)
		user_unbuckle_mob(buckled_mobs[1], user)
	else
		if(user.combat_mode)
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				to_chat(user, "<span class='notice'>You don't want to hurt [src]!</span>")
				return
			user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			playsound(src.loc, 'sound/effects/bang.ogg', 10, TRUE)
			visible_message(span_danger("[user] punches [src], but doesn't leave a dent!"), \
							span_warning("[user] punches you, but doesn't leave a dent!"), null, COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("You punch [src], but don't leave a dent!"))
			log_combat(user, src, "tried to punch", important = FALSE)
		else
			visible_message(span_notice("[user] pets [src]."), \
							span_notice("[user] pets you."), null, null, user)
			to_chat(user, span_notice("You pet [src]."))


/mob/living/silicon/attack_drone(mob/living/simple_animal/drone/M)
	if(M.combat_mode)
		return
	return ..()

/mob/living/silicon/attack_drone_secondary(mob/living/simple_animal/drone/M)
	if(M.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/silicon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	if(buckled_mobs)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.electrocute_act(shock_damage/100, source, siemens_coeff, flags) //Hard metal shell conducts!
	return 0 //So borgs they don't die trying to fix wiring

/mob/living/silicon/emp_act(severity)
	. = ..()
	to_chat(src, span_danger("Warning: Electromagnetic pulse detected."))
	if(. & EMP_PROTECT_SELF)
		return

	//Light EMP does 20 damage, heavy EMP does 40.
	adjustFireLoss(40/severity, FALSE)

	for(var/mob/living/M in buckled_mobs)
		if(prob(100/severity))
			unbuckle_mob(M)
			M.Paralyze(4 SECONDS)
			M.visible_message(span_boldwarning("[M] is thrown off of [src]!"))
	flash_act(affect_silicon = 1)

/mob/living/silicon/bullet_act(obj/projectile/Proj, def_zone, piercing_hit = FALSE)
	var/bullet_signal = SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, Proj, def_zone)
	if(bullet_signal & COMSIG_ATOM_BULLET_ACT_FORCE_PIERCE)
		return BULLET_ACT_FORCE_PIERCE
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_BLOCK)
		return BULLET_ACT_BLOCK
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_HIT)
		return BULLET_ACT_HIT
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		adjustBruteLoss(Proj.damage)
		if(prob(Proj.damage*1.5))
			for(var/mob/living/M in buckled_mobs)
				M.visible_message(span_boldwarning("[M] is knocked off of [src]!"))
				unbuckle_mob(M)
				M.Paralyze(4 SECONDS)
	if(Proj.stun || Proj.knockdown || Proj.paralyze)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.visible_message(span_boldwarning("[M] is knocked off of [src] by the [Proj]!"))
	Proj.on_hit(src, 0, piercing_hit)
	return BULLET_ACT_HIT

/mob/living/silicon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash/static)
	if(affect_silicon)
		return ..()
