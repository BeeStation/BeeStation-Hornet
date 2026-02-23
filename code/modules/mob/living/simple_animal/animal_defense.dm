/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M, modifiers)
	// so that martial arts don't double dip
	if (..())
		return TRUE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		var/shove_dir = get_dir(M, src)
		if(!Move(get_step(src, shove_dir), shove_dir))
			log_combat(M, src, "shoved", "combat mode", "failing to move it")
			M.visible_message("<span class='danger'>[M.name] shoves [src]!</span>",
				"<span class='danger'>You shove [src]!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", COMBAT_MESSAGE_RANGE, list(src))
			to_chat(src, "<span class='userdanger'>You're shoved by [M.name]!</span>")
			return TRUE

	if(!M.combat_mode)
		if (stat == DEAD)
			return
		visible_message("<span class='notice'>[M] [response_help_continuous] [src].</span>", \
						"<span class='notice'>[M] [response_help_continuous] you.</span>", null, null, M)
		to_chat(M, "<span class='notice'>You [response_help_simple] [src].</span>")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)


	else
		if(HAS_TRAIT(M, TRAIT_PACIFISM))
			to_chat(M, "<span class='warning'>You don't want to hurt [src]!</span>")
			return
		M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		visible_message("<span class='danger'>[M] [response_harm_continuous] [src]!</span>",\
						"<span class='userdanger'>[M] [response_harm_continuous] you!</span>", null, COMBAT_MESSAGE_RANGE, M)
		to_chat(M, "<span class='danger'>You [response_harm_simple] [src]!</span>")
		playsound(loc, attacked_sound, 25, TRUE, -1)
		attack_threshold_check(M.dna.species.punchdamage)
		log_combat(M, src, "attacked")
		updatehealth()
		return TRUE

/mob/living/simple_animal/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.combat_mode)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, span_notice("You don't want to hurt [src]!"))
			return FALSE
		..(user, 1)
		playsound(loc, "punch", 25, 1, -1)
		visible_message(span_danger("[user] punches [src]!"), \
				span_userdanger("You're punched by [user]!"), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You punch [src]!"))
		adjustBruteLoss(15)
		return TRUE

/mob/living/simple_animal/attack_paw(mob/living/carbon/monkey/M)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			var/damage = rand(1, 3)
			attack_threshold_check(damage)
			return 1
	if (!M.combat_mode)
		if (health > 0)
			visible_message(span_notice("[M.name] [response_help_continuous] [src]."), \
							span_notice("[M.name] [response_help_continuous] you."), null, COMBAT_MESSAGE_RANGE, M)
			to_chat(M, span_notice("You [response_help_simple] [src]."))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)


/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/humanoid/M, modifiers)
	if(..()) //if harm or disarm intent.
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			visible_message(span_danger("[M] [response_disarm_continuous] [name]!"), \
							span_userdanger("[M] [response_disarm_continuous] you!"), null, COMBAT_MESSAGE_RANGE, M)
			to_chat(M, span_danger("You [response_disarm_simple] [name]!"))
			log_combat(M, src, "disarmed", "disarm")
		else
			var/damage = rand(15, 30)
			visible_message(span_danger("[M] slashes at [src]!"), \
							span_userdanger("You're slashed at by [M]!"), null, COMBAT_MESSAGE_RANGE, M)
			to_chat(M, span_danger("You slash at [src]!"))
			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			attack_threshold_check(damage)
			log_combat(M, src, "attacked", "harm")
		return 1

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	. = ..()
	if(. && stat != DEAD) //successful larva bite
		var/damage = rand(5, 10)
		. = attack_threshold_check(damage)
		if(.)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = M.melee_damage
		return attack_threshold_check(damage, M.melee_damage_type)

/mob/living/simple_animal/attack_slime(mob/living/simple_animal/slime/M, list/modifiers)
	if(..()) //successful slime attack
		var/damage = 20
		if(M.is_adult)
			damage = 30
		if(M.transformeffects & SLIME_EFFECT_RED)
			damage *= 1.1
		return attack_threshold_check(damage)

/mob/living/simple_animal/attack_drone(mob/living/simple_animal/drone/M)
	if(M.combat_mode) //No kicking dogs even as a rogue drone. Use a weapon.
		return
	return ..()

/mob/living/simple_animal/attack_drone_secondary(mob/living/simple_animal/drone/M)
	if(M.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/simple_animal/proc/attack_threshold_check(damage, damagetype = BRUTE, armorcheck = MELEE, actuallydamage = TRUE)
	var/temp_damage = damage
	if(!damage_coeff[damagetype])
		temp_damage = 0
	else
		temp_damage *= damage_coeff[damagetype]

	if(temp_damage >= 0 && temp_damage <= force_threshold)
		visible_message(span_warning("[src] looks unharmed!"))
		return FALSE
	else
		if(actuallydamage)
			apply_damage(damage, damagetype, null, getarmor(null, armorcheck))
		return TRUE

/mob/living/simple_animal/bullet_act(obj/projectile/Proj, def_zone, piercing_hit = FALSE)
	var/bullet_signal = SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, Proj, def_zone)
	if(bullet_signal & COMSIG_ATOM_BULLET_ACT_FORCE_PIERCE)
		return BULLET_ACT_FORCE_PIERCE
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_BLOCK)
		return BULLET_ACT_BLOCK
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_HIT)
		return BULLET_ACT_HIT
	apply_damage(Proj.damage, Proj.damage_type)
	Proj.on_hit(src, 0, piercing_hit)
	return BULLET_ACT_HIT

/mob/living/simple_animal/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if(QDELETED(src))
		return
	var/bomb_armor = getarmor(null, BOMB)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(prob(bomb_armor))
				adjustBruteLoss(500)
			else
				investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
				gib()
				return
		if (EXPLODE_HEAVY)
			var/bloss = 60
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

		if(EXPLODE_LIGHT)
			var/bloss = 30
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

/mob/living/simple_animal/blob_act(obj/structure/blob/B)
	adjustBruteLoss(20)
	return

/mob/living/simple_animal/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect)
	if(!no_effect && !visual_effect_icon && melee_damage)
		if(melee_damage < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()
