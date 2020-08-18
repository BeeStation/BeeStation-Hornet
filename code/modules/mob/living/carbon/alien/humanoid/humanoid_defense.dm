
/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if ("harm")
				var/damage = M.dna.species.punchdamage
				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] punches [src]!</span>", \
						"<span class='userdanger'>[M] punches you!</span>", null, COMBAT_MESSAGE_RANGE)
				if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
					Unconscious(40)
					visible_message("<span class='danger'>[M] knocks [src] down!</span>", \
							"<span class='userdanger'>[M] knocks you down!</span>")
				var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
				apply_damage(damage, BRUTE, affecting)
				log_combat(M, src, "attacked")

			if ("disarm")
				if (!(mobility_flags & MOBILITY_STAND))
					dropItemToGround(get_active_held_item())
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] disarms [src]!</span>", \
						"<span class='userdanger'>[M] disarms you!</span>", null, COMBAT_MESSAGE_RANGE)

/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
