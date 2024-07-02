/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		..(user, 1)
		adjustBruteLoss(15)
		var/hitverb = "hit"
		if(mob_size < MOB_SIZE_LARGE)
			step_away(src,user,15)
			sleep(1)
			step_away(src,user,15)
			hitverb = "slam"
		playsound(loc, "punch", 25, 1, -1)
		visible_message("<span class='danger'>[user] [hitverb]s [src]!</span>", \
					"<span class='userdanger'>[user] [hitverb]s you!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, user)
		to_chat(user, "<span class='danger'>You [hitverb] [src]!</span>")
		return TRUE

/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	return ..()
