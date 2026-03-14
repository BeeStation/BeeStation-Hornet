

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M)
	if(..())
		playsound(loc, "punch", 25, 1, -1)
		log_combat(M, src, "attacked", M)
		visible_message(span_danger("[M] kicks [src]!"), \
				span_userdanger("[M] kicks you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, M)
		to_chat(M, span_danger("You kick [src]!"))
		var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(M.get_combat_bodyzone(src)))
		apply_damage(M.dna.species.punchdamage, BRUTE, affecting)

/mob/living/carbon/alien/larva/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	user.AddComponent(/datum/component/force_move, get_step_away(user,src, 30))

/mob/living/carbon/alien/larva/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()
