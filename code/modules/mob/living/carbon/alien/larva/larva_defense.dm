

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M)
	if(..())
		var/damage = M.dna.species.punchdamage
		playsound(loc, "punch", 25, 1, -1)
		log_combat(M, src, "attacked")
		visible_message("<span class='danger'>[M] kicks [src]!</span>", \
				"<span class='userdanger'>[M] kicks you!</span>", null, COMBAT_MESSAGE_RANGE)
		if ((stat != DEAD) && (damage > 4.9))
			Unconscious(rand(100,200))

/mob/living/carbon/alien/larva/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()
