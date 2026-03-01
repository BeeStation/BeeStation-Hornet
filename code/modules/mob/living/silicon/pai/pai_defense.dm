
/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return FALSE

/mob/living/silicon/pai/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	take_holo_damage(50/severity)
	Paralyze(400/severity)
	silent = max(30/severity, silent)
	if(holoform)
		fold_in(force = TRUE)
	//Need more effects that aren't instadeath or permanent law corruption.

/mob/living/silicon/pai/ex_act(severity, target)
	take_holo_damage(severity * 50)
	switch(severity)
		if(1)	//RIP
			qdel(card)
			qdel(src)
		if(2)
			fold_in(force = 1)
			Paralyze(400)
		if(3)
			fold_in(force = 1)
			Paralyze(200)

/mob/living/silicon/pai/attack_hand(mob/living/carbon/human/user, modifiers)
	if(user.combat_mode)
		user.do_attack_animation(src)
		if (user.name == master)
			visible_message("<span class='notice'>Responding to its master's touch, [src] disengages its holochassis emitter, rapidly losing coherence.</span>")
			if(do_after(user, 1 SECONDS, TRUE, src))
				fold_in()
				if(user.put_in_hands(card))
					user.visible_message("<span class='notice'>[user] promptly scoops up [user.p_their()] pAI's card.</span>")
		else
			visible_message("<span class='danger'>[user] stomps on [src]!.</span>")
			take_holo_damage(2)
	else
		visible_message("<span class='notice'>[user] gently pats [src] on the head, eliciting an off-putting buzzing from its holographic field.</span>")

/mob/living/silicon/pai/bullet_act(obj/projectile/Proj)
	if(Proj.stun)
		fold_in(force = TRUE)
		src.visible_message(span_warning("The electrically-charged projectile disrupts [src]'s holomatrix, forcing [src] to fold in!"))
	. = ..(Proj)

/mob/living/silicon/pai/ignite_mob(silent)
	return FALSE //No we're not flammable

/mob/living/silicon/pai/proc/take_holo_damage(amount)
	emitterhealth = clamp((emitterhealth - amount), -50, emittermaxhealth)
	if(emitterhealth < 0)
		fold_in(force = TRUE)
	if(amount > 0)
		to_chat(src, span_userdanger("The impact degrades your holochassis!"))
	return amount

// Called when we take burn or brute damage, pass it to the shell instead
/mob/living/silicon/pai/proc/on_shell_damaged(datum/hurt, type, amount, forced)
	take_holo_damage(amount)
	return COMPONENT_IGNORE_CHANGE

/// Called when we take stamina damage, pass it to the shell instead
/mob/living/silicon/pai/proc/on_shell_weakened(datum/hurt, type, amount, forced)
	take_holo_damage(amount * ((forced) ? 1 : 0.25))
	return COMPONENT_IGNORE_CHANGE

/mob/living/silicon/pai/getBruteLoss()
	return emittermaxhealth - emitterhealth

/mob/living/silicon/pai/getFireLoss()
	return emittermaxhealth - emitterhealth
