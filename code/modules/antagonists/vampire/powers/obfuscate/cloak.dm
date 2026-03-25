/datum/action/vampire/cloak
	name = "Cloak of Darkness"
	desc = "Shroud yourself in shadow and become completely invisible. Costs blood to upkeep while in the light, but is free in darkness."
	button_icon_state = "power_cloak"
	power_explanation = "Activate this Power to become fully invisible.\n\
		While in darkness or shadow, the cloak costs no blood to maintain.\n\
		While in the light, the cloak drains blood to sustain itself.\n\
		Additionally, while Cloak is active, you are completely invisible to silicons.\n\
		Attacking, throwing, or being set on fire will break the cloak."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 20
	constant_vitaecost = 0
	sol_multiplier = 2.5
	cooldown_time = 5 SECONDS
	/// How much blood is drained per tick while in the light.
	var/light_vitae_cost = 4
	/// Whether we are currently in shadow (no blood drain).
	var/in_shadow = FALSE

/// Must have nobody around to see the cloak
/datum/action/vampire/cloak/can_use()
	. = ..()
	if(!.)
		return FALSE

	return TRUE

/datum/action/vampire/cloak/activate_power()
	. = ..()
	check_witnesses()
	var/mob/living/user = owner
	user.AddElement(/datum/element/digital_camo)
	ADD_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))
	user.balloon_alert(user, "cloak turned on.")
	animate(user, alpha = 0, time = 1 SECONDS)
	// Apply the cloaked status effect (handles self-visibility, bump/attack disruption)
	user.apply_status_effect(/datum/status_effect/vampire_cloaked)

/datum/action/vampire/cloak/continue_active()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/user = owner
	if(user.stat != CONSCIOUS)
		to_chat(user, span_warning("Your cloak failed because you fell unconscious!"))
		return FALSE

	// Check if the cloak status was broken (by attacking, etc.)
	if(!user.has_status_effect(/datum/status_effect/vampire_cloaked))
		return FALSE

	// Check if we are in shadow or light
	var/turf/location = get_turf(user)
	var/was_in_shadow = in_shadow
	in_shadow = (!QDELETED(location?.lighting_object) && location.get_lumcount() < LIGHTING_TILE_IS_DARK) || QDELETED(location?.lighting_object)

	if(!in_shadow)
		// In light: drain blood
		var/actual_cost = light_vitae_cost
		if(user.has_status_effect(/datum/status_effect/vampire_sol))
			actual_cost *= sol_multiplier
		if(vampiredatum_power)
			if(vampiredatum_power.current_vitae < actual_cost)
				to_chat(user, span_warning("You don't have enough blood to sustain your cloak in the light!"))
				return FALSE
			vampiredatum_power.adjust_vitae(-actual_cost)
		else
			if(!HAS_TRAIT(user, TRAIT_NO_BLOOD))
				if(user.blood_volume < actual_cost)
					to_chat(user, span_warning("You don't have enough blood to sustain your cloak in the light!"))
					return FALSE
				user.blood_volume -= actual_cost
	else if(!was_in_shadow && in_shadow)
		// Just entered shadow
		to_chat(user, span_notice("The shadows embrace you. Your cloak no longer drains your blood."))

	return TRUE

/datum/action/vampire/cloak/deactivate_power()
	var/mob/living/user = owner

	animate(user, alpha = 255, time = 1 SECONDS)
	user.RemoveElement(/datum/element/digital_camo)
	REMOVE_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))
	user.remove_status_effect(/datum/status_effect/vampire_cloaked)
	user.balloon_alert(user, "cloak turned off.")
	in_shadow = FALSE
	return ..()

// Override use_power to skip the default constant_vitaecost drain (we handle it ourselves in continue_active)
/datum/action/vampire/cloak/use_power()
	if(!continue_active())
		deactivate_power()
		return FALSE
	return TRUE

/// Vampire-specific cloaked status effect. Handles self-visibility and breaks on offensive actions.
/datum/status_effect/vampire_cloaked
	id = "vampire_cloaked"
	alert_type = /atom/movable/screen/alert/status_effect/vampire_cloaked
	tick_interval = -1
	duration = -1
	/// Whether we've applied the self-visibility alt appearance.
	var/can_see_self = FALSE

/datum/status_effect/vampire_cloaked/on_apply()
	if(!..())
		return FALSE
	// Make it so the user can always see themselves while cloaked
	var/mutable_appearance/self_appearance = mutable_appearance('icons/hud/actions/actions_minor_antag.dmi', "ninja_cloak")
	self_appearance.alpha = 100
	self_appearance.override = TRUE
	owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, REF(src), image(self_appearance, loc = owner), owner)
	can_see_self = TRUE
	// Register signals for things that break the cloak
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(break_cloak))
	RegisterSignal(owner, COMSIG_MOB_ITEM_AFTERATTACK, PROC_REF(break_cloak))
	RegisterSignal(owner, COMSIG_MOB_THROW, PROC_REF(break_cloak))
	RegisterSignal(owner, COMSIG_ATOM_ATTACKBY, PROC_REF(break_cloak))
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_HAND, PROC_REF(break_cloak))
	return TRUE

/datum/status_effect/vampire_cloaked/on_remove()
	if(can_see_self)
		owner.remove_alt_appearance(REF(src))
		can_see_self = FALSE
	UnregisterSignal(owner, list(
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_ITEM_AFTERATTACK,
		COMSIG_MOB_THROW,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
	))

/datum/status_effect/vampire_cloaked/proc/break_cloak()
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/vampire_cloaked
	name = "Cloaked in Darkness"
	desc = "You are shrouded in shadow, invisible to the world. Attacking will break the cloak."
	icon_state = "cloak"
