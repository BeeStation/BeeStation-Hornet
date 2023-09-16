/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		..(user, 1)
		apply_damage(/datum/damage_source/blunt/light, BRUTE, 15, null)
		var/hitverb = "punches"
		if(mob_size < MOB_SIZE_LARGE)
			step_away(src,user,15)
			sleep(1)
			step_away(src,user,15)
			hitverb = "slams"
		playsound(loc, "punch", 25, 1, -1)
		visible_message("<span class='danger'>[user] [hitverb] [src]!</span>", \
		"<span class='userdanger'>[user] [hitverb] you!</span>", null, COMBAT_MESSAGE_RANGE)
		return TRUE

/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	return ..()
