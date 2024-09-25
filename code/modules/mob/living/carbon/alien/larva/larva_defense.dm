

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M)
	if(..())
		playsound(loc, "punch", 25, 1, -1)
		log_combat(M, src, "attacked")
		visible_message("<span class='danger'>[M] kicks [src]!</span>", \
				"<span class='userdanger'>[M] kicks you!</span>", null, COMBAT_MESSAGE_RANGE)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.get_combat_bodyzone(src)))
		apply_damage(M.dna.species.punchdamage, BRUTE, affecting)

/mob/living/carbon/alien/larva/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.a_intent == INTENT_HARM)
		..(user, 1)
		adjustBruteLoss(5 + rand(1,9))
		user.AddComponent(/datum/component/force_move, get_step_away(user,src, 30))
		return 1

/mob/living/carbon/alien/larva/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()
