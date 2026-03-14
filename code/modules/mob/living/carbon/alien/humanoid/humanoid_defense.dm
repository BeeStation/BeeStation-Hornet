/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(15)
	var/hitverb = "hit"
	if(mob_size < MOB_SIZE_LARGE)
		safe_throw_at(get_edge_target_turf(src, get_dir(user, src)), 2, 1, user)
		hitverb = "slam"
	playsound(loc, "punch", 25, 1, -1)
	visible_message(span_danger("[user] [hitverb]s [src]!"), \
				span_userdanger("[user] [hitverb]s you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You [hitverb] [src]!"))

/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	return ..()
