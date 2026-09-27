/// Stamina stun
/datum/status_effect/incapacitating/stamcrit
	id = "stamcrit"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STAMINA_STUN_TIME
	heal_flag_necessary = HEAL_STAM|HEAL_CC_STATUS

/datum/status_effect/incapacitating/stamcrit/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	if(owner.check_stun_immunity(CANKNOCKDOWN) || HAS_TRAIT(owner, TRAIT_NOSTAMCRIT))
		return FALSE
	if(SEND_SIGNAL(owner, COMSIG_LIVING_ENTER_STAMCRIT) & STAMCRIT_CANCELLED)
		return FALSE
	. = ..()
	if(!.)
		return
	owner.visible_message(
		span_danger("[owner] slumps over, too weak to continue fighting..."),
		span_userdanger("You're too exhausted to continue fighting..."),
		span_hear("You hear something hit the floor.")
	)
	owner.add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED), STAMINA)
	owner.add_filter("stamcrit", 1, drop_shadow_filter(x = 0, y = 0, size = -3, color = "#04080F"))
	owner.update_stamina_hud()

/datum/status_effect/incapacitating/stamcrit/on_remove()
	owner.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED), STAMINA)
	owner.remove_filter("stamcrit")
	owner.update_stamina_hud()
	return ..()
