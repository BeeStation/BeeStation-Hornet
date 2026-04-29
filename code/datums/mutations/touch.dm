/datum/mutation/shock
	name = "Shock Touch"
	desc = "A mutation that allows the user to store accumulated bioelectric and static charge, consciously discharging it upon others with no harm to themselves."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	power_path = /datum/action/spell/touch/shock
	instability = 30
	locked = TRUE
	energy_coeff = 1
	power_coeff = 1

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	icon_state = "zapper"
	inhand_icon_state = "zapper"

/datum/action/spell/touch/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with."
	button_icon_state = "zap"
	sound = 'sound/weapons/zapbang.ogg'
	cooldown_time = 10 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE
	mindbound = FALSE
	hand_path = /obj/item/melee/touch_attack/shock
	draw_message = ("<span class='notice'>You channel electricity into your hand.</span>")
	drop_message = ("<span class='notice'>You let the electricity from your hand dissipate.</span>")

/datum/action/spell/touch/shock/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	return TRUE

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(QDELETED(target) || isturf(target))
		return
	user.Beam(target, icon_state = "lightning[rand(1, 12)]", time = 5, maxdistance = 32)
	var/zap = 15
	if(iscarbon(target))
		var/mob/living/carbon/ctarget = target
		if(ctarget.electrocute_act(zap, user, flags = SHOCK_NOSTUN)) //doesnt stun. never let this stun
			ctarget.drop_all_held_items()
			ctarget.adjust_confusion(15 SECONDS)
			ctarget.visible_message(
				span_danger("[user] electrocutes [target]!"),
				span_userdanger("[user] electrocutes you!")
			)
		else
			user.visible_message(span_warning("[user] fails to electrocute [target]!"))
	else if(isliving(target))
		var/mob/living/ltarget = target
		ltarget.electrocute_act(zap, user, flags = SHOCK_NOSTUN)
		ltarget.visible_message(span_danger("[user] electrocutes [target]!"),span_userdanger("[user] electrocutes you!"))
	else
		to_chat(user, span_warning("The electricity doesn't seem to affect [target]..."))
	remove_hand_with_no_refund(user)
	return ..()
