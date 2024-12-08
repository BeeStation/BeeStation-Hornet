/// For actions that are innate and not directly tied to a master datum
/datum/action/innate
	/// If we're a click action, the text shown on enable
	var/enable_text
	/// If we're a click action, the text shown on disable
	var/disable_text

/datum/action/innate/set_click_ability(mob/on_who)
	. = ..()
	if (enable_text && requires_target)
		to_chat(on_who, enable_text)

/datum/action/innate/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	if (disable_text && requires_target)
		to_chat(on_who, disable_text)

/datum/action/innate/on_activate(mob/user, atom/target)
	if (enable_text && !requires_target)
		to_chat(user, enable_text)

/datum/action/innate/on_deactivate(mob/user, atom/target)
	if (disable_text && !requires_target)
		to_chat(user, disable_text)

